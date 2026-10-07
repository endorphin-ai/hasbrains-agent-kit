package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"os"
	"strings"
	"sync"
	"time"
)

// tokens is the token use of one or more API responses.
type tokens struct {
	In, Out, CacheWrite, CacheRead int64
}

func (t *tokens) add(o tokens) {
	t.In += o.In
	t.Out += o.Out
	t.CacheWrite += o.CacheWrite
	t.CacheRead += o.CacheRead
}

// context is the size of the request that produced the response.
func (t tokens) context() int64 {
	return t.In + t.CacheWrite + t.CacheRead
}

type message struct {
	model string
	t     tokens
}

// transcript is the running total of one .jsonl transcript. Claude Code only
// appends to a transcript, so each read continues where the last one stopped.
type transcript struct {
	offset    int64
	lastUsed  time.Time
	messages  map[string]message // by API message id
	tools     map[string]struct{}
	firstTS   int64
	lastTS    int64
	lastModel string
	lastCtx   int64
	lastStop  string // stop_reason of the last response; "end_turn" means finished
	cwd       string
}

var transcripts = struct {
	sync.Mutex
	byPath map[string]*transcript
}{byPath: map[string]*transcript{}}

type transcriptLine struct {
	Type      string `json:"type"`
	Sidechain bool   `json:"isSidechain"`
	Cwd       string `json:"cwd"`
	Timestamp string `json:"timestamp"`
	Message   struct {
		ID         string `json:"id"`
		Model      string `json:"model"`
		StopReason string `json:"stop_reason"`
		Usage      struct {
			usage
			Output flex `json:"output_tokens"`
		} `json:"usage"`
		Content []struct {
			Type string `json:"type"`
			ID   string `json:"id"`
		} `json:"content"`
	} `json:"message"`
}

func parseTS(s string) int64 {
	t, err := time.Parse(time.RFC3339Nano, s)
	if err != nil {
		return 0
	}
	return t.Unix()
}

// readTranscript brings the totals of a transcript up to date. mainLoop skips
// sidechain lines, so a session total does not include its subagents.
func readTranscript(path string, mainLoop bool) *transcript {
	transcripts.Lock()
	defer transcripts.Unlock()
	now := time.Now()
	for p, t := range transcripts.byPath {
		if now.Sub(t.lastUsed) > time.Hour {
			delete(transcripts.byPath, p)
		}
	}

	fh, err := os.Open(path)
	if err != nil {
		return nil
	}
	defer fh.Close()
	st, err := fh.Stat()
	if err != nil {
		return nil
	}
	t := transcripts.byPath[path]
	if t == nil || st.Size() < t.offset {
		t = &transcript{messages: map[string]message{}, tools: map[string]struct{}{}}
		transcripts.byPath[path] = t
	}
	t.lastUsed = now
	if st.Size() == t.offset {
		return t
	}
	if _, err := fh.Seek(t.offset, io.SeekStart); err != nil {
		return t
	}
	r := bufio.NewReaderSize(fh, 1<<20)
	for {
		line, err := r.ReadBytes('\n')
		if err != nil {
			// A line without its newline is still being written; read it next time.
			if !errors.Is(err, io.EOF) {
				return t
			}
			break
		}
		t.offset += int64(len(line))
		t.addLine(line, mainLoop)
	}
	return t
}

func (t *transcript) addLine(line []byte, mainLoop bool) {
	isAssistant := bytes.Contains(line, []byte(`"type":"assistant"`))
	// Tool results can be very large; only decode the lines that are needed.
	if !isAssistant && t.firstTS != 0 {
		return
	}
	var l transcriptLine
	if json.Unmarshal(line, &l) != nil {
		return
	}
	ts := parseTS(l.Timestamp)
	if t.firstTS == 0 {
		t.firstTS = ts
	}
	m := l.Message
	if l.Type != "assistant" || (mainLoop && l.Sidechain) || !strings.HasPrefix(m.Model, "claude") {
		return
	}
	use := tokens{
		In:         int64(m.Usage.Input),
		Out:        int64(m.Usage.Output),
		CacheWrite: int64(m.Usage.CacheCreation),
		CacheRead:  int64(m.Usage.CacheRead),
	}
	// One response is logged as several lines that repeat its usage. Keep
	// the last one per message id, or the tokens count several times.
	if old, ok := t.messages[m.ID]; !ok || use.Out >= old.t.Out {
		t.messages[m.ID] = message{model: m.Model, t: use}
	}
	for _, c := range m.Content {
		if c.Type == "tool_use" && c.ID != "" {
			t.tools[c.ID] = struct{}{}
		}
	}
	if ts > 0 {
		t.lastTS = ts
	}
	if use.context() > 0 {
		t.lastCtx = use.context()
	}
	t.lastModel, t.lastStop = m.Model, m.StopReason
	if l.Cwd != "" {
		t.cwd = l.Cwd
	}
}

// byModel sums the tokens per model id.
func (t *transcript) byModel() map[string]tokens {
	out := map[string]tokens{}
	for _, m := range t.messages {
		sum := out[m.model]
		sum.add(m.t)
		out[m.model] = sum
	}
	return out
}

// ModelPrice is the price of one model family in USD per million tokens.
type ModelPrice struct {
	Match      string  `json:"match"` // part of the model id, e.g. "opus"; "*" matches every model
	In         float64 `json:"in"`
	Out        float64 `json:"out"`
	CacheWrite float64 `json:"cacheWrite"`
	CacheRead  float64 `json:"cacheRead"`
}

// pricesVersion is raised when defaultPrices changes, so a config that still
// has an older default table gets the new one.
const pricesVersion = 2

// defaultPrices are Anthropic's API list prices. The rows are tried in
// order, so a specific id comes before its family. Cache write is the
// 5-minute rate, 1.25 x input.
func defaultPrices() []ModelPrice {
	return []ModelPrice{
		{Match: "fable-5-1", In: 10, Out: 50, CacheWrite: 12.5, CacheRead: 0.25},
		{Match: "fable", In: 10, Out: 50, CacheWrite: 12.5, CacheRead: 1},
		{Match: "opus-5-5", In: 4, Out: 20, CacheWrite: 5, CacheRead: 0.2},
		{Match: "opus", In: 5, Out: 25, CacheWrite: 6.25, CacheRead: 0.5},
		{Match: "sonnet-5", In: 2, Out: 10, CacheWrite: 2.5, CacheRead: 0.2},
		{Match: "sonnet", In: 3, Out: 15, CacheWrite: 3.75, CacheRead: 0.3},
		{Match: "haiku", In: 1, Out: 5, CacheWrite: 1.25, CacheRead: 0.1},
		{Match: "*", In: 3, Out: 15, CacheWrite: 3.75, CacheRead: 0.3},
	}
}

// priceFor returns the first price row that matches the model id.
func (c Config) priceFor(model string) (ModelPrice, bool) {
	model = strings.ToLower(model)
	for _, p := range c.Prices {
		if p.Match == "*" || strings.Contains(model, strings.ToLower(p.Match)) {
			return p, true
		}
	}
	return ModelPrice{}, false
}

// cost prices the tokens of a transcript. priced is false when no row
// matches one of its models.
func (c Config) cost(byModel map[string]tokens) (usd float64, priced bool) {
	priced = len(byModel) > 0
	for model, t := range byModel {
		p, ok := c.priceFor(model)
		if !ok {
			priced = false
			continue
		}
		usd += (float64(t.In)*p.In + float64(t.Out)*p.Out +
			float64(t.CacheWrite)*p.CacheWrite + float64(t.CacheRead)*p.CacheRead) / 1e6
	}
	return usd, priced
}

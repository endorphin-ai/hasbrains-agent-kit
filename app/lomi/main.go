package main

import (
	"embed"
	_ "embed"
	"log"

	"github.com/wailsapp/wails/v3/pkg/application"
	"github.com/wailsapp/wails/v3/pkg/events"
)

//go:embed all:frontend/dist
var assets embed.FS

//go:embed assets/trayicon.png
var trayIcon []byte

const homepage = "https://hasbrains.com/"

func main() {
	deck := NewDeckService()

	// Lomi lives in the menu bar: no Dock icon, and the window opens
	// under the menu bar item.
	app := application.New(application.Options{
		Name:        "Lomi",
		Description: "The Claude Code status line in the menu bar",
		Services: []application.Service{
			application.NewService(deck),
		},
		Assets: application.AssetOptions{
			Handler: application.AssetFileServerFS(assets),
		},
		Mac: application.MacOptions{
			ActivationPolicy: application.ActivationPolicyAccessory,
		},
	})

	pinned := deck.cfg.AlwaysOnTop
	window := app.Window.NewWithOptions(application.WebviewWindowOptions{
		Title:            "Lomi",
		Width:            880,
		Height:           620,
		MinWidth:         520,
		MinHeight:        260,
		Frameless:        true,
		Hidden:           true,
		AlwaysOnTop:      pinned,
		HideOnEscape:     true,
		HideOnFocusLost:  !pinned,
		BackgroundColour: application.NewRGB(17, 18, 23),
		URL:              "/",
	})
	// Closing the window only hides it; Quit is in the menu bar menu.
	window.RegisterHook(events.Common.WindowClosing, func(e *application.WindowEvent) {
		window.Hide()
		e.Cancel()
	})

	tray := app.SystemTray.New()
	tray.SetTemplateIcon(trayIcon)
	tray.SetTooltip("Lomi")
	tray.AttachWindow(window).WindowOffset(6)

	menu := app.NewMenu()
	menu.Add("Open Lomi").OnClick(func(*application.Context) { tray.ShowWindow() })
	menu.Add("hasbrains.com").OnClick(func(*application.Context) { app.Browser.OpenURL(homepage) })
	menu.AddSeparator()
	menu.Add("Quit Lomi").OnClick(func(*application.Context) { app.Quit() })
	tray.SetMenu(menu)

	deck.window, deck.tray = window, tray
	app.Event.OnApplicationEvent(events.Common.ApplicationStarted, func(*application.ApplicationEvent) {
		go deck.watch()
		tray.ShowWindow() // show once at launch, so the app is not invisible
	})

	if err := app.Run(); err != nil {
		log.Fatal(err)
	}
}

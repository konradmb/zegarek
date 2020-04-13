import gintro/[gtk, gdk, glib, gobject, gio]
import times
import os, system

let appdir = os.getAppDir() / "/"

var continueClockUpdates = true
var label: Label

proc updateClock(label: Label): bool =
  let time = getTime().format("HH:mm:ss:fff")
  label.text = time
  continueClockUpdates

proc addClockTimer() =
  timeoutAdd(1, updateClock, label)

proc pauseClock(button: Button) =
  continueClockUpdates = not continueClockUpdates
  if continueClockUpdates:
    addClockTimer()

proc appActivateWithBuilder(app: Application) =
  let builder = newBuilder()
  discard builder.addFromFile(appdir & "main.glade")
  let window = builder.getApplicationWindow("window")
  window.setApplication(app)
  if existsFile(appdir / "../../zegarek-icon.svg"):
    discard window.setIconFromFile(appdir / "../../zegarek-icon.svg")
  elif existsFile(appdir / "../res/zegarek-icon.svg"):
    discard window.setIconFromFile(appdir / "../res/zegarek-icon.svg")

  label = builder.getLabel("timeLabel")

  addClockTimer()

  let screen = getDefaultScreen()
  let cssProvider = newCssProvider()
  discard cssProvider.loadFromPath(appdir & "main.css")
  addProviderForScreen(screen, cssProvider, STYLE_PROVIDER_PRIORITY_APPLICATION)

  var button = builder.getButton("pause")
  button.connect("clicked", pauseClock)

  showAll(window)

proc main: int =
  let app = newApplication("com.github.konradmb.zegarek", {ApplicationFlag.nonUnique})
  connect(app, "activate", appActivateWithBuilder)
  return run(app)

main().quit()
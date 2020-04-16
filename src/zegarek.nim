import gintro/[gtk, gdk, glib, gobject, gio]
import os, system
import libintl

import clockTimer

const gettextPackage = "zegarek"
let appdir = os.getAppDir() / "/"

proc isAppimage(): bool =
  existsEnv("APPIMAGE")

proc appActivateWithBuilder(app: Application) =
  let builder = newBuilder()
  discard builder.addFromFile(appdir & "main.glade")
  let window = builder.getApplicationWindow("window")
  window.setApplication(app)
  if existsFile(appdir / "../../zegarek-icon.svg"):
    discard window.setIconFromFile(appdir / "../../zegarek-icon.svg")
  elif existsFile(appdir / "../res/zegarek-icon.svg"):
    discard window.setIconFromFile(appdir / "../res/zegarek-icon.svg")

  builder.getLabel("timeLabel").startClockTimer()

  var button = builder.getButton("pause")
  button.connect("clicked", pauseClock)

  builder.getSpinButton("resolution").setSpinButton()

  builder.getToggleButton("12Hours").connect12HoursButton()
  builder.getToggleButton("24Hours").connect24HoursButton()

  let screen = getDefaultScreen()
  let cssProvider = newCssProvider()
  discard cssProvider.loadFromPath(appdir & "main.css")
  addProviderForScreen(screen, cssProvider, STYLE_PROVIDER_PRIORITY_APPLICATION)

  showAll(window)

proc activateGettext() =
  discard setlocale(LC_ALL, "")
  if existsDir(appdir /../ "build/locale"):
    assert appdir /../ "build/locale" == bindtextdomain(gettextPackage, appdir /../ "build/locale");
  elif existsDir(appdir /../ "/share/locale"):
    assert appdir /../ "/share/locale" == bindtextdomain(gettextPackage, appdir /../ "/share/locale");
  assert "UTF-8" == bind_textdomain_codeset(gettextPackage, "UTF-8");
  assert gettextPackage == textdomain(gettextPackage);

proc main: int =
  if isAppimage():
    putEnv("GTK_EXE_PREFIX", appdir /../ "")
  activateGettext()

  let app = newApplication("com.github.konradmb.zegarek", {ApplicationFlag.nonUnique})
  connect(app, "activate", appActivateWithBuilder)
  return run(app)

main().quit()
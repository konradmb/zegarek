import gintro/[gtk, gdk, glib, gobject, gio]
import os

import commonVars, clockTimer, resizeClock, loadCss, settings

proc onDeleteEvent(w: ApplicationWindow; event: gdk.Event): bool =
  saveSettings()
  return EVENT_PROPAGATE

proc appActivateWithBuilder*(app: Application) =
  discard builder.addFromFile(appdir & "main.glade")
  mainWindow = builder.getApplicationWindow("window")
  mainWindow.setApplication(app)
  mainWindow.connect("delete_event", onDeleteEvent)
  if existsFile(appdir / "../../zegarek-icon.svg"):
    discard mainWindow.setIconFromFile(appdir / "../../zegarek-icon.svg")
  elif existsFile(appdir / "../res/zegarek-icon.svg"):
    discard mainWindow.setIconFromFile(appdir / "../res/zegarek-icon.svg")

  builder.getLabel("timeLabel").startClockTimer()

  var button = builder.getButton("pause")
  button.connect("clicked", pauseClock)

  spinButton = builder.getSpinButton("resolution")
  spinButton.setSpinButton()

  builder.getToggleButton("12Hours").connect12HoursButton()
  builder.getToggleButton("24Hours").connect24HoursButton()

  mainWindow.connect("configure-event", windowConfigureEvent)

  loadCss()

  loadSettings()

  showAll(mainWindow)
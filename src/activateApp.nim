import gintro/[gtk, gdk, glib, gobject, gio]
import os

import commonVars, clockTimer, resizeClock, loadCss


proc appActivateWithBuilder*(app: Application) =
  discard builder.addFromFile(appdir & "main.glade")
  mainWindow = builder.getApplicationWindow("window")
  mainWindow.setApplication(app)
  if existsFile(appdir / "../../zegarek-icon.svg"):
    discard mainWindow.setIconFromFile(appdir / "../../zegarek-icon.svg")
  elif existsFile(appdir / "../res/zegarek-icon.svg"):
    discard mainWindow.setIconFromFile(appdir / "../res/zegarek-icon.svg")

  builder.getLabel("timeLabel").startClockTimer()

  var button = builder.getButton("pause")
  button.connect("clicked", pauseClock)

  builder.getSpinButton("resolution").setSpinButton()

  builder.getToggleButton("12Hours").connect12HoursButton()
  builder.getToggleButton("24Hours").connect24HoursButton()

  mainWindow.connect("configure-event", windowConfigureEvent)

  loadCss()

  showAll(mainWindow)
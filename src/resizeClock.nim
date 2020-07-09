import gintro/[gtk, gdk]
import strformat

import commonVars, loadCss, settings
include caseTuple

proc resizeClock*() =
  var width, height: int
  mainWindow.getSize(width, height)

  var size: float
  case (millisecondsResolution, currentTimeFormat):
    of (1, timeFormat24), (2, timeFormat24),
       (3, timeFormat24), (5, timeFormat24):
      size = float(width)/14
    of (1, timeFormat12), (2, timeFormat12),
       (3, timeFormat12), (5, timeFormat12):
      size = float(width)/18
    else:
      size = 30 
  loadCss(fmt"#timeLabel {{font-size: {size}pt;}}")

proc windowConfigureEvent*(window: ApplicationWindow, event: Event): bool =
  resizeClock()
  EventPropagate
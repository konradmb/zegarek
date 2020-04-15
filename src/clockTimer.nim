import gintro/[gtk, gdk, glib, gobject, gio]
import times

var continueClockUpdates = true
var label: Label
var spinButton: SpinButton

var millisecondsResolution = 1

type timeFormat = enum
  timeFormat12,
  timeFormat24
var currentTimeFormat = timeFormat24


proc spinButtonValueChanged(button: SpinButton) =
  let value = button.getValue().toInt()
  case value:
  of 0:
    millisecondsResolution = 5
  of 1:
    millisecondsResolution = 3
  of 2:
    millisecondsResolution = 2
  of 3:
    millisecondsResolution = 1
  else:
    echo "Invalid clock resolution entered: " & $value

proc setSpinButton*(button: SpinButton) =
  spinButton = button
  spinButton.connect("value-changed", spinButtonValueChanged)


proc set12HoursFormat(button: ToggleButton) =
  currentTimeFormat = timeFormat12
proc set24HoursFormat(button: ToggleButton) =
  currentTimeFormat = timeFormat24

proc connect12HoursButton*(button: ToggleButton) =
  button.connect("toggled", set12HoursFormat)
proc connect24HoursButton*(button: ToggleButton) =
  button.connect("toggled", set24HoursFormat)


proc updateClock(label: Label): bool =
  var time: string
  if currentTimeFormat == timeFormat24:
    time = getTime().format("HH:mm:ss:fff")[0..^millisecondsResolution]
  elif currentTimeFormat == timeFormat12:
    time = getTime().format("hh:mm:ss:fff")[0..^millisecondsResolution] &
       getTime().format(" tt")

  label.text = time
  continueClockUpdates

proc startClockTimer*(labelInput: Label) =
  label = labelInput
  timeoutAdd(1, updateClock, label)

proc pauseClock*(button: Button) =
  continueClockUpdates = not continueClockUpdates
  if continueClockUpdates:
    startClockTimer(label)
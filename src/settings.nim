import gintro/[gtk, glib]
import os, json, marshal

import commonVars

var millisecondsResolution* = 1
var millisecondsResolutionValue*: int

type timeFormat* = enum
  timeFormat12,
  timeFormat24
var currentTimeFormat* = timeFormat24

proc loadSettings*() =
  var j = parseFile(userConfigDir()/"Zegarek"/"settings.json")
  currentTimeFormat = j["currentTimeFormat"].to(timeFormat)
  millisecondsResolutionValue = j["millisecondsResolutionValue"].to(int)
  spinButton.setValue(millisecondsResolutionValue.cdouble())

proc saveSettings*() =
  var j = %*
    { "currentTimeFormat": currentTimeFormat,
      "millisecondsResolutionValue": millisecondsResolutionValue }

  echo j
  echo userConfigDir()
  createDir(userConfigDir()/"Zegarek")
  writeFile(userConfigDir()/"Zegarek"/"settings.json", $j)
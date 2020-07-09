import gintro/[gtk, gdk, glib, gobject, gio]
import os, system
import libintl

import activateApp, resizeClock, commonVars

proc isAppimage(): bool =
  existsEnv("APPIMAGE")

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
    let setAppDir =  appdir /../ ""
    putEnv("GTK_EXE_PREFIX", setAppDir)
    echo "Running as AppImage, GTK_EXE_PREFIX set to ", setAppDir
  activateGettext()

  let app = newApplication("com.github.konradmb.zegarek", {ApplicationFlag.nonUnique})
  connect(app, "activate", appActivateWithBuilder)
  return run(app)

main().quit()
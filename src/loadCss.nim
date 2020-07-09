import gintro/[gtk, gdk, glib, gobject, gio]

import commonVars

proc loadCss*(append: string = "")=
  let screen = getDefaultScreen()
  let cssProvider = newCssProvider()
  discard cssProvider.loadFromPath(appdir & "main.css")
  if append != "":
    discard cssProvider.loadFromData(cssProvider.toString() & append)
  addProviderForScreen(screen, cssProvider, STYLE_PROVIDER_PRIORITY_APPLICATION)
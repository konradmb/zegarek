import gintro/[gtk]
import os

const gettextPackage* = "zegarek"
let appdir* = os.getAppDir() / "/"

let builder*: Builder = newBuilder()
var mainWindow*: ApplicationWindow
# Package

version       = "0.1"
author        = "konradmb"
description   = "A simple clock with milisecond resolution"
license       = "GPL-3.0"
srcDir        = "src"
binDir        = "src"
bin           = @["zegarek"]
skipExt       = @["nim"]



# Dependencies

requires "nim >= 1.2.0"
requires "gintro  >= 0.7.3"

import os, strformat

template run(cmd: string) =
  echo gorge("cd " & system.getCurrentDir() & " && " & cmd)

proc convertImage(filePath: string) =
  let filename = filePath.splitFile().name
  for size in ["16x16", "32x32", "64x64", "128x128", "256x256"]:
    let cmd = fmt"convert {filePath} -resize {size} AppDir/usr/share/icons/hicolor/{size}/apps/{filename}.png"
    echo cmd
    run cmd


task appimage, "Build AppImage":
  mkdir("build")
  cd("build")
  mkdir("AppDir")
  run """
    wget -c https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage &&
    chmod +x linuxdeploy-x86_64.AppImage &&
    ./linuxdeploy-x86_64.AppImage --appdir AppDir
  """
  run "nim c -d:release -o:AppDir/usr/bin/zegarek ../src/zegarek.nim"
  convertImage("../res/zegarek-icon.svg")
  cpFile("../res/zegarek-icon.svg", "AppDir/usr/share/icons/hicolor/scalable/apps/zegarek-icon.svg")
  cpFile("../res/zegarek.desktop", "AppDir/usr/share/applications/zegarek.desktop")
  cpFile("../src/main.css", "AppDir/usr/bin/main.css")
  cpFile("../src/main.glade", "AppDir/usr/bin/main.glade")
  run fmt"VERSION={version} ./linuxdeploy-x86_64.AppImage --appdir AppDir --output appimage"

task clean, "Clean build directory":
  cd("build")
  rmDir("AppDir")
  rmFile("zegarek")
  run("rm Zegarek*.AppImage")

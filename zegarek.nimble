# Package

version       = "0.4.2"
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

import strformat, strutils
import sequtils
import pegs
from os import splitFile, `/`

import macros

template runGorge(cmd: string): string =
  gorge("cd " & system.getCurrentDir() & " && " & cmd)

template run(cmd: string) =
  echo runGorge(cmd)

proc convertImage(filePath: string) =
  let filename = filePath.splitFile().name
  for size in ["16x16", "32x32", "64x64", "128x128", "256x256"]:
    let cmd = fmt"rsvg-convert {filePath} -w {size.split('x')[0]} -h {size.split('x')[1]} -o AppDir/usr/share/icons/hicolor/{size}/apps/{filename}.png"
    echo cmd
    run cmd

proc getPackageName(): string =
  # TODO: packageName is empty when not specified. Is it a bug?
  if packageName.len != 0:
    return packageName
  else:
    return "zegarek"

proc downloadAndExtractAppImage(url: string, outputDir: string) =
  let filename = runGorge fmt"""wget -cnv {url} 2>&1 |cut -d\" -f2"""
  run fmt"""
    chmod +x {filename} &&
    printf '\x00' | dd bs=1 seek=8 count=1 conv=notrunc of={filename} &&
    ./{filename} --appimage-extract
    mv ./squashfs-root {outputDir}
  """

macro repeatProc(procVar: untyped, args: varargs[untyped]): untyped =
  result = newNimNode(nnkStmtList)
  for arg in args:
    let a = quote do:
      `procVar`(`arg`)
    result.add(a)

template rmDir(dirs: varargs[string]) =
  repeatProc rmDir, dirs

template rmFile(files: varargs[string]) =
  repeatProc rmFile, files

task updateL10n, "Update .pot and .po localisation files":
  mkdir "build"
  # Prevent translation of Name and Icon fields in .desktop 
  writeFile "build/zegarek.desktop.in",
    "res/zegarek.desktop".readFile.
    multiReplace([("Name=", "_Name="), ("Icon=", "_Icon=")])
  
  run fmt"""xgettext --package-name={getPackageName()} --package-version={version}\
   -f po/POTFILES.in -d {getPackageName()} -p po -o {getPackageName()}.pot"""
  
  let linguas = readFile("po/LINGUAS").split("\n")
  for lang in linguas:
    run fmt"msgmerge po/{lang}.po po/{getPackageName()}.pot -o po/{lang}.po"


proc buildL10nMo() =
  let linguas = readFile("po/LINGUAS").split("\n")
  for lang in linguas:
    mkDir fmt"build/locale/{lang}/LC_MESSAGES"
    run fmt"msgfmt po/{lang}.po -o build/locale/{lang}/LC_MESSAGES/{getPackageName()}.mo"
  run fmt"msgfmt --desktop --template=res/zegarek.desktop -d po -o build/zegarek.desktop"

proc buildL10nDesktop() =
  run fmt"msgfmt --desktop --template=res/zegarek.desktop -d po -o build/zegarek.desktop"

task buildL10n, "Build files needed for localisation":
  buildL10nMo()
  buildL10nDesktop()

task appimage, "Build AppImage":
  `buildL10n Task`()

  mkdir("build/AppDir")
  cd("build")

  downloadAndExtractAppImage("https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage ", "linuxdeploy")
  run "./linuxdeploy/AppRun --appdir AppDir"

  run "nim c -d:release -d:nimDebugDlOpen -o:AppDir/usr/bin/zegarek ../src/zegarek.nim"

  convertImage("../res/zegarek-icon.svg")

  # Fix AppImage thumbnail creation
  cpFile("AppDir/usr/share/icons/hicolor/256x256/apps/zegarek-icon.png", "AppDir/zegarek-icon.png")
  run "cd AppDir && ln -s zegarek-icon.png .DirIcon"
  
  cpFile("../res/zegarek-icon.svg", "AppDir/usr/share/icons/hicolor/scalable/apps/zegarek-icon.svg")
  cpFile("../res/zegarek.desktop", "AppDir/usr/share/applications/zegarek.desktop")
  cpFile("../res/zegarek.desktop", "AppDir/zegarek.desktop")
  cpFile("../src/main.css", "AppDir/usr/bin/main.css")
  cpFile("../src/main.glade", "AppDir/usr/bin/main.glade")
  cpDir("locale", "AppDir/usr/share/locale")
  if existsFile("requiredLibs"):
    run "wget -c https://github.com/AppImage/pkg2appimage/raw/master/excludelist"
    var requiredLibs = readFile("requiredLibs").splitLines().filterIt(not it.contains(">"))
    for excludedLib in readFile("excludelist").splitLines():
      # Ignore comments and empty lines
      if excludedLib =~ peg"^\s*'#'.*" or excludedLib =~ peg"^\s*$":
        continue
      let excludedLib = excludedLib.split("#")[0].replace(" ", "")

      requiredLibs = requiredLibs.filterIt(not it.contains(excludedLib))
    writeFile("requiredLibsFiltered", requiredLibs.join("\n"))
    echo "Filtered libs: ", requiredLibs
    run "xargs -i cp -L {} AppDir/usr/lib/ < requiredLibsFiltered"
    # Silence canberra error
    var requiredSpecialLibs = readFile("requiredLibs").splitLines().filterIt(it.contains(">"))
    for lib in requiredSpecialLibs:
      echo fmt"Copying {lib}"
      let splitLib = lib.replace(" ", "").split(">")
      mkdir "AppDir/usr/lib"/splitLib[1].splitFile().dir
      cpFile splitLib[0], "AppDir/usr/lib"/splitLib[1]
    # Blacklist additional libraries
    let blacklistedLibs = ["libmount.so.1", "libblkid.so.1", "libbsd.so.0", "libxcb-shm.so.0",
      "libsystemd.so.0", "libgcrypt.so.20"]
    writeFile("libs.blacklist", blacklistedLibs.join("\n") & "\n")

  run fmt"VERSION={version} ./linuxdeploy/AppRun  --appdir AppDir"
  run """for i in `cat libs.blacklist`; do rm AppDir/usr/lib/"$i"; done"""
  run "cp /lib/x86_64-linux-gnu/libz.so.1 AppDir/usr/lib/"
  run "cp /usr/local/lib/x86_64-linux-gnu/libgio-2.0.so.0 AppDir/usr/lib/"
  run "cp /usr/local/lib/x86_64-linux-gnu/libpango-1.0.so.0 AppDir/usr/lib/"
  run "cp /usr/local/lib/x86_64-linux-gnu/libpangoft2-1.0.so.0 AppDir/usr/lib/"
  run "cp /usr/lib/x86_64-linux-gnu/libfreetype.so.6 AppDir/usr/lib/"
  run "cp /usr/lib/x86_64-linux-gnu/libharfbuzz.so.0 AppDir/usr/lib/"
  run "cp /usr/local/lib/x86_64-linux-gnu/libglib-2.0.so.0 AppDir/usr/lib/"

  # run "xargs -i cp -L {} AppDir/usr/lib/ < requiredLibs"


  downloadAndExtractAppImage("https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage", "appimagetool")
  run fmt"VERSION={version} ./appimagetool/AppRun AppDir"

task appimageDocker, "Build AppImage in Docker":
  run "docker build -t zegarek ."
  mkdir "build"
  run fmt"docker run -i --rm zegarek sh -c 'cd build && tar -c Zegarek*AppImage' | tar -x -C build/"

task clean, "Clean build directory":
  cd("build")
  rmDir "AppDir", "locale", "squashfs-root"
  rmFile "zegarek.desktop", "zegarek.desktop.in"
  run("rm Zegarek*.AppImage")

before build:
  buildL10nMo()
  #not working now - nimble bug
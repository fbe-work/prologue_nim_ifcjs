# Package

version       = "0.2.20221101"
author        = "fbe-work"
description   = "minimalistic interaction demo with ifcjs."
license       = "MIT"
srcDir        = "src"
bin           = @["prologue_nim_ifcjs"]


# Dependencies
requires "nim >= 1.6.8"
requires "prologue >= 0.6.2"

# Tasks
task release, "build backend and frontend, start server":
  exec "nim js   -d:release --hint:Name:off --out:static/js/frontend.js frontend.nim"
  exec "nim c -r -d:release --hint:Name:off                             backend.nim"

# Package

version       = "0.2.0"
author        = "PMunch"
description   = "Wrapper of the Imlib2 library"
license       = "MIT"
srcDir        = "src"



# Dependencies

requires "nim >= 1.2.6"
requires "x11 >= 1.2"

task test, "Run headless Imlib2 tests":
  exec "nim c -r --path:src tests/test_headless.nim"
  exec "nim c -r -d:X_DISPLAY_MISSING --path:src tests/test_headless.nim"

# Package

version       = "0.1.0"
author        = "ajusa"
description   = "An easy way to iterate on HTML templates"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["platey"]


# Dependencies

requires "nim >= 1.6.10"
requires "bossy >= 0.1"
requires "jsony >= 1.1.5"
requires "libfswatch"

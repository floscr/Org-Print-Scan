# Package

version       = "0.1.0"
author        = "Florian Schroedl"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["org_print_scan"]
binDir        = "./dst"


# Dependencies

requires "nim >= 1.4.4"
requires "https://github.com/floscr/nimfp#master"
requires "print"
requires "cligen >= 1.5.4"
requires "tempfile >= 0.1.7"
requires "fusion"
requires "zero_functional"

import distros
if detectOs(NixOS):
  foreignDep "pkgconfig"

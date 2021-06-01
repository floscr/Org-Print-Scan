# Package

version       = "0.1.0"
author        = "Florian Schroedl"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["org_print_scan"]


# Dependencies

requires "nim >= 1.4.6"
requires "nimfp >= 0.4.5"
requires "argparse >= 2.0.0"

import distros
if detectOs(NixOS):
  foreignDep "pkgconfig"

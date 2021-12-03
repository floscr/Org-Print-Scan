import argparse

var p = newParser:
  option("-o", "--output", help="Output to this file")
  command("copy"):
    arg("name")
    arg("others", nargs = -1)
    run:
      echo opts.name
      echo opts.others
      echo opts.parentOpts.apple
      echo opts.parentOpts.b
      echo opts.parentOpts.output

try:
  p.run(@["--apple", "-o=foo", "somecommand", "myname", "thing1", "thing2"])
except UsageError as e:
  stderr.writeLine getCurrentExceptionMsg()
  quit(1)

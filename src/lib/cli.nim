import argparse
import fusion/matching
import ./env
import ./scan

{.experimental: "caseStmtMacros".}

var p = newParser:
  help(APP_NAME)
  command("copy"):
    arg("file")
    run:
      discard main(filePaths = @[opts.file])

try:
  if commandLineParams().len == 0:
    echo p.help
    quit(0)

  p.run(commandLineParams())
except UsageError as e:
  stderr.writeLine getCurrentExceptionMsg()
  quit(1)


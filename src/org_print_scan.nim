import std/options
import fusion/matching
import ./lib/env
import ./lib/main
import argparse
import fp/maybe

{.experimental: "caseStmtMacros".}

proc runCli(args = commandLineParams()): auto =
  echo args
  var p = newParser:
    help(APP_NAME)
    command("copy"):
      arg("file")
      option("-h", "--headline", help = "Headline title", default = none[string]())
      option("-t", "--tags", help = """List of tags seperated by ","
Tags will be converted to captials""", default = none[string]())
      run:
        discard main(
          filePaths = @[opts.file],
          headline = opts.headline.just().notEmpty(),
          tags = opts.tags.just().notEmpty(),
        )

  try:
    if args.len == 0:
      echo p.help
      quit(0)

    p.run(args)
  except UsageError as e:
    stderr.writeLine getCurrentExceptionMsg()
    quit(1)

when isMainModule:
  runCli()

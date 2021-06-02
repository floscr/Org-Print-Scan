import argparse
import fp/option
import lib/main
import lib/types
import strformat
import sugar

const AppName = "org_print_scan"
const USE_STDIN = "USE_STDIN"

var p = newParser(AppName):
  option("-i", "--input", help = "Input File \nDefaults to scanning when no input is passed.")

  run:
    let options = CLIArgs(
      input: opts.input.Some.notEmpty
    )
    discard main(options)
    quit(1)

p.run

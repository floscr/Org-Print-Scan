import argparse
import fp/option
import lib/main
import lib/types
import strformat

const AppName = "org_print_scan"

var p = newParser(AppName):
  option("-i", "--input", help = """Input File
Defaults to scanning when no input is passed.""")
  option("-o", "--output", help = """Output File
When a file with a .pdf extension is passed, the file will be appended.""")

  run:
    let options = CLIArgs(
      input: opts.input.Some.notEmpty
    )
    discard main(options)
    quit(1)

p.run

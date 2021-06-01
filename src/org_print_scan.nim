import argparse
import strformat
import lib/main
import sugar

const AppName = "org_print_scan"
const USE_STDIN = "USE_STDIN"

var p = newParser(AppName):
  help "Help text here..."

  flag "--version", help = "Print the version of " & AppName
  flag "--revision", help = "Print the Git SHA of " & AppName
  flag "--info", help = "Print version and revision"

  run:
    echo main()
    quit(1)

p.run

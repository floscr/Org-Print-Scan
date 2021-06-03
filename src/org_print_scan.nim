import cligen
import lib/main

{.experimental.}

const AppName = "org_print_scan"

proc cli(input="", output=""): int =
  discard main(input = input, output = output)
  1

dispatch(cli, help = {
  "input": """Input file
When no file is passed it defaults to scanning via scanimage""",
  "output": """Output file
When passing an existing pdf, the pages will be appended.""",
})

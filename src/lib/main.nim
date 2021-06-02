import types
import utils
import fp/option
import fp/either
import sugar
import strformat
import tempfile
import os

const SCAN_FILE_NAME = "out.pnm"
const PROCESS_SCAN_CMD = &"scantailor-cli --color-mode=mixed ${SCAN_FILE_NAME} ./ > /dev/null 2>&1"
const SCAN_CMD = &"""scanimage \
    --mode Color \
    --resolution 600 \
    --format pnm \
    --output ${SCAN_FILE_NAME} \
    > /dev/null 2>&1"""

proc main*(opts: CLIArgs): any =
  let workingDir = mkdtemp()

  # When no file name is passed execute scan & processing command
  let input = opts.input
    .fold(
      () => sh(SCAN_CMD, { poStdErrToStdOut: true, workingDir })
        .flatMap(sh(PROCESS_SCAN_CMD))
        .map(x => "out.tif"),
      x => x.right,
    )
    .map(x => joinPath(workingDir, x))

  echo $input

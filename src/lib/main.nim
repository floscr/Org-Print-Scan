import types
import utils
import fp/option
import fp/either
import sugar
import strformat
import tempfile
import os

const SCAN_FILE_NAME = "out.pnm"
const SCAN_CMD = &"""scanimage \
    --mode Color \
    --resolution 600 \
    --format pnm \
    --output ${SCAN_FILE_NAME}"""
const PROCESS_SCAN_CMD = &"scantailor-cli --color-mode=mixed ${SCAN_FILE_NAME} ./"

proc main*(opts: CLIArgs): any =
  let workingDir = mkdtemp()

  # When no file name is passed execute scan & processing command
  let filename = opts.input
    .fold(
      () => sh(SCAN_CMD, workingDir)
        .flatMap((x: string) => sh(PROCESS_SCAN_CMD, workingDir))
        .map(x => "out.tif"),
      x => x.rightS,
    )
    .map(x => joinPath(workingDir, x))
    # OCR the input file
    .flatMap((x: string) => sh(&"ocrmypdf ${x} out.pdf", workingDir))

  echo $filename
  ""

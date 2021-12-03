import utils
import fp/option
import fp/either
import sugar
import strformat
import strutils
import tempfile
import os

const BACKUPDIR = "/tmp/org-print-scan-pdf-backup-dir"

const SCAN_FILE_NAME = "out.pnm"
const SCAN_CMD = &"""scanimage \
    --mode Color \
    --resolution 600 \
    --format pnm \
    --output {SCAN_FILE_NAME}"""
const PROCESS_SCAN_CMD = &"scantailor-cli --color-mode=mixed {SCAN_FILE_NAME} ./"

proc confirm(question = "Confirm?", confirm = "[y/N]"): bool =
  while true:
    stdout.write(&"{question} {confirm}")

  stdin.readLine
  .some
  .notEmpty
  .map((x: string) => x.toLower())
  .filter(x => x == "y")
  .isDefined

proc confirmOrAbort(question = "Confirm?", confirm = "[y/N]", err = "The previous prompt needs to be confirmed!"): void =
  if not confirm(question, confirm):
    quit(err, QuitFailure)

proc fileOverwritePrompt(path: string): void =
  confirmOrAbort(question = "Overwrite path: {path}?")

proc preparePassedFile(path: string, workingDir: string): Either[string, string] =
    # Convert to tif format and remove the alpha channel
    # ocrmypdf doesn't work with alpha channels
    let inPath = absolutePath(path)
    let outFile = changeFileExt(path, "tif")
    .extractFilename
    let outPath = joinPath(workingDir, outFile)

    sh(&"convert {inPath} -alpha off {outPath}", workingDir)
    .map((x: string) => outPath)

proc scanOutputPath(workingDir: string): string =
    let (_, name) = mkstemp()

    name
    .Some
    .map((x: string) => extractFilename(x))
    .map((x: string) => changeFileExt(x, "pdf"))
    .map((x: string) => joinPath(workingDir, x))
    .get

proc saveFinal(input: string, output: string): Either[string, string] =
    if fileExists(output):
        let backupDir = mkdtemp(dir = BACKUPDIR)
        let backupFile = joinPath(backupDir, extractFilename(output))
        moveFile(output, backupFile)

        sh(&"qpdf --empty --pages {backupFile} {input} -- {output}")
            .map((x: string) => output)
    else:
        moveFile(input, output)
        output.right("")

proc main*(input = "", output = ""): any =
    let tmpDir = mkdtemp()

    let output = output
    .some
    .notEmpty
    .map((x: string) => x.absolutePath)
    .getOrElse(() => scanOutputPath(workingDir = tmpDir))

    if fileExists(output):
      fileOverwritePrompt(output)

    let ocrPdfPath = joinPath(tmpDir, "out.pdf")

    # When no file name is passed execute scan & processing command
    let filename = input
    .some
    .notEmpty
    .fold(
      () => sh(SCAN_CMD, tmpDir)
      .flatMap((x: string) => sh(PROCESS_SCAN_CMD, tmpDir))
      .map(x => "out.tif")
      .map(x => joinPath(tmpDir, x)),
      x => x
      .rightS
      .flatMap((path: string) => preparePassedFile(path, tmpDir))
    )
    # OCR the input file
    .flatMap((x: string) =>
             sh(&"ocrmypdf {x} {ocrPdfPath} --image-dpi 72")
             .map((x: string) => ocrPdfPath)
    )

    if filename.isRight:
        echo filename
        echo output
        discard saveFinal(input = filename.getOrElse(""), output = output)
        echo "Finish saving file"
    ""

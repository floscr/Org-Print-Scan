import utils
import fp/option
import fp/either
import sugar
import strformat
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

proc preparePassedFile(path: string, workingDir: string): Either[string, string] =
    # Convert to tif format and remove the alpha channel
    # ocrmypdf doesn't work with alpha channels
    let inPath = absolutePath(path)
    let outFile = changeFileExt(path, "tif")
        .extractFilename
    let outPath = joinPath(workingDir, outFile)

    sh(&"convert {inPath} -alpha off {outPath}", workingDir)
        .map((x: string) => outPath)

proc getOutput(path: Option[string], workingDir: string, isScan: bool): Option[string] =
    let path = path
        .map((x: string) => absolutePath(x))

    if path.isEmpty and isScan:
        let (_, name) = mkstemp()
        let filename = name.Some
            .map((x: string) => extractFilename(x))
            .map((x: string) => changeFileExt(x, "pdf"))
            .map((x: string) => joinPath(workingDir, x))

        let fileExists = filename
            .filter((x: string) => not fileExists(x))
            .isEmpty

        if fileExists:
            raise newException(Exception,
                    &"No output file passed and generated filename {$filename} exists")
        else:
            filename

    else:
        path

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
    let isScan = input == ""
    let workingDir = mkdtemp()

    let output = getOutput(
      path = output.Some.notEmpty,
      workingDir = workingDir,
      isScan = isScan
    )

    let ocrPdfPath = joinPath(workingDir, "out.pdf")

    # When no file name is passed execute scan & processing command
    let filename = input
        .Some
        .notEmpty
        .fold(
          () => sh(SCAN_CMD, workingDir)
            .flatMap((x: string) => sh(PROCESS_SCAN_CMD, workingDir))
            .map(x => "out.tif")
            .map(x => joinPath(workingDir, x)),
          x => x
            .rightS
            .flatMap((path: string) => preparePassedFile(path, workingDir))
        )
        # OCR the input file
        .flatMap((x: string) => sh(&"ocrmypdf {x} {ocrPdfPath} --image-dpi 72")
            .map((x: string) => ocrPdfPath)
        )

    if filename.isRight:
        echo filename.getOrElse("")
        echo output.getOrElse("")
        discard saveFinal(input = filename.getOrElse(""),
                output = output.getOrElse(""))
        echo "Finish saving file"
    ""

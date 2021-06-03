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

proc preparePassedFile(path: string, workingDir: string): Either[string, string] =
    # Convert to tif format and remove the alpha channel
    # ocrmypdf doesn't work with alpha channels
    let inPath = absolutePath(path)
    let outFile = changeFileExt(inPath, "tif")
        .extractFilename
    let outPath = joinPath(workingDir, outFile)

    sh(&"convert {inPath} -alpha off {outPath}", workingDir)
        .map((x: string) => outPath)

proc main*(input = "", output = ""): any =
    # let input = input.Some.notEmpty
    # let output = output.Some.notEmpty

    # echo typeof input
    discard input.Some.notEmpty.map((x: string) => "foo")

    # let workingDir = mkdtemp()

    # let ocrPdfPath = joinPath(workingDir, "out.pdf")

    # # let output = opts.output.asEither("No file supplied")

    # # let outPath = output
    # #     .map((x: string) => changeFileExt(x, "pdf"))
    # #     .orElse(() => opts.input
    # #             .map((x: string) => changeFileExt(x, "pdf"))
    # #             .filter((x: string) => fileExists(x))
    # #             .asEither("File exists.")
    # #     )

    # # if (outPath.isLeft): raise newException(Exception, outPath.getLeft)

    # # When no file name is passed execute scan & processing command
    # let filename = input
    #     .fold(
    #       () => sh(SCAN_CMD, workingDir)
    #         .flatMap((x: string) => sh(PROCESS_SCAN_CMD, workingDir))
    #         .map(x => "out.tif")
    #         .map(x => joinPath(workingDir, x)),
    #       x => x
    #         .rightS
    #         .flatMap((path: string) => preparePassedFile(path, workingDir))
    #     )
    #     # OCR the input file
    #     .flatMap((x: string) => sh(&"ocrmypdf {x} {ocrPdfPath} --image-dpi 72"))

    # echo $filename
    ""

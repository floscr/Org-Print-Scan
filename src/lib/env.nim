import std/os
import std/sugar
import std/os
import std/osproc
import std/times
import fp/maybe

const APP_NAME* = "papi"

const BASE_DIR* = "/home/floscr/Media/Scans"
const SCANS_DIR* = BASE_DIR.joinPath("Files")
const ORG_FILE* = BASE_DIR.joinPath("Scans.org")

type Env* = object
  baseDir*: string
  scansDir*: string
  orgFile*: string
  executionDate*: DateTime

proc mkDefaultEnv*(): Env =
  Env(
    baseDir: BASE_DIR,
    scansDir: SCANS_DIR,
    orgFile: ORG_FILE,
    executionDate: now(),
  )

proc strDefineToMaybe(x: string): Maybe[string] =
  x.just()
  .notEmpty()
  .filter(x => not x.defined())

const PDFTOTEXT_BIN_PATH {.strdefine.} = ""
let pdftotextBinPath* = PDFTOTEXT_BIN_PATH
.strDefineToMaybe()
.getOrElse("pdftotext")

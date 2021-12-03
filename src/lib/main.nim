import std/os
import std/osproc
import std/collections/sequtils
import std/strformat
import std/sugar
import std/osproc
import std/strutils
import std/times
import fusion/matching
import fp/list
import fp/either
import fp/maybe
import ./env
import ./type_document
import ./utils/fp
import ./org

{.experimental: "caseStmtMacros".}

proc copyFile(path: string, env: Env): auto =
  let (srcDir, srcBase, srcExt) = path.splitFile()

  let srcDocument = newDocument(path)

  let dstFilename = srcDocument.getDstFileName()
  let dstPath = env.scansDir.joinPath(dstFilename)

  echo ("Copying File:", path, dstPath)

  # TODO: Will throw if copying fails
  copyFile(path, dstPath)

  let dstDocument = newDocument(dstPath)

  var orgFile = open(env.orgFile, fmAppend)
  orgFile.writeLine(dstDocument.toOrg(env))

  dstDocument

proc setup(env: Env): auto =
  @[
    env.baseDir,
    env.scansDir,
  ]
  .asList()
  .forEach(createDir)

  if not env.orgFile.fileExists():
    let initFile = org.initFile(
      fileTitleHeader = "Scans".just(),
      rootHeadline = "Scans".just(),
    )
    env.orgFile.writeFile(initFile)

  env

proc main*(filePaths: seq[string]): auto =
  let filePaths = filePaths
  .map(expandTilde)
  .filter(fileExists)

  let env = mkDefaultEnv()
  .setup()
  .tryET()

  filePaths
  .asList()
  .map(path => copyFile(path=path, env=env.get()))

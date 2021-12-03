import std/os
import std/osproc
import std/collections/sequtils
import std/strformat
import std/sugar
import std/osproc
import std/strutils
import std/times
import std/options
import fusion/matching
import fp/list
import fp/either
import fp/maybe
import ./env
import ./type_document
import ./utils/fp
import ./org
import cascade

{.experimental: "caseStmtMacros".}

proc copyFile(
  path: string,
  env: Env,
  title: Maybe[string],
  tags: Maybe[seq[string]],
): auto =
  let srcDocument = newDocument(path)

  let dstFilename = srcDocument.getDstFileName()
  let dstPath = env.scansDir.joinPath(dstFilename)

  echo ("Copying File:", path, dstPath)

  # TODO: Will throw if copying fails
  copyFile(path, dstPath)

  let dstDocument = cascade newDocument(dstPath):
    title = title
    tags = tags

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

proc main*(
  filePaths: seq[string],
  headline: Maybe[string],
  tags: Maybe[string],
): auto =

  let tags = tags
  .map(x => x.split(","))

  let title = headline

  let filePaths = filePaths
  .map(expandTilde)
  .filter(fileExists)

  let env = mkDefaultEnv()
  .setup()
  .tryET()

  filePaths
  .asList()
  .map(path => copyFile(
    path = path,
    env = env.get(),
    tags = tags,
    title = title,
  ))

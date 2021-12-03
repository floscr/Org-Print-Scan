import std/os
import std/times
import std/strformat
import std/sugar
import fusion/matching
import fp/maybe
import ./env
import ./org

{.experimental: "caseStmtMacros".}

const DOCUMENT_TIME_FORMAT* = "yyyyMMdd"

type Document* = ref object
  path*: string
  fileInfo*: FileInfo
  title*: Maybe[string]
  tags*: Maybe[seq[string]]

proc newDocument*(path: string): Document =
  Document(
    path: path,
    fileInfo: path.getFileInfo(),
  )

proc documentDateFormat*(x: Time): string =
  x.format(DOCUMENT_TIME_FORMAT)

proc documentDateNow*(): string {.inline.} =
  getTime().documentDateFormat()

proc getDstFileName*(x: Document): string =
  let date = x.fileInfo.creationTime.documentDateFormat()

  (_, @filename, @ext) := x.path.splitFile()

  &"""{date}-{filename}{ext}"""

proc toOrg*(
  doc: Document,
  env: Env,
): string =
  let (_, base, ext) = doc.path.splitFile()
  let relativeFileName = relativePath(doc.path, env.baseDir)

  let titleLink = doc.title
  .fold(
    () => &"[[file:./{relativeFileName}][{base}{ext}]]",
    title => &"[[file:./{relativeFileName}][{title}]]",
  )

  org.makeHeadline(
    title = titleLink,
    level = 2,
    tags = doc.tags.getOrElse(newSeq[string]()),
    properties = @[
      ("CREATED", org.makeTimestamp(env.executionDate))
    ],
  )

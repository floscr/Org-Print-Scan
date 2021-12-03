import std/os
import std/times
import std/strformat
import std/options
import std/sugar
import fusion/matching
import fp/maybe
import ./env
import ./utils/fp

{.experimental: "caseStmtMacros".}

const DOCUMENT_TIME_FORMAT* = "yyyyMMdd"

type Document* = ref object
  path*: string
  fileInfo*: FileInfo
  title*: Option[string]

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

proc toOrg*(x: Document, env: Env): string =
  let (_, base, ext) = x.path.splitFile()
  let relativeFileName = relativePath(x.path, env.baseDir)

  let titleLink = x.title
  .convertMaybe()
  .fold(
    () => &"[[file:./{relativeFileName}][{base}{ext}]]",
    title => &"[[file:./{relativeFileName}][{title}]]",
  )

# let createdTime = getTime()-a[]

#   &"""** {titleLink}
# """

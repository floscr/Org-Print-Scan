import std/strformat
import strformat
import fp/maybe
import strutils
import collections/sequtils
import sugar
import fp/list
import zero_functional

const ORG_FILE_HEADER_TITLE_KEY = "TITLE"

proc makeFileHeader*(key: string, value: string): string =
  ## Create an org file header with `key` and `value`.
  ## The key will be converted to uppercase per convention.
  ## E.g.: #+TITLE: `value`
  &"#+{key.toUpper()}: {value}"

proc makeFileTitleHeader*(value: string): string =
  ## Create an org file title header
  ## E.g.: #+TITLE: `value`
  makeFileHeader(key = ORG_FILE_HEADER_TITLE_KEY, value)

proc makeHeadlineTags*(tags: seq[string] = @[]): string =
  if tags.len == 0:
    ""
  else:
    let tagsStr = tags
    .map(toUpper)
    .join(sep = ":")

    &":{tagsStr}:"

proc makeHeadline*(
  title: string,
  level = 1,
  tags: seq[string] = @[],
): string =
  let stars = "*".repeat(level).just()
  let title = title.just()
  let tags = tags
  .makeHeadlineTags()
  .just()
  .notEmpty()

  @[stars, title, tags] --> filter(it.isDefined())
  .map(it.get())
  .reduce(it.accu & " " & it.elem)

proc initFile*(
  fileTitleHeader = Nothing[string](),
  rootHeadline = Nothing[string]()
): string =
  let header = fileTitleHeader
  .map(x => makeFileTitleHeader(x))

  let headline = rootHeadline
  .map(x => makeHeadline(x))

  @[
    header,
    headline,
  ] --> filter(it.isDefined())
  .map(it.get())
  .reduce(it.accu & "\n\n" & it.elem)

when isMainModule:
  import unittest

  test "makeHeadline":
    check: makeHeadline("Foo", tags = @["foo", "bar"]) == "* Foo :FOO:BAR:"
    check: makeHeadline("Foo", level = 3) == "*** Foo"

  test "initFile":
    check: initFile() == ""
    check: initFile(fileTitleHeader = "Foo".just()) == "#+TITLE: Foo"
    check: initFile(rootHeadline = "Foo".just()) == "* Foo"
    check: initFile(fileTitleHeader = "Foo".just(), rootHeadline = "Foo".just()) == """#+TITLE: Foo

* Foo"""

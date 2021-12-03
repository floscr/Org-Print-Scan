import std/strformat
import strformat
import fp/maybe
import strutils
import collections/sequtils
import sugar
import fp/list
import zero_functional
import times

const ORG_FILE_HEADER_TITLE_KEY = "TITLE"
const ORG_TIME_FORMAT = "YYYY-MM-dd ddd" # 2022-01-07 Fri

type orgProperty = (string, string)

proc makeTimestamp(date: DateTime, inactive = true): string =
  let dateStr = date.format(ORG_TIME_FORMAT)
  if inactive:
    &"[{dateStr}]"
  else:
    &"<{dateStr}>"

proc makeFileHeader*(key: string, value: string): string =
  ## Create an org file header with `key` and `value`.
  ## The key will be converted to uppercase per convention.
  ## E.g.: #+TITLE: `value`
  &"#+{key.toUpper()}: {value}"

proc makeFileTitleHeader*(value: string): string =
  ## Create an org file title header
  ## E.g.: #+TITLE: `value`
  makeFileHeader(key = ORG_FILE_HEADER_TITLE_KEY, value)

proc makeHeadlineProperties*(properties: seq[orgProperty] = @[]): string =
  if properties.len == 0:
    ""
  else:
    let propertiesStr = properties
    .map((x: orgProperty) => &":{x[0].toUpper()}: {x[1]}")
    .join(sep = "\n")

    &""":PROPERTIES:
{propertiesStr}
:END:
"""

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
  properties: seq[orgProperty] = @[],
): string =
  let stars = "*".repeat(level).just()
  let title = title.just()
  let tags = tags
  .makeHeadlineTags()
  .just()
  .notEmpty()

  let properties = properties
  .makeHeadlineProperties()
  .just()
  .notEmpty()

  let headline = @[
    stars, title, tags,
  ] --> filter(it.isDefined())
  .map(it.get())
  .reduce(it.accu & " " & it.elem)

  @[
    headline.just(),
    properties,
  ] --> filter(it.isDefined())
  .map(it.get())
  .reduce(it.accu & "\n" & it.elem)

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

  test "Date":
    let dt = dateTime(2017, mMar, 30, 00, 00, 00, 00, utc())
    check: dt.makeTimestamp() == "[2017-03-30 Thu]"
    check: dt.makeTimestamp(inactive = false) == "<2017-03-30 Thu>"

  test "Properties Block":
    check: makeHeadlineProperties(@[("foo", "bar")]) == """:PROPERTIES:
:FOO: bar
:END:
"""

  test "Headline":
    check: makeHeadline("Foo", level = 3) == "*** Foo"
    check: makeHeadline("Foo", tags = @["foo", "bar"]) == "* Foo :FOO:BAR:"
    check: makeHeadline("Foo", properties = @[("foo", "bar")]) == """* Foo
:PROPERTIES:
:FOO: bar
:END:
"""

  test "Empty File":
    check: initFile() == ""
    check: initFile(fileTitleHeader = "Foo".just()) == "#+TITLE: Foo"
    check: initFile(rootHeadline = "Foo".just()) == "* Foo"
    check: initFile(fileTitleHeader = "Foo".just(), rootHeadline = "Foo".just()) == """#+TITLE: Foo

* Foo"""

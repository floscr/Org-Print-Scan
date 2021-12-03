import std/times

const DOCUMENT_TIME_FORMAT* = "yyyyMMdd"

proc documentDate*(x: DateTime): string =
  x.format(DOCUMENT_TIME_FORMAT)

proc dbDate*(): string {.inline.} =
  utc(now()).dbDate()

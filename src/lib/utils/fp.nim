import std/osproc
import std/strutils
import std/options
import fp/either
import fp/maybe

proc sh*(cmd: string, opts = {poStdErrToStdOut}): Either[string, string] =
  ## Execute a shell command and wrap it in an Either
  ## Right for a successful command (exit code: 0)
  ## Left for a failing command (any other exit code, so 1)
  let (res, exitCode) = execCmdEx(cmd, opts)
  if exitCode == 0:
    return res
        .strip
        .right(string)
  return res
    .strip
    .left(string)

proc stripWhitespace*(x: string): string =
  ## Immutable strip of whitespace on start & end of string
  var x = x
  discard x.strip()
  x

proc convertMaybe*[T](x: Option[T]): Maybe[T] =
  if x.isSome():
    just(x.unsafeGet())
  else:
    nothing(T)

proc convertMaybe*[T](x: Maybe[T]): Option[T] =
  if maybe.isDefined(x):
    some(x.get())
  else:
    none(T)

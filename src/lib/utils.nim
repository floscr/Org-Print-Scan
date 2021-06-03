import osproc
import strutils
import osproc
import fp/option
import fp/either
import sugar

proc bitap*[T](xs: Option[T], errFn: () -> void, succFn: T -> void): Option[T] =
  if (xs.isDefined):
    succFn(xs.get)
  else:
    errFn()
  xs

proc sh*(cmd: string, workingDir = ""): Either[string, string] =
  let (res, exitCode) = execCmdEx(cmd, workingDir=workingDir)
  if exitCode == 0:
    return res
      .strip
      .right(string)
  return res
    .strip
    .left(string)

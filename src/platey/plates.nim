import jsony, strformat, strutils
export jsony

type Plate* = object
  name*: string # The name of the template
  body*: string # The HTML snippet to display

const PLATES_HEADER = "---PLATES---"
const PLATES_FOOTER = "---END PLATES---"

proc toString*(plates: seq[Plate]): string =
  dedent &"""
  {PLATES_HEADER}
  {plates.toJson()}
  {PLATES_FOOTER}
  """

proc extractPlates*(output: string): seq[Plate] =
  let i = output.find(PLATES_HEADER) + PLATES_HEADER.len
  let j = output.find(PLATES_FOOTER)
  return output[i..j].strip.fromJson(seq[Plate])

var GLOBAL_PLATES*: seq[Plate] = @[]

template plates*(body: untyped): untyped {.dirty.} =
  body
  echo GLOBAL_PLATES.toString()

template plate*(plateName: string, code: untyped): untyped =
  var plate: Plate
  plate.name = plateName
  plate.body = code
  GLOBAL_PLATES.add(plate)

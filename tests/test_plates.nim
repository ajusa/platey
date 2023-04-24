import unittest, strutils

import platey/plates

let SAMPLE_OUTPUT = dedent"""
---PLATES---
[{"name":"edit mode","body":"edit"},{"name":"create mode","body":"create"}]
---END PLATES---
"""
suite "plates":
  const expected = @[
      Plate(name: "edit mode", body: "edit"),
      Plate(name: "create mode", body: "create")]
  setup:
    GLOBAL_PLATES = @[]
  test "plates template aggregates plates":
    plates:
      plate "edit mode":
        "edit"
      plate "create mode":
        "create"
    check GLOBAL_PLATES == expected
  test "plates are printed":
    check expected.toString == SAMPLE_OUTPUT
  suite "sampleOutput":
    test "it extracts the printed plates":
      check SAMPLE_OUTPUT.extractPlates == expected
    test "it raises an exception when the output is mangled":
      expect Exception:
        discard extractPlates("random nonsense")

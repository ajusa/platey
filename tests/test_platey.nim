import unittest, platey, strutils, platey/plates

const sampleOutput = dedent """
---PLATES---
[{"name":"edit mode","body":"edit"},{"name":"create mode","body":"create"}]
---END PLATES---
"""

suite "handleOutput":
  test "it returns error text when the error code is not zero":
    check handleOutput("error", 3, "") == """<div id="content"><pre>error</pre></div>"""
  test "it returns first story when selected is missing":
    check handleOutput(sampleOutput, 0, "") == """<div id="content">edit</div>"""
  test "it returns plate by name":
    check handleOutput(sampleOutput, 0, "create mode") == """<div id="content">create</div>"""

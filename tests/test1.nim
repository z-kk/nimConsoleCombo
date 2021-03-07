import unittest

type
  TestEnum = enum
    a = "one"
    b = "two"
    c = "three"
    d = "four"

import nimConsoleCombo
test "seq[string]":
  let
    vals = @["one", "two", "three", "four"]
    res = vals.selectCombo("文字列配列から選択", 2)
  echo "選択された値: ", res

test "seq[tuple]":
  let
    vals = @[("t", true), ("f", false)]
    res = vals.selectCombo("タプルから選択", 2)
  echo "選択された値: ", res

test "enum":
  try:
    let res = TestEnum.selectCombo("enumから選択", -1, false)
    echo "選択された値: ", res
  except NotSelected:
    echo "未選択"

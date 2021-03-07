import
  terminal

type
  NotSelected* = object of CatchableError

proc echoComboItem(comItems: seq[string], idx: int) =
  ## 選択中のアイテムを表示する
  eraseLine()
  if idx in 0 ..< comItems.len:
    echo "> ", comItems[idx]
    cursorUp()

proc selectCombo*(comItems: seq[string], message: string, idx = 0, isShowAll = true): tuple[val: string, idx: int] =
  ## 文字列配列から選択
  if idx < 0:
    result.idx = -1
  elif idx > comItems.len - 1:
    result.idx = comItems.len - 1
  else:
    result.idx = idx

  echo message
  if isShowAll:
    echo ">>"
    for item in comItems:
      echo "  ", item
    echo "<<"

  echoComboItem(comItems, result.idx)
  var prevChars: seq[int]
  while true:
    let ch = getch()
    case ch.ord
    of 13:
      cursorDown()
      break
    of 27, 91:
      prevChars.add(ch.ord)
    of 65 .. 68:
      if prevChars != @[27, 91]:
        continue
      case ch.ord
      of 65:
        # 上
        result.idx.dec
        if result.idx < 0:
          if idx < 0:
            result.idx = -1
          else:
            result.idx = 0
      of 66:
        # 下
        result.idx.inc
        if result.idx >= comItems.len:
          result.idx = comItems.len - 1
      of 67:
        # 右
        result.idx = comItems.len - 1
      of 68:
        # 左
        result.idx = 0
      else: discard
      prevChars = @[]
    else:
      prevChars = @[]
      case ch
      of 'j', 'n':
        # 次を選択
        result.idx.inc
        if result.idx >= comItems.len:
          result.idx = comItems.len - 1
      of 'k', 'p':
        # 前を選択
        result.idx.dec
        if result.idx < 0:
          if idx < 0:
            result.idx = -1
          else:
            result.idx = 0
      of 'h', 'H', 'g':
        # 先頭を選択
        result.idx = 0
      of 'l', 'L', 'G':
        # 最後を選択
        result.idx = comItems.len - 1
      else: discard

    echoComboItem(comItems, result.idx)

  if result.idx in 0 ..< comItems.len:
    result.val = comItems[result.idx]

proc selectCombo*[T](comItems: seq[tuple[title: string, val: T]], message: string, idx = 0, isShowAll = true): T =
  ## タイトル, 値のタプル配列から選択
  var itms: seq[string]
  for item in comItems:
    itms.add(item.title)
  let res = itms.selectCombo(message, idx, isShowAll).idx
  if res < 0 and idx < 0:
    raise newException(NotSelected, message)
  return comItems[res].val

proc selectCombo*(enm: type enum, message: string, idx = 0, isShowAll = true): enum =
  ## enumから選択
  var itms: seq[(string, int)]
  for item in enm:
    itms.add(($item, item.ord))
  return enm(itms.selectCombo(message, idx, isShowAll))

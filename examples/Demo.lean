import TermColorLayout

open TermColor
open TermColor.Layout
open scoped TermColor.Style

private def heading (title : String) : Text :=
  Text.styled ("\n" ++ title ++ "\n") (Style.bold <+> Style.fg (.indexed 250))

private def widthRow (label : String) (value : Text) : Text :=
  Text.styled (label ++ "  ") Style.dim ++ value ++
    Text.styled ("  width=" ++ toString (Text.width value) ++
      " height=" ++ toString (Text.height value) ++ "\n") Style.dim

private def alignmentRows : Text := Text.concat
  [ Text.plain "left   | " ++ align 16 .left (Text.styled "left" Style.green) ++ Text.plain "\n"
  , Text.plain "center | " ++ align 16 .center (Text.styled "center" Style.yellow) ++ Text.plain "\n"
  , Text.plain "right  | " ++ align 16 .right (Text.styled "right" Style.cyan) ++ Text.plain "\n"
  ]

private def columnsDemo : Text := Text.concat
  [ columns [12, 24, 10] 2
      [ Text.styled "Feature" Style.bold
      , Text.styled "What it preserves" Style.bold
      , Text.styled "Width" Style.bold
      ] [.left, .left, .right]
  , Text.plain "\n"
  , columns [12, 24, 10] 2
      [ Text.styled "width" Style.cyan
      , Text.plain "CJK and combining marks" 
      , Text.plain "Unicode"
      ] [.left, .left, .right]
  , Text.plain "\n"
  , columns [12, 24, 10] 2
      [ Text.styled "wrap" Style.cyan
      , Text.styled "Styled content wraps without losing its color" Style.green
      , Text.plain "pure"
      ] [.left, .left, .right]
  , Text.plain "\n"
  , columns [12, 24, 10] 2
      [ Text.styled "box" Style.cyan
      , Text.plain "Padding, titles, borders, and max width"
      , Text.plain "layout"
      ] [.left, .left, .right]
  ]

private def boxesDemo : Text := Text.concat
  [ box
      (Text.styled "Unicode borders\nwrap inside a width limit" Style.green)
      { title := some (Text.styled "default box" Style.bold)
        borderStyle := Style.fg (.indexed 244)
        padding := 1
        maxWidth := some 34 }
  , Text.plain "\n\n"
  , box
      (Text.styled "ASCII fallback\nwith a left title" Style.yellow)
      { chars := asciiBoxChars
        title := some (Text.styled "fallback" Style.bold)
        titleAlignment := .left
        borderStyle := Style.magenta
        padding := 1 }
  ]

def main : IO Unit := do
  let widthExamples := Text.concat
    [ Text.styled ("defaultWidth=" ++ toString defaultWidth ++ "  charWidth('界')=" ++
        toString (charWidth '界') ++
        "  stringWidth(界面)=" ++ toString (stringWidth "界面") ++ "\n") Style.dim
    , widthRow "ASCII" (Text.plain "termcolor")
    , widthRow "CJK" (Text.styled "界面" (Style.bold <+> Style.cyan))
    , widthRow "combining" (Text.styled "e\u0301" Style.yellow)
    , widthRow "emoji" (Text.styled "🚀" Style.magenta)
    , widthRow "multiline" (Text.plain "ab\n界")
    ]
  let padding := Text.concat
    [ Text.plain "padRight | " ++ padRight 16 (Text.styled "content" Style.green) ++ Text.plain "\n"
    , Text.plain "padLeft  | " ++ padLeft 16 (Text.styled "content" Style.cyan) ++ Text.plain "\n"
    ]
  let truncation := Text.concat
    [ Text.plain "truncate | " ++ truncate 16
        (Text.styled "界面 content that is longer" Style.yellow) ++ Text.plain "\n"
    , Text.plain "wrap    | " ++ wrap 16
        (Text.styled "界面 content that wraps and keeps style" Style.magenta) ++ Text.plain "\n"
    ]
  let document := Text.concat
    [ Text.styled "termcolor-layout" (Style.bold <+> Style.fg (.indexed 45))
    , Text.plain "\nPure styled-text layout\n"
    , heading "display width"
    , widthExamples
    , heading "padding and alignment"
    , padding
    , alignmentRows
    , heading "truncate and wrap"
    , truncation
    , heading "columns"
    , columnsDemo
    , heading "boxes"
    , boxesDemo
    , Text.plain "\nplainText removes styles: "
    , Text.plain (Text.plainText (Text.styled "still readable" Style.bold))
    , Text.plain "\n"
    ]
  IO.print (Text.render RenderTarget.ansi16 document)

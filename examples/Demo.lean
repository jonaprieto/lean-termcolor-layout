/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import TermColor.Layout
import TermColor.ColorScheme
import TermColor.Detect

open TermColor
open TermColor.Layout
open scoped TermColor.Style

private def demoPalette : ColorScheme := ColorScheme.catppuccin

private def heading (title : String) : Text :=
  Text.styled ("\n" ++ title ++ "\n") (Style.bold <+> Style.fg demoPalette.foreground)

private def widthRow (label : String) (value : Text) : Text :=
  Text.styled (label ++ "  ") (Style.dim <+> Style.fg demoPalette.comment) ++ value ++
    Text.styled ("  width=" ++ toString (Text.width value) ++
      " height=" ++ toString (Text.height value) ++ "\n")
      (Style.dim <+> Style.fg demoPalette.comment)

private def alignmentRows : Text := Text.concat
  [ Text.plain "left   | " ++ align 16 .left (Text.styled "left" (Style.fg demoPalette.green)) ++
      Text.plain "\n"
  , Text.plain "center | " ++ align 16 .center (Text.styled "center" (Style.fg demoPalette.yellow)) ++
      Text.plain "\n"
  , Text.plain "right  | " ++ align 16 .right (Text.styled "right" (Style.fg demoPalette.cyan)) ++
      Text.plain "\n"
  ]

private def columnsDemo : Text := Text.concat
  [ columns [12, 24, 10] 2
      [ Text.styled "Feature" (Style.bold <+> Style.fg demoPalette.purple)
      , Text.styled "What it preserves" (Style.bold <+> Style.fg demoPalette.purple)
      , Text.styled "Width" (Style.bold <+> Style.fg demoPalette.purple)
      ] [.left, .left, .right]
  , Text.plain "\n"
  , columns [12, 24, 10] 2
      [ Text.styled "width" (Style.fg demoPalette.cyan)
      , Text.plain "CJK and combining marks"
      , Text.plain "Unicode"
      ] [.left, .left, .right]
  , Text.plain "\n"
  , columns [12, 24, 10] 2
      [ Text.styled "wrap" (Style.fg demoPalette.cyan)
      , Text.styled "Styled content wraps without losing its color" (Style.fg demoPalette.green)
      , Text.plain "pure"
      ] [.left, .left, .right]
  , Text.plain "\n"
  , columns [12, 24, 10] 2
      [ Text.styled "box" (Style.fg demoPalette.cyan)
      , Text.plain "Padding, titles, borders, and max width"
      , Text.plain "layout"
      ] [.left, .left, .right]
  ]

private def boxesDemo : Text := Text.concat
  [ box
      (Text.styled "Unicode borders\nwrap inside a width limit" (Style.fg demoPalette.green))
      { title := some (Text.styled "default box" (Style.bold <+> Style.fg demoPalette.cyan))
        borderStyle := Style.fg demoPalette.comment
        padding := 1
        maxWidth := some 34 }
  , Text.plain "\n\n"
  , box
      (Text.styled "ASCII fallback\nwith a left title" (Style.fg demoPalette.yellow))
      { chars := asciiBoxChars
        title := some (Text.styled "fallback" (Style.bold <+> Style.fg demoPalette.purple))
        titleAlignment := .left
        borderStyle := Style.fg demoPalette.pink
        padding := 1 }
  ]

def main : IO Unit := do
  let widthExamples := Text.concat
    [ Text.styled ("defaultWidth=" ++ toString defaultWidth ++ "  charWidth('界')=" ++
        toString (charWidth '界') ++
        "  stringWidth(界面)=" ++ toString (stringWidth "界面") ++ "\n")
        (Style.dim <+> Style.fg demoPalette.comment)
    , widthRow "ASCII" (Text.plain "termcolor")
    , widthRow "CJK" (Text.styled "界面" (Style.bold <+> Style.fg demoPalette.cyan))
    , widthRow "combining" (Text.styled "e\u0301" (Style.fg demoPalette.yellow))
    , widthRow "emoji" (Text.styled "🚀" (Style.fg demoPalette.pink))
    , widthRow "multiline" (Text.plain "ab\n界")
    ]
  let padding := Text.concat
    [ Text.plain "padRight | " ++ padRight 16 (Text.styled "content" (Style.fg demoPalette.green)) ++
        Text.plain "\n"
    , Text.plain "padLeft  | " ++ padLeft 16 (Text.styled "content" (Style.fg demoPalette.cyan)) ++
        Text.plain "\n"
    ]
  let truncation := Text.concat
    [ Text.plain "truncate | " ++ truncate 16
        (Text.styled "界面 content that is longer" (Style.fg demoPalette.yellow)) ++ Text.plain "\n"
    , Text.plain "wrap    | " ++ wrapLines 16
        (Text.styled "界面 content that wraps and keeps style" (Style.fg demoPalette.pink)) ++
        Text.plain "\n"
    ]
  let document := Text.concat
    [ Text.styled "termcolor-layout" (Style.bold <+> Style.fg demoPalette.cyan)
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
  let target ← TermColor.target
  IO.print (Text.render target document)

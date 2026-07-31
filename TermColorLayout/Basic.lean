/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import TermColorLayout.Width

/-!
# TermColor.Layout.Basic: pure styled-text layout

These operations preserve segment styles and never emit ANSI escapes. Rendering remains the
responsibility of `TermColor.Text.render`.
-/

namespace TermColor
namespace Layout

/-! Default fallback for layout that has no terminal width yet. -/
def defaultWidth : Nat := 80

inductive Alignment where
  | left
  | right
  | center

private def spaces (count : Nat) : Text :=
  Text.plain (String.ofList (List.replicate count ' '))

private def annotatedChars (text : Text) : List (Char × Style) :=
  text.segments.flatMap fun segment => segment.text.toList.map fun character =>
    (character, segment.style)

private def fromAnnotated (items : List (Char × Style)) : Text :=
  let segments := items.foldl (fun segments (character, style) =>
    match segments with
    | last :: rest =>
        if last.style == style then
          { last with text := last.text.push character } :: rest
        else
          { text := character.toString, style := style } :: segments
    | [] => [{ text := character.toString, style := style }]) []
  { segments := segments.reverse }

private def splitLines (text : Text) : List Text :=
  let (current, completed) := annotatedChars text |>.foldl
    (fun (current, completed) (character, style) =>
      if character == '\n' then
        ([], fromAnnotated current.reverse :: completed)
      else
        ((character, style) :: current, completed)) ([], [])
  (fromAnnotated current.reverse :: completed).reverse

private def joinLines : List Text → Text
  | [] => Text.empty
  | first :: rest => rest.foldl (fun result line => result ++ Text.plain "\n" ++ line) first

private def splitAtWidth (limit : Nat) (items : List (Char × Style)) :
    List (Char × Style) × List (Char × Style) :=
  let rec go (remaining : Nat) (acc : List (Char × Style)) :
      List (Char × Style) → List (Char × Style) × List (Char × Style)
    | [] => (acc.reverse, [])
    | item :: rest =>
        let itemWidth := charWidth item.1
        if itemWidth == 0 || itemWidth ≤ remaining then
          go (remaining - itemWidth) (item :: acc) rest
        else
          (acc.reverse, item :: rest)
  go limit [] items

private def takeWidth (limit : Nat) (text : Text) : Text :=
  if limit == 0 then Text.empty
  else fromAnnotated (splitAtWidth limit (annotatedChars text)).1

private def mapLines (function : Text → Text) (text : Text) : Text :=
  joinLines (splitLines text |>.map function)

/-- Pad every logical line on the right to `target` columns. -/
def padRight (target : Nat) (text : Text) : Text :=
  mapLines (fun line => line ++ spaces (target - stringWidth line.plainText)) text

/-- Pad every logical line on the left to `target` columns. -/
def padLeft (target : Nat) (text : Text) : Text :=
  mapLines (fun line => spaces (target - stringWidth line.plainText) ++ line) text

/-- Align every logical line to `target` columns. -/
def align (target : Nat) (alignment : Alignment) (text : Text) : Text :=
  match alignment with
  | .left => padRight target text
  | .right => padLeft target text
  | .center =>
      mapLines (fun line =>
        let missing := target - stringWidth line.plainText
        let left := missing / 2
        spaces left ++ line ++ spaces (missing - left)) text

/-- Keep at most `limit` display columns on each logical line. -/
def truncate (limit : Nat) (text : Text) : Text :=
  mapLines (takeWidth limit) text

private def wrapAnnotated (limit : Nat) (items : List (Char × Style)) :
    List (List (Char × Style)) :=
  let rec go (remaining : Nat) (current : List (Char × Style))
      (completed : List (List (Char × Style))) : List (Char × Style) →
      List (List (Char × Style))
    | [] =>
        if current.isEmpty then completed.reverse else (current.reverse :: completed).reverse
    | item :: rest =>
        let itemWidth := charWidth item.1
        if itemWidth == 0 || itemWidth ≤ remaining || current.isEmpty then
          go (remaining - min itemWidth remaining) (item :: current) completed rest
        else
          go (limit - min itemWidth limit) [item] (current.reverse :: completed) rest
  go limit [] [] items

private def wrapLine (limit : Nat) (line : Text) : List Text :=
  let chunks := wrapAnnotated limit (annotatedChars line)
  if chunks.isEmpty then [Text.empty] else chunks.map fromAnnotated

/-- Wrap every logical line to at most `limit` display columns. A wide first character may occupy
two columns when `limit` is one, since splitting a character is impossible. -/
def wrap (limit : Nat) (text : Text) : Text :=
  let limit := max 1 limit
  joinLines ((splitLines text).flatMap (wrapLine limit))

private def widthAt (widths : List Nat) (index : Nat) : Nat :=
  widths.getD index (widths.getD (widths.length - 1) defaultWidth)

private def alignmentAt (alignments : List Alignment) (index : Nat) : Alignment :=
  alignments.getD index .left

private def maxRows (columns : List (List Text)) : Nat :=
  columns.foldl (fun result column => max result column.length) 0

private def row (widths : List Nat) (gap : Nat) (alignments : List Alignment)
    (columns : List (List Text)) (index : Nat) : Text :=
  let cells := columns.mapIdx fun columnIndex column =>
    align (widthAt widths columnIndex) (alignmentAt alignments columnIndex)
      (column.getD index Text.empty)
  let separator := spaces gap
  match cells with
  | [] => Text.empty
  | first :: rest => rest.foldl (fun result cell => result ++ separator ++ cell) first

/-- Lay out one row of styled cells as fixed-width columns. Cells wrap before alignment. -/
def columns (widths : List Nat) (gap : Nat) (cells : List Text)
    (alignments : List Alignment := []) : Text :=
  let wrapped := cells.mapIdx fun index cell =>
    splitLines (wrap (widthAt widths index) cell)
  let rows := maxRows wrapped
  joinLines ((List.range rows).map (row widths gap alignments wrapped))

structure BoxChars where
  topLeft : Char := '┌'
  topRight : Char := '┐'
  bottomLeft : Char := '└'
  bottomRight : Char := '┘'
  horizontal : Char := '─'
  vertical : Char := '│'

def asciiBoxChars : BoxChars where
  topLeft := '+'
  topRight := '+'
  bottomLeft := '+'
  bottomRight := '+'
  horizontal := '-'
  vertical := '|'

structure BoxConfig where
  chars : BoxChars := {}
  borderStyle : Style := {}
  padding : Nat := 1
  title : Option Text := none
  titleAlignment : Alignment := .center
  maxWidth : Option Nat := some defaultWidth

private def borderRun (config : BoxConfig) (character : Char) (count : Nat) : Text :=
  Text.styled (String.ofList (List.replicate count character)) config.borderStyle

private def boxTop (config : BoxConfig) (innerWidth : Nat) : Text :=
  let borderWidth := innerWidth + 2 * config.padding
  let left := Text.styled (String.ofList [config.chars.topLeft]) config.borderStyle
  let right := Text.styled (String.ofList [config.chars.topRight]) config.borderStyle
  match config.title with
  | none => left ++ borderRun config config.chars.horizontal borderWidth ++ right
  | some title =>
      let titleText := Text.plain " " ++ title ++ Text.plain " "
      let missing := borderWidth - stringWidth titleText.plainText
      let leftFill := match config.titleAlignment with
        | .left => 0
        | .right => missing
        | .center => missing / 2
      left ++ borderRun config config.chars.horizontal leftFill ++ titleText ++
        borderRun config config.chars.horizontal (missing - leftFill) ++ right

private def boxLine (config : BoxConfig) (innerWidth : Nat) (line : Text) : Text :=
  let left := Text.styled (String.ofList [config.chars.vertical]) config.borderStyle
  let right := Text.styled (String.ofList [config.chars.vertical]) config.borderStyle
  left ++ spaces config.padding ++ line ++
    spaces (innerWidth - stringWidth line.plainText) ++ spaces config.padding ++ right

/-- Draw a pure text box around styled content. `maxWidth` limits the outer width when supplied. -/
def box (content : Text) (config : BoxConfig := {}) : Text :=
  let available := config.maxWidth.map fun width => max 1 (width - 2 - 2 * config.padding)
  let content := match available with
    | some width => wrap width content
    | none => content
  let contentLines := splitLines content
  let contentWidth := contentLines.foldl
    (fun result line => max result (stringWidth line.plainText)) 0
  let titleWidth := match config.title with
    | none => 0
    | some title => stringWidth title.plainText + 2
  let innerWidth := max contentWidth titleWidth
  let body := contentLines.map (boxLine config innerWidth)
  let bottomLeft := Text.styled (String.ofList [config.chars.bottomLeft]) config.borderStyle
  let bottomRight := Text.styled (String.ofList [config.chars.bottomRight]) config.borderStyle
  joinLines ([boxTop config innerWidth] ++ body ++ [bottomLeft ++
    borderRun config config.chars.horizontal (innerWidth + 2 * config.padding) ++ bottomRight])

end Layout
end TermColor

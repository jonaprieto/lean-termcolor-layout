/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import TermColor.Layout.Width

/-!
# TermColor.Layout.Basic: pure styled-text layout

These operations preserve segment styles and never emit ANSI escapes. Rendering remains the
responsibility of `TermColor.Text.render`.
-/

namespace TermColor
namespace Layout

/-- Default fallback for layout that has no terminal width yet. -/
def defaultWidth : Nat := 80

inductive Alignment where
  /-- Align content against the left edge. -/
  | left
  /-- Align content against the right edge. -/
  | right
  /-- Center content within the available width. -/
  | center
  deriving BEq, DecidableEq, Repr, Inhabited

private def spaces (count : Nat) : Text :=
  Text.plain (String.ofList (List.replicate count ' '))

private def annotatedChars (text : Text) : List (Char × Style × Option String) :=
  text.segments.flatMap fun segment => segment.text.toList.map fun character =>
    (character, segment.style, segment.link)

private def fromAnnotated (items : List (Char × Style × Option String)) : Text :=
  let segments := items.foldl (fun segments (character, style, link) =>
    match segments with
    | last :: rest =>
        if last.style == style && last.link == link then
          { last with text := last.text.push character } :: rest
        else
          { text := character.toString, style := style, link := link } :: segments
    | [] => [{ text := character.toString, style := style, link := link }]) []
  { segments := segments.reverse }

/-- Split a `Text` into logical lines on `'\n'`, preserving each segment's style.

The counterpart to `joinLines`. Callers laying out their own multi-line cells need this to
indent or pad continuation lines: `columns` aligns every column to its width, so a caller
that wants no trailing padding on the last column has to split and rejoin itself. -/
def splitLines (text : Text) : List Text :=
  let (current, completed) := annotatedChars text |>.foldl
    (fun (current, completed) (character, style, link) =>
      if character == '\n' then
        ([], fromAnnotated current.reverse :: completed)
      else
        ((character, style, link) :: current, completed)) ([], [])
  (fromAnnotated current.reverse :: completed).reverse

/-- Join logical lines with newline separators. -/
def joinLines : List Text → Text
  | [] => Text.empty
  | first :: rest => rest.foldl (fun result line => result ++ Text.plain "\n" ++ line) first

private def splitAtWidth (limit : Nat) (items : List (Char × Style × Option String)) :
    List (Char × Style × Option String) × List (Char × Style × Option String) :=
  let rec go (remaining : Nat) (acc : List (Char × Style × Option String)) :
      List (Char × Style × Option String) →
        List (Char × Style × Option String) × List (Char × Style × Option String)
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

private def wrapAnnotated (limit : Nat) (items : List (Char × Style × Option String)) :
    List (List (Char × Style × Option String)) :=
  let rec go (remaining : Nat) (current : List (Char × Style × Option String))
      (completed : List (List (Char × Style × Option String))) :
      List (Char × Style × Option String) → List (List (Char × Style × Option String))
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
def wrapLines (limit : Nat) (text : Text) : Text :=
  let limit := max 1 limit
  joinLines ((splitLines text).flatMap (wrapLine limit))

private def trimTrailingSpaces (items : List (Char × Style × Option String)) :
    List (Char × Style × Option String) :=
  List.reverse (List.dropWhile (fun item => item.1 == ' ') (List.reverse items))

private def lastSpaceIndex (items : List (Char × Style × Option String)) : Option Nat :=
  (items.foldl (fun (found, index) item =>
    (if item.1 == ' ' then some index else found, index + 1)) (none, 0)).1

private def wrapWordLine (limit : Nat) (items : List (Char × Style × Option String)) :
    List (List (Char × Style × Option String)) :=
  if items.isEmpty then [[]]
  else
    let rec go (fuel : Nat) (remaining : List (Char × Style × Option String))
        (completed : List (List (Char × Style × Option String))) :
        List (List (Char × Style × Option String)) :=
      match fuel with
      | 0 => completed.reverse
      | fuel + 1 =>
          match wrapAnnotated limit remaining with
          | [] => completed.reverse
          | chunk :: rest =>
              let hardRest := rest.flatten
              if hardRest.isEmpty then
                (chunk :: completed).reverse
              else
                match lastSpaceIndex chunk with
                | none => go fuel hardRest (chunk :: completed)
                | some index =>
                    let line := trimTrailingSpaces (chunk.take index)
                    let next := List.dropWhile (fun item => item.1 == ' ')
                      (chunk.drop (index + 1) ++ hardRest)
                    go fuel next (line :: completed)
    go (items.length + 1) items []

/-- Wrap every logical line to at most `limit` display columns, breaking at spaces where
possible. A word wider than `limit` is split like `wrapLines`; spaces at a break are dropped. -/
def wrapWords (limit : Nat) (text : Text) : Text :=
  let limit := max 1 limit
  joinLines ((splitLines text).flatMap fun line =>
    (wrapWordLine limit (annotatedChars line)).map fromAnnotated)

/-- Wrap `body` to `width`, prefixing its first line with `marker` and continuations with spaces. -/
def gutter (marker : Text) (indent width : Nat) (body : Text) : Text :=
  let wrapped := splitLines (wrapLines (max 1 (width - indent)) body)
  match wrapped with
  | [] => marker
  | first :: rest =>
      joinLines ((marker ++ first) :: rest.map (fun line => spaces indent ++ line))

private def widthAt (widths : List Nat) (index : Nat) : Nat :=
  widths.getD index (widths.getD (widths.length - 1) defaultWidth)

private def alignmentAt (alignments : List Alignment) (index : Nat) : Alignment :=
  alignments.getD index .left

private def maxRows (columns : List (List Text)) : Nat :=
  columns.foldl (fun result column => max result column.length) 0

private def columnSeparator (gap : Nat) (separator : Text) : Text :=
  if separator.segments.all (·.text.isEmpty) then
    spaces gap
  else
    let separatorWidth := stringWidth separator.plainText
    let used := min gap separatorWidth
    let left := (gap - used) / 2
    spaces left ++ separator ++ spaces (gap - used - left)

private def row (widths : List Nat) (gap : Nat) (alignments : List Alignment)
    (separator : Text)
    (columns : List (List Text)) (index : Nat) : Text :=
  let cells := columns.mapIdx fun columnIndex column =>
    align (widthAt widths columnIndex) (alignmentAt alignments columnIndex)
      (column.getD index Text.empty)
  let separator := columnSeparator gap separator
  match cells with
  | [] => Text.empty
  | first :: rest => rest.foldl (fun result cell => result ++ separator ++ cell) first

/-- Lay out one row of styled cells as fixed-width columns. Cells wrap before alignment. -/
def columns (widths : List Nat) (gap : Nat) (cells : List Text)
    (alignments : List Alignment := []) (separator : Text := Text.empty) : Text :=
  let wrapped := cells.mapIdx fun index cell =>
    splitLines (wrapLines (widthAt widths index) cell)
  let rows := maxRows wrapped
  joinLines ((List.range rows).map (row widths gap alignments separator wrapped))

/-! Characters used to draw a box. -/
structure BoxChars where
  /-- Top-left corner. -/
  topLeft : Char := '┌'
  /-- Top-right corner. -/
  topRight : Char := '┐'
  /-- Bottom-left corner. -/
  bottomLeft : Char := '└'
  /-- Bottom-right corner. -/
  bottomRight : Char := '┘'
  /-- Horizontal border character. -/
  horizontal : Char := '─'
  /-- Vertical border character. -/
  vertical : Char := '│'
  deriving BEq, DecidableEq, Repr, Inhabited

/-- ASCII characters for terminals without Unicode box drawing. -/
def asciiBoxChars : BoxChars where
  topLeft := '+'
  topRight := '+'
  bottomLeft := '+'
  bottomRight := '+'
  horizontal := '-'
  vertical := '|'

/-! Configuration for `box`. `maxWidth` is the outer width, including borders and padding. -/
structure BoxConfig where
  /-- Characters used for the border. -/
  chars : BoxChars := {}
  /-- Style applied to border characters. -/
  borderStyle : Style := {}
  /-- Number of spaces between the border and content. -/
  padding : Nat := 1
  /-- Optional one-line title in the top border. -/
  title : Option Text := none
  /-- Horizontal alignment of the title. -/
  titleAlignment : Alignment := .center
  /-- Maximum outer width, including borders and padding. -/
  maxWidth : Option Nat := some defaultWidth
  deriving BEq, DecidableEq, Repr

instance : Inhabited BoxConfig := ⟨{}⟩

/-- The content width left inside a box with the given outer width. -/
def boxInnerWidth (config : BoxConfig) (outer : Nat) : Nat :=
  max 1 (outer - 2 - 2 * config.padding)

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
  let available := config.maxWidth.map (boxInnerWidth config)
  let content := match available with
    | some width => wrapLines width content
    | none => content
  let title := match available, config.title with
    | some width, some title =>
        if width < 2 then none else some (truncate (width - 2) title)
    | _, title => title
  let config := { config with title }
  let contentLines := splitLines content
  let contentWidth := contentLines.foldl
    (fun result line => max result (stringWidth line.plainText)) 0
  let titleWidth := match title with
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

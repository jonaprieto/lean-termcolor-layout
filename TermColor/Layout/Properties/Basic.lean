/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import TermColor.Layout

set_option maxRecDepth 10000

/-!
# termcolor-layout properties

The executable library stays small; these laws hold its visible-text and layout contract.
-/

namespace TermColor
namespace Layout

theorem width_empty : Text.width Text.empty = 0 := by
  decide

theorem default_width_is_80 : defaultWidth = 80 := by
  decide

theorem width_plain (text : String) : Text.width (Text.plain text) = stringWidth text := by
  rfl

theorem expand_tabs_to_next_stop : expandTabs 4 "a\tb" = "a   b" := by
  decide

theorem expand_tabs_resets_after_newline : expandTabs 4 "ab\tx\nq\tx" = "ab  x\nq   x" := by
  decide

theorem string_width_with_tabs : stringWidthWithTabs 4 "a\tb" = 5 := by
  decide

theorem width_ignores_style (text : String) (style : Style) :
    Text.width (Text.styled text style) = stringWidth text := by
  rfl

theorem pad_right_example :
    (padRight 5 (Text.plain "hi")).plainText = "hi   " := by
  decide

theorem pad_left_example :
    (padLeft 5 (Text.plain "hi")).plainText = "   hi" := by
  decide

theorem align_left_example :
    (align 5 .left (Text.plain "hi")).plainText = "hi   " := by
  decide

theorem align_center_example :
    (align 5 .center (Text.plain "hi")).plainText = " hi  " := by
  decide

theorem align_right_example :
    (align 5 .right (Text.plain "hi")).plainText = "   hi" := by
  decide

theorem multiline_padding_example :
    (padRight 3 (Text.plain "a\n界")).plainText = "a  \n界 " := by
  decide

theorem truncate_example :
    (truncate 3 (Text.plain "hello")).plainText = "hel" := by
  decide

theorem truncate_wide_character_does_not_overflow :
    (truncate 1 (Text.plain "界")).plainText = "" := by
  decide

theorem truncate_preserves_style_text :
    (truncate 3 (Text.styled "界面" Style.cyan)).plainText = "界" := by
  decide

theorem wrap_preserves_ascii_chunks :
    (wrapLines 3 (Text.plain "abcdef")).plainText = "abc\ndef" := by
  decide

theorem wrap_wide_characters_do_not_overflow :
    (wrapLines 3 (Text.plain "界面")).plainText = "界\n面" := by
  decide

theorem wrap_words_prefers_spaces :
    (wrapWords 8 (Text.plain "hello world")).plainText = "hello\nworld" := by
  decide

theorem wrap_words_splits_long_words :
    (wrapWords 3 (Text.plain "abcdef")).plainText = "abc\ndef" := by
  decide

theorem gutter_aligns_continuations :
    (gutter (Text.plain "› ") 2 12 (Text.plain "a long expression")).plainText =
      "› a long exp\n  ression" := by
  decide

theorem columns_draws_styled_separator :
    (columns [2, 2] 1 [Text.plain "a", Text.plain "b"] [] (Text.plain "│")).plainText =
      "a │b " := by
  decide

theorem box_inner_width_matches_box :
    boxInnerWidth { padding := 1 } 12 = 8 := by
  decide

theorem split_lines_single_line :
    (splitLines (Text.plain "hi")).length = 1 := by
  decide

theorem split_lines_counts_logical_lines :
    (splitLines (Text.plain "a\nb\nc")).length = 3 := by
  decide

theorem split_lines_keeps_empty_line :
    (splitLines (Text.plain "a\n\nb")).length = 3 := by
  decide

theorem split_lines_join_roundtrip :
    (joinLines (splitLines (Text.plain "a\nb\nc"))).plainText = "a\nb\nc" := by
  decide

theorem split_lines_preserves_style :
    (splitLines (Text.styled "a\nb" Style.bold)).map (·.plainText) = ["a", "b"] := by
  decide

end Layout
end TermColor

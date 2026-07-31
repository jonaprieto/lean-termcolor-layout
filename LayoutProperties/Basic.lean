/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import TermColorLayout

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
    (wrap 3 (Text.plain "abcdef")).plainText = "abc\ndef" := by
  decide

theorem wrap_wide_characters_do_not_overflow :
    (wrap 3 (Text.plain "界面")).plainText = "界\n面" := by
  decide

end Layout
end TermColor

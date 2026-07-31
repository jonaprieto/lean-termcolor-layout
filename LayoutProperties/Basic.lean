/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import TermColorLayout

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

set_option maxRecDepth 10000 in
theorem pad_right_example :
    (padRight 5 (Text.plain "hi")).plainText = "hi   " := by
  decide

set_option maxRecDepth 10000 in
theorem truncate_example :
    (truncate 3 (Text.plain "hello")).plainText = "hel" := by
  decide

set_option maxRecDepth 10000 in
theorem wrap_preserves_ascii_chunks :
    (wrap 3 (Text.plain "abcdef")).plainText = "abc\ndef" := by
  decide

end Layout
end TermColor

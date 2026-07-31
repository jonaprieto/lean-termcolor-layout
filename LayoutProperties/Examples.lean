/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import LayoutProperties.Basic

namespace TermColor
namespace Layout

set_option maxRecDepth 10000 in
theorem ascii_width : stringWidth "termcolor" = 9 := by
  decide

set_option maxRecDepth 10000 in
theorem cjk_width : stringWidth "界" = 2 := by
  decide

theorem combining_width : stringWidth "e\u0301" = 1 := by
  decide

set_option maxRecDepth 10000 in
theorem ansi_style_does_not_change_width :
    Text.width (Text.styled "warning" Style.bold) = 7 := by
  decide

set_option maxRecDepth 10000 in
theorem wrapping_example :
    (wrap 3 (Text.plain "abcdef")).plainText = "abc\ndef" := by
  decide

set_option maxRecDepth 10000 in
theorem columns_example :
    (columns [4, 4] 1 [Text.plain "a", Text.plain "b"]).plainText = "a    b   " := by
  decide

set_option maxRecDepth 10000 in
theorem box_example :
    (box (Text.plain "hi") { padding := 1 }).plainText =
      "┌────┐\n│ hi │\n└────┘" := by
  decide

end Layout
end TermColor

/-
Copyright (c) 2026 Jonathan Prieto-Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import TermColor.Layout.Properties.Basic

set_option maxRecDepth 10000

namespace TermColor
namespace Layout

theorem ascii_width : stringWidth "termcolor" = 9 := by
  decide

theorem cjk_width : stringWidth "界" = 2 := by
  decide

theorem combining_width : stringWidth "e\u0301" = 1 := by
  decide

theorem ansi_style_does_not_change_width :
    Text.width (Text.styled "warning" Style.bold) = 7 := by
  decide

theorem wrapping_keeps_style :
    Text.render RenderTarget.ansi16 (wrap 1 (Text.styled "ab" Style.red)) =
      "\u001b[31ma\u001b[0m\n\u001b[31mb\u001b[0m" := by
  decide

theorem columns_example :
    (columns [4, 4] 1 [Text.plain "a", Text.plain "b"]).plainText = "a    b   " := by
  decide

theorem columns_wrap_example :
    (columns [4, 4] 1 [Text.plain "abcde", Text.plain "x"]).plainText =
      "abcd x   \ne        " := by
  decide

theorem box_example :
    (box (Text.plain "hi") { padding := 1 }).plainText =
      "┌────┐\n│ hi │\n└────┘" := by
  decide

theorem ascii_box_example :
    (box (Text.plain "hi") { chars := asciiBoxChars, padding := 1 }).plainText =
      "+----+\n| hi |\n+----+" := by
  decide

end Layout
end TermColor

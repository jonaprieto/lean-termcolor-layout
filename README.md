# termcolor-layout

Pure display-width measurement and layout for [`termcolor`](https://github.com/jonaprieto/lean-termcolor).

It preserves `TermColor.Text` styles while providing Unicode-aware width, padding, alignment,
truncation, wrapping, columns, and boxes. It performs no terminal IO and emits no ANSI escapes
until the caller uses `Text.render`. Width-sensitive defaults use 80 columns until a caller supplies
the live terminal width.

```lean
import TermColorLayout

open TermColor
open TermColor.Layout

def message : Text := Text.styled "界面" Style.bold

#eval Text.width message -- 4
#eval (wrap 3 message).plainText
```

Build:

```sh
lake build TermColorLayout LayoutProperties demo
lake exe demo
```

The separate `LayoutProperties` library contains machine-checked laws and concrete width/layout
examples. The layout policy treats controls and combining marks as zero-width, common CJK and
emoji as two columns, and ambiguous characters as one. It is codepoint-based and does not model
grapheme-cluster shaping or terminal-specific emoji presentation.

## License

Apache-2.0.

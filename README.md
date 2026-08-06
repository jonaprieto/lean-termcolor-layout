# termcolor-layout

[![CI](https://github.com/jonaprieto/lean-termcolor-layout/workflows/CI/badge.svg)](https://github.com/jonaprieto/lean-termcolor-layout/actions/workflows/ci.yml)
[![Lean 4](https://img.shields.io/badge/Lean%204-library-5f5f5f)](lean-toolchain)
[![License](https://img.shields.io/badge/license-Apache--2.0-green)](LICENSE)

Pure display-width measurement and layout for [`termcolor`](https://github.com/jonaprieto/lean-termcolor).

It preserves `TermColor.Text` styles while providing Unicode-aware width, padding, alignment,
truncation, wrapping, columns, and boxes. It performs no terminal IO and emits no ANSI escapes
until the caller uses `Text.render`. Width-sensitive defaults use 80 columns until a caller supplies
the live terminal width.

It is the layout layer used by [`termcolor-widgets`](https://github.com/jonaprieto/lean-termcolor-widgets),
[`termcolor-terminal`](https://github.com/jonaprieto/lean-termcolor-terminal), and
[`argus`](https://github.com/jonaprieto/lean-argus).

## What it provides

- display-cell width for control characters, combining marks, CJK text, emoji, and ambiguous characters;
- truncation, wrapping, padding, alignment, columns, and bordered boxes;
- word-aware wrapping, hanging gutters, column separators, and public box inner-width calculation;
- `splitLines` and `joinLines`, a pair: split a `Text` into logical lines preserving each
  segment's style, and put it back together. A caller laying out its own cells needs both,
  because `columns` pads every column including the last;
- style-preserving `TermColor.Text` output, including OSC-8 hyperlink metadata, that remains
  independent of terminal capabilities.

```lean
import TermColor.Layout

open TermColor
open TermColor.Layout

def message : Text := Text.styled "界面" Style.bold

#eval Text.width message -- 4
#eval (wrapLines 3 message).plainText
```

## Build

```sh
lake build TermColor.Layout TermColor.Layout.Properties demo
lake exe demo
```

## Demo

The demo covers Unicode display cells, tab stops, alignment, wrapping, columns, boxes, ASCII
fallbacks, and style/OSC-8 metadata preservation.

The separate `TermColor.Layout.Properties` library contains machine-checked laws and concrete width/layout
examples. The layout policy treats controls and combining marks as zero-width, common CJK and
emoji as two columns, and ambiguous characters as one. It is codepoint-based and does not model
grapheme-cluster shaping or terminal-specific emoji presentation.

## License

Apache-2.0.

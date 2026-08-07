# termcolor-layout

[![CI](https://github.com/jonaprieto/lean-termcolor-layout/actions/workflows/ci.yml/badge.svg)](https://github.com/jonaprieto/lean-termcolor-layout/actions/workflows/ci.yml)
[![Lean 4](https://img.shields.io/badge/Lean%204-library-5f5f5f)](lean-toolchain)
[![License](https://img.shields.io/badge/license-Apache--2.0-green)](LICENSE)

Pure display-width measurement and layout for [`termcolor`](https://github.com/jonaprieto/lean-termcolor).
Styles remain attached to `Text`; no terminal IO or escape emission occurs here.

## Provides

Display-cell width, truncation, wrapping, padding, alignment, columns, boxes, `splitLines`, and
`joinLines`. The default width is 80 columns until a caller supplies a terminal width.

```lean
import TermColor.Layout

open TermColor TermColor.Layout

def message : Text := Text.styled "界面" Style.bold
#eval Text.width message
#eval (wrapLines 3 message).plainText
```

## Build

```sh
lake build TermColor.Layout TermColor.Layout.Properties demo
lake exe demo
```

## Related projects

Used by [`termcolor-widgets`](https://github.com/jonaprieto/lean-termcolor-widgets),
[`termcolor-terminal`](https://github.com/jonaprieto/lean-termcolor-terminal), and
[`argus`](https://github.com/jonaprieto/lean-argus).

## License

Apache-2.0.

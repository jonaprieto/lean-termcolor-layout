# TermColor.Layout.Properties

The separate property library keeps the runtime package dependency-free and documents the
visible-width and layout contract with machine-checked laws and concrete examples.

The width policy is codepoint-based. It handles controls, combining marks, CJK, and common emoji,
but does not model grapheme-cluster shaping or terminal-specific emoji presentation.

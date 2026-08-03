import Lake
open Lake DSL

package «termcolor-layout» where
  version := v!"0.1.6"
  leanOptions := #[⟨`autoImplicit, false⟩, ⟨`relaxedAutoImplicit, false⟩]

require «termcolor» from git
  "https://github.com/jonaprieto/lean-termcolor.git"
  @ "d0d9a6d24cd06a2ca5de0c47d1860fb0363aa397"

@[default_target]
lean_lib «TermColor.Layout» where
  roots := #[`TermColor.Layout]
  globs := #[.andSubmodules `TermColor.Layout]

lean_lib «TermColor.Layout.Properties» where
  roots := #[`TermColor.Layout.Properties]
  globs := #[.andSubmodules `TermColor.Layout.Properties]

lean_exe «demo» where
  root := `Demo
  srcDir := "examples"

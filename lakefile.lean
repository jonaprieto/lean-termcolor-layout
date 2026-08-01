import Lake
open Lake DSL

package «termcolor-layout» where
  version := v!"0.1.0"
  leanOptions := #[⟨`autoImplicit, false⟩, ⟨`relaxedAutoImplicit, false⟩]

require «termcolor» from git
  "https://github.com/jonaprieto/lean-termcolor.git" @ "1d78a0ce44f3f97fe55f5b02d13fa42af55e8229"

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

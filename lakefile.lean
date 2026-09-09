import Lake
open Lake DSL

package «termcolor-layout» where
  version := v!"0.1.15"
  leanOptions := #[⟨`autoImplicit, false⟩, ⟨`relaxedAutoImplicit, false⟩]

require «termcolor» from git
  "https://github.com/jonaprieto/lean-termcolor.git"
  @ "v1.1.7"

@[default_target]
lean_lib «TermColor.Layout» where
  roots := #[`TermColor.Layout]
  globs := #[.andSubmodules `TermColor.Layout]

lean_lib «TermColor.Layout.Properties» where
  roots := #[`TermColor.Layout.Properties]
  globs := #[.andSubmodules `TermColor.Layout.Properties]

@[test_driver]
lean_exe «tests» where
  root := `Tests
  srcDir := "test"

lean_exe «demo» where
  root := `Demo
  srcDir := "examples"

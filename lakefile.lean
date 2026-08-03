import Lake
open Lake DSL

package «termcolor-layout» where
  version := v!"0.1.4"
  leanOptions := #[⟨`autoImplicit, false⟩, ⟨`relaxedAutoImplicit, false⟩]

require «termcolor» from git
  "https://github.com/jonaprieto/lean-termcolor.git"
  @ "f0c0cef08a9c0c2019929856d48c6ba46458a26f"

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

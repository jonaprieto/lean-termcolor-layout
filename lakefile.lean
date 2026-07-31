import Lake
open Lake DSL

package «termcolor-layout» where
  version := v!"0.1.0"
  leanOptions := #[⟨`autoImplicit, false⟩, ⟨`relaxedAutoImplicit, false⟩]

require «termcolor» from git
  "https://github.com/jonaprieto/lean-termcolor.git" @ "5af8a9895750a735d18a77a3cd866cbf48ccd45d"

@[default_target]
lean_lib «TermColorLayout» where
  globs := #[.andSubmodules `TermColorLayout]

lean_lib «LayoutProperties» where
  globs := #[.andSubmodules `LayoutProperties]

lean_exe «demo» where
  root := `Demo
  srcDir := "examples"

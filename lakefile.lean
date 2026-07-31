import Lake
open Lake DSL

package «termcolor-layout» where
  version := v!"0.1.0"
  leanOptions := #[⟨`autoImplicit, false⟩, ⟨`relaxedAutoImplicit, false⟩]

-- API documentation is opt-in so normal users keep the small dependency set.
meta if get_config? env = some "dev" then
  require «doc-gen4» from git
    "https://github.com/leanprover/doc-gen4" @ "a41d5ebebfa77afe737fec8de8ad03fc8b08fdff"

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

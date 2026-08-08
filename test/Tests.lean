/-
Copyright (c) 2026 Jonathan Cubides. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jonathan Prieto-Cubides
-/

import TermColor.Layout

/-!
# Layout reference checks

These checks intentionally use plain ASCII strings and tiny reference functions. They are not a
second production implementation: their purpose is to catch changes to padding and truncation
semantics without depending on the implementation's private helpers or on a property-testing
framework.
-/

open TermColor TermColor.Layout

private def inputs : List String := ["", "a", "ab", "abc", "hello", "lean"]

private def referencePadRight (target : Nat) (text : String) : String :=
  text ++ String.ofList (List.replicate (target - text.length) ' ')

private def referencePadLeft (target : Nat) (text : String) : String :=
  String.ofList (List.replicate (target - text.length) ' ') ++ text

private def referenceTruncate (limit : Nat) (text : String) : String :=
  String.ofList (text.toList.take limit)

private def paddingChecks : List Bool :=
  inputs.flatMap fun text =>
    [ (padRight 5 (Text.plain text)).plainText == referencePadRight 5 text
    , (padLeft 5 (Text.plain text)).plainText == referencePadLeft 5 text
    , (truncate 3 (Text.plain text)).plainText == referenceTruncate 3 text
    ]

private def roundTripChecks : List Bool :=
  [ (joinLines (splitLines (Text.plain "a\nb\nc"))).plainText == "a\nb\nc"
  , (joinLines (splitLines (Text.plain "a\n\nb"))).plainText == "a\n\nb"
  , (wrapLines 3 (Text.plain "abcdef")).plainText == "abc\ndef"
  ]

#guard paddingChecks.all id
#guard roundTripChecks.all id

def main : IO UInt32 := do
  IO.println "layout reference checks passed"
  pure 0

# P07 focused bench progress

The historical P07 2/2 stop remains unchanged. This bench is separately and
explicitly authorized by authorization.md. Maintained source is unchanged.

## Step 1 — reproduction and bounded localization

The isolated baseline reproduces all four errors. Patched input file hashes
match the preserved source-state.json exactly. run.py restores c234058e files
under .build/p07-focused-bench/inputs, applies the saved patch there and redirects
all outputs/caches. Imported pinned module/object identities are recorded in
pinned-inputs.json. No reduction is an accepted implementation.

| Diagnostic | Change | Compiler result |
| --- | --- | --- |
| D01 | Empty exercisePipeline body | Same four errors |
| D02 | Trap CyclePipelineOwner initializer body | Same four errors |
| D03 | Restore owned generic owner/probe; preserve diagnostic admission field | Compiles |
| D04 | Trap four semantic-borrow/offer methods | Same four errors |
| D05 | Empty cyclePipelineProbe caller body | Same four errors |
| D06 | Emit unoptimized SILGen for exact failing source | Emits intermediate SIL |
| D07 | Make four stored scopes private; trap external scope reader | Compiles |

SILGen's four synthesized read accessors each issue `load [copy]` for a
noncopyable scoped field. See accessor-evidence.txt. The owner becomes loadable
when generic owned Geometry/Interaction fields are replaced by pointer fields;
its former indirect generic arrangement compiles. D07 isolates exported stored
scope accessors as a concrete repair target. This is compiler localization, not
proof that all related lifetime constructs are broken.

Diagnostic budget: **7/12 used**. Workaround candidates: **0/2 used**.
Bench consecutive unproductive workaround repairs: **0/2**.
Next: candidate 1 keeps stored scopes private and supplies explicit lifetime-bound
borrow methods to the external coordinator join, preserving every real method.
Then test the consuming-owned alternative, with positive and negative evidence.

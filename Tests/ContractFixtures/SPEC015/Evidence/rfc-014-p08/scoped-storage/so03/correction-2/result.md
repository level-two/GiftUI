# SO-03 correction-2 precompiler checkpoint — 2026-10-14

**UNVALIDATED.** Eugene explicitly approved one fixture-only helper correction,
one native rerun and independent Strong review, with zero further automatic
repairs. [Authorization/dispatch](../../../progress.md#so-03-correction-2-authorization-and-dispatch--2026-10-14)
precedes source edits; exact proposal is the [preceding independent review](../correction-1/independent-review.md).
Clean entry `7531e5c3`; implementation-executor task `p08_so03_helper_correction`,
no subagents. Parent arranges a fresh separate independent Strong review.

The sole source delta is ScopedStorageProbe.swift: private so03InitialCount takes
all five consuming independent accesses, invokes unchanged so03Union, consumes its
actual Optional, and reads committedRecordCount in the helper before returning an
owned UInt16. The call passes all temporary mutableSpan accesses in the same full
expression and retains the zero-count assertion. so03Union/so03GenericUnion,
every lifetime annotation, positive twin, negative cause, 27 focused labels and
closed common-session operation/retained-owned assertions remain unchanged.
No driver or production source changed. Accepted ADR-039/S11.1–4/S13.1 govern;
this is fixture realization under existing implementing Specs and active plans.
I3-04/I3-05 counter/four-stack necessity and closed ITERATION-001 controls persist.

[Source freeze](source-freeze.json), [source diff](source.diff), [unchanged
43-command plan](planned-commands.json) and [historical evidence hashes](historical-evidence-hashes.json)
record the checkpoint. Read-only comparison verifies 122 source inputs and 128
previous driver inputs (only the authorized fixture differs), 24 unaffected pins,
compiler/macro/core receipt and reused GiftUI artifacts. All 84 historical SO-03
files are pinned without modification. Plan is exactly 42 compiler + 1 existing
execute; same flags/oracles/labels/argv, only fresh output directory substitution
will follow. Maintained formatter and governance (198 nodes/2,019 edges/all existing
task manifests) pass. No compiler, probe or native invocation has run.

Commit the unvalidated source and frozen receipts before exactly one command:

```text
scripts/contracts/run-spec-011.sh --profile macos-dynamic --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014-swift64/af66aaf967e3fe8f-__4p5wu2/macos-dynamic
```

New allowance 0/1 consumed; total fixture corrections 2 (prior 1 plus this authorized
helper correction); automatic follow-up repairs 0. Original and correction-1 native
allowances each remain 1/1 consumed, 0 remaining. First prerequisite/positive failure
or wrong negative cause stops; freeze exact result, no source repair or retry, commit
outcome before separate independent review. Historical helper 2/2, B03 1/1,
GOT/image/backing/phase/IR and SPIKE-075 seven closed experiments stay closed;
no reset or new cumulative 0/2 counter. Independent review owns guard classification.
All nine criteria, HC-RD-003/P08/R07/T8.1, physical fit/58,648-versus-27,648 stack
failure and mandatory I4-07/P09–P12 remain open; SO-04–09 proposed/unapproved.
No full suite, target/image or hardware work. No new deferred item: the helper is
current selected-path work, and existing residuals retain their recorded owners.

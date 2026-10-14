# SO-03 correction-2 native outcome — 2026-10-14

**FAILED at execute; source frozen, no repair or rerun.** Unvalidated helper
source/receipt commit `ef46dd4b` was clean native entry. Exactly one [invocation](attempt-1/invocation.json)
of the command below ran against fresh immutable output
`.build/contracts/spec-011-owned-keys/tmpiggjdqn4/macos-dynamic`:

```text
scripts/contracts/run-spec-011.sh --profile macos-dynamic --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014-swift64/af66aaf967e3fe8f-__4p5wu2/macos-dynamic
```

Driver exit **1**. All **42 compiler cells met their expected oracles**:
**30 successful compilations and 12 expected-negative diagnostic rejections**.
These include both prerequisites, all real operation consumers, OwnedKeyProbe,
all **27 focused positive/negative probes** and link. The existing 14-value layout IR check passed.
All 43 planned commands were attempted once. The existing executable's sole
execution exited **-5 (signal 5)** with **zero-byte stdout/stderr** in [execute.log](attempt-1/execute.log).
No completion/count message was observed. The [driver receipt](attempt-1/result.json)
and [raw invocation output](attempt-1/invocation.log) preserve this exact failure.
No diagnostic location, failing assertion, runtime compatibility/session acceptance
or resource conclusion is established. No compiler, executable, probe, debugger,
source repair or retry followed the stop. Separate independent Strong review owns
cause/contract/guard classification and any concrete next proposal.

The private helper correction compiles in the unchanged matrix. It consumes all
five independent inputs, calls unchanged so03Union, consumes the Optional and reads
its count inside the helper, returning only owned UInt16. Every annotation/twin/
negative cause and the common-session executable family remain unchanged; the
previous initializer lifetime diagnostics are absent. Expected-negative passes
are the driver's exact ownership/lifetime diagnostic oracles, not successful
compilation of rejected code. All runtime assertions remain in source but their
completion is unproved by the stopped execution.

Read-only post-run verification matches **122 source-freeze inputs, 128 driver
inputs, 24 unaffected pins, 130 output artifact hashes/sizes and 84 historical
SO-03 evidence files**. Compiler/macro/core receipt/reused GiftUI identities match.
All 43 actual argv/oracles equal the precompiler plan after only fresh output
substitution; attempted argv equals the complete plan, and Main.swift bytes match.
Source bytes remain frozen at `ef46dd4b`. All 63 text output counterparts were
copied byte-for-byte under attempt-1; binary modules/objects/executable remain in
the immutable local output and match [artifact hashes](attempt-1/artifact-hashes.json).
The earlier source/outcomes/reviews and native attempts remain untouched.

Correction-2 allowance **1/1 consumed, 0 remaining**; fixture corrections **2**
total, automatic follow-up repairs **0**. Original and correction-1 native
allowances each remain **1/1 consumed, 0 remaining**. Historical helper 2/2,
B03 1/1, GOT/image/backing/phase/IR allowances and SPIKE-075 seven closed experiments
remain closed. No counter reset or new cumulative 0/2 budget. New passing compiler
checks are recorded; independent review determines the guard disposition.

Specs 011/013/015 stay implementing, owner plans active. All nine SO criteria,
HC-RD-003/P08/R07/T8.1, physical fit and the **58,648-versus-27,648** stack failure
remain open. Counter/Cycle full-graph and mandatory I4-07 analyzer integration/
owned-return evidence and separate P09/P10–P12/hardware/timing duties persist.
SO-04–09 remain proposed/unapproved. No new deferred item or contract/status/
manifest change; no suite, target/image or hardware work ran.


Outcome documentation checks PASS: governance 198 nodes/2,019 edges/all existing
task manifests; 532 local Markdown file links; exact 63 tracked text outputs/raw
invocation bytes; no source/driver change after native entry. Maintained/document
staged diff checks pass. Standard staged diff reports only preserved raw evidence
whitespace: invocation.log's terminal blank line and six compiler-rendered blank
source lines (`188 | `) in the retained-dispatcher negative log. Complete
`git -c core.whitespace=-blank-at-eof,-blank-at-eol diff --cached --check` passes;
raw logs are not trimmed or normalized. Outcome evidence/navigation is committed
separately from the frozen source before independent review.

## Independent review handoff

Review source `ef46dd4b`, prior review `7531e5c3`, this exact frozen result and
accepted ADR-039/S11.1–4/S13.1. Verify helper-only scope, unchanged annotations,
27 positive/negative labels/causes, complete 43 argv/42 compiler checks, all
identities, and execute -5 with empty output. Classify compiler progress and
runtime stop from read-only evidence without attributing an unobserved location.
Assess guard disposition and smallest concrete handoff; no source edit, compiler,
probe, execution, debug run, repair, target/image or hardware is authorized.
Parent arranges the separate fresh independent Strong review after this outcome
commit. The explicit user allowance includes zero further automatic repairs.

# Historical correction-2 precompiler checkpoint — 2026-10-14

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

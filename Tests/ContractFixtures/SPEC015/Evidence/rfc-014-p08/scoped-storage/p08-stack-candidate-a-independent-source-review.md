# P08 stack candidate A — independent Strong source review

**SOURCE BLOCKED at `3d69aba9`; screen remains 0/1.** Independent Sol 6.1 High
review of the [source freeze](p08-stack-candidate-a-source-freeze.md),
[manifest/diff](stack-candidate-a/manifest.json),
[qualification](p08-stack-candidate-a-applicability.json) and
[activity](p08-stack-candidate-a-activity.md). One introduced mechanical field-
receiver error affects five sites. It is not an architecture or resource-contract
problem. No source correction, compiler or screen was run by this review.

## B01 — blocking: transcript is not CounterControl

CounterScopedStorage.swift:1486–1496 declares P08HostReuseTranscript with a direct
`admission: CounterAdmission?` field and **no runtime member**. The candidate
incorrectly rewrites its four stale admission submissions at **1605, 1608, 1609,
1610** and retained-admission assignment at **1628** as
`transcript.pointee.runtime.admission`. These are invalid members, not equivalent
reads of CounterControl's forwarding getters. The current frozen source is not
ready for compilation; this is source evidence, not an emitted compiler result.

The exact minimal correction is to restore `transcript.pointee.admission` at
those five sites, including the original retained handle assignment and stale
pointer/state/completion submissions. Keep the legitimate Control runtime reads.
Do not add a runtime property, substitute current-host admission, alter producer
identity or drop these controls. The source freeze's 35-substitution claim includes
these five incorrect transcript receivers; **30** substitutions are legitimate
original Control projections. Refreeze exact source/qualification/diff hashes and
obtain focused independent reassessment before the one target screen. This review
does not execute or redefine the parent's correction/authorization disposition.

## Other bounded source findings

No additional blocker is found. CounterControl's admission/context/unavailable
getters simply return their original runtime fields. The other 30 reads preserve
values, short-lived observation and ordering, without a retained inout borrow
across client calls or changed mutation. The ten selected boundaries are exactly
seven CounterHostState methods, cleanup supply/checkJoins and the new comparison
helper. Existing large out-of-line helpers remain unchanged; every existing
lifetime annotation, state case, consuming transition and deferred cleanup stays.

All five full fingerprint comparisons remain after their respective stale client
operation. The helper borrows the original expected owned facts, constructs the
same complete current fingerprint and uses the same synthesized equality, returning
only Bool. Snapshot fields and original reservation lifetime remain intact; no
hash, partial fingerprint, capability escape or callback is added. Normalized
whole-file comparison accounts for every candidate change as the reviewed
attributes, field substitutions or this complete synchronous comparison helper.

Manifest/diff and five baseline/current source hashes, two evidence-glue hashes,
all lifetime lists, driver AST and 384/202 label inventories verify. Independently
checked seven exact original receipt hashes, old metadata hashes and complete
argv-derived input counts/digests, with all five candidate sources excluded and
only CounterScopedStorage present as metadata. Driver changes only path/activity
pins; current-source/receipt/input/artifact/compiler/macro drift guards remain.
No qualification promotes an old compiled counter result. Image/full-coverage
guards, capacities, constraints, corpus/oracle ordering and budgets are unchanged.
Only documentary/hash/source checks were performed here; no test gate, formatter,
compiler, runtime, image, debugger, hardware action or subagent was invoked.

Documentary checks pass: governance (200 nodes / 2,026 edges), 195 local
Markdown links and whitespace.

Candidate **1/1 frozen**, screen **0/1**, historical 2/2 closed. Preserve this
finding and frozen identity; no optimization variant or stack-limit change is
selected. Code-generation effect remains unknown and the 27,648-byte baseline
and P08 fit failure remain. All acceptance/resource/IRQ/Dynamic and later-package
gates retain their recorded open dispositions.

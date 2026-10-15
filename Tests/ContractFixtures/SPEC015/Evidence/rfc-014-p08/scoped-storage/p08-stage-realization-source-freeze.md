# P08 typed-stage initial source freeze

**Source frozen for independent review; no compiler, runtime or fit result.**
Input/design review `d7df2c80`, [design](../../../../../../docs/implementation-designs/spec-015-p08-typed-stage-realization.md)
`8bc9c9a4`; [authorization/bounds](p08-stage-realization-activity.md).
Initial source candidate 1; corrections **0/2**, screens **0**. Historical closed
allowances remain closed; the two-consecutive-unproductive guard remains.

The only Swift edit is `RuntimeDerived/CounterScopedStorage.swift`:

- Replace private `P08BodyStage`/`P08BodyCleanup` take/switch/reinsert with concrete
  Static/Dynamic consuming session, supplied, owner and host phases. Only
  `P08BodyResult { Int, Bool, Bool }` returns. Original model/root lenders and
  activation backing stay in `runP08ScopedBody` across every nested phase call.
- Early 1 resets the session; early 2 retires inert supplied storage then resets;
  early 3 runs the same eight owner hooks **before** joins; early 4 returns from
  the host phase **before** activation. The host defer captures a mutable host
  never subsequently consumed. Every result reaches common original control
  postconditions and one origin retirement after phase cleanup. Reuse's terminal
  teardown plus the host defer retains double-teardown coverage.
- Reuse helpers retain the same original action/admission/revision ordering, one
  complete stale fingerprint/model baseline and all five full comparisons.
  All original assertions, failure guards, frame checks and labels remain; down/up
  positive action cycles, actual sealed mutating dispatch and one effect remain.
- Factor Embedded exchange/surplus, invalid-extent and fault loop bodies into
  concrete case helpers. Original loops, namespaces/issuance order, selected
  slots, prefix bounds and checks remain. Native reservation loops already
  construct owners inside callbacks and are unchanged.

Required CounterHostState, lifetime contracts, five banks/geometry, physical
owners/layout, capacities, workload, allocation strategy, toolchain/flags and
resource ceilings are unchanged. New helper/caller/argument/report/snapshot and
cleanup costs remain chargeable; no move elision, tail call or stack saving is
claimed. Phase syntax/lifetime acceptance and actual aggregate frames remain
unproved until current compiler/artifact evidence.

The [source diff](stage-realization-source/source.diff.xz) pins both Swift and the
driver's two applicability constants, against `d7df2c80beddf1975b0cf74c9fbe8ff8cccb1ea4`.
[Manifest](stage-realization-source/manifest.json) SHA-256
`daf6ca9c9aac34cb295755386f31c361adde8f971a2dd9964493519d6dd035d2`.
Swift SHA-256 `db3b91b9ab935043032ce3d3182dd384fca40b3d18f016d73820e62a24877e95`;
uncompressed diff SHA-256 `bab71bed4dbc33ab932c4d2fdd2163b8d0218831ac618b7db54b250b7129f595`.
The exact diff is stored as xz so ordinary patch context markers are not mistaken
for source trailing whitespace by the outer commit check.

[New exact qualification](p08-stage-realization-applicability.json) SHA-256
`3274499cf3d610307900b7e682c5ebc2e0ed3acaee4f71a29af96d48e9d8cf9f`
repins the seven component receipts only. Fresh compiler-free verification checks
their argv exclusion/current Swift metadata hash, 11 dependency receipt identities,
891 artifact hashes, 895 recorded Swift argv inputs, core Swift manifests,
compiler/macro/SwiftSyntax identities. The existing Package.swift metadata drift
in core receipts is explicitly recorded; actual Swift compilation inputs and
artifacts match. No old manifest/qualification/result is changed, and no compiled
counter input/result can reuse this exception. Driver guards and registrations
are unchanged apart from the new path/activity pin.

[Static coverage observations](stage-realization-source/static-coverage.json)
record exact reuse statement multisets, five comparisons/one baseline, equal root
issuance sites and the shared fault body's original assertions. Physical/fingerprint,
outer/supplied, actual host routes and session-only/exclusivity regions are byte
identical. The manifest pins the complete historical label inventory by hash:
384/202 compiler labels, five controls per native route, 26 runtime reuse labels;
all **current execution coverage is not run**. These are source checks, not proofs
of compiler acceptance or operational behavior.

Compiler-free checks: exact driver qualifier function accepts all seven receipts,
rejects current-source and predecessor-metadata drift; Python AST parsing, local
links, governance and whitespace checks pass. Pinned
`env PATH="/Users/eugene/work/GiftUI/.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin:$PATH" scripts/format-swift.sh`
exits 0, with its existing fixture exclusion and no unrelated edits. No suite,
compiler, runtime, build or image invocation was executed.

After independent source review, run the registered early rejection screen:

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter \
  --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded \
  --host-build .build/contracts/p08-scoped-host-hzs5q7za \
  --fresh-focused --select-family so07-layout-facts
```

Immediately inspect actual entry/phase/case/reuse/cleanup frames and live caller
paths. An oversized reachable lower bound rejects fit before expensive followup.
Even a passing module/layout screen omits 202 controls, has incomplete aggregate
coverage and cannot qualify for the image handoff. The design specifies affected
native runtime/exclusivity/complete matcher families, ARMv6/Embedded compilation,
full current image prerequisite and linked resource/ABI/IRQ/allocator evidence.
P08/R07/T8.1/HC-RD-003 and all prior residuals remain open.

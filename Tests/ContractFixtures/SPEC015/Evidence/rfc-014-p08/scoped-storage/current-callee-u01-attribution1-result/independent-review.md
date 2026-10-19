# Independent Strong review — P08 U01 attribution 1

Reviewed 2026-10-19 at **`008ffe6b7d5b1d193c95136181034ffcba88e23e`**.
Verdict: **PASS for bounded U01 callback/local-helper attribution and its STOP
disposition.** No blocking factual, contract or scope finding was identified.
U01 remains open; complete callee/safety PASS is unestablished and
`strict_cold_eligible` remains false. This is not P08 acceptance.

## Independent evidence checks

Read the [packet](README.md), its extractor and complete retained bodies,
the prior independent interpretation, source joins, accepted ADR-039/040,
implementing SPEC-015 S15.1/S15.2 and iteration/plan navigation. Independent
standard-library SHA-256/JSON/text inspection and read-only Git comparisons
produced the [inspection record](independent-review-inspection.json). The
author's extractor was read, not executed or imported.

All **67 frozen inputs** equal their exact baseline blobs; all **four packet
files** equal the reviewed commit. All **42 source hashes**, **five preexisting
dirty-file hashes** and the preexisting Python cache hash match. Every numbered
line in all **13 excerpt spans** equals the raw capture. The SIL hash remains
`6cc9e7b6cecbeb46dd71b2ac8b6e023182354e7fcc08c814374b9c23303c71ed`.
Exact target headers/symbol inventories across **25 objects** and both zero-block
ordinary ABI index entries agree with the packet. The extractor reads frozen
bytes, inventories exact symbols within their modules, and writes only its two
derived outputs; it does not select linked winners or obtain populated metadata.
Its hard-coded spans are valid for the verified frozen inputs.

No compiler, build, test, controller, decoder, demangler, qualifier, fixture or
application runtime, strict-cold route, image, connected operation or source
repair ran. Source, raw evidence, marker and cache were preserved.

## Technical verdict

- **Both actual callback chains agree.** SIL 598697–598701 and 600947–600951
  capture scalar scratch/count in on-stack closures and call ordinary
  `BoundedText.withUTF8<()>` with `[nothrow]`. P08 0xa2adc passes local
  0xb6928 (`.TA.65`) through 0xb3700 (`.TA`); P08 0xa3e6c passes 0xb3700
  directly. The captures at context +0x10/+0x18 agree with `.TA`'s
  `ldp x2,x3,[x20,#0x10]`. GiftUI 0x77c stores callback/context at
  sp+0x88/+0x90; its context sp+0x70 makes thunk 0x838's +0x18/+0x20 loads
  exact. Generic 0x8c4 therefore calls 0x838, whose 0x858 calls the selected
  P08 callback with copied bytes and original bounded count.
- **Selected normal returns exclude the conditional error transfer.** The
  complete SIL 601530–601687 has 20 blocks, six `cond_fail` sites and no
  apply-family, throw or allocation instruction. Both complete object decoder
  bodies have 48 instructions, no call, no stack reference and no x21/w21
  reference; normal `ret` and terminating `brk` are distinct outcomes. The
  local P08 thunks preserve x21, and the actual callers initialize it to zero.
  GiftUI restores that state before dispatch. Thus 0x85c and 0x8c8 skip the
  error stores and the 0x8dc transfer on these selected normal returns.
  Trap infeasibility and complete memory safety are not established here.
- **Metadata and dynamic stack remain unconditional setup.** GiftUI 0x7cc
  obtains Error metadata before generic dispatch. Helper 0x8fc has a real
  cold branch through external `swift_getTypeByMangledNameInContext2` at
  0x930; no retained cache-state proof excludes it. Generic 0x894/0x898 loads
  `S = *(*(M-8)+0x40)` and 0x8a0–0x8ac reserves `(S+15)&~15` bytes before
  calling the callback. Neither the no-throw result nor `()` supplies numeric
  S. The separate private-storage size load at 0x8b0/0x8b4 does not supply it.
  Fixed frames cannot establish a complete nested bound without that value,
  callers and external costs.
- **ErrorWS and local outlined helpers are correctly distinguished.** ErrorWS
  is loaded into x6; the retained generic never uses x6. Its inactive transfer
  target is instead `*(*(M-8)+0x20)`, with no populated target in this packet.
  GiftUI's own helper 72 at 0xc904 stores the stack guard; its own helper 40
  at 0xc67c compares it. Neither allocates or calls indirectly. The 0x834
  stack-canary failure target remains external. Other modules' numbered
  helpers are not substituted.
- **No linked/heap/stack overclaim follows.** Both retained generic definitions
  and both decoder definitions support the local observations. Duplicate
  object definitions do not establish the linked provider. No feasible heap
  event, cold zero-heap PASS, numeric temporary bound, complete stack PASS,
  runtime qualification or contract impossibility is proved.

## Exact next dependency and allowance classification

Prepare **one separate U01 R01–R04 evidence request**, beginning with read-only
inventory of already frozen exact linked artifacts and matching runtime/library
bytes. R01 needs selected cold metadata implementation/transitive costs; R02
needs applicable populated metadata or exact version-matched ABI evidence for
the size/reservation bound; R03 needs actual linked binding/provider identity;
R04 needs selected memcpy costs and stack-guard/failure disposition under the
safety proof. Record missing inputs, applicability/hashes, proposed commands,
budgets, independent review and stop conditions before any acquisition or new
execution. This is **preparation only**, not an acquisition, decoder, runtime,
compiler, collection, repair, retry or strict-cold allowance. U02–U05 retain
their prior open dispositions and need separately bounded work.

No actual contract/scope choice arose. A proposed warm-up exception or
heap/ownership/privacy/bound/scope relaxation must go upstream for the
maintainer-requested Astra Medium decision before reliance. No ADR/Spec change
or optional deferred capture is needed for this evidence-only review: R01–R04
are current proof dependencies. ADR-040's finite-counter exception remains in
force; no historical counter ceiling is reinstated. This is active
ITERATION-003's necessary finite-counter dependency for analyzer/constrained
stack validation; closed ITERATION-001 gains no work. Full RFC-015 delivery
remains ITERATION-004 I4-07.

Collection **1/1 consumed**, source/tooling repairs **0**, retries **0**, and
marker **[16777234, 29640436]** remain unchanged. Complete callee **and** safety
PASS must precede preparation of a new current strict-cold manifest for the
existing prepared route; host-first baseline, silent/observed/ordinary windows,
workload/baseline counts and zero-heap enforcement remain binding.
**P08/R07/T8.1, remaining SO criteria, strict-cold/zero-heap, four-profile,
ABI/resources, independent exit and later conformance gates stay open.**

---
id: SPIKE-069
feature: external-application-integration
title: Scoped Model Access and Escape Enforcement
status: completed
authors:
  - codex
created: 2026-10-09
updated: 2026-10-09
source:
  - RFC-014
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: ITERATION-003
---

# SPIKE-069: Scoped Model Access and Escape Enforcement

Evidence for RFC-014 B1 and the ownership part of B2. This is disposable
compiler/lifetime work, not approved architecture or production migration.
The blockers remain in RFC-014; this record does not defer them.

## Authorization and Baseline

On 2026-10-09 Eugene answered the proposed bounded B1 proof package and
model-ownership contract: “Please proceed then. And commit each step”. This
authorizes this bounded continuation, with executor-selected limits below.
It does not approve RFC-014, a fourth capture buffer, changed public APIs,
production implementation, or connected hardware. SPIKE-067/068 remain stopped.

Baseline: `ae5c5ecc`, clean working tree. Inspect actual State, Static binding,
View and Canvas declarations. Record candidate sources and transformations
before their first compiler trial.

## Target Questions

1. Does a copyable bound wrapper plus a scoped callback enforce non-escape
   through return values, outer storage and delayed closures?
2. Can a lifetime-dependent borrowed model/capture view on pinned Swift 6.3.2
   reject those escapes and overlapping owner mutation while permitting reads?
3. Can delayed Canvas use an owned snapshot key and receive a fresh borrow at
   invocation, preserving declaration-time snapshot selection?
4. What source/lowering changes and unproved ownership mechanisms remain?

## Bounds / Stop Conditions

- One **90-active-minute** ceiling starting **20:05 UTC**, conservatively
  including orientation; deadline **21:35 UTC**, initially no excluded waiting.
  Include authoring, builds, analysis, repairs, validation and commits.
- At most **48 experimental compiler/link/executable invocations**, counting
  each underlying call inside wrappers; at most **three repair rounds** after
  failed trials. Read-only inventory, doctors, symbol inspection and
  documentation validation are not compiler/run trials. No per-step reset.
- Two candidates only, A and B below. No general generator, owner rewrite,
  archived aggregate candidate, transfer study or automatic successor.
- Preserve commands, input/compiler hashes, flags, exit codes and raw logs.
  The first exhausted ceiling ends this package with a terminal disposition.
- A decisive escape rejects that exact enforcement mechanism, not every typed
  handle or possible source-compatible lowering. Stop extending it; only the
  already-declared B alternative remains available.
- Unexpected compiler failure is inconclusive, not a safety pass. Positive
  controls must compile before interpreting negative diagnostics.
- No connected operation, SDK install, production source edit or accepted
  ADR/implemented Spec change. Target outputs remain under
  `.build/nrf52840/` and `.build/raspberry-pi/` respectively.

## Candidate Ownership Contract (Proposed)

This is a review candidate; ADR-024/025/026/034 remain authoritative.

| Object | Ownership / lifetime obligation |
| --- | --- |
| Model backing | Host-provided stable typed pool; release only after quiescence and both framework and application ownership end |
| Model identity | Owner context + slot + allocation generation; distinct from registration generation; refuse exhausted generation reuse |
| Registration | Detachment retires observation, not application ownership of the model |
| Replacement | Reserve model, snapshot and registration before attach; failed attach preserves former association; committed replacement survives later derivation failure |
| Frozen capture | Immutable snapshot selected at declaration; pin through every Canvas invocation/discard; no pointer in published semantics or interaction |
| Canvas payload | Owned scalars and typed snapshot key; key cannot read storage by itself; resolve only inside a live owner/freeze scope |
| Retired model | Still consumes model/snapshot capacity while application-owned; never recycle merely because observation detached |
| Admission | Separate bounded writable region; may accept facts during freeze, but callbacks cannot resolve/read/mutate frozen models |
| Report/result | Separate dirty/registration and mutation-result regions; no mutable aggregate-owner borrow across a callback writing either region |

Let **R** bound distinct detached model snapshots still application-owned,
in addition to one installed model and one staged replacement. A conservative
non-sharing analyzer reservation is **4 + R** capture slots: source-live,
admitted, installed, staged, and R retired snapshots. Transition backing alone
costs **(4 + R) × 6,464 bytes**; metadata, leases and alignment are additional.
Sharing can reduce the count only with a proved immutable ownership mechanism.

Four slots therefore require demonstrated **R = 0** for the selected host's
replacement lifecycle, not a framework-wide prohibition of application owners.
If R is positive, declare and charge it. An unbounded R leaves B2 open. Pool
exhaustion must fail before replacement commits and preserve the old association;
this experiment does not choose the production error declaration or application R.

Handle copies must not create untracked owners. A production proposal needs
enforceable application retain/release or borrowing rules; a prototype refcount
does not prove arbitrary copies are tracked. Generation validation must never
dereference released owner backing.

## Method

### A — Copyable facade with callback restriction only

Use actual production State and `StaticObservableModelStorage.withBoundState`
as the control. Test returning the bound wrapper, storing it in outer storage
from a Void callback, and delayed closure capture. Never dereference escaped
production pointers. This tests API enforcement, not observed production misuse.

The source-compatible candidate keeps the same copyable wrapper/typed-handle
shape, specializes routes, and restricts callback results to scalars/status.
If outer-storage or delayed-closure escape still compiles, specialization alone
is insufficient. It needs a checked lowering rule or changed API before
integration. Do not claim this refutes every source-compatible implementation.

### B — Explicit phase borrow and delayed snapshot-key resolution

Use a nonescapable, lifetime-dependent view over bounded typed transitions.
Candidate syntax uses the pinned compiler's `~Escapable` and
`@lifetime(borrow ...)` support; preserve exact checked declarations in the
fixture. An annotation without negative compiler controls is not evidence.

```text
withFrozenModel(key, body: (borrowing FrozenModelView) -> Status) -> Status
emitCanvas(snapshotKey, ownedScalarParameters)
invokeCanvas(key, body: (borrowing FrozenCaptureView) -> Status) -> Status
```

Views expose scalar/indexed value reads, no unsafe pointer or unrestricted
generic result. Declaration emits owned values and a key. Post-layout invocation
resolves that pinned key under the live owner and supplies a fresh read borrow;
resolving the current capture instead would violate declaration-time selection.

This can require portable State/body/Canvas contract changes. Test direct use
of the borrowed view in today's declaration/escaping-Canvas shape, recording
rejections as compatibility evidence. Hand-written fixture adaptation is not
an implemented generator or complete actual traversal.

### Ordered gates

1. **Compiler:** A counterexamples; B positive read and negative return, outer
   storage, escaping closure and overlapping mutation controls. Reject only on
   intended diagnostics after positive compilation.
2. **Lifetime driver for a surviving mechanism:** scalar counter and full
   404 × 16-byte capture; snapshot revision pinning; attach failure; replacement
   then derivation failure; retained old model; pool exhaustion; admission during
   freeze; zero/multiple Canvas uses; discard/teardown. Identify modeled behavior
   versus actual GiftUI owner/traversal execution. Model-only success cannot
   close B1. Stop at an unavailable required mechanism rather than substituting
   a different design or weakening the cases.
3. **Composition boundary:** inventory View/State/Canvas changes and remaining
   generated routes. Expose any new API decision and stop before implementing
   it or a full migration. Full analyzer stack and four-profile application
   parity remain adoption gates even if the small driver succeeds.

## Reproduction

Disposable code/raw evidence: `experiments/spike-069-scoped-model-access/`.
Use project-local Swift 6.3.2 throughout, recording compiler and SDK identities.

- macOS Dynamic/Static: distinct profile definitions and native driver execution
  where the compiler gate permits it.
- Pi 1: cross-compile `armv6-unknown-linux-gnueabihf` with the paired Dynamic
  SDK; no remote execution.
- nRF52840: `armv7em-none-none-eabi`, Embedded Swift, `-wmo`, `-Osize`, and the
  maintained Cortex-M4F hard-float flags. Inspect object/ELF ABI and symbols.
  Object evidence is not a linked-image heap, RAM/flash, stack or execution proof.

Toolchain doctors passed on 2026-10-09. Missing target language/toolchain support
is inconclusive for that configuration, never inferred from native success.

## Results

Completed with [raw evidence and analysis](../../experiments/spike-069-scoped-model-access/evidence/result.md).
Step 1: `e22bed02` committed the recipe/ownership contract before compilation.
Step 2 records code/evidence; step 3 integrates the RFC recommendation. The
ledger preserves all 45 invocations, including failed trial 05 and its one
repair; 24 negative checks were compiler rejections for their intended reason.

A's callback-only enforcement is refuted on all four configurations. B's
positive borrow compiles on all four with experimental LifetimeDependence;
the compiler also warns about the selected `@lifetime` spelling. Sixteen
modeled lifetime cases pass in each native profile; Pi/nRF objects compile.
An owned body built with actual GiftUI sources compiles, but directly capturing
the nonescapable view in actual Canvas is rejected on all four configurations.
A delayed owned-key fixture preserves declaration-time snapshot selection.

The nRF section-GC fixture has no retained allocator relocation, with hard-float
ABI evidence; unreferenced allocator symbols remain in the relocatable symbol
table. No complete firmware, stack or whole-application zero-heap claim follows.

## Limitations

- This is the B1 entry experiment, not complete feasibility or conformance.
- Non-escape does not prove pool ownership, transaction/IRQ correctness,
  generated code or every callback. Unsafe internal construction needs audit.
- No fourth-slot adoption, R selection, exact codec, whole-image stack, Dynamic
  peak-memory or physical performance conclusion is authorized.

## Disposition

Completed, partial support with an exposed API/lowering decision. Recommend
scoped reads and delayed owned keys as an internal candidate, not an approved
portable contract. Actual checked lowering or revised declarations, compiler
support policy, backing/application ownership and complete route coverage remain
B1 obligations. B0 and B2–B4 remain open. The separate R=1 model illustrates
five slots; it does not select application R or amend ADR-034.

Compiler work is terminal at **45/48 invocations and 1/3 repair rounds**.
Remaining work in this allowance is only evidence review, RFC integration and
commits. Neither completion nor unused allowance authorizes another experiment.

## References

- [RFC-014](../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md)
- [I3-T02 review](../iterations/iteration-003-review/i3-t02-design-review.md)
- [Current plan](../iterations/iteration-003-review/memory-efficiency-plan.md)
- [ADR-024](../adrs/adr-024-structurally-owned-observable-reference-state.md)
- [ADR-026](../adrs/adr-026-profile-equivalent-bounded-observable-state.md)
- [ADR-034](../adrs/adr-034-five-second-transition-capture.md)

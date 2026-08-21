---
id: SPIKE-003
feature: observable-reference-state
title: Portable Observable Reference State Feasibility
status: completed
authors:
  - Yauheni Lychkouski
created: 2026-08-21
updated: 2026-08-21
source:
  - RFC-008
related_future_work:
  - FW-019
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPIKE-003: Portable Observable Reference State Feasibility

> This Spike produces feasibility evidence for RFC-008. Its declarations,
> generated code, storage layout, field widths, and prototype code are
> disposable and do not establish production architecture or authorize
> implementation.

## Parent Gate

RFC-008 cannot advance to approval until one representative observable model
and `@State` declaration compile for both ordinary and supported Embedded
Swift builds, preserve the proposed reference-state semantics through dynamic
and bounded static fixtures, and report enough resource evidence to rule out
an implicit heap or unavailable runtime dependency.

The Spike feeds evidence only to RFC-008. It does not decide the public API,
approve a generated representation, set production capacities, or authorize
migration of the current state implementation.

## Target Questions

1. Can one source-level `@State` declaration preserve one identity-bearing
   observable model across dynamic and static runtime fixtures without
   profile-specific portable Presentation code?
2. Can the supported Embedded Swift target realize that model as an actual
   Swift reference instance, a generated address-stable typed handle, or
   another bounded representation without a general heap?
3. What minimum portable instrumentation can report semantically visible model
   mutations: generated setters, explicit model-owned signaling, a supported
   compiler hook, or a bounded combination?
4. Can one runtime registration attach, coalesce changes, detach on published
   removal, and reject a stale report after slot reuse without closures,
   reflection, `Any`, task-local binding, or an unbounded observer list?
5. Do the candidate dynamic and static realizations agree on preservation,
   replacement, removal, failed derivation, serialized mutation, duplicate
   ownership, and deterministic exhaustion?
6. What linked RAM, flash, stack, per-location storage, and bounded operation
   costs does each viable static candidate introduce over a comparable
   non-observable state baseline?

## Bounds / Stop Conditions

- Limit the prototype to one root, one observable presentation model, one
  owning state location, one borrowed descendant read, and a fixed branch used
  to exercise removal and reinsertion.
- Give the representative model only the fields needed to demonstrate an
  integer-like control value, a bounded capture-like value, and a derived
  read. Do not reproduce the complete Signal Analyzer domain.
- Compare at most three representation/instrumentation candidates selected in
  the experiment README before implementation begins.
- Use host semantic fixtures plus compile/link evidence for
  `nrf52840dk/nrf52840`; do not flash or operate connected hardware.
- Keep disposable code under
  `experiments/spike-003-portable-observable-reference-state-feasibility/`.
- Stop when one candidate satisfies every semantic and zero-heap check with
  reproducible resource evidence, or when all selected candidates fail a
  named compiler, runtime, semantic, or resource requirement.
- Stop and report an inconclusive result if the pinned toolchain cannot
  produce comparable baseline and candidate images; do not change the global
  Swift toolchain or install an SDK outside repository-managed paths.

## Method

### 1. Candidate declarations

Define one portable fixture view whose source shape is equivalent across
profiles:

```text
@State one observable model
    -> read model-derived text/control facts
    -> mutate through one identified action
    -> apply one admitted external fact
```

Each candidate must preserve the same model identity while transient fixture
views are recreated. If a candidate uses generated source or a macro, preserve
the expansion and identify every runtime dependency it introduces.

Candidate mechanisms may include:

- a directly retained reference instance with a bounded intrusive registrar;
- a generated address-stable model store with a typed reference-semantic
  handle; or
- explicit model-owned mutation signaling over a generated location.

Do not include property-read dependency graphs, public bindings, arbitrary
observer collections, Apple Observation, or unrelated UI features.

### 2. Shared semantic fixture driver

Run the same behavioral cases against the dynamic and static candidate:

1. materialize the state location and record model identity;
2. recreate the transient root repeatedly and verify identity preservation;
3. perform several model writes in one admitted mutation phase and verify one
   dirty state and one complete reevaluation;
4. apply one external fact through a bounded admission-shaped fixture rather
   than direct mutation;
5. replace the model through an admitted state assignment and verify detach /
   attach ordering;
6. remove the branch, publish, send a stale report, and verify no invalidation;
7. reuse the slot for a fresh model and verify the stale report cannot alias
   it;
8. fail derivation before publication and verify the previously published
   live set remains authoritative and state is rederived without replay;
9. attach the same model to two owning locations and verify deterministic
   duplicate ownership failure; and
10. exhaust state-location and registration capacity independently.

The driver must record stable fixture IDs, expected and actual outcomes,
model-identity observations, dirty transitions, reevaluation count, and
registration generation or equivalent stale-report evidence.

### 3. Embedded compile and link fixtures

Provide comparable baseline and candidate Embedded Swift modules using the
repository's supported compiler, SDK, Zephyr board configuration, CPU/ABI
flags, optimization, and runtime support.

The baseline must contain the same call-shaped model reads, mutations, and
render-independent control flow without the candidate observation machinery.
The candidate must exercise initialization, attach, several coalesced change
reports, replacement or detach, and a stale-report rejection in code visible
to the linker.

Generated firmware and deployable artifacts remain under
`.build/nrf52840/`. The experiment may keep stable reports or temporary host
fixtures under its own directory or `/tmp`.

### 4. Required checks and measurements

For each viable candidate and its baseline, report:

- ordinary Swift and Embedded Swift compilation result;
- source-level differences, if any, in the portable fixture;
- linked RAM and flash totals and candidate-minus-baseline deltas;
- model storage, state-location, registration, dirty/live bits, generated
  descriptors, and stale-report protection separately where symbols permit;
- worst-case stack by reproducible compiler report, high-water fixture, or
  conservative complete call-graph analysis;
- fixed operation counts for materialization, attach, one mutation report,
  coalescing 20 reports, replacement, detach, and stale-report rejection;
- allocator configuration and unresolved/linked symbol inspection proving no
  general heap requirement;
- absence of reflection, `Any` storage, task-local binding, Apple Observation,
  Objective-C runtime, exceptions, `Task`, and thread primitives from the
  embedded dependency closure; and
- shared semantic fixture results for every required positive and negative
  case.

If stack instrumentation or tracing changes the linked image, report resource
and instrumented variants separately rather than subtracting unlike images.

## Reproduction

The experiment must provide one repository-root entry point, preferably:

```text
experiments/spike-003-portable-observable-reference-state-feasibility/run.sh
```

It must:

1. print the pinned compiler, SDK, board, CPU/ABI, optimization, and source
   revision inputs;
2. run the shared dynamic/static host semantic fixtures;
3. build comparable Embedded Swift baseline and candidate modules/images;
4. inspect allocator and forbidden runtime dependencies;
5. collect size, symbol, stack, and bounded operation evidence; and
6. emit one stable summary table per candidate plus a pass, fail, or
   inconclusive result for every target question.

The command must not download a global toolchain, install under `/opt`, change
Xcode/global Swift selection, flash a board, or infer connected-hardware
evidence.

## Results

The experiment completed on the pinned Swift 6.3.2 / Zephyr 4.3.0 toolchain
for `nrf52840dk/nrf52840`. The complete reproducible evidence is under
[`experiments/spike-003-portable-observable-reference-state-feasibility/`](../../experiments/spike-003-portable-observable-reference-state-feasibility/).
No board was flashed or operated.

### Candidate outcomes

| Candidate                                              | Ordinary Swift                                | Embedded compile/link                                                  | Zero-heap result                                                                                              | Semantic result                                                                                |
| ------------------------------------------------------ | --------------------------------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Direct Swift class with explicit signaling             | Passed through the dynamic-class host fixture | Passed                                                                 | Failed: an escaping class retained `swift_allocObject -> posix_memalign`; the zero-heap shim returns `ENOMEM` | Host semantics passed, but a preserved Embedded instance cannot materialize without allocation |
| Generated typed handle with explicit generated setters | Passed                                        | Passed with the same `@State var model: ObservableModel` fixture shape | Passed: both configured heaps are zero and no allocator entry point remains linked                            | Dynamic-class and static-handle profiles produced equivalent results for every shared case     |

A non-escaping Swift class was stack-promoted and linked without an allocator,
but it cannot outlive transient fixture reconstruction and therefore is not a
valid state-preservation mechanism.

### Semantic evidence

The shared host driver passed preservation, 20-report coalescing, admitted
external mutation, replacement, published removal, stale report rejection
after removal and slot reuse, failed derivation without replay, duplicate
ownership, state-location exhaustion, and registration exhaustion for both
profiles. The normalized results are in
[`semantic-results.tsv`](../../experiments/spike-003-portable-observable-reference-state-feasibility/evidence/semantic-results.tsv).

The generated candidate recorded one materialization, two attaches (initial
and replacement), 20 model reports coalesced to one initial dirty transition,
one replacement, two detaches, and two stale-report rejections across the
full fixture. The three additional report calls exercise the old token, fresh
replacement token, and detached replacement token. See
[`operation-counts.tsv`](../../experiments/spike-003-portable-observable-reference-state-feasibility/evidence/operation-counts.tsv).

### Embedded resource evidence

| Metric | Baseline | Generated handle | Delta |
| --- | ---: | ---: | ---: |
| Linked RAM bytes (ELF LOAD) | 8,060 | 8,060 | 0 |
| Linked flash bytes (ELF LOAD files) | 26,232 | 26,680 | +448 |
| `bss` bytes | 1,049 | 1,087 | +38 |
| Model storage | 24 | 32 | +8 |
| Of which generated owner-token storage | 0 | 8 | +8 |
| State location | 0 | 4 | +4 |
| Registration | 0 | 8 | +8 |
| Generation / stale protection | 0 | 2 | +2 |
| Spike-only instrumentation counters | 0 | 16 | +16 |
| Generated descriptors | 0 | 0 | 0 |
| Conservative complete fixture stack | 56 | 88 | +32 |

The unchanged LOAD-segment RAM total reflects linker alignment; the symbol-
and section-level storage increase is the 38-byte `bss` delta. The two model
records contain 24 bytes of baseline application/identity fields plus eight
bytes of generated owner tokens. Dirty and live bits are packed into the
four-byte state-location record. The 88-byte stack
bound is a conservative complete call-graph result from linked disassembly,
not a hardware high-water measurement.

The generated image has `CONFIG_HEAP_MEM_POOL_SIZE=0` and
`CONFIG_COMMON_LIBC_MALLOC_ARENA_SIZE=0`, retains no allocator entry point,
and introduces no linked reflection, `Any` storage, task-local binding, Apple
Observation, Objective-C, exception, `Task`, or thread-primitive dependency
over the baseline. The final ELF reports ARMv7E-M and VFP register arguments.

### Target-question disposition

1. **Pass:** one portable `@State` source shape preserved identity in shared
   dynamic/static fixtures and compiled for Embedded Swift.
2. **Pass for a generated handle; fail for an escaping Swift class:** the
   address-stable typed handle provides bounded reference semantics without a
   general heap.
3. **Pass for explicit generated setters:** they provide sufficient
   synchronous model-owned signaling. Compiler hooks and macros were not
   needed to reach the stop condition and were not evaluated.
4. **Pass:** one bounded registration attached, coalesced, detached, and
   rejected stale generations without closures or an observer list.
5. **Pass:** shared fixtures agreed on every required positive and negative
   semantic case.
6. **Pass for feasibility evidence:** incremental storage, flash, stack, and
   bounded path counts are reported above. Production capacity and assembled
   Signal Analyzer budgets remain Specification work.

## Limitations

- Compile/link and host fixtures do not prove connected nRF52840 execution,
  interrupt safety, real stack high-water, or full Signal Analyzer cadence.
- The representative model does not establish final application storage
  bounds or production API ergonomics.
- A successful generated candidate demonstrates feasibility, not that its
  generated declarations, field layout, or tooling are maintainable contracts.
- Resource deltas from the fixture may not scale linearly to the complete
  Signal Analyzer; downstream Specifications must budget the assembled stack.
- The pinned compiler can emit `R_ARM_GOT_PREL` relocations for repeated
  imported C accessor calls that GNU BFD rejects without a useful diagnostic.
  Keeping the generated model boundary in non-inlined typed functions avoided
  that relocation while leaving portable Presentation source unchanged. This
  is a toolchain constraint, not evidence for a production annotation choice.
- Host execution proves the generated candidate logic and shared semantics;
  the Embedded images were compiled and linked but not executed on hardware.

## Disposition

Completed. The evidence established that a generated typed handle with
explicit generated model-owned setters is a feasible representation and
instrumentation family under the pinned Embedded Swift configuration.
RFC-008 has since approved the bounded typed representation family and
synchronous model-owned signaling boundary, now extracted into proposed
ADR-025 and ADR-026. The Spike still does not approve its disposable
declarations, generation layout, or production capacities.

If complete-root reevaluation proves infeasible while observation storage is
otherwise viable, record the measurements against FW-019's revisit trigger;
do not add property-level tracking to the Spike or RFC silently.

## References

- [RFC-008: Observable Reference State Architecture](../rfcs/rfc-008-observable-reference-state-architecture.md)
- [PROPOSAL-005: Observable Reference State](../proposals/proposal-005-observable-reference-state.md)
- [ADR-006: Shared Semantics Across Runtime Profiles](../adrs/adr-006-shared-semantics-runtime-profiles.md)
- [ADR-011: Serialized Run Cycle and Semantic Publication](../adrs/adr-011-serialized-run-cycle-and-publication.md)
- [ADR-025: Coarse Model-Owned Observable Invalidation](../adrs/adr-025-coarse-model-owned-observable-invalidation.md)
- [ADR-026: Profile-Equivalent Bounded Observable State Realization](../adrs/adr-026-profile-equivalent-bounded-observable-state.md)
- [GiftUI Embedded Layer Inventory](../GiftUI_Embedded_Layer_Inventory.md)
- [nRF52840 Toolchain Skill](../../skills/giftui-nrf-toolchain/SKILL.md)

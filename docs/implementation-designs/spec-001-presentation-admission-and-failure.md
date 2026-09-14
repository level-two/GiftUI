---
spec: SPEC-001
feature: signal-analyzer
title: Implementation Design — Presentation Admission and Failure
status: current
authors:
  - codex
created: 2026-09-13
updated: 2026-09-13
implementation_plan: ../implementation-plans/spec-001-implementation-plan.md
related_future_work: []
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# Implementation Design — Presentation Admission and Failure

> This note explains one replaceable internal realization of an approved
> contract. It is non-authoritative and cannot introduce architecture or amend
> the governing Specification.

## Purpose and Boundary

This note explains how the target-composed Signal Analyzer admission owner can
assign one sequence across three physically independent fact stores, seal and
apply accepted facts once in that order, reserve failure capacity, and keep
repository callbacks outside observable mutation. It also identifies where
mandatory failure effects and residual policy enter after admission rejects.

The note does not change fact cases, capacities, producer bounds, failure
meaning, application-executor ownership, GiftUI mutation ownership, runtime
phases, profile storage limits, or host lifecycle. It does not move the queue
into portable Presentation or let the generic Execution owner interpret
analyzer facts.

## Governing Contract

The realization follows SPEC-001's `Presentation`, `Observable state and
admission configuration`, `Serialized delivery`, and `Error Handling`
sections; acceptance criteria SA-AC-029 through SA-AC-031 and SA-AC-035 through
SA-AC-040; and implementation-plan tasks T5.1, T5.3, and T5.5. ADR-011 owns the
serialized cycle, ADR-015 owns mandatory-effect-before-policy ordering,
ADR-016 keeps diagnostics non-authoritative, ADR-027 owns bounded fact
admission, and SPEC-009/010 retain execution and observable-state mechanisms.

## Current-Code Context

`SignalAnalyzerPresentationAdmissionAdapter` already converts repository
callbacks into one `SignalAnalyzerPresentationFact` and never retains or
mutates a model. `SignalAnalyzerViewModel.apply(_:)` is already package-scoped
to the mutation join. `GiftUIExecution` supplies the admission outcomes, wake
accumulation, sealing vocabulary, and serialized production pipeline.
SPEC-013 supplies bounded dynamic and static storage lifetimes and audits.

`HostSequencedFactAdmission` supplies the analyzer-agnostic fixed-storage
kernel: one common sequence, three physical stores, producer counters, sealing,
ordered removal, quiescence, and discard.
`DynamicSignalAnalyzerHostFactAdmission` in the application-specific
`SignalAnalyzerHost` target now owns the first concrete endpoint's exhaustive
four-case classification and exact rejection mapping behind
`SignalAnalyzerFactAdmission`. The composition fixture also drives sealed facts through
`RuntimeCompletePipeline.applyAdmittedWork()`, applies them to the real
`SignalAnalyzerViewModel` exactly once, and proves post-seal deferral. The
matching Static endpoint is a copyable direct-dispatch handle over caller-owned
fixed storage; both endpoints delegate to the same application-specific
classifier and sequencer core and produce equal normalized cross-store
transcripts. The integrated-cycle fixture wires both endpoints to the exact
host pacing owner and production pipeline and compares their accepted and
retryable-refusal outcomes.

## Proposed Internal Organization

`GiftUIHostConfiguration` owns a package-scoped, payload-generic sequencing
kernel because SPEC-015 assigns the callback/admission cross-owner join to the
host. It does not import or switch over analyzer facts. Each concrete
executable root owns one non-portable admission endpoint that classifies facts
and supplies them to the kernel. Together they contain:

- one sequence cursor whose next accepted value begins at one;
- one optional snapshot entry;
- one 32-entry ordered compact-fact ring;
- one optional reserved operational-failure entry;
- producer-category counters for transition, bootstrap, and action-induced
  facts in the current half-open service window; and
- one wake accumulator supplied by the host.

Every stored entry pairs the fact with its assigned sequence. The endpoint is
the only analyzer-aware layer: it maps `captureSnapshot` to the snapshot slot,
`operationalFailure` to the reserved slot, and capture mutations plus
acquisition-state values to the compact ring. Reusable Execution and profile
owners see only their existing admission, lifecycle, reservation, and
opportunity contracts.

The common kernel uses inline tuple storage for all 32 compact entries and no
dynamic collection. Dynamic and static roots therefore share the ordering
algorithm; final profile artifacts still verify their independently audited
storage and allocation behavior.

## Data and Control Flow

Repository delivery remains synchronous:

```text
application executor
  -> repository callback
  -> Presentation admission adapter
  -> target admission endpoint
       -> validate category and physical capacity
       -> reserve nonzero sequence
       -> store in the selected physical store
       -> request/coalesce wake
  -> return admission outcome
```

Admission never enters the runtime or mutates the ViewModel. At the next
serialized opportunity, sealing closes the current stores and swaps or copies
their bounded metadata into an immutable sealed view. Later arrivals enter the
next admission window. Mutation performs a three-way merge by the sequence at
the head of each store, consumes the least sequence, applies it once, then
advances only that store. Completion empties the sealed view; no accepted entry
can be replayed.

When ordinary admission rejects, the adapter preserves the exact rejection and
asks the same endpoint to place one `operationalFailure` in the reserved slot.
Failure completion then performs required containment before constructing any
valid residual-policy input. A reserved-slot rejection is itself preserved and
cannot overwrite either ordinary traffic or an earlier failure.

## Algorithms and Data Structures

The sequence cursor stores the next `UInt32`. Reservation succeeds for
`1...UInt32.max`; accepting `UInt32.max` permanently exhausts the cursor.
Exhaustion rejects before store mutation, wake request, or sequence reuse.

Capacity checks are independent:

| Store | Bound | Ordinary producers |
| --- | ---: | --- |
| Snapshot | 1 | initial complete capture |
| Compact ring | 32 | capture mutations and acquisition state |
| Reserved failure | 1 | operational failure only |

Producer counters impose the stricter `20 + 2 + 6 == 28` production envelope.
The four spare ring entries test physical capacity but never extend a producer
budget. Category excess is rejected before consuming a slot or sequence.

The ring uses head, count, and fixed indices; it never resizes. The sealed merge
compares at most three head sequences per applied fact, so its work is linear in
the selected batch and its extra state is constant. Checked successor and count
arithmetic fail closed.

## Lifecycle and State

Construction starts with empty stores, sequence one, open admission, zero
producer counters, and no pending wake. Seal transfers only the entries present
at that boundary. Completing an opportunity releases the sealed values and
opens a new half-open service window with zero category counters; it does not
reset the lifetime sequence.

Quiescence first makes admission unavailable, then stops repository observation
and prevents new application callbacks. Existing sealed work is either
completed under the host's mandatory teardown rules or discarded with its
recorded containment. Teardown clears all three stores and wake state but never
makes a retired sequence reusable.

## Runtime Profiles and Platforms

Dynamic roots may use preallocated bounded buffers whose capacities equal the
validated SPEC-013 audit. Static roots use generated or caller-supplied fixed
storage with the same logical slots and merge rules. No profile selects a
different fact classification, sequence, capacity, rejection, application
order, or wake behavior. Raspberry Pi follows Dynamic semantics; nRF52840
follows Static semantics.

Static construction and steady-state admission must introduce no heap,
reflection, task, thread, exception, Objective-C, or dynamic collection path.
That requirement is verified from the final specialized host artifact rather
than inferred from the common tests.

## Resource and Failure Behavior

The mechanism retains at most one snapshot, 32 compact facts, and one reserved
failure plus fixed metadata. It performs no retry or synchronous runtime entry.
Physical-capacity, producer-category, unavailable, and sequence-exhaustion
rejections preserve their exact local condition. Mandatory containment is
independent of optional diagnostic projection and precedes residual policy.

The large snapshot payload is stored only in its dedicated slot; compact and
failure storage cannot silently absorb it. Profile byte reports measure each
physical store separately and reconcile their aggregate against SPEC-013 and
SPEC-015 audits.

## Test and Diagnostic Seams

Focused ledgers record attempted fact, producer category, selected store,
assigned sequence, outcome, wake transition, seal generation, application
ordinal, and disposal. Required cases include sequences one and `UInt32.max`,
exhaustion, each first excess, the complete 28-fact producer burst, all 32
physical compact slots, physical fact 33, post-seal deferral, cross-store
ordering, at-most-once application, reserved-slot isolation, quiescence, and
same-thread/distinct-executor transcript equality.

Diagnostics may observe a completed ledger entry after the authoritative
outcome. Tests inject omitted, saturated, and failing diagnostic sinks and
require identical storage, wake, effect, policy, and model transcripts.

## Rejected Implementation Alternatives

- A single heterogeneous array erases the independent snapshot and failure
  reservations and cannot establish static fixed storage.
- A sequence cursor per store cannot reconstruct total callback order.
- Applying facts in repository callbacks violates executor/mutation separation.
- Letting the four-slot margin extend producer bounds changes the approved
  workload rather than implementing it.
- Moving the endpoint into portable Presentation reverses target ownership and
  would expose Execution/profile machinery upward.

## Open Implementation Questions

No contract choice remains open. Concrete executable-source placement and the
generated static backing declaration are selected mechanically when the first
macOS and nRF composition roots are added; neither may change the ownership or
algorithm above.

## Code and Evidence Links

- [`HostSequencedFactAdmission.swift`](../../Sources/GiftUIHostConfiguration/HostSequencedFactAdmission.swift)
  implements the fixed host-owned sequencing kernel.
- [`HostSequencedFactAdmissionTests.swift`](../../Tests/GiftUIHostConfigurationTests/HostSequencedFactAdmissionTests.swift)
  covers physical and producer bounds, sequencing, sealing, deferral,
  quiescence, and nonaliasing exhaustion.
- [`SignalAnalyzerHostFactAdmission.swift`](../../Sources/SignalAnalyzerHost/SignalAnalyzerHostFactAdmission.swift)
  supplies the application-specific Dynamic retained endpoint, Static direct
  endpoint, shared production classifier, and exact rejection mapping.
- [`SignalAnalyzerHostFactAdmissionTests.swift`](../../Tests/GiftUIHostConfigurationTests/SignalAnalyzerHostFactAdmissionTests.swift)
  proves the target-root classification and application rejection vocabulary
  plus the production-pipeline mutation ordering without placing that switch
  in portable Presentation.
- [`fact-admission-cases.tsv`](../../Tests/ContractFixtures/SPEC001/fact-admission-cases.tsv)
  records the normalized T5.1 admission corpus.

The completed integrated profile-equivalence cycle and its checked-in
normalized rows are linked from the SPEC-001 Milestone 5 evidence.

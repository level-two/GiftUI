# RFC-014 working direction and approval process

**2026-10-10 — working RFC direction; not accepted architecture.** Parent:
[RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md).
Eugene proposed a Canvas protocol with deferred drawing, then observable
properties whose storage delegates to the graph with current/frozen versions,
and asked to fix those decisions and explain the process. This records that
combined direction for further RFC design. It does not infer approval of the
whole RFC, an ADR, a Specification, a physical storage budget or an experiment.

The feature remains at RFC stage under accepted PROPOSAL-007. Iteration 3 owns
the runtime-derived analyzer/counter validation; this adds no MVP or iteration
commitment. Earlier [A/B designs](rfc-014-source-design-options.md) remain
alternatives. The recommendation to develop closure-based SnapshotCanvas first
is replaced by the following working direction, C.

## Detailed design follow-up

The [C contract draft](rfc-014-c-contract.md) now specifies Canvas source,
contextual property reads, eager copy-freeze, initialization, replacement and
error behavior. The [storage ledger](rfc-014-c-storage-ledger.md) proposes K=2
current models and F=1 frozen frame model for both apps, with five analyzer
capture-sized banks and bounded refusal when a former owner occupies capacity.
These are proposed refinements under the instruction to proceed, not accepted
ADRs/Specs. Source-context injection, precise layouts and complete target costs
remain unproved in full. The subsequently authorized
[SPIKE-070](../../spikes/spike-070-protocol-canvas-versioned-access.md) is terminal
inconclusive, with native/ARMv6 positives and unrun Embedded escape/resource
gates. Direction C remains a working design; the result approves no API or budget.

## Decisions to carry into the RFC

| ID | Working design choice | Meaning and limit |
| --- | --- | --- |
| C1 | Canvas is a protocol refining View, with a draw method and framework-supplied leaf traversal | Application conformers need no body implementation. The protocol constrains Body to Never; the framework supplies the invariant body witness. Draw receives checked local bounds and an explicit scoped GraphicsContext. This changes today's concrete closure-based Canvas contract. |
| C2 | Observable properties delegate storage to stable typed runtime-owned model locations | The property wrapper identifies a location; it need not embed the large value in each copied View or Canvas. “Graph-backed” means associated with structural identity, not stored inside disposable graph nodes. An application-owned model can outlive its graph registration. |
| C3 | Model storage exposes current and frozen logical versions | Application mutation uses current data; body evaluation and drawing use the same frozen frame revision. Freeze is coherent across participating properties/models, not lazily chosen on first read. No torn frame combining different revisions. |
| C4 | One frame freeze covers graph construction, Layout and drawing | The framework retains the owner/backing until all frame readers and staged Canvas values are released. Canvas does not independently need a historical snapshot if all its reads are covered by that frame owner. Bounds checking alone does not make an escaped pointer safe. |
| C5 | Preserve the serialized mutation/admission contract | Incoming external events enter bounded admission. Existing model writes occur in the authorized mutation phase. Two logical versions do not introduce simultaneous writers, background model mutation or another executor. Supporting those would require a separate explicit revision of ADR-011/025 and race/atomicity design. |
| C6 | Defer physical allocation choices until the peak ownership ledger is complete | Two logical versions do not mean two extra analyzer buffers or prove that two slots cover source, admission, replacement and retained old models. Preserve ADR-034 until an explicit amendment/successor is accepted. |

C1/C2 come from the maintainer's proposals; C3–C6 make the required consistency,
existing phase constraints and resource limits explicit for review. None is a
new authority-bearing contract yet. The wrapper name (`@Published` or another
name) is provisional; no Combine dependency or Combine compatibility is implied.

## Proposed surface and lifecycle

This is an uncompiled protocol sketch, not the final public declaration:

```swift
protocol Canvas: View where Body == Never {
    func draw(
        in bounds: Rect,
        context: inout GraphicsContext
    ) throws(DrawingError)
}
```

The framework stages bounded concrete Canvas values, resolves local geometry,
then calls draw in deterministic order, synchronously and at most once per
occurrence per attempt. Drawing produces the existing bounded immutable plan
before frame offer. The backend receives operations, not a model or Canvas.
Static still needs finite typed payload storage and dispatch; using a protocol
does not authorize an arbitrary existential array, hidden allocation or a
pre-expanded graph. Conformer fields still need an enforceable storage contract.

Proposed sequencing:

1. Apply admitted mutations and replacement; record model dirtiness.
2. Establish one consistent frozen revision for all models read by the frame.
3. Bind model/property reads to that revision through an explicit owner context;
   construct the runtime graph, perform Layout and invoke concrete Canvas methods.
4. Release staged Canvas payloads and frozen read access after their final use;
   discard them on every failure path. Preserve existing plan/offer lifetimes.
5. Allow the next mutation/freeze sequence. A failed frame does not roll back or
   replay mutations; unpublished state remains dirty under existing contracts.

The exact context binding is still B1: a property getter must know whether it
addresses current or frozen storage without a global/task-local resolver, unsafe
escaped binder, or body reevaluation after Layout. A shared class reference does
not automatically provide that distinction. Every stored value or reference
reachable from the frozen version must remain stable too; freezing a top-level
pointer cannot freeze mutable nested storage.

For the first storage design, describe a complete copy/freeze protocol as a
semantic baseline, including bounded element-wise copying of large captures.
It is not a promise that that implementation fits. Compare bank swapping only
with a complete rule for preparing the next writable bank: unchanged fields
must not revert to an older revision. No copy-on-write, dirty-field propagation
or physical overlay is selected merely by choosing two logical versions.

## What must be settled before approval

- **B1:** exact property/model and Canvas declarations; initialization and
  materialization; current/frozen access binding; complete read/write routes;
  safe nested backing; diagnostics; supported compiler behavior and lifetime
  enforcement on all four configurations. The old Spike did not test C.
- **B2/B0:** [ownership ledger](rfc-014-ownership-audit.md), replacement/attach
  failure, detached application owners, frame pins, teardown and first-excess
  outcomes; map logical versions to source/admission/model backing and count
  peak bytes. Recompute the old four-slot budget; it is not evidence for C.
- **B4:** concrete analyzer and counter source, finite typed Canvas dispatch,
  real traversal, helper migrations and coherent structural identity. C does
  not imply adopting the previous ScopedState/WithModel/SnapshotCanvas API.
- **B3 and adoption evidence:** supported-image stack/heap and matched Dynamic
  costs. Keep full feasibility and the separate 4 MHz failure visible; classify
  which evidence is needed before design approval and which belongs to the
  approved implementation's conformance gates. Do not require production
  implementation before its Specification gate.

## Process from here

1. **Record the working direction — this change.** Update RFC navigation and
   retain alternatives/evidence. No accepted document changes and no new
   experiment is launched.
2. **Complete the focused RFC design.** Produce the exact source/access contract,
   lifecycle/error tables, application examples and physical ownership ledger
   for C. Resolve its conflict map against ADR-024/025/026/028/034 and affected
   SPEC-006/010/012/013/015 plus the analyzer SPEC-001. Preserve existing
   semantics where possible; identify actual amendments rather than implying
   that a new wrapper or protocol is a private implementation detail.
3. **Obtain only missing evidence.** If exact declarations or storage lifetime
   cannot be established by contract/source review, propose a new bounded Spike
   with named questions, target matrix, negative cases and numeric limits.
   Obtain experiment authorization before running it. SPIKE-069 is terminal;
   its unused allowance is not transferable. Do not reopen a general study.
4. **Review and approve RFC-014.** Resolve its approval blockers, then present
   the complete proposal for explicit maintainer approval. Direction selection
   alone does not approve unresolved runtime-record or resource decisions.
5. **Extract and accept focused ADRs.** After RFC approval, use proposed ADRs
   for runtime records/identity, Canvas invocation representation, and versioned
   observable ownership/access as warranted by the final decision boundaries.
   Amend/supersede affected accepted decisions explicitly; amend ADR-034 only
   if the physical reservation actually changes. Maintainer accepts the ADRs.
6. **Specify, plan and implement.** Draft affected exact Specifications, obtain
   approval, create ready implementation plans, then implement in coherent
   commits with conformance evidence. Iterate only on unresolved failures;
   preserve separate connected-operation and iteration closure gates.

This sequence follows [Feature Lifecycle](../../engineering/FEATURE_LIFECYCLE.md)
and [Documentation Rules](../../engineering/DOCUMENTATION_RULES.md#approval-authority).
Design work may continue under the existing request; authoritative acceptance
requires the explicit approvals above. No correctness obligation has been
moved to deferred work. General concurrent mutation/version history is not
included in this selected workload.

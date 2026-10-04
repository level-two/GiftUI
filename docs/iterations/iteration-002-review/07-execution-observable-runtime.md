# Step 07 — Execution, Observable State, Interaction, and Runtime

Source baseline: `6cf31f26`. Contracts: SPEC-009/010/011/013 and the SPEC-001
application joins; ADR-010/011/012/013/024/025/026/027/033.

| Owner | Reviewed joins and invariants |
| --- | --- |
| GiftUIExecution | Admission controller/sealer/transaction, phase machine, identity allocators, mutation batch, pointer action capture, frame-offer normalization, pending/recovery and wake state. Owns serialized phases, provenance and bounded admission, not application dispatch or concrete model storage. |
| GiftUIObservableState | Candidate/association/target lifecycles, attachment registration, replacement transaction/bridge, report guard, dirty derivation and binding decorator. Owns state-location/attachment validity and coarse dirty reporting. |
| GiftUIInteraction | Candidate staging, generation preservation, enabled/clip/hit validation, committed records, gesture adapter. Owns bounded routed actions/hits; runtime performs typed model dispatch. CBR-001 remains the independent staging-capacity defect. |
| GiftUIRuntimeCore | Profile validator/storage registry, common pipeline, interaction builder/dispatcher, cleanup/quiescence trackers and focused failure state. Composes focused contracts and audits physical storage; does not redefine Layout or backend mechanics. |
| GiftUIRuntimeDynamic | Heap-backed family/usage ledger, semantic/layout/drawing/render workspaces, Canvas storage, model registration/replacement and weak root target access. Logical limits remain independent of allocator spare capacity. |
| GiftUIRuntimeStatic | Caller-owned regions, fixed usage ledger, generated metadata/callable table, static observable/model/interaction stores, root target access and execution binding. Raw pointers require stable caller backing and scoped access; no substitute ARM target or heap representation proposed. |

## Complete input and failure flow

The inspected path is normalized event with physical-presentation provenance →
bounded source/sequence admission → sealed mutation batch → gesture capture at
the committed hit table → generation-qualified action → typed action conversion
and current-model borrow → model report → later semantic derivation/publication →
accepted physical presentation and interaction commit. Movement/up cancel stale
captures; dispatcher checks action identity/generation, enabled state, and current
target generation again, covering replacement between admission and dispatch.
Native root access uses a weak reference; Static access uses stable caller
storage. Those adapters have different ownership obligations.

Admission after a seal requests later work rather than entering the active
mutation phase synchronously. Reserved operational failure admission remains
distinct from ordinary capacity-limited facts. The report guard treats stale
attachments, coalesced changes, invalid phase with proved no-write, and unproved
safety differently. Replacement validates/reserves/attaches a candidate before
retiring the live registration; failed candidates detach/discard while retaining
the former identity and dirty state. Nonwrapping generation allocation intentionally
does not recycle an abandoned identity.

The common pipeline tracks mutation progress and publication separately.
Before publication, rollback discards candidate semantics/observable/interaction
state; after publication, offer failure preserves the published semantic revision.
Frame offer normalization rejects impossible body/endpoint pairs and preserves
producer versus endpoint refusal. Latest-only pending intent keeps the newest
semantic revision, separates backpressure from budgeted retryable refusal, and
coalesces wake requests. Quiescence refuses new admission before detaching and
releasing queues/routing/storage; it does not initiate a new body/handler/offer.

## Counterevidence and resource review

A suspected layout-failure callable leak is not a finding: common cleanup
discards the semantic candidate, and
`DynamicSemanticHostStorage.discardExpansion()` → `clearAttempt()` →
`canvasStorage.discard()` releases staged closures (lines 468, 644, 654).
The separate release action is needed in other stages, not proof of a missing
release in this composition. The nRF source stages callable payloads inside its
focused drawing invocation and checks release before publication.

The 16-family/51-limit registry distinguishes simultaneous persistent and
attempt-local stores, audit payload from allocator spare bytes, and reset from
teardown. Flattening these families or aliases into a single untyped region would
weaken accounting and lifetime evidence. Static/Dynamic convenience coordinators
forward to focused owners while enforcing binding quiescence; removing them is
not justified merely by forwarding method count.

No additional confirmed defect was established in these inspected state-machine
joins. Large owner state machines still depend on boundary/negative/injected-
failure corpora, including profile differential tests; Step 11 records their
fresh gate outcome. This source review does not turn software-generated input
into physical input or timing conformance.

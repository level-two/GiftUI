# Review64: current static dependencies and consolidated residuals

The result is **partial static evidence, not complete callee/safety eligibility**.
No source, compiler, executable, runtime state or contract was changed. The
human-approved review window is 2026-10-26 11:01:30–13:01:30 UTC. This follow-up
uses ordinary exact commands, hashes and raw outputs; the processing cap and
custom per-message ledger were removed only for this review. The two-hour,
8 MiB output and original aggregate excerpt limits remain.

[findings.json](findings.json) contains the causal claims and their limitations;
[residuals.json](residuals.json) is the one consolidated remaining set. Paths in
these files beginning `../` are result-relative; other paths are repository-root
relative. The raw outputs and exact decoder argument vectors are in
[the sibling local directory](../current-native-static-review64-local/).

## Supported results

* **Current Error category relation is repaired.** The prior and current
  ObservableState objects have different whole-file hashes. Their complete
  symbols and relevant sections/relocations, including the exact Error
  descriptor/type/cache data, agree; only modulehash data differs. This joins
  the already accepted current refusal/getter path to the old nongeneric
  resilient category. It establishes the conditional arena dependency, not
  unavoidable or observed allocation. See
  [current-error-data-relation.json](../current-native-static-review64-local/current-error-data-relation.json).
* **An actual Static Coordinator call reaches generic metadata and role
  dispatch.** The complete Static builder at `0x74cac–0x754fc` passes
  CounterAction metadata and the CounterRoles witness to the actual Canvas
  bridge. Its valid action branch dispatches witness slot 8 to the exact role
  body. The role body requests three concrete types before testing its input
  type. For CounterAction it then returns role 6 before the inert sample
  constructors and their `try!` paths. The opaque bridge also acquires generic
  Optional/Canvas/RecordView metadata before its record guards.
* **One concrete own-cache candidate is joined.** Static builder `0x751fc`
  requests `StaticTwoInteractionCandidateStorage<SemanticCompleteIdentity>`.
  The current negative cell, symbolic payload, descriptor, generic Eq key,
  accessor and own zero-fill cache are saved. The A47/A48 empty-cache/factory
  graph supplies a *conditional* allocator-family consequence under its normal
  valid argument, constraint, expected-provider and first-required-use
  premises. These premises are not promoted to a fully examined current
  parser/constraint closure or an unconditional implementation defect.
* **Fixed initialization is finite.** The actual current token/helper/callback
  chain supplies `(1,1,2,1,1,2,1,1)` to the complete current DrawingLimits
  constructor. Its guards pass and it has no calls. The actual Swift once
  import/export, dispatch winner/callback and wait wrapper are related. The
  wait wrapper calls the kernel `__ulock_wait`; recursion/contention/error and
  loaded-state premises remain explicit.
* **Remaining layout origins are precise.** The 28-byte thunk is reached by a
  four-byte wrapper and field-type symbolic references for ExecutionBinding,
  PipelineOwner and supplied Host storage. This is not a proof that runtime
  type-reference consumers never request it.

The selected Coordinator Static conformance execution is mandatory. It is not
silently substituted for resource-entry-v1's Graph/StaticScoped/Host invocation.
Other Host/traversal specializations, codec/error callbacks and remaining
metadata/witness acquisition are available local evidence, not missing providers.

## Retained boundaries

Installed config initialization, wait and allocator-backend bodies now have
bounded classifications. Their actual environment, arena/pool state, zone
registration/callback identity, loaded imports and kernel return behavior are
not observed. The config initializer has matched-key parsing/logging/string
duplication branches; absence of those inherited keys is not assumed.

Review63's incorrect whole-object equality claim and correction remain intact.
Its oversized 26-body Roles group remains NONQUALIFIED. Review64 selects the
exact role body through a new concrete Action caller; it does not retroqualify
the old group or all other traversal specializations. An initial review64 data
query incorrectly read a zero-fill cache as file-backed; the saved correction
removes those instruction bytes as evidence and cites actual section flags 1.

Unit execution remains FAILED before Interaction tests; Interaction is
UNEXECUTED. Existing Model/API/profile, live-state, stdout/persistence/window,
current-image/cold/resource and remaining P08 obligations remain open.
Functional 442/442 includes expected negatives and reused receipts, not 442
fresh invocations, and is not a resource or eligibility result.

No automatic source remedy is selected. A finite bridge/role specialization
assessment may address the demonstrated opaque dependency, but it must preserve
all generic operation/codec/role/error checks and prove actual compiled removal;
neither prewarming nor an assumed observer exemption follows from this review.

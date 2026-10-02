# T10.5 — Owning runtime seam blocks production delegation

Disposition: blocked; no partial production join retained. T10.1–T10.4 are
committed prerequisites. A local Dynamic stage extraction and common-runner
join compiled and exercised initial acceptance. It is not delivered as complete
because admission/application and exact failure handling still need the owning
runtime seam.

`RuntimePipelineMutationResult.failure` carries only
`RunCycleFailure<RuntimeOwnerFailure>`. If an admitted batch mutates the model
before failing, `RuntimeCompletePipeline.run` retains its initial
`mutationApplied = false`; it can only set that bit after `.applied`. Its
application-failure branch therefore reports `.unchanged` and no dirty wake.
SPEC-013 State/Lifecycle requires earlier failure to preserve applied state as
dirty and schedule paced rederivation. The attached reproduction confirms one
applied fact, preserves the exact focused error, and fails both required
disposition expectations. Existing fault-matrix tests assume application-stage
failures happen before any mutation; they do not prove this case.

Reproduce on e06114c3 by applying `common-runner-partial-mutation.patch`, then
`swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE --filter
partialMutationFailureRetainsDirtyStateForRederivation`. The expected failing
output is `common-runner-partial-mutation.log`. The patch is evidence, not a
registered failing production test.

The production admission boundary also returns typed
`SignalAnalyzerRuntimeCondition` rejections, including capture revision
mismatch and reserved failure capacity exhaustion. The fixed framework owner
carrier has no application-owner case. Returning a fabricated Execution
invariant or retaining meaning only in a diagnostic channel is not an approved
join. The owning review must establish how exact application failures and
partial mutation reach policy after mandatory effects without importing the
analyzer into Runtime Core.

Next required work: SPEC-013 Specification review of the mutation result /
application failure boundary, followed by an owner-plan repair and its partial
application regressions. Amend the governing RFC/ADR only if that review identifies an
architectural change. T10.5 explicitly requires missing production seams to be
resolved under their owning Spec; an analyzer-local coordinator is prohibited.
This is a current correctness blocker, not deferred Future Work.

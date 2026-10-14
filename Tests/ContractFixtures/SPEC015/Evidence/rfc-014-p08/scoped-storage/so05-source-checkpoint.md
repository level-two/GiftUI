# SO-05 source checkpoint — 2026-10-14

Input SO-04 checkpoint `fd879ad0`; continuation of the approved initial source
pass. No compiler/build/executable/formatter/debugger/IR/image/target invocation.

Changed source: `CounterScopedStorage.swift`, `CounterHostOwner.swift`,
`CounterDynamicHostOwner.swift`, `CounterPipelineOwner.swift`,
`CounterHostProbe.swift`, `CounterDynamicHostProbe.swift`, `CounterGraphProbe.swift`,
`CounterCoordinatorProbe.swift` and the approved additional `CounterAdmission.swift`.
The latter changes only its conformance constraint clause; all witness bodies
remain exact. Runtime coordinator source remains unchanged.

| Transfer / cleanup boundary | Source realization |
| --- | --- |
| Actual physical owner → session | The common token retains actual-owner dependence inside nested final-object borrows; session privately owns G and the five-input scoped Interaction state. |
| Session → Static/Dynamic supplied | Consuming `intoSupplied`/`intoDynamicSupplied` carries session/model/root/semantic/values/control union. Both supplied types preserve exact suppressed G/C/R/H plus existing concrete scope types and owned audit. |
| Supplied → pipeline → coordinator → host | Consuming `intoPipeline` transfers private fields with complete union; both host/state/coordinator aliases retain G/C/R/H. Original source/admission/endpoint/control and graph joins remain. |
| Inert retirement | `retireInertStorage` consumes supplied directly; no coordinator constructed. |
| Active retirement | Cache ticket released at existing pre-quiescence point; coordinator quiesced once; its dependent Optional consumed once by switch; pipeline consumed into `CounterRetiredStorage`. No fields borrowed/copied from dying opportunity. |
| Retired reset | Semantic → geometry → Interaction, with `self: copy self`; terminal invalidation remains in the existing pipeline and repeated empty resets do not resolve another candidate. |
| Before supplied / after supplied early return | Immediate `P08BodyCleanup` defer owns session reset or consuming inert retirement/reset. |
| After owner / before activation / activation failure / candidate failure / normal return | Holder owns one current stage. Owner path executes eight teardown steps; host path uses its existing idempotent teardown. Normal helper's completed teardown is observed, not replayed. Control checks require stopped input, detached observations, drained admissions/capture and no root/committed routing. |
| End callback / next session / final release | Access/token scopes end before factory idle checks; original banks and geometry must be empty/reset. Physical original inventory destructs in reverse after all scoped users. |

Selected native/Embedded Static and Dynamic outer storage and concrete host/graph
assembly bodies now live in the trusted file. Selected `geometry.take`,
`interaction.take`, old workspace callback and old Embedded slot/accessors are
absent. Owned coordinator profiles retain their independent storage and explicit
owned-only `returnWorkspaces`; owned scheduler/graph/action/semantic/pixel/join/
wake/admission controls are retained. Four selected Static slots remain disjoint
and graph/host stages sequential. Typed inventory/destructor and measurement
bookkeeping is completed alongside the carrier connection.

This is uncompiled source, not a runtime/fit pass. Full lifetime syntax/private
factory/Optional projection/audit reconciliation and every body return still
need independent source review and separately authorized four-profile evidence.
SO-06 corpus/driver/generator registrations follow before the coherent freeze.
Whitespace check passes. All criteria, fit, budgets/guard and lifecycle statuses
remain unchanged; zero post-freeze corrective passes.

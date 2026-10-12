# P08-B02 — reviewed helper and construction-mask realization

2026-10-12. Entry `6e332ab10e3ae5a7e0f636825fdcebe31ec6b693`;
only entry diff was the parent-authored B02 dispatch in `../../progress.md`,
included in this commit. Strong `gpt-6.1-sol`, high, C3/R3; sequential, no
delegation. [B01 independent Strong PASS](b01-independent-review.md) supplies
the exact inputs/classification. Governing criteria: HC-003/014/018 and
HC-RD-002 under ADR-038 and approved SPEC-015. No authority or scope change.

Implemented exactly the four reviewed fixture files under
`Tests/ContractFixtures/SPEC015/RuntimeDerived/`:

- `CounterHostOwner.swift` and `CounterDynamicHostOwner.swift`: removed both
  `constructedRuntimeProjectionIsValid` whole-coordinator borrowing helpers.
  Activation step7 now reads the existing `state.controlPointer` and checks
  `hasRoot`, `committedRecords == 2`, admissionController, wake and scheduler.
  Actual application and native endpoint projection checks stay at that boundary.
- `CounterHostAssembly.swift`: adopted the exact reviewed mask vector below.
  Endpoint6 retains backing0/text1/configuration2–5; admission11/root14 retain0;
  wake16 retains0 plus capability2–5 because its scheduler stores the complete
  assembly report. Normalized15's co-location and handler13's operation signature
  supply no construction edge. Comments identify these exact origins.
- `CounterGraphProbe.swift`: added the reviewed independent expected vector and
  checks each of eighteen role identities/masks. Preserved all eight structural
  negative modes and past-end behavior. The expected reported graph assertions
  increase from10 to46 (36 added role/mask comparisons); these have **not run**.
  Comments explicitly prevent a structural pass from claiming hidden-origin
  rejection evidence.

```text
role:  0 1 2 3 4 5  6 7 8 9 10 11 12 13 14 15 16 17
mask:  0 0 0 0 0 0 63 0 0 0  0  1  0  0  1  0 61  0
```

Static diff inspection confirms the changes are confined to those helper bodies,
their two activation call sites, graph mask selection/comments and corresponding
positive graph controls. Both initializer root/model association checks remain;
attachRoot's exact ticket retain and quiesce's release before shutdown remain.
No supplied storage, pointer getter, cache ownership, application/endpoint
constructor, wake notification, scheduler behavior or teardown path changed.
No source outside the four-file footprint changed.

Validation was source/diff inspection and `git diff --check` only. No compiler,
version command, macro/executable, formatter, gate, dependency rebuild/refresh or
target build ran. No feasibility or assertion pass is claimed. The formatter
and pinned identity recheck remain B03 prerequisites, followed by the single
predeclared native invocation and frozen outcome/separate review. Historical
repair **2/2 remains closed**; B03 native **0/1 remains unconsumed**.

The [B01 coverage table](b01-inventory.md#separate-operational-binding-and-required-coverage)
remains unchanged and mandatory for remaining P08: rejected-admission wake and
timestamp invariance; multiple fact categories behind nonfact wake; actual
foreign binding/control/report rejection; production burst/category boundaries;
actual nonretryable refusal/supersession; every actual activation failure and
backing expiry; required-origin/callback-indirection rejection before later
projection. Existing structural validation still cannot detect a missing legal
lower dependency. Actual Embedded endpoint, four registered application routes,
early linked target images/resources/ABI and final independent P08 exit also
remain open. B01 review explicitly permits these recorded gaps during bounded
B02/B03; they are neither optional Future Work nor a new approval gate.

B02 stops at this committed diff/receipt. B03 is separately dispatched. SPEC-015
remains implementing, its plan active and T8.1/P08 open; P09–P12 remain pending.

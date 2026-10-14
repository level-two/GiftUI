# SO-03 fixture stabilization source review — 2026-10-14

The maintainer authorized one bounded package to review the newly added SO-03
runtime fixtures together, correct related fixture defects within the existing
contract, validate with a fixed repair budget, and obtain independent review.
This is a new package allowance; the original, correction-1 and correction-2
native invocations and the first-trap diagnostic remain consumed. No historical
counter or two-consecutive-unproductive guard is reset.

## Reviewed source boundary

- `Tests/ContractFixtures/SPEC011/RuntimeDerived/InteractionProbe.swift`:
  the owned control, shared record/Canvas operations and host assertions.
- `Tests/ContractFixtures/SPEC011/RuntimeDerived/ScopedStorageProbe.swift`:
  five independent initializer inputs, the common actual-owner session,
  exchange and retained-owned dispatcher checks.
- `Tests/ContractFixtures/SPEC015/RuntimeDerived/CounterProfileStorage.swift`,
  `CounterStorageMeasurement.swift` and `CounterStorageRegions.swift`: source
  applicability and measurement callers frozen as SO-03 driver inputs, not
  compiled by this component invocation.
- `scripts/contracts/check-spec-011-owned-keys.py`: the finite native command
  plan, negative diagnostic oracles and existing execute cell.

The first-trap independent review identified a concrete Canvas fixture defect:
the Canvas construction enters three path components but calls `store` without
`appendRecord`. No semantic record exists, so the store must reject the active
path as `invalidIdentity` if reached. The single source correction adds one
checked `appendRecord` after the path loop. It creates record ordinal zero,
matching the unchanged `reference(at: 0)` assertion. The checked error still
uses the existing typed failure path. No other reviewed fixture defect has
source evidence sufficient for a change before validation.

The correction changes no production source, driver, accepted contract,
capacity, lifetime annotation, assertion or expected diagnostic. The three
measurement callers remain source-inspected only. Accepted ADR-039 and approved
SPEC-011 S11.1–4, SPEC-013 S13.1–2 and SPEC-015 S15 govern this work; all
three Specifications remain implementing with active plans. ITERATION-003
I3-04/I3-05 supplies the finite counter and four-stack need. I4-07 analyzer
integration and later P09–P12 duties remain separate.

## Fixed validation and stop budget

One source repair pass is used here. After committing this source checkpoint,
run exactly one fresh macOS Dynamic `run-spec-011.sh` invocation with the pinned
RFC-014 compiler and GiftUI build. Its internal plan remains 42 compiler cells
and one execute, including 27 focused probes. Stop at the first unexpected
cell and preserve raw output. No automatic follow-up source repair, compiler
variant, retry, debugger launch, broader suite, target/image build or hardware
action is included. Commit the result separately, then request a separate
read-only Strong review of the source and exact result.

All nine SO criteria, physical fit and the 58,648-versus-27,648 stack finding,
HC-RD-003/P08/R07/T8.1, and I4-07/P09–P12 remain open until their own evidence
and gates are met. SO-04–09 remain unapproved.

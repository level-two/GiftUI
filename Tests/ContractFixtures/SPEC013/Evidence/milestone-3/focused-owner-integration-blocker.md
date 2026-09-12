# T3.5 / T4.5 Focused-Owner Integration Blocker

Date: 2026-09-12

SPEC-013's Dynamic and Static concrete coordinators cannot yet conform to
`GiftUIRuntimeProfileCoordinator` without inventing an Interaction-owned seam.
The protocol requires a typed `Handler` and `TargetAccess`, and the approved
cycle requires the dispatcher to re-read the committed record and validate its
identity, action generation, enabled state, target generation, and action code
immediately before borrowing the current model.

The repository currently contains `ActionModelTargetAccess` and the completed
SPEC-011 candidate/gesture machinery, but no `InteractionDispatcher` protocol,
production dispatcher, or target-composed adapter. SPEC-011's active plan
confirms T5.1 through T5.6 remain unchecked; T5.3 owns those missing surfaces.
Recording mutation helpers are explicitly non-production and cannot satisfy
SPEC-013 T3.5, T4.5, or Milestone 5.

Consequently:

- T3.5 cannot bind Dynamic Interaction publication and dispatch;
- T4.5 cannot bind the fixed Static stores/table to a complete common
  coordinator or make the required full-operation allocation claim; and
- Milestones 5 through 7 and the dependent Milestone 8 integration/conformance
  work cannot begin.

Resolving this requires authorization to resume the approved SPEC-011 plan at
T5.1 and jointly land T5.1-T5.6 with the SPEC-013 profile adapters. Runtime Core
must not create a substitute dispatcher, model registry, or alternate action
algorithm.

Reproduction:

```text
rg -n "protocol InteractionDispatcher|struct .*InteractionDispatcher" Sources Tests
sed -n '395,430p' docs/implementation-plans/spec-011-implementation-plan.md
```

The first command finds no production symbol. The second shows all six required
SPEC-011 Milestone 5 tasks still open.

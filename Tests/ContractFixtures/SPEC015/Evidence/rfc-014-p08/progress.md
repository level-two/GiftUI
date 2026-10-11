# RFC-014 P08 execution receipt — 2026-10-11

**Current boundary: host integration blocked pending exact SPEC-015 lifetime
review/approval.** User authorized proceeding after P07; orientation started at
clean `9fa495dd`. Strong Sol 6.1 High, sequential, no delegation. P08 starts and
remains **0/2 consecutive unproductive repairs**. P07 history is unchanged.

Entry authority: approved SPEC-015 runtime amendment, T8.1 / HC-RD-001–004,
accepted ADR-035/036/037, [bounded P08 sequence](../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md#ordered-work-packages),
ITERATION-003 I3-04/05 and closed MVP stack/behavior regression. SPEC-015 remains
`approved`, plan `ready`; no production implementation transition is claimed.
P07 finite exit passed separately; full T9.1/T11.1 and P10–P12 remain open.

## Step 0 — exact containing-host boundary

Files/symbols inspected: SPEC-015 `MVPHostInstance` and concrete construction
clauses; source `HostConfigurationResults.swift` / `MVPHostInstance`,
`HostPresetBootstrap.swift` / `MVPValidatedHostInstanceFactory.Instance` and
`HostPresetConstructionResult`; both actual runtime concrete coordinators and
their audited-binding conformance. Invariant: a host retaining a scoped
coordinator cannot outlive any supplied backing, yet must preserve the complete
validation/activation/teardown contract and role graph.

The [decision packet](scoped-host-constraint.md), evidence-only exact
[proposed diff](proposed-spec-015.diff) and [seven pinned controls](scoped-host-proof/result.json)
record the concrete conflict, proposed narrow correction and limits. Exact command:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-host-proof/reproduce.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmpwj8mqyyn/macos-static
```

Current host protocol rejects inherited Escapable; proposed correction and
concrete lifetime-dependent return compile; copy/escape reject. Current internal
associated factory rejects a scoped Instance, and naive associated suppressions
are unavailable on the pinned compiler. No existing bootstrap success is inferred.
All seven persistent controls match their expected outcome; all 165 runtime
inputs, 143 artifacts and compiler/core receipt hashes verify. An initial missing
audited-binding constraint in a temporary fixture was corrected productively.
Guard remains **0/2**. Only evidence/checkpoint documentation changed.

Next: separate bounded Strong review of the exact proposal, including construction
compatibility and required negative/lifecycle proof; explicit maintainer decision;
then implementation only under the resulting approved contract. No independent
schema expansion, P09 work, compiler change, hardware operation, resource claim
or package acceptance accompanies this blocker record.


## Approved correction — 2026-10-11

Eugene explicitly replied “Approved, please proceed” after the separate
[independent proposal review](independent-blocker-review.md). The exact reviewed
[diff](proposed-spec-015.diff) is applied to SPEC-015; the
[approval map](../../../../../docs/iterations/iteration-003-review/rfc-014-spec-approval.md#scoped-host-lifetime-amendment--2026-10-11)
records the decision and unchanged construction/activation/teardown obligations.
Original packet/probes/review remain intact. This commit changes authority and
traceability only; production implementation starts afterward. Guard **0/2**.

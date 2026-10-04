# Step 31 — Iteration 2 scope preparation

The maintainer requested filling the scope after completion of the bounded
research. [ITERATION-002 revision 7](../iteration-002-cleanup.md) replaces the
candidate collection with a reviewable proposed delivery baseline. It remains
`draft`; `approved_revision`, `approval` and `closure` remain null. Preparing
this revision is not approval of it or authorization to amend accepted contracts.

## Recommended selection

| Item | Proposed outcome | Exit criteria |
| --- | --- | --- |
| I2-01 / CBR-007 | Callback-safe acquisition startup | IT-AC-008 |
| I2-02 / CBR-001 | Complete staged interaction capacity preflight | IT-AC-009 |
| I2-03 / CBR-004 | Isolated runner evidence/scratch with retained failures | IT-AC-010 |
| I2-04 / CBR-006 | Accept documented safe repository source paths | IT-AC-011 |
| I2-05 / CBR-008 | Actual artifact compiler/SDK identity | IT-AC-012 |
| I2-06 / CBR-003 | Startup text validation through the shared Layout owner | IT-AC-013 |
| I2-07 / FW-029 | The 15 named Embedded file guards and empty-shell cleanup | IT-AC-004 |
| I2-08 / CBR-002, SPIKE-011 | Clean generation of both existing topology outputs | IT-AC-003 |
| I2-09 / Step 14 | Approved 5s/404-record retention across all three stores | IT-AC-005 |

IT-AC-001/002/006/007 cover registration, ownership/dependencies, preserved
research provenance and evidence-based closeout. Existing criterion IDs are
retained; newly explicit defect criteria receive IT-AC-008–013. The milestones
state delivery order without pretending to be a ready implementation plan.

Two reproduced correctness defects and three evidence-tooling defects take
priority over simplification. Runner isolation precedes overlapping integration
validation. Startup/source/generator maintenance has explicit parity and resource
requirements. Retention drafting may proceed independently, but production
retention changes depend on RFC/ADR/Spec approval and a ready plan.

## Boundaries and lifecycle routing

This is post-MVP work on features currently registered as `implemented`.
Accepted ADR-003/007/008 and implemented SPEC-001/002/007/011/013/015 remain
authority. I2-01–08 use lightweight maintenance only while approved contracts,
module owners, profile semantics and resource bounds remain intact. I2-09
changes the accepted history horizon: it requires a reviewed RFC amendment,
a successor accepted decision for ADR-003 and approved affected Specifications.
The scope itself does not create those artifacts or approvals.

The dependency review found no new wrong dependency; preserving ownership is
an integration invariant, with no blanket redesign selected. Clean generation
is partial remediation of CBR-002, not elimination of specialized binding policy
or all ordinal mappings. Named roles and full runtime replacement remain under
EXP-001's revisit triggers. CBR-005, rendering performance and the broad connected
validation campaign remain deferred under existing records and exceptions.

The proposed retention keeps the 30s/80-event-per-second workload and 1/2/5s
visible windows. Total delivered facts are distinct from retained history.
Connected regression checks for changed paths are included, while virtual-time
history checks do not prove lossless wall-time delivery or four-fps presentation.
The measured timing gaps remain visible. Any newly exposed failure needs an
explicit disposition rather than an inferred extension of an old exception.

## Handoff and validation

Next: explicit maintainer approval of revision 7, followed by applicable upstream
retention gates and ordered implementation tasks with evidence mappings. If a
selected outcome cannot be delivered, report it as unmet and seek a specific
scope amendment/exception before closure. Do not reopen generic audit passes.

Scope, findings and review navigation are cross-linked. FW-029 and EXP-001 record
the bounded draft selection without promotion. The manifest's navigation comment
is refreshed; its feature stages and registered relationships are unchanged.
No production source, maintained tests, operational scripts, accepted contracts,
historical evidence or connected device state changes in this step.

[Validation record](evidence/31-scope-validation.json) records documentation
links, scope item/criterion traceability, unchanged authority/production inputs,
immutable research archives, whitespace and both governance validators.
Repository product tests are not rerun for this documentation-only step.

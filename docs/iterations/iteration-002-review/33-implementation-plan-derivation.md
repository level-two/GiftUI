# Step 33 — Implementation plan derivation

Eugene approved iteration 2 revision 7 and requested a separate commit of derived
planning results. [Step 32](32-scope-approval.md), commit `2a0bf0fa`, records the
scope approval before planning. No product implementation begins in this step.

## Derived records

- [Delivery coordination](../iteration-002-cleanup/implementation-plan.md)
  maps all nine selected items and all thirteen iteration criteria, delivery
  order, shared-output prerequisites, exact owner/build commands, resource and
  connected evidence boundaries, design-note triggers and upstream blockers.
- [SPEC-001 plan](../../implementation-plans/spec-001-implementation-plan.md),
  Milestone 11: eight pending tasks for source startup and integration, shared
  startup text, clean generation, report identity, final profile/connected
  evidence and reconciliation. Its complete 45-criterion matrix retains original
  mappings and adds cleanup tasks; original ledger entries are unchanged.
- [SPEC-011 plan](../../implementation-plans/spec-011-implementation-plan.md),
  Milestone 10: three pending staged-capacity correction/integration/gate tasks.
  Its complete 13-criterion matrix and previous ledger entries remain intact.
- [SPEC-013 plan](../../implementation-plans/spec-013-implementation-plan.md),
  Milestone 10: three pending source-selection/validation/integration tasks.
  Its complete 15-criterion matrix remains intact. It has no existing structured
  task-evidence manifest; pending task dispositions are recorded in the plan.

The three existing owner plans move from `completed` to `ready` for the added
maintenance milestones. Their original completed tasks and historical conformance
remain valid for their recorded scope; existing Specifications and feature stages
remain `implemented`. No new Specification is created, amended or promoted.
Existing Specification-to-plan links continue to identify the same plans.

## Readiness and boundaries

I2-01–08 are executable maintenance under the current accepted contracts.
Repository runner/source-path tasks live in delivery coordination rather than
being represented as a new product Specification. Runner protection must cover
child-owned shared writers before overlapping aggregate gates.

I2-09 has ordered RFC review, successor ADR acceptance, coordinated Specification
approval and subsequent exact implementation-plan derivation. Its production
tasks are intentionally not ready under the current 30s/2,404-record contract.
That remaining approval dependency does not invalidate independent maintenance
readiness. It remains current selected work, not a deferred promise or an
automatic exception. The scope remains `approved`, revision 7; implementation
activation and final closure have not occurred.

Prototype results support expected comparisons only. The plan preserves packed
runtime hierarchy and specialized model policy; CBR-002's residual coupling,
CBR-005/performance and broad connected-validation gaps retain existing deferred
records/triggers. No new optimization, lower input rate, workload duration change,
stack reduction or full-conformance claim is introduced.

## Validation

[Planning validation](evidence/33-plan-validation.json) records complete unique
criterion mappings, matching task/ledger dispositions, unchanged original ledger
entries, scope approval integrity, local links/anchors, existing file references,
unchanged product/authority/historical archives, whitespace and governance checks.
New tasks have no execution evidence; metadata files under ContractFixtures are
planning ledgers, not changed product fixtures or passed tests.

Product tests and connected operations are not performed for this documentation
and pending-ledger derivation. An additional local formatting change to the
iteration 3 Included Scope table appeared during planning; preserve it in the
requested workspace commit after verifying that its cell content, metadata and
scope are unchanged. Commit these records separately from scope approval.
The first executable correctness tasks are SPEC-001 T11.1 and SPEC-011 T10.1;
retention drafting may advance independently through its explicit gates.

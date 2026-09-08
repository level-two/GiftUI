# SPEC-010 T3.4 Reconciliation Fault Evidence

## Matrix

The focused fault suite injects every T3.4 boundary:

| Boundary | Expected result and mandatory local effect |
| --- | --- |
| Location reservation | `locationCapacityExhausted`; no rejected association |
| Registration reservation | `registrationCapacityExhausted`; no rejected association |
| Association staging | `associationStagingCapacityExhausted`; sticky first failure |
| Duplicate owner | `duplicateOwner`; original owner remains attached |
| Incompatible association | `incompatibleAssociation`; prior live association remains |
| Nil attachment return | `staleAttachment`; candidate route retires |
| Mismatched attachment return | `staleAttachment`; candidate route retires |
| Report during attach | `staleAttachment`; a later matching return cannot activate |
| Mismatched detach | `invariantViolation`; installed registration stays active |
| Finish invariant | `invariantViolation`; active candidate storage is cleared |

Candidate discard invalidates and detaches candidate-only state, restores
bounded storage for a later attempt, and preserves the prior live association.
The state-aware decorator separately enumerates every candidate binding error
and proves the body remains suppressed.

## Reproducible validation

```sh
swift test --filter 'ObservableState(ReconciliationFault|BindingDecorator)Tests'
ruby scripts/contracts/check-spec-010-reconciliation-faults.rb
```

The registered audit also rejects dynamic containers, reflection, suspension,
prohibited owner imports, and public/package exposure of the route lifecycle.

## Boundary

This task validates owner-local errors and cleanup. SPEC-003 fact mapping,
residual policy, dirty/wake behavior, replacement, generation allocation, and
profile storage remain assigned to later SPEC-010 milestones.

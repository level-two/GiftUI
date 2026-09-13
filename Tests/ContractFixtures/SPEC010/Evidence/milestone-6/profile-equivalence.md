# SPEC-010 Milestone 6 Profile Equivalence

Date: 2026-09-13

The Runtime Conformance target runs one generic `ObservableStateReconciler`
and `ObservableStateTargetView` algorithm over two physical stores: bounded
Dynamic array storage and a two-slot, value-typed Static store. The shared
corpus proves initial materialization, same-location preservation, distinct
declaration ordinals, candidate-only publishable generations, retirement,
exact first excess, and generation exhaustion with value-for-value equal
normalized results.

The Static store has exactly two inline `ProfileSlot` fields. Its focused
operation path uses no `Any`, reflection, strings, task/thread facility,
Objective-C runtime, arbitrary existential registry, or dynamic collection.
Memory-layout assertions account for both slots including alignment padding.
The surrounding transcript array is test-owned observation, outside the
Static operation path.

Existing focused owner suites supply the remaining Milestone 6 evidence:

- dirty derivation tests exercise twenty reports, one dirty location, one
  outstanding wake, one reevaluation, and no replay;
- presentation-fact admission tests prove later-cycle ordering, refusal,
  after-seal deferral, and no direct model mutation;
- attachment, association, replacement, lookup, and target-lifetime suites
  cover stale reuse, replacement failure, and generation retirement.

Run from the repository root:

```sh
swift test --filter observableProfile
swift test --filter staticObservableProfileStorageIsFixedAndValueTyped
swift test --filter ObservableStateDirtyDerivation
swift test --filter PresentationFactAdmission
swift test --filter ObservableStateTarget
scripts/contracts/check-spec-010-harness.rb
```

These are host-execution and source-inspection results. Production capacities,
host assembly, and connected-target behavior remain owned by SPEC-015.

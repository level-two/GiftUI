# SPEC-010 T4.2 Atomic Replacement Evidence

The profile-neutral replacement transaction accepts work only in `.mutating`
and applies the focused order: compatibility, ownership, fresh-generation
reservation, registration capacity, then replacement-staging capacity. A
successful begin owns a candidate-only registration whose complete attachment
must be returned exactly before commit.

Commit retires the exact former route, installs the verified candidate with
its fresh target generation, returns the former attachment for one detach,
and marks the location dirty. The success fixture proves the former attachment
is stale, the candidate attachment is current, the former model is detached
once, and the fresh current association remains dirty when a later derivation
fails.

Every validation, ownership, generation, registration, staging, nil-return
(`duplicateOwner`), and mismatched-return (`invariantViolation`) failure
preserves the former route, target generation, and dirty state. Candidate
attachment failures return the candidate attachment for cleanup. A synchronous
report during attachment is stale and poisons the attempt: a later matching
attachment return cannot erase the first failure or activate the candidate.

```sh
swift test --filter ObservableStateReplacementTransactionTests
ruby scripts/contracts/check-spec-010-replacement-transaction.rb
```

The transaction exposes no model or target lookup. Borrowed live and
publishable lookup timing remains T4.3.

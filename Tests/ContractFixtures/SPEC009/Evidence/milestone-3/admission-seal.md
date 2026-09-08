# SPEC-009 T3.5 Admission Seal Evidence

The focused sealer selects bounded prefixes in the contract order: pointer
events, state-change facts, completion facts, same-cycle activation
candidates, one dirty intent, then one latest-presentation intent. Counts
equal to their cycle-stable limits succeed. Activation candidates must arise
from selected pointers and fit the semantic-action limit.

Excess valid pointer/fact suffix counts produce a successful selection with
`hasDeferredWork`; they do not fail or enter the current membership. The
admission controller records arrivals after the seal as deferred, retains
their original storage order, and creates a fresh `.admittedWork`
empty-to-nonempty transition after the opportunity's prior wake was taken.

```sh
swift test --filter 'ExecutionAdmission(Sealer|Controller)Tests'
ruby scripts/contracts/check-spec-009-admission-seal.rb
```

The task does not apply facts, dispatch activation candidates, or choose
production queue packing. Seal-time pointer and reservation rollback faults
remain T3.6.

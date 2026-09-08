# SPEC-009 T3.4 Admission Controller Evidence

The internal fixture-finite controller conforms to the common
`ExecutionAdmissionSink` and delegates physical records to caller-owned
bounded storage. It copies complete normalized pointers, state-change facts,
and completion facts only after validation and category-capacity checks, then
joins the existing coalesced `.admittedWork` wake path. A queued result makes
no current-cycle membership promise and invokes no fact or action.

The focused matrix proves:

- every result preserves the exact current `ExecutionContext`;
- stale revision, invalid sequence/ordinal, pointer capacity, active-source
  capacity, and quiescence perform mandatory sequence cancellation;
- invalid state/completion values, disabled completion, category saturation,
  and unavailable state retain no rejected copy and request no wake;
- successful submissions retain exact values and coalesce to one wake; and
- pointer validation precedes queue reservation, with only already-proven
  numeric state advancing before a capacity cancellation.

```sh
swift test --filter ExecutionAdmissionControllerTests
ruby scripts/contracts/check-spec-009-admission-controller.rb
```

The one-source fixture represents the configured
`maximumActiveInputSources == 1` boundary without choosing SPEC-013's
production multi-source packing. Sealing, application, dispatch, and
after-seal membership remain T3.5 and later tasks.

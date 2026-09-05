# SPEC-010 State and Sink Ownership

Plan task: `T1.3`

Date: 2026-09-05

`State<Value>` exposes only the exact public initializer and nonmutating
wrapped-value setter. Its package representation is a closed two-case storage:
`initial(Value)` or `bound` with fixed live-read and replacement routes.
Successful binding extracts the initializer, replaces the storage case, and
returns the extracted value to the observable-state owner. The wrapper never
retains the initializer and bound routes simultaneously, and a repeated bind
returns `nil` without installing a fallback.

Focused tests prove that a bound getter follows the current live-read route,
the setter forwards replacement candidates, a preserved binding releases its
repeated initializer after owner consumption, and later binding is refused.
A coordinator-shaped fixture records only the first setter failure, ignores a
later success, returns that first failure synchronously, and clears the slot on
consumption. It stores no model, candidate, callable, fact, or history in the
result slot. The production slot and exact `ObservableStateResult` remain
owned by T5.4 after SPEC-009 and T2.1 provide their approved declarations.

`_GiftUIObservableChangeSink` is noncopyable and has one private attachment and
one fixed report route. Construction remains package-only. Its read-only
attachment access does not consume the sink, while a compiler-negative fixture
that reaches SIL generation rejects two consuming uses with the ownership
diagnostic. `check-spec-010-state-wrapper.rb` fixes the two-case and route
shape and rejects task-local state, global mutable fallback, string keys,
`Any`, reflection, and the removed PoC registry family.

Validation commands:

```text
swift test --filter ObservableStateDeclarationsTests
scripts/contracts/check-spec-010-state-wrapper.rb
scripts/contracts/check-spec-010-sink-ownership.sh
scripts/contracts/run-spec-010.sh --profile macos-dynamic
```

The contract driver remains conformance-incomplete by design: this task closes
the portable wrapper/sink boundary only and does not claim runtime owner,
profile, execution-cycle, or four-profile evidence.

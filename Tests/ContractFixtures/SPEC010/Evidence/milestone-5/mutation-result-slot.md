# SPEC-010 Mutation Result Slot Evidence

`ObservableStateMutationResultSlot` is bounded inline coordinator state holding
only cycle activity and the first `ObservableStateError`. A failed bound setter
or report disposition records that exact error. Later failures and successful
results cannot overwrite it, and the model, fact, callable, candidate, and
operation history are never retained.

The coordinator consumes and clears the slot synchronously after each enclosing
fact, handler, or fixture operation. Derivation is refused while an unconsumed
failure remains; after consumption, a later operation may report its own exact
failure, and the slot must again be empty before the mutation-to-derivation
transition.

When no cycle is active, a failure is not stored. It is returned as an
`ownerAdapter` route so the mandatory disposition occurs directly. Successful
results create neither a stored failure nor an adapter route.

Reproduce the focused evidence with:

```sh
swift test --filter ObservableStateMutationResultSlotTests
scripts/contracts/check-spec-010-mutation-result-slot.rb
scripts/contracts/run-spec-010.sh --profile macos-dynamic
scripts/contracts/run-spec-010.sh --profile macos-static
```

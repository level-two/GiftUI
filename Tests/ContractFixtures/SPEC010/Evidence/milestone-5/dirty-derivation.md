# SPEC-010 Dirty Derivation Evidence

`ObservableStateDirtyDerivation` is a two-location, profile-neutral proof of
the shared dirty/wake lifecycle. Each clean-to-dirty location transition
returns `dirtied`, repeated reports for that location return `coalesced`, and
all dirty locations share one outstanding `semanticDirty` wake.

At idle opportunity entry the wake is taken before mutation freezes. Freeze
captures the represented dirty epoch, and any dirty bit triggers one complete-
root derivation covering both fixture locations. Successful publication clears
exactly that represented epoch. A later frame refusal does not restore dirty
state or request another wake because semantic publication is already complete.

Derivation failure keeps the represented changes dirty and requests one later
semantic wake after the first was taken. The separately entered recovery cycle
rederives the complete root while the applied-mutation count remains unchanged,
proving there is no mutation replay. Mutation and a repeated freeze are both
rejected after the freeze boundary.

Reproduce the focused evidence with:

```sh
swift test --filter ObservableStateDirtyDerivationTests
scripts/contracts/check-spec-010-dirty-derivation.rb
scripts/contracts/run-spec-010.sh --profile macos-dynamic
scripts/contracts/run-spec-010.sh --profile macos-static
```

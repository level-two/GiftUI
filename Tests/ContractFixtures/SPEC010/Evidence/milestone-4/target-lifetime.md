# SPEC-010 T4.4 Target-Lifetime Evidence

The profile-neutral lifetime coordinator holds only bounded attachment and
opaque-generation records around the model-free lookup slot. Candidate-only
discard returns the exact attachment for detach, reports the exact retired
generation, removes all lookup visibility, and invokes the abstract
Interaction candidate-discard seam exactly once. The fixture attaches and
detaches a model at that exact returned attachment, then proves a later
reservation—even in the recycled slot—receives a fresh generation.

Publishing an unencountered candidate retires the former live attachment and
generation and makes live lookup return `nil`. Publishing a candidate-only
encounter makes it live without discarding Interaction; discarding a preserved
encounter keeps the former live target but still discards the unpublished
Interaction candidate. The T4.2 preservation matrix proves failed and staged
replacement never changes the former live target.

Interaction candidate construction receives the private lookup through one
synchronous closure whose parameter is explicitly `borrowing`. The owner does
not expose the view as stored state, and its source contains no model, sink,
handler, callable, Interaction import, or dynamic collection.

```sh
swift test --filter 'ObservableState(TargetLifetime|TargetLookupSlot|ReplacementTransaction)Tests'
ruby scripts/contracts/check-spec-010-target-lifetime.rb
```

Together with T4.1–T4.3, this closes Milestone 4 target-generation lifetime.
OS-003, OS-009, and OS-012 remain pending where their mappings still require
profile-equivalence work in T6.1.

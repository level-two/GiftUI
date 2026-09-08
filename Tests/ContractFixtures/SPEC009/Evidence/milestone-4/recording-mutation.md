# SPEC-009 T4.2 Recording Mutation Evidence

The bounded sealed mutation batch owns at most two values per fixture category
without dynamic storage. It applies state-change facts first, completion facts
second, and semantic actions last, preserving producer or pointer order inside
each category. A batch becomes one-shot before the first effect; every later
phase and repeated mutation attempt leaves the exact applied transcript
unchanged.

Construction and `.admitting` perform no application or dispatch. Immediately
before each action dispatch, the owner revalidates the exact identity, action
generation, enabled state, and observable target generation. Missing identity,
generation mismatch, disablement, or target-generation mismatch suppresses
dispatch without retargeting; a fully matching action dispatches once.

```sh
swift test --filter RecordingMutationBatchTests
ruby scripts/contracts/check-spec-009-recording-mutation.rb
```

The fixture retains complete finite values only and imports no semantic,
layout, observable-state, Interaction, render, runtime, backend, or platform
owner. Mutation freeze and publication remain T4.3.

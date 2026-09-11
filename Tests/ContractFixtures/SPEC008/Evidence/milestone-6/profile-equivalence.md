# T6.5 Render Profile Equivalence

All five canonical rendering cases execute through recording, fixture-dynamic,
and fixture-static identity and workspace representations. The representations
use distinct identity layouts, ordinal-visit storage, and foreground-stack
storage while sharing exactly one generic call to
`GiftUIRenderLowering.RenderProducer.produce`.

Each case compares the complete `RenderProductionResult`, header-bearing
ordered value-event sequence, real SPEC-003 adapter result, render limits,
structural workspace capacity, and observed foreground high-water. The
existing canonical goldens independently bind each named case to its exact
manifest fields; the equivalence audit rejects a missing or extra profile case.

Reproduce with:

```console
swift test --filter canonicalCorpusMatchesAcrossRecordingDynamicAndStaticRenderProfiles
scripts/contracts/check-spec-008-profile-equivalence.rb
```

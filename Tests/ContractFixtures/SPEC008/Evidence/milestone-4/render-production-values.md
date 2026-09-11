# T4.1 Render Production Value Evidence

Date: 2026-09-11

`GiftUIRenderLowering` now owns the exact six-byte, nonzero `RenderLimits`, the
bounded `RenderProductionResult`, and the identity-keyed caller-owned
`RenderProductionWorkspace` lifecycle. The package target has exactly the five
approved production dependencies. `RenderDamageMode`, required by the approved
producer signature, is the exact one-byte closed value owned by Render Core.

Reproduce on the pinned host toolchain:

```sh
swift test --filter RenderProductionValueTests
swift test --filter RenderValueTests
swift package dump-package | ruby scripts/contracts/check-target-dependencies.rb
scripts/contracts/check-spec-008-render-production-values.rb
scripts/contracts/check-spec-008-render-core-values.rb
```

The focused tests cover each zero-limit rejection, exact admitted fields,
value-layout ceilings, all seven success/failure payloads, capacity reporting,
nested acquisition refusal, exact reset counting, and clean workspace reuse.
The source audits reject duplicate ownership, dynamic storage, public surface,
and prohibited failure/execution/capability coupling.

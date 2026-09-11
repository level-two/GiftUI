# Render Failure Adapter Evidence

`GiftUIRenderFailureAdapterFixture` depends only on `GiftUIRenderLowering` and
`GiftUIFailureCore`. Its pure result-to-fact function maps all seven closed
`RenderProductionError` cases to the exact SPEC-003 condition, origin, affected
scope, and containment required by SPEC-008.

The focused test exhausts the seven mappings. The source audit also proves that
Render Lowering imports neither Failure Core nor Failure Diagnostics and that
the adapter has no diagnostic, allocation, or production-attempt path. Mapping
therefore cannot change a render result or trigger a second attempt.

Run:

```sh
swift test --filter GiftUIRenderFailureAdapterTests
scripts/contracts/check-spec-008-render-failure-adapter.rb
swift package dump-package | ruby scripts/contracts/check-target-dependencies.rb
```

# SPEC-008 Render Core Value Evidence

Plan task: `SPEC-008 T3.1`

`Sources/GiftUIRenderCore/RenderValues.swift` is the first source in the new
package-internal Render Core target. Its only dependencies are `GiftUI` and
`GiftUITextResources`; SPEC-002's exact target graph records those two edges
and the focused test target atomically with the source.

Focused tests prove every field and initializer, nominal font/glyph identity,
the exact seven-case `RenderProductionError` raw-value order, exact 4-byte
`RenderSinkCapacity`, exact 1-byte error layout, and every remaining value-size
ceiling. The source audit proves sole ownership and excludes strings,
references, existentials, closures, dynamic collections, semantic/layout/
lowering/failure/capability imports, and duplicate resource identity types.

Reproduce from the repository root:

```text
swift test --filter RenderCore
scripts/contracts/check-spec-008-render-core-values.rb
swift package dump-package | scripts/contracts/check-target-dependencies.rb
```

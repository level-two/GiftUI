# SPEC-008 Semantic Render View Evidence

Plan task: `SPEC-008 T2.1`

`GiftUISemanticCore` owns the exact five-case `SemanticRenderScope` and the
package-only `SemanticRenderView` consumer contract. The source imports only
`GiftUI`, retains the existing one-way dependency edge, and contains no
concrete storage, rendering behavior, layout/lowering/backend coupling, or
second identity domain.

A direct fixture view proves the exact root and scope count, all scope values,
source child order, transparent render-only mappings onto an existing layout
identity, and distinct structural/text/clip identity mappings. Unknown
identities and every out-of-range child lookup return `nil`. This task exposes
only the consumer view; the production adapter from the complete SPEC-006
result remains assigned to T2.2 and waits for SPEC-006 and SPEC-007.

Reproduce from the repository root:

```text
swift test --filter SemanticRenderViewTests
scripts/contracts/check-spec-008-semantic-render-view.rb
swift package dump-package | scripts/contracts/check-target-dependencies.rb
```

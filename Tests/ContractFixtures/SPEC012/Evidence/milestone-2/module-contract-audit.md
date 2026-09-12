# SPEC-012 Module Contract Audit

Plan task: `SPEC-012 T2.5`

The registered audit verifies the exact `GiftUIDrawing` and
`GiftUIRenderCore` dependency edges against SPEC-002's package graph and their
actual source imports. It proves that Render Core and backend/raster/platform/
driver targets do not import `GiftUIDrawing`.

The source ownership scan finds exactly one declaration owner for `Canvas`,
the stroke header/view/range/sink family, and the drawing summary/error/result
family. It also rejects a `visitCanvas` traversal category, a second
`CanvasIdentity`, and Canvas-specific semantic graph/node types, preserving
SPEC-006's generic payload and identity path.

The macOS dynamic/static, Raspberry Pi ARMv6, and nRF52840 Embedded Swift
package interfaces all preserve:

```text
mutating func straightLineStroke<Stroke>(_ stroke: borrowing Stroke) -> Swift.Bool where Stroke : GiftUIRenderCore.StraightLineStrokeView
```

The same interfaces place the stroke consumer types only in Render Core and
the plan result types only in Drawing. Reproduce the source audit directly or
run any profile value probe, which invokes the interface audit:

```text
scripts/contracts/check-spec-012-module-contract.rb
scripts/contracts/check-spec-012-value-profiles.sh --profile <profile>
```

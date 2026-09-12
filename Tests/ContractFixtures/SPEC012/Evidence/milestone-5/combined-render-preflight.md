# SPEC-012 T5.1 Combined Render Preflight Evidence

The production `RenderProducer` ordinary entry point and the new extended
entry point share one private preflight traversal. The ordinary path supplies a
zero-operation extension, so the complete pre-existing SPEC-008 lowering test
corpus remains unchanged. The extension is called after each scope's local
ordinary operation and before its children with the semantic identity,
resolved bounds, and inherited logical clip.

`CanvasRenderProducer.preflight` delegates to that entry point and performs no
independent recursion or sink access. The focused Canvas fixture records:

- a combined header containing one background fill and one stroke;
- one workspace acquire/reset pair and active-workspace reentry rejection;
- checked combined-operation and configured-capacity first-excess failure;
- exact Canvas identity, positive width, surface origin, inherited clip,
  complete points, gap-free subpaths, and exclusive-upper-bound validation;
- exact Canvas, stroke, point, subpath, and normalized-operation summary
  equality; and
- fail-closed `.invariantViolation` for fourteen independently malformed plan
  views, with no partial header.

Reproduce the focused evidence with:

```sh
swift test --filter canvasPreflight
swift test --filter GiftUIRenderLoweringTests
scripts/contracts/check-spec-012-module-contract.rb
swift package dump-package | scripts/contracts/check-target-dependencies.rb
```

These are host tests. They make no Raspberry Pi, nRF52840, allocation, backend,
or connected-hardware claim; those remain assigned to later plan tasks.

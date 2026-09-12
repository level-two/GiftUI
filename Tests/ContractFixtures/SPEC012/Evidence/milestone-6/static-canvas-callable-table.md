# SPEC-012 T6.2 Static Canvas Callable Table Evidence

`GiftUIDrawing` owns the exact amended `StaticCanvasCallableTable` declaration.
The checked generated fixture consumes `static-canvas-manifest.yaml` and emits
three dense direct switch cases:

| ID | expression | capture bytes | observed stroke |
|---:|---|---:|---|
| 1 | grid | 8 | gray, width 1, `(0,0)` to `(40,0)` |
| 2 | trace | 12 | occurrence-owned blue and green offsets/levels |
| 3 | marker | 0 | white, width 1, `(40,0)` to `(40,24)` |

The capture record sizes are exactly 8, 12, and 0 bytes. The common inline
storage is 12 bytes, equal to the greatest case rather than the 20-byte sum.
The table receives that storage as a borrow and reads only the scalar fields
needed by the selected body. It has no collection, escaping closure, retained
closure fallback, whole-storage copy, or default dispatch to client code.

The focused runtime fixture invokes four occurrence-owned records in source
order. The two ID-2 occurrences preserve distinct blue/green captured values.
Each invocation uses the exact `GraphicsContext.withPath` two-`inout`, `Size`,
and `throws(DrawingError)` shape. The occurrence owner invalidates its sole
logical capture record once after success or `.invalidValue`; a later call
fails `.invalidScope` and does not release twice.

Reproduce the host evidence with:

```sh
scripts/contracts/check-spec-012-static-canvas-manifest.rb
scripts/contracts/check-spec-012-module-contract.rb
swift test --filter generatedStaticCanvas
```

Cross-profile generated integration, allocation/symbol inspection, production
limits, and host handles remain T6.3-T6.5/SPEC-013/SPEC-015 work. This evidence
makes no nRF board, Raspberry Pi deployment, or connected-hardware claim.

# SPEC-012 Static Canvas Callable Table Specification Blocker

Plan task: `SPEC-012 T6.2`

T6.2 cannot implement the approved `StaticCanvasCallableTable` declaration
with the pinned Apple Swift 6.3.3 compiler. Compiling the exact associated-type
requirement produces:

```text
error: cannot suppress 'Copyable' requirement of an associated type
associatedtype CaptureStorage: ~Copyable
                               ^
```

The failure occurs while emitting `GiftUIDrawing`, before any generated table
conformance or fixture code is type-checked. The same declaration is normative
in SPEC-012's `Types / APIs` section, so replacing it with an implicitly
`Copyable` associated type would change the approved capture-storage contract.

The affected task is paused for Specification review. T6.2-T6.5 cannot claim
the required noncopyable generated capture storage, dispatch, destruction, or
profile integration until the contract supplies a source shape accepted by
all pinned compilers. T6.1's descriptor and checked manifest remain valid and
independent of this declaration failure.

Reproduce from the repository root by temporarily adding the exact declaration
to `GiftUIDrawing` and running:

```text
swift test --filter StaticCanvas
```

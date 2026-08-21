# SPIKE-003 experiment design

This directory contains disposable feasibility evidence for SPIKE-003. Its
types, generated bridges, capacities, field widths, and source spelling are
not production proposals.

## Candidate matrix (frozen before implementation)

| ID | Representation | Mutation instrumentation | Expected evidence |
| --- | --- | --- | --- |
| `direct-class` | A retained Swift `class` instance | Explicit model-owned setter signaling | Host semantic control plus an Embedded Swift compile/link attempt that reveals allocator/runtime dependencies |
| `generated-handle` | A copied typed handle naming address-stable generated storage | Explicit generated setters synchronously report through one bounded registration | Shared host semantics and a zero-heap Embedded Swift image with the same portable `@State` source shape |

No third candidate will be added unless both selected candidates fail for
different remediable reasons and the Spike bounds are revised explicitly.

## Portable declaration boundary

Both candidate fixtures use this source-level shape:

```swift
struct PortableFixture {
    @State var model: ObservableModel
}
```

The generated-handle candidate copies a small typed value, but every copy
addresses one generated model slot; copying it does not copy model state. The
setter boundary is explicit and model-owned. Portable presentation code does
not call a runtime invalidation API.

## Measurements

`run.sh` runs one semantic driver against dynamic class-backed and static
typed-handle profiles, attempts the direct-class Embedded image, builds
comparable generated-handle baseline and candidate images, inspects linked
symbols and ABI attributes, and emits stable evidence under
`.build/nrf52840/spike-003-*/reports/spike-003/`.

The host driver covers preservation, coalescing, admitted external facts,
replacement, published removal, stale-token rejection, failed derivation,
duplicate ownership, and independent state/registration exhaustion. Embedded
images exercise initialization, attach, 20 coalesced reports, replacement,
detach, and stale-report rejection in linker-visible code.


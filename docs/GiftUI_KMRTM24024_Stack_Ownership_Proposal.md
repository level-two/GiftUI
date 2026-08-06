# GiftUI KMRTM24024 Stack Ownership Proposal

**Status:** Proposed permanent fix
**Scope:** `GiftUIRuntimeStatic`, `GiftUIBackendRGB565`, and the
`kmrtm24024_spi` nRF52840 application
**Immediate mitigation:** 144 KiB main stack pending this work

## 1. Problem statement

The connected nRF52840-DK run found that
`giftui_swift_display_application_run` reserves approximately 27,128 bytes in
one stack frame. The firmware's 24 KiB main stack cannot contain that frame.
The stack pointer jumps below the Zephyr MPU guard, later calls overwrite the
NRFX SPIM control block, and the SPI completion interrupt faults while
deasserting chip select. The visible symptoms are a white display and LCD CS
remaining low indefinitely.

The frame is large because fixed-capacity values with substantial inline
storage coexist in one function:

- `StaticGraphBuilder`, `StaticLayoutArena`, `StaticLayoutResult`, and
  `StaticLayout` contain one or more 64-node inline stores;
- `RGB565TileRenderer` contains a 3,840-byte inline pixel tile;
- value returns, enum payloads, closure captures, and temporary copies extend
  or overlap those values' stack lifetimes.

Zephyr already enables `CONFIG_HW_STACK_PROTECTION` and
`CONFIG_MPU_STACK_GUARD`. They did not prevent corruption because the function
prologue subtracts the large frame in one step and does not access the guard
region before nested calls begin below it. Stack protection remains useful,
but it cannot be the primary bound for large Embedded Swift frames.

## 2. Goals

- Keep the firmware heap-free and deterministic.
- Preserve the public rendering and layout semantics used by host tests.
- Give each large fixed-capacity buffer one explicit, long-lived owner.
- Prevent builder-to-arena-to-layout copies of the 64-node store.
- Keep ordinary Swift call frames small enough for a deliberately sized main
  stack with at least 25% measured worst-case margin.
- Fail the build when a critical firmware entry point regresses beyond its
  accepted frame budget.
- Preserve synchronous SPI transactions and the existing four-row RGB565
  tile bound.

## 3. Proposed design

### 3.1 Caller-owned static runtime workspace

Add an Embedded-oriented `StaticRuntimeWorkspace` that owns the node, parent,
and hit-region stores. The nRF application creates exactly one workspace in
static storage. `StaticRuntime` builds and lays out the graph in that same
workspace instead of successively materializing a builder, arena, result enum,
and snapshot that each carry inline storage.

Expose a scoped API equivalent to:

```swift
runtime.withLayout(
    content,
    in: surfaceSize,
    using: &runtimeWorkspace
) { layout in
    // Read-only layout access is valid only for this scope.
}
```

The scoped layout handle contains counts and an exclusive borrow of the
workspace rather than a copy of its node array. Capacity failures remain typed
and deterministic. The host implementation may retain its convenient
value-based storage internally, but both profiles must run the same layout and
rendering contract tests.

### 3.2 Caller-owned RGB565 tile workspace

Separate the 3,840-byte pixel array from `RGB565TileRenderer`. Add a fixed
`RGB565TileWorkspace` and initialize the renderer with an exclusive borrow:

```swift
var renderer = RGB565TileRenderer(
    configuration: configuration,
    workspace: &tileWorkspace
)
```

The nRF application owns one tile workspace in static storage. The renderer
keeps only configuration, active bounds, and a scoped pointer/borrow. Existing
byte-capacity validation remains unchanged.

### 3.3 Firmware-owned workspace and narrow phases

The firmware application owns one runtime workspace and one tile workspace in
`.bss`. Its entry point is split into narrow, non-inlined phases:

1. validate and blank the display;
2. build/layout using the runtime workspace;
3. render/present using the tile workspace while borrowing the layout;
4. unblank and report measurements;
5. enter the idle loop.

Mark the phase boundaries `@inline(never)` where necessary so optimization
cannot merge all fixed storage back into one frame. No phase may contain two
full node stores or copy a tile workspace.

Static workspace ownership is single-threaded and application-local. It must
not be exposed through an unsafe global mutable API to general GiftUI clients.

## 4. Stack-safety enforcement

Add a post-link report/check for critical symbols, beginning with
`giftui_swift_display_application_run` and the layout/render phases. The check
must derive frame size from supported compiler output when available; a
documented disassembly check is an acceptable pinned-toolchain fallback.

Initial acceptance budgets:

- no individual critical Swift frame larger than 4 KiB;
- no call path used during initial render with more than 12 KiB measured
  main-stack high-water;
- at least 25% unused main stack after cold boot, full render, repeated render,
  error paths, and maximum-capacity layout tests.

Keep MPU stack guarding enabled. Also investigate pinned Swift/LLVM stack
probing for large frames; enable it only after the ARMv7E-M output and runtime
cost are verified. Frame-size checks remain required even if probing is added.

## 5. Implementation sequence

1. Add size/frame regression tests and record the current 27,128-byte failure
   as the baseline the new implementation must eliminate.
2. Introduce `RGB565TileWorkspace` and migrate renderer tests without changing
   rendered bytes or tile boundaries.
3. Introduce `StaticRuntimeWorkspace` and in-place graph/layout mutation.
4. Add the scoped layout API and prove the layout handle cannot outlive its
   workspace borrow.
5. Move both workspaces to application-owned static storage and split the
   firmware entry point into non-inlined phases.
6. Add the post-link frame-size gate to `scripts/nrf52840/build.sh` reports.
7. Reduce `CONFIG_MAIN_STACK_SIZE` from the temporary value only after
   connected-board high-water measurements meet the 25% margin requirement.

## 6. Verification and acceptance

The permanent fix is accepted when:

- all existing Swift package tests pass;
- new maximum-capacity runtime and renderer-workspace tests pass;
- the nRF build retains heap-disabled checks, ARMv7E-M, and VFP calling
  convention verification;
- the post-link report shows every critical frame within budget;
- UART reaches initial-frame completion without a fault;
- LCD CS returns high after every transaction and remains high while idle;
- the thermostat is visibly rendered after at least 20 resets and 20 complete
  frame transfers;
- measured worst-case main-stack usage retains at least 25% margin;
- generated RAM remains below the repository's 192 KiB limit.

## 7. Temporary mitigation and removal condition

Use a 144 KiB main stack for connected-hardware validation while the ownership
work is pending. Hardware trials at 36 KiB and 56 KiB still overflowed. A
128 KiB diagnostic build completed the initial frame and measured 107,916 bytes
of peak main-stack use, so 144 KiB retains 26.8% headroom. The larger value is a
mitigation, not the permanent resolution: it leaves the oversized frame and
copy behavior intact. Remove or reduce the temporary increase only after the
workspace design, frame-size gate, and connected-board stack measurements
satisfy Section 6.

# SPEC-012 Declaration Profile Compilation Evidence

Plan task: `SPEC-012 T1.5`

The profile-aware declaration checker compiles the maintained `GiftUI` public
drawing surface and all sixteen registered positive/negative witnesses with
the pinned compiler, target, SDK, optimization, and profile condition for
macOS dynamic, macOS static, Raspberry Pi ARMv6, and nRF52840 Embedded Swift.
Each run records the emitted module/interface, per-fixture diagnostics, client
SIL, undefined symbols, a configuration-equivalent baseline, and exact command
transcript. ARMv6 and nRF52840 runs are hardware-free cross-build and
inspection evidence only.

The emitted interfaces preserve concrete `throws(DrawingError)`, noncopyable
`GraphicsContext` and `Path`, non-public construction, and the exact Canvas,
style, and error surface. Dynamic macOS and ARMv6 interfaces contain the
private Canvas closure layout required until invocation. Static macOS and
nRF52840 interfaces contain no stored Canvas closure; production generated
callable IDs and capture storage remain T6/SPEC-013 work.

The positive fixtures cover defaults, both stroke overloads, explicit typed
trailing closures, stroke-mutate-stroke reuse, multiple subpaths, and concrete
error propagation. The negative fixtures reject construction, copying,
borrowed consumption, synchronous/asynchronous escape, untyped or wrong error
types, and captured outer-context overlap with their registered diagnostics.
The two optimizer-owned ownership/exclusivity diagnostics compile with the
maintained declarations in one optimized module, matching SPIKE-008; all other
fixtures consume the emitted module.

Client SIL and undefined-symbol audits compare each drawing witness with a
configuration-equivalent baseline. No drawing-introduced `any Error`,
allocator, reflection, task, Objective-C, or C++ exception-runtime artifact is
accepted. Embedded Swift's own allocator/error support definitions are present
in both SIL inputs and therefore cannot be misreported as drawing-introduced.

Reproduce from the repository root:

```text
scripts/contracts/check-spec-012-declarations.sh --profile macos-dynamic
scripts/contracts/check-spec-012-declarations.sh --profile macos-static
scripts/contracts/check-spec-012-declarations.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-012-declarations.sh --profile nrf52840-embedded
```

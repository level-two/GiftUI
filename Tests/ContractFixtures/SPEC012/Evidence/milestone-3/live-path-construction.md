# SPEC-012 Live Path Construction Evidence

Plan task: `SPEC-012 T3.3`

`GiftUIDrawing.LivePathBuilder` implements the profile-neutral live Path state
machine over caller-owned bounded storage. The engine checks arithmetic and
both independent capacities before asking storage to commit an atomic first
subpath, replacement move, later subpath, or line operation.

The same corpus runs against dynamic array-backed and fixed tuple-backed
storage and produces identical points and explicit `SubpathRange` values. It
covers consecutive-move replacement, move after a completed segment,
zero-length segment preservation, multiple subpaths, exact point/subpath
limits, line without a current point, first point excess, first subpath excess,
nil out-of-range access, and reset. A captured pre-mutation transcript proves
later path mutation does not alter earlier observed geometry; T3.4 applies
that property to immutable stroke snapshots.

The public `GraphicsContext.withPath` fixture also rejects nested acquisition
as `.reentrancyViolation`, keeps the outer Path active, and resets live totals
on both normal and throwing exits.

Reproduce from the repository root:

```text
swift test --filter PathConstructionTests
swift test --filter DrawingSurfaceTests
scripts/contracts/check-spec-012-module-contract.rb
scripts/contracts/check-spec-012-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-012-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-012-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-012-value-profiles.sh --profile nrf52840-embedded
```

All four optimized profile compilers accept the same generic construction
engine, including the static Embedded Swift profile.

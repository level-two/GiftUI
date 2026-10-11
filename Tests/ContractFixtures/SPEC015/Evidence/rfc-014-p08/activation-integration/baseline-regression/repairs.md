# Baseline regression narrowed repairs — 2026-10-12

## Repair 1 — explicit SwiftPM native build backend

Initial P02 macos-dynamic rebuild succeeded with Swift 6.4, but its default
Swift Build backend emits `out/Products/Debug` instead of the existing native
`plugin-tools-description.json` consumed by the regression driver. The driver
then failed before macro fixture compilation. Exact failure and build log remain
under `.build/contracts/spec-006-rfc-014-swift64/acd84ab87aa5533f-8rzbzfko/macos-dynamic`.

Select `--build-system native` explicitly for the host macro build, preserving the
existing driver's artifact/SwiftSyntax description contract. This is a build
backend selection correction, not a source, schema or lifetime change. One of
two narrowed repairs used; productive: all four registered P02 routes now pass,
including their existing P04 component checks. P01's 17 controls pass. No second
P02 repair was needed. `p02-receipts.json` records the successful output paths,
input freshness and compiler/macro identities; `p02-initial-macro-build.log`
freezes the initial successful macro build preceding the metadata-layout failure.

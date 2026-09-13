# SPEC-014 T6.4 Borrow Lifetime and Storage Evidence

Date: 2026-09-13

The glyph raster API separates one-time identity, metrics, record, geometry,
and payload validation from repeated tile-local coverage. One nonescaping
`withPayload` body encloses the complete operation-major traversal, so a glyph
crossing two tiles records exactly one metrics request, one record request,
and one payload borrow. The resource fixture poisons its payload immediately
after that body and the submitted owned RGB565 bytes remain exact.

A one-shot producer harness records one producer invocation and one borrowed
fill call while the integration performs three raster/consumer tile visits.
Every visit observes the same workspace address. Immediately after each
synchronous submission the test overwrites the active workspace; previously
submitted target-owned bytes remain unchanged.

The registered storage audit now also scans the three tiled production sources
and rejects ownership-bearing arrays, collections, unsafe pointers, producer
storage, or a class-owned workspace. Production storage remains caller-owned,
generic, fixed, and bounded; closures are nonescaping and tile access is an
exclusive inout borrow.

Run from the repository root:

```sh
scripts/contracts/check-spec-014-storage.rb
swift test --filter oneShotProducerAndBorrowedOperation
swift test --filter tiledFillAndExactGlyph
swift test --filter glyphCoverage
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-014-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-014-value-profiles.sh --profile nrf52840-embedded
```

All audits, focused tests, and profile compilations pass.

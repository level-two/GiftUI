---
related_future_work:
  - FW-027
---

# Pi performance investigation closeout — 2026-09-30

The maintainer stopped performance experiments and requested integration of
useful changes that preserve contracts and architecture into
`feature/mvp-implementation`. Integration starts from `1e22e0a5` and selects
compatible implementation from `feature/pi-cold-frame-path` at `9251510b`.
The Signal Analyzer remains in implementation; no Specification is marked
implemented and no architecture or acceptance criterion changes.

## Retained implementation

- Dynamic semantic publication constructs bounded child/modifier lookups once,
  sorts occurrence order once, and clears those lookups on replacement or
  discard. Dynamic layout indexes scopes within the existing scope bound.
- The application removes its duplicate layout validation pass; `layout()`
  still performs the required validation before measurement/publication.
- RGB565 emission scans only affected bounds and row runs, calculates checked
  byte offsets once per run, and uses paired pixel reads/writes. Default
  protocol witnesses preserve existing storage/writer implementations.
- Raster coverage retains exact orthogonal and segment-bound optimizations;
  all static profiles keep their allocation-free fallback. The original
  optimization excluded only Embedded Swift; integration restricts its row
  buffer to the dynamic profile to preserve SPEC-013/SPEC-014 zero-heap rules.
- Pi framebuffer projection maps each region once and copies identical covered
  rows. It retains the working branch's aspect-fit mapping, byte order,
  ordered overlap, payload reservation, and transfer/failure protocol.

The integration also carries the existing direct-import dependency declarations
and application-owner boundary registrations from the source branch. These
register already maintained imports, rather than introducing new module edges.
The render-view forwarding check now tolerates formatter whitespace while
requiring the same sole `storage.renderView` body.

These are replaceable internal realizations under accepted ADR-005, ADR-006,
ADR-010, and ADR-032 and approved SPEC-007, SPEC-008, SPEC-013, and SPEC-014.
They add no full framebuffer, operation replay, or cross-frame result cache.
The feature manifest continues to register implementation in progress.

## Excluded and preserved

The older responsive application/layout merge overlaps the working branch's
newer compact 320 x 240 nRF target and reviewed pixels. Its sources, contract
revision, and evidence remain on `feature/responsive-analyzer-layout` and the
original Pi branches; they are not integrated by this closeout. The working
branch's approved nRF display contracts, firmware, portable composition, and
fixture references remain the integration baseline.

The complete physical-surface prototype remains only on
`feature/pi-cold-full-surface-experiment`. It adds a 307,200-byte buffer and
bypasses selected endpoint behavior, so it is excluded under
[FW-026](../../../../../docs/future-work/fw-026-pi-complete-physical-surface-presentation.md).
The rejected packed projection and row-buffer trials are not adopted.
Temporary semantic and phase timers are excluded. Historical measurements are
preserved as evidence, not an assertion of current-layout timing or pixels.

## Remaining performance and conformance gap

[Timer-free semantic measurements](pi-cold-semantic-sort-once-20260928.md)
record approximately 1.56-second complete frame service, well above 250 ms.
The retained implementation does not establish the cadence criterion or
complete physical six-control validation. Postponement is not a waiver;
SPEC-001 tasks and acceptance criteria remain open. No remote deployment,
service restart, connected run, or board flash is part of this integration.

[FW-027](../../../../../docs/future-work/fw-027-pi-performance-investigation-resumption.md)
records the restart trigger: remaining MVP functionality is ready for
integrated conformance review and Pi cadence blocks completion, or the
maintainer explicitly reprioritizes responsiveness. Partial frames and
cross-frame reuse remain separate non-authoritative FW-024/FW-025 directions.

## Integration validation

The formatter, governance/authority graph, and root suite pass: 298 XCTest
cases and 1,138 Swift Testing tests. Final focused runtime/raster validation
passes 92 Swift Testing tests, including semantic replacement, ordered
framebuffer row projection, exact canonical stroke pixels/bytes, partial tiles,
and worst-case tile resource bounds. Both SPEC-013 static compiler probes pass.
The final standalone SPEC-007 boundary and migration checks and SPEC-008
borrowed-render-view boundary check pass after the retained tooling fixes.

`scripts/test.sh all-hardware-free` completed all 72 checks: 25 passed and 47
failed in the first integration run. The [machine results](pi-performance-closeout-gate-20260930.tsv)
preserve that non-green result. Some failures precede the final dependency and
formatter-check fixes; those checks were rerun separately. The broad gate is
not represented as passing. Its remaining failures include stale consumer and
migration ledgers, stale text-generator identity, an invalid capability
resolver fixture, the action-generation allocator audit, active backend
conformance, and missing locked Pi/nRF pixel references. Several cheap failures
were reproduced against an archived `1e22e0a5` baseline: SPEC-003 direct Failure
Core consumer mismatch, SPEC-005 generator identity, SPEC-006 maintained Pi
migration entry, SPEC-011 allocator count, and SPEC-014 migration/conformance.
The capability fixture and backend module inventories are unchanged by the
selected runtime/raster implementation. These require separate MVP conformance
work; the closeout does not waive them or change expected results.

The working baseline `1e22e0a5` has no locked
`Tests/ContractFixtures/SPEC001/PixelReferences` RGB565 files. T7.7/T7.9
therefore remain blocked on independent review. No expected pixels are
regenerated or approved to make the integration pass. Host-native tests and
compiler probes do not establish connected hardware conformance.

Local reports: `.build/test-reports/all-hardware-free/`,
`.build/pi-performance-closeout-focused.log`, and
`.build/pi-performance-closeout-governance.log`. The integration is validated
as a dirty source selection based on `1e22e0a5`; driver metadata preserves that
boundary. No code or expected result changes follow the final focused check.

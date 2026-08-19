---
id: SPIKE-001
feature: capability-system
title: Tiled One-Shot Stream and Capability Compatibility Fixtures
status: planned
authors:
  - Yauheni Lychkouski
created: 2026-08-19
updated: 2026-08-19
source:
  - RFC-006
related_future_work:
  - FW-014
  - FW-015
related_explorations: []
related_spikes:
  - SPIKE-002
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPIKE-001: Tiled One-Shot Stream and Capability Compatibility Fixtures

> This Spike produces feasibility evidence for RFC-006. Its types, names,
> storage layout, diagnostics, and prototype code are disposable and do not
> establish production architecture or an implementation contract.

## Parent Gate

RFC-006 cannot advance until normalized positive and negative fixtures show
that:

1. a first-party-style RGB565 tiled path can consume RFC-004's synchronous
   borrowed operation stream exactly once without retaining or replaying it;
2. incompatible canonical pixel encodings are rejected independently; and
3. incompatible downstream submission lifetimes are rejected independently.

The Spike feeds its evidence only to RFC-006 and, for the operation-delivery
meaning, RFC-004 review. It does not approve either RFC.

## Target Questions

1. Can a bounded RGB565 tiled raster prototype produce the required normalized
   opaque rendering result while traversing a borrowed operation stream only
   once?
2. Can the prototype finish or reserve all backend-owned derived work before
   the synchronous offer returns, retaining no operation or stream reference?
3. Can one closed, deterministic `rasterPresentation` resolver accept the
   normalized Raspberry Pi and nRF52840 tiled configurations?
4. With every unrelated input held compatible, does the resolver reject an
   empty producer/display pixel-encoding intersection for that reason alone?
5. With every unrelated input held compatible, does the resolver reject a
   producer/display submission-lifetime mismatch for that reason alone?
6. Are all positive and negative results independent of contributor order?

## Required Minimal Experiment Code

Place all disposable code under:

`experiments/spike-001-tiled-one-shot-capability-fixtures/`

The experiment MUST contain only the following minimum pieces.

### 1. Closed fixture vocabulary

Define experiment-local, fixed-shape values sufficient to express:

- required operation-set identity;
- logical extent;
- canonical pixel encoding, containing at least `rgb565` and one deliberately
  incompatible encoding;
- produced-buffer lifetime;
- accepted submission lifetime;
- handoff form and maximum in-flight submissions;
- raster workspace and tile-buffer bounds; and
- one available result or a stable unavailable reason.

The vocabulary MUST NOT use strings, reflection, discovery, a heterogeneous
registry, target identity, backend identity, or production GiftUI public API.
It MUST model only the RFC-006 `rasterPresentation` family.

### 2. Pure bounded resolver

Implement one experiment-local resolver over fixed records. It MUST:

- validate the required operation-set and one-shot delivery form;
- compute the producer/display pixel-encoding intersection;
- validate produced-buffer and accepted-submission lifetime compatibility;
- validate extent, tile workspace, storage, and in-flight bounds;
- return one normalized available result or one stable unavailable reason;
- reject malformed or duplicate single-owner contributions deterministically;
  and
- return the same result for every tested permutation of contributor order.

The resolver need not establish final Swift API, field widths, diagnostics, or
provenance representation.

### 3. Borrowed one-shot operation source

Implement a test source with an observable lease and traversal counter. It
MUST:

- expose the minimum normalized operation sequence needed to cover opaque
  clear/fill, rectangle stroke, positioned bitmap text, clipping, and damage;
- permit at most one traversal;
- invalidate the lease when the synchronous offer returns;
- fail the test on a second traversal or any access through the expired lease;
  and
- report the number of yielded operations.

The operation sequence and expected pixel result MUST be fixed fixture data,
not generated randomly.

### 4. One-shot RGB565 tiled prototype

Implement the smallest bounded tiled prototype capable of consuming the test
source. The experiment MAY choose operation-major synchronous submission,
bounded backend-owned derived work, or another bounded mechanism, but it MUST
not weaken the test source.

The prototype MUST:

- traverse the offered operation stream exactly once;
- use no full-surface pixel framebuffer;
- keep raster/display staging at or below 16 KiB;
- use a maximum nRF52840 fixture tile of `480 * 4 * 2 = 3,840` bytes;
- complete or reserve all backend-owned derived work before `offer` returns;
- retain no borrowed stream, operation, iterator, closure, or lease afterward;
- submit only derived RGB565 pixel/tile/transfer data after consumption; and
- produce a deterministic final pixel image through a fake synchronous
  surface used only as a test oracle.

The existing production `RGB565TileRenderer` MUST NOT be silently changed for
this Spike. Its drawing closure is currently invoked once per tile. The Spike
must either demonstrate a distinct bounded technique or report that the RFC's
one-shot direction was not shown feasible.

### 5. Fixture test executable

Provide one host test executable or Swift test target that runs all required
fixtures and exits nonzero on any failed assertion. It MUST emit a compact
machine-readable or stable text result table containing fixture ID, expected
result, actual result, stream traversal count, retained-lease check, and tile
storage high-water mark.

## Required Fixtures

| ID | Deliberate condition | All other relevant inputs | Required result |
| --- | --- | --- | --- |
| `TILED-PI-POS` | Raspberry Pi RGB565 tiled path | Compatible | Available; one stream traversal |
| `TILED-NRF-POS` | nRF52840 RGB565 tile, synchronous borrowed submission, 3,840-byte tile | Compatible | Available; one stream traversal and no retained lease |
| `ENCODING-NEG` | Producer offers only RGB565; display accepts only the incompatible encoding | Compatible, including lifetime | Unavailable: no common canonical pixel encoding |
| `LIFETIME-NEG` | Producer storage expires on return; display requires retained asynchronous borrowing | Compatible, including RGB565 | Unavailable: incompatible downstream submission lifetime |
| `ENCODING-CONTROL` | Common RGB565 restored | Same as `ENCODING-NEG` otherwise | Available |
| `LIFETIME-CONTROL` | Synchronous borrowing or compatible copy/ownership restored | Same as `LIFETIME-NEG` otherwise | Available |

Every fixture MUST be run with at least the canonical contributor order and
its reverse. The two negative fixtures SHOULD run all permutations if the
fixed contributor count keeps that test small.

The negative fixtures MUST differ from their controls in exactly the named
compatibility dimension. A generic `unavailable` result is insufficient; the
stable reason must identify the independently failing dimension.

## Reference-Image Check

The positive tiled execution MUST be compared with an independent expected
pixel image or a simple non-tiled reference rasterizer. Comparison MUST cover:

- every pixel in the normalized damaged region;
- tile boundaries;
- operation ordering where later opaque drawing overwrites earlier drawing;
  and
- the first and final partial tile where applicable.

The reference oracle may allocate on the host. Such allocation is outside the
prototype and MUST NOT be presented as evidence about embedded memory use.

## Bounds / Stop Conditions

- Do not add a production target or public API.
- Do not implement a generalized Trait, capability, registry, or optimizer
  framework.
- Do not modify RFC-004 or RFC-006 semantics merely to make the test pass.
- Do not use connected Raspberry Pi or nRF52840 hardware; this Spike is a
  normalized host/cross-platform semantic fixture.
- Stop after the six required fixtures, permutation checks, and reference-image
  comparison pass or produce a reproducible failure.
- Stop and report an inconclusive or negative result if conformance requires a
  second stream traversal, retention of borrowed operations, a full-surface
  framebuffer, more than 16 KiB staging, or an unbounded derived-work store.

## Method

1. Record the exact fixture values and expected outcomes before implementing
   the resolver or tiled prototype.
2. Run the negative and control pairs against the pure resolver.
3. Offer the fixed operation stream once to the bounded tiled prototype.
4. Poison the stream lease immediately when the offer returns.
5. Complete any permitted derived-data submission and compare the final image
   with the reference image.
6. Repeat resolution with contributor-order permutations.
7. Preserve commands, compiler version, logs, and the stable result table.

## Reproduction

The completed experiment MUST document:

- host OS and architecture;
- Swift compiler version and build configuration;
- exact command from the repository root;
- exact fixture source revision;
- whether optimization is enabled; and
- paths to the result table and any reference/actual pixel dumps.

The preferred single entry point is:

```text
experiments/spike-001-tiled-one-shot-capability-fixtures/run.sh
```

The script is part of disposable Spike infrastructure. It MUST run without
network access and MUST place generated results under the experiment directory
or `.build/`, not under production source directories.

## Success Criteria

This Spike answers RFC-006's fixture gate positively only if all of the
following are true:

- both positive tiled fixtures resolve available;
- the operation source traversal count is exactly one per offered frame;
- expired-lease instrumentation observes no post-offer operation access;
- the actual and reference pixel images match;
- staging remains within the stated bounds and no full framebuffer is used;
- `ENCODING-NEG` fails only for pixel encoding and its control succeeds;
- `LIFETIME-NEG` fails only for submission lifetime and its control succeeds;
  and
- contributor ordering changes no normalized result or stable reason.

Passing these criteria is feasibility evidence, not approval of the candidate
representation or permission to copy it into production.

## Failure Routing

- If tiled rendering requires operation replay or retention, return the common
  delivery decision to coordinated RFC-004/RFC-006 review. FW-014 remains the
  existing place for a possible future replayable delivery mode.
- If encoding or lifetime cannot be rejected independently, return RFC-006's
  resolver-input and ownership model to review. FW-015 does not authorize
  removing either input from the MVP resolver.
- If only the experiment representation is awkward but all semantic criteria
  pass, record that limitation for later Specification work without treating it
  as an architectural failure.

## Results

Not run. This Spike is planned.

When executed, record the result table, storage high-water marks, operation
counts, image comparison, and any failed invariant here or in a versioned
evidence file linked from this section.

## Limitations

- Host execution does not prove nRF52840 RAM, stack, flash, initialization
  work, or allocator independence; SPIKE-002 owns that evidence.
- A fake synchronous surface proves the selected lifetime semantics, not
  electrical behavior, display-controller correctness, or connected hardware.
- Experiment-local names and layouts are not suitable for a public API review.

## Disposition

Planned. On completion, feed the evidence and limitations into RFC-006 and the
compatible operation-stream findings into RFC-004 review. Do not promote or
reuse the experiment code directly.

## References

- [RFC-006: GiftUI Capability System Architecture](../rfcs/rfc-006-capability-system-architecture.md)
- [RFC-004: Run Cycle and Frame Transaction](../rfcs/rfc-004-run-cycle-and-frame-transaction.md)
- [FW-014: Replayable Operation Delivery](../future-work/fw-014-replayable-operation-delivery.md)
- [FW-015: Capability Resolver Input Minimization](../future-work/fw-015-capability-resolver-input-minimization.md)
- [SPIKE-002: nRF52840 Capability-Path Resource Evidence](spike-002-nrf52840-capability-path-resource-evidence.md)

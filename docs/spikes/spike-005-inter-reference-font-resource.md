---
id: SPIKE-005
feature: giftui-mvp-architecture
title: Licensed Inter Reference Font Resource
status: completed
authors:
  - Yauheni Lychkouski
created: 2026-08-25
updated: 2026-08-25
source:
  - SPEC-005
related_future_work: []
related_explorations: []
related_spikes: []
promoted_to: []
supersedes: []
superseded_by: []
target_milestone: MVP
---

# SPIKE-005: Licensed Inter Reference Font Resource

> This Spike produces source, licensing, derivation, integrity, and resource
> evidence for SPEC-005. Its manifest serialization, outline encoding,
> generator, validator, and firmware fixtures are disposable and do not define
> production architecture or authorize implementation.

## Parent Gate

SPEC-005 cannot advance to `review` until a licensed reference resource and
derived assets are checked in with provenance, reproducible generation,
integrity evidence, and measured static-resource bounds. This Spike tests
whether the official Inter 4.1 Regular release can provide that evidence
within SPEC-005's draft ceilings.

The Spike does not approve SPEC-005, resolve its separate SPEC-003
failure-origin blocker, select a production outline provider, or adopt its
disposable generated tables into a production target.

## Target Questions

1. Does a version-pinned Inter Regular source permit redistribution,
   derivation, embedding, and checked-in evidence under a documented license?
2. Does the source map every scalar in U+0020...U+007E and U+00B0, and can one
   exact replacement glyph be designated without ambient fallback?
3. Can one deterministic derivation produce a renamed subset font, canonical
   metrics and mappings, a 1-bit bitmap strike, and a per-glyph outline
   feasibility payload under one candidate resource identity?
4. Do all source and generated outputs have reproducible SHA-256 evidence?
5. Do the glyph, mapping, manifest, realization-payload, nRF52840 linked-flash,
   fixed-RAM, and validation-stack measurements fit SPEC-005's draft ceilings?

## Bounds / Stop Conditions

- Use only official Inter release 4.1 member
  `extras/ttf/Inter-Regular.ttf`, SHA-256
  `40d692fce188e4471e2b3cba937be967878f631ad3ebbbdcd587687c7ebe0c82`.
- Generate one Regular instance at 16 pixels and exactly the 96 required
  scalar mappings. Do not add font fallback, shaping, kerning, ligatures,
  extra weights, runtime registration, or public text styles.
- Use `.notdef` as glyph zero and as the designated exact replacement glyph.
- Keep all disposable inputs, generators, outputs, and reports under
  `experiments/spike-005-inter-reference-font/`.
- Limit firmware work to hardware-free builds for `nrf52840dk/nrf52840`; do
  not flash or operate a connected board.
- Stop with a negative result if any checked hash, required mapping, count,
  payload, manifest, linked-flash, fixed-RAM, stack, architecture, hard-float,
  zero-heap, or deterministic-rebuild check fails.

## Method

The experiment checks in the unmodified upstream TTF and OFL 1.1 text. A
hash-pinned macOS ARM64 Python environment uses fontTools 4.60.2, Pillow
11.3.0, and its bundled FreeType 2.13.3 to:

1. verify the source hash and exact required coverage;
2. subset and rename the face to `GiftUI Reference Sans`;
3. retain the exact mapping plus required component glyphs;
4. rasterize one 16-pixel monochrome strike with MSB-first packed rows;
5. decompose the same exact glyphs into a bounded spike-only outline payload;
6. emit canonical metrics, mappings, raster records, payload digests, a
   candidate canonical manifest, and one candidate resource identity;
7. emit C constants used by a hardware-free nRF52840 digest-validation
   fixture; and
8. generate every output twice and reject any byte difference.

The nRF52840 comparison links the candidate manifest, bitmap payload, expected
SHA-256 digests, and a bounded SHA-256 validator against a configuration-
equivalent baseline. It records program-header flash/RAM totals, section
sizes, compiler stack-usage reports, ELF architecture attributes, heap
configuration, allocator-symbol absence, and host validation.

## Reproduction

From the repository root:

```text
experiments/spike-005-inter-reference-font/run.sh --verify
scripts/nrf52840/doctor.sh
experiments/spike-005-inter-reference-font/run-nrf.sh
```

The first command uses network access only to install hash-pinned generator
wheels into a temporary environment. The source font and license are already
checked in. The nRF runner uses only repository-managed toolchains and writes
transient firmware under `.build/nrf52840/`.

Stable inputs, derived assets, and evidence are under
[`experiments/spike-005-inter-reference-font/`](../../experiments/spike-005-inter-reference-font/).

## Results

### Licensing and provenance

The selected source is Inter release 4.1, published by the Inter Project
Authors under SIL Open Font License 1.1. The checked-in license permits use,
modification, embedding, and redistribution subject to its conditions. The
derivative is named `GiftUI Reference Sans`; upstream identity is retained
only as provenance and acknowledgement.

The official archive URL, archive SHA-256, archive member, source SHA-256,
copyright, license URL, derived name, exact tools, and reproduction command
are recorded in
[`PROVENANCE.json`](../../experiments/spike-005-inter-reference-font/generated/PROVENANCE.json).
The complete file digest inventory is
[`SHA256SUMS`](../../experiments/spike-005-inter-reference-font/evidence/SHA256SUMS).

### Generated package evidence

| Measurement | Result | SPEC-005 draft ceiling |
| --- | ---: | ---: |
| Required scalar mappings | 96 | 256 per instance |
| Total glyphs including component glyphs | 102 | 256 per instance |
| Source TTF | 411,640 bytes | provenance input |
| Renamed subset TTF | 20,752 bytes | evidence input |
| Candidate canonical manifest | 6,218 bytes | 16,384 bytes |
| Monochrome bitmap payload | 1,911 bytes | 65,536 bytes |
| Spike outline payload | 13,195 bytes | 65,536 bytes |

Coverage validation found no missing or unexpected mapping. The 102-glyph
count includes `.notdef` and five unencoded component glyphs needed by the
required Inter outlines. Unsupported valid scalars select glyph zero; no
ambient fallback occurs.

The candidate resource identity is:

```text
bd14de9ff2baaaf464c130d5e2d0554004a4055cc57a8c16a65fe2cc39394910
```

Two independent generation passes were byte-identical, and a subsequent
clean temporary-environment `--verify` run matched every checked-in output.

### nRF52840 resource evidence

| Measurement | Baseline | Candidate | Delta | SPEC-005 draft ceiling |
| --- | ---: | ---: | ---: | ---: |
| Linked flash bytes | 22,836 | 32,060 | 9,224 | 98,304 |
| Linked RAM bytes | 4,988 | 4,988 | 0 | 512 resource-specific |
| `bss` bytes | 1,013 | 1,013 | 0 | 512 resource-specific |
| `data` bytes | 28 | 28 | 0 | 512 resource-specific |
| Conservative validation call-chain stack | 0 | 568 | 568 | 1,024 |

Both pristine builds produced the same normalized size tuple. The candidate
ELF reports ARMv7E-M and the VFP hard-float calling convention. Both configured
heaps are zero, no allocator entry point remains linked, and host execution
recomputed and accepted the candidate manifest and bitmap SHA-256 values. It
also rejected one-byte manifest and bitmap mutations with their distinct
integrity-failure results.
Detailed evidence is in
[`evidence/nrf52840/`](../../experiments/spike-005-inter-reference-font/evidence/nrf52840/).
No board was flashed or run.

## Limitations

- The legal findings are engineering evidence, not legal advice. A human must
  review the OFL obligations and checked-in notices before SPEC-005 review.
- The candidate canonical byte encoding resolves enough detail for the Spike,
  but SPEC-005 must explicitly confirm signed geometry encoding and raster-
  record inclusion before adopting its resource identity.
- `giftui-spike-outline-v1` proves a bounded per-glyph outline payload is
  possible. It is not an accepted provider format and was not rasterized by a
  production GiftUI outline provider.
- The 16-pixel instance is a proportional reference fixture, not a public
  typography or layout-style decision.
- The firmware fixture links C data and a disposable C validator rather than
  the future Swift `GiftUITextResources` implementation. It demonstrates
  resource feasibility but does not measure that module's eventual code and
  type overhead.
- The 568-byte stack result is a conservative GCC static call-chain sum, not a
  connected-hardware high-water measurement.

## Disposition

Completed. Inter 4.1 Regular is feasible as the licensed source for a bounded
SPEC-005 reference package, and the source, license, derivation commands,
candidate derived assets, hashes, and resource measurements are now preserved
in the repository.

The evidence feeds SPEC-005 review preparation. Before that Specification can
advance to `review`, maintainers must review licensing, decide whether to
adopt or replace the candidate manifest and outline encodings, integrate the
selected generated package through the authoritative contract, and resolve
the separate SPEC-003 failure-origin blocker. None of those gates is bypassed
by this completed Spike.

## References

- [SPEC-005: Deterministic Text Resource Contract](../specs/spec-005-text-resources.md)
- [ADR-023: Exact Font Resource Identity and Ownership](../adrs/adr-023-exact-font-resource-identity.md)
- [RFC-003: Deterministic Text Rendering Architecture](../rfcs/rfc-003-deterministic-text-rendering-architecture.md)
- [Inter 4.1 release](https://github.com/rsms/inter/releases/tag/v4.1)
- [Inter 4.1 license](https://github.com/rsms/inter/blob/v4.1/LICENSE.txt)

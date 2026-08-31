# SPEC-002 T5.2 Shared Semantic-Corpus Evidence

**Task:** `T5.2`

**Recorded:** 2026-08-31

## One ordered corpus

`SemanticCorpus/cases.tsv` contains seven ordered, fixed-width cases covering:

1. public `Point` value copying/equality at both scalar limits;
2. valid zero/ordinary and rejected negative `Size`/`ProposedSize` construction;
3. ordinary and every directional checked add/subtract/multiply overflow edge;
4. rectangle limit construction, rejected exclusive-edge overflow, empty
   behavior, and half-open containment;
5. all three exact pointer-phase raw values;
6. minimum and maximum raw source/sequence/ordinal/revision wrappers; and
7. normalized events for every phase with minimum, maximum, and ordinary
   coordinates and provenance.

The fail-closed checker proves that the probe markers match registry order and
that the expected words sum to checksum `28`:

```text
SPEC-002 profile corpus check passed: 7 ordered cases, checksum 28.
```

## Profile comparison

Every profile writes the same normalized `semantic-contract.tsv`; its SHA-256
is `a96af982d5f483d0d8c3da6cf80a41251af3bfeda2ef8a3d51acfc9f5c386844` in
all four reports.

| Profile | Foundation/probe disposition | Transcript disposition |
| --- | --- | --- |
| macOS dynamic | exact Foundation source plus probe compiled and executed | `profile_corpus_checksum=28` |
| macOS static | exact Foundation source plus probe compiled and executed | byte-for-byte equal to dynamic, checksum `28` |
| Raspberry Pi ARMv6 | exact Foundation source plus probe cross-compiled as `GiftUIFoundationProfileCorpusProbe.swiftmodule` | same semantic-contract hash and checksum `28`, labeled `execution=cross-build-only` |
| nRF52840 Embedded | exact Foundation source plus probe cross-compiled as `GiftUIFoundationProfileCorpusProbe.swiftmodule` | same semantic-contract hash and checksum `28`, labeled `execution=cross-build-only` |

The ARMv6 and nRF reports demonstrate that the pinned target compilers accept
the same Foundation implementation and complete semantic probe without a
profile adapter or fallback declaration. Their transcript is a checked corpus
and cross-compilation disposition, not a claim that the target binary executed
on connected hardware.

## Reproduction

```sh
scripts/contracts/run-spec-002.sh --profile macos-dynamic
scripts/contracts/run-spec-002.sh --profile macos-static
scripts/contracts/run-spec-002.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-002.sh --profile nrf52840-embedded
```

No command deploys, accesses a remote machine, restarts a service, or flashes
hardware.

# SPEC-003 Milestone 5 Four-Profile Compilation Evidence

**Task:** `T5.1`

**Recorded:** 2026-08-30

## Shared corpus

`ProfileCorpusProbe/ProfileCorpusProbe.swift` is one collection-free compiled
form of the seven ordered `SemanticCorpus/cases.tsv` rows. The fail-closed
corpus checker compares every `corpus-case` marker with the registry order and
derives the expected checksum from all fixed-width expected words:

```text
SPEC-003 profile corpus check passed: 7 ordered cases, checksum 69.
```

Both macOS profiles execute that source and require the exact transcript
`profile_corpus_checksum=69`. ARMv6 and nRF52840 compile the same source as a
target module; this is cross-build evidence and does not claim target
execution.

## Exact profile results

| Profile | Compiler/target/mode | Result |
| --- | --- | --- |
| macOS dynamic | Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`), `arm64-apple-macosx26.0`, `-O` WMO | passed and executed checksum 69 |
| macOS static | Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`), `arm64-apple-macosx26.0`, `-O` WMO | passed and executed checksum 69 |
| Raspberry Pi 1 | Swift 6.3.2, `armv6-unknown-linux-gnueabihf`, Bookworm SDK, `-O` WMO | passed cross-build and target-module inspection |
| nRF52840 | Swift 6.3.2, `armv7em-none-none-eabi`, Embedded Swift, `-Osize` WMO | passed cross-build and target-object inspection |

The four standalone commands were:

```sh
scripts/contracts/run-spec-003.sh --profile macos-dynamic
scripts/contracts/run-spec-003.sh --profile macos-static
scripts/contracts/run-spec-003.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-003.sh --profile nrf52840-embedded
```

Every report records `remote_access=false`, `deployment=false`,
`service_restart=false`, and `flashing=false`.

## Target object attributes

The ARMv6 SwiftPM Core object is an ELF 32-bit little-endian ARM EABI5
relocatable object. Its `.ARM.attributes` section contains the `arm1136jf-s`
CPU name and hard-float calling-convention tag.

The nRF Core object reports:

```text
Tag_CPU_name: "cortex-m4"
Tag_CPU_arch: v7E-M
Tag_FP_arch: VFPv4-D16
Tag_ABI_VFP_args: VFP registers
```

The drivers fail if these attributes are absent. This evidence does not claim
a linked final-image resource result, stack bound, connected-device behavior,
or semantic transcript equivalence beyond the two executed macOS profiles;
those remain T5.2-T5.4 and T6.2 work.

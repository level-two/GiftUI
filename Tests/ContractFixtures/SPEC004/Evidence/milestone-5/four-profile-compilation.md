# SPEC-004 Milestone 5 Four-Profile Compilation Evidence

**Task:** `T5.1`

**Recorded:** 2026-08-31

## Shared normalized corpus

`NormalizedProfileProbe/NormalizedProfileProbe.swift` is one collection-free
compiled form of the five ordered `configuration` rows in
`SemanticCorpus/cases.tsv`. The fail-closed profile-corpus checker compares
the complete row markers in registry order and verifies the fixed case-code
checksum:

```text
SPEC-004 profile corpus check passed: 5 ordered cases, checksum 12.
```

Both macOS profiles execute that source and require the exact transcript
`normalized_profile_checksum=12`. ARMv6 and nRF52840 compile the same source
as a target module; this is hardware-free cross-build evidence and does not
claim target execution.

## Exact profile results

| Profile | Compiler/target/mode | Result |
| --- | --- | --- |
| macOS dynamic | Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`), `arm64-apple-macosx26.0`, `-O` WMO | passed and executed checksum 12 |
| macOS static | Apple Swift 6.3.3 (`swiftlang-6.3.3.1.3`), `arm64-apple-macosx26.0`, `-O` WMO | passed and executed checksum 12 |
| Raspberry Pi 1 | Swift 6.3.2, `armv6-unknown-linux-gnueabihf`, Bookworm SDK, `-O` WMO | passed cross-build and target-module inspection |
| nRF52840 | Swift 6.3.2, `armv7em-none-none-eabi`, Embedded Swift, `-Osize` WMO | passed cross-build and target-object inspection |

The four standalone commands were:

```sh
scripts/contracts/run-spec-004.sh --profile macos-dynamic
scripts/contracts/run-spec-004.sh --profile macos-static
scripts/contracts/run-spec-004.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-004.sh --profile nrf52840-embedded
```

Every report records `remote_access=false`, `deployment=false`,
`service_restart=false`, and `flashing=false`.

## Target object attributes

The Raspberry Pi capability object is an ELF 32-bit little-endian ARM EABI5
relocatable object. Its `.ARM.attributes` section contains the `arm1136jf-s`
CPU name and hard-float calling-convention tag.

The nRF capability object reports:

```text
Tag_CPU_name: "cortex-m4"
Tag_CPU_arch: v7E-M
Tag_FP_arch: VFPv4-D16
Tag_ABI_VFP_args: VFP registers
```

The driver fails if these attributes are absent. This evidence does not claim
a linked final-image resource result, stack bound, connected-device behavior,
or full static/dynamic transcript equivalence beyond the already completed
Milestone 3 evidence; those remaining bounded-resource and final-matrix claims
belong to `T5.2` through `T5.4` and `T6.2`.

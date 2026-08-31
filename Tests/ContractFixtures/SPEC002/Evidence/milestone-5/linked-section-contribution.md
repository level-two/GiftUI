# SPEC-002 Matched Linked-Section Contribution

Implementation-plan task `T5.4` uses one checked-in Swift/C template for both
images in each profile. Baseline and candidate builds have identical source
and link inputs; only the candidate defines `GIFTUI_SPEC002_CANDIDATE`. That
branch references every SPEC-002-owned public or package value and all three
checked arithmetic operations. Source hashes, full recorded commands,
compiler/SDK metadata, inspector identity, raw section listings, images, and
both link maps are generated under each profile's replace-on-rerun report
directory.

## Signed candidate-minus-baseline deltas

| Profile | Executable code | Read-only | Initialized | Zero-initialized | File size |
| --- | ---: | ---: | ---: | ---: | ---: |
| macOS dynamic | +296 B | 0 B | 0 B | 0 B | +96 B |
| macOS static | +296 B | 0 B | 0 B | 0 B | +96 B |
| Raspberry Pi ARMv6 | +272 B | +8 B | 0 B | -288 B | +368 B |
| nRF52840 Embedded | +248 B | 0 B | 0 B | 0 B | +532 B |

The ARMv6 zero-initialized decrease is preserved as a signed descriptive
result: section alignment and linker placement may move in either direction
when the candidate retains additional code. Linked-section deltas are not
normative ceilings; SPEC-002's value-layout maxima and zero-allocation rules
remain the pass/fail resource limits.

## Reproduction and evidence boundary

The following exact standalone commands passed from revision `8139a93` plus
this task's working-tree change:

```text
scripts/contracts/run-spec-002.sh --profile macos-dynamic
scripts/contracts/run-spec-002.sh --profile macos-static
scripts/contracts/run-spec-002.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-002.sh --profile nrf52840-embedded
```

The macOS images were executed as host smoke checks. ARMv6 and nRF52840 are
linked cross-build and inspection evidence only. The ARMv6 images passed the
32-bit ARMv6 hard-float verifier; both nRF images declared ARMv7E-M VFP-register
arguments. The nRF builds used the pinned Zephyr 4.3.0 wrapper and produced
complete final ELF images and maps without deployment, remote access, or
flashing.

The normalized report classifies executable, read-only, initialized writable,
and zero-initialized allocatable sections with the profile toolchain's section
inspector, then records the complete image file-size delta separately. Raw
tool output remains beside `linked-section-deltas.tsv` so reviewers can
reproduce or revise the descriptive grouping without rebuilding the images.

# SPEC-012 T9.4 Target Inspection

Date: 2026-09-14

The SPEC-014 production consumer run
`64f28244cdc154dd98ca1786ced9a80ce1df7d6f-7b601523b1450ef0` passed for all
four profiles. Raspberry Pi inspection requires the exact
`armv6-unknown-linux-gnueabihf` object and EABI5 hard-float attributes; the
checker rejects ARMv7 and AArch64 substitutions. Its optimized backend entry
has zero allocator references.

The nRF linked image targets `nrf52840dk/nrf52840` using the bundled
`armv7em-none-none-eabi` Swift module and reports `Tag_CPU_arch: v7E-M`,
`Tag_FP_arch: VFPv4-D16`, and `Tag_ABI_VFP_args: VFP registers`. Optimized SIL
contains zero heap-allocation instructions. Symbol and storage audits reject
forbidden runtime dependencies, retained frame/display lists, and a hidden
complete-frame buffer in the tiled path.

Both target reports retain full command transcripts, symbols, link maps,
section deltas, bounded stack and workspace high-water, allocation results,
and linked file-size/RAM/flash evidence. This is compile/link and artifact
inspection only; no remote target was accessed and no board was flashed.

```sh
scripts/contracts/run-spec-014.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-014.sh --profile nrf52840-embedded
```

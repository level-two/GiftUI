# T5.3 Static Resource Images

Date: 2026-09-04

This evidence is hardware-free cross-build evidence. No device was contacted,
deployed to, restarted, or flashed. The maintained measurement method is
described by
[`spec-005-static-resource-layout.md`](../../../../../docs/implementation-designs/spec-005-static-resource-layout.md).

## nRF52840 bitmap-only pair

The exact `nrf52840dk/nrf52840` baseline and candidate were each rebuilt twice
with the same optimized whole-module source construction. Both pairs were
byte-identical:

| Image | SHA-256 | Fixed RAM | Flash |
| --- | --- | ---: | ---: |
| baseline | `e4133977db6980cbb1bb9fd02d03041b4619046fa6d203a757f8eaffbbc9cc5f` | 6,016 B | 25,716 B |
| candidate | `550b5a2c56f80efd871cd237f2d9c69f718a4d3e070258eb10144def93be3f32` | 6,016 B | 48,740 B |
| SPEC-005 delta | — | 0 B | 23,024 B |

The delta passes the 512-byte fixed-RAM and 96-KiB flash ceilings. A
conservative retained-root call-graph analysis reports 1,004 bytes for the
validation path, below the 1-KiB ceiling. The image declares ARMv7E-M,
Cortex-M4, VFPv4-D16, and the hard-float VFP register calling convention.
Bitmap payload/provider symbols are retained. Outline payload/provider symbols
are absent from both the symbol inventory and link map.

Immutable report:
`.build/contract-reports/spec-005/be1690c2f5186e9a7ed69dd8aedc24501695bd92-0850d99ea3b82820/nrf52840-embedded`

## Raspberry Pi ARMv6 bitmap-only pair

The optimized baseline and candidate were built for the exact
`armv6-unknown-linux-gnueabihf` triple. Their ELF identity and ARM attributes
prove 32-bit ARM EABI5, ARMv6, and the hard-float calling convention.

| Image | SHA-256 | Final image size |
| --- | --- | ---: |
| baseline | `00036407c26ddba14d67d42e89770a98c3074db99710dc2d3e282c30ee3f7626` | 8,732,608 B |
| candidate | `b5c689d56d42360dd07f5a88f37736f690ad876bf40bd32a31fba8bd269a351f` | 8,922,908 B |
| SPEC-005 delta | — | 190,300 B |

The candidate retains the bitmap payload/provider and nominal
`FontResourceID`. Outline payload/provider symbols are absent from the final
image and link map.

Immutable report:
`.build/contract-reports/spec-005/be1690c2f5186e9a7ed69dd8aedc24501695bd92-6059a56feb7fd668/raspberry-pi-armv6`

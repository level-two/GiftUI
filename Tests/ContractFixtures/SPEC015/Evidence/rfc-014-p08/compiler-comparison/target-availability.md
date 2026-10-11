# Swift 6.4 candidate target availability — 2026-10-12

**Candidate artifacts are available; compatibility remains untested.** This
read-only inventory changes no compiler pin or source, downloads no SDK, and
runs no compiler test or hardware operation. [Structured evidence](target-availability.json)
freezes the filtered release metadata, exact query provenance, local module
hashes, current pin-file identities and subsequent checks.

## Raspberry Pi 1 ARMv6

The parent retrieved the [release-tag API](https://api.github.com/repos/swift-embedded-linux/armhf-debian/releases/tags/6.4.0)
on 2026-10-12, with curl exit zero. The response identifies
[release 6.4.0](https://github.com/swift-embedded-linux/armhf-debian/releases/tag/6.4.0)
as non-draft/non-prerelease, published 2026-09-17. The exact candidate asset is
[swift-6.4.0-RELEASE-raspios-bookworm-armv6-sdk.tar.gz](https://github.com/swift-embedded-linux/armhf-debian/releases/download/6.4.0/swift-6.4.0-RELEASE-raspios-bookworm-armv6-sdk.tar.gz),
231,261,913 bytes, with API-advertised SHA256
`3332907e1fe366a24cdd9b4af566cb4f1a1f39aa8fad785cb328af17c7484848`.
The archive has not been downloaded or inspected; the advertised digest is not
a locally verified archive hash.

[Current Pi pins](../../../../../../scripts/raspberry-pi/toolchain.env) pair
Swift 6.3.2 with its Bookworm ARMv6 SDK and require
`armv6-unknown-linux-gnueabihf`. A candidate investigation must verify the exact
new archive, inspect its destination and sysroot, freshly build every dependent
module with the matching compiler, and compile/link the supported target.
ARMv6 CPU and VFP-register ABI, dependency/linker compatibility, applicable
regressions and complete image RAM/stack/allocator costs remain unproved.
ARMv7 and AArch64 assets cannot substitute for this SDK.

## nRF52840-DK Embedded Swift

The verified local 6.4 package contains the standard Embedded Swift target module:

```text
.toolchains/p08-comparison/expanded/swift-6.4.0-RELEASE-osx/swift-6.4.0-RELEASE-osx-package.pkg/Payload/usr/lib/swift/embedded/Swift.swiftmodule/armv7em-none-none-eabi.swiftmodule
```

It is 22,290,788 bytes; local SHA256 is
`15912e1951ad3738d0dd98e10c5d08d8a48189ad918e59a7156764578705836b`.
The structured evidence also identifies companion modules for this target.
[Compiler setup](setup-receipt.json) records the containing official package,
trusted signature, compiler identity and exact version metadata.

[Current Nordic pins](../../../../../../scripts/nrf52840/toolchain.env) retain
Swift 6.3.2, Zephyr 4.3.0 with its pinned revision, SDK 0.17.4,
`nrf52840dk/nrf52840`, and `armv7em-none-none-eabi`. Candidate compatibility
requires fresh probe/module/firmware builds using Zephyr's Cortex-M4F hard-float
flags, then final ELF `v7E-M` and VFP-register calling-convention checks.
The 192 KiB RAM and 1 MiB flash limits, stack use, disabled heap and applicable
zero-heap symbol checks remain required. Module presence alone proves none of
those properties.

## Decision boundary

These prerequisites follow the existing
[Pi toolchain skill](../../../../../../skills/giftui-pi-toolchain/SKILL.md) and
[Nordic toolchain skill](../../../../../../skills/giftui-nrf-toolchain/SKILL.md).
Supported pins remain authoritative and unchanged. A compiler-baseline change
needs the explicit ADR/Specification decision described by the
[comparison scope](scope.md), followed by fresh complete validation; 6.3.2
module binaries cannot be reused with another compiler. No deployment, restart,
flash, connected-target result or P08 completion follows from this inventory.

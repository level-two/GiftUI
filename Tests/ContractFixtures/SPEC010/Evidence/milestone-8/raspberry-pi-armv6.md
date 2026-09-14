# SPEC-010 T8.2 Raspberry Pi ARMv6 Evidence

Date: 2026-09-14

The hardware-free doctor probe passed, and the SPEC-010 driver published the
`raspberry-pi-armv6` member of run ID
`f76656e188855f67d5c72170c29167a55f8d6c90-9ed90617cd81f0d9`. The project-local
Swift 6.3.2 compiler used the pinned static SDK and exact
`armv6-unknown-linux-gnueabihf` destination to compile the portable observable
module and generated host. The generated declaration digest matches both
macOS profiles.

The corresponding SPEC-013 production report in run ID
`f76656e188855f67d5c72170c29167a55f8d6c90-31230e742780694f` supplies Dynamic
runtime dependency closure, complete normalized transcript, high-water,
timing, allocation, stack/layout, and target inspection evidence. Its object is
32-bit ARMv6 EABI5 hard-float; no ARMv7 or AArch64 substitute is accepted.
This was compile/link and inspection evidence only: no remote access,
deployment, service restart, or connected execution occurred.

```sh
scripts/raspberry-pi/doctor.sh --probe
scripts/contracts/run-spec-010.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-013.sh --profile raspberry-pi-armv6
```

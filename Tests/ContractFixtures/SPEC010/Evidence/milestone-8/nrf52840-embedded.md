# SPEC-010 T8.3 nRF52840 Embedded Evidence

Date: 2026-09-14

The hardware-free doctor probe passed for the pinned Swift 6.3.2 toolchain,
Zephyr revision, SDK, and `nrf52840dk/nrf52840` board. The SPEC-010 driver
published the `nrf52840-embedded` member of run ID
`f76656e188855f67d5c72170c29167a55f8d6c90-9ed90617cd81f0d9`, compiling the
portable observable declarations and generated host with the bundled
`armv7em-none-none-eabi` module and Cortex-M4F hard-float flags. Its generated
declaration digest matches all other profiles, and the object excludes macro
support from the target closure.

The matching SPEC-013 production report in run ID
`f76656e188855f67d5c72170c29167a55f8d6c90-31230e742780694f` provides the
complete Static corpus, zero heap/allocation-path proof, exact storage and
stack high-water, workload timing, and linked-image inspection. The ELF
reports ARMv7E-M, VFPv4-D16, and VFP-register arguments. No simulator,
connected-board execution, or flashing occurred.

```sh
scripts/nrf52840/doctor.sh --probe
scripts/contracts/run-spec-010.sh --profile nrf52840-embedded
scripts/contracts/run-spec-013.sh --profile nrf52840-embedded
```

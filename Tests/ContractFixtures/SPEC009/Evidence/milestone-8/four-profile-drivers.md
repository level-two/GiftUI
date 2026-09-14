# SPEC-009 T8.5 Four-Profile Driver Evidence

Date: 2026-09-14

## Result

The Raspberry Pi and nRF52840 hardware-free doctor probes passed before the
profile runs. The four standalone drivers then published the shared run ID
`6c2188a80f6476999f2364d3a8dee049e6fe8155-d651c7c92f4ee6d5` for:

- `macos-dynamic`
- `macos-static`
- `raspberry-pi-armv6`
- `nrf52840-embedded`

Each report contains the exact compiler, SDK/target, optimization flags,
repository revision and dirty state, fixture digest, command transcript, and
31-value layout image. Its prerequisite table records the integrated SPEC-013
allocation/high-water evidence and SPEC-014 production target inspection as
complete, and re-executes their storage-boundary and module-contract checks.
The reports remain correctly fail-closed on acceptance evidence until T8.6.

The supporting SPEC-013 collection records Static zero heap, exact storage
high-water and workload timing, stack/layout inspection, ARMv6 target identity,
and nRF VFP attributes. The supporting SPEC-014 profile collections record
production backend resource bounds, sections, symbols, and link maps. No run
accessed a remote target, deployed, restarted a service, used a simulator,
executed on connected hardware, or flashed a board.

## Reproduction

```sh
scripts/raspberry-pi/doctor.sh --probe
scripts/nrf52840/doctor.sh --probe
for profile in macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded; do
  scripts/contracts/run-spec-009.sh --profile "$profile"
done
```

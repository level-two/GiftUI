# SPEC-009 T8.4 Production Resource Evidence

Date: 2026-09-14

Evidence kind: host execution, compiler inspection, cross-build, and linked-
image inspection. No simulator, connected target, deployment, service restart,
or flashing was used.

## Result

The exact macOS Dynamic, macOS Static, Raspberry Pi ARMv6, and nRF52840
Embedded compilers each reproduce all 31 SPEC-009 value-layout rows. On every
compiler `ExecutionFixtureOwnerFailure` is exactly 4 bytes,
`RunCycleFailure<ExecutionFixtureOwnerFailure>` is 5 bytes within its 8-byte
ceiling, and `RunCycleResult<ExecutionFixtureOwnerFailure>` is exactly its
72-byte ceiling.

The SPEC-013 production storage corpus supplies the downstream runtime proof.
It checks all 51 logical exact-limit and first-excess cases and all 16 physical
storage families. Dynamic storage reports the queue/workspace high-water at
the approved fixture limits, 136 owned payload bytes, at least 136 reserved
payload bytes, and 16 allocator-backed regions separately from total profile
bytes. Static storage uses fixed tuple-backed regions and no dynamic storage
facility.

Whole-module optimized macOS Static and nRF52840 binding entry points contain
no allocator, generic-metadata allocator, Objective-C, reflection, task,
thread, exception-personality, closure-box, existential-box, partial-apply, or
raw-allocation reference. Their reports record zero heap allocations and zero
peak heap bytes. The named binding entry point is the reachability boundary;
unrelated retained generic bodies are not mislabeled as executed profile code.
The nRF linked image is ARMv7E-M/VFPv4-D16 with VFP-register arguments, and the
Pi object is exactly `armv6-unknown-linux-gnueabihf`.

## Reproduction

```sh
for profile in macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded; do
  scripts/contracts/check-spec-009-value-profiles.sh \
    --profile "$profile" --output ".build/spec-009/t8.4-value-layouts/$profile"
done
scripts/contracts/collect-spec-013-t7.3-evidence.sh \
  .build/spec-009/t8.4-runtime-profile-evidence
```

The stable upstream details are recorded in SPEC-013's
`milestone-6/storage-boundaries.md` and `milestone-7/target-inspection.md`.

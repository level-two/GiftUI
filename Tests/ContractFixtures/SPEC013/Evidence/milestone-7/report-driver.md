# SPEC-013 T7.1 Reproducible Report Driver Evidence

Evidence kind: host execution, cross-build toolchain inspection, and source
inspection. No simulator, connected target, deployment, service restart, or
flashing was used.

## Result

Each exact profile invocation publishes under an immutable run ID derived from
the Git revision and declared input hashes. Reports record repository dirty
state, full command, compiler, SDK, target, truthful evidence class, all 41
numeric artificial limits, sixteen audit/high-water families and checked total,
every registered fixture result, and the normalized transcript digest. A hash
manifest protects every report file and repeated identical publication is
idempotent.

T7.2 resource and timing instrumentation is an explicit blocking prerequisite
in each report. The driver does not insert guessed stack, heap, section, code-
size, or timing values.

## Standalone invocations

```sh
scripts/contracts/run-spec-013.sh --profile macos-dynamic
scripts/contracts/run-spec-013.sh --profile macos-static
scripts/contracts/run-spec-013.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-013.sh --profile nrf52840-embedded
```

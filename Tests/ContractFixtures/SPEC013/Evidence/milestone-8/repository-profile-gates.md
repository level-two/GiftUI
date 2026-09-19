# SPEC-013 T8.3 Repository and Profile Gates

On 2026-09-19, revision `2aeeb81` passed the maintained Swift formatter and
`scripts/test.sh --profile all-hardware-free`. The aggregate includes focused
Runtime Core/Dynamic/Static/conformance suites, governance and dependency
checks, and all four exact SPEC-013 driver modes.

The report driver was also made repeat-safe: when the same revision and input
set already has an immutable report, it verifies the report hash manifest,
updates the latest pointer atomically, and exits successfully without
recollecting nondeterministic timing samples or overwriting evidence.

Stable fixture and method records remain under
`Tests/ContractFixtures/SPEC013/Evidence/`; generated run reports remain under
`.build/contract-reports/spec-013/`. Raspberry Pi and nRF rows are cross-build
evidence only, with remote access, deployment, connected execution, and
flashing false.

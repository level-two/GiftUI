# T9.4 validated owner handoff — 2026-10-02

Implementation revision f6ef6fb6. All eight standalone registered owner gates
pass: `scripts/contracts/run-spec-013.sh --profile <profile>` and
`scripts/contracts/run-spec-015.sh --profile <profile>` for macos-dynamic,
macos-static, raspberry-pi-armv6 and nrf52840-embedded. Results and immutable
report identities are in owner-handoff-results.tsv; exact invocations, input
hashes, metadata and raw logs are preserved in owner-handoff-reports.tar.gz.

The repaired bounded seam is handed to SPEC-001 T10.5/T10.6. T9.2's actual
behavior tests pass as recorded separately; registered SPEC-013 now also
measures the amended carrier declarations for each selected profile. Full
assembled production/failure normalization and resource evidence remain the
downstream joins, not discharged by seam tests or host compilation.

Neither Spec is marked implemented. Earlier owner passes remain historical.
Other owners' failed assertions, reviewed-pixel references, and connected
hardware/cadence/high-water requirements are not waived by this handoff.
No board flash, remote deployment or restart was performed.

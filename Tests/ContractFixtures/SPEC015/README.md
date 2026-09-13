# SPEC-015 Contract Fixtures

This directory freezes the evidence boundary for the approved MVP host
configuration contract. `fixture-registry.tsv` is ordered and exhaustive;
each registered schema rejects missing, unknown, duplicate, reordered, stale,
or unversioned required fields. Focused failures remain typed columns rather
than flattened diagnostic strings.

The four registered profiles are `macos-dynamic`, `macos-static`,
`raspberry-pi-armv6`, and `nrf52840-embedded`. Evidence is classified as
`host-execution`, `cross-build`, `simulator`, or `connected-target`.
Cross-build and simulator evidence never implies connected-target evidence.

The host package and focused test target are reserved in `module-owners.tsv`.
They become active only with substantive source, Package.swift declarations,
and exact SPEC-002 dependency rows. The migration inventory treats the legacy
SwiftUI composition root as evidence, never as production authority.


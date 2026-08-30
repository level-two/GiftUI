# SPEC-003 T4.2 Capability Owner Adapter Evidence

`GiftUIFailureCore` now names the exact capability-local conditions
`rasterMalformedRequirement` through `rasterByteCountOverflow` at raw values
12 through 25. Raw value 11 remains representable but has no named constant;
the shared constants 0 through 10 remain unchanged.

The unpublished `GiftUICapabilityFailureAdapterFixture` target imports exactly
`GiftUICapabilities` and `GiftUIFailureCore`. It maps all fourteen closed
`RasterPresentationUnavailable` families one-to-one and constructs
`GiftUIOutcome<CapabilitySnapshot>.failure` with capability origin, runtime
scope, and contained containment.

Tests vary every malformed field, all four contributor roles, all four
capacity domains, and required/available byte payloads. These associated
values never change the primary condition. No mapping uses
`requiredFacilityUnavailable`, produces success/operational output, exposes a
partial snapshot, or imports diagnostics. An actual available snapshot
resolved before three simulated runtime fault facts remains exactly equal
after refusal, disconnection, and post-handoff transport-fault observation.

The exact package DAG permits the fixture target's two downward edges and
keeps both production leaves dependency-free. The same collection-free adapter
source compiles under macOS dynamic/static, Raspberry Pi ARMv6, and nRF52840
Embedded Swift profiles. No deployment or flashing occurred.

# Actual artifact compiler metadata

2026-10-04. SPEC-001 T11.5 implemented. Successful reports resolve compiler and SDK through the same project-local configuration used by builds. Native checks carry separate identity/path fields. Pi reports its actual Swift driver, destination path and SHA-256. nRF reports its actual Swift compiler, SDK version/path and Zephyr checkout revision. Both macOS variants use the selected compiler and SDK. Existing metadata keys remain; historical reports are unchanged.

[Fixture](fixture.log): all four variants, distinct default/paired compiler versions, 37 assertions passed. [Actual local identities](actual-toolchains.txt): native Swift 6.3.3 versus paired Swift 6.3.2, ARMv6 SDK destination and Zephyr SDK 0.17.4. Both local doctors pass. Fresh artifact-linked reports remain pending combined integration T11.6.

Reproduce: `ruby Tests/GovernanceTooling/artifact_toolchain_test.rb`; source `scripts/contracts/artifact-toolchain.sh` and call `giftui_artifact_toolchain_metadata <profile> "$PWD"`; final `scripts/test.sh all-hardware-free`.

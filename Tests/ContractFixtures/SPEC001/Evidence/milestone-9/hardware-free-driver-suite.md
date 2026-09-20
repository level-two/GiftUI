# SPEC-001 T9.2 Hardware-Free Driver Suite

- Focused tests: Domain, Data, Presentation, host composition, and preset runner
- SPEC-001 profiles: macOS Dynamic, macOS Static, Pi ARMv6, nRF52840 Embedded
- Dependency drivers: SPEC-002 through SPEC-015 in every registered applicable profile
- Standalone invocations: preserved by `scripts/contracts/driver-registry.tsv`
- Cross-profile comparison: 24 normalized semantic/workload fields equal
- Connected execution: not claimed

The repository gate executes each driver independently and retains immutable
logs under `.build/test-reports/all-hardware-free/` and contract reports under
`.build/contract-reports/`. `compare-spec-001-profiles.rb` consumes the four
latest SPEC-001 reports and fails on a missing field or any semantic/workload
difference.

The host-native focused phase explicitly compiles with
`GIFTUI_DYNAMIC_PROFILE` because it exercises the production Dynamic target
host and its retained Canvas callables for every requested evidence profile.
The later profile-specific product build remains authoritative for the selected
macOS, ARMv6, or nRF artifact and preserves its own compile-mode contract.

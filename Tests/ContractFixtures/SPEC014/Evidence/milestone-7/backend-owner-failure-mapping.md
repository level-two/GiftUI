# SPEC-014 T7.3 Backend Owner Failure Mapping

Date: 2026-09-13

The narrow backend owner adapter preserves the exact raster or display error
and emits the SPEC-003 fact selected by an explicit detection point. Tests
cover every `RasterBackendError` and `DisplayTargetError` case.

- construction arithmetic is contained Foundation/runtime overflow;
- construction capacity is contained host-composition/runtime exhaustion;
- construction mismatch is an unsafe host-composition/runtime invariant;
- pre-body envelope or geometry is a contained backend/candidate invalid value;
- post-begin failures are unsafe backend/runtime invariants, except exact
  reentrancy remains `reentrancyViolation`;
- accepted transport loss is contained presentation-integration/component
  facility unavailability.

The adapter imports only Display Core, Failure Core, and Raster Core. It does
not import execution correlation, and no lower display or transport module was
changed.

Run from the repository root:

```sh
swift test --filter RasterBackendOwnerFailureAdapterTests
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-014-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-014-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-014-value-profiles.sh --profile nrf52840-embedded
```

All mappings and profile compilations pass.

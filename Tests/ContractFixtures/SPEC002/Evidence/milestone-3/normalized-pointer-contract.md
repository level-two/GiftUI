# SPEC-002 Normalized Pointer Contract Evidence

This record closes implementation-plan tasks `T3.1`–`T3.3` and Milestone 3.

The generated public Swift interface contains exactly the approved public
geometry owner set and no `InputEvent` or normalized-input declaration. The
generated package interface contains exactly `GeometryArithmetic` plus the
seven approved normalized-pointer owners. A fail-closed surface checker
rejects old compatibility names, public input, optional provenance, and
backend/platform/OS/RTOS/driver/HAL/hardware vocabulary.

The ordered compile registry contains separate external-client and package
contexts. Its package fixture constructs all three phases at minimum,
ordinary, and maximum coordinate and raw-wrapper values. Host tests prove:

- phase raw values 0, 1, and 2;
- `InputSourceID` occupies 2 bytes;
- `PointerSequenceID`, `InputOrdinal`, and `PresentationRevision` each occupy
  4 bytes;
- `NormalizedPointerEvent` occupies no more than 32 bytes;
- every raw bit pattern used at the min/max boundaries is preserved; and
- copies compare equal without reference identity.

The no-argument repository gate passes 16 Foundation tests and the
macOS-dynamic driver. The macOS-static and nRF52840 Embedded Swift drivers also
compile all three fixtures successfully. The input ledger's five rows are
closed individually against interface, fixture, and value-test evidence.

No admission, ordering, stale-event, cancellation, hit-test, dispatch,
physical conversion, backend, host, or connected-hardware behavior was added
or tested. No remote access, deployment, or flash occurred.

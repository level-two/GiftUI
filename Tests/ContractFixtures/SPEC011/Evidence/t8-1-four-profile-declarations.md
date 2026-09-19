# SPEC-011 T8.1 Four-Profile Declarations

The exact declaration audit verifies the public `GiftUIAction`, qualified
`Button`, title initializers, `disabled`, handler, and borrowing model surface,
plus the six-action positive fixture and seven negative declaration shapes.

Each `run-spec-011.sh` mode executes that audit, then composes the matching
SPEC-013 profile driver and SPEC-015 final product build. Consequently the
same declarations are compiled as part of the macOS Dynamic, macOS Static,
`armv6-unknown-linux-gnueabihf`, and `armv7em-none-none-eabi` product graphs.
The immutable report records compiler, SDK/target, full commands, repository
revision, input digest, and the hashes of both composed evidence reports.

Reproduction uses the four exact commands listed in the implementation plan.
The ARMv6 and nRF modes are cross-build inspection only; neither runs or
flashes connected hardware.

# Static C-loop pacing revalidation — 2026-10-02

The production-host C test now models action application inside the paced
common-runner presentation opportunity. Pending input remains unapplied at
100/180 ms, starts its source schedule at 250 ms, and admits the first due
facts at 340 ms. A zero-delay pair is drained in that same source opportunity.
The obsolete direct-input-drain stub asserts if called.

The pending/contained result (`2`) preserves the physical touch revision and
frame count while advancing the next opportunity deadline. Terminal refusal
still returns `-EIO` and teardown quiesces input and retires the graph.

`scripts/contracts/check-spec-001-nrf-production-host.sh` passes.

## Authorized connected attempt

Toolchain doctor passed. The user authorized flashing and stack measurement.
The named production ELF SHA-256 was
`db66ec8e39541fb2aa841c50a6c72a24f9bec7618d9e120ec22e1717f77e0c30`;
HEX SHA-256 was
`3dc9c3893a60ed30cb89cac2d305acf42e3e874c04d95ef64b0b48ede681626e`.

`scripts/nrf52840/flash.sh --application signal-analyzer-static --no-build`
failed because J-Link could not connect to the probe. A direct J-Link
connection check confirmed `Cannot connect to the probe/programmer`.
No successful flash or new stack measurement is claimed. The connected
prerequisite remains open until the powered debug USB probe is available.

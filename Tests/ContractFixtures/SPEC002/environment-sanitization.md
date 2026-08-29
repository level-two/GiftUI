# SPEC-002 Environment Sanitization Record

This record is the evidence for implementation-plan task `T0.6`.

## Raspberry Pi

- `scripts/raspberry-pi/toolchain.env` retains exact Swift 6.3.2, Bookworm,
  ARMv6 target, archive, signer, and checksum pins but defines no product.
- `build.sh` requires `--product` unless `--probe` selects the checked-in
  hardware-free toolchain probe.
- `deploy.sh` requires `--product` for every deployment, including deployment
  of an existing artifact, and still rejects a remote machine that does not
  report `armv6l`.
- `local.env.example` contains connection examples only; it supplies no PoC or
  MVP product default.
- Setup, environment, doctor, probe, build, artifact verification, and deploy
  outputs remain under the project-local `.toolchains/` and
  `.build/raspberry-pi/` roots.

## nRF52840

- Only `firmware/nrf52840/applications/probe/` remains.
- `scripts/nrf52840/toolchain.env` defaults only to that hardware-free probe.
- `build.sh` remains generic and emits its ELF, HEX, map, Devicetree, VFP ABI,
  symbol, heap, and memory evidence under `.build/nrf52840/<application>/`.
- `flash.sh` requires `--application` and is not called by setup, doctor,
  build, tests, or the probe.
- The hard-coded removed-module script `compile-layer.sh` is absent.

## Structural verification

The retained shell scripts pass `bash -n`, and the build/deploy/flash help
surfaces are callable without a toolchain download or connected device. An
active-tree audit outside `README.md`, which is rewritten by `T0.8`, finds no
PoC product, removed module, or removed firmware-application assumption in
`scripts/`, `skills/`, `Package.swift`, `Sources/`, or the root test target.

This task performs no deployment, remote access, service restart, connected-
board operation, or flash.

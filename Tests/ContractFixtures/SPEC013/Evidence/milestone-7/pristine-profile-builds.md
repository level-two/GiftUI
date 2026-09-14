# T7.4 Pristine Profile Builds

Two detached, clean temporary checkouts at the same repository revision run
the exact `macos-dynamic`, `macos-static`, `raspberry-pi-armv6`, and
`nrf52840-embedded` report-driver modes. Project-local pinned toolchains are
linked into each checkout; generated reports and build products remain ignored.

The comparison requires byte-identical canonical transcript inputs, storage
audit, storage high-water, artificial limits, and fixture results between both
builds of every profile. It also requires one transcript digest across all four
profiles. Compiler and SDK identity, target-private layout, and other
profile-private metadata stay visible and are permitted to vary; portable
semantic or resource rows are not.

Raspberry Pi and nRF reports are hardware-free cross-build evidence. The
collector performs no remote access, deployment, service restart, flashing, or
connected-board execution.

Reproduce from a clean committed revision:

```sh
scripts/contracts/check-spec-013-pristine-builds.sh
```

The retained summary is
`.build/contract-reports/spec-013/pristine-builds/portable-comparison.tsv` with
collection identity in `collection-metadata.tsv` and per-run logs under
`logs/`.

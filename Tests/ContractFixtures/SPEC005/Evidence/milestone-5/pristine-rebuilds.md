# T5.4 Pristine Rebuild Evidence

T5.4 completed on 2026-09-04 against repository revision
`fdac8a775c35267fabb986f4fb65e3bacd265b96`.

The registered pristine-rebuild harness created two detached clean checkouts,
gave each checkout-local access to the repository-managed toolchains, and ran
the exact standalone SPEC-005 driver for all four profiles in each checkout:

```text
scripts/contracts/run-spec-005.sh --profile macos-dynamic
scripts/contracts/run-spec-005.sh --profile macos-static
scripts/contracts/run-spec-005.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-005.sh --profile nrf52840-embedded
```

`scripts/contracts/check-spec-005-pristine-rebuilds.sh` passed. Its normalized
artifact inventory contains 27 passing comparisons across commands, metadata,
input hashes, semantic transcripts, allocation results, ARMv6 resource
summaries and sections, nRF resource summaries and sections, and nRF
validation call graphs. Checkout-local paths and process-specific temporary
directory suffixes are the only normalized fields.

The following registered top-level gates then passed from the same clean
revision:

```text
scripts/test.sh
scripts/test.sh all-hardware-free
```

The default gate passed governance, governance-tooling tests, Swift formatting,
driver registration, root Swift tests, the diagnostic-buffer check, and every
registered macOS dynamic contract driver. The `all-hardware-free` gate passed
the same common checks plus SPEC-002 through SPEC-005 for macOS dynamic, macOS
static, Raspberry Pi ARMv6, and nRF52840 embedded.

All Raspberry Pi and nRF results are cross-built hardware-free evidence. The
harness records `remote_access=false`, `deployment=false`,
`service_restart=false`, `connected_target_execution=false`, and
`flashing=false`; no connected hardware was used.

Reproduction reports are generated under:

- `.build/contract-reports/spec-005/pristine-rebuilds/`
- `.build/test-reports/macos-dynamic/`
- `.build/test-reports/all-hardware-free/`


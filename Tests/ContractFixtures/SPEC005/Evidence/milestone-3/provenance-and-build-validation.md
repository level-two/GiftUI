# SPEC-005 T3.4 Provenance and Build-Validation Evidence

T3.4 consolidates the reference package's reviewed engineering provenance,
attribution, deterministic derivation, generated inventory, and build results.
It does not provide legal advice; the checked-in OFL text remains the license
authority.

## Source and attribution

- Upstream: Inter 4.1 by the Inter Project Authors
- Selected source: official `extras/ttf/Inter-Regular.ttf`
- Source SHA-256: `40d692fce188e4471e2b3cba937be967878f631ad3ebbbdcd587687c7ebe0c82`
- License: SIL Open Font License 1.1, checked in beside the source
- License SHA-256: `262481e844521b326f5ecd053e59b98c8b2da78c8ee1bdbb6e8174305e54935a`
- Derived family identity: `GiftUI Reference Sans`
- Production reproduction command:
  `scripts/text-resources/verify-reference-generation.sh --verify`

The stable attribution and scope statement is
`ThirdParty/Inter-4.1/README.md`. The machine-checked inventory is
`reference-provenance.tsv` in this evidence directory. It records exact byte
counts and SHA-256 values for the source, license, generator, pins, setup and
verification workflows, generated catalogue, both generated payload sources,
and generation manifest.

## Build-validation results

On 2026-09-01, the following checks passed from the repository root:

```text
scripts/text-resources/verify-reference-generation.sh --verify
scripts/contracts/check-spec-005-reference-generation.rb
scripts/contracts/check-spec-005-reference-compositions.sh /tmp/spec-005-compositions
swift test --filter GiftUIReferenceTextResourcesTests
scripts/contracts/run-spec-005.sh --profile macos-dynamic
```

The results reproduce the adopted `bd14de9f...394910` resource identity,
validate the complete package once for each required realization, validate
all 204 record borrows, and produce exact complete, bitmap-only, and
outline-only availability transcripts. The registered driver hashes these
inputs and evidence records in every report.

These are deterministic generation, macOS package/compiler/link, and
hardware-free contract results. They do not assert connected Raspberry Pi or
nRF52840 execution, deployment, service changes, flashing, or legal advice.

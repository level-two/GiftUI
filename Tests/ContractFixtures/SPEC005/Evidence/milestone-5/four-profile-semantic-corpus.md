# SPEC-005 T5.1 Four-Profile Semantic Corpus Evidence

All four standalone drivers compile the contract leaf and concrete reference
package with their pinned compiler and target flags. ARMv6 compiles the
outline-capable complete reference package for
`armv6-unknown-linux-gnueabihf`; nRF52840 compiles the bitmap-only source list
for `armv7em-none-none-eabi` with Cortex-M4F hard-float flags and no outline
payload source.

Each report contains `semantics/profile-semantics.tsv`. The normalized rows
cover the adopted identity and payload digests, catalogue counts, exact and
replacement mappings, line and glyph metrics, representative ink/advance
geometry, all 45 isolated/pairwise validation precedence cases, all nine
SPEC-003 owner mappings, and the 256-comparison maximum. Comparison requires
every logical row to be byte-for-byte equal across all profiles. The only
permitted semantic transcript difference is declared availability: macOS and
ARMv6 report realizations `0,1`; the nRF composition requires and exposes only
bitmap realization `0`.

Every driver also records compiler identity and hash, exact target and flags,
repository revision and dirty state, input/generator/catalogue/manifest/payload
hashes, required and available realization IDs, and hardware-free evidence
labels. Pi and nRF results are cross-built inspection only; no remote access,
deployment, restart, connected-target execution, or flashing occurred.

## Reproduction

```text
scripts/contracts/run-spec-005.sh --profile macos-dynamic
scripts/contracts/run-spec-005.sh --profile macos-static
scripts/contracts/run-spec-005.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-005.sh --profile nrf52840-embedded
scripts/contracts/compare-spec-005-profile-semantics.rb
```

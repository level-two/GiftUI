# SPEC-014 T7.5 Transaction and Failure Corpus

Date: 2026-09-13

`transactions.yaml` now contains the complete reservation, producer-body,
and responsibility-transfer cross-product. It records all five body results
before and after transfer, every no-body reservation exit, exact cleanup and
forced-finish counts, and the ten required invalid writer/reservation uses.

`failures.yaml` records the ordered fifteen-stage detection sequence, every
`RasterBackendError` and `DisplayTargetError` mapping, simultaneous-stage
precedence fixtures, the three legal operational reservation outcomes, and
all seven constructed reservation failures that must become contract
violations without invoking the producer. It also fixes pre-transfer
abortability, post-transfer draining, one health update, immutable capability
state, and omitted/selected/saturated/dropped/failing diagnostic modes.

The semantic checkers require exact row sets and ordering. Focused Swift tests
execute every display reservation failure, all legal and impossible body/error
combinations, writer grammar misuse, payload submission misuse, and accepted
responsibility behavior.

Run from the repository root:

```sh
scripts/contracts/check-spec-014-fixtures.rb
scripts/contracts/check-spec-014-transactions.rb
scripts/contracts/check-spec-014-failures.rb
swift test --filter OneShotRasterBackendEndpointTests
swift test --filter DisplayWriterTests
swift test --filter DisplaySubmissionTests
```

All fixture checks and focused tests pass.

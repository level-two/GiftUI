# T7.2 Signal Analyzer Approval Fixture

The host approval fixture runs one successful layout with the exact limits
`512 / 64 / 4096 / 512 / 4096`. Its semantic surface contains nested vertical,
horizontal, and overlay containers; direct spacers; zero and explicit spacing;
leading/center and top/center/bottom alignments; empty, composite, explicit,
and all-edge padding; fixed, minimum, finite-maximum, and infinite frames; and
SPEC-005 reference-metric text.

Observed high water for the fixture is 24 scopes, depth 5, 10 text scalars,
2 text lines, and 9 positioned glyphs. These are approval-fixture observations,
not production host budgets.

Reproduce with:

```sh
swift test --filter signalAnalyzerApprovalFixture
```

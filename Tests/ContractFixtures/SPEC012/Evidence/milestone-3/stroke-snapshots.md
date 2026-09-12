# SPEC-012 Stroke Snapshot Evidence

Plan task: `SPEC-012 T3.4`

`StrokeSnapshotProducer` validates the complete live Path and style before
calculating the whole additional stroke, point, subpath, and normalized-
operation demand with checked `UInt16` arithmetic. It compares every demand to
the independent attempt limit before making one atomic append through
caller-owned plan storage.

Focused fixtures cover two ordered snapshots of a Path that is mutated between
submissions, preserving the earlier record and all explicit subpaths. Empty
and one-point Paths each append one canonical no-op record. The tests also
prove exact color/style/origin/clip headers, equality-limit success,
nonpositive-width `.invalidValue`, over-limit-width `.capacityExhausted`, first
whole-plan excess without mutation, and malformed in-range Path data rejected
as `.invariantViolation` before append.

Reproduce from the repository root:

```text
swift test --filter StrokeSnapshotTests
scripts/contracts/check-spec-012-module-contract.rb
scripts/contracts/check-spec-012-value-profiles.sh --profile macos-dynamic
scripts/contracts/check-spec-012-value-profiles.sh --profile macos-static
scripts/contracts/check-spec-012-value-profiles.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-012-value-profiles.sh --profile nrf52840-embedded
```

The four optimized compilers accept the same generic validation and snapshot
engine, including the fixed static Embedded Swift profile. Concrete profile
storage remains responsible for implementing its final append atomically.

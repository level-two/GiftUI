# SPEC-009 Focused Owner Failure Evidence

`RecordingFixtureOwnerFailure` is a finite inline fixture sum spanning mutation,
completion, semantic, layout, and immutable-render-input boundaries. The
selection seam captures its first exact value together with the detecting
`ExecutionContext`; subsequent focused failures are observed too late to
replace either value.

The test matrix crosses every fixture failure with all 32 simultaneous subsets
of the five injected cleanup-fault bits. Every row still completes partial-
result discard, candidate abort, scratch release, borrow release, and summary
production before returning the original `.focusedOwner` failure and context.
Diagnostic-write and mechanical cleanup failures are recorded as evidence but
cannot become a generic execution error, diagnostic carrier, or replacement
primary failure.

Layout probes enforce the Specification's inline bound: the concrete focused
failure remains no larger than four bytes and its specialized
`RunCycleFailure` remains no larger than eight bytes.

Reproduce the focused evidence with:

```sh
swift test --filter RecordingFocusedFailureSelectionTests
scripts/contracts/check-spec-009-focused-failures.rb
scripts/contracts/run-spec-009.sh --profile macos-dynamic
scripts/contracts/run-spec-009.sh --profile macos-static
```

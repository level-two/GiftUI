# SPEC-002 Contract Fixtures

This directory contains only fixtures and evidence derived from the approved
SPEC-002 contract. No source or helper is copied from the `PoC` tag.

## Layout

```text
Fixtures/
  Positive/<fixture-id>/main.swift
  Negative/<fixture-id>/main.swift
  Negative/<fixture-id>/expected-diagnostic-patterns.txt
Evidence/<milestone>/
fixture-manifest.tsv
DependencyGraphCases/
```

`fixture-manifest.tsv` is the checked-in, ordered fixture registry. Every row
has a stable identifier, an expectation (`pass` or `fail`), an access context
(`public` or `package`), an entry-point path, and an optional
diagnostic-pattern path. Drivers must execute rows in
file order and must reject duplicate identifiers, unknown expectations,
missing entry points, and unregistered fixture directories.

Positive fixtures must compile and, when they contain an executable assertion,
run successfully. Negative fixtures must fail compilation for every
non-comment, non-empty fixed-string pattern in their diagnostic-pattern file.
An unexpected success, a failure without all expected patterns, or an
unrelated compiler failure is a contract failure. Drivers normalize only
temporary absolute paths; they do not rewrite compiler diagnostics or bless
new output automatically.

Each fixture owns a single `main.swift` entry point so the same source can be
compiled by the profile-specific command selected by
`scripts/contracts/run-spec-002.sh`. Fixtures may import only declarations
needed by their stated contract. Test-only shims, PoC compatibility helpers,
and fallback implementations are forbidden.

Public fixtures compile as external clients. Package fixtures compile with the
same checked-in package identity as `GiftUI`, solely to exercise package SPI;
negative fixtures are always public so package access cannot mask a forbidden
boundary.

Generated output has one deterministic root:

```text
.build/contract-reports/spec-002/<profile>/
```

Within a profile, fixture output belongs under `fixtures/<fixture-id>/` and
profile metadata belongs in `metadata.txt`. Re-running a profile replaces its
own report directory and must not modify another profile. Stable milestone
transcripts selected for review are copied deliberately to
`Evidence/<milestone>/`; generated report trees are never committed.

`DependencyGraphCases/` contains synthetic checker regressions, not Swift
compile fixtures. Its unknown-edge case must reject an undeclared owner, and
its cycle case must fail the independent cycle check even when the declared
and actual edges match.

The standalone SPEC-002 entry points are the four commands required by the
Specification:

```sh
scripts/contracts/run-spec-002.sh --profile macos-dynamic
scripts/contracts/run-spec-002.sh --profile macos-static
scripts/contracts/run-spec-002.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-002.sh --profile nrf52840-embedded
```

The repository-level registry and aggregate entry point are introduced by
implementation-plan task `T1.5`; their registration cannot weaken these
standalone commands.

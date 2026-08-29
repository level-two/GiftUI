# SPEC-004 Contract Fixtures

This directory contains fixtures and evidence derived only from approved
SPEC-004. It defines a deterministic hardware-free seam for the pure
capability leaf and resolver; it does not substitute for runtime, backend,
host, failure, one-shot consumer, or connected-hardware integration.

## Layout

```text
Fixtures/
  Positive/<fixture-id>/main.swift
  Negative/<fixture-id>/main.swift
  Negative/<fixture-id>/expected-diagnostic-patterns.txt
SemanticCorpus/
  cases.tsv
  adapter-boundary.md
ResourceHarness/
  Baseline/
  Candidate/
Evidence/<milestone>/
fixture-manifest.tsv
```

`fixture-manifest.tsv` is the ordered compile-fixture registry. Every data row
has five tab-separated fields: stable identifier, `pass` or `fail`, `public`
or `package`, one Swift entry point, and either `-` or the negative fixture's
fixed-string diagnostic-pattern file. Drivers must reject duplicates, unknown
tokens, missing files, unregistered fixture directories, unexpected success,
and missing diagnostic patterns.

`SemanticCorpus/cases.tsv` is the ordered normalized input registry. Drivers
must hash and execute the same rows in the same order for every profile.
Typed-resolver rows and raw-adapter rows remain distinct as described beside
the corpus; malformed raw inputs are never manufactured as valid typed values.

Matched resource inputs live under `ResourceHarness/Baseline` and
`ResourceHarness/Candidate`. Generated inputs use exactly:

```text
.build/contract-generated/spec-004/<profile>/
```

Reports use exactly:

```text
.build/contract-reports/spec-004/<profile>/
```

Re-running one profile replaces only that profile's generated and report
directories. Stable selected transcripts may be copied deliberately to
`Evidence/<milestone>/`; generated trees are never committed.

## Evidence labels

- **Hardware-free host evidence** runs pure fixtures locally. It proves
  portable semantics and host-observed behavior only.
- **Hardware-free cross-built evidence** compiles and inspects pinned ARMv6 or
  nRF images without remote access, deployment, execution, or flashing. It
  proves target/compiler/binary facts, not connected-device behavior.
- **Connected-target evidence** requires an owning integration and separate
  user authorization. No SPEC-004 task requires it, and no SPEC-004 contract
  command deploys, restarts a service, or flashes hardware.

The exact four standalone driver commands arrive in plan task `T0.3`; their
registration must preserve hardware-free behavior.

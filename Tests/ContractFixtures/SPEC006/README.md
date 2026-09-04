# SPEC-006 Contract Fixtures

This directory contains fixtures and evidence derived only from approved
SPEC-006. It establishes the deterministic, backend-free seam for Rank 0
declarations and bounded semantic expansion. It does not define layout,
rendering, state ownership, interaction dispatch, capabilities, backends,
runtime-profile policy, host policy, or connected-hardware behavior.

## Layout

```text
Fixtures/
  Positive/<fixture-id>/main.swift
  Negative/<fixture-id>/main.swift
  Negative/<fixture-id>/expected-diagnostic-patterns.txt
SemanticCorpus/
  README.md
  cases.tsv
  canonical-transcript.tsv
  normalized-results.tsv
Instrumentation/
Evidence/<milestone>/
fixture-manifest.tsv
```

`fixture-manifest.tsv` is the ordered compile-fixture registry. Every data row
has six tab-separated fields: a unique lowercase kebab-case identifier,
`pass` or `fail`, `public` or `package`, one Swift entry point, either `-` or
the negative fixture's fixed-string diagnostic-pattern file, and a sorted
comma-separated module allowlist. Drivers must reject duplicates, unknown
tokens, missing or unregistered files, unexpected compilation results, and
missing expected diagnostics. The registry begins empty and is populated only
by the implementation task that owns each compile fixture.

The profile-neutral semantic input, canonical transcript, and normalized
result schemas are fixed in `SemanticCorpus/README.md`. Their registries begin
empty; later tasks must add rows in stable order and may not introduce
profile-specific reinterpretation.

Generated inputs use exactly:

```text
.build/contract-generated/spec-006/<profile>/
```

Reports use exactly:

```text
.build/contract-reports/spec-006/<revision>-<input-set>/<profile>/
```

Stable review evidence may be copied deliberately to `Evidence/<milestone>/`.
Generated and report trees are never committed.

## Evidence labels

- **Hardware-free host evidence** executes pure declaration and semantic
  fixtures locally. It proves portable semantics and host-observed behavior.
- **Hardware-free cross-built evidence** compiles and inspects pinned ARMv6 or
  nRF52840 images without remote access, deployment, execution, or flashing.
  It proves compiler, target, ABI, ELF, layout, and static-image facts only.
- **Simulator evidence** executes through an explicitly named simulator
  integration. It cannot be relabeled as connected-target evidence.
- **Connected-target evidence** executes on an explicitly selected physical
  target and requires an owning integration plus separate user authorization.
  No SPEC-006 contract command deploys, restarts a service, or flashes a board.

The exact four standalone commands and fail-closed report checks arrive in
plan task `T0.3`; this fixture contract does not claim they exist yet.

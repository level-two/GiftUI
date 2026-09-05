# SPEC-010 Contract Fixtures

This directory contains fixtures and evidence derived only from approved
SPEC-010. It establishes the deterministic, profile-neutral seam for portable
observable reference state, generated host discovery, owner reconciliation,
reporting, and target-generation lifetime. It does not define application
models, Interaction, runtime-profile capacities, host policy, backends,
platform scheduling, drivers, or connected-hardware behavior.

## Layout

```text
Fixtures/
  Positive/<fixture-id>/main.swift
  Negative/<fixture-id>/main.swift
MacroExpansion/
  cases.tsv
  Expected/<fixture-id>.swift
SemanticCorpus/
  cases.tsv
  canonical-transcript.tsv
  normalized-results.tsv
Instrumentation/
Evidence/<milestone>/
fixture-manifest.tsv
required-evidence.tsv
```

`fixture-manifest.tsv` is the ordered compile registry. Every row has six
tab-separated fields: unique kebab-case ID, `pass` or `fail`, `public` or
`package` access, Swift entry point, `-` or a fixed-string diagnostic-pattern
file, and a sorted comma-separated module allowlist.

`MacroExpansion/cases.tsv` is the ordered generation registry. Every row names
one source fixture, one expected byte-stable expansion or `-`, one expected
diagnostic file or `-`, and an evidence class. Generated source is build input;
it is never runtime discovery or profile authority.

The semantic registries contain symbolic location, ordinal, attachment,
generation, phase, dirty, and wake observations. They may not contain model
addresses, metatype addresses, callable identity, string structural paths, or
profile-private storage bytes. Dynamic and static implementations normalize to
the same rows.

`required-evidence.tsv` contains exactly `OS-001` through `OS-012`. Every row
starts `pending`; a task may change a row only when all named evidence exists.
Drivers must report incomplete conformance while any row remains pending.

Generated inputs use `.build/contract-generated/spec-010/<profile>/`. Reports
use `.build/contract-reports/spec-010/<revision>-<input-set>/<profile>/` and
are never committed.

## Evidence labels

- **Host evidence** executes pure macro, owner, and semantic fixtures locally.
- **Cross-built evidence** compiles and inspects ARMv6 or nRF52840 artifacts;
  it does not imply target execution.
- **Simulator evidence** requires an explicitly named simulator.
- **Connected-target evidence** requires an explicitly selected physical
  target and separate user authorization.

No SPEC-010 contract command deploys, restarts a service, flashes a board, or
claims connected execution. The exact four driver commands arrive in T0.3.

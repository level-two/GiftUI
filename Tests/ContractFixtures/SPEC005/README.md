# SPEC-005 Contract Fixtures

This directory contains fixtures and evidence derived only from approved
SPEC-005. It establishes one deterministic hardware-free seam for the exact
text-resource contract. It does not promote SPIKE-005 code into production or
substitute for layout, rendering, raster-provider, backend, host, simulator,
or connected-hardware integration.

## Layout

```text
Fixtures/
  Positive/<fixture-id>/main.swift
  Negative/<fixture-id>/main.swift
  Negative/<fixture-id>/expected-diagnostic-patterns.txt
SemanticCorpus/
  README.md
  cases.tsv
ProfileCorpusProbe/
ResourceHarness/
  Baseline/
  Candidate/
Instrumentation/
Evidence/<milestone>/
fixture-manifest.tsv
```

`fixture-manifest.tsv` is the ordered compile-fixture registry. Every data row
has six tab-separated fields: a stable lowercase kebab-case identifier,
`pass` or `fail`, `public` or `package`, one Swift entry point, and either `-`
or the negative fixture's fixed-string diagnostic-pattern file, followed by a
sorted comma-separated module allowlist. Drivers build a fixture-local import
root containing only those modules and their declared dependencies, execute
both file and reverse order, and reject duplicate identifiers, unknown tokens,
missing files, unregistered fixture directories, unexpected compilation
success, and missing diagnostic patterns. Negative fixtures are always public.

`SemanticCorpus/cases.tsv` is the ordered normalized input registry shared by
all profiles. Its schema is defined in `SemanticCorpus/README.md`. A driver
must hash and process the same rows in the same order without profile-specific
addition, omission, reordering, or reinterpretation.

`ResourceHarness/Baseline` and `ResourceHarness/Candidate` are matched roots
for later linked-resource measurements. The roots must retain equal entry
signatures, compiler and linker modes, corpus inputs, and observable sinks;
only the candidate may reference the production SPEC-005 implementation.

Generated inputs have exactly one deterministic root:

```text
.build/contract-generated/spec-005/<profile>/
```

Reports have exactly one deterministic root:

```text
.build/contract-reports/spec-005/<profile>/
```

Re-running one profile replaces only that profile's generated and report
directories. Stable review evidence may be copied deliberately into
`Evidence/<milestone>/`; generated trees are never committed.

## Evidence labels

- **Hardware-free host evidence** executes pure contract fixtures on the local
  host. It can prove portable semantics and host-observed behavior only.
- **Hardware-free cross-built evidence** compiles and inspects the pinned
  ARMv6 or nRF52840 target image without remote access, deployment, execution,
  or flashing. It can prove compiler, target, ELF, section, disassembly, and
  static-resource facts, but not connected-device behavior.
- **Simulator evidence** executes through a named simulator integration. It
  must identify that simulator and cannot be relabeled as physical display or
  connected-target evidence.
- **Connected-target evidence** executes on an explicitly selected physical
  target and requires an owning integration plus separate user authorization.
  No independent SPEC-005 contract command deploys, restarts a service, or
  flashes hardware.

The exact four standalone driver commands arrive in plan task `T0.3`. Their
registration must preserve these evidence boundaries.

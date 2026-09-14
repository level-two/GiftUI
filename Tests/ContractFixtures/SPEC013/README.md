# SPEC-013 Contract Fixtures

This directory contains the profile-neutral fixture and evidence schemas for
the approved SPEC-013 runtime-profile contract. The corpus fixes artificial
limits, canonical value transcripts, acceptance evidence, report metadata,
and evidence classification before either runtime profile claims behavior.
It does not select production capacities, a backend, host policy, retry
policy, platform implementation, or connected hardware.

## Canonical registries

`fixture-manifest.tsv` orders every canonical YAML corpus. Each document has
`schema: spec-013-v1` and a `cases` sequence. Later owning tasks add complete
cases without changing the frozen field vocabulary to fit an implementation.
Case names are globally unique lowercase kebab-case, cite one or more
`RP-001` through `RP-015` criteria, and name only registered evidence classes.

`artificial-limit-schema.tsv` names every input leaf used to construct the
same deliberately small `RuntimeProfileLimits` in both profiles. A fixture
records an exact-limit value and changes only its named variation field for a
first-excess or incompatibility case. Production host values are outside this
schema and remain owned by SPEC-015.
`artificial-limit-values.tsv` supplies the exact numeric value for every leaf
so each normalized profile report records the complete artificial limit set.

`canonical-transcript.tsv` is the closed, ordered vocabulary for normalized
cross-profile observations. Comparison is value-for-value and includes exact
focused failures, mappings, cleanup, and lifecycle results. Addresses,
profile-private bytes, allocation strategy, generated-code addresses, and
diagnostic volume are explicitly excluded.

`required-evidence.tsv` contains exactly the fifteen SPEC-013 acceptance
criteria and begins fail-closed. A criterion remains `pending` until its
owning task records reproducible evidence. `report-schema.tsv` fixes the
required metadata and measurement fields for all four exact driver modes.

`Instrumentation/` contains bounded, profile-neutral resource counters, a
macOS allocation/peak-byte interposer, and the exact measurement-method
registry. These mechanisms do not themselves constitute collected profile,
forbidden-facility, ELF, pristine-build, or connected-hardware evidence.

## Evidence classification

- `host-execution` runs a fixture on the build host.
- `cross-build` compiles or links a non-host artifact without executing it.
- `inspection` examines source, interfaces, SIL/IR, symbols, sections, stack,
  link maps, images, value layouts, or ELF attributes.
- `simulator` executes through an explicitly named simulator.
- `connected-hardware` executes on a separately authorized physical target.

Cross-build and inspection results for Raspberry Pi or nRF52840 are
hardware-free evidence. Nothing in this directory deploys, accesses a remote
target, restarts a service, or flashes a board.

# SPEC-009 Contract Fixtures

This directory contains the profile-neutral execution-cycle fixtures derived
from approved SPEC-009. The corpus fixes the recording seam for phase order,
admission, publication, one-shot handoff, refusal recovery, provenance,
focused-owner failure preservation, and the Signal Analyzer workload. It does
not define runtime-profile storage, render behavior, observable-state storage,
interaction lowering, backend policy, host pacing, or connected-hardware
behavior.

## Registries

`fixture-manifest.tsv` orders exactly six YAML fixture files and declares the
domain-specific fields each may add to the shared fields in
`shared-fields.tsv`. `phase-vocabulary.tsv` is the closed symbolic event
vocabulary for canonical phase transcripts. `normalized-schema.tsv` fixes the
profile-neutral result, failure, and operational records. `required-evidence.tsv`
contains exactly `EX-001` through `EX-014` and begins fail-closed.

Every YAML document has `schema: spec-009-v1` and a `cases` sequence. A case
must contain every shared field, use explicit `none` for an inapplicable field,
contain only the extra fields registered for its file, and name one or more
acceptance criteria. Case names are kebab-case and globally unique. Symbolic
identities use `<namespace>:<decimal>` with one of the namespaces in
`identity-rules.tsv`; pointer, address, hash, closure, metatype, and
profile-private identity representations are forbidden.

The initial YAML files intentionally contain no cases. Later owning tasks add
complete cases without changing the frozen schema. The harness rejects a
populated case that has no criterion reference, an unknown criterion, or a
criterion that does not reciprocally list the case.

## Evidence labels

- `host-execution` runs pure focused fixtures on the host.
- `cross-build` compiles a non-host artifact without executing it.
- `inspection` examines layouts, symbols, sections, stack, or link maps.
- `simulator` requires an explicitly named simulator.
- `connected-hardware` requires a separately authorized physical target.

No SPEC-009 contract fixture deploys, restarts a service, flashes a board, or
claims connected-hardware execution.

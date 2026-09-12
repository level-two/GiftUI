# SPEC-014 Contract Fixtures

This directory owns the profile-neutral fixture and evidence schema for the
approved SPEC-014 raster backend and display integration contract. The schema
is frozen before production behavior is claimed. Later tasks populate cases
without weakening or adding implementation-private shared fields.

## Canonical corpora

`fixture-manifest.tsv` registers exactly five ordered YAML documents. Each
document has `schema: spec-014-v1` and a `cases` sequence. Case identifiers are
globally unique lowercase kebab-case values, cite one or more `BI-001` through
`BI-015` criteria, and use only the registered profiles and evidence classes.

Every case contains all fields in `shared-field-schema.tsv`. A field that does
not apply is the literal string `none`; omission is invalid. The schema checker
rejects missing or unknown fields, duplicate fixture identifiers, unknown
criteria/profiles/evidence classes, and cases that are not referenced by the
acceptance registry.

The five corpora have these responsibilities:

- `raster.yaml`: canonical operation, clipping, damage, logical-pixel, byte,
  segmentation, and cross-realization expectations.
- `transactions.yaml`: reservation, writer, payload, transfer, cancellation,
  drain, and reservation-identity scripts.
- `capabilities.yaml`: contribution, effective-value, descriptor, startup
  reconciliation, and the four exact MVP configurations.
- `failures.yaml`: detection precedence, retained local error, SPEC-003
  mapping, health transition, drain, and diagnostic-isolation expectations.
- `resources.yaml`: limits, value layouts, ownership, allocation, stack,
  linked-symbol, high-water, and timing conditions.

## Evidence boundary

`required-evidence.tsv` begins fail-closed with every acceptance criterion
pending. Its `cases` field is `-` only while no case has been frozen for that
criterion. Once a case exists, it must be referenced by at least one criterion
row, and every reference must name a case in exactly one registered corpus.

`module-owners.tsv` freezes each SPEC-014 production, test, and narrow failure-
adapter owner with its exact direct dependencies. Owners begin `reserved` so
T0.2 does not create empty placeholder modules. An owner becomes `active` only
in the same change as its first substantive source, `Package.swift` entry, and
SPEC-002 exact target-dependency row. `dependency-fixtures.tsv` records the
positive and negative graph examples that the module checker must classify.

Cross-build and inspection evidence for Raspberry Pi or nRF52840 is hardware-
free. These fixtures do not deploy, access a remote target, restart a service,
or flash a board, and they cannot establish connected-hardware conformance.

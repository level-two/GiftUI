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

Milestone 4 adds three raster cases: a mixed recording-surface transcript with
odd stride and damaged-subrect painter replacement, an explicit import of all
17 independently frozen SPEC-012 stroke vectors, and a pre-output translated-
point overflow. The recording endpoint is test evidence only; it does not
select a production surface realization or submission strategy.

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

`migration-inventory.tsv` records the authoritative disposition for current
owner seams and the relevant historical `PoC` renderer, surface, framebuffer,
tile, display, text-raster, platform, device, and test families. Prefix rows
cover every file below that historical component root. The migration checker
also verifies that retired component roots remain absent from maintained
source and runs synthetic pattern regressions for the forbidden legacy shapes.

`declaration-compile-fixtures.tsv` registers negative import boundaries that
compile in an isolated transitive visibility closure for each owner. The
positive compile-surface fixture supplies concrete conformers for all five
normative protocols and generic `Sendable` constraints for all eight values.
`Instrumentation/BackendValueLayoutProbe.swift` emits constant size, stride,
and alignment facts from each pinned 32-bit and 64-bit compiler; the profile
checker enforces the exact SPEC-014 ceilings before stateful implementations.

`macos-host-input.yaml` is the single immutable paired-test logical extent for
the macOS dynamic and static capability cases. It does not select or imply a
production window size. `capabilities.yaml` freezes those equal logical
results alongside the exact Pi and nRF tiled results and the nRF full-
framebuffer rejection.

Milestone 7 completes the transaction corpus with the full reservation/body/
transfer result matrix and every required writer misuse. The failure corpus
freezes the normative detection order, all raster/display local mappings,
legal reservation outcomes versus impossible constructed failures, accepted
drain and health behavior, and the five diagnostic modes. Dedicated semantic
checkers reject missing rows, precedence changes, or reopened responsibility.

Cross-build and inspection evidence for Raspberry Pi or nRF52840 is hardware-
free. These fixtures do not deploy, access a remote target, restart a service,
or flash a board, and they cannot establish connected-hardware conformance.

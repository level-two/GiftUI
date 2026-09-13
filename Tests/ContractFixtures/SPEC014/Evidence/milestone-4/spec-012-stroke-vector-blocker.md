# SPEC-014 T4.4 — SPEC-012 Stroke Vector Blocker

Date: 2026-09-13

## Disposition

`T4.4` remains open and upstream-blocked. SPEC-014 can consume the approved
borrowed `StraightLineStrokeView`, but it cannot implement and prove “every
SPEC-012 canonical straight-line stroke vector” because the owning checked-in
corpus and independent oracle are not complete.

## Reproduction

From the repository root:

```sh
ruby -ryaml -e 'document = YAML.safe_load(File.read("Tests/ContractFixtures/SPEC012/raster-vectors.yaml")); abort "expected empty pending corpus" unless document == {"schema" => "spec-012-raster-vectors-v1", "vectors" => []}'
rg -n 'T8\.1|T8\.2' docs/implementation-plans/spec-012-implementation-plan.md
```

Observed authoritative state:

- `Tests/ContractFixtures/SPEC012/raster-vectors.yaml` contains `vectors: []`;
- SPEC-012 `T8.1` (freeze the complete normative vectors) is unchecked;
- SPEC-012 `T8.2` (build the independent oracle) is unchecked;
- SPEC-012 criterion `DR-006` remains pending without case evidence.

## Boundary

The replaceable SPEC-014 scan-conversion direction is documented in
`docs/implementation-designs/spec-014-widened-integer-stroke-raster.md`.
That note is not an independent semantic oracle and cannot substitute for
SPEC-012's owned golden masks. Generating both implementation output and
expected vectors from the same SPEC-014 algorithm would be circular evidence.

No SPEC-012 task, corpus, or acceptance status was changed. No approximate,
floating-point, native-style, or self-authored fallback vector was admitted.
`T4.6`, Milestone 5 equivalence, Milestone 6 stroke equivalence, and BI-009
remain blocked behind this dependency.

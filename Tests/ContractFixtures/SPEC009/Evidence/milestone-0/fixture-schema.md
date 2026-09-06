# SPEC-009 Fixture Schema Evidence

Plan task: `SPEC-009 T0.1`

The ordered manifest registers exactly the six normative YAML files from
SPEC-009. Every file uses `spec-009-v1`, begins with an empty ordered case
sequence, and is validated against one shared-field schema plus its explicit
domain additions. The frozen phase and normalized-record registries compare
symbolic semantics rather than profile-private bytes.

`scripts/contracts/check-spec-009-harness.rb` validates the schema without
claiming behavior that belongs to later tasks. It rejects missing or extra
fixture documents, malformed registries, duplicate or unknown cases and
fields, absent shared fields, invalid evidence labels, non-reciprocal
criterion references, and forbidden identity representations. All fourteen
acceptance rows remain `pending`, so the scaffold is fail-closed.

Evidence classifications distinguish host execution, cross-build, inspection,
simulator, and connected-hardware results. This task performs no deployment,
service restart, board access, or flashing.

Reproduce from the repository root:

```text
ruby scripts/contracts/check-spec-009-harness.rb
```

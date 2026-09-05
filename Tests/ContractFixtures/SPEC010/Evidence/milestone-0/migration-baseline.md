# SPEC-010 Migration Baseline

Plan task: `T0.4`

Date: 2026-09-05

The machine-checked `migration-inventory.tsv` is derived from the immutable
`PoC` tag at `d5d6330432caa7c983d8dba35cf9f23c3800860b`. Its rows reproduce the
removed prototype's portable `@State` spellings, task-local binding context,
string-backed `StateKey`, heterogeneous `Any` store, existential storage seam,
runtime-specific state files, and direct thermostat mutation sites.

The baseline contains 15 `@State` spellings across six paths (including one
documentation mention), five task-local binding-context spellings across
three paths, 15 `StateKey` spellings across seven paths, two heterogeneous
stores, eight existential storage uses, eight runtime-specific state paths,
and six direct thermostat mutation sites. Neither the PoC nor current
maintained source imports Apple Observation or uses `@Observable`; that
already-absent dependency is retained as an explicit evidence-only row.

Completed SPIKE-003 and SPIKE-006 contribute nine disposable declaration
spellings across five experiment files. They remain evidence-only: maintained
source cannot refer to those experiments, and none of their concrete storage,
capacity, or generated forms is implementation authority.

Every inventory row uses one of the plan's four dispositions: `remove`,
`replace-through-owner`, `downstream-owned`, or `evidence-only`.
`check-spec-010-migration.rb` pins the PoC tag, reproduces path/count maps,
verifies every removed runtime path remains absent, rejects the legacy and
Apple-only mechanisms in maintained Swift, and reproduces the current Spike
inventory. The SPEC-010 driver registers and executes the check before any
profile compilation.

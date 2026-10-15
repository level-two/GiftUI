# P08 narrow predicate correction — independent source review

**SOURCE PASS at `c9c69770`.** The exact two-helper Swift diff implements the
user-approved mechanical correction; no source blocker is found in this scope.
Compiler acceptance remains pending the one authorized measurement rerun.

CounterPipelineOwner.swift:73–91 evaluates seven vacancy and four claim predicates
independently into owned Bools before combining them. Mechanical substitution of
the local aliases reproduces every original field expression, equality, phase
alternative, Boolean grouping and final assertion exactly. The eleven field-read
initializers contain no short-circuit closures; subsequent Boolean RHS closures
read only owned locals. Only pure field predicates become eager. No baseline,
whole-control copy, owner, cleanup path, lifetime or capability changes. Replacing
the two current helper bodies with their predecessors reconstructs the entire
original Swift file byte for byte; no other Swift file changed.

The [freeze](p08-control-resident-predicate-source-freeze.md),
[manifest](control-resident-predicate-source/manifest.json) and exact patch verify.
Both source/glue before/after hashes match. Qualification SHA-256 is
`27cb807261cb84561b603fadc35287cc8f80174e6888cae3d78e42e91ca7bdd0`;
the driver changes only its exact path/hash/activity pins and retains its checks.
All eight current candidate hashes match. All seven receipt entries are identical
to the reviewed predecessor and their actual receipt hashes match; only the
pipeline candidate hash changed. The unchanged 895-input proof was not repeated.
Driver Python AST checks pass. No compiler, test, build, runtime, image or source
edit was performed by this review.

The narrow fix is **1/1 frozen, rerun 0/1**; prior grouped 2/2 and all older budgets
remain closed. Proceed once with the exact command below. This source PASS does
not authorize another repair variant or predict later compiler acceptance. The
old 32,000-byte reservation remains unchanged; strict actual facts must precede
any planned exact measured Swift/C completion. A sizing mismatch must remain a
failed validation with raw facts accepted=false, never a false SO07 pass. The
partial screen cannot close P08/R07/T8.1/HC-RD-003 or establish runtime/stack fit.

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded --host-build .build/contracts/p08-scoped-host-hzs5q7za --collect-failures --fresh-focused --select-family so07-layout-facts
```

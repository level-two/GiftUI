# P08 narrow predicate correction — source freeze

Eugene explicitly approved “Please proceed” to the mechanical predicate fix,
independent source review and **one** same focused measurement rerun. This is a
new narrow allowance: one source fix frozen, rerun 0/1, zero extra automatic
variants. The prior control-resident correction 2/2 and all older budgets remain
closed. Baseline `e866e55d`; the [final prior failure](p08-control-resident-final-result.md)
and its original source/logs remain immutable. No compiler/build/runtime/image
ran during this correction; source review and compiler acceptance are pending.

Only the two approved `CounterControl` borrowing helpers change Swift code.
`requireVacantRuntimeSlot` evaluates seven original stored-field predicates into
independent owned Bools; `requireRuntimeClaim` does so for four. Their Boolean
combinations now capture only owned local Bools. Mechanically expanding the
aliases reproduces each original expression exactly, with the same field/equality
order and final assertions. Only pure field tests become eager; no callback,
whole-control copy, baseline refresh, new owner or lifecycle change is introduced.
All identity/endpoint/backend observations, cleanup and original scopes remain.

The diff audit of all newly added borrowed declarations in `f7e56cf0..current`
found the same Boolean RHS field capture only in these two helpers. The private
cleanup helper already observes independent Bools. Both backend observers and
endpoint getters return owned facts directly; the semantic producer retains its
existing synchronous callbacks; recording initialization explicitly owns a copy.
This source audit does not guarantee that later compiler checks pass.

[Exact manifest](control-resident-predicate-source/manifest.json) and
[source patch](control-resident-predicate-source/source.patch) pin the two changed
source/glue files. CounterPipelineOwner SHA-256:
`4869af4f277ec2cad6ff5aadf053d316e69c378de674bb3cb6b55dc7fe4f5e47`.
Patch SHA-256: `9d77b0e9517be0554d3908b7920eac5206152c4f623b5ce6a2b5b7eba6faf376`.

[New applicability proof](p08-control-resident-predicate-applicability.json)
SHA-256 `27cb807261cb84561b603fadc35287cc8f80174e6888cae3d78e42e91ca7bdd0`
is pinned by the driver. All seven receipt hashes and exact compiler-argv
fingerprints are unchanged; eight candidate exclusions across all seven argvs and
the other seven candidate hashes were rechecked. The actual driver qualification
function verifies all eight metadata exceptions. The predecessor's exact complete
input/artifact/dependency proof is retained, not relabeled as a fresh compilation.
No changed compiled input can use this exclusion proof.

Compiler-free verification: exact inverse predicate/body comparison, six existing
backend observation/extension tests, Python AST/pin checks, and pinned host Swift
6.4 formatter all pass. Fixtures are outside formatter scope; no incidental source
changes occurred. `git diff --check` passes. No whole suite was run.

After independent source PASS, the parent may execute once:

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded --host-build .build/contracts/p08-scoped-host-hzs5q7za --collect-failures --fresh-focused --select-family so07-layout-facts
```

This rebuilds current preparation/counter inputs; 202 omitted controls remain
not-run, complete/passed aggregate flags false. The old 32,000-byte Swift/C slot
constants remain unchanged. A newly decoded larger actual minimum may yield the
already planned truthful sizing mismatch: raw facts remain unvalidated/accepted
false, strict decoding unchanged. No sizing update is permitted before actual
facts. New diagnostics or resource failure do not authorize another automatic
source variant. P08/R07/T8.1/HC-RD-003 remain open; no fit improvement is claimed.

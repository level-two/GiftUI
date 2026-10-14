# P08 suite collection — independent Strong source-readiness review

**Disposition: correct B01–B03 together before qualifying collection/reuse.**
Independent Sol 6.1 High review of harness `d6792a06` and the
[new batch authorization](p08-suite-collection-activity.md). Reviewed
`p08_check_collection.py`, `check-spec-015-counter.py`, `run-spec-015.sh` and
`test_p08_check_collection.py`. No source fix, compiler, full suite, probe,
formatter, actual runtime or subagent here. Parent's unrelated six current
navigation edits are excluded from this review commit.

Accepted ADR-039 and approved S11/S13/S15 remain authority. The current activity
permits collecting independent failures and grouped routine corrections/focused
validation, **at most two grouped corrective cycles**, with the cumulative
two-unproductive guard. Historical allowances remain immutable, but their old
per-run stops/zero-repair limits do not govern this new batch. These findings are
ordinary evidence/implementation defects within that authorization; no renewed
line/file permission or architecture/contract decision is required.

## Three concrete blockers

| Finding | Evidence and minimal correction invariant |
| --- | --- |
| **B01 — legacy import omits generation/dependency inputs** | `p08_check_collection.py:177–192` verifies normalized scoped-control argv, generated variant source and current Swift tokens in that control command against `cab1c415`. It does not check `Counter.swift`/`Counter.schema.json`, used by `check-spec-015-counter.py:170`, or the other rebuilt preparation-module sources. `verify_inputs:113–125` compares current inputs to predecessors only for focused reuse, not legacy import. Thus Counter.schema.json can change, preparation can successfully generate a different imported P08CounterSchema, and the old controls can still import because their own command/variant/source tokens are unchanged. Pin and verify the complete relevant generator/preparation inputs against the historical execution, including original schema/presentation source and implicit module dependencies, before importing any controls. Preserve compiler/macro/recipe identities and require successful preparation. Do not rely on merely rebuilding current modules as proof of historical equivalence. Add compiler-free coverage for generator/dependency drift; reject it or execute the affected controls freshly under the registered collection. |
| **B02 — target failure receipt overstates compiled evidence** | `check-spec-015-counter.py:353–355` unconditionally sets execution to “cross-compiled current selected counter host” and writes the output object inventory. Collection now permits `counter-model` to fail or be blocked and continues to this branch. Overall passed=False records the failure, but that execution text still claims a module that did not compile; a copied/partial object must not establish current success. Make target compile claims and valid object inventory conditional on successful required preparation/current counter module. Failed/blocked target checks must report unavailable compilation evidence, retaining their statuses rather than an unconditional success description. |
| **B03 — unselected observation-oracle drift is not checked** | `Collector.run:160–164` protects unchanged command/source/diagnostic identities, while `Collector.observation:215–219` has no oracle identity or family-selection comparison. The entire driver hash is exempted in `verify_inputs:120–122`. A focused driver edit can therefore upgrade an unselected failed runtime observation using an unchanged reused execution log. A mocked compiler-free reproduction seeded failed runtime-summary, selected only stable, reused execute, changed summary observation to true, and `finish()` returned true. Bind finite observation criteria/prerequisites/evidence to an identity and require changed families to be selected. Keep exact single-occurrence reuse and positive-count/zero-failure summary criteria; group runtime-summary consistently with runtime (family currently leaves it as its own stem). Add a focused observation-drift regression. Do not treat a changed unselected oracle as verified aggregate coverage. |

B01 concerns historical control equivalence, B02 truthful target dispositions,
and B03 focused aggregate acceptance. Bundle them into one coherent setup
correction/independent assessment rather than introducing another per-barrier
user stop. Fresh native collection without reuse does not have the B01/B03 reuse
gap, but the proposed imported/focused four-profile harness is not fully ready
until these obligations are corrected.

## Inspected sound mechanisms

- Newly executed commands journal numeric exit/status/identity/log hashes;
  running/interrupted journals are incomplete. Collection returns nonzero for
  any failed or blocked check and preserves the known legacy 192nd failure.
- Failed preparation blocks dependents. Every negative scoped control requires
  its positive twin; failure cannot be concealed by a later negative rejection.
  Known matcher mismatch keeps collecting independent controls. The native
  counter link needs the real counter module, and runtime labels/summary need
  successful execute; the five exclusivity checks form a separate prepared group
  whose negative execution requires its positive execution.
- Native object lists use only preparation modules, map counter-model to the
  actual P08CounterRuntime object and keep control objects out of the link.
  Exclusivity replaces that object with its own module rather than linking both.
- Focused command/source/oracle identities, compiled-input/collector hashes,
  compiler/recipe identities, artifact/log hashes, complete label-set coverage
  and retained unchanged failures are checked for command-based checks.
- The exact immutable legacy packet pin matches. Inferred historical exit classes
  remain explicit; no numeric negative codes are invented. Baseline registrations
  retain the known tuple matchers; structured alternatives constrain error sites,
  require recognized errors and reject crashes/prefix errors when used.
- The existing generator bodies/labels are unchanged; explicit scoped totals
  remain **384 non-Embedded / 202 Embedded**, five native exclusivity controls and
  thirteen reuse labels per selected route. Shell forwarding rejects collection
  options on the unrelated legacy corpus.

Checks pass: **12 compiler-free Python tests**, `bash -n run-spec-015.sh` and
scoped whitespace checks. The additional B03 reproduction used temporary files
and mocked subprocess outcomes only; it ran no actual compiler/runtime. These
tests exercise mechanics, not full evidence equivalence or Swift conformance.

All nine SO criteria, HC-RD-003/P08/R07/T8.1 and actual target/resource fit remain
open, including historical **58,648-byte failure / unchanged 27,648-byte
main-stack ceiling**. FW-038 remains deferred validation-cost work; no required
matrix is reduced. I4-07/P09–12/hardware/timing/lifecycle duties remain separate.
Current grouped cycles **0/2 consumed at review**; parent owns subsequent cycle
accounting, bundled harness correction, collection and navigation updates.

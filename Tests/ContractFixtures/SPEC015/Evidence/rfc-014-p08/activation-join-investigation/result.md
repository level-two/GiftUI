# P08 evidence-only investigation: held for accounting review — 2026-10-11

**Held pending independent guard-accounting interpretation. No further compiler
invocation is authorized while held. No production integration occurred.**
The maintainer's [bounded authorization](authorization.md) was committed as
`0bc51d70` before any fresh compiler invocation. Entry was clean `984a0afc`.
Strong Sol6.1 High, sequential, no delegation. Historical production repair guard
remains **2/2**, with no reset from this evidence-only allowance.

## Used allowance and actual result

Exactly **2/6 fresh compiler invocations**, **1/2 candidate internal layouts**,
**0 negative invocations**, no executable or target execution. CandidateA's
positive control did not pass; CandidateB and both negatives remain uncompiled.
All source snapshots, exact commands, complete stdout/stderr and identities are
preserved in [run1](run-1/result.json), [run2](run-2/result.json) and the
[current ledger](ledger.json). [Hashes](manifest.json) cover the evidence files.
The compiler was pinned Swift6.3.2, SHA256
`d8e40107da0e2c1c59640a983faea326d5d2bddfe81f7609db14bade43c4a5b9`.

| Fresh invocation | Scope | Actual result |
| --- | --- | --- |
| 1 | A positive initialization/activation/real caller | exit1: caller incorrectly used `consume` on two Copyable fields; no positive lifetime proof |
| 2 | SameA layout, exact two-token caller correction | exit1: activation self-lifetime escapes; internal noncopyable-copy diagnostics; imported non-frozen profile field-consumption errors |

Run1 source is retained separately from the corrected run2 caller. The only
caller correction removes `consume` before `profile.canvasBacking` and
`profile.workspace`; layoutA and supplied-owner source hashes are identical in
both invocations. The correction counts as a fresh compiler invocation, with
no free rerun. No negative followed a failed positive. No historical controls,
additional module builds, hidden probes, compiler changes or unsafe escape
workarounds were run.

Run2 [full stderr](run-2/stderr.txt) includes `lifetime-dependent variable 'self'
escapes its scope` at `activate()`, diagnostics literally describing `copy of
noncopyable typed value` as a compiler bug, and `cannot partially consume
'profile' of non-frozen type ... imported from 'RuntimeCycleProbe'` in the caller.
These mixed diagnostics establish neither a lawful construction pattern nor a
root-cause attribution. No isolated initializer pass, ownership rejection pass,
backing-lifetime pass, completed host or P08 acceptance is claimed.

## Guard accounting requiring independent interpretation

The runner conservatively counted both unsuccessful positive invocations as two
unproductive candidate attempts and stopped. The authorization names **two
consecutive unproductive candidate attempts**, while only one layout was used.
Run1 was caller setup; run2 exposed new diagnostics and a narrower activation
location. The parent requires independent read-only interpretation of that
literal approved condition before finalizing exhaustion or permitting any further
run. Neither the executor nor this receipt reclassifies the failures to continue.

The [original runner ledger after run2](ledger-after-run-2.json) preserves its
provisional count2 and stop text. The current ledger marks candidate accounting
unresolved, records both unsuccessful invocations and adds a hard hold before
any compiler launch. Four of the numerical six-call allowance are unused; unused
capacity is **not** continuation authority while held. CandidateB source is
prepared under the original second hypothesis and explicitly has no compile
result. No third layout exists.

## Provenance, scope and limitations

[Read-only identity verification](verified-inputs.json) confirms60 schema inputs/
83 artifacts,165 runtime inputs/143 artifacts, core receipt/GiftUI artifact and
compiler hashes. The original approved compiler flags/features were inherited;
only output/module-cache locations changed. The frozen actual modules are used
as dependencies, with no modification or rebuild.

The concrete positive caller enters actual model/root, semantic typed-array,
Canvas typed-array, layout/render/path/plan and control backing scopes before
initializing an inert owner. The attempted state stores supplied scopes before
activation; actual pipeline/endpoint, binding, admission and Static coordinator
constructors occur only inside `activate()` source. Compilation failed, so none
of this is a proven complete host pattern. The caller's imported non-frozen
partial-consumption issue remains unresolved. Evidence fixtures are isolated
from production and cannot be adopted without separate reviewed resumption.

P08 remains incomplete. Last validated maintained implementation is `c39733de`;
the prior schema and host component passes retain their limited applicability.
The full counter, all nine validation stages, actual endpoint/report/role audits,
cache tickets/replacement callbacks/frame lifetimes/partial teardown, four build
routes and early linked target-image checks remain open. P09, hardware, physical
resource/timing claims and package acceptance remain outside this investigation.
Next action is the parent's independent read-only accounting/result review and
resulting explicit disposition; no production resumption is inferred.

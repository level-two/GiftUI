# P08 evidence-only investigation: stopped — 2026-10-11

**No verified candidate. Both authorized layouts failed their positive controls;
compiler work is stopped. No production integration occurred.** Strong Sol6.1
High, sequential, no delegation. Authorization `0bc51d70` preceded every fresh
compile. The [accounting review](accounting-review.md), committed at `c05e6d35`,
permitted the fixed second layout under the original allowance, without a reset.

## Finite result and counters

Exactly **3/6 fresh compiler invocations**, **2/2 layouts**, **zero negatives**,
**zero passing controls**. Failed A is conservatively charged1/2 by independent
review; failed B is charged the second candidate attempt, **2/2**. The historical
production repair guard remains **2/2**, unchanged. Three unused numerical calls
are not continuation authority: both authorized layouts have been tried and
neither positive passed. No negative may establish ownership/lifetime proof after
a failed positive. No further compiler work or production resumption is inferred.

| Invocation | Control | Actual result |
| --- | --- | --- |
| [1](run-1/result.json) | A positive | exit1: two caller consumes of Copyable fields rejected |
| [2](run-2/result.json) | same A, exact two-token caller correction | exit1: activation self-lifetime, internal noncopyable-copy and imported non-frozen partial-consumption diagnostics |
| [3](run-3/result.json) | predeclared unchanged B, caller-only in-place lending correction | exit1: activate state transfer escapes self lifetime, activate/quiesce used-after-consume and internal noncopyable-copy diagnostics |

Run3 command: `python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/activation-join-investigation/run-one.py B positive`.
The [expanded compiler command](run-3/command.txt), [complete stdout](run-3/stdout.txt),
[complete stderr](run-3/stderr.txt), exact sources and hashes are retained. Its
caller-only correction borrows the actual imported `StaticCycleProfileStorage`
fields in an extension method with no added state, instead of partially consuming
them. It retains the profile's actual audit and model/root, semantic typed-array,
Canvas typed-array, geometry and control lending scopes. The concrete caller
constructs an inert owner, calls `activate()` and `quiesce()` within all scopes.
Imported-field consumption diagnostics are absent in run3; that observation is
not an isolated passing caller or initializer proof.

LayoutB and Supplied hashes remain respectively
`2fc421c3088b5504ebe732532113e102a930033d77ce53dc91c724e1b8c0a04a` and
`8f740852e5e627d2b2a16f6aba69a3bd3b12b87a8ab774731997a2fe2aaa0cf6`.
At `LayoutB.swift:22`, `state.take()` produces a lifetime escape depending on
argument `self`, used in the inert pattern capture. Both `activate()` and
`quiesce()` also report use-after-consume. Four diagnostics literally mention
noncopyable copies as a compiler bug; these mixed failures do **not** establish a
compiler root cause, language impossibility or correct host construction.
The candidate attempts share an unresolved actual activation ownership/lifetime
boundary; no passing control justifies another repair. No variant or third
layout was attempted. Both prepared negatives remain uncompiled.

## Identity, retained history and limits

Pinned Swift6.3.2 compiler SHA256:
`d8e40107da0e2c1c59640a983faea326d5d2bddfe81f7609db14bade43c4a5b9`.
[Verified identities](verified-inputs.json) cover60 schema inputs/83 artifacts,
165 runtime inputs/143 artifacts, core receipt/artifacts and compiler. The runner
rechecked its frozen schema inputs/artifacts and compiler before run3. No imported
module was rebuilt or changed, no compiler flags/features were added and no
historical controls were rerun. No executable or target run occurred.
[Manifest](manifest.json) covers the evidence; [ledger](ledger.json) is the current
stop. The [provisional original ledger](ledger-after-run-2.json) and
[held receipt](held-result-after-run-2.md) preserve the earlier accounting hold.
[Continuation](continuation.md) records the exact independently reviewed release
of that hold. Raw run1/run2 results are unchanged.

All fixtures remain isolated evidence. Actual pipeline/endpoint, binding,
admission and coordinator constructors appear only inside candidate `activate()`;
failed compilation supplies no production pattern authority. No extra host
abstraction, unsafe escape, contract amendment or hardware action occurred.

P08 is incomplete. Last validated maintained implementation remains `c39733de`.
Counter composition/all nine validation stages, endpoint/report/role audits,
cache tickets/replacement callbacks/frame lifetimes/partial teardown, four build
routes and early linked target images remain open. P09 and package acceptance
are outside this investigation. The next action is independent read-only final
result review and a separate explicit decision before any production resumption
or further compiler work.

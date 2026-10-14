# P08 integrated corrective cycle 1 source freeze — 2026-10-14

Input `e59a3c40`; implementation baseline `e2d9db9c`. This commit freezes one
bundled correction for [C01–C05 and B01/O01](p08-integrated-cycle1-diagnosis.md)
under the [broader activity](p08-integrated-activity.md). Corrective cycle **1/2
started and consumed**, assessment/rerun pending. Four initial driver cells are
consumed: SPEC-011, SPEC-013 and scoped-host macOS Dynamic passed; actual counter
failed at counter-model. No corrective rerun or image attempted. All immutable
initial logs, 19 commands, 194 source hashes and three predecessor hashes remain
unchanged. No compiler, build, formatter, driver/runtime, IR/probe or hardware in
this correction; changed Swift files are formatter-excluded contract fixtures.

[New exact source/label manifest](p08-integrated-cycle1-source-manifest.json)
freezes the current nine-file integrated inventory, six changed source/driver
files, qualification input and unchanged 26 labels. The initial manifest is
historical and untouched. No accepted contract, lifecycle, focused namespace,
workload, toolchain/platform, ownership architecture or resource ceiling changes.

| Cause | Contract-preserving source correction |
| --- | --- |
| C01 | Dynamic geometry sizing split into explicit UInt64 inline/payload/layout/render/path/plan locals; exact prior terms and arithmetic obligations preserved. |
| C02 | Five original native inline fields held by separate nested typed pointers, each lending its initialized `mutableSpan` to the supported MutableSpan buffer visitor. No owned backing copy/allocation or aggregate borrow substitutes for the field scopes. |
| C03 | Each of the five stage transfers binds `stage.take()!` to local `current`, then consumes it once in the switch. Existing complete method lifetime unions, one stage and structured cleanup remain. |
| C04 | Both concrete observation conformances explicitly suppress Copyable/Escapable defaults for G/C/R/H and preserve existing protocol/identity constraints. |
| C05 | `CounterDynamicHostProbe.swift` imports the actual generated `P08CounterSchema`; generic signature/outcome assertions are unchanged. Necessary sixth correction file, not a new permission gate. |
| B01 | Direct idle bridge call removed. The original capture is delivered through the real normalized/admitted/sealed execution mutation path described below. |
| O01 | Stale fingerprint now includes application callbacks, observations installed/detached, reentrant rejections and stopped checks, plus owned seal/dispatch observations. |

B01 retains `CounterProducedAction` immutably in the corpus. Guarded
`prepareProducedAction` checks its original origin before gate/controller/wake
access and queues a real down. The actual host cycle admits/seals one down with
zero actions and no model/dispatch effect. Guarded `deliverProducedAction` checks
origin again before capture/gate/controller access, requires the established
live capture to match, and assigns **the retained original `produced.captured`**
into existing `CounterPointerState.capture`. It never constructs/restamps an
envelope or substitutes a new observation. A real up goes through the gate and
admission; existing sequence/revision/gesture checks release that original value
into the existing sealed action. Existing apply consumes it after state/completion
facts in the actual `.mutating` phase and invokes the unchanged checked bridge.
No idle dispatch, fake context, retained scoped target/root, new pending transaction
owner or second dirty state is introduced. Host/state forward only owned facts and
these closed operations; current dirty authority remains singular in runtime control.

Both stale prepare and delivery are checked against the full fingerprint/model
scalar. The current twin checks down input1/action0 and zero effects, then up
input1/action1, exact retained capture in sealed/dispatched observations, actual
mutating dispatch context correlated to the up summary's cycle, exactly one
applied/dispatch increment, cleared gesture capture and model2. Existing independent
semantic/pixel oracle verifies value2. All prior corpus labels, raw collision,
same-address/two-host/cleanup/negative/exclusivity controls are preserved.

The seal/dispatch instrumentation contains owned immutable captures/context and
a checked bounded dispatch counter. It is recorded by actual seal/dispatch only;
no runtime admission decision or transaction reads it as a pending work owner.
Fresh control initialization/reconstruction resets all observations/counts and
asserts empty instrumentation. Control/coordinator MemoryLayout partitions charge
these fields, including padding, in existing family24; actual target layouts and
stack must also charge retained original capture, new down/up summary temporaries,
separate typed field/span helper frames and full fingerprint copies. Symbolic
accounting is not numerical fit. The 58,648-byte historical failure and unchanged
27,648 ceiling, Dynamic allocation peaks, Static zero heap and complete IRQ/ABI
obligations remain open.

## Exact noncompiled applicability qualification and next check

[Qualification](p08-integrated-cycle1-applicability.json) pins three original
successful receipt hashes, each original CounterScopedStorage hash and the exact
corrected source hash. Their pinned recorded argv contain respectively 110/171/52
unique Swift input paths and exclude this source. It is the only input mismatch
in each component receipt; all their compiled inputs remain unchanged. Their
whole-source applicability manifests are explicitly **not current**. No historical
receipt was rewritten or successful cell rerun. Counter driver qualifies only this
exact source/receipt/hash combination, rechecks recorded inputs and retains every
other input/artifact/compiler/macro/flag/recipe check plus historical r06 fallback.
The resulting counter receipt will explicitly record qualification use; fresh
receipts must match normally. No arbitrary mismatch skip or mutable-current-source
acceptance is introduced.

Independent Strong assessment is next, then at most one affected rerun:

```text
scripts/contracts/run-spec-015.sh --profile macos-dynamic --corpus rfc-014-counter --runtime-build .build/contracts/spec-013-runtime-cycle/tmpi1u8hyk5/macos-dynamic --host-build .build/contracts/p08-scoped-host-ezcy1qan
```

Remaining profiles retain initial invocation status. Compiler labels remain
384/202, five native exclusivity controls and 13 labels per route with positive
twins first. Source correction is unreviewed/unexecuted; no counter runtime,
compiler-matrix, target, fit or acceptance claim. All nine SO criteria,
HC-RD-003/P08/R07/T8.1, I4-07/P09–12/hardware/timing and lifecycle gates remain
open; Specifications implementing, plans active. No new optional deferred idea;
required correctness is not deferred. Current permitted consistency outcomes
pass: nine source hashes/six changed files, qualification hash/three pinned
receipts/excluded recorded inputs, 26 labels, driver AST without invocation,
194 local Markdown targets and whitespace. These are consistency checks, not
Swift typechecking or independent assessment.

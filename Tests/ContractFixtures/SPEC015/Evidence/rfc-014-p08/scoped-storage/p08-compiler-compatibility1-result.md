# P08 compiler compatibility 1 — independent result and boundary assessment

**Disposition: FAILED; STOP at the authorized activity boundary.**
Independent Sol 6.1 High read-only source/log diagnosis of candidate `bbb54fc1`,
review `7002a953`, the [activity](p08-compiler-compatibility1-activity.md) and
[immutable result packet](compiler-compatibility1-counter/manifest.json).
Conformance-reviewer rules apply within accepted ADR-039/approved S11/S13/S15.
No source fix, compiler, build, probe, variant, formatter, runtime or subagent in
this assessment. This report and the preserved packet are the only staged changes.

The [one exact authorized counter invocation](compiler-compatibility1-counter/result.json)
at clean `7002a953` exited **1** at `counter-model`, output
`.build/contracts/p08-counter-ldxvgm61`; [19 commands](compiler-compatibility1-counter/commands.txt)
and the [compiler log](compiler-compatibility1-counter/counter-model.log) are
preserved. The log contains **ten explicit lifetime/ownership errors and no fatal
SILGenCleanup assertion**. The prior numeric error is not emitted. This is
productive progress from the earlier assertion to concrete diagnostic sites,
not successful compiler acceptance or proof of the old assertion's sole root cause.
The previous source-ready assessment was limited to source inspection; this
compiler result now rejects the candidate's complete source shape.

## Three cause groups, not ten independent repairs

| Group | Exact source-backed diagnosis | Next correction invariant; no fix validated here |
| --- | --- | --- |
| L01: original inline-span dependency | `CounterScopedStorage.swift:1713,1716,1719,1722,1725`. Each mutableSpan obtained through the typed-pointer parameter's pointee is reported escaping; notes identify dependence on recordsStorage/pathsStorage/payloadsStorage/scalarsStorage/entriesStorage and mark the immediately following buffer visitor out of scope. Five fields instantiate one borrowing pattern. | Make each initialized original field's actual typed mutable borrow cover the complete span/buffer callback interval, with supported explicit dependencies. Synchronous pointer reservation by itself did not satisfy the checker. Inspect the inout/field-access lifetime boundary rather than applying the graph's owned-pointer projection pattern to a scoped span. Preserve all original addresses/counts, disjoint exclusive loans and backing-last cleanup; no copied owned array, unchecked lifetime override, raw-span workaround that erases the dependency or altered limits. Exact accepted syntax remains unproved. |
| L02: borrowed facade consumed in nested construction | `1958,1961,2093,2095`, consumed at 1963/2097. Both Semantic storage lenders' withLifetime callbacks provide **borrowing SemanticRecordStore**; both Canvas lenders provide **borrowing CanvasStagedValues**. `runP08ScopedBody` at 1915–1916 consumes semantic/values, while these original borrowed callback parameters are captured and passed directly. The diagnostic's wording also mentions escaping closure/non-Escapable borrowing; it does not prove that the explicitly nonescaping APIs actually retain callbacks. Static and Dynamic share this transfer cause. | Preserve the lender-owned originals and legally move lifetime-dependent scoped projections into the existing consuming chain. Existing `SemanticRecordStore.borrowedStore()` (`Sources/GiftUISemanticCore/SemanticRecordStore.swift:84–94`) and `CanvasStagedValues.borrowedValues()` (`Sources/GiftUIDrawing/CanvasStagedValues.swift:74–83`) retain `@_lifetime(copy self)` and offer a concrete source-backed starting seam; `CounterCoordinatorProbe.swift:22` already uses them. Their use at these nested sites still requires compiler proof. Do not make the originals Copyable, change borrowed lender callbacks to consuming, erase any carrier dependency or duplicate mutable transaction/storage ownership. |
| L03: borrowed observation in assertion capture | `CounterScopedStorage.swift:2265–2266`. `p08VerifyRoleTranscript` borrows transcript; precondition's autoclosure captures that borrowed parameter. | Read the necessary owned scalar/event observation before assertion construction, or use a direct borrowing check that creates no capture of the borrowed aggregate. Preserve the exact twelve-entry/six-commit R/H oracle and every address/count/exchange/destruction assertion. This local assertion pattern is distinct from L01's dependent spans and L02's scoped ownership transfer; copying raw pointers cannot repair those groups. |

The existing ordinary warnings are non-failing observations, not added causes.
These diagnostics identify rejected source relationships under the pinned compiler;
they do not establish that an accepted-contract realization is impossible, that a
compiler defect explains all sites, or that the suggested projection/borrow shapes
will compile. Additional errors, runtime/exclusivity failures and target/resource
failures may still be masked. No architecture/contract/toolchain change is justified
by the current result alone.

## Coherent next decision

The next package-boundary decision may authorize a **grouped lifetime/ownership
realization continuation** covering L01–L03 and their actual Static/Dynamic scoped
construction paths, rather than ten line-level permissions. Its source boundary
should keep original typed lenders/reservations, lawful borrowed-to-scoped transfer,
complete supplied→pipeline→coordinator→host→retirement dependencies, once-only
cleanup and all independent oracles together. A source candidate must reconcile
these relationships before independent Strong review and the registered driver.
Necessary exact applicability qualification updates should preserve the original
successful component receipts, not rerun them merely for a noncompiled source hash.

Any renewed authorization must define its finite candidate/invocation/repair
allowance and stop condition; **none is inferred or created here**. This is a
proposal for a coherent next activity, not permission for another source edit,
compiler reduction/probe, rerun, variant or remaining-profile/image execution.
If a realization actually needs an accepted lifetime/ownership contract changed,
report that specific conflict upstream before using it. No contract amendment,
Copyable workaround, disabled checking, new compiler/platform or resource exception
is selected by this diagnosis.

## Final accounting and evidence limits

Compatibility 1: **candidate1/1 consumed, run1/1 failed, automatic repairs0**.
Historical integrated cycles remain **2/2 consumed**, both affected reruns failed;
no reset or further automatic action follows from deeper diagnostics. The cumulative
guard is preserved; observed progress does not override this activity's terminal
allowance boundary.

Initial matrix remains **4/14 cells consumed**: SPEC-011 macOS Dynamic **459**,
SPEC-013 **5,904** and scoped-host **187** assertions passed; actual counter failed.
Those three component results retain their exact noncompiled applicability
qualification limits. **Ten initial cells and both early images remain unrun.**
The actual counter has no successful complete module/driver result; its 384/202
scoped controls, five Native exclusivity controls and 26 reuse runtime labels are
still unvalidated. No counter runtime, target, image or actual fit is established.

All **IN-SO-001/002/003, RP-SO-001/002/003 and HC-SO-001/002/003** remain open,
as do HC-RD-003/P08/R07/T8.1 and fit. The historical **58,648-byte failure** and
unchanged **27,648-byte main-stack ceiling** are not replaced by passing evidence.
I4-07/P09–12, hardware/timing and lifecycle transitions remain separate; Specs
implementing, plans active. Required lifetime correctness is current work, not
deferred Future Work; no new optional deferred idea was found.

Read-only checks pass: six immutable evidence hashes, nineteen commands, unchanged
nine source identities, wrapper exit1, exactly **5+4+1** emitted diagnostics and
absence of the prior assertion, plus whitespace/local report links. Parent owns
current activity/navigation/manifest updates, governance and the user-facing
boundary report. These checks preserve evidence identity and establish no compiler,
runtime or resource acceptance.

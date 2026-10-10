# RFC-014 P05 independent Strong exit review — 2026-10-11

**Disposition: PASS at the finite P05 component exit. No blocking finding.**
This supports the parent recording the package pass; it does not close T9.1,
T12.1, either Specification, or any P06–P12 obligation. No production repair,
contract amendment, scope decision, exception, or successor work was performed.
Consecutive unproductive repairs remain **0 of 2**.

## Frozen boundary and authority

Dispatch: `5b3ff038`, clean on entry. Reviewed change:
`2aa5c7cc..9bcd5ed6`, with implementation through `fec8a27c` and subsequent
evidence only. All eight final owner routes identify clean tested source
`fec8a27cf6cf0ae679a1e34ebb90738e8d592f85`.

The approved RFC-014 amendments and retained baseline contracts in SPEC-007
and SPEC-011 control this review, under accepted ADR-032/033/035/036; SPEC-013
and SPEC-015 control key pools, bounds and accounting. The approved amendment
receipt is `docs/iterations/iteration-003-review/rfc-014-spec-approval.md`.
The P05 row and owner T9.1/T12.1 matrices supply the finite review boundary,
not new authority. ITERATION-003 I3-04/05 requires runtime analyzer/counter
derivation and accounted storage; the closed MVP supplies regression semantics.
SPEC-007/011 remain implementing, owner plans active, reports collecting.

## Invariant review

| P05 obligation | Disposition and inspected evidence |
| --- | --- |
| Bank-scoped Layout/Render queries, no second graph or model access | PASS. `SemanticRecordLayoutView.swift:51` and `SemanticRecordRenderView.swift:6` store only the nonescapable bank view. Owner/bank/revision/ordinal checks occur in `SemanticRecordStore.swift:221`; backing remains lent by the store factory and reader count is released by `withView`'s defer at line 168. Payload projections are finite value switches. Structural records stay transparent; modifier records provide one wrapper scope each. Render traverses existing canonical parent/sibling links, skips transparent records, and returns the same checked identities for geometry joins. No retained node table or model resolver was added. |
| Unchanged geometry, limits and failure cleanup | PASS for P05. Layout and RenderLowering algorithm edits are generic lifetime suppressions; prior result adapters were moved intact to separate files. Actual declaration traversal in `LayoutProbe.swift:76` checks nested frame/padding, bank reuse, stale references, scope/depth excess and sink begin/stage/publish failure. `LayoutOracleProbe.swift:10` independently seeds records to isolate the consumer adapter; literal expected rectangles/lines/glyph positions derive from SPEC-007 and the retained Stack/Text/Geometry tests, not another production invocation. Exact 98 scopes/depth 13 and configured 97/12 rejection are checked. Malformed lookup permits discard/reuse. |
| Complete owned keys across bank reuse/refusal | PASS. `InteractionOwnedKeyState.swift:48` checks candidate/action provenance and obtains the full `SemanticCompleteIdentity`; `SemanticRecordStore.swift:240` reconstructs every path component including endpoint role. Candidate, prepared committed, hit and committed records retain values, never bank references. Existing complete-record equality includes geometry, paint order, enabled state, action and target (`InteractionState.swift:140`). The twelve-publication fixture retains the original capture through ten refused offers and restores the original complete key without consuming a new committed generation. |
| Capacity admission and atomic failure | PASS. Checked component arithmetic, per-key and logical candidate-pool limits join existing error precedence at `InteractionOwnedKeyState.swift:86`; the preflight runs before append. Failure poisons the whole candidate and prevents even an erroneous commit request at line 132. Discard resets candidate bookkeeping; committed records/revision remain untouched. Equal-limit acceptance, first-excess rejection, duplicate/geometry precedence, and preservation of a prior capture are independently asserted. Accepted-offer resolution was factored without behavioral change into `RuntimeInteractionCandidateResolution.swift:60`; the caller still must only offer a finished valid candidate. |
| Exact model target and stale release/replacement cancellation | PASS for the bridge component. `RuntimeRecordInteractionBridge.swift:27` requests the exact encountered publishable root association; domain/code/preflight failures are selected before staging. Dispatch at line 60 rechecks complete key, action generation, enabled state and current registration generation. `ObservableStateRootScope.swift:514` checks the published association again, and `ObservableModelScope.swift:222` acquires mutation authority before invoking the operation thunk. It retains checked preflight/non-failing commit and synchronous reporting after the mutable model access. The fixture proves no operation during frame rejection, failed replacement preserving A, successful replacement cancelling A, fresh generation for B, and detached-but-retained B being undispatchable. |
| Complete retained key/capture accounting | PASS for measured component layout. Six slots contain three candidate key regions and two committed regions. Every key is 206 bytes (34 six-byte components plus count); totals are 3,708 candidate and 2,472 committed bytes, with 928 remaining bytes in the 7,108-byte Static state. External pointer capture is 212 bytes, including another 206-byte key. These physically distinct copies cannot be deduplicated in later accounting. Inline storage is bounded and independent of semantic banks; the logical component admission limit is not presented as the physical byte total. |

The array/optional records in the selected Dynamic and Static table adapters
own those complete values. No change increases the approved logical application
limits. Allocator overhead, temporary key copies, Swift call stack/IRQ overlap,
complete Execution captures and the eventual host's total live storage are still
required P07/P11 accounting, not absent or zero costs.

## Independent evidence verification

The read-only [verification script](verify-exit-evidence.py) produced
[this result](exit-evidence-verification.json). It checked all eight snapshot
hashes against both their index and original result files, every declared input
against current bytes and the frozen tested Git commit, compiler hashes, pinned
P02 receipt and reused GiftUI object/module hashes, all **500** retained local
artifact hashes and sizes, saved command lists, exit classifications, native
assertion logs, negative compiler diagnostics and target ABI logs. All pass.
No owner route was rerun because no concrete correctness concern required a
reproduction after inspection and successful identity verification.

| Evidence | Proven boundary |
| --- | --- |
| macOS Dynamic and Static SPEC-007 | 196 assertions each; two expected escape compile rejections each. Actual declaration path selects the corresponding semantic backing. Full Layout and RenderLowering compile. |
| macOS Dynamic and Static SPEC-011 | 215 assertions and 183 P03 root regressions each. Interaction tables select actual Dynamic/Static storage. |
| ARMv6 and nRF owner routes | Component compilation, Layout/Render escape controls, key-layout IR, CPU v6/v7E-M and VFP-register ABI. No target execution. |

**Evidence precision:** `InteractionProbe.swift:258` and `RootProbe.swift:227`
use `StaticObservableRootAdapter` in both native runs. Therefore these runs prove
the shared checked target/operation mechanism with Static root ownership; they
do not prove complete Dynamic root/coordinator integration. That remains P07's
explicit concrete-profile obligation. The hand-seeded Layout corpus isolates
the adapter; only `LayoutProbe` exercises actual declarations here. It does not
replace complete analyzer/counter traversal and baseline-corpus migration.

The optional dependency-check investigation is explicitly unverified and was
not rerun or counted as a pass. No target deployment, flash, hardware execution,
full-module adoption, full application layout/pixel/action transcript, linked
zero heap, memory fit, throughput, or connected result is inferred.

## Remaining gates and review checks

LY-RD-001/002 and IN-RD-001/002 pass only their enumerated P05 portions above.
The nine retained LY and thirteen retained IN criteria remain migration-pending
in their owner matrices: reviewed unchanged algorithms and selected fixtures do
not close their complete corpora, application, integration, resource or platform
obligations. P06 owns Canvas; P07 owns concrete coordinator/root composition,
candidate rollback joins and audit integration; P08/P09 own actual applications
and immutable workload adoption; P10 owns broad conformance; P11 owns complete
resource/connected dispositions; P12 owns cutover and final owner reports.

No missing authority or new deferred decision was found at the P05 boundary.
These remaining requirements already have owners and cannot be waived through
this receipt. No additional Future Work or investigation is created.

Review-record checks: `scripts/validate-governance.rb` and `git diff --check`
must pass before this receipt is committed. See the commit's recorded review
completion in [progress](progress.md#independent-review-completion).

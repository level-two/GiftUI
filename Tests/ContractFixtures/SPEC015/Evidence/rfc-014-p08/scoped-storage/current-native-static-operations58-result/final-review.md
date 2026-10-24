# Operations58 + cleanup57 independent focused review

Verdict: **PASS for the scoped source correction and focused compiled mechanism; full validation remains pending.** No material source or evidence blocker was found in this finite package. This verdict supports the coordinator selecting the next validation disposition. It does not authorize a full run or commit, grant a test exception, establish Static resource conformance, or request the implemented transition.

Reviewed against HEAD `011b6dde0bd1f7e2e8cf13e5244e1348a1fee9a3`, the six current source hashes in [validation.json](validation.json), the operations58 [scope](scope.json), and the carried [cleanup57 review](../current-native-static-cleanup57-result/final-review.md) and [scope](../current-native-static-cleanup57-result/scope.json). No source, compiler, runtime, provider, test-driver, collector, or index changes were made by this reviewer.

## Source and behavior

The incremental four-file group contains ten existing serialized bodies and six usable-only declarations, including the single consolidated `ObservableStateCandidateDisposition` nominal correction. The combined cleanup57 + operations58 source scope is six files. Independent comparison of the four incremental before/current snapshots, removing only serialization attributes and whitespace, found identical source bodies. The enum change adds only `@usableFromInline`; cases and raw values are unchanged. The [combined diff](../current-native-static-operations58-local/combined57-58-source.diff) and companion cleanup57 snapshots preserve signatures, generic constraints, layout, capacities, defaults, consuming/borrowing relationships, and API behavior. This is not a CounterOwnedModel-specific source bypass: the existing generic Model requirements and controls remain.

The examined operations retain the following consequential order:

- Candidate admission checks discovery/phase and active-candidate state before changing candidate flags. Generation lookup retains identity, publication, candidate and encounter checks. Completion clears operation/candidate state with the existing deferred cleanup, performs the bounded retirement/publication loop, releases offers, and preserves the first error.
- Replacement validates phase, candidate state, published identity, ticket and next generation in the existing order. Existing model materialization, capacity/reservation checks and stage/discard behavior remain. The former route is retired before detach; publication, ownership transfer, ticket release and typed destruction retain their order. Cleanup failure does not replace the earlier primary error, and the existing stop requirement remains.
- The serialized mutation overload is `mutate(identity:ordinal:matching:operation:)`, which the actual pipeline calls. Its phase/identity/publication/generation checks precede the operation closure, and mutation-reporting state is cleared with the existing defer. The mutation-value overload was not substituted for this boundary.
- Cleanup57 still attempts unregister after detach failure, retires callbacks before ending backing storage, preserves the first error, destroys only occupied typed model slots, and keeps repeated shutdown/idempotence and stopped-activation behavior. Nongeneric ledger bookkeeping and private replacement claim fields remain opaque.

The maintenance cost is real: ten more serialized bodies and six more usable declarations expose additional implementation detail to cross-module optimization and future compatibility maintenance. No forced-inline attribute, global compiler flag, architecture change, or representation change was introduced. Runtime `__text` is **820,384 bytes**, **+3,804** versus cleanup57 and **+5,516** versus accepted constructor50; this is a code-size tradeoff, not a performance result.

## Compiled consequence and nonrelocation

The current Runtime object is `8317d90ebe05b92c714e2a0d014ab31fb4c6b03938766a92d4293372ddb73f49`. Its identity and the retained complete capture hashes were checked. [proof.json](proof.json), the exact [caller/body joins](../current-native-static-operations58-local/proof/actual-operation-joins.json), and [current target map](../current-native-static-operations58-local/proof/current-rootScope-targets.json) support the following target-specific result:

| Actual path | Retained compiled consequence |
| --- | --- |
| `exerciseCounter` | Calls at `0x2650` and `0x28e0` reach concrete begin `0x3294–0x33e0` and finish `0x7ccc–0x7fe4`. The former GMD/instantiate result passed to opaque begin/finish is absent. Required retained-model replacement refusal and subsequent success remain unconditional for Static and Dynamic controls. |
| Observe/build generation | Actual observe `0x5f9e4` and Static/Native-wrapper build `0x74e1c` / `0x73e84` retain inlined generation/publication checks and concrete matching, without the former RootScope metadata argument. |
| Begin/expand and publish/abort | Actual Static/Native-wrapper begin `0x6c10c` / `0x6513c`, publish `0x76438` / `0x75f28`, and discard `0x726a0` / `0x723f8` reach concrete begin/finish. The selected callers cover both Static and wrapper realizations, rather than only a Dynamic owner. |
| Dispatch | Actual Static/wrapper calls `0x648f4` / `0x64284` reach concrete operation mutation `0xa8308–0xa8504`, then ModelScope mutation `0x988fc–0x98ad8`. This is the operation-closure overload. |
| Replacement | Concrete replacement `0x81cc–0x8a2c` contains stage/discard/key work and reaches concrete commit `0x994b4–0x995c8`. Complete selected operation bodies have no generic metadata acquisition. |
| Cleanup57 regression | Semantic `withRoot` `0xa8574–0xa8878` calls concrete shutdown on normal/error paths at `0xa86ec`, `0xa8728`, `0xa87b4`, `0xa87ec`; Coordinator lifetime `0x962c–0x98f8` does so at `0x9804` / `0x9834`. Both reach shutdown `0x8a2c–0x8bf4`, without restoring the removed cleanup metadata argument. |

The target map leaves no reference to this exact RootScope GMD/thunk in the named exercised operations, earlier setup, or a new named acquisition helper. This supports removal without displacement of the demonstrated requests. Counts alone would not establish that conclusion; the actual typed callers and complete reached operation captures are necessary parts of this proof.

There are still **two** references in the same preexisting **28-byte** constrained generic pipeline metadata-layout thunk, `0xae394–0xae3b0` before and `0xaf224–0xaf240` after. The [before](../current-native-static-operations58-local/proof/before-layout-thunk.stdout) and [after](../current-native-static-operations58-local/proof/after-layout-thunk.stdout) captures retain the same seven instructions and symbolic targets: the noncopyable-runtime-support GOT guard, the same concrete RootScope GMD and instantiate tail, and the same alternate outlined helper. PC/page changes are not a semantic change. Its transitive runtime/caller/reflection invocation remains open; neither global metadata absence nor whole-root eligibility is established.

## Validation and evidence limits

Independent checks found all **201** focused inputs and all **168** corrected P07 inputs equal to current files, all six combined source hashes equal to the focused receipt, and the compiler, Runtime, runtime-result receipt and host-result receipt identities matching. The exact commands, files, hashes, flags and dispositions are retained in [validation.json](validation.json).

| Gate | Disposition |
| --- | --- |
| Formatter / lint | PASS, exit 0. |
| Initial P07 | FAIL, retained; diagnostics concern CandidateDisposition visibility. The one permitted nominal-only correction resolved it. |
| Corrected P07 `tmpx4wt4oc6/macos-static` | PASS, **5,904 assertions / 0 failures**, exit 0; result SHA `7a5380abee368611a821e1a9fb205b5089d136f5eebff7b5e8bdf3f453ec9311`. |
| Fresh focused `p08-counter-yje67t90` | PASS, **1,736,320 assertions / 0 failures**, exit 0; result SHA `e6dc854bf19fab46ab1592c55c87970c69c5fe5d865d6603c3117610e7bcc904`. `focused_passed=true`; aggregate `passed=false` and `collection_complete=false` are intentional. |
| Both functional output oracles | PASS against cleanup57: mixed **611,253 bytes / 120 SO06 lines** and Static **391,098 bytes / 60 SO06 lines**. I independently reproduced equality using only decimal address tokens 4/8 on validated 14-token `SO06 role` lines with token 11 `=>`; all other bytes, order and whitespace were preserved. |
| Current full applicability | **PENDING**. No full collection was authorized or launched for this source. Constructor50's earlier full result is not transferred to these changed objects. |
| Unit gate | **FAILED before Interaction; Interaction UNEXECUTED**. No unit PASS or human exception is claimed. |

The two pre-edit Python syntax errors remain disclosed delivery errors: no statements or source changes executed. They are not failed semantic trials or evidence of a further source candidate. The first P07 failure is preserved rather than replaced by the corrected run.

[Accounting](accounting.json) is an ordinary retained-size snapshot, not an authenticated Batch A accounting experiment. Its arithmetic is consistent: operations58 **197,813,034 B** + carried cleanup57 **187,366,264 B** + **33,554,432 B** final reserve = **418,733,730 B**, below the **2,147,483,648 B** envelope. Prior A51/A52/A55/A56 recording FALSE dispositions remain unchanged. This review adds no experimental qualification claim.

The repository evidence is finite and reviewable through [scope.json](scope.json), its selected captures/snapshots, and the required cleanup57 companion. Raw `.build` artifacts remain explicitly required external working-tree dependencies; this package does not promise clean-checkout replay or require a failed-history/notebook sweep.

## Remaining disposition

Accept the joint cleanup57 + operations58 **focused correction** for its demonstrated operation/cleanup removal and preserved functional behavior. Keep full validation pending for the coordinator's explicit selection; no automatic full run or commit follows from this review. Owning Model generic design, the retained layout thunk, error/once/provider and live binding/environment/stdout/persistence/window questions, remaining image/profile/cold/resource/P08 duties, and the unit gate remain open. Available unexamined local frontiers must not be relabeled as absent providers or external blockers.

The [lifecycle test and human-transition gate](../../../../../../../docs/engineering/FEATURE_LIFECYCLE.md) remains unmet. No implemented transition, allocation observation/bytes claim, global zero-heap claim, overall Batch A PASS, or P08 completion is supported here.

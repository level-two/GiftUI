# Supplied Counter traversal: frozen source handoff

Baseline: `bd74686ee9b9110c4a6cb6086225d8eeb8b20ff3`; the accepted scoped implementation remains `17e9da5f`. This candidate changes exactly the five files in `source-freeze.json`. Prior source, proof, failures and unrelated dirty paths remain preserved. No compiler, runtime or test producer has started.

This is implementing P08 under the active RFC-014/ITERATION-003 plan, not an implemented transition. The finite Counter is the required runtime stack validation before the scheduled Analyzer migration. SPEC-006's profile-owned Workspace/Sink operations and ADR-035's single Semantic Core traversal/identity/borrow ownership remain the governing boundary.

## Physical and algorithm boundary

`SemanticRecordWorkspaceState` is an opaque nongeneric Core value containing the previous bank, limits, complete identity and expansion flag. It owns the existing path/identity algorithms. The general `RecordWorkspace<Roles>` now forwards to that state. The concrete `CounterRecordWorkspace` stores only that state and directly supplies `CounterRoles` to the shared role operation.

`SemanticExpansionTraversalOperations` expresses scalar bookkeeping and explicit mutating operations over disjoint fields. Its defaults contain the single existing visitor/traversal algorithm. Both the original general `SemanticExpansionTraversal` and the new nongeneric `CounterSemanticTraversal` implement only field forwarding for those operations. The latter stores the actual concrete Workspace, Sink, attempt, identity/failure bookkeeping and the same concrete observable binding; it contains no generic Workspace/Traversal owner, envelope, existential or retained factory closure.

The internal `SemanticRecordTraversalRealization.make` requirement is on the new realization seam. It adds no requirement to the existing Workspace, Sink or Codec protocols. Both Counter expansion sites pass `CounterSemanticTraversal.self` to the checked Core adapter. Core retains candidate selection, bank validation, codec preparation and the local bank descriptor, then constructs the opaque states and invokes the concrete static constructor. No raw bank accessor or prepared state bundle is exported to the fixture.

The constructor retains the union of incoming SinkState, codec and binding dependencies. The SinkState is from the same live local bank; the concrete binding is consumed once. The supplied visitor is consumed in Core's traversal operation and destroyed before outer pending/bank failure cleanup. Original general entry signatures, error precedence, counters, path/child/modifier order, guards, publication and retirement behavior remain intact. No limit or expected test value changes.

## Source review and correction

Astra High completed the unified five-file source/lifetime/visibility audit. Its sole definite precompile finding was the generic `stopped` getter's `||` autoclosures over borrowed noncopyable Self. The correction uses sequential failure, binding-failure and access-failure checks in exactly that order. Replacing that getter alone reproduces the preserved reviewed Core bytes; the other four frozen source hashes did not change. The reviewer permits the compiler gate after this exact correction, not implementation or metadata acceptance.

The selected local Swift 6.4 formatter and the maintained `scripts/format-swift.sh` plus `--lint` pass. Logs and the pre-review freeze/diff/Core bytes are retained here. The exact current full2 twelve-command/42-source recipe, reuse hashes, fresh-first output priority, unchanged guard and cumulative usage definition are in `compile-plan.json` for root's launch-plan review.

## Decisive compiled gate still required

Compilation must establish lifetime/conformance acceptance. Then actual current construction, factory/witness forwarding, traversal/child callback, observable binding, normal/error results, copy/drop, pending transfer and retirement must show removal without relocation. In particular, concrete type spelling does not prove that binding, associated-type/witness, Optional/result or cleanup metadata is nonallocating. Any mechanism/lifecycle contradiction or actual compiled allocation failure returns a terminal reassessment, not an annotation/wrapper variant. No long validation, live experiment or commit is inferred from this source handoff.

Plan bookkeeping distinguishes preserved full2 source hashes from current `expected_for_candidate` hashes; all 156 current source hashes and reuse/guard identities were rechecked before launch. No source changed during reconciliation.

# P08 Analyzer ABI diagnostic policy batch 1

Status: **static policy successor; unqualified; fresh campaign integration blocked**.
No compiler, producer, SDK diagnostic, campaign, hardware or deployment ran.
This is an evidence-local implementation/test packet, not a lifecycle artifact,
architecture amendment, source repair, or execution allowance.

The finite scope follows the independently reviewed discovery result: ARMv6
A7/A8 plus nine privacy controls; Embedded A1–A8 plus nine privacy controls;
Dynamic A1–A8 plus nine privacy controls. There are exactly **45** forms.
macOS Static gains no policy form. Positive observations remain prerequisites
with zero qualified controls. Old policies and results retain their meaning.

## Authority and provenance

SPEC-015 remains `implementing`, its plan `active`, and P08 open. Consulted
FEATURE_LIFECYCLE, AI_AGENT_RULES, DOCUMENTATION_RULES, ITERATION_SCOPES,
ITERATION-001 MVP, ITERATION-003 scope, docs/features.yaml, SPEC-015 and its
implementation plan, accepted ADR-036/039, and implementation-executor and
deferred-work-curator skills. The analyzer reference application and required
four-profile stack/ABI validation justify this evidence maintenance; iteration
3 IT-AC-008 remains unmet. No contract or architecture defect was found by this
bounded parser work. No new deferred decision was discovered.

Discovery source packet: `6731bbeb81ecd2c3390f700703e960ed3a30dc1c`.
Discovery archive: `bc38fa6c297e491a10e490aaf69bd087a9cee95a`, sibling
`analyzer-abi-diagnostic-discovery-sweep-result`. Its 44 expected nonzero target
observations supply 44 forms. ARMv6 A7 is copied from sibling
`analyzer-abi-continuation-campaign10-result`, authenticated campaign commit
`8789f33e5e52130d0717733df7590650f55c3dce`; that campaign stopped on its A7 gutter
classifier. The complete source result/audit identities and exact commands are
retained by policy origins and archived captures. Every discovery audit was
verified against the stage's prelaunch-audit SHA before derivation. Logs were
verified against recorded stdout/stderr hashes. No old packet was changed.

## Contents and use

- `policy.json`: pinned exact forms, header order/line/column/message/source
  rows, display-only notes, full byte-equivalent UTF-8 streams, 25 deduplicated
  source snapshots, case-specific source identities and canonical context hashes.
- `archived-captures.json`: exact archived argv (including target/SDK/package/
  profile/feature flags), input/producer identities, compiler/tool identities,
  audit/provenance/dependency identities. These are historical captures, not
  independently authenticated future process results.
- `policy_binder.py`: pure validation with no filesystem, subprocess, path
  resolution or diagnostic-controlled lookup. `authenticate_prelaunch` captures
  immutable canonical context/source hashes; `finish` rechecks them and the full
  streams. `bind` also supports one-shot archived replay. Every result explicitly
  carries `qualified=False`. Only exit integer 1, no launch error and the exact
  empty stdout/complete stderr are accepted. Boolean, float, signal and other exit
  anomalies reject. Duplicate JSON keys and nonfinite values reject.
- `derive_policy.py`: deterministic archive-only reconstruction, run from repo
  root. It derives only this packet's JSON payload and prints the policy SHA.
  Source lookup uses enumerated recipe paths and archive manifests, never text
  extracted from diagnostics. A changed SHA requires explicit binder pin review.
- `test_policy.py`: static accepts, mutations and prelaunch/finish drift tests.
- `static-validation.json` and `packet-hashes.json`: results and payload hashes.

Run from repository root:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/analyzer-abi-diagnostic-policy-batch1/test_policy.py
```

Full-stream equality deliberately rejects reordered/missing/extra errors or
notes, altered symbols/locations/paths/source rows, CRLF, changed gutters,
terminal-newline changes, output chatter and unrelated failures. ARM A7/A8
inlined declaration gutters and the four named private-member virtual
`SignalAnalyzerDomain.SignalAnalyzerDiagnostic.*` note forms are accepted only
as literal case-local display. Their paths never supply source/dependency
identity. Real note locations bind independently supplied archived source bytes.
No note-absent variant or general virtual-note/gutter allowance is introduced.

## Exact boundary before fresh campaign integration

This packet accepts archived identities only. There is no path relocation or
fresh producer waiver. A new campaign cannot call this binder with altered
roots/receipts and obtain a result. No campaign successor/recipe was prepared.
The immutable prelaunch API demonstrates capture/drift checking for the pinned
archive, and does not authenticate a future runner by itself.

The available campaign10 P02 receipts are `campaign/receipts/0.json`
(macOS Static) and `2.json` (ARMv6), both source commit `8789f33e…`. There is no
Embedded/Dynamic current campaign P02 receipt: first failure stopped execution
before those stages. Discovery uses separate isolated-core producers. Its
module hashes cannot be assumed equivalent to future authenticated P02 outputs.
A fresh campaign also has new source commit, environment digest, launch audit,
current core paths and potentially module bytes. Those values are not known
without its normal sequential producers. Accepting arbitrary caller-provided
replacement hashes would remove the producer authentication requirement.

A bounded integration successor must freeze and review the following before
launch; these are requirements for that implementation, not implemented claims:

1. A literal finite path map, anchored at path-component boundaries, from the
   archived campaign10/discovery general root, ARMv6 root and Embedded root to
   three newly named absent campaign roots (macOS children under general root).
   A separate per-profile core-directory map must come exclusively from the
   verified current P02 producer. Toolchain/SDK/plugin/source names, diagnostic
   relative suffixes and all non-root argv tokens remain exact. Reject aliases,
   overlapping roots, traversal, symlinks, unknown/extra substitutions and any
   replacement derived from output. Apply that same map once to source identities,
   diagnostic headers, complete stream templates and planned argv; seal the result.
2. Invoke the existing P02 receipt verifier with exact current commit, package,
   profile, compiler/plugin hashes, frozen input hashes and required checks.
   Capture its verified receipt bytes, full artifact map and producer directory.
   Require positive checks to have `pass is True` and exact expected integer exit;
   retain existing negative-check meanings. Validate actual core bytes against
   the receipt. Never accept a matching basename alone. Future Embedded/Dynamic
   receipt values must be obtained sequentially at their authorized stage.
3. For every current negative cell, authenticate its completed prerequisite
   stages and exact generated-source bytes against the approved lowerer/source
   candidate. Bind all domain/schema/core module inputs to those actual producer
   stages, including failures at domain/schema stages. Preserve the existing
   target ABI, runtime and macro-oracle gates. The exact current predecessor-stage
   artifact hashes/receipts are additional missing facts, not discovery positives.
4. Before each launch, freeze canonical immutable bytes containing policy hash,
   complete selected control, exact source snapshots, argv/cwd/effective
   environment digest, current commit and compiler/SDK/plugin inventories,
   verified P02 and preceding-stage identities, finite path map, planned stage
   and completed audit identity/time. Recheck immediately before launch and
   after exit; reject drift, stale/failed producer or source/profile/package
   swaps, unexpected stage/order, nonzero prerequisite or missing checks.
5. Pass only those captured bytes to the pure matcher; compare complete mapped
   stdout/stderr and exact exit 1. Emit qualification only through the existing
   sequential campaign receipt rules. Add static adapter tests for each root,
   current producer and provenance mutation, then obtain independent integrated
   readiness review before any compiler/campaign invocation.

This boundary is evidence insufficiency for safe integration, not an upstream
contract defect. It grants no generic adapter or new execution authority.
P08/current-callee/cold/resources/P09–P12/I4-07/runtime/safety/conformance remain
open; historical retry/repair budgets remain closed.

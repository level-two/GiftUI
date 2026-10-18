# P08 Analyzer ABI campaign 11 preparation

Status: **proposed fresh integration, independent readiness review pending**.
This packet has run compiler-free static tests only. No compiler, campaign,
producer, hardware operation or deployment has run. The archived batch1 binder
and its meanings are preserved in their original packet.

This evidence-local successor implements the requested fresh sequential
macOS Static → ARMv6 → Embedded → Dynamic campaign under normal first material
failure, one source candidate, zero retries and zero automatic repairs. Fresh
macro checks and each profile's P02/P04 run precede that profile's twenty cells.
All 80 control receipts must exist before dependent stages can run.

SPEC-015 remains implementing, its plan active, and P08 open. This is maintenance
of the analyzer reference application and four-profile stack/ABI validation
required by ITERATION-003 IT-AC-008. Governance authority remains FEATURE_LIFECYCLE,
AI_AGENT_RULES, ITERATION_SCOPES, the approved iteration scope, accepted ADR-036/039,
SPEC-015 and its active plan. The implementation-executor and
deferred-work-curator procedures apply. No architecture, contract, lifecycle
transition or new deferred work is introduced by this packet.

## Derivation and contents

The runner and active supporting inputs derive from campaign10 preparation.
The new packet changes literal campaign10 identifiers to campaign11; this
includes a separate campaign11 ARM A4 binder, leaving the archived binder
untouched. The older Static policies retain their original historical operand
roots and use their existing current-core authentication APIs.

The 45 diagnostic forms are the exact bytes of batch1 policy at commit
`bc5acd3c27e18dbe8c0f7837ed5ec99f707a2653`, with pinned SHA-256
`b16415ab48830c7bed7ee94e9e653a8a75b76968e8b23aca758a2d6504594dca`.
`batch1-archived-captures.json` is also copied unchanged. `fresh-templates.json`
extracts exact archived argv, registered control and core operands. The special
ARM A7 archived campaign capture supplies its stage argv; its complete control
comes from the unchanged campaign10 registered controls. Every other control
matches the discovery capture exactly. The template bytes have a separate pin
inside `fresh_policy.py`.

`fresh_policy.py` is a separate pure matcher. It relocates only the six enumerated
historical roots (discovery and campaign10 in three namespaces) to the three
literal campaign11 roots. Component boundaries, canonical paths and one-pass
relocation prevent prefix aliases and traversal. It maps full stream templates,
source keys and argv consistently; toolchain, SDK, plugin and all other tokens
stay exact. A separate exact core `-I` operand comes from the authenticated
current P02. It accepts only integer exit 1, no launch anomaly, exact full raw
stdout/stderr, complete unchanged control and exact source snapshots. Captures
and matcher results always carry `qualified=False`; only the campaign's existing
receipt route qualifies a control.

Before each of these 45 launches the runner independently authenticates actual
HEAD/freeze, P02 stage logs, current receipt and archived receipt copy, complete
frozen profile-specific receipt fields/checks/compiler/plugin/source identities,
recomputed input digest and fresh root, all receipt artifacts, preceding completed
control receipts, required prerequisite stages, actual generated-source/lowerer
joins, imported module joins, and all completed producer outputs for that profile.
It captures and writes an audit with context, exact argv/cwd/environment digest,
compiler and SDK identities, receipt/artifact map, sources, root map and completion
time. It rechecks immediately before process launch and after exit; the pure
matcher checks the immutable context/source snapshots and complete streams.
Producer output snapshots are captured immediately after successful stages,
including stages inside ABI-negative cells. Actual filesystem captures reject
symlink aliases and stale generated artifacts.

`fresh-core-fields.json` derives exact Static fields from the existing Static
policy and exact cross-target fields from the ARM current-core policy. Dynamic
changes only the profile; Embedded changes the profile and compiler path. The
required input inventory, compiler bytes, macro/SwiftSyntax bytes and complete
positive and negative check list remain exact. Unknown future receipt digests,
module bytes and output roots are acquired and authenticated sequentially;
they are not missing preparation facts or generic replacement waivers.

`postformat-freeze.json` captures the current 541-input candidate and is pinned
by the runner. No maintained Swift file changed in this packet. Any later
formatting or source change requires a reviewed refreshed freeze and pin before
launch. The working tree contains unrelated existing source/build-script edits;
they are not modified by this packet.

## Static validation and review gate

Run from repository root:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/analyzer-abi-continuation-campaign11-preparation/test_fresh_policy.py
```

Four tests exercise all 45 exact forms and planned argv, mutations to exits,
streams, control identity, provenance, source bytes, core and template identity,
all six path roots, traversal/prefix aliases, and runner sequencing hooks.
These tests establish matcher/static integration behavior, not actual producer
or compiler success. Independent readiness review must assess the filesystem
trust boundary, fresh P02 assumptions, preserved Static/ARM policies and the
frozen invocation before any compiler/campaign invocation. No current unknown
receipt/module bytes require advance invention. Any first material failure
must produce a stop with later controls/dependents unrun and no repair/retry.

P08/current-callee/cold/resources/P09–P12/I4-07/runtime/safety/conformance remain
open. Historical closed campaign budgets are not reopened by this preparation.

## Readiness correction after independent Strong review

The correction addresses the five readiness blockers in the review of
`019bf10a`. It introduces no new campaign allowance and executes no compiler.

1. Launch requires independent review to supply the exact committed revision,
   repository tree and packet subtree IDs. The sole intended launch route reads
   `reviewed-launch.py` from that reviewed Git object using `git show`, piping
   its bytes to `PYTHONDONTWRITEBYTECODE=1 python3 - COMMIT TREE PACKET_TREE`.
   The bootstrap reads its verifier from the same Git commit before loading any
   working-tree packet Python or JSON. It authenticates the commit/tree object
   bytes, joins the three IDs, compares the exact packet inventory and every
   actual blob byte, then invokes the runner with all three external pins.
   Directly invoking a mutable working-tree launcher is not the reviewed launch
   route. The IDs must come from the completed independent review; the packet's
   mutable manifest supplies no external trust. The runner repeats this check at
   every verification boundary. Its lock re-execution preserves all external IDs.
2. `fresh_context` calls full verification before creating or rechecking a
   capture. Every launch verifies actual HEAD, all 541 frozen input bytes,
   compiler bytes and resolved identities, packet Git blobs and input inventories
   both before subprocess start and after it returns. Cached labels/digests do
   not substitute for these actual filesystem checks.
3. ARM P02 and every ARM scratch producer/consumer launch reauthenticate the
   complete SDK inventory, links, bytes, archive and installation receipt before
   and after the process. ARM fresh capture and dependent gates also reauthenticate
   it. A changed SDK cannot qualify a negative or release the dependent gate.
4. `producer-input-inventory.json` seals 498 discovered maintained source and
   fixture files. Rules cover all files under Sources, the complete P02 fixture
   discovery directories, all SPEC015 RuntimeDerived files, generated workload
   TSVs and macro test Swift sources. Every launch checks both exact discovered
   membership and bytes, preventing newly added files from entering a producer's
   glob between reviewed preparation and launch. Frozen producer scripts retain
   their exact glob rules. Completed imported object/module inventories are
   checked separately against sealed producer/control receipts.
5. The 80-receipt gate now reauthenticates exact order, every control receipt and
   artifact, all producer receipts and their preserved copies, current P02 fields,
   inputs and artifacts, transitive positive modules, every captured producer
   output and stage log, actual object/module inventories, and the ARM SDK. The
   gate runs before dependent release and before and after every dependent
   subprocess. Legal additions to the shared positive cell are checked against
   the union of its sealed control receipts; unknown additions reject.

`test_readiness.py` adds four tests using real temporary files. They exercise
resealed packet manifests and changed HEAD against externally pinned Git objects;
all 541 frozen inputs, compiler mutations, added discovered files and symlink
aliases; the actual SDK authenticator against changed bytes/added files/symlinks;
and the actual 80-receipt gate against first/last receipt, core artifact,
positive module and extra imported-object mutations. These complement the four
finite matcher tests. No compiler or campaign ran. The corrected commit requires
a new independent readiness review and externally supplied object pins before
launch.

## Second readiness correction

The four residual blockers in the review of `d4d78043` are corrected here.

- `frozen-links.json` explicitly pins the real freeze's two supported `swift`
  and `swiftc` links by exact path, literal link target, resolved path and bytes.
  The other 539 frozen files still reject aliases. The compiler-free suite now
  authenticates the actual real 541-input freeze and tests an alternate link
  targeting identical bytes.
- Every authentication Git subprocess and trusted bootstrap uses
  `git --no-replace-objects`. Every retrieved packet blob is independently hashed
  as a Git blob object, in addition to the commit and tree objects. The bootstrap
  independently hashes its retrieved verifier blob. A real temporary repository
  with an active blob replacement ref cannot substitute changed packet bytes.
  The external trusted launch command must likewise use
  `git --no-replace-objects show REVIEWED_COMMIT:.../reviewed-launch.py` before
  piping to `PYTHONDONTWRITEBYTECODE=1 python3 - COMMIT TREE PACKET_TREE`.
- `verify_unlocked` authenticates the reviewed Git packet, exact freeze, supported
  links, compiler identities, input discovery inventory, complete installed ARM
  SDK/archive/provenance and materialization candidate before the Ruby lock
  script can execute. This includes the frozen
  `scripts/lib/serialize-validation.rb` bytes. Verification repeats under the
  lock and at producer/consumer boundaries. The actual pre-Ruby verifier is tested
  against a changed lock script.
- Every control receipt now seals every matching stage's complete stdout/stderr
  identity, source provenance and prelaunch audit references, including negative
  stages. Existing policy authentication audits are also retained. The complete
  80-receipt gate rechecks these actual files before each dependent use; actual
  negative-stream and fresh-audit mutations are rejected by its filesystem test.

Positive scratch sources needed additional provenance checks. Every explicit
Swift input and each lowerer's two input operands now has exact provenance checked
before and after process execution. Maintained inputs join the reviewed freeze or
input inventory; materialized inputs join the exact positive/negative candidate;
generated inputs join an already completed lowerer output snapshot. These source
captures are sealed into stage/control receipts and checked again at the dependent
gate. Tests mutate both materialized positive and generated inputs.

The suite now has twelve compiler-free tests (eight filesystem/readiness tests
and four finite matcher tests). No compiler, campaign or producer command ran.
This correction requires a fresh independent review and new external object pins.

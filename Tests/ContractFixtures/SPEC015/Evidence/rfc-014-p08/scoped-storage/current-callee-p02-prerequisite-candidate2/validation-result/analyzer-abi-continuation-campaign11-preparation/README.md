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

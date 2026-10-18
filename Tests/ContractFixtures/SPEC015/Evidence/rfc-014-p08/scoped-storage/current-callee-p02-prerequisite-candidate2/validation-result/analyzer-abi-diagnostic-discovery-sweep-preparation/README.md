# P08 Analyzer ABI diagnostic discovery sweep preparation

**PREPARATION ONLY. UNEXECUTED. INDEPENDENT READINESS REVIEW REQUIRED.**

This evidence-local packet implements the bounded proposal committed at
`9af639a2`, from campaign10 packet `8789f33e` and terminal archive `8ad2d63d`.
It proposes one discovery invocation, one fixed source candidate, zero retries
and zero repairs. It confers no compiler execution authority, diagnostic policy,
qualified control receipt or P02/P08 acceptance. Historical campaigns, stops,
allowances and policy packets retain their meanings.

This narrow correction addresses readiness blocker B01 from packet commit
`b8935ba312302d856f0a46ff68d2d2bf1be05c50`: the editable local manifest was not an
immutable review anchor. `anchor-correction-provenance.json` lists the unchanged
base blobs and the exact corrected payloads. Target/control/source/environment
identities and execution budgets are unchanged.

SPEC-015 remains implementing, its plan active and P08/R07/T8.1 open. Accepted
ADR-036/039 and approved SPEC-006/010/015 supply the existing contract context;
ITERATION-003 revision 5 I3-04/I3-05 supplies evidence maintenance context.
ITERATION-001's shared Signal Analyzer and four target configurations explain
the reference need. Full scoped-storage delivery remains ITERATION-004 I4-07.
No architecture, contract, lifecycle status, manifest, maintained source or
optional scope changes occur in this packet.

## Closed inventory and prerequisites

`plan.json` contains exactly 50 target cells, in this order:

- ARMv6: `negative-A8`, five `private-*` controls and four `outside-package-*`
  controls, in original registration order: ten targets.
- nRF52840 Embedded: all twenty original registered controls.
- macOS Dynamic: all twenty original registered controls.

The 29 previously qualified controls are excluded as target observations. ARMv6
A7 is excluded: campaign10 already archived its exact raw rejection, without a
qualified receipt. The proposed later policy batch may review that archived
output separately. This packet grants no A7 allowance.

There are 56 cells and at most 118 launches. Six cells are prerequisites only:
one isolated core producer per profile and three complete fresh ARM positive
controls. Embedded and Dynamic positives are both registered targets and gates
for their own dependents. Each cell runs once, sequentially; each negative stops
at its original declared first rejection stage regardless of exit or wording.

The isolated core producer preserves the P02 module source order, compiler and
flags. It builds GiftUI, lowers the unchanged Counter schema/source, then builds
CounterSchema and CounterPresentation. Those Counter modules support the
unchanged DeclarationHost/native 120-check oracle; no counter workload runs.
The exact existing macro executable is authenticated against campaign10's
qualified P02 receipt and actual bytes. `producer-derivation.json` records the
direct producer subset and its differences from a full P02/P04 run. No P02/P04
runner, macro build or macro test suite is proposed. The subset creates no
P02/P04 qualification.

All three positive controls retain their original stages. Native declaration
execution requires `checks=120 failures=0`; native semantics requires
`analyzer-abi semantics=18 failures=0`. Cross targets retain compile-only
semantics and DeclarationHost ELF checks for ARM/v6 or ARM/v7E-M with VFP
calling convention. A failed core producer blocks that profile. Failed positive
actual lowering blocks its dependents; failed serialized read blocks ABI/privacy
negatives, and failed semantics blocks privacy negatives. Every block is
recorded. Only independent cells continue. Global identity, infrastructure or
storage failure stops all remaining cells, with explicit unrun dispositions.

## Frozen commands, environment and evidence

The literal per-stage argv, input paths/hashes, outputs, intended rejection
stage, control registration and dependency edges are all in `plan.json`.
`registered-controls.json`, `selectors.json` and `scratch-sources.json` are byte
copies of campaign10. `static-inspect.py` independently expands all 118 commands
against that recipe and the P02 core command shape. Source order, flags,
package-name removal and oracle identities are preserved; active output/cache
paths relocate to the new discovery roots.

The original 541-input postformat freeze remains SHA-256
`0cb2c32520e4344940c4801c9bfea21206e828dd2d6db07dfb8ae06dd4840333`.
Its inputs currently match. Compiler package, driver/frontend/library/header
installation, both compiler paths, full macOS SDK and ARMv6 SDK installations,
SDK archive/install provenance, readelf, plugin, interpreters, lock script and
Xcode linker/selection metadata are pinned by byte identities. Embedded Swift's
bundled ARMv7E-M modules belong to the frozen compiler installation. nRF remains
`nrf52840dk/nrf52840` / `armv7em-none-none-eabi`, with original Cortex-M4F hard-float
flags. Raspberry Pi remains `armv6-unknown-linux-gnueabihf`.

**The explicit environment is a new discovery context.** Campaign10 archived
environment overrides, and an effective hash for ARMv6 A4, but did not archive
the inherited values. Environment equivalence cannot be reconstructed or
claimed. `environment-context.json` freezes locale, PATH, DEVELOPER_DIR, TMPDIR
and every supplied value, and names absent SDKROOT/TOOLCHAINS, Swift/Clang extra
flags/cache, DYLD, TERM and color variables. Actual HOME `/Users/eugene` is
preserved; relevant Swift configuration roots and their absence/byte state are
frozen in `home-config-identities.json`. Explicit caches and TMPDIR isolate
discovery writes. Only the actual direct lock-owner PID is added at runtime.
Complete effective environment values and their canonical SHA-256 are captured
before every launch. No diagnostic selects any environment value.

A future diagnostic policy or qualification campaign must separately establish
applicability to its reviewed environment, or explicitly adopt this reviewed
context. This archive cannot prove campaign10 diagnostic dialect equivalence.

Before launch, the runner seals source, module, producer, tool, SDK, argv,
environment, current commit and dependency identities into an independent audit.
It checks the permanent validation lock's owner/inode, exact HEAD, frozen inputs,
packet, historical bytes, installed inventories, prerequisite artifacts and
32 GiB minimum free space before each stage. Source/module/SDK/identity and audit
checks repeat after launch. Each actual exit and complete binary stdout/stderr
file receives byte count and SHA-256. Raw logs, audits and source copies are
sealed against later drift. No diagnostic parser is imported or invoked.

The invocation now requires an **external full reviewed packet commit SHA**.
Before reading any packet JSON, the runner authenticates every packet file,
including itself, the plan and its manifest, against that commit's exact Git
tree/blob bytes and file modes. It rejects missing files, untracked additions,
symlinks, replacements and Git object-content mismatch. Git replacement objects
and inherited Git configuration/environment cannot reinterpret the anchor.
The immutable packet snapshot is checked before every stage, immediately before
each process launch and after launch. Its commit/tree/snapshot identity joins
the run record and each prelaunch audit. Runtime HEAD is frozen separately as
source provenance; it never chooses or replaces the reviewed packet anchor.

Expected exit one is an **unqualified observation only**. Exit zero at a negative
stage is a failed negative observation; abnormal exits are archived unqualified.
Unexpected failure before the intended rejection stage blocks the rest of that
cell. None of these outcomes creates a qualified control receipt, privacy pass,
profile completion, acceptance or diagnostic allowance.

## Future invocation and fresh roots

From `/Users/eugene/work/GiftUI`, only after independent readiness review and
separate authorization for the one sweep invocation, use this template with the
externally reviewed correction commit's full SHA:

```sh
/usr/bin/ruby /Users/eugene/work/GiftUI/scripts/lib/serialize-validation.rb /Applications/Xcode.app/Contents/Developer/usr/bin/python3 /Users/eugene/work/GiftUI/Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/analyzer-abi-diagnostic-discovery-sweep-preparation/execute-discovery.py --execute-reviewed-discovery-once --reviewed-packet-commit REVIEWED_FULL_COMMIT_SHA
```

The concrete command with the resulting full commit SHA is supplied outside
this packet in the correction handoff/readiness review. Keeping the anchor in
that external invocation avoids embedding a commit ID inside its own committed
payload. `plan.json` stores only the `{reviewed_packet_commit}` argument template.
Do not choose the SHA from editable packet data, a branch name or runtime HEAD.

The reserved roots must all be absent:

- `.build/contracts/p08-analyzer-abi-diagnostic-discovery-sweep`
- `.build/raspberry-pi/contracts/p08-analyzer-abi-diagnostic-discovery-sweep`
- `.build/nrf52840/contracts/p08-analyzer-abi-diagnostic-discovery-sweep`

All three roots are reserved before the first compiler. A started sweep cannot
resume or reuse them, even if some cells are blocked. Startup preflight failure
before reservation launches no compiler and produces no discovery receipt. Lock
availability and continued storage/identity/config stability are runtime
prerequisites; preparation does not assert future availability.

The primary root holds `result.json`, exact packet/freeze copies, raw stage
logs, prelaunch audits, byte copies of source inputs and `archive-manifest.json`.
Target-specific sources, caches, modules and objects stay under the corresponding
reserved roots. Every consumed/generated source and module/object output has an
identity; caches are excluded from export. The fixed record schema and exact
file naming are recorded in `plan.json`. The final result distinguishes observed,
failed and prerequisite-blocked targets, all unqualified.

## Preparation validation and remaining review

Only AST parsing, JSON decoding, independent recipe expansion, directory/symlink
inspection and byte/hash comparison ran. The runner was never imported or
executed. No compiler, parser, producer, campaign, formatter, test, hardware,
resource check or deployment operation ran. Static inspection checks all 50
targets, all 118 argv, 541 frozen inputs, 2,595 historical files and complete
installed inventories. `static-inspection.json` records that result;
`packet-hashes.json` seals every packet payload except itself.

The read-only inspection command is:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/analyzer-abi-diagnostic-discovery-sweep-preparation/static-inspect.py
```

After the correction is committed, add `--reviewed-packet-commit` followed by
that external full SHA to independently compare the entire working packet to
the committed Git blobs. This is read-only inspection and never invokes or
imports the discovery runner. The precommit static report cannot contain its
own resulting commit SHA; the postcommit check is reported externally.

Independent review must assess the complete integrated wrapper, direct producer
derivation and new environment context before execution. AST/JSON/hash checks
cannot prove runtime correctness or compiler acceptance. Full inventory checks
are deliberate and may take time. The packet has no automatic repair path.
Review the eventual raw archive independently, map exact observed forms to their
profile/source/compiler/SDK/environment, and prepare a separate finite policy
batch plus adversarial static tests before proposing a new qualification run.

P07, schema4 activation, counter384, resources, flashing and deployment are absent.
P08/current-callee/cold/resources, P09–P12, I4-07, runtime/safety/privacy and
conformance completion remain open. No lifecycle transition or retroactive
campaign receipt is granted.

# ITERATION-002 delivery coordination plan

**Governing scope:** [approved revision 7](../iteration-002-cleanup.md),
[approval provenance](../iteration-002-review/32-scope-approval.md), approval
commit `2a0bf0fa`.
**Prepared:** 2026-10-04. **Execution:** not started.

This derived record coordinates the nine approved outcomes across existing
owner plans and repository tooling. It adds no architecture, contract,
exception or approval. The SPEC-001/011/013 plans contain the executable
maintenance tasks; their original milestones and evidence remain historical.
Other owner Specifications retain their existing plans and regression gates.

**Readiness:** I2-01–08 have grounded maintenance tasks under current contracts.
I2-09 has an ordered upstream artifact workflow; retention production work is
not ready and has no executable task under the current 30s contract. Iteration
approval is complete, and final closure waits for every selected outcome or an
explicitly approved scope amendment/exception.

## Authority and current state

This is post-MVP maintenance of features registered as `implemented`, preserving
[ITERATION-001](../iteration-001-mvp.md)'s shared Signal Analyzer and four target
configurations. Accepted ADR-003/007/008/033 and implemented
SPEC-001/002/007/011/013/015 govern the affected owners. The accepted Proposals
and approved RFCs remain the authority chain linked by those Specifications;
superseded ADR-002/013 and experimental sources are historical only.

- `DefaultSignalAcquisitionRepository.start()` currently publishes running after
  callback-capable source startup; terminal revision failure can occur inside it.
  The real deterministic source and lifecycle suites provide the regression seam.
- `InteractionState.finishCandidate()` preflights retained commit capacities but
  omits staged committed capacity before copying. The standard equal-capacity
  composition does not demonstrate production reachability of the unequal case.
- `scripts/test.sh` clears a selection-only report/cache root. Child drivers also
  use shared output paths; parent directory uniqueness alone is insufficient.
- Deferred `source` paths conflict with the authority graph's ID-only handling;
  `Tests/GovernanceTooling` supplies fixture-based validation seams.
- `run-spec-001.sh` captures the default compiler and emits it as Pi artifact
  identity; the actual cross-build uses the project-local paired compiler.
- Firmware startup still uses separate text-measure/place fragments. Common
  Layout and native firmware rehearsal already exist and must retain codec checks.
- The 15 Step 15 files need coordinated SwiftPM exclusion, nRF CMake and native
  compile lists. Packed topology updates currently consume previous Swift output;
  SPIKE-011 demonstrates clean emission but its code is not production authority.

[Steps 00–30](../iteration-002-review/README.md) supply investigation evidence.
The 72-check historical gate and connected observations are preserved, not
reused as passes for cleanup. No production source changes in this derivation.

## Scope-to-task matrix

| Scope item | Owning tasks / dependencies | Required exit evidence |
| --- | --- | --- |
| I2-01 | SPEC-001 T11.1 → T11.2 | Real-source max/max-minus-one and callback-then-throw cases, no duplicate running/failure publication, stopped source, normal lifecycle and affected host comparison |
| I2-02 | SPEC-011 T10.1 → T10.2 → T10.3 | Independently unequal capacities, exact contained result/precedence, unchanged committed state, discard/reuse, equal-profile and ABI/resource evidence |
| I2-03 | TOOL-01 | Overlap, interruption and failure fixture; no parent/child report or scratch/cache interference; retained invocation and exact child identities |
| I2-04 | TOOL-02 | Safe existing/missing/escaping paths, ID/path mixtures and unknown IDs; strict authority relationships and reciprocal-link validation retained |
| I2-05 | SPEC-001 T11.5; final real-run verification in T11.6 | Differing native/paired compiler fixture and fresh metadata matching actual compiler/SDK/build/artifact identities across profiles |
| I2-06 | SPEC-001 T11.3 | Migrated startup/text/codec corpus, duplicate fragments and consumers retired, paired no flash/RAM growth, connected startup regression in T11.7 |
| I2-07 | SPEC-013 T10.1 → T10.2 → T10.3 | Exact 15-file outer-guard/empty-shell change, coherent source selection, residual policy, native behavior, unchanged linked size and profile/dependency negatives |
| I2-08 | SPEC-001 T11.4 | Two clean generations, exact outputs and 42 maintained semantic cases, stale/malformed input refusal, generator-only zero flash/RAM delta; explicit partial CBR-002 disposition |
| I2-09 | RET-01 → RET-02 → RET-03 → RET-04; production task derivation held until gates pass | Approved upstream artifacts, then ready exact implementation/validation tasks for the approved retention contract; IT-AC-005 stays pending |

## Iteration acceptance-criterion matrix

Each iteration criterion appears once here. The owner plans retain complete
Specification criterion matrices and append cleanup tasks to affected rows.

| Criterion | Tasks / existing baseline | Planned evidence / current disposition |
| --- | --- | --- |
| IT-AC-001 | Approval record; FINAL-01 | Registered approved revision and provenance; approval established, final navigation/governance check pending |
| IT-AC-002 | SPEC-011 T10.3; SPEC-013 T10.2/T10.3; SPEC-001 T11.6 | Before/after imports and target/source closure, existing dependency gates; pending cleanup validation |
| IT-AC-003 | SPEC-001 T11.4 | Clean output/freshness/refusal/parity/zero-delta packet and residual mappings; pending |
| IT-AC-004 | SPEC-013 T10.1/T10.2/T10.3 | Named-file selection and source/profile/resource packet; pending |
| IT-AC-005 | RET-01–04, subsequently derived production tasks | Current ADR-003/Spec amendments missing; implementation blocked, no research result promoted to production pass |
| IT-AC-006 | Steps 00–30; FINAL-01 | Preserved baseline/coverage/archive hashes and explicit evidence limits; preparation established, preservation checked at closeout |
| IT-AC-007 | SPEC-001 T11.8; FINAL-01 | Every item and criterion has evidence/disposition, coherent commits, precise exceptions and human closure; pending |
| IT-AC-008 | SPEC-001 T11.1/T11.2/T11.7 | Callback-safe source/host lifecycle packet; pending |
| IT-AC-009 | SPEC-011 T10.1/T10.2/T10.3 | Unequal-capacity/preflight/commit/rollback packet; pending |
| IT-AC-010 | TOOL-01; SPEC-001 T11.6 | Isolated/serialized runner fixture and real gate invocation ledger; pending |
| IT-AC-011 | TOOL-02 | Source-path/authority graph fixture and repository governance packet; pending |
| IT-AC-012 | SPEC-001 T11.5/T11.6 | Actual artifact/native/SDK identity packet; pending |
| IT-AC-013 | SPEC-001 T11.3/T11.7 | Migrated common-engine startup corpus, paired resource/ABI and connected startup packet; pending |

## Ordered work and dependencies

1. Execute the correctness milestones: SPEC-001 T11.1/T11.2 and SPEC-011
   T10.1/T10.2. Their interfaces are fixed; they may be developed independently
   but shared build/driver output must not overlap before TOOL-01 protects it.
2. Complete TOOL-01, TOOL-02 and SPEC-001 T11.5. TOOL-01 is a prerequisite for
   overlapping aggregate gates. TOOL-02 must retain the existing strict ID rules;
   it does not resolve missing lifecycle approvals.
3. Complete SPEC-001 T11.3/T11.4 and SPEC-013 T10.1/T10.2. Land startup text
   removal before finalizing Embedded selection so CMake/native lists are not
   repeatedly reconstructed from stale source sets. Generator-only paired-size
   comparison must precede unrelated resource changes.
4. Perform SPEC-011 T10.3 and SPEC-013 T10.3 owner validation. In parallel with
   independent maintenance, RET-01–03 may prepare upstream documents; each
   downstream artifact waits for its normal human gate.
5. After maintenance integration, SPEC-001 T11.6/T11.7/T11.8 record fresh
   hardware-free and focused connected results. If retention is still blocked,
   label this the maintenance packet under the unchanged 30s contract; do not
   call it final iteration completion. After RET-04 enables actual retention
   implementation, rerun affected/combined checks for those new changes.
6. FINAL-01 reconciles all nine outcomes and requests closure only when the scope's
   exit dispositions are complete. Scope remains `approved` during planning;
   set it `active` when implementation starts. Commit each completed coherent
   task/step with its result and evidence; never mark a planning task as code fixed.

### Repository tooling tasks

- [ ] **TOOL-01 — Runner isolation and publication.** Inspect parent and child
  shared paths in `scripts/test.sh`, `scripts/contracts/*`, compiler caches and
  firmware/SwiftPM build roots. Implement safe isolation or serialization through
  all those writers, preserving explicit standalone commands and the registry.
  Exercise two overlapping same-selection invocations, failure and interruption
  using cheap fake checks in isolated fixture roots; retain distinct reports,
  exact child IDs and complete failure ledgers. Check safe latest publication,
  lock cleanup if used and retention policy that cannot delete active runs.
  Register the maintained fixture check explicitly in the existing runner
  (or extend its existing governance-tooling check). The real final gate supplies
  integration evidence. No new report schema may silently invalidate consumers.
- [ ] **TOOL-02 — Deferred source-path alignment.** Update
  `scripts/governance/build-authority-graph.rb` and the existing authority-graph
  fixture suite. Accept documented repository sources without confusing paths
  with unknown artifact IDs; reject missing, absolute/escaping or unsafe paths
  under the repository rules. Test valid ID/path/mixed sources, unknown IDs,
  missing files and symlink/path-resolution escapes. Retain strict authority edges,
  metadata statuses and reciprocal artifact links. Run `scripts/governance/test.sh`
  and `ruby scripts/validate-governance.rb`; record the exact changed graph/source
  representation and corrected reproduction. Dependency: current documented
  `source` rule, not a new approval shortcut.

### Retention upstream workflow — no production authorization yet

- [ ] **RET-01 — RFC amendment and review.** Use rfc-author/rfc-reviewer to
  prepare the smallest reviewable amendment within accepted PROPOSAL-002 and
  RFC-001's capture boundary. Preserve historical approved reasoning and explicit
  status. Define the 5s horizon, inclusive cutoff/404 rationale, baselines,
  equal-time/overflow/publication behavior and three-store accounting using
  Step 14 evidence. Keep 1/2/5s views, 10 Hz/channel and the 30s/80-event/s workload.
  Scope approval authorizes preparation; explicit human RFC approval remains.
- [ ] **RET-02 — Successor retention decision.** After RET-01 approval, use
  adr-author to extract the accepted direction into a proposed successor to
  ADR-003. Allocate the next unused ADR ID at authoring time, preserve old history
  and reciprocal successor relationships, and obtain explicit acceptance before
  treating it as architecture.
- [ ] **RET-03 — Coordinated Specification amendments.** After the decision
  gate, use spec-author/spec-reviewer for SPEC-001/SPEC-015 and any affected
  SPEC-013 resource assumptions. Account for Domain/Data/live/model/admission
  stores, C/Swift size guards, workload fixtures, derived designs and report
  consumers. Retained record count and total delivered count get separate oracles;
  existing timing/cadence requirements and exceptions retain their meanings.
  Obtain explicit approval of the exact contracts before production use.
- [ ] **RET-04 — Derive the now-authorized retention tasks.** Use
  implementation-planner after RET-03 to amend governing owner plans and task
  ledgers with exact requirements. Replace this held handoff with executable
  tasks for all three stores, boundary/replay/snapshot/pixel/workload checks and
  paired RAM/ABI/heap/resource validation. Cover IT-AC-005 completely and inspect
  the existing connected-host design. Do not use the current plan to mechanically
  substitute `2404`/`30`: those values also describe historical evidence and the
  unchanged delivered-event workload. This task ends at a ready plan, not code.

### Final integration and closure

- [ ] **FINAL-01 — Iteration reconciliation.** Depend on completed owner tasks,
  TOOL-01/02 and approved/executed retention tasks, or a separately approved scope
  amendment/exception for any missing outcome. Verify all thirteen iteration
  criteria, complete/partial/deferred finding dispositions, immutable report and
  artifact identities, source/authority links, scope status and deferred triggers.
  Preserve CBR-002's residual mapping policy and CBR-005's unmeasured lookup share.
  Refresh conformance evidence only for new observations; timing/physical gaps
  stay linked to FW-027/031/032/033. Request explicit human closure with unmet
  criteria and exact exception provenance visible. No automatic Specification
  transition or finding closure follows from the aggregate pass.

## Validation commands and evidence

Run from repository root. These are future task commands, not checks performed
by this planning step:

```sh
scripts/format-swift.sh
scripts/governance/test.sh
ruby scripts/validate-governance.rb
scripts/contracts/run-spec-001.sh --profile macos-dynamic
scripts/contracts/run-spec-011.sh --profile macos-static
scripts/contracts/run-spec-013.sh --profile nrf52840-embedded
scripts/test.sh all-hardware-free
```

The standalone drivers also accept `macos-static`, `raspberry-pi-armv6` and
`nrf52840-embedded` as registered; owner tasks specify the required profile set.
Use focused suites/corpus first, then owner gates, then one combined final gate.
Repeat/broaden only for subsequent changes, failures or unresolved concerns.
Do not overlap writers until TOOL-01's chosen protection covers their paths.

Use the repository Pi/nRF build skills and stable commands for target artifacts:
Pi product `SignalAnalyzerRaspberryPiARMv6`, nRF application
`signal-analyzer-static`. Keep toolchains/builds local, enforce Pi ARMv6 and
nRF ARMv7E-M/VFP hard-float ABI, disabled heaps and approved resource bounds.
Collect matched before/after sizes per simplification; do not sum Spike savings
as an assumed combined production result.

Connected checks use the standing maintainer device-work authorization and the
approved changed-path validation scope. Verify current target identities and
artifact hashes immediately before use; Pi must report `armv6l`, nRF must match
the intended J-Link/board. Use the owning connected-host design for application
commands and pin maps, stable deploy/flash routes, bounded sessions and teardown.
The last research targets were `giftui@giftui-pi.local` and J-Link `683833660`;
these are observations to verify, not substitutes for current device evidence.
Do not restart an unrequested service or infer physical contacts from software
input. Unavailable hardware leaves a task blocked rather than passed.

Keep evidence in new immutable iteration-002 packets referenced by the affected
owner tasks. Record repository/dirty-source, fixture, command, compiler/SDK,
artifact and raw-log identities; parent/child run IDs, failures, limits and
reproduction commands must be recoverable. Evidence paths are allocated during
execution; empty task `evidence` lists here mean no execution proof yet.

## Design-note triggers and risks

- No new design note is required for the local startup/capacity corrections.
  Update existing owner notes if their lifecycle explanations become inaccurate.
- Maintain SPEC-001's static-semantic note if clean generator template/policy
  ownership needs explanation, or SPEC-013's storage note if source-list
  selection becomes difficult to reconstruct. Notes cannot define new ownership.
- Retention's live/model/admission and snapshot lifetime may require updates to
  the existing connected-host/admission design after approved contract changes.
- Runner isolation must cover child-owned writers, not just parent logs;
  serialization is acceptable where individual build roots cannot isolate safely.
- Generator determinism requires projection freshness and explicit codec/policy
  inputs; matching previous output without fresh inputs is insufficient.
- The source-start reproduction does not prove the same bug exists on nRF.
  Compare target lifecycle behavior before selecting additional corrections.
- New architecture, contract or resource-bound divergence pauses affected work
  for triage. Missing retention approvals are current blockers, not deferred ideas.

## Deferred and follow-up work

Approved exclusions remain unchanged: performance and lookup optimization under
FW-027/FW-032; broad connected validation under FW-031/FW-033; residual guard
work under FW-029; named roles/full runtime replacement under EXP-001 and its
Spikes; compiler-output diagnostics under FW-028. Their existing authoritative
source links and revisit triggers remain in force. No new deferred item,
feature stage, exception or optimization is created by this plan.

## Completion record

All new execution tasks are pending; retention production remains held upstream.
Original completed owner tasks and historical criterion/exception evidence are
unchanged. [Plan-derivation checks](../iteration-002-review/33-implementation-plan-derivation.md)
record this document step separately from future execution.

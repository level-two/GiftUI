# ITERATION-003 preparation baseline — 2026-10-05

**Current handoff — 2026-10-09:** Iteration 2 is closed; iteration 3 owns
runtime/memory/efficiency and iteration 4 owns external integration. PROPOSAL-007
is accepted and RFC-013 remains draft. Use the [current plan](../../../iterations/iteration-003-review/memory-efficiency-plan.md);
the dated observations and former next steps below are historical context.

Prepared after Eugene's instruction “Please then proceed.” following the
baseline → consumer study → post-MVP Proposal preparation sequence.
[ITERATION-003 revision 2](../../../iterations/iteration-003-dev-ux-improvement.md)
remains the commitment; this record adds evidence and lifecycle navigation,
not a scope amendment or architecture approval.

## Baseline identity and cleanup dependency

Initial inspection and probes used HEAD `8e3e5ee9` with no production-source diff.
Concurrent iteration 2 documentation/evidence commits advanced HEAD to
`c1fdd3b9`; the final baseline was refreshed after their completion. The
maintained production inputs are unchanged.
[Baseline JSON](evidence/baseline.json) records the full revision, 846 maintained
input hashes, the actual manifest graph (84 targets / 13 products), observed
aggregate ledgers and the matched nRF comparison image. The
[input inventory](evidence/maintained-input-hashes.tsv) covers Sources, firmware,
package and target/contract scripts. Documentation and experimental additions
are not new production implementation.

| Observed evidence | Current meaning |
| --- | --- |
| `run-ZP4SPN01`, revision `759cf594`, complete / exit 0 / 74 recorded checks | Historical four-profile maintenance pass. It predates the retention/current-trace correction; it is not final current-retention validation. |
| `run-bmuwVkCK`, revision `a607be12`, interrupted / exit 143 / 46 recorded checks | Retained interrupted aggregate. The tracked current-trace correction also preserves its earlier Pi comparison failure; interruption does not erase that negative result. |
| `run-IehHOIJf`, starting revision `feb40589`, complete / exit 0 / 74 checks | Current five-second retention packet passes and verifies 60 owner/profile reports. Exact child revisions/toolchains and unchanged maintained inputs are preserved in packet 18; this is inherited evidence, not a rerun for this preparation. |
| Current nRF ELF hash matches `9822838b…`, the retained retention candidate | Prior identified image: 274,144 flash bytes, 95,104 RAM bytes, 27,648-byte configured main stack, disabled heaps and VFP checks in its retained evidence. No new build or stack high-water measurement. |

Metadata and ledgers are copied under `evidence/` as point-in-time observations;
their `.build/` originals can advance. Raw identities are preserved. Scope 2 is
still active revision 7; its [coordination plan](../../../iterations/iteration-002-cleanup/implementation-plan.md)
and [current reconciliation](../../../iterations/iteration-002-cleanup/evidence/19-current-handoff/result.md)
retain the Pi connected dependency and final closure gates. The
[completed integration packet](../../../iterations/iteration-002-cleanup/evidence/18-retention-integration/result.md)
arrived during this preparation. The initial nonterminal 47-check observation
is preserved separately in `evidence/initial-run-IehHOIJf-*`; it is not a failed
run and is superseded as current status by the actual completed record. This
preparation does not rerun or close iteration 2. Refresh owner/build/generation
hashes and validation before package restructuring.

## Triage and authority

The new investment is registered as `external-application-integration`, lifecycle
stage `proposal`, with accepted [PROPOSAL-007](../../../proposals/proposal-007-external-application-integration.md).
The initial “Please then proceed.” instruction authorized preparation and its
required manifest/traceability updates. Eugene subsequently accepted the
presented Proposal on 2026-10-05; the [acceptance record](../../../iterations/iteration-003-review/proposal-007-acceptance.md)
preserves the exact instruction and clears the RFC-design prerequisite. Keeping a
separate feature prevents the implemented MVP architecture status from looking
like approval of new external access and distribution contracts.

This is major post-MVP work: it changes cross-package contracts, consumption and
host/backend integration, with Embedded/resource/compatibility implications.
The lightweight path cannot select those durable choices. Existing MVP scope
justifies analyzer regression on the four stacks; it supplies no new external
integration requirement or implementation authority.

Accepted ADR-006/007/008/010/033 and implemented SPEC-002/009/012/013/014/015 are
the constraints inspected. FW-016/FW-030, active EXP-002 and SPIKE-014 are
evidence/provenance, not architecture. Original MVP feature statuses remain
implemented. The new Proposal is accepted; RFC review, ADR decisions, Spec
approval and ready plans remain outstanding for the new feature.

## Refreshed consumption evidence

[SPIKE-014](../../../spikes/spike-014-external-consumer-access-baseline.md)
completed six bounded native/Embedded compile probes; exact commands, compiler
versions, source/module hashes, logs and object hashes are in
[results](evidence/spike-014-results.json).

| Probe | Native Swift 6.3.3 | Embedded Swift 6.3.2 / Cortex-M4F |
| --- | --- | --- |
| Counter/status declaration with fixed actions and disabled Reset | Object emitted | Object emitted |
| Independent package names `DisplayTarget` | Package-access rejection | Package-access rejection |
| Independent package names `HostPresetBootstrap` | Package-access rejection | Package-access rejection |

Eight inspected modules lack direct library products: RuntimeCore, RuntimeDynamic,
RuntimeStatic, SurfaceCore, RasterCore, DisplayCore, BackendIntegration and
HostConfiguration (all with the `GiftUI` prefix). Product export and external
type access are distinct barriers. Direct module search paths in this probe do
not demonstrate supported external package resolution.

The baseline confirms current shared endpoint/session/raster validation owners
and host workload/configuration ties to the analyzer from the
[backend inventory](../backend-foundation-inventory-2026-10-05.md). No complete
second host, observable binding, Canvas callable or runnable setup control is
proven. Current setup counts and consumer linked resource totals remain
unmeasured; do not substitute analyzer counts or count failed onboarding as zero.

## Concrete study and decision handoff

The [consumer study](consumer-study.md) fixes the finite 0–9 counter workload,
actions/disabled-state oracle, Canvas stroke variant, display/service-loop
substitution, failure/lifecycle corpus, four-profile evidence matrix and
before/after measurement protocol. It names the remaining access/construction
and finite Static proof obligations without selecting new APIs or ownership.

Proposal 7 covers the coordinated investment and maps EI-001–005 to iteration
IT-AC-001–005. Prepare one integrating architectural review of consumption,
access, extension and host/build interfaces under the accepted Proposal;
separate RFCs only when evidence demonstrates independently reviewable decision
boundaries. RFC design may now proceed; no RFC is yet registered.

| Remaining gate | Exact next action |
| --- | --- |
| Equivalent setup/resource control | Define a bounded full-consumer Spike with the selected control/candidate and budgets; capture real setup and linked costs. Privileged current SPI, if used in control-only research, must remain labeled debt. |
| Static root/actions/Canvas | Prove finite observable slots/generations, action binding, text and Canvas callable/storage realization for the selected consumer; declaration compilation alone is insufficient. |
| External contracts/topology | Compare the actual transitive access closure and construction alternatives; choose through RFC/ADR/Spec gates. Do not make all internals public. |
| Stable cleanup inheritance | Refresh current retention/trace/source/toolchain evidence and coordinate overlapping owners before restructuring. Leave connected Pi/final iteration 2 gates visible. |
| Implementation | Approved Specs, measured resource ceilings and ready criterion-mapped plans. |

The investment gate is complete through the linked human acceptance; the table
lists the remaining work rather than repeating that gate as pending.

General generation/services/simulation remain with FW-006/009/022; EXP-002 keeps
the wider direction map. Performance/physical follow-up remains FW-027/031/032/033.
No new deferred idea is required by this preparation; the existing sources and
triggers suffice. Scope membership adds the new Proposal feature as traceability,
without changing the selected outcomes or revision.

## Reproduction and validation

From the repository root:

```sh
scripts/nrf52840/doctor.sh
python3 experiments/spike-014-external-consumer-access/run.py
python3 docs/explorations/exp-002/preparation-2026-10-05/capture-baseline.py
scripts/validate-governance.rb
scripts/governance/build-authority-graph.rb --check
git diff --check
```

Probe and capture scripts reproduce **current** observations; rerunning them can
change the snapshot and must not relabel the captured baseline as a later pass.
They rely on existing native/Embedded modules and record those artifacts rather
than proving freshly rebuilt owners. The nRF doctor passed; its version set is
retained in [diagnostic output](evidence/nrf-doctor.log).
Governance and authority checks passed: 175 nodes / 1,759 edges, 7 features,
68 main-lifecycle artifacts and all reported task-evidence checks. All 192 local
Markdown links in the changed/new documents resolve. Probe source/log and all
846 maintained-input identities match their snapshots; whitespace checks and
Python syntax checks passed. The Python bytecode check required approved access
to its configured host cache after a sandbox refusal; this did not change the
probe classification or production inputs. Production tests and connected
actions are not repeated for this preparation-only change.

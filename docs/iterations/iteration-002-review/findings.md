# Findings Register

Source baseline: `6cf31f266987e917458f31f05ed8c390cda9a202`.
Local IDs use `CBR-001`, `CBR-002`, etc.; they are review identifiers, not
lifecycle artifact IDs. Findings are recommendations and evidence only.

The approved iteration scope selects remediation; this register records evidence
and dispositions, not an independent implementation authority. No finding is
implemented by the research.

[Approved scope revision 7](../iteration-002-cleanup.md) now selects correction
of CBR-001/003/004/006/007/008 and clean-generation remediation for part of
CBR-002. Named role bindings and residual ordinal/model coupling remain
explicitly unselected under EXP-001; CBR-005 stays under FW-032. Production maintenance evidence now establishes the dispositions below; connected validation has separate outstanding limits.

[Delivery coordination](../iteration-002-cleanup/implementation-plan.md) and
SPEC-001/011/013 cleanup milestones map the selections to executed maintenance
tasks and explicit remaining blockers. [Fresh integration](../iteration-002-cleanup/evidence/10-integration/result.md) records 74 passing checks and 60 verified reports.

| ID | Classification / priority | Observation | Disposition |
| --- | --- | --- | --- |
| CBR-001 | Confirmed preflight/error-classification defect; medium, correctness shortlist | Staged committed-action capacity is omitted from preflight | Corrected: preflight and real Dynamic/Static five-store, rollback/reuse/precedence corpus pass; production trigger was not claimed. |
| CBR-002 | Supported simplification opportunity; medium | Manual ordinal/model mappings couple ordinary source to a separately generated hierarchy | Partial: complete clean generator/freshness/parity passes; manual ordinal/model mappings remain under EXP-001. |
| CBR-003 | Supported simplification opportunity; medium | Startup probes retain separate target-host text-layout algorithms after the common production Layout join | Implemented: common Layout startup corpus replaces duplicate algorithms; paired flash −1,296/RAM unchanged. Connected action regression remains blocked. |
| CBR-004 | Confirmed test-ledger isolation defect; medium | Same-selection test runs clear and write shared reports/caches | Corrected: serialized writers, distinct retained invocation roots and child identities; failure/interruption/overlap fixtures and real gate pass. |
| CBR-005 | Performance hypothesis; investigation only | Packed identity lookups repeatedly scan scope records | Preserved under FW-032; outside cleanup remediation selection |
| CBR-006 | Confirmed process/tooling inconsistency; low | Deferred-track source paths are documented as legal but rejected by authority graph validation | Corrected: safe source-path support preserves strict authority IDs/edges; governance fixtures pass. |
| CBR-007 | Confirmed source-start lifecycle defect; medium | Synchronous terminal revision failure is overwritten by running state | Corrected: callback-safe terminal startup and source quiescence pass real-source/admission tests; Pi connected check remains blocked. |
| CBR-008 | Confirmed report-identity defect; low | Pi artifact report records default host Swift rather than its paired cross-build compiler | Corrected: fresh reports separately identify actual paired artifact compiler/SDK and native check compiler. |

## CBR-001 — Missing staged committed-action capacity preflight

- **Evidence:** `Sources/GiftUIInteraction/InteractionState.swift:51,223,247`;
  [Step 02](02-interfaces-and-mappings.md) and
  [reproduction](evidence/02-capacity-probe.json). Reviewed source baseline above.
- **Contract/consequence:** SPEC-011 Lifecycle requires capacity and commit-storage
  preflight at finish. A two-record candidate with a one-record staged committed
  buffer returns runtime safety-not-proven `.invariantViolation` instead of a
  contained capacity result; this can select a stronger containment path.
- **Counterevidence/confidence:** High confidence in the reproduced reusable-state
  defect. Current standard nRF setup uses equal capacities; no current production
  trigger demonstrated. Existing 17 XCTest/three Swift Testing cases pass but
  their helper uses equal capacities.
- **Smallest correction/risk:** Check staged committed capacity before copying;
  include it in initial limit validation where appropriate. Preserve error
  precedence, committed state, discard behavior, and infallible ready-state commit.
- **Routing/validation:** Lightweight correction under SPEC-011; no architecture
  change proposed. Cover independently undersized candidate, staged committed,
  retained committed, and hit stores, exact capacity/first excess, no partial
  publication, and discard/reuse in affected Static/Dynamic compositions.
- **Owner/disposition:** Interaction owner; recommended remediation, awaiting
  final iteration selection. Keep the correctness issue visible; not deferred
  as a cosmetic cleanup preference.

## CBR-002 — Hierarchy-dependent model projection has manual ordinal maps

- **Evidence:** `Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFModelTextWriter.swift:16,78`;
  `StaticSignalAnalyzerNRFModelModifierWriter.swift:52,77`;
  `scripts/contracts/generate-spec-001-nrf-topology.py:15,60`.
- **Rationale/consequence:** SPEC-001 shared portable hierarchy and SPEC-013 bounded
  storage justify the projection but do not establish that ordinary sources
  should reproduce its ordinals. Coordinated text/style/topology updates increase
  maintenance effort and drift risk.
- **Counterevidence/confidence:** High confidence in coupling; no current mismatch
  established. Differential tests, topology checks, and checked packed records
  protect current behavior. Packed representation itself has a concrete resource
  purpose.
- **Smallest investigation/risk:** Inventory every manual binding and generation
  input; compare stable-role generation with runtime derivation from portable
  declarations. Keep exact text, actions, identity, colors, failures, and bounds.
- **Routing/validation:** Existing ITERATION-002 hierarchy investigation; use an
  Exploration/Spike when undertaking candidate implementation or measurement.
  Module/contract/profile/resource changes require their normal approvals.
  Measure parity, RAM/flash/stack/heap, derivation costs, and reproducibility.
- **Owner/disposition:** Signal Analyzer target-host/generation owners;
  [SPIKE-011](../../spikes/spike-011-clean-topology-generation.md) supports clean
  generation of both table outputs with exact source/semantic parity and zero
  linked size delta. [SPIKE-009](../../spikes/spike-009-nrf-hierarchy-role-bindings.md)
  supports optional named role bindings (+192 flash bytes, unchanged RAM,
  42 exact semantic comparisons). Retain packed runtime hierarchy. SPIKE-010's
  snapshot counting prerequisite does not establish a full replacement;
  [Step 20](20-static-stack-assessment.md) records static stack proof barriers.
  Finding remains open pending production selection/remediation.

## CBR-003 — Duplicate text-layout rules remain in startup validation

- **Evidence:** `Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedTextMeasure.swift:3`;
  `StaticSignalAnalyzerNRFEmbeddedTextPlace.swift:3`;
  `firmware/nrf52840/applications/signal-analyzer-static/src/StaticPreset.swift:300,356,2888`;
  `src/main.c:82`; focused semantic-region tests.
- **Rationale/consequence:** Production uses common LayoutEngine; startup probes
  still maintain separate measurement/placement logic, creating two places to
  update text rules and making probe success weaker evidence of the production
  algorithm than a common-path probe.
- **Counterevidence/confidence:** High confidence in duplicate live algorithms;
  they test packed codecs/startup validity and cannot simply be deleted. No
  incorrect current text output is asserted. [Step 13](13-startup-text-probe-assessment.md) now measures a 1,296-byte flash saving with unchanged RAM in an isolated shared-engine candidate.
- **Smallest correction/risk:** Adapt startup/probe cases to common Layout over
  the packed workspace, preserving separately useful codec negatives. Retire
  duplicated algorithms only after proving their consumers and coverage migrate.
- **Routing/validation:** Candidate lightweight maintenance under SPEC-001/007/013;
  a changed startup contract/resource bound needs upstream review. Test text
  corpus, packed writes, startup failures, firmware build/ABI and measured costs.
- **Owner/disposition:** Target-host/probe owners; recommended candidate pending
  final scope selection and the concrete negative/overflow corpus migration recorded in [Step 13](13-startup-text-probe-assessment.md).

## CBR-004 — Test runner reports are shared across invocations

- **Evidence:** `scripts/test.sh:61-69,96-105` constructs a selection-only report
  directory, removes it, and appends check results there. The
  [MVP closeout](../../../Tests/ContractFixtures/SPEC001/Evidence/milestone-10/iteration-closeout-20261003/README.md#final-local-validation)
  explicitly records two overlapping invocations contaminating shared runner
  metadata/results and using a separate console-derived ledger instead.
- **Contract/consequence:** Reliable evidence needs an unambiguous invocation
  identity. Same-selection reruns erase prior reports; concurrent runs can mix
  results and clear active caches/build scratch directories. This weakens the
  aggregate ledger even when individual contract reports remain immutable.
- **Counterevidence/confidence:** High confidence in shared-directory behavior
  and the documented historical interference. Per-contract immutable report
  publication already provides a useful pattern. No destructive race was run
  during this audit, and no new failing product behavior is inferred.
- **Smallest correction/risk:** Give each runner invocation isolated reports,
  caches, and scratch storage, with an atomic latest pointer, or serialize runs
  and preserve separate historical reports. Preserve exact child report/run IDs.
- **Routing/validation:** Lightweight tooling maintenance. Test distinct same-
  selection invocation paths, interrupted/failed runs, ledger identity, latest
  publication, and aggregation using a cheap runner fixture; run the ordinary
  affected gate once after that isolated check.
- **Owner/disposition:** Repository test tooling; recommended correction pending
  iteration selection. Retention/cleanup policy remains an implementation choice.

## CBR-005 — Repeated packed identity lookups need phase measurements

- **Evidence:** `Sources/SignalAnalyzerTargetHost/StaticSignalAnalyzerNRFEmbeddedRenderSemanticAdapter.swift:17`
  scans scopes for each identity; `StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace.swift:70`
  does the same and is called by staging, measurement, placement, text-line, and
  glyph operations. Current packed hierarchy has 92 scopes.
- **Hypothesis/consequence:** Repeated linear lookups can aggregate substantial
  work, depending on call counts. No measured contribution to the historical
  approximately 21-second presentation cadence is established.
- **Counterevidence/confidence:** Source structure is clear; performance impact
  is unknown. Small bounded tables can be preferable to another retained index
  on nRF. An ordinal and an identity are not automatically interchangeable.
- **Investigation/validation:** Measure per-phase costs and lookup counts first;
  only then compare unchanged scans with bounded alternatives, including RAM,
  flash, stack, heap, malformed identity handling, and exact output parity.
- **Owner/disposition:** Target-host/performance owners; captured in existing
  [FW-032](../../future-work/fw-032-nrf-performance-improvement.md), without
  promoting it or changing cleanup scope. Revisit at the authorized performance
  iteration or a release-blocking target responsiveness issue.

## CBR-006 — Deferred source paths conflict with the validator

- **Evidence:** `docs/engineering/DOCUMENTATION_RULES.md:230` allows an artifact
  ID or repository path in deferred-track `source` metadata. The authority graph
  builder includes `source` among ID-only relationships at
  `scripts/governance/build-authority-graph.rb:30,164` and rejects all paths.
  [Observed validation failure](evidence/03-governance-source-case.json) records
  the attempted reciprocal FW-032 source link and exact rejection.
- **Consequence/confidence:** High confidence in the documented/tooling mismatch.
  Source-backed captures cannot use the documented path form without failing the
  governance gate. Existing ID-backed captures continue to work.
- **Smallest correction/risk:** Align deferred-source validation and graph
  representation with the existing documented path rule, retaining strict ID
  checks for authority relationships and safe existing-file path validation.
  Preserve artifact-ID edges; repository sources do not become authority nodes.
- **Routing/validation:** Lightweight governance-tooling maintenance under the
  existing Documentation Rules; test valid ID/path/mixed sources, missing files,
  unknown IDs, and path resolution without weakening approval gates.
- **Owner/disposition:** Governance tooling; recommended bounded correction.
  For this research, existing Spec source IDs and reciprocal body/References
  links preserve provenance; the transient rejected metadata entry was removed.

## CBR-007 — Terminal callback during source startup is overwritten

- **Evidence:** `Sources/SignalAnalyzerData/DefaultSignalAcquisitionRepository.swift:50,57,152`;
  actual deterministic source's synchronous initial callbacks; [Step 05](05-portable-and-application.md)
  and [unchanged-source reproduction](evidence/05-acquisition-start-probe.json).
- **Contract/consequence:** SPEC-001 terminal revision procedure (679–692,
  SA-AC-043) requires failed state, stopped delivery, no ordinary state callback
  for that failure, and a fresh graph. At max/max-minus-one during startup, one
  terminal callback is followed by ordinary running publication; the real
  deterministic source remains active while later Start is unavailable.
- **Confidence/counterevidence:** High confidence in reproduced Data behavior.
  Existing tests exhaust revision after successful startup. Initial revision
  zero does not trigger this case; full-host failure containment and equivalent
  nRF startup behavior were not demonstrated by this host Data probe.
- **Smallest correction/risk:** Treat source startup as callback-capable; preserve
  any failure/terminal transition and stop a source activated during that call.
  Do not blindly publish running on return. Cover startup throws after callbacks
  and avoid duplicate terminal/state publication or producer activation.
- **Routing/validation:** Maintenance within SPEC-001; Data/lifecycle tests with
  the real deterministic source at max/max-minus-one and a callback-capable source
  failing during Start; successful Start/Stop/restart, Clear, terminal replay,
  failure admission/quiescence; compare corresponding target realizations.
- **Owner/disposition:** Data/source lifecycle owner; recommended correctness
  correction, not deferred as simplification.

## CBR-008 — Pi compiler metadata describes the wrong compiler

- **Evidence:** `scripts/contracts/run-spec-001.sh:80,167` captures default
  `swiftc --version` before the profile build and writes it to the Pi report.
  The fresh Pi report records Apple Swift 6.3.3 while its actual build log
  confirms project-local Swift 6.3.2 and the paired ARMv6 SDK. The
  [hashed comparison](evidence/11-pi-compiler-identity.json) identifies the
  report, artifact and build log.
- **Consequence/confidence:** High confidence in the emitted metadata mismatch;
  it misattributes the cross-built artifact's compiler and weakens reproduction.
  The driver also runs native checks, so both compiler identities are useful
  when separately named.
- **Counterevidence:** `scripts/raspberry-pi/build.sh:93-96` enforces Swift 6.3.2;
  the cross-build/ABI gate passes. No wrong compiler use or artifact ABI defect
  is demonstrated. The nRF report explicitly writes its pinned target compiler.
- **Correction/routing:** Lightweight report-tooling maintenance. Record the
  actual cross-build compiler and SDK; retain a separately named native-check
  compiler where needed. Validate report fields against toolchain/build output
  with differing default and paired compiler versions across all profiles.
- **Owner/disposition:** Contract-driver evidence tooling; recommended bounded
  correction discovered while inspecting fresh gate output.

## Deferred and Follow-up Work

Step 09's [isolated updater check](evidence/09-hierarchy-generator.json) reproduces
both current hierarchy outputs and is idempotent. This is counterevidence to a
stale-generation concern under CBR-002; it does not resolve manual ordinal
coupling or establish clean declaration-derived generation.

[FW-032](../../future-work/fw-032-nrf-performance-improvement.md) now links back
to CBR-005. The capacity correctness finding remains a current selection item;
it is not hidden by this performance deferral.

## Follow-up investigation disposition

[Steps 13–16](17-followup-reconciliation.md) add bounded candidate measurements
and scope detail without altering maintained code or closing findings as fixed.
Five-second retention has paired history/replay and independent left-edge
evidence plus measured three-store costs. Fifteen file-selection guards have
a named candidate and explicit residual policy. Full hierarchy replacement,
physical timing/high-water and connected behavior remain unproven.

[Steps 18–21](21-research-closeout.md) complete the reopened hardware-free queue:
actual-body snapshot traversal, complete clean topology generation, addressed
static resource inspection and reconciled draft scope revision 3. Clean
generation is a supported candidate; full runtime replacement is excluded from
the proposed cleanup commitment. Connected work is explicitly deferred by the
maintainer. All eight findings retain their open/deferred dispositions; no
production defect was fixed by disposable research.

## Production maintenance disposition — 2026-10-05

[Integration evidence](../iteration-002-cleanup/evidence/10-integration/result.md)
updates the current table above. The preceding investigation descriptions and
raw records remain historical recommendations, not current pending selection.
CBR-001/004/006/007/008 corrections are validated in their maintained scope.
CBR-003 production migration and resource result are validated hardware-free;
its connected portion remains incomplete. CBR-002 is deliberately partial:
clean generation is production, while named roles and residual model/ordinal
coupling remain under EXP-001. CBR-005 remains the unmeasured lookup hypothesis
under FW-032. Fifteen selected guards and the compatibility alias are retired;
residual profile/resource/board/instrumentation guards remain under FW-029.

[Connected attempt](../iteration-002-cleanup/evidence/11-connected-attempt/result.md)
records actual failures, device state and authorization blockers. It creates no
new exception and cannot close the full connected corpus in FW-031/FW-033.
Retention approval is a current iteration blocker, not deferred work. Iteration
2 remains active; FINAL-01 and SPEC-001 T11.8 are incomplete.

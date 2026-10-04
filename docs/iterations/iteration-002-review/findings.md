# Findings Register

Source baseline: `6cf31f266987e917458f31f05ed8c390cda9a202`.
Local IDs use `CBR-001`, `CBR-002`, etc.; they are review identifiers, not
lifecycle artifact IDs. Findings are recommendations and evidence only.

No remediation is approved or implemented by this register.

| ID | Classification / priority | Observation | Disposition |
| --- | --- | --- | --- |
| CBR-001 | Confirmed preflight/error-classification defect; medium, correctness shortlist | Staged committed-action capacity is omitted from preflight | Recommended for bounded correction; production reachability remains unproved |
| CBR-002 | Supported simplification opportunity; medium | Manual ordinal/model mappings couple ordinary source to a separately generated hierarchy | Needs investigation under the existing hierarchy candidate |
| CBR-003 | Supported simplification opportunity; medium | Startup probes retain separate target-host text-layout algorithms after the common production Layout join | Candidate for contract-preserving maintenance after probe-coverage review |
| CBR-004 | Confirmed test-ledger isolation defect; medium | Same-selection test runs clear and write shared reports/caches | Recommended tooling correction; historical interference recorded |
| CBR-005 | Performance hypothesis; investigation only | Packed identity lookups repeatedly scan scope records | Preserved under FW-032; outside cleanup remediation selection |
| CBR-006 | Confirmed process/tooling inconsistency; low | Deferred-track source paths are documented as legal but rejected by authority graph validation | Recommended bounded validator alignment |

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
- **Owner/disposition:** Signal Analyzer target-host/generation owners; needs
  investigation, not a commitment to remove all generated code.

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
  incorrect current text output or measured binary-size benefit is asserted.
- **Smallest correction/risk:** Adapt startup/probe cases to common Layout over
  the packed workspace, preserving separately useful codec negatives. Retire
  duplicated algorithms only after proving their consumers and coverage migrate.
- **Routing/validation:** Candidate lightweight maintenance under SPEC-001/007/013;
  a changed startup contract/resource bound needs upstream review. Test text
  corpus, packed writes, startup failures, firmware build/ABI and measured costs.
- **Owner/disposition:** Target-host/probe owners; recommended candidate pending
  final scope selection and coverage assessment.

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

## Deferred and Follow-up Work

[FW-032](../../future-work/fw-032-nrf-performance-improvement.md) now links back
to CBR-005. The capacity correctness finding remains a current selection item;
it is not hidden by this performance deferral.

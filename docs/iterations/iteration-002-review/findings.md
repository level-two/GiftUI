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

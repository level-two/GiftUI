# Step 17 — Follow-up reconciliation and scope readiness

The maintainer requested completion of the remaining investigation steps with
separate commits. Steps 13–16 now record concrete experiments and assessments;
production source, tests, build scripts, package topology and authoritative
ADRs/Specs remain unchanged. Spike code is disposable research.

| Follow-up | Result | Commit | Recommended scope disposition |
| --- | --- | --- | --- |
| [13 — Startup text probe](13-startup-text-probe-assessment.md) | Actual shared-engine startup candidate and native/codec checks; −1,296 flash bytes, unchanged RAM | `0e983967` | Consider bounded maintenance with the specified negative/overflow coverage migration |
| [14 — Five-second retention](14-five-second-retention-impact.md) | 2,410 paired replay/history checks, 7,200 independent left-edge checks; all three stores accounted; −96,000 RAM bytes | `60558ed6` | Consider 5s/404-record contract amendment; retain 30s workload and delivered-event validation |
| [15 — Source conditionals](15-conditional-removal-candidates.md) | 15 explicit whole-file guard candidates pass native/Embedded checks at unchanged linked size; residual policy recorded | `34d3403b` | Select these source-selection changes and empty-shell removal if desired; coordinate all build lists |
| [16 — Hierarchy alternatives](16-hierarchy-feasibility-experiment.md) | Direct-module route hits EmbeddedRestrictions; generated 32-role candidate preserves 42 semantic transcripts at +192 flash / zero RAM | `db526c94` | Retain packed hierarchy; consider explicit named bindings. Full runtime replacement requires another selected bounded candidate and budgets |

## Recommended planning order

1. Confirm the bounded remediation selection in draft ITERATION-002 revision 2.
   Prioritize CBR-007 startup correctness and CBR-001 staged-capacity handling,
   followed by CBR-004/006/008 evidence-tooling defects.
2. Select CBR-003 and the named file-selection cleanup as supported maintenance
   candidates, with their concrete coverage/source-list validation requirements.
3. If selecting five-second retention, approve ADR-003 and affected capture/host
   amendments before implementation. Use the complete owner/fixture impact
   assessment; retained record counts and accepted workload counts differ.
4. Treat generated named bindings as an optional smaller CBR-002 cleanup. Keep
   the packed representation and topology updater unless further research is
   explicitly selected. Do not promise a full runtime replacement from this Spike.
5. After scope selection/approval and applicable contract gates, create the
   implementation tasks and affected-profile validation matrix. Do not copy
   disposable prototypes into production as an implicit next step.

This research round has no unperformed generic owner-review or candidate-impact
step. Full bounded typed view lowering, complete clean offline generation,
whole-stack/target derivation timing and agreed replacement budgets remain
unproven. They are candidate-specific follow-up if scope selects that work,
not established product capabilities or completed acceptance criteria.

Connected Pi/nRF input/display/failure validation and physical cadence/high-water
remain separately deferred under the existing approved exceptions and
FW-027/031/032/033. This request did not authorize flashing, deployment or a
connected campaign. The source review and hardware-free gate cannot close them.

[Findings](findings.md), [coverage](coverage.md), [EXP-001](../../explorations/exp-001-nrf-hierarchy-derivation.md)
and [draft scope revision 2](../iteration-002-cleanup.md) now agree on these
outcomes and limitations. Eight findings remain open for selection/remediation;
no finding is closed as fixed by an isolated prototype. The previous four-profile
72-check gate remains the production baseline; focused tests and constrained
candidate builds provide the new research evidence.

[Final documentation/provenance checks](evidence/17-document-validation.json)
record link/script/JSON checks, governance and preserved maintained inputs.

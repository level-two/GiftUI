# RFC-015 readiness and conditional approval — 2026-10-13

**Verdict: ready for human approval consideration. Conditional human approval
applied after this review.** Strong review used Sol 6.1 High, read-only and
sequentially, against `7cea403c`. No compiler, experiment or production change
was made for this readiness review.

## Review conclusion

RFC-015 now selects a coherent architecture: conditional owned state
conformances; scoped operation parameters with owned-only retained dispatchers;
a common actual-owner session for all bank accesses; equal immutable logical
capacities within exchanged pairs; complete role-descriptor exchange; checked
physical initialization; assigned logical cleanup; and consuming scoped
retirement. No additional architectural choice is required to extract the
decision and prepare its contracts.

The candidate preserves ADR-007/008 dependency and host-composition boundaries,
ADR-035 complete independent keys, ADR-036 stable backing and model-pin duties,
and ADR-038 explicit construction inputs. No supersession of those decisions is
indicated. The source inventory confirms the counter uses operation-only
RuntimeRecordInteractionBridge dispatch, so a retained scoped dispatcher is not
required by the selected design.

SPIKE-075 establishes bounded native state/owned-compatibility/copy/return
feasibility. It does not prove full host composition, all bank dependencies,
common-session mutation, target acceptance, physical lifecycle or resource fit.
Those remain implementation and conformance obligations. B1–B4's old blanket
RFC-approval-blocker classification was stale and conflicted with the RFC's own
distinction between design readiness and production acceptance. Reclassifying
them preserves their obligations; it does not mark their evidence complete.

The fixture-only owned alternative remains credible and is not experimentally
falsified. Scoped access is selected for complete compiler-bounded ownership
through the shared Interaction pipeline, accepting the broader migration cost
and the risk that target stack fit remains unmet. No claim of unique necessity
or sufficient stack reduction is made.

The initial and revision reviews remain immutable historical assessments.
This fresh review resolves their design omissions by checking the subsequently
specified choices, not by retroactively altering their verdicts. No additional
experiment or successor budget is requested.

## Human authority

Eugene instructed:

> if RFC in not anymore blocked, please accept it, produce required docs/amendments and commit everything, so we will be ready to proceed with the P08

The readiness condition is satisfied at the architectural level described above.
RFC-015 therefore changes from draft to approved on 2026-10-13. The request also
authorizes preparation and commitment of the downstream document package.
RFC approval does not itself accept a newly written ADR, approve new Spec text,
close P08 conformance or reset any production validation/repair allowance.
The downstream package will identify the remaining explicit approval points.

## Required downstream work

1. Extract one additive ownership ADR from RFC-015, at proposed status until
   accepted. Prepare exact SPEC-011/013/015 amendments for review against it.
2. Prepare the P08/shared and owner-plan updates, plus the physical inventory/
   binding/cleanup design-note requirements, without authorizing work around a
   missing contract gate.
3. Obtain ADR acceptance and Spec-amendment approval before those contracts are
   used; record a bounded production-validation disposition separately.
4. Require full implementation/conformance evidence for P08 exit. Keep P08/R07/
   T8.1 open and the failed 58,648-byte construction frame against the unchanged
   27,648-byte stack visible. P09–P12 and hardware remain outside this change.

Failure to express the selected contracts during implementation must stop the
affected work for upstream review. No lifetime erasure, duplicated state
machine, new retained scoped dispatcher, compiler change or resource exception
is preauthorized.

# Remaining Specification closeout authorization — 2026-10-03

The maintainer explicitly instructed in this task:

> Please postpone the work of performance improvement to the future iterations. And please treat the remaining specs as done.

At this decision, SPEC-001, SPEC-011, and SPEC-015 were the remaining
implementing Specifications; the ten owner transitions were already approved
separately and SPEC-007/SPEC-008 were already implemented. This record applies
the instruction to those three remaining transitions and completes their plans
with the following approved exception dispositions.

| Scope | Observed result retained | Current disposition / follow-up |
| --- | --- | --- |
| SPEC-001 SA-AC-023 and SA-AC-039; T8.1/T8.2 performance scope | Pi approximately 0.72 frames/s, 1.294–1.522 s costs; nRF approximately 21 s presentation intervals. Cadence fails; sustained 80 Hz admission and complete target costs remain unproved. | Approved exception for this iteration; performance improvement deferred to FW-027 and FW-032. |
| SPEC-001 SA-AC-005 and SA-AC-024; remaining T8.1/T8.2/T8.3 evidence | Complete final connected screen/input/failure/recovery corpus and semantic/action/drawing trace comparison are absent. Reviewed host pixels pass; limited live capture prefix matches; these are narrower evidence. | Approved exception for this iteration; FW-033 preserves the remaining evidence campaign. |
| SPEC-011 T9.3/T9.4 connected gate | Complete physical pointer/touch provenance, disabled overlap, movement/stale cancellation, exact-once dispatch and fault corpus are absent. Calibration is confirmed; Pi controls have prior human signoff. | Approved exception for the connected gate; FW-031/FW-033 preserve follow-up. Hardware-free criterion passes retain their original scope. |
| SPEC-015 assembled connected-target gate | All four hardware-free profile checks pass; connected cadence and complete physical/fault/trace coverage remain unproved or failing as above. | Approved exception for assembled connected coverage; FW-032/FW-033 preserve follow-up. |

The status transitions record the maintainer's closeout decision. No failed
measurement is reclassified as a test pass, no missing observation is invented,
and no numerical or behavioral requirement is amended. Full measured target
conformance remains future work. The approval overrides prior statements that
these gaps prevent the implemented transition.

The final 72-check hardware-free invocation passed. Exact artifact identities,
measurements, scope limits and immutable logs are retained in [the closeout](README.md).
The raw validation archive is unchanged; this approval is a subsequent record.

- [Pi performance](../../../../../../docs/future-work/fw-027-pi-performance-investigation-resumption.md)
- [macOS physical pointer](../../../../../../docs/future-work/fw-031-macos-connected-pointer-validation-resumption.md)
- [nRF performance](../../../../../../docs/future-work/fw-032-nrf-performance-improvement.md)
- [Connected evidence](../../../../../../docs/future-work/fw-033-connected-validation-follow-up.md)

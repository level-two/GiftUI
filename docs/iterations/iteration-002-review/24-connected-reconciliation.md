# Step 24 — Connected reconciliation and device restoration

The bounded hardware-free research and subsequent authorized hardware campaign
are complete. No additional generic review pass is needed before cleanup scope
selection. This closes the investigation queue, not production remediation or
the complete connected acceptance corpus.

| Step | Evidence | Commit |
| --- | --- | --- |
| 22 — Production baseline | Pi 0.717fps / 9,748KiB sampled RSS; nRF 21.2s median publication gap; deterministic nine-record prefix; verified startup extent 19,480 bytes | `709133cc` |
| 23 — Candidate costs | Packed 55.612/55.732ms; roles 54.265/54.431ms; partial counting 6.254/6.269ms; observed extents 3,992/3,984/17,896 bytes; target refusal/reuse passes | `073fb5c8` |
| 24 — Reconciliation | Restoration, source/evidence integrity and current planning/deferred-work disposition | This step |

## Device and source state

The repository J-Link runner restored the original production ELF/HEX after
all three disposable images. Identified serial 683833660 reaches ready idle
revision1, with zero sampled driver counters and CFSR/HFSR, and running DHCSR.
No debugger/J-Link process from the campaign remains attached. Pi reports
`armv6l`, the original matching binary hash and no remaining application process.
No remote service was restarted. Maintained `Sources`, `Tests`, firmware,
`scripts`, `Package.swift` and demo inputs match the initial review snapshot.

[Restoration and validation record](evidence/24-connected-closeout.json) and
[raw restoration archive](evidence/24-restoration-logs.tar.gz) preserve the
final state, exact file hashes and verification results. Earlier Step22 and
SPIKE-012 evidence archives remain immutable. The original 72-check hardware-free
gate remains the production baseline; new candidate firmware ABI/heap/resource,
calibration/result and refusal/reuse checks validate the disposable work.
Formatting, Python/shell syntax, local links and governance were checked.

## Planning consequence

Keep the Step21 priority order: reproduced correctness and evidence tooling
issues first, then supported startup/source-selection cleanup. Clean topology
generation remains the supported CBR-002 tooling candidate. Named roles are an
optional maintenance cleanup; the small target staging difference does not
select them or establish a performance fix. Retain the packed runtime hierarchy.

The actual-body counting prerequisite now has target cost/stack evidence, but
still lacks stable identity, observable attachment, complete semantic publication
and full parity. Its different-work timing is not replacement feasibility.
Neither measured sentinel extents nor the static entry frames provide a
whole-program upper bound. Retain the current stack reservation.

[Draft scope revision4](../iteration-002-cleanup.md) incorporates the new evidence
without selecting production fixes. The eight original findings remain open or
deferred. Feature lifecycle states, authoritative contracts and approved MVP
exceptions remain unchanged. Explicit scope selection/approval and any required
contract amendments precede implementation. No performance optimization is
silently added to cleanup.

## Remaining work and revisit triggers

- **Production remediation:** select findings/candidates and approve cleanup
  scope. Five-second retention still requires ADR-003/Spec amendments; it is
  not authorized by the benchmark results.
- **Timing and sustained acquisition:** FW-027/032 retain the four-fps gap,
  80-event/s/30s requirement, phase-cost and lossless-admission questions. Resume
  remediation when performance work is selected; current staging measurements
  do not isolate the linear-lookup hypothesis or explain complete frame cost.
- **Connected input, pixels and failure/recovery:** FW-033 retains physical touch,
  movement/disabled-overlap/stale cancellation/exact-once dispatch, normal and
  diagnostic pixels/traces, transport failures/recovery and loaded resource
  coverage. Software Start worked; software Stop's outcome was unestablished.
  A controlled connected corpus and physical contact supply the missing evidence.
- **Whole-program stack and full runtime replacement:** future explicit design
  selection must supply unresolved control-flow targets, simultaneous storage,
  complete identity/state/publication parity and agreed budgets. A partial
  counting benchmark cannot close those questions.
- **macOS physical-pointer subset:** FW-031 remains outside this Pi/nRF campaign.

These are concrete delivery/corpus/design gates, not unperformed generic audit
passes or a claim that every acceptance criterion passed.

## References

- [Step22 baseline and excluded attempts](22-connected-baseline.md)
- [Step23 candidate results](23-connected-hierarchy-candidates.md)
- [SPIKE-012](../../spikes/spike-012-connected-hierarchy-costs.md)
- [EXP-001](../../explorations/exp-001-nrf-hierarchy-derivation.md)
- [Coverage](coverage.md) and [findings](findings.md)
- [FW-027](../../future-work/fw-027-pi-performance-investigation-resumption.md)
- [FW-032](../../future-work/fw-032-nrf-performance-improvement.md)
- [FW-033](../../future-work/fw-033-connected-validation-follow-up.md)

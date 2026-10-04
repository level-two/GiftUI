# Step 28 — Focused connected follow-up reconciliation

The concrete nRF software-input and phase/failure investigation tasks are
complete and production firmware is restored. Pi profiler preparation is
complete, but its connected measurement is blocked by lost SSH connectivity.
The broader connected acceptance corpus remains incomplete. This record
supersedes Step 24's current planning disposition without rewriting its history.

| Step | Completed work | Commit |
| --- | --- | --- |
| 25 | Production service-boundary Start/Stop, all windows, disabled Plus, movement cancellation and stale rejection | `cabb826c` |
| 26 | Actual-owner copied nRF stages; Clear/maximum diagnostic; one pixel refusal, teardown and fresh activation | `60d5ba19` |
| 27 | Separate verified ARMv6 Pi phase profiler and bounded resumption tooling; measurement blocked | `3c17f537` |
| 28 | Current disposition, resource/evidence integrity and nRF restoration | This step |

## What the evidence changes

Software Stop is established through a controlled production service boundary;
the earlier mid-frame attempt is still inconclusive. Window changes and selected
cancellation/refusal behavior now have production software-input observations.
Clear has no visible control in the approved contract; its copied experiment
uses the actual repository/admission path. A maximum diagnostic is a model fact,
not a repository-failure simulation.

The copied nRF common stages localize roughly 97% of cycle time to layout and
offer/production. Actual SPI writes account for about 5%, so transport alone is
insufficient to explain the roughly21s frame. Linear lookup counts and narrower
render/layout costs remain hypotheses for selected performance work, not extra
generic audit passes or an authorized optimization. The copied real source loop
delivers two scheduled records20.959s apart, far from compliant lossless sustained
admission. A copied refusal case cleans up, and fresh activation succeeds after
terminal input storage is explicitly reconstructed. No automatic production
recovery is introduced or claimed.

## Device and evidence state

The original nRF ELF/HEX is restored with the repository's explicit J-Link
runner. Serial 683833660 reports ready idle revision 1, zero sampled driver counters,
zero CFSR/HFSR and running DHCSR. No owned debugger remains attached. Pi's original
binary is unchanged; no service was restarted and no Pi profiler execution began.
An isolated research upload may be incomplete because SSH became unavailable.
Its resumption command requires `armv6l` before deployment and verifies the full
remote research hash before executing. Final Pi reachability/process verification
is unavailable; do not turn that absence into a successful remote check.

Maintained source, tests, firmware, toolchain scripts, package and demo match the
initial source baseline. Original validation and earlier connected archives are
unchanged. This round verifies copied firmware ABI/zero heaps/resource limits,
calibration and clock-agreement limits, exact-size snapshots, outcomes, retirements,
Python/shell syntax, documentation links, formatting and governance. It does not
rerun or relabel the immutable 72-check production gate. Details and restoration
logs are in the [validation record](evidence/28-host-followup-validation.json)
and [restoration archive](evidence/28-host-restoration-logs.tar.gz).

## Remaining tasks and the exact next step

1. **Resume the prepared Pi phase measurement** when
   `giftui@giftui-pi.local` or a maintainer-supplied SSH peer is reachable. Device
   authorization persists. No new codebase review or toolchain setup is needed.
2. **Supply physical contacts and complete acceptance evidence** when the
   connected-validation corpus is selected. No physical taps were supplied in
   this run. Physical provenance, exact-once/disabled-overlap, independent full
   pixels/traces, other fault modes and sustained80-event/s coverage stay under
   FW-027/031/032/033. Software cases do not automatically close these exceptions.
3. **Select and approve cleanup scope** before production remediation. Draft
   revision 5 keeps correctness/tooling first, supported simplifications next,
   and packed hierarchy retained. Five-second retention still requires its
   ADR/Spec amendments. No finding was silently implemented or architecture
   changed by the experiments.

SPIKE-013 remains active solely for the prepared Pi measurement. The original
hardware-free investigation queue is complete; further review passes require a
new perspective, changed code or a specifically selected unresolved question.
The eight original findings retain their open/deferred dispositions. Existing
features, contracts, acceptance criteria and approved exceptions remain unchanged.

## References

- [Step 25](25-quiescent-software-input.md), [Step 26](26-connected-nrf-phases-and-failure.md), [Step 27](27-pi-profiler-preparation.md).
- [SPIKE-013](../../spikes/spike-013-connected-host-followup.md), [coverage](coverage.md), [findings](findings.md).
- [Draft scope revision 5](../iteration-002-cleanup.md).
- [FW-027](../../future-work/fw-027-pi-performance-investigation-resumption.md), [FW-031](../../future-work/fw-031-macos-connected-pointer-validation-resumption.md), [FW-032](../../future-work/fw-032-nrf-performance-improvement.md), [FW-033](../../future-work/fw-033-connected-validation-follow-up.md).

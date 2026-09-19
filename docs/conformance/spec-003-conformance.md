---
spec: SPEC-003
feature: giftui-mvp-architecture
title: SPEC-003 Conformance Report
status: complete
reviewers:
  - codex
created: 2026-09-20
updated: 2026-09-20
implementation_plan: ../implementation-plans/spec-003-implementation-plan.md
related_future_work:
  - FW-009
  - FW-012
  - FW-013
related_explorations: []
related_spikes: []
supersedes: null
superseded_by: null
---

# SPEC-003 Conformance Report

> This report records evidence. A complete report does not itself authorize
> the governing Specification's `implemented` transition.

## Review Scope

This review freezes the explicitly reapproved
[SPEC-003](../specs/spec-003-failure-outcomes-and-containment.md) at pre-report
SHA-256 `53c03bbb87cf3115dc0a3c50f0fd109aab5cc55111c724a066b93b4f077a05ed`,
the active [implementation plan](../implementation-plans/spec-003-implementation-plan.md)
at pre-report SHA-256
`5bd597bb3db550f866c57dc4293987de8452c55f10dbfad0a77c92c716a7b52b`,
the bounded-buffer and resource-driver design notes, and implementation
revision `0af72f55948c873c45a5356ade3dd25b32d99927`.

The reviewed environments are Apple Swift 6.3.3 on the reapproved arm64
`Mac15,7` macOS 26.6.2 build 25G83 runner, project-local Swift 6.3.2 ARMv6
and nRF cross-build toolchains, and a separately authorized connected
Raspberry Pi Model B Rev 2 running Raspbian Bookworm and reporting `armv6l`.
No nRF board execution or flash operation is required or claimed by SPEC-003.

## Acceptance-Criterion Results

| Criterion | Result | Evidence | Notes / exception authority |
| --- | --- | --- | --- |
| `FAIL-AC-01` | pass | [harness readiness](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-0/harness-readiness.md), [final owner boundaries](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-4/final-owner-boundaries.md) | Core leaf import, interface, link, and forbidden-import checks pass. |
| `FAIL-AC-02` | pass | [execution correlation](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-4/execution-correlation.md), [final owner boundaries](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-4/final-owner-boundaries.md) | The correlation adapter has only the approved downward edges; Execution and driver fixtures cannot import upward. |
| `FAIL-AC-03` | pass | [static/dynamic semantics](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/static-dynamic-semantics.md) | The exhaustive corpus preserves conservative containment for known, unknown, and richer values. |
| `FAIL-AC-04` | pass | [layout/allocation/RAM](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/layout-allocation-and-ram.md) | All 23 concrete values meet the exact 2-byte equality and 4/8/20/24-byte maxima on every pinned target compiler. |
| `FAIL-AC-05` | pass | [execution correlation](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-4/execution-correlation.md), [Foundation adapter](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-4/foundation-owner-adapter.md) | Identity/origin are preserved and scope/containment are never narrowed or upgraded. |
| `FAIL-AC-06` | pass | [execution correlation](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-4/execution-correlation.md) | Two annotations preserve order; the third is refused without mutation. |
| `FAIL-AC-07` | pass | [correctness path](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-2/correctness-path.md), [static/dynamic semantics](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/static-dynamic-semantics.md) | The complete finite policy domains and forbidden inputs have one exact disposition. |
| `FAIL-AC-08` | pass | [production host containment](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-4/production-host-containment.md) | Invalid input and unlisted results use the exact quiescence sequence and block later cycles. |
| `FAIL-AC-09` | pass | [diagnostic isolation](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-3/diagnostic-isolation.md), [static/dynamic semantics](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/static-dynamic-semantics.md) | Omitted, selected, filtered, saturated, dropped, and failed diagnostics leave correctness values equal. |
| `FAIL-AC-10` | pass | [diagnostic isolation](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-3/diagnostic-isolation.md), [correctness path](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-2/correctness-path.md) | Dropped transitions do not affect explicit health; counters saturate without wrapping or blocking transitions. |
| `FAIL-AC-11` | pass | [correctness path](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-2/correctness-path.md), [static/dynamic semantics](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/static-dynamic-semantics.md) | Quiesced health is terminal while only the applicable non-saturated counter advances. |
| `FAIL-AC-12` | pass | [callback/interrupt isolation](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-3/callback-interrupt-isolation.md) | Both delivery contexts record zero semantic mutations and zero client-action invocations. |
| `FAIL-AC-13` | pass | [diagnostic buffer](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-3/diagnostic-buffer.md), [static/dynamic semantics](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/static-dynamic-semantics.md) | Every selected capacity has deterministic non-overwriting exhaustion behavior. |
| `FAIL-AC-14` | pass | [correctness path](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-2/correctness-path.md), [layout/allocation/RAM](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/layout-allocation-and-ram.md) | Static construction through generic policy dispatch records zero heap allocations. |
| `FAIL-AC-15` | pass | [four-profile compilation](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/four-profile-compilation.md), [static/dynamic semantics](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/static-dynamic-semantics.md) | The complete host-executed portable transcripts are byte-identical; the same corpus cross-builds for ARMv6 and nRF. |
| `FAIL-AC-16` | pass | [four-profile compilation](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/four-profile-compilation.md), [matched resource images](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/resource-images.md) | All exact optimization modes and two-build repeatability checks pass. |
| `FAIL-AC-17` | pass | [layout/allocation/RAM](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/layout-allocation-and-ram.md), [matched resource images](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/resource-images.md), [macOS latency](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-5/macos-latency.md) | Step, capacity, allocation, RAM, code, stack, instruction, repeatability, and reapproved-runner latency limits pass. |
| `FAIL-AC-18` | pass | [Foundation adapter](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-4/foundation-owner-adapter.md), [capability adapter](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-4/capability-owner-adapter.md), [integration audit](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-6/integration-audit.md) | SPEC-002/004 use the exact shared vocabulary with reciprocal links and no competing owner. |
| `FAIL-AC-19` | pass | [connected Raspberry Pi](../../Tests/ContractFixtures/SPEC003/Evidence/milestone-6/connected-raspberry-pi.md) | The verified target reports `armv6l`; same-revision resource rows and connected p99 latency pass with all raw samples retained. |

## Required-Test Results

At revision `e26353bcae9fef15684cc8e19eafc0cfeb9dd37a`, the complete
`scripts/test.sh --profile all-hardware-free` matrix ran all four exact
SPEC-003 profiles under immutable run ID
`e26353bcae9fef15684cc8e19eafc0cfeb9dd37a-8fd4193daca54e30`.
Every engineering, Swift, contract, macOS Dynamic/Static, ARMv6, and nRF check
passed. The aggregate returned nonzero only because one governance-tooling
test still expected the now-completed T5.4 task to be blocked. Revision
`0af72f5` corrected that stale expectation; its focused four-test/23-assertion
suite and `scripts/validate-governance.rb` then passed with zero failures.

The separately authorized connected command passed at revision `c49e8a5`:

```sh
scripts/contracts/run-spec-003-connected-pi.sh \
  --host 192.168.55.44 \
  --user giftui \
  --host-key-alias giftui-pi.local
```

It verified the saved host key, required `armv6l`, regenerated the ARMv6
resource proof, built and atomically deployed the release probe, compared
local/remote SHA-256, executed the raw-sample corpus, restarted no service,
and verified probe removal in the same SSH session.

## Profile, Backend, and Platform Evidence

- **macOS Dynamic and Static:** host execution on the reapproved Mac15,7 / M3
  Pro / macOS 26.6.2 build 25G83 runner with Apple Swift 6.3.3 and `-O` WMO.
- **Raspberry Pi hardware-free:** exact Swift 6.3.2
  `armv6-unknown-linux-gnueabihf` `-O` WMO build, EABI5 hard-float inspection,
  matched ELF/section/call-graph evidence.
- **Raspberry Pi connected:** Raspberry Pi Model B Rev 2, Raspbian Bookworm,
  kernel `6.12.93+rpt-rpi-v6`, connected release-corpus execution reporting
  `armv6l`.
- **nRF52840:** exact Swift 6.3.2 Embedded Swift `-Osize` WMO ELF,
  ARMv7E-M/VFPv4-D16 hard-float and instruction/resource inspection. No
  connected board or flash claim is needed for this Specification.

The connected PiScreen display/input gates owned by SPEC-001, SPEC-011, and
SPEC-015 are not inferred from SPEC-003's connected latency run. The selected
Pi exposed an ADS7846 touchscreen but no framebuffer or connected DRM display.

## Resource and Performance Evidence

| Profile | Writable RAM | Linked code | Worst stack | Latency / instructions |
| --- | ---: | ---: | ---: | ---: |
| macOS dynamic | 1,596 / 2,048 B | 532 / 32,768 B | 64 / 512 B | p99 167 ns / 100 us |
| macOS static | 444 / 512 B | 592 / 24,576 B | 64 / 384 B | p99 125 ns / 100 us |
| Raspberry Pi ARMv6 | -40 / 512 B | 24,388 / 24,576 B | 40 / 384 B | connected p99 5,000 ns / 150 us |
| nRF52840 Embedded | 256 / 320 B | 132 / 16,384 B | 24 / 256 B | 38 / 4,096 instructions |

Every resource row comes from two byte-identical pristine final images and
identical normalized reports. The connected Pi report preserves 1,000
warm-ups and all 10,000 raw measured samples; each macOS profile does the same
on the exact reapproved runner.

## Deviations and Exceptions

No implementation divergence, failed SPEC-003 requirement, or approved
exception was found. The stale governance-tooling expectation was a
non-contract test-fixture defect and is corrected at the reviewed revision.

The absent connected PiScreen display is not a SPEC-003 deviation:
SPEC-003's connected criterion is the ARMv6 resource and latency corpus.
Display and physical-input conformance remains explicitly owned by SPEC-001,
SPEC-011, and SPEC-015 and remains open there.

## Deferred Work Audit

FW-009 (shared diagnostic service), FW-012 (durable cross-build identity), and
FW-013 (finer containment/recovery) remain outside MVP SPEC-003 conformance.
None conceals a required correctness, resource, latency, or integration item.

## Review Conclusion

All nineteen acceptance criteria have passing, reproducible evidence. The
hardware-free and connected-target claims are separated, and no deviation or
exception remains. This report supports requesting explicit human
authorization for SPEC-003's `implemented` transition. It does not perform
that transition; SPEC-003 remains `implementing` until a maintainer explicitly
authorizes it.

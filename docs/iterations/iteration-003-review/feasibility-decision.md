# Iteration 3 bounded feasibility decision

Status: active preparation. Governing scope: [ITERATION-003 revision 5](../iteration-003-dev-ux-improvement.md).
Coordination: [ME-01–09 activity plan](memory-efficiency-plan.md).
This is one derived evidence/decision packet, not architecture or an implementation contract.

## Launch and limits

Eugene requested committing the governing changes, creating a separate branch,
then proceeding with preparation and committing each step on 2026-10-09.
Governing changes: `5591932983499d4414e5e9c5b2da6fce36f23839` on `main`.
Preparation branch: `iteration-003-bounded-preparation`.
Preparation started at **2026-10-09 14:52:08 UTC**.

- Active elapsed-time ceiling: **60 minutes**, including analysis and build/run
  time; waiting for human/device access is separately reported.
- Experimental invocation ceiling: **8** underlying build/run invocations total.
- Correction ceiling: **2** experimental repair attempts total.
- These are executor-selected ceilings, not an extension of SPIKE-067's stopped
  744/768 invocations and 30/30 corrections. No compilation on that same question
  is authorized by this launch. Review of existing evidence is permitted.
- Source/evidence reads, identity hashing, toolchain version/availability checks,
  documentation validation and commits are not experiments; their time still counts.
- Stop at the earliest ceiling or a decision supported by the evidence. Publish
  one terminal disposition; do not automatically create follow-up experiments.

The selected cost boundaries are (1) runtime graph/storage construction and
service lifetimes, (2) layout and frame production, including Pi projection and
nRF raster/transfer, and (3) source-service delay caused by synchronous frames.
Compare at most two remedies per boundary. Other findings must fit this budget,
become explicit blockers, or be captured through the deferred track if optional.

## ME-01 — Baseline and gaps

Completed baseline inventory. [Machine-readable identities](feasibility-evidence/baseline.json)
freeze Git objects, installed compiler/destination hashes and historical report
identities. All ten maintained/authority roots checked match iteration-2 closeout
`2d036748`: Sources, Tests, firmware, scripts, ThirdParty, package files, ADRs,
Specs and architecture. The working copies match those objects.

| Baseline | Evidence / current gap |
| --- | --- |
| Native compiler | Swift 6.3.3, macOS SDK 26.5; keep distinct from paired cross compilers. |
| Pi compiler/SDK | Project-local Swift 6.3.2, ARMv6 hard-float destination; [doctor passes](feasibility-evidence/pi-doctor.log), no probe/build. |
| nRF compiler/SDK | Project-local Swift 6.3.2, Zephyr 4.3.0 at the pinned revision, SDK 0.17.4; [doctor passes](feasibility-evidence/nrf-doctor.log), no probe/build. Python 3.14.6 differs from lock baseline 3.12.13 but passes the supported range; J-Link 9.66 differs from tested 8.96, no device operation. |
| Production images | All four paths recorded by the final integration reports are absent locally. Historical hashes are frozen, not reverified against current binaries or devices. |
| Production resources | Final nRF report records 95,104 linked RAM bytes and 274,144 flash bytes, zero heap and 27,648-byte main stack reservation. This is the five-second-retention image, not the earlier 191,104-byte RAM image. |
| Workload | SPEC-001: 30 continuous seconds, 80 events/s, four-FPS cadence, loss/order/latency/state/pixel requirements. Retention is five seconds / 404 records per nRF store, not the older 30-second storage configuration. |
| Applications/profiles | Analyzer and finite counter; macOS Dynamic/Static, Pi 1 Dynamic and nRF Embedded Static. Counter may use repository composition; it still lacks a reviewed numeric application budget and complete supported-image proof. |
| Architecture/contract authority | Accepted ADRs and implemented owner Specs remain binding. Runtime work affects SPEC-001/006/010/012/013/015, with layout/render/backend costs additionally governed by SPEC-007/008/011/014. PROPOSAL-007 is accepted; RFC-013 remains draft. |
| Experimental evidence | Retrieve only packet 65 and its directly relevant memory/lifetime predecessors from archive `af5e9559`. No resumed compilation, prior result relabeling or assumed supported-composition success. |

The available evidence permits source-level accounting and architectural triage.
It cannot establish fresh target timings, complete stack safety, or final
runtime-derived production feasibility. Missing binaries alone do not justify
rebuilding an exhausted candidate. Timing and ownership evidence will be assessed
next to determine the smallest useful upstream decision.

## ME-02 / ME-03 — Memory, lifetimes and performance

Pending source/evidence assessment. Historical target measurements will retain
their original workload, image and instrumentation limitations.

## ME-04 — Alternatives and terminal decision

Pending. No architecture is selected and no implementation is authorized.

## Usage and validation

ME-01 checkpoint, 14:53:56 UTC: 1m48s active elapsed; 0/8 experimental invocations,
0/2 experimental corrections; no waiting. Both non-probe doctors pass. No hardware
operation, production change, new conformance claim or study restart.

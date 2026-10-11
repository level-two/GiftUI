# P07 final candidate evidence — 2026-10-11

Implementation is ready for independent Strong exit review; this record does not
accept P07 or close SPEC-009 T9.1 / SPEC-013 T11.1. The approved SPEC-009/013
coordinator amendments, accepted ADR-035/036/037 and the explicit
[consuming-owner resumption](consuming-owner-resumption.md) govern this boundary.
I3-04/05 supplies runtime derivation and efficiency scope; closed MVP behavior
remains the regression oracle. P08–P12 have not started.

Implementation through `af796ed8` includes the construction correction reviewed
separately in [construction-c1-correction.md](construction-c1-correction.md), plus
lifecycle steps 1–6 in [progress.md](progress.md). Strong implementation used
Sol 6.1 High for this final recovery/evidence assignment. Independent exit review
is assigned separately. No compiler/contract, capacity or hardware change occurred;
no optional discovery required a new deferred artifact.

## Reproduction and identity

Run each registered SPEC-013 migration route from the repository root with
`--compiler-baseline rfc-014` and the verified P02 core directory below. The core
inputs, GiftUI module/object and macro/compiler executable identities are checked
by the driver before fresh dependent module compilation. Reusing these unchanged
core artifacts is explicit; every P07 dependent module is freshly built.

All four receipts use implementation commit `af796ed8` with the same final driver
label edit (`runtime-cycle-and-audited-storage`). Their dirty bit honestly reflects
the uncommitted driver label and documentation/evidence reconciliation; receipt
input hashes identify the exact source. The label changes no test, failure or
execution behavior. Documentation edits are outside the driver compile inputs.
The [integrity record](final-integrity.json) verifies every source, core
receipt/compiler and generated artifact hash. Exact commands, flags, compiler SHA-256 and output paths are in
each receipt and its `commands.txt`; no build directory is overwritten.

| Route | Command arguments after `scripts/contracts/run-spec-013.sh` | Receipt / result |
| --- | --- | --- |
| macos-static | `--profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/dd5d4849463055f2-hwlll28l/macos-static` | [final-macos-static.json](final-macos-static.json); 3917 native assertions, zero failures, twelve negatives |
| macos-dynamic | `--profile macos-dynamic --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/189dda86d331e15d-wpk82ft7/macos-dynamic` | [final-macos-dynamic.json](final-macos-dynamic.json); 3917 native assertions, zero failures, twelve negatives |
| raspberry-pi-armv6 | `--profile raspberry-pi-armv6 --compiler-baseline rfc-014 --giftui-build .build/raspberry-pi/contracts/spec-006-rfc-014/189dda86d331e15d-w03qxe3s/raspberry-pi-armv6` | [final-raspberry-pi-armv6.json](final-raspberry-pi-armv6.json); cross-compilation, ARMv6 + VFP registers, twelve negatives |
| nrf52840-embedded | `--profile nrf52840-embedded --compiler-baseline rfc-014 --giftui-build .build/nrf52840/contracts/spec-006-rfc-014/189dda86d331e15d-xnmh_sbd/nrf52840-embedded` | [final-nrf52840-embedded.json](final-nrf52840-embedded.json); cross-compilation, ARMv7E-M + VFP registers, twelve negatives |

The two native routes each compare 23 complete actual-profile transcript pairs.
Both routes' [complete logical values](final-logical-transcripts.json) are also
identical to each other. Independent driver checks require every successful
checked dispatch to have exactly one model commit and one synchronous report.
Counts are new-work totals, not claims that every assertion has a unique criterion.

The [actual storage descriptors](final-storage-regions.json) enumerate all 26 audit
fields and retained count/size/stride/alignment partitions, with checked native
totals Static 68,502 and Dynamic 166,239 bytes. Source partitions and cleanup
checks support the exclusion ledger in [progress.md](progress.md) and
[construction-c1-correction.md](construction-c1-correction.md). These are profile
backing measurements, not complete RAM/image/stack or allocator-overhead budgets.

## Evidence mapped to the unchanged package boundary

| Contract / owner duty | Candidate evidence | Remaining acceptance boundary |
| --- | --- | --- |
| RP-RD-001; construction and audited concrete binding | Actual scoped factories, same-owner Model/Schema binding, all 26 fields, physical capacities vs configured limits, 21 configured-limit cases on both actual profiles, eight-axis below/equal/above controls; construction step 6 and final native receipts | P11 full application/host backing, allocator, linked RAM/stack and overlap remain open; this selected finite composition is not the complete analyzer |
| RP-RD-002; actual complete cycle | Both actual storage/profile owners feed the common pipeline and concrete coordinator. Exact stage/failure/cleanup transcripts, early frame acquisition, bank reuse, last-read vs registration retirement, accepted/refused routing, partial mutation, discarded removal, actual pointer seal/cancellation and checked dispatch/report, terminal teardown and malformed Drawing append rollback | P10 complete migrated application regression and P12 owner conformance remain open |
| SPEC-009 T9.1; EX-001/010/012/013 | Scoped admission/opportunity forwarding; eight copy/escape/consuming-return negatives and four Model/Schema/action/mutation mismatch negatives; actual nested opportunity rejection, context/provenance, no replay and teardown; fresh target object ABI checks | T9.1 and complete amended owner acceptance stay open for P10–P12; no full target execution inferred |
| SPEC-009 prior intent and latest-only recovery; RP-009 | Lifecycle step 6 preserves prior intent on prepublication failure and clears stored older intent on newer acceptance. Newer retry count resets to 1, same-revision backpressure preserves count, newer backpressure resets to 0. Superseded events and coalesced wake counts are exact. Existing finite refusal exhaustion and terminal nonretryable refusal remain | No new host policy, retry limit or pacing contract; full application integration remains later work |
| RP-RD-003 | Pinned Swift 6.3.2, LifetimeDependence/Lifetimes, four fresh selected-module builds, 12 required negatives per route; target CPU/VFP ABI verification | Full linked Static zero heap, complete stack/RAM/flash and matched Dynamic allocations/dispatch costs remain unmet P11 obligations |
| RP-RD-004 | Existing selected limits and failure/publication semantics retained; configured-limit failures refuse before streams/commits/mutations | Complete migrated application loaded frame/acquisition/timing and connected evidence remain unmet; no acceptance checkbox changed |

Native recordings do not stand in for target execution. ARMv6 and nRF are
cross-compiled selected objects, with architecture and hard-float verification;
no ELF firmware/executable, complete image zero-heap proof, connected run, deploy,
restart or flash is claimed. The necessary preexisting host/test conformers only
supply the package-only prior-intent observation; full host/firmware migration and
the full `all-hardware-free` repository gate belong to P08–P10.

## Review handoff and repair guard

Final source/driver changes are complete. Review the prior-intent observation's
internal authority rationale in lifecycle step 6, latest-revision transitions,
actual construction/limit enforcement, cleanup exclusivity, source partition
accounting, transcript comparison and target evidence limits. Preserve all
historical failed benches/diagnostics and the prior exhausted 2/2 stop.

The explicitly resumed consecutive-unproductive-repair count remains **0/2**.
This assignment's native recovery validation and final route collection required
no repair. A failed independent review is a new bounded repair assignment within
the same resumed guard, not automatic acceptance or a guard reset. No P07 pass,
SPEC transition or permission to begin P08 is implied by this handoff.

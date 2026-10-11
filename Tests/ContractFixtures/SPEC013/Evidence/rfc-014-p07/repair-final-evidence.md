# P07 repaired final candidate evidence — 2026-10-11

The original [independent exit review](independent-exit-review.md) remains **FAIL**
for its frozen `c1500b86` candidate. R1 and R2 are now repaired in `0741894a` and
`ad671ea6`, with refreshed four-route evidence below. The repaired candidate is
ready for separate Strong rereview; this record does not accept P07 or close
SPEC-009 T9.1 / SPEC-013 T11.1. Approved SPEC-009/013 amendments, accepted
ADR-035/036/037 and the [explicit resumption](consuming-owner-resumption.md)
remain unchanged. ITERATION-003 I3-04/05 governs the runtime derivation/efficiency
scope; closed MVP semantics remain the regression oracle. P08–P12 have not started.

Sequential Strong implementation used Sol 6.1 High. The [progress record](progress.md)
preserves construction and lifecycle steps, the original review, both bounded
repairs and their native receipts. No contract/compiler, limit/capacity or hardware
change occurred. No optional discovery required a new deferred artifact.

## Reproduction and identity

Run each registered SPEC-013 migration route from the repository root with
`--compiler-baseline rfc-014` and the verified P02 core directory below. The core
inputs, GiftUI module/object and macro/compiler executable identities are checked
by the driver before fresh dependent module compilation. Reusing these unchanged
core artifacts is explicit; every P07 dependent module is freshly built.

All four receipts identify the same clean implementation commit `ad671ea6`.
No source or driver changed during collection. The [integrity record](repair-final-integrity.json)
verifies every source, core receipt, compiler and generated artifact hash, the
identical driver hash on all four routes, and native transcript/storage equality.
Exact commands, flags, compiler SHA-256 and output paths are retained in each
receipt and its `commands.txt`; no build directory is overwritten. Documentation
reconciliation followed collection and is outside driver compile inputs.

| Route | Command arguments after `scripts/contracts/run-spec-013.sh` | Receipt / result |
| --- | --- | --- |
| macos-static | `--profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/dd5d4849463055f2-hwlll28l/macos-static` | [repair-final-macos-static.json](repair-final-macos-static.json); 5904 native assertions, zero failures, twelve negatives |
| macos-dynamic | `--profile macos-dynamic --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/189dda86d331e15d-wpk82ft7/macos-dynamic` | [repair-final-macos-dynamic.json](repair-final-macos-dynamic.json); 5904 native assertions, zero failures, twelve negatives |
| raspberry-pi-armv6 | `--profile raspberry-pi-armv6 --compiler-baseline rfc-014 --giftui-build .build/raspberry-pi/contracts/spec-006-rfc-014/189dda86d331e15d-w03qxe3s/raspberry-pi-armv6` | [repair-final-raspberry-pi-armv6.json](repair-final-raspberry-pi-armv6.json); cross-compilation, ARMv6 + VFP registers, twelve negatives |
| nrf52840-embedded | `--profile nrf52840-embedded --compiler-baseline rfc-014 --giftui-build .build/nrf52840/contracts/spec-006-rfc-014/189dda86d331e15d-xnmh_sbd/nrf52840-embedded` | [repair-final-nrf52840-embedded.json](repair-final-nrf52840-embedded.json); cross-compilation, ARMv7E-M + VFP registers, twelve negatives |

The two native routes each compare 26 complete actual-profile transcript pairs.
Both routes' [complete logical values](repair-final-logical-transcripts.json) are also
identical to each other. Independent driver checks require every successful
checked dispatch to have exactly one model commit and one synchronous report.
Counts are new-work totals, not claims that every assertion has a unique criterion.

The [actual storage descriptors](repair-final-storage-regions.json) enumerate all 26 audit
fields and retained count/size/stride/alignment partitions, with checked native
totals Static 68,503 and Dynamic 166,240 bytes. Source partitions and cleanup
checks support the exclusion ledger in [progress.md](progress.md) and
[construction-c1-correction.md](construction-c1-correction.md). The one-byte increase in each profile accounts for the actual cleanup-completion
state introduced by R2. These are profile
backing measurements, not complete RAM/image/stack or allocator-overhead budgets.

## Evidence mapped to the unchanged package boundary

| Contract / owner duty | Candidate evidence | Remaining acceptance boundary |
| --- | --- | --- |
| RP-RD-001; construction and audited concrete binding | Actual scoped factories, same-owner Model/Schema binding, all 26 fields, physical capacities vs configured limits, 21 configured-limit cases on both actual profiles, eight-axis below/equal/above controls; construction step 6 and final native receipts | P11 full application/host backing, allocator, linked RAM/stack and overlap remain open; this selected finite composition is not the complete analyzer |
| RP-RD-002; actual complete cycle | Both actual storage/profile owners feed the common pipeline and concrete coordinator. Exact stage/failure/cleanup transcripts, early frame acquisition, bank reuse, last-read vs registration retirement, accepted/refused routing, partial mutation, discarded removal, actual pointer seal/cancellation and checked dispatch/report, terminal teardown and malformed Drawing append rollback | P10 complete migrated application regression and P12 owner conformance remain open |
| SPEC-009 T9.1; EX-001/010/012/013 | Scoped admission/opportunity forwarding; eight copy/escape/consuming-return negatives and four Model/Schema/action/mutation mismatch negatives; actual nested opportunity rejection, context/provenance, no replay and teardown; fresh target object ABI checks | T9.1 and complete amended owner acceptance stay open for P10–P12; no full target execution inferred |
| SPEC-009 prior intent and latest-only recovery; RP-009 | Lifecycle step 6 preserves prior intent on prepublication failure and clears stored older intent on newer acceptance. Newer retry count resets to 1, same-revision backpressure preserves count, newer backpressure resets to 0. Superseded events and coalesced wake counts are exact. Existing finite refusal exhaustion and terminal nonretryable refusal remain | No new host policy, retry limit or pacing contract; full application integration remains later work |
| P07-R1; SPEC-009 exhaustive failure outcome table | Exact frame/intent/preservation/wake/commit assertions distinguish preallocation candidate-ID exhaustion, postallocation presentation-ID exhaustion, ordinary offer failure, required-facility loss and nonretryable refusal. Stored older recovery clears after ordinary newer publication failure; prior routing remains and mutation is not replayed | Repaired in `0741894a`; independent rereview required |
| P07-R2; SPEC-013 idle and terminal quiescence | Actual healthy live capture/committed routing and retained recovery are released before idle return; repeated and terminal stops tear down exactly once. Real scoped derivation retains active backing until mandatory finalization; quiescence completion reflects actual cleanup | Repaired in `ad671ea6`; independent rereview must assess the minimal internal hook, cleanup ordering and completion guard |
| RP-RD-003 | Pinned Swift 6.3.2, LifetimeDependence/Lifetimes, four fresh selected-module builds, 12 required negatives per route; target CPU/VFP ABI verification | Full linked Static zero heap, complete stack/RAM/flash and matched Dynamic allocations/dispatch costs remain unmet P11 obligations |
| RP-RD-004 | Existing selected limits and failure/publication semantics retained; configured-limit failures refuse before streams/commits/mutations | Complete migrated application loaded frame/acquisition/timing and connected evidence remain unmet; no acceptance checkbox changed |

Native recordings do not stand in for target execution. ARMv6 and nRF are
cross-compiled selected objects, with architecture and hard-float verification;
no ELF firmware/executable, complete image zero-heap proof, connected run, deploy,
restart or flash is claimed. The necessary preexisting host/test conformers supply package-only observations of existing prior intent and candidate state; full host/firmware migration and
the full `all-hardware-free` repository gate belong to P08–P10.

## Review handoff and repair guard

The same independent reviewer should recheck R1 exact disposition and stored
recovery consistency, and R2 actual idle cleanup before ownership extraction,
terminal/repeated idempotence, active/deferred cleanup ordering and the internal
opportunity hook. Both package-only read-only observations reflect existing owner
state. The minimal cleanup hook adds no authored common operational signature,
policy or scope. The concrete coordinator requires opportunity cleanup completion
as well as stopped binding admission before reporting quiescence or extracting it.

The original FAIL report, its frozen final receipts and all historical failed
benches/diagnostics remain intact. The original [final candidate record](final-evidence.md)
is historical; this repaired record controls the new candidate. The resumed
consecutive-unproductive-repair count remains **0/2**, with the historical exhausted
**2/2** stop preserved. One R2 test setup compile error had a known typed-throws
scope cause and was corrected productively; both repairs and final collection
passed their subsequent gates. A repair is not a self-issued P07 pass. P08,
Specification transitions and complete P10–P12/resource/image/timing/hardware
acceptance remain outside this handoff.

# Independent frozen-firmware complete-bound review — 2026-10-16

**PASS after proof-decoder correction: proceed to the authorized counter-only
resource reconciliation and normal guarded build.** Main 106,496 / ISR 8,192
payload reservations conservatively cover this frozen image's source-constrained
95,469 / 6,672 bounds. Projected linked RAM charge 255,612 and extent 255,616 fit
physical 262,144. This is an upper-bound review, not a measured peak, acceptance of
a future ELF, source optimization allowance or P08 completion. The maintainer
already approved revising stack and total RAM within physical SRAM and delegated
numerical selection; no further numerical approval is requested here.

Reviewed commit `686800bc`, its [result](p08-current-firmware-complete-bound-result.md),
[immutable original manifest](linked-firmware-complete-bound/manifest.json) and
archive SHA `44aff7957b6be3fdef318520c2531b0c63342a113472ffa0ff9815df18363e94`
(2,390,672 bytes). All 213 archived member hashes and 195 current/snapshot source
hashes match. ELF SHA is
`e649c5d26a676140b473e8fa1de5b075a479d8282a7f6d69e0034fb215884c38`.
The [independent supplement](linked-firmware-complete-bound-review/manifest.json)
contains the exact decoder patch, executable replay and corrected outputs; the
original archive was not rewritten.

## Finding and correction

The original local-SP decoder did not fully model pre/post-index writeback or
non-SP load/store-multiple register effects. Stale register facts could therefore
understate retained SP or constrain an indirect target incorrectly. The supplement
models LDR/STR and LDRD/STRD base updates, invalidates loaded LDM registers, advances
LDM/STM bases, and invalidates overlapping tracked stack values on STM. All
reachable writeback forms were checked: 1,752 sites, including 418 non-SP forms;
none loads its writeback base in an LDM register list. Unknown loaded values are
invalidated rather than retained as code-pointer facts.

Actual correction: both contexts of `__aeabi_uldivmod` at `0x130` now charge the
16 bytes retained by pre-indexed STRD at `0x14c` to the call at `0x150` (previously
zero). Their local maxima change 0→16. No target family or reachability changes;
the maximum main, startup and handler bounds remain unchanged. Thus the finding
is repaired in evidence, not waived. The corrected replay closes 1,788 contexts /
1,469 functions with zero unresolved calls and zero reachable unknown local SP.

## Soundness checks

The finite target families were checked against their original callbacks, typed
loans, closure literals, immutable witnesses, driver API/init tables and generated
ISR table. Manual families conservatively overlap; they do not choose the smaller
of possible targets. Both SPI1 and SPIM3 paths remain included. GPIO user lists,
kernel timeouts, onoff monitor/notification callbacks and error-cache destruction
are excluded only through their separate source/lifetime premises, not because
the decoder failed to resolve them. The sole linked onoff client is spinwait;
XTAL configuration excludes synth/calibration requests. Its process-event flag
permits at most two active calls and defers further work.

Fourteen original simultaneous loans bound lending recursion; no nested second
storage owner is admitted by the frozen source. Semantic child depth 24 plus all
four authored screen modifier applications bound the semantic/layout/record
cycles. Child loops finish one child before the next. The same-identity helper
catalog is acyclic; specialized helper boundaries can defer the debit to the next
edge, but each charged edge on a feasible path consumes a child/modifier descent.
The conservative shared rank 28 remains sufficient. Corpus payload/state changes,
reuse, current/stale/refusal/failure and cleanup paths do not introduce arbitrary
record graphs or additional callbacks. This premise is specific to the frozen
counter, including its finite authored screen and validation checks.

Actual-site SP uses the lowest merged SP endpoint, includes outgoing argument
space and dynamic alignment, follows tail restores and models outlined helpers
in caller state. Startup frames do not enclose main after the PSP reset;
`bg_thread_main` retains eight bytes. The one manual UART epilogue is checked
against its saved-MSP restoration and retains alignment seven plus push eight.
The corrected division helper is included even though it does not set the maximum.

Reset/startup and handler roots were reviewed separately. PSP main software
95,349 + caller eight + first exception allowance 112 = 95,469. Temporary startup
storage needs 312. Three NVIC priority bits permit eight configurable ranks;
HardFault and NMI add two. Taking the larger 524-byte fault-wrapper software path
at every level, plus 112 basic/lazy-FP/alignment bytes at every level and startup,
gives 312 + 10 × 636 = 6,672. This deliberately overcounts rather than relying on
actual driver-priority restrictions. Arm's [exception stack guidance](https://developer.arm.com/community/arm-community-blogs/b/architectures-and-processors-blog/posts/how-much-stack-memory-do-i-need-for-my-arm-cortex--m-applications)
supports the basic/FP frames, alignment, separate stack banks and fixed-priority
exception levels. Fault lockup and fatal trap termination do not create unbounded
resuming software recursion. Arbitrary SRAM corruption or changed call pointers
are outside the valid-source proof.

Rooted allocation was checked beyond symbol absence: `posix_memalign` returns
ENOMEM without writing its output; `swift_allocObject` initializes that output
nil and reaches UDF before returning. Boxed-error allocation also terminates.
The rooted hidden error-destroy context is initially nil and cleared before its
sole release; later metadata writes do not repopulate that context. Consequently
no hidden destructor continuation or successful heap allocation is dropped. A
fatal boxed-error path is not credited as a successful typed refusal.

RAM arithmetic removes only old main 27,648 and ISR 2,048 from PT_LOAD 170,620:
other RAM is 140,924, retaining both 64-byte guards, all four donors, metadata and
C globals. Adding 106,496 and 8,192 gives 255,612 (extent 255,616), leaving
6,532 charge / 6,528 address bytes. The reservations exceed the proven main/ISR
bounds by 11,027 / 1,520. Flash, ABI and layout passes remain separate claims.

## Required final-image requalification

1. Reconcile only the counter's approved stack/physical-RAM authority and extra
   Kconfig/resource check. Existing analyzer limits and closed source-correction
   allowances remain unchanged. Build through the normal guarded route and
   retain the complete current collection, doctor/build receipts and exclusions.
2. Freeze the new ELF, map, config, toolchain, all analysis/source inputs and their
   hashes in a new immutable packet. Recheck actual PT_LOAD charge/extent, guards,
   ABI, flash, disabled arenas, donor layout and rooted no-heap paths.
3. Create an explicit old→new address map using symbols, aliases, body/site
   disassembly and source identity. Audit every address-specific premise: manual
   target families, phase seeds, pruned sites, nonreturn allocators, nil-cache
   writes, rank/same-helper edges, loan entries, reset/switch/handler roots,
   UART epilogue, device/ISR tables and all six delay-thunk bytes. Absolute data
   addresses, decimal site strings and instruction assertions also require
   rebasing; a uniform offset or hash replacement is insufficient. Regenerate
   names and executable premise assertions from that audited mapping. Changed
   bodies or families require fresh proof, not forced matching.
4. Run the corrected executable analysis against the newly hash-frozen ELF;
   require complete reachable writeback coverage, no unresolved edges/local SP,
   freshly justified recursion/exception/allocator premises and recomputed
   main/ISR/total RAM within the selected reservations. Archive its executable
   reproducer, mapping, outputs and source checks; independently review before
   accepting the new image. The supplied `reproduce-review.py` intentionally
   rejects changed ELF/source hashes and cannot certify a new link automatically.

P08/R07/T8.1, full SO/conformance, the current four-route matrix and independent
P08 exit review remain open. Later P09–P12/I4-07 and connected/timing obligations
retain their existing allocation. This bounded review ran read-only proof
analysis and documentation checks; no source/build/test/hardware campaign or
limit change occurred. No new deferred design mechanism was introduced.

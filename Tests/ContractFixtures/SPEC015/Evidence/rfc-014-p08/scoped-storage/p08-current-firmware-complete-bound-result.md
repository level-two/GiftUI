# P08 frozen firmware conservative resource proposal — 2026-10-16

**Propose counter-only main 106,496 bytes (104 KiB), ISR 8,192 (8 KiB),
and total RAM ceiling 262,144 (physical 256 KiB), subject to independent proof
review, authority reconciliation and final normal guarded image verification.**
The maintainer explicitly authorizes larger main and total RAM within physical
SRAM. This analysis changes no source, limit, build, corpus or repair allowance.
P08 remains open. The normal analyzer retains its existing configuration/budget.

The [packet manifest](linked-firmware-complete-bound/manifest.json) pins the
[complete analysis archive](linked-firmware-complete-bound/complete-bound-proof.tar.xz).
It extends the same final ELF `e649c5d26a676140b473e8fa1de5b075a479d8282a7f6d69e0034fb215884c38`,
not the differently compiled contract object. The
[earlier frozen image packet](linked-firmware-current/manifest.json) pins its
compiler, inputs, map/config, complete nRF 227/227 collection and explicit reused
receipt qualifications. The [live rejection and callback-site erratum](p08-current-firmware-live-ram-independent-review.md)
remain valid against the former 196,608 budget; that old rejection is no longer
an instruction to stop analysis at 192 KiB.

| Conservative bound / proposal | Bytes |
| --- | ---: |
| Main-root software, all finite corpus phases | 95,349 |
| Persistent bg_thread_main caller | 8 |
| First exception basic + lazy FP + conservative alignment on main PSP | 112 |
| **Main PSP bound** | **95,469** |
| **Proposed main payload / margin** | **106,496 / 11,027** |
| Pre-switch startup on temporary interrupt storage | 312 |
| Largest IRQ-wrapper software path | 444 |
| Largest exception-wrapper software path, used uniformly | 524 |
| ISR bound: startup + ten × (524 + 112) | **6,672** |
| **Proposed ISR payload / margin** | **8,192 / 1,520** |
| Retained linked RAM, excluding both old replaceable payloads | 140,924 |
| **Projected RAM charge / physical margin** | **255,612 / 6,532** |
| Projected address extent / physical address margin | 255,616 / 6,528 |

These are conservative source-constrained upper bounds, not measured peaks or
minimum reservations. The graph deliberately admits mutually exclusive branches
and finite callback supersets. Its remaining source premises are explicit in
`PROOF.md`, not hidden as zero-cost unresolved edges. Independent review must
validate them before accepting this bound.

The read-only reproducer checks the exact ELF SHA, regenerates disassembly and
all function/CFG/context/SCC calculations, and asserts no unresolved immediate or
indirect edge and no reachable unknown local SP. The packet contains the complete
graph, target catalog, rank edges, selected source snapshots/hashes, generated ISR
table/config, output paths and nil-cache audit. Run `python3 reproduce.py` after
extracting on this pinned repository host; it does not build or run firmware.

The principal recursion premises are fourteen original simultaneous bank loans;
semantic child-depth limit 24 plus the entire screen's four authored modifier
applications; an explicit acyclic same-identity helper-edge catalog; and Zephyr's
two-active-call onoff deferral rule. All host payloads, capacities, callbacks,
current/stale/refusal/failure/cleanup paths and exact observations remain included.
The sole manual local-SP case is the asserted UART saved-MSP epilogue (15 bytes).

Reset uses interrupt storage temporarily on PSP; switching to main resets PSP,
so old startup frames do not enclose the main route. Main execution uses PSP and
handler execution MSP. The ISR bound conservatively includes eight configurable
priority levels (three NVIC priority bits), two fixed HardFault/NMI levels,
lazy FPU/basic/alignment space for every level, and startup. It uses the larger
fault-handler path at every level, including configurable faults. This avoids
relying on a narrower actual driver-priority nesting claim.

Source-excluded callback sites are separately audited: GPIO user callback lists
stay empty; no kernel timeout producer is linked; the sole onoff request client
uses spinwait and installs no notification callback; no onoff monitor is
registered. Both SPI1 and SPIM3 generated driver/init/ISR paths are included.

Rooted allocation is qualified beyond the existing symbol/config guard:
`posix_memalign` always returns ENOMEM without writing its output, and
`swift_allocObject` initializes that output nil and traps before returning.
No heap allocation succeeds. The sole release's hidden error-destroy cache
context is initially nil and cleared before release; its indirect destructor and
the post-allocation error-copy continuation are unreachable. Fatal boxed-error
paths are terminal; they are not claimed to satisfy an expected typed refusal.
Corpus applicability and normal no-heap checks remain required.

The retained-RAM calculation removes only main 27,648 and ISR 2,048 from actual
linked 170,620, retaining both 64-byte guards, four 34,720 donors (138,880),
metadata within its donor, C globals and every other section. Payload changes are
multiples of 64; the existing four-byte segment gap explains charge versus extent.
Final linking must still verify actual placement/alignment, ABI, flash, disabled
arenas, rooted allocation and source/receipt freshness. No fit is inferred across
a recompilation without that verification.

Next: independently review this proof; record the narrowly authorized counter-only
resource exception in authority; apply its extra Kconfig and RAM check; run the
normal complete-collection/guarded-image route and requalify the linked result.
Then reconcile the full four-route/SO matrix and obtain independent P08 exit
review. P08/R07/T8.1 remain open; later P09–P12/I4-07 and connected/timing gates
retain the dispositions in the [completion assessment](../../../../../../docs/implementation-designs/spec-015-p08-completion-resource-assessment.md).

# P08 rebuilt counter firmware resource result — 2026-10-16

**Current nRF counter resource PASS; independent proof review next.**
The normal pristine build uses the accepted counter-only main/ISR payloads
106,496 / 8,192 and physical RAM ceiling 262,144 under
[ADR-040](../../../../../../docs/adrs/adr-040-counter-physical-sram-budget.md).
The fresh complete conservative proof covers this actual new ELF, not merely the
prior frozen image or contract object. P08 overall remains open for its remaining
four-route/SO matrix and independent exit review.

The [manifest](linked-firmware-final-fit/manifest.json) pins the immutable
[resource packet](linked-firmware-final-fit/firmware-resource-proof.tar.xz).
ELF SHA256 is
`0e54fe25ce637f5dd116b1094f64d7a46829a43351465abae265d4ebe61f02f5`.
It was built at `f5705c00`, after independent authority/configuration review;
analysis reads the 755-file hash-verified preserved snapshot, avoiding the shared
normal-analyzer build directory. Actual build and doctor wrappers, snapshot
manifest, ELF/map/config/reports, all 341 compile commands, 339 distinct compiler
source files, 291 proof-source hashes/snapshots and executable corrected proof
are archived. No additional build, application execution or hardware occurred.

| Actual current image | Bytes |
| --- | ---: |
| Complete main bound / reserved payload / margin | **95,469 / 106,496 / 11,027** |
| Complete ISR bound / reserved payload / margin | **6,672 / 8,192 / 1,520** |
| Linked RAM charge / physical ceiling / margin | **255,612 / 262,144 / 6,532** |
| RAM address extent / physical address margin | **255,616 / 6,528** |
| Flash / limit | **403,400 / 1,048,576** |
| Guarded main symbol / guarded ISR symbol | 106,560 / 8,256 |
| Four backing donors; metadata within donor | 138,880; 16,584 |

The two stack symbols retain 64-byte guards, meet without overlap, and end at
`0x2003e680`, within physical `[0x20000000,0x20040000)`. Other retained RAM after
removing both payloads is 140,924. The four-byte RAM LOAD gap explains charge
versus extent. Actual ARMv7E-M hard-float, 160 strict layout roots, entry/symbol,
flash and zero-arena/allocator-symbol guards pass. The complete counter collection
remains the same 227/227 successful complete receipt `yq7m79g3`; strict handoff
hashes validate without rerunning it. Inherited runtime/host `compiled=false` and
`original_manifest_current=false` qualifications remain explicit.

## Fresh address and proof qualification

All 2,600 executable ranges, aliases, sizes, addresses and freshly demangled names
map identically to the committed **e649** image. The full allocated-byte comparison
permits exactly nine changed aligned words: reset ISR-size instructions and
main/ISR/guard/MPU pointer constants. The only canonical instruction changes are
reset's two `2112 → 8256` MOVs. Every other initialized allocated byte is identical;
only the two stack objects change RAM address/size. All 227 Swift source hashes,
24 owners/imports, compiler/macro identities and 341 compile commands are identical;
Kconfig changes only main and ISR sizes. This is audited identity rebasing, not a
uniform offset or replacement of an ELF hash.

The executable audit checks every address/site/phase/root/rank/loan premise,
including decimal and composite sites, all manual callback families, init/device/
ISR tables, immutable witnesses, delay-code bytes, UART epilogue, nonreturning
allocators and nil-cache writes. It uses the independently corrected decoder from
[the prior proof review](p08-current-firmware-complete-bound-independent-review.md).
The fresh replay closes **1,788 contexts / 1,469 functions**, with zero unresolved
calls or reachable unknown SP; every edge, retained call-site SP, local maximum
and source-pruned site matches the corrected old graph. All 1,752 writeback sites
are explicitly inventoried and unchanged. A narrow classification erratum counts
**403 non-SP memory bases**, rather than the old review's 418 label; it changes no
instruction, decoder behavior, frame or aggregate bound. Old packets stay immutable.

The finite source constraints remain fourteen original simultaneous loans,
semantic depth 24 plus four authored modifiers, acyclic same-identity helpers and
two-active onoff deferral. All feasible cold/live/current/stale/refusal/injected
failure/cleanup paths retain their original capacities and observations. Main
95,349 + persistent caller 8 + first exception/FPU/alignment 112 = 95,469. Startup
312 + ten conservative handler levels × (software 524 + frame 112) = 6,672.
Reset/PSP/MSP switching and early main-stack startup are separately accounted for.
No observed high-water or isolated prologue substitutes for this upper bound.

Rooted heap proof goes beyond symbols: `posix_memalign` still returns ENOMEM
without writing output; `swift_allocObject` initializes nil and traps before
return. The hidden error-destroy context remains initially nil and cleared before
its sole release; its destructor continuation stays unreachable. No successful
heap bytes are omitted. Fatal boxed-error paths remain terminal, not successful
typed refusals. Empty GPIO/timeout/onoff callback exclusions retain their unchanged
source/lifetime premises. The archived `REQUALIFICATION.md` and executable audit
make those dependencies explicit.

Run `python3 reproduce.py` after extracting the packet on the pinned repository
host. It verifies member/tool/source hashes, regenerates disassembly, names,
context/SCC bounds and address/writeback/RAM checks, and performs no compilation
or firmware execution. The full replay and member-hash verification pass.

The build's four external working-tree edits (two analyzer Swift files, post-counter-return
CMake edits and empty-array shell expansion) are preserved as provenance and were
not authored or committed as source by this step; known pycache is untouched.
The normal analyzer ELF is not this result. Next is independent current-image
proof review, then the remaining P08 matrix/SO and exit reconciliation. Later
P09–P12/I4-07 and connected/timing obligations retain their existing allocation.

An additional external `scripts/raspberry-pi/build.sh` delta appeared at finalization;
it is preserved and excluded from this commit and counter evidence.

# Independent rebuilt-counter resource acceptance — 2026-10-16

**PASS: actual ELF `0e54fe25` fits the accepted counter-only reservations and
physical SRAM.** Reviewed `a018582c` and the
[result](p08-current-firmware-final-fit-result.md). Main **95,469 ≤106,496**,
ISR **6,672 ≤8,192**, RAM charge **255,612 ≤262,144**, address extent **255,616**
and end `0x2003e680 <0x20040000`; flash **403,400 ≤1,048,576**. This accepts this
image's resource proof under ADR-040, not P08 exit, target execution or full SO.

The [original manifest](linked-firmware-final-fit/manifest.json) and immutable
archive match SHA `0259a55f8dac3c4f4d704a90a72a9dd0ccd12d9aebfa26e2e2d5a599cbae2b36`,
3,828,340 bytes. There are **689 hashed members plus `archive-files.json`**,
690 physical archive files. Independent extraction and the complete executable
`python3 reproduce.py` replay pass; all 291 current proof-source hashes, 339
archived compiler inputs, tool/member hashes and actual ELF SHA
`0e54fe25ce637f5dd116b1094f64d7a46829a43351465abae265d4ebe61f02f5`
validate. The [independent validation receipt](linked-firmware-final-fit-review/validation.json)
and [replay output](linked-firmware-final-fit-review/reproduce.log) preserve the result.
No compiler/build/runtime/hardware operation ran in this review.

The new address proof establishes identity for every one of 2,600 executable
ranges, sizes, aliases and regenerated names, including uncovered `$t` code.
Every initialized allocated-byte difference is restricted to exactly nine aligned
words: initial/reset stack tops, the two reset ISR-size MOVs, main/ISR/guard/MPU
pointers. Only the two stack objects change address/size; only main/ISR Kconfig
sizes change. All other code/data bytes, 227 Swift source hashes, 24 owners/imports,
compiler/macro identities and 341 compile commands are identical. Thus the old
source premises transfer through proved identity, not an assumed uniform offset.

The audit freshly checks manual target families, code/decimal/composite call
sites, phase/root/rank/loan entries, init/device/ISR tables, immutable witnesses,
all six delay-thunk bytes, UART epilogue, allocator trap and initially nil mutable
cache slots. Every corrected old/new graph edge, retained call-site SP, local
maximum and source-pruned site agrees. Fresh closure is 1,788 contexts / 1,469
functions, zero unresolved calls or unknown local SP. The decoder is the reviewed
writeback-corrected implementation with only its ELF input path changed. All
1,752 reachable writeback sites are inventoried; the more precise memory-base
classification is **403 non-SP**, correcting the old review's 418 label with zero
instruction, SP, target or aggregate effect. The two division contexts retain
16 bytes at their call as required.

The fourteen original loans, finite child/modifier rank 24+4, acyclic same-helper
catalog, two-active onoff deferral and empty callback/cache exclusions retain
their reviewed source constraints. Refusal/failure/cleanup paths remain covered.
The unchanged allocator returns ENOMEM and traps before successful allocation;
nil-cache clearing excludes only its unreachable destructor. Terminal boxed-error
paths are not credited as typed-refusal successes. Reset changes select the new
ISR top; main PSP resets to its enlarged payload. Early startup/fatal nesting,
PSP/MSP separation and conservative basic/lazy-FP/alignment accounting remain
within the reviewed bounds. Arbitrary corruption/external callbacks remain outside
this valid-source proof.

Actual stack symbols 106,560 /8,256 retain each 64-byte guard, are contiguous,
and end within physical SRAM. Other retained RAM is 140,924; four donors remain
138,880 and metadata 16,584 remains inside its donor. Main/ISR margins are
11,027 /1,520; physical charge/address margins 6,532 /6,528. ABI, 160 layout roots,
flash and disabled-arena/symbol checks are actual-image passes, distinct from the
rooted allocation proof. Complete 227/227 nRF evidence retains its explicit
inherited runtime/host `compiled=false` / `original_manifest_current=false`
qualifications; no fresh target execution is inferred.

External analyzer/CMake/shell changes and the later external Pi build-script hunk
were preserved, not staged or attributed here. The latter affects only the normal
Pi route after its counter branch exits. Documentation links, governance and
whitespace checks pass; known pycache remains untouched.

The concrete remaining acceptance work is in the
[bounded P08 evidence campaign](p08-remaining-acceptance-campaign.md). Pi freshness,
Native missing controls and matched allocation/physical/stack accounting, caller
reconciliation and independent P08 exit remain required; nRF fit is now evidenced.

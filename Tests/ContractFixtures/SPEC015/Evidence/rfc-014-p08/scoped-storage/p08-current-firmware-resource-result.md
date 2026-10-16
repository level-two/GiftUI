# P08 current firmware resource result — 2026-10-16

**STOP: the actual linked firmware has a required cold main-stack subset of
28,560 > 27,648.** Complete nRF collection, pristine firmware build, linked
RAM/flash, strict layout and ABI checks pass. Stack fit fails independently of
those passes. This is final-image evidence, replacing the prior applicability
gap; no contract-object frame is substituted for a firmware frame.

No source optimization, resource change, new compiler/build/link invocation,
target execution or hardware operation occurred in this assessment. Historical
repair allowances stay closed; P08/R07/T8.1 and full SO acceptance remain open.

## Exact artifacts and qualified passes

Build revision is `f042252f39a167c97c2c30d9fe5ed4b1a5f30029`; maintained counter
source remains `51cfc960` / SOURCE review `ee10d2f1`. The narrow ALL_SYMBOLS
receipt fix at `f042252f` changes no counter realization or resource limit.

| Evidence | Current result |
| --- | --- |
| Complete nRF collection `.build/nrf52840/contracts/p08-counter-yq7m79g3` | **227/227 pass**, collection_complete=true/passed=true. Target code was not executed. The former 202 nRF omissions are closed for this exact collection. |
| Normal doctor and pristine supported counter build | Pass; all 24 source owners freshly compiled with actual firmware flags. No partial receipt or scratch-link bypass. |
| ELF `.build/nrf52840/signal-analyzer-static/rfc014-counter-firmware/zephyr/zephyr.elf` | SHA256 `e649c5d26a676140b473e8fa1de5b075a479d8282a7f6d69e0034fb215884c38`. |
| Map / configuration | Map SHA256 `7f157a92a5c69463c1234ef181033edaf3b88fae2e7fddf0c820351b9a1fc703`; `.config` SHA256 `4f722a1601be957e850c3ff3b9c79399d72d2918c788f631364ad129ee21e2e1`. |
| Compiler | Swift executable SHA256 `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`; exact actual commands/imports/source hashes are preserved. |
| Linked RAM / flash | **170,620 / 196,608** RAM and **403,400 / 1,048,576** flash. Flash is below the 917,504 warning threshold. RAM includes configured stack reservations; no stack high-water is added again. |
| Layout / ABI | All **160** strict roots match: four 34,720-byte slots charge 138,880, metadata extent 16,584 within donor, additional retained metadata zero. ELF32 ARMv7E-M Thumb-2, Cortex-M4F hard-float/VFP register ABI passes. |

The complete collection still carries the two exact existing runtime/host
noncompiled applicability qualifications: `CounterScopedStorage.swift` has
compiled=false/original_manifest_current=false in those predecessor recipes.
The qualification preserves their excluded-source applicability; it is not a
fresh full-source predecessor pass. The counter collection and subsequent firmware
do freshly compile the actual selected sources. Do not erase that distinction.
Native focused 42-check receipts still omit 384 checks per profile; no fresh full
Pi or Native matrix, target execution or complete owner conformance follows.

The [manifest](linked-firmware-current/manifest.json) pins the immutable
[resource packet](linked-firmware-current/resource-proof.tar.xz), 881,600 bytes,
SHA256 `8db18ea94b5c9b1ad41b64759617cd7cb75c4bd5e57e9c7014a36cb56d7f1fdc`.
It includes the actual ELF/map/config, reports, complete collection/source handoff,
build wrappers, actual compiler commands, symbol-indexed complete selected
disassembly, direct BL/callback-literal proofs and the rejecting sum. Previous
firmware remains preserved under `.build/nrf52840/p08-preserved-firmware-20261016T145328Z`.

## Required simultaneous cold reservations in the actual ELF

The normal valid two-host reconstruction route initializes original backing,
constructs the first host with early=0 and no candidate fault, then later tears
down/reconstructs for the second host. At the first preset-factory call, the
following fixed entry reservations remain simultaneous. Function identities are
ELF STT_FUNC symbol-table indices/addresses, not objdump's nearest printed label.

| Actual operation | Symbol index / Thumb-cleared address | Saved registers + local reservation |
| --- | --- | ---: |
| two-host caller | 5469 / `0x4af34` | 36 +36 =72 |
| one-host caller | 7184 / `0x4b038` | 36 +108 =144 |
| prepared host | 5521 / `0x1a62c` | 36 +1,500 =1,536 |
| original model lender | 7148 / `0x42422` | 32 +488 =520 |
| root body | 7198 / `0x1a888` | 32 +1,200 =1,232 |
| semantic lender | 5210 / `0x5956e` | 32 +488 =520 |
| semantic callback body | 5448 / `0x1aab8` | 32 +1,024 =1,056 |
| original owner.withStorage | 6515 / `0x10cb8` | 36 +3,820 =3,856 |
| scoped consuming body | 5465 / `0x4a2e8` | 36 +300 =336 |
| session/caller | 6928 / `0x49574` | 36 +5,920 +4 =5,960 |
| cold constructor | 6453 / `0x48d88` | 36 +9,920 +12 =9,968 |
| actual nRF preset factory | 6187 / `0x4949e` | 16 +3,344 =3,360 |
| **Selected required lower bound** | | **28,560** |

Actual direct BLs connect two-host+102/+164→one-host, one-host+236→prepared,
prepared+374→model lender, root+478→semantic lender, semantic body+240→withStorage,
scoped body+204→session, session+266→constructor and constructor+1650→factory.
Each relevant fixed reservation is restored after the nested operation, not at
source consumption. The constructor's factory call still precedes destination
assignment/destruction and subsequent host use/teardown.

The linked callback pointers use actual literal words plus Thumb PC+4 at the ADD:
word at `0x1a884`, ADD at `0x1a7a0` → `0x517d5` (model forwarder);
word at `0x1aab4`, ADD at `0x1aa26` → `0x519b5` (semantic forwarder);
word at `0x1abec`, ADD at `0x1aba6` → `0x51a6d` (scoped forwarder);
word at `0x110e8`, ADD at `0x110b6` → `0x503cb` (first original byte-loan forwarder).
The raw little-endian words, PC+4 values and results are in the proof JSON.
Model lender preserves its supplied function pointer across BLX; model forwarders
`0x517d4`→`0x517e2`→root, semantic forwarder `0x519b4`→semantic body, and scoped
forwarder `0x51a6c`→scoped body are actual linked functions with complete bodies.
The semantic lender's internal `0x5996c` helper is preserved but not added.

`withStorage` still encloses the original b0/b1/b2/b3/g0/g1/g2/g3/g4/c0/h0/r0/r1/h1
loans and invokes the supplied consuming body once before unwinding. The actual
first byte lender is `0xef20`; its callback is the resolved `0x503cb` Thumb target.
All these interposed bank/forwarder costs are omitted from the twelve-entry sum.
They are additional enclosing work, not invented direct withStorage→body edges.

SP reassignment does not release the counted fixed frames: prepared allocates a
further 112-byte aligned area and 8-byte outgoing area; root allocates a further
96-byte aligned area and 64 outgoing bytes; semantic body allocates 96 aligned
bytes; withStorage derives its later SP by subtracting 296 then rounding down,
and reserves another 16 outgoing bytes at the lender call. These extra areas and
BFC alignment are deliberately omitted. The enclosing entry/corpus/custody,
all remaining callback/lender frames, deeper factory callees and IRQ are omitted
too. Cold namespace/plan/join helpers have returned; later live/stale/cleanup
operations and alternative callbacks are not summed into this path.

Thus **28,560 exceeds 27,648 by 912 before additional required costs**. The 912
is not a complete gap or a proposed adjustment. This sufficient actual-image
rejection triggers the requested stop before exhaustive phase/IRQ closure.
No complete peak or total-RAM impossibility is claimed.

## Allocation, IRQ and remaining gates

Current config reserves main 27,648 and ISR 2,048; FPU/hard-float and MPU stack
guard are enabled, heaps are disabled and multithreading is off. Config and a
passing link do not prove safe feasible exception/FPU overlap. That complete
bound remains open and is unnecessary to establish the already rejecting subset.

Actual linked `swift_allocObject` at `0x31a3a` forwards to its 52-byte implementation
at `0x31a3e`, which calls `posix_memalign` at `0x5ddb2` and traps if its output
pointer is null. The latter returns ENOMEM/12 without storing an allocation.
Complete bodies are preserved. This is not rooted zero-heap proof: allocator
presence alone proves neither a reachable allocation nor its absence. Complete
rooted reachability, including indirect targets, remains unclosed at this stack
STOP. Matched Dynamic allocation/overhead and complete failure/destructor/live
stack paths remain open too.

P08 now has a complete current nRF compiler collection and a real early linked
nRF artifact with ABI/layout/RAM/flash evidence. It still lacks passing nRF stack
fit, complete applicable four-route/current-source coverage and refreshed early
Pi evidence, complete stack/IRQ/allocation accounting and independent P08 exit.
All nine SO criteria remain open as full criteria; P09 analyzer migration,
P10 integrated conformance, P11 complete workload/resources/connected dispositions,
P12 cutover and the exact I4-07 residual remain separate. No hardware/timing gate
is closed or moved by these new artifacts.

**Recommendation:** perform one bounded internally compatible design review
against this actual firmware, targeting simultaneous original-lender/control and
constructor/destination materialization under unchanged limits. Internal design
work itself needs no contract approval. A new source candidate requires a
separately explicit bounded execution/repair allowance; this result renews none.
Do not repeat full collection/image work without a changed concrete realization.
If the chosen remedy instead raises the stack limit, first obtain a complete
phase/IRQ bound and reconciled whole-RAM proposal, then the reviewed resource/
contract decision identified by the completion assessment. Neither +912 nor
currently unused linked RAM supplies that bound or approval.

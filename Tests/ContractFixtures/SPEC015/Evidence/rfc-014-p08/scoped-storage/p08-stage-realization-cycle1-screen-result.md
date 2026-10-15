# Typed-stage correction 1 — object screen result

**Compiler/layout PASS; stack fit FAIL.** Actual registered screen at `12dbc312`
exits 0 in about 53 seconds: 25 preparation/module/layout checks pass, 202 compiler
controls are not run. `fresh_focused=true`, `focused_passed=true`,
`collection_complete=false`, `passed=false`. No runtime/full collection, image or
target execution is implied. Correction 1 is productive: it clears the borrowed
baseline compiler errors. Count remains **1/2**, one correction left; all prior
allowances/failures remain historical. No compiler/build/runtime/image call was
made in this analysis; only existing symbol decoding and object disassembly.

The [compact result](stage-realization-cycle1-screen/result.json),
[original receipts archive](stage-realization-cycle1-screen/screen-receipts.tar.xz)
and [section/symbol/prologue/call packet](stage-realization-cycle1-screen/frames-and-calls.json.xz)
pin actual commands, tools, source and full bounded disassemblies of 24 relevant
functions. Source SHA-256 `55e9026c25aa66f3374ccd81fa14ab6982e07aea2e3a95b2e2d9fae5c4295631`.
Actual object `.build/nrf52840/contracts/p08-counter-4ku93qwd/P08CounterRuntime.o`
SHA-256 `e782a5b48e75d7cf7a442fcbf735c31d09e62b2f6d55f2ddcb1f1e73f9a691f6`;
build receipt `214d74b6ab3132954e622b9de3221c4a663998d55d828e48783b78aa6a1d6d66`;
wrapper receipt `d17b291dd630cc375a96c34cdf05d14a4784a508c933365a13783b3355239062`.
Layout hash `81fd3495fb408fab732065a0697c7ab5a6050feae23b68c3c28d10e68d56c640`
still gives cursor 31,993, alignment 8, four 32,000-byte slots / 128,000 retained.
Wrapper stderr is empty. Packet result SHA-256
`112529655754bda39d49d45cb5544e8b13ea32a2c27734652f9a61d1e4b4be2e`.

## Required live subpath

These ET_REL owner section identities qualify address zero. Every frame includes
actual saved registers and initial SP subtractions. The packet resolves each
relocation through its real symbol table/index. All seven edges are actual `BL`
and `R_ARM_THM_CALL`, with caller SP restoration after return. Enclosing callbacks,
deeper helpers, alignment and IRQ are omitted additional costs, never credits.

| Required function | Section | Saves + local bytes | Frame lower bound |
| --- | ---: | ---: | ---: |
| `p08RunStaticSessionPhase` | 3828 | 36 + 1,972 | 2,008 |
| `p08RunStaticSuppliedPhase` | 3824 | 36 + 9,984 + 12 | 10,032 |
| `p08RunStaticOwnerPhase` | 3812 | 36 + 18,944 + 92 | 19,072 |
| `p08RunStaticHostPhase` | 3804 | 36 + 8,896 + 28 | 8,960 |
| `p08RunReuseHost` specialization | 3707 | 36 + 4,384 + 28 | 4,448 |
| `p08ReuseCurrentAction` specialization | 3691 | 36 + 22,528 + 100 | 22,664 |
| actual `SignalAnalyzerPresetHostInstance.runOpportunity` | 3619 | 16 + 128 | 144 |
| actual `CounterHostState.runOpportunity` | 7149 | 32 + 7,840 + 24 | 7,896 |

Edges: section3828+0x370→3824; 3824+0x300→3812; 3812+0x186→3804;
3804+0x86→3707; 3707+0x7c→3691; 3691+0x64→3619; 3619+0x2a→7149.
Sum **75,224 > 27,648 bytes**. Even the first three live phase frames total
31,112. No mutually exclusive construction/cleanup branches are summed.

Source feasibility: `p08CounterHost` calls the real Static host twice in the same
reservation, passing a nonnull transcript through `runP08StaticHost`, default
early 0 and no candidate fault. All phase early exits are false. The second host
has `transcript.hosts == 1`, so reuse performs the current-action positive twin,
prepares the actual capture and runs its down cycle. The host is active, report
valid, activation step seven; its actual wrapper enters active state opportunity.
The up cycle later follows the same call chain. This proves a required source
workload path, not observed target execution on an insufficient configured stack.

## Effect and remaining cause

Root frame **30,096→128**; reuse ordering frame **66,616→4,448**. The older reported
body/run/reuse lower bound was 114,464. New subpath boundaries differ, so their
difference is not a measured whole-workload saving. New fit still fails. The old
image's conditional zero-margin main-stack room was 64,512 with other RAM fixed;
even that historical margin is below 75,224. A modest budget-only solution has no
support, and no current image RAM fit is claimed.

The nested consuming phases retain their argument/construction homes throughout
later host work. A separate explicit copy sample remains in section3691:
+0x168 sets memcpy length **3,889**, +0x174 calls `__aeabi_memcpy8`, then +0x178
calls `CounterHostState.observeModelValue`. Source `host.owner.observeModelValue()`
still materializes whole-state storage in this caller despite the existing state
operation boundary. This is a static sample, not heap allocation, semantic
authority duplication or an exhaustive frame partition. The required state's
own 7,896-byte opportunity frame also stays chargeable. No Swift variable DWARF
or complete upper bound is claimed.

## Final correction proposal for independent approach review

Both actual causes must be addressed together. No source implementation or second
correction consumption accompanies this result commit.

1. One lexical concrete construction function per route replaces recursive
   session→supplied→owner→host execution. Original model/root/activation lenders
   remain in `runP08ScopedBody`. Consume session into supplied, supplied into a
   mutable owner and owner through the existing factory into one mutable host.
   Early 1 resets session; early 2 retires/resets supplied; early 3 runs all eight
   hooks before joins. Each early branch returns owned completion facts before
   the next transfer. No enum, new owner or unchecked lifetime operation.
2. The lexical function installs a host-only defer after construction. This host
   is never consumed again; early 4 returns before activation. The host operation
   function now takes **inout host**, with no consuming local host or cleanup
   defer. Keep all run branches. Reuse teardown followed by lexical defer retains
   double-teardown coverage. Common control checks/origin retirement still run
   once after the lexical function returns. Removing nested execution edges is
   concrete; coalescing local consumed-value homes is compiler-dependent.
3. Add short fileprivate noninlined operations borrowing the host for existing
   produced-action/model observations and prepare/deliver calls. Return only the
   same owned capture facts, UInt8 or Bool; assert owned results outside borrowed
   accesses. This confines the witnessed whole-state forwarder temporary to an
   operation call instead of repeating homes in the larger reuse body. Preserve
   every full stale fingerprint/model comparison, one original baseline and same
   admission/order. No new protocol, scoped getter or arbitrary conformer API.
4. Split action down/up cycle bodies into sequential inout-host operations, with
   only original owned capture/applied/dispatched facts between them. Retain all
   cycle/admission/context/model/capture/effect/frame assertions. Do not return
   summaries, refresh baselines or drop required coverage. Charge all actual
   resulting helper/caller storage; source splitting is not a saving claim.

Bounded file list remains one Swift fixture plus exact qualification/driver pin
and immutable evidence. This is a concrete private candidate, not an annotation-
only retry or promised fit. Main uncertainty: resulting total live constructor
and observation storage with this compiler. Independent approach/source review
must precede the same registered early fresh screen. If its reachable lower bound
still exceeds the limit, final correction 2/2 stops; no third variant is implied.
If promising, current full collection/image/path/ABI/IRQ/allocator/RAM/flash and
independent acceptance remain required. P08/R07/T8.1/HC-RD-003 stay open.

Read-only packet hashes/decompression, arithmetic, local links, governance and
whitespace checks pass. The packet is 132,265 bytes; binaries are hash-pinned,
not duplicated. Unrelated generated pycache remains untouched.

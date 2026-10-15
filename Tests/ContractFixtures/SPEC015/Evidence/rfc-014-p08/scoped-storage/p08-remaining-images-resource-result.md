# P08 early images and resource reconciliation — 2026-10-15

**Fit FAIL; P08/R07/T8.1/HC-RD-003 remain open. Independent Strong exit review
is pending.** The four [full collections](p08-remaining-full-collections-result.md)
pass for final source `0d3e3c7d`, reviewed at `51544daa`; the two registered early
image builds exit 0 at checkpoint `47b57eb8`. A reachable frame in the actual
nRF image alone exceeds the unchanged 27,648-byte main-stack ceiling. This
document supplies evidence and dispositions, not an implemented transition.
The [activity](p08-remaining-completion-activity.md) has consumed both corrective
cycles (2/2). No source repair, new compiler/build invocation, target execution,
hardware action or resource waiver was performed during this reconciliation.

## Preserved image identities

The [image manifest](remaining-early-images/image-manifest.json) pins both ELF
hashes, all four parent-run doctor/build wrappers, exact commands, input receipts,
reports, maps, nRF configuration/build recipe and the 16-file prior-image backup.
`remaining-early-images/image-reports.tar.xz` is 1,347,396 bytes, SHA-256
`c7d6fac8c6d6d3c3aab9d5f60dc0155e90ce94b431ac0fb28a1ad5fe44dfcbfc`.
It contains 33 individually hashed members; ELF binaries are hashed, not copied.
The original caller JSON is preserved inside this archive before its current-view
refresh. The [read-only disassembly command](remaining-early-images/nrf-disassembly-command.json)
pins the full compressed nRF disassembly and objdump identity. Target code was
never executed by these inspections.
The existing nRF compile-command database is additionally preserved compressed;
`nrf-compiled-input-identities.json` hashes 681 existing source/object/tool files.
These identities attribute the inspected image recipe; they do not rerun compilation.

| Artifact | SHA-256 |
| --- | --- |
| Pi `rfc015-scoped-counter-image/counter.elf` | `ea0bc08884fc68a3f785a47f028171e43e35b5454d55dee5ea688ed3c26931cf` |
| Pi `input-receipt.json` | `d83a9df8e34fe0597b6080cf490f1e735d43d4859ef04986d3d3ecfc83664f09` |
| nRF `rfc014-counter-firmware/zephyr/zephyr.elf` | `66ca1113d997c6424aedb258c1477692ce4bf5b42ed77f42bb1d5cba66339da9` |

The Pi ELF is ELF32 ARM EABI5 hard-float PIE, CPU v6, Thumb-1/VFPv2 with VFP
register arguments. The nRF ELF is ELF32 ARM EABI5 hard-float executable,
ARMv7E-M/Thumb-2/VFPv4-D16 with VFP register arguments. Both retain eight-byte
ABI alignment. These are linked-artifact checks, not connected-board results.

## Exact nRF stack failure

The [symbol and command record](remaining-early-images/entry-and-frame-symbols.json)
uses actual ELF STT_FUNC addresses/extents. Objdump's nearest printed Swift label
is sometimes `swift_allocError+...`; that printed label does **not** identify the
enclosing Swift function. The symbol table resolves this ambiguity.

The feasible accepted-workload path is:

1. C [`main`](remaining-early-images/main.log), `0x322bc`, calls SPI initialization.
   Its success branch loads backing address `0x200003c0`, byte count 128,000 and
   calls `giftui_rfc014_counter_entry` at `0x322d6`.
2. The [entry thunk](remaining-early-images/entry-thunk.log), `0x5c206`, tail-branches
   to the [Swift entry](remaining-early-images/swift-entry.log), `0x5c20a`.
   Its nonnil/count checks match the actual C symbol and source reservation.
3. After the preceding graph phase returns, the Swift entry directly calls
   `counterExerciseScopedStorage` at `0x5c230`, target `0x214f4`. The source entry
   and `CounterScopedStorageProbe.swift` select this scoped-storage workload;
   the call is not a hypothetical unrelated symbol or a dead negative probe.
4. That function's [complete disassembly](remaining-early-images/scoped-storage-complete.log)
   begins with nine saved registers (36 bytes), `sub.w sp, sp, #29952` and
   `sub sp, #108`, then rounds SP down to a 16-byte boundary.

Its standalone frame therefore needs **at least 29,952 + 108 + 36 = 30,096 bytes**,
already **2,448 bytes above 27,648**. Rounding costs another 0–15 bytes. C `main`
saves 16 bytes and the live Swift entry saves 24 bytes; they cannot reduce this
lower bound. This proves failure without assuming the size of any nested frame,
failure return, destructor or interrupt. The success branch is a feasible path
required by the approved workload; no claim is made that it ran on a board.

[Additional local-subtraction observations](remaining-early-images/nrf-large-local-allocations.json)
include construction, body, repeated-host, wake and retirement helpers. They are
exact symbol-range prologue observations, **not** a complete frame/callgraph bound.
For example, repeated-host local SP subtractions total 102,604 bytes before saved
registers or callees. They reinforce the need for a separately authorized resource
resolution but are unnecessary to prove the minimal failure above.

The historical 58,648-byte enclosing-construction failure at `63e717d1` remains
historical evidence. It is neither overwritten nor replaced by a passing bound.
No complete construction/body-return/helper/retirement/IRQ upper bound is claimed:
indirect calls, compiler temporaries, feasible IRQ nesting/hardware frames and
handler callees are unclosed. `.config` retains main stack 27,648, ISR stack 2,048,
MPU enabled, no zero-latency or multilevel interrupts. A separate ISR reservation
does not make the demonstrated oversized thread frame fit. Exhaustive path
enumeration was stopped once this actual reachable lower bound proved failure.

## Other resource and physical-accounting dispositions

The actual nRF layout report verifies all 25 original regions, disjoint checked
count×stride extents, rounded offsets, cursor 31,993, maximum alignment 8 and
required slot 32,000. The exact C symbol `counter_backing.0` is 128,000 bytes at
`0x200003c0`, in BSS with alignment 8. Its four origins are spaced 32,000 bytes,
each aligned to 8; all retained bytes, including seven end-rounding bytes per
slot, are charged. Retained surplus beyond four declared slots is zero. All 129
measurement roots and their bounded immediate-return/tail proofs are recorded
from the object and final ELF by the unchanged strict extractor; extraction is
read-only and `executed=false`.

FLASH is **396,660 / 1,048,576** (warning threshold 917,504); static RAM including
the configured stack reservations is **159,744 / 196,608**. Those individual
linker checks pass. All **454** linker warnings are the same orphan
`.swift_modhash` class. Its actual allocated, non-executable 3,632-byte section
belongs to the flash LOAD segment and is already charged in FLASH; it is not
unaccounted RAM. No warning suppression, retention or source change was made.

The final [native physical-control receipt](remaining-early-images/native-physical-controls.json)
pins Dynamic 1,736,082 / Static 1,736,158 assertions, zero failures, all 13 labels
per route and all five native exclusivity controls. The compiled fixture derives
the 26 backing families from original physical IDs, count/size/stride/alignment,
retained bytes and existing Dynamic payload visitors. Native Optional strides,
G4's typed tail wrapper, R1 surplus, residual metadata and state partitions remain
charged. Role swaps preserve original IDs/address/extents; reverse successful-prefix
destruction, partial acquisition cleanup, repeated hosts at one inventory/control
address and backing-last retirement are exercised by those native runs. They do
not establish target runtime/destructor behavior or a complete peak stack ledger.
Exhaustive owner/token/descriptor/carrier temporary accounting and every target
cleanup/destructor path remain unproved; no aggregate physical-resource closure
is inferred from the 26-family validator or the successful native assertions.

The four former `withBacking` measurement consumers now read owned measurement
facts in Counter/Cycle measurement and region files; no capability callback is
reintroduced. This does not migrate the retained analyzer owners or prove their
actual factories valid. Existing source partitions/payload capacities are not a
complete allocator-header or transient peak allocation measurement for Dynamic.

The nRF heap and common-libc malloc arena configuration remain zero. Actual
[`posix_memalign`](remaining-early-images/posix-memalign.log) returns ENOMEM (12),
and the linked [Swift object allocator](remaining-early-images/swift-alloc-object.log)
calls it and traps on null. [Direct allocator branch observations](remaining-early-images/allocator-observations.json)
are preserved, but do not resolve all indirect selected-path reachability. Thus
complete Static zero-allocation reachability, matched Dynamic allocation headers/
temporary peaks and complete Pi/native stack costs remain **unproved**, never
zero by inference from link success or allocator stubs. No board timing, display,
SPI/IRQ execution or hardware allocation result is claimed.

## Caller and acceptance reconciliation

The [current caller inventory](so01-current-callers.json) refreshes all original
171 files and includes five additional selected RuntimeDerived fixtures (176
total). At this final checkpoint 44 original hashes changed (42 were stale at
activity entry). The [delta](remaining-early-images/caller-refresh-delta.json)
pins every old/new hash. Exact current token/line hits are audit aids; retained
D01–D34 dispositions are not compiler-resolved compatibility proof. Analyzer
factory/model/root/target gaps, I4-07 and generated/analyzer migration remain
explicit. No broad analyzer/P10 test campaign was run.

| Criterion | Current disposition |
| --- | --- |
| IN-SO-001 | Required declaration/state/lifetime matrix passes the four full compiler collections. |
| IN-SO-002 | Native unequal-count R/H swaps, refusal/capacity/key/generation/stale controls pass; targets compile, not execute. |
| IN-SO-003 | Current caller hashes/hits and four owned-fact repairs reconciled; owned analyzer/factory/Cycle-wide compatibility remains incomplete. |
| RP-SO-001 | Actual nRF numeric original layout/C reservation passes; native original inventory/prefix destruction/surplus controls pass. Target cleanup execution is absent; complete cost ledger remains open. |
| RP-SO-002 | Native cleanup/activation/candidate/retirement/repeated-session and exclusivity controls pass; no target runtime or complete resource closure. |
| RP-SO-003 | Four full matrices and both linked images/ABI/layout/static RAM/flash pass; **nRF stack fit fails**, complete IRQ/allocator/Dynamic cost proof remains open. |
| HC-SO-001 | Four full independently lifetime-limited carrier matrices pass, including synchronous-scope async transfer rejection and successful twins. |
| HC-SO-002 | Finite counter native ownership/cleanup/provenance/action/semantic/pixel controls pass; broader retained analyzer applicability and target execution are not supplied. |
| HC-SO-003 | Exact source/compiler/route/images recorded; resources fail and independent Strong exit remains pending. No P08 pass. |

P08, R07, T8.1 and HC-RD-003 stay open. SPEC-011/013/015 remain implementing;
plans remain active. I4-07/analyzer applicability, P09–P12, connected hardware
and timing evidence retain their existing boundaries. The next action is an
independent Strong review of this failure package, then maintainer disposition
of the exhausted allowance/resource failure. No corrective architecture or raised
ceiling is selected by this report.

## Documentary verification

`python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/remaining-early-images/verify-evidence.py`
passes: 25 packet files, 33 archive members, both ELF identities, 681 existing
compiled-input identities, all 176 current caller hashes and the exact
symbol/entry/prologue arithmetic. `git diff --check` and
`scripts/validate-governance.rb` pass (199 authority nodes, 2,024 edges;
7 features, 76 lifecycle artifacts). These checks verify
preservation/attribution only; they do not add compiler, runtime or fit coverage.

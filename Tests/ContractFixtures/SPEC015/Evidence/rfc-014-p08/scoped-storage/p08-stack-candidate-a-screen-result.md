# Candidate A — one nRF screen, object rejection

**STOP expensive follow-up: target object remains oversized.** The one registered
screen compiled successfully in about 53 seconds; the read-only stack rejection
inspection fails. Candidate A improves materialization substantially but does not
fit 27,648 bytes. Independent Strong result review is next. Candidate 1/1 and
screen 1/1 are consumed; the single mechanical pre-execution B01 correction is
preserved separately. Historical2/2 stays closed. No automatic optimization
variant, source repair, additional compiler/build/image or target run follows.

## Exact partial evidence

At `8acaf27a`, parent ran the exact command in the
[corrected freeze](p08-stack-candidate-a-review-correction-source-freeze.md).
Output: `.build/nrf52840/contracts/p08-counter-fbv0g_nt`. Flags are
`fresh_focused=true`, `focused_passed=true`, `collection_complete=false`,
`passed=false`: **25 preparation/module/layout checks pass, 202 compiler
controls are not run**. No native runtime/exclusivity, Pi or new image evidence.
Wrapper exit 0, stderr empty. This is not a full suite or fit pass.

| Artifact | SHA-256 |
| --- | --- |
| Wrapper `20261015T201653650401Z-stack-candidate-a-screen/result.json` | `089f00752c5810ce0b09a2bdac58f38088a7597943fa7e86df843ba470c1dd89` |
| `P08CounterRuntime.o` | `025dc84f58f2c26cb9188132475995405bae8cbb3e7b6b174eb87b8190868b03` |
| `so07-layout-facts.json` | `19d227b06ab9c0081363658bfd8f22ffea60b0d7c1e6e85073ae265af6f2afd6` |

The [receipt manifest](stack-candidate-a-screen/receipt-manifest.json) pins all
215 current input identities, compiler, object identity, exact parent wrapper,
commands, checks, objects list and layout facts. The 42,320-byte archive
`stack-candidate-a-screen/screen-receipts.tar.xz` SHA-256 is
`555a4e03c650a0330e3d6940b626af47685598dd65d54cc83ce316eecaf67483`.
Layout remains cursor 31,993 / alignment 8 / 32,000×4 = 128,000; no new layout or
capacity is selected. Object code is hashed, not copied into evidence.

## Exact object stack result

[Function evidence](stack-candidate-a-screen/object-frames.json) pins exact
STT_FUNC identities, **ET_REL owner sections**, complete bounded disassemblies,
tool/command/output identities and relocations. All functions start at section
offset 0; those offsets are not globally unique and are never treated as linked
addresses. Section numbers below belong to this exact object only.

| Function | Section | Prior linked frame lower bound | Current object lower bound |
| --- | ---: | ---: | ---: |
| counterExerciseScopedStorage | 3937 | 30,096 | **30,096** |
| runP08ScopedBody | 3792 | 71,808 | **9,176** |
| P08BodyCleanup.constructOwner | 3756 | 37,768 | **37,768** |
| P08BodyCleanup.constructHost | 3768 | 42,928 | **42,928** |
| P08BodyCleanup.run | 3776 | 38,672 | **38,672** |
| p08RunReuseHost | 3615 | 102,640 | **66,616** |
| P08BodyCleanup.finish | 3784 | 31,552 | **31,376** |
| counterWakeControls | 7376 | 36,240 | **11,888** |

Current scoped-storage prologue still saves nine registers (36), subtracts
29,952+108 and aligns SP down to 16: **≥30,096 > 27,648**, before caller/callee/IRQ.
The actual current Swift entry has an R_ARM_THM_CALL relocation to this exact
function. This alone rejects the early screen; no exhaustive callgraph is needed.

[Section/symbol-table-indexed relocation proof](stack-candidate-a-screen/entry-and-nested-relocations.json)
also preserves the required nonnull-transcript path. In section 3792, BL at 0x288
calls cleanup.run, followed by finish at 0x28e. In section 3776, the nonnull branch
BL at 0xa8 calls reuse; the host is reinserted afterward. Target identities come
from each relocation's actual linked symbol table/index, not name guesses or
unresolved disassembly address0. Caller frames remain allocated; neither is a
tail call. Source predicates remain failAfterRuntime=false, early0, no candidate
failure and the live transcript forwarded twice in the same physical reservation.

The current three-frame lower bound is **9,176+38,672+66,616 =114,464**,
down 98,656 from 213,120. Outer wrappers, nested runtime calls, alignment and IRQ
costs are excluded. Mutually exclusive construction/finish frames are not added
to that sum. Body→constructHost alone is ≥52,104; body→finish ≥40,552.
This is an object rejection bound, not a new linked-ELF measurement or complete
upper bound. Firmware rebuild flags/composition can differ; no new image ran.

[Wake-copy comparison](stack-candidate-a-screen/wake-copy-comparison.json) finds
zero explicit 4,200-byte memcpy sites there (six in the prior linked function),
while **138 explicit 3,889-byte transfer sites remain**. These are qualified
immediate/call-relocation sites with no intervening BL/r2 overwrite, not dynamic
counts or simultaneous-byte totals. Body and wake improvements support the
targeted realization effect; remaining state/carrier transfers and large
construction/run/cleanup/reuse frames still dominate. They do not imply semantic
duplication of noncopyable ownership. Existing large out-of-line helpers were
intentionally retained rather than mechanically annotated.

## Decision and limits

A budget-only change still cannot fix this object path within the current RAM
ceiling: **114,464 > 64,512**, even before outer costs. The latter is already the
zero-headroom theoretical main-stack maximum with the prior linked image's other
RAM frozen (132,032 non-main-object bytes); it is not a new limit or current
image measurement. A 30 KiB increase remains insufficient. No heap, backing,
capacity, workload, MPU/IRQ or RAM relaxation is adopted.

The next decision is whether to authorize a separately reviewed realization
package addressing the **remaining whole stage/carrier materialization**:
38,672-byte cleanup.run, 42,928-byte host construction, 31,376-byte finish and
66,616-byte reuse. The residual 3,889-byte state-transfer sites need attribution
before selecting another change; repeating the same annotations or merely
raising the stack is not an evidence-grounded fix. A private lawful construction/
borrow/control-flow realization that preserves existing cases/lifetimes could be
reviewed internally. A representation change to mandated state cases, scoped
ownership, workload or resource bounds requires the applicable upstream review;
this report selects neither. This is a concrete remaining-mechanism handoff,
not authorization for another optimization search or generic retry.

P08/R07/T8.1/HC-RD-003 remain open. Full current coverage, final ELF layout/ABI/
RAM/flash, complete main/IRQ/allocator/Dynamic proof, independent final exit,
I4-07/analyzer, P09–P12 and hardware/timing remain separate unmet obligations.
All historical source/review/screen/image records remain immutable. Inspection
used only the existing object and read-only tools; maintained source is unchanged.

Documentary verification passes for archive members, exact object identity,
partial flags/statuses, eight section-qualified frame/disassembly records,
two symbol-table-indexed BL edges, arithmetic and local links. The 15-payload
packet index `stack-candidate-a-screen/packet-files.json` SHA-256 is
`91d6c067b4642bd2cbff22d9cf0b43b70db313e52345cc2e9cd7719cb17f74bf`.
Whitespace and governance pass (200 authority nodes, 2,026 edges; seven features,
76 lifecycle artifacts). These checks do not execute code or close fit.

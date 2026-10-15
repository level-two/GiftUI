# P08 candidate A — independent Strong result review

**STOP independently confirmed; P08 fit FAIL.** Review of result commit
`31dcea76` and the [screen result](p08-stack-candidate-a-screen-result.md)
finds no material discrepancy. Candidate A made useful reductions, but the
existing object is sufficient to reject this candidate under unchanged limits.
Further full suites or images for this source would not close the demonstrated
stack failure. This is an object-screen conclusion, not a final ELF measurement.

Independently verified all 15 indexed payload hashes/decompressed hashes, nine
archive members, all 215 current input hashes, wrapper exit 0/empty stderr and
actual `P08CounterRuntime.o` SHA-256
`025dc84f58f2c26cb9188132475995405bae8cbb3e7b6b174eb87b8190868b03`.
A separate ELF32 read confirms ET_REL/ARM, actual owner sections and STT_FUNC
identities. Read-only regeneration of eight full section disassemblies and two
entry disassemblies exactly matches the packet. Actual SHT_REL `sh_info`,
`sh_link` and symbol indices resolve the entry and nested targets; section-relative
zero offsets are not treated as global addresses. No compiler or code execution
was performed.

The reachable scoped-storage prologue saves 36 bytes and subtracts 29,952+108:
**at least 30,096 bytes**, unchanged, exceeding 27,648 by 2,448 before callers.
The current entry's call relocation reaches this function. Separately, raw
prologues and actual BL relocations establish the required nonnull-transcript
path **9,176 + 38,672 + 66,616 = 114,464**, reduced by 98,656 from 213,120.
Body calls cleanup.run at section 3792:0x288 and then finish; cleanup.run calls
reuse at section 3776:0xa8 after its nonnull check and reinserts the host afterward.
Caller frames remain allocated. The source still supplies the same live transcript
twice with false runtime failure, early zero and no candidate failure. No mutually
exclusive construction/finish frame is added to this three-frame bound.

Other independently checked frame bounds are construction 37,768/42,928,
finish 31,376 and wake 11,888. Explicit wake transfer sites independently reproduce
4,200-byte sites **6→0** and 3,889-byte sites **138→138**. These static sites do
not establish dynamic counts, simultaneous bytes or semantic ownership copying.
The remaining stage/construction/reuse materialization is a concrete investigation
boundary; a particular further source fix is not proved by these counts.

The receipt truthfully records **25 pass / 202 not run**, fresh-focused and focused
pass true, collection-complete and aggregate pass false. Layout remains
31,993 cursor / alignment 8 / 32,000×4 = 128,000. No current full profile suite,
new image, runtime, exclusivity or full lifecycle acceptance is claimed. The
114,464-byte bound also exceeds 64,512, the prior image's zero-headroom theoretical
main-stack maximum with other RAM frozen. That comparison rejects a budget-only
answer under those assumptions; it is neither a current image measurement nor a
proposed larger ceiling.

Recommendation: stop costly validation here. Any continuation should first
attribute remaining whole stage/host construction, run/reinsertion and reuse
materialization and produce a separately bounded private realization design.
Existing evidence does not force a contract change, but does not prove a lawful
remaining fix. Preserving cases, scoped lifetimes, noncopyable ownership, workload,
capacity and limits keeps such a design internal. If it requires changing those
obligations, take that precise change through upstream contract review before
implementation. Do not repeat annotations blindly or raise the stack ceiling.

Candidate **1/1**, screen **1/1**, the one explicit mechanical pre-execution
correction and historical **2/2 closed** remain recorded; no new allowance is
created. Source remains `9cac6bfa` (candidate A plus exact B01 restorations).
P08/R07/T8.1/HC-RD-003 and all acceptance/resource gaps remain open. No source,
compiler, runtime, image or hardware work was performed by this review.

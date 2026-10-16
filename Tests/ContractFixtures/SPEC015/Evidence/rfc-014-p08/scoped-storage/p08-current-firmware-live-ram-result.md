# P08 current firmware live RAM rejection — 2026-10-16

Current follow-up: the maintainer subsequently authorized total RAM up to physical
262,144. The [complete-bound proposal](p08-current-firmware-complete-bound-result.md)
continues analysis under that direction; this immutable lower-bound evidence
still rejects its historical 196,608 ceiling. Decision text below predates the
new direction.

**A larger main stack alone cannot fit this realization within RAM 196,608.**
The same actual final ELF requires a source-feasible live fixed-stack subset of
**56,888** bytes. Its other linked RAM is **142,972**, giving a whole-RAM lower
bound of **199,860 > 196,608 by 3,252**, before omitted costs. This is a sufficient
rejection, not a complete peak or a sufficient proposed RAM/stack adjustment.

The [independent bounded review](p08-current-firmware-live-ram-independent-review.md)
confirms this rejection and records one source-specific callback-site correction
(`0x59a64` replaces the packet's nil-arm `0x59b3a`), with no numerical effect.
The original proof packet remains immutable.

The maintainer now permits selecting a sufficient larger main stack; roughly
30 KB was illustrative, not a ceiling. That direction does **not** authorize
raising total RAM 196,608. No source optimization, limit edit, compiler/build/link,
application execution, hardware operation or renewed repair allowance occurred.

## Frozen evidence and selected feasible path

ELF SHA256 remains
`e649c5d26a676140b473e8fa1de5b075a479d8282a7f6d69e0034fb215884c38`.
The [preceding final-image packet](linked-firmware-current/manifest.json) pins
the compiler, all actual firmware inputs, map/config and complete nRF 227/227
collection. Its passes and predecessor-receipt qualifications remain unchanged.
The new [manifest](linked-firmware-live-ram/manifest.json) pins the
[live proof packet](linked-firmware-live-ram/live-resource-proof.tar.xz):
187,476 bytes, SHA256
`4c6f0c49bd2e83dde4c3d73a7a47b3c7f8c935ce22b681b28df6a2be1d3aea0a`.

The packet contains all 47 selected entry prologues, complete selected/bridge
disassembly, a source/CFG custody audit, current source snapshots, exact ELF RAM
and stack-symbol arithmetic, and a read-only mechanical verifier. After
extracting it, run `python3 verify_fixed_subset.py --elf <frozen-ELF> --objdump
<pinned-GNU-objdump>`. It checks instructions/reservations/RAM; the separate
`CUSTODY.md` establishes the source-feasibility premise. Mechanical verification
passes; it is not execution of the firmware or proof of a complete upper bound.

Select `p08EmbeddedHost`'s required **.host(0)** case: nil reuse/baseline,
early=0, no candidate fault and successful normal activation. The source calls
the ordinary lifecycle, actual host corpus, then wake controls and successful
admitted-work service. Semantic expansion traverses the authored CounterScreen
background/VStack/disabled Increment Button/Text label. Stop after the concrete
Text declaration-role entry reservation.

| Simultaneous selected fixed entries | Bytes |
| --- | ---: |
| main/entry/corpus/ordinary host/custody/metadata-host/one-host | 456 |
| prepared host, original model/semantic lenders and root/semantic bodies, withStorage | 9,592 |
| session, host phase, lifecycle, host corpus, wake controls | 26,728 |
| service/pipeline and finite authored semantic traversal, through declaration-role entry | 20,112 |
| **Required fixed subset** | **56,888** |

Actual nested BLs retain `counterHostCorpus`'s 7,584-byte frame while calling
`counterWakeControls` at `0x1d6c6`; wake controls retain 9,360 at the successful
coalesced-service BL `0x1dd06`. Those costs are simultaneous. Constructor and
preset-factory frames have already returned and are excluded. The dispatch
`p08RunMetadataCase` restores its 64 bytes before tail-branching to the ordinary
metadata host, so it is excluded too. The `.twoHosts` reuse route and scoped
corpus are mutually exclusive with this selected ordinary-host route and are
not charged. Two semantic tail-forwarding helpers likewise charge zero.

All original fourteen storage loans still enclose the supplied body. **Every
interposed bank lender/callback/forwarder and scoped consuming-body frame is
omitted** from the sum; no generic slot-alternative graph is used to invent a
direct withStorage→session edge. Alignment, outgoing arguments, deeper equality
and other callees, startup, exception/FPU preservation and IRQ costs are omitted.
The broader provisional analyser is archived as discovery only: its generic
65,224 subtotal mixed mutually exclusive paths and is not an accepted bound.

## Whole RAM reconciliation

The actual ELF has disjoint RAM PT_LOAD spans `[0x20000000,0x20000324)` and
`[0x20000328,0x20029a80)`: **804 + 169,816 = 170,620** bytes. Their address
extent is 170,624 because of the four-byte gap. `z_main_stack` is **27,712**
bytes at `0x20022e40`, including its **64-byte guard** and configured **27,648**
payload. `z_interrupt_stacks` is **2,112**, including 2,048 payload and 64 guard.
Both whole symbols lie inside the second RAM segment and do not overlap.

Subtract only main's replaceable payload, preserving both guards, ISR reservation,
backing and all other linked costs:

```text
other retained RAM = 170620 − 27648 = 142972
main capacity before rounding = 196608 − 142972 = 53636
required RAM lower bound = 142972 + 56888 = 199860
lower-bound excess = 199860 − 196608 = 3252
```

No stack high-water is added twice. Four backing slots still charge 138,880;
metadata 16,584 is within that donor, not another added reservation. No rooted
zero-heap pass, complete IRQ bound or complete startup/live/failure/cleanup peak
is inferred. Further closure cannot rescue this unchanged representation under
196,608: this one required path already rejects it.

## Decision boundary and remaining gates

Escalate the **distinct total-RAM tradeoff** before selecting a reservation or
building again: retain 196,608 and permit a concrete bounded change to fixture
co-residency/materialization, or explicitly review a larger total-RAM contract.
The current four-slot representation is not itself a permanent four-slot
contract, but no smaller representation or preserved full corpus is proved here.
No candidate implementation or renewed source attempt is authorized by this
analysis. The 3,252 excess is not the complete gap or a sufficient amendment.

After that decision, finish the conservative feasible main/startup/IRQ/FPU and
allocator account, choose a sufficient aligned reservation with margin, update
the applicable authority, and verify the resulting normal guarded image and
whole RAM. P08/R07/T8.1, complete applicable four-route/SO evidence and independent
P08 exit review remain open. Native omissions, Pi freshness, later P09–P12/I4-07
and connected/timing obligations retain their separate dispositions in the
[completion assessment](../../../../../../docs/implementation-designs/spec-015-p08-completion-resource-assessment.md).

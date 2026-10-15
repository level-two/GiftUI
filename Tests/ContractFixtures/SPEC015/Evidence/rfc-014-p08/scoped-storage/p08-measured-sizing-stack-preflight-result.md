# P08 measured sizing passes; current required RAM lower bound fails

**The current source cannot fit the unchanged 196,608-byte RAM ceiling by raising
only its stack budget.** Required stack frames total at least 71,088 bytes; the
measured original backing alone retains 138,880. Their sum is **209,968**, exceeding
the ceiling by **13,360** before other RAM, outer callers, deeper helpers or IRQs.
This is an object/source preflight rejection, not a current linked-image result.
[Independent resource review](p08-measured-sizing-independent-resource-review.md)
PASS verifies the lower bound and supports stopping costly broader validation. No source/decoder/limit change or compiler execution occurred here.

## Exact current evidence

At `09ca9e0a`, the registered fresh focused screen passed all 25 selected checks,
including strict layout, and left 202 compiler controls not-run. Focused-passed is
true; collection-complete and aggregate passed remain false. The exact 129 target
roots establish cursor 34,713, maximum alignment 8, slot 34,720 and full four-slot
138,880 charge; current Swift/C agree. This removes the old undersized-backing
qualifier from the prior stack analysis.

[Receipt manifest](measured-sizing-stack-preflight/receipt-manifest.json) and
[compressed actual screen](measured-sizing-stack-preflight/actual-screen.tar.xz)
preserve commands, compiler/source identities, logs and layout. SHA-256 values:

| Artifact | SHA-256 |
| --- | --- |
| Current `P08CounterRuntime.o` | `dd12ac00c0d5558e18b9ad1afc975a44c321a04eada6773723c82030cb105ea7` |
| Build receipt | `4d4ea1191b78757eedb4cfac03e7e5f8fa45fabf5887edd93d6223660fe186c5` |
| Strict layout | `e1a4e17f0cd6ff41e6688a97138931c6b11a8c9c4a3b7005afd8707550005254` |
| Screen wrapper | `8dc806d7536278951fe5f5429979974f6abb1fe08b0b41c34231c3ac869b861e` |

[Source identities](measured-sizing-stack-preflight/source-identities.json) match
the current receipt for each Swift source used in the path. [Packet hashes](measured-sizing-stack-preflight/packet-hashes.json)
pin bounded function disassemblies, exact prologues and relocation records. No
whole-module disassembly or new target probe was generated in this step.

## One simultaneous required stale-action path

[Proof ledger](measured-sizing-stack-preflight/required-RAM-lower-bound.json)
records actual ET_REL sections, symbol-table/index identities, call offsets and
the source-scoped callback map. [Bounded frames](measured-sizing-stack-preflight/bounded-frames.json)
include raw prologues; `sub`, `sub.w` and `subw` are all charged. Each referenced
`section-N.txt.xz` contains its exact current objdump command's disassembly.

| Counted function / section | Stack bytes |
| --- | ---: |
| Selected static reservation, reuse specialization /3829 | 11,680 |
| Two-host reuse closure /3938 | 11,872 |
| Static session phase /3869 | 12,664 |
| Static host phase /3861 | 1,528 |
| Reuse host specialization /3760 | 2,680 |
| Old-origin rejection /3720 | 9,136 |
| Stale-action check /3672 | 8,552 |
| Full fingerprint match /3637 | 5,208 |
| Full fingerprint initialization /3617 | 7,768 |
| **Required stack lower bound** | **71,088** |

Factory 3829 directly calls reuse closure 3938 at offset 442. The closure's second
`runP08StaticHost` realization calls `counterForeignJoinScope` at 654 and retains
its frame for later same-inventory/retirement/destruction checks. The callback
address relocation at 864 selects exact forwarder 12628, through 11294/11305 to
body 3903. [Callback evidence](measured-sizing-stack-preflight/callback-link-evidence.json)
binds these actual identities; the foreign lender contains the indirect callback
invocation. Source `CounterHostProbe.swift:168` makes that callback synchronous.

`CounterScopedStorage.swift:2115` then nests original root, semantic, canvas and
storage loans. Their concrete callback references are 3903→10992→3911,
3911→11309→3918, and 3918→11313→3922; their literal relocation/call offsets are
in the ledger. Body 3922 directly calls session 3869 at 204. These lender and
forwarder frames are deliberately **omitted**, not presumed zero. The two counted
outer callers remain live across these loans; neither is a tail replacement.

Session early=0 reaches host phase while retaining lexical host/deferred teardown.
Nonnil reuse selects the reuse path; transcript.hosts==1 on the second host selects
old-origin rejection. Its stale-action call is unconditional. Direct BL edges
3869→3861→3760→3720→3672→3637→3617 preserve their caller homes. The fingerprint
match's initialization is charged separately from its later equality branch;
mutually exclusive calls or repeated checks are not summed.

## Disposition and remaining decision

138,880 + 71,088 = 209,968 > 196,608, even assigning zero bytes to every omitted
cost. Thus the earlier conditional maximum stack 53,632 (using old other-RAM costs)
is also exceeded, by 17,456. No old image RAM number is presented as current. The
current exact ELF, complete main/IRQ upper bounds, other construction/current-action/
teardown maxima, allocator reachability and timing remain unproved; none can reduce
this required lower bound. The existing recipe links the compiled object; no new
LTO, flags, workload separation or elimination assumption is introduced.

After independent proof review, stop the expensive full 202 controls/image for this
source under unchanged resource ceilings: they cannot establish acceptance. The
tooling/sizing work was productive and corrections remain **0/2**; those unused
cycles do not authorize representation optimization or resource relaxation. Prior
closed budgets remain closed. P08/R07/T8.1/HC-RD-003 remain blocked.

The next decision is about physical realization or the resource contract, rather
than another stack-only adjustment. Concrete remaining homes are the 11,680-byte
factory and 11,872-byte full reuse closure plus owned baseline/match/init homes
9,136/8,552/5,208/7,768. A separately reviewed realization package could target
those retained whole-value observations/construction homes while preserving every
field, identity, 64-record comparison and cleanup obligation. Alternatively, a RAM
ceiling/workload decision would require explicit authority and fresh complete
costs; this report recommends no new numeric ceiling, hidden allocation, dropped
coverage or automatic source variant.

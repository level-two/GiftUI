# R07 backing realization result — 2026-10-13

[Independent backing-result review](independent-review.md) atc3eda302 accepts
the narrowed route/link evidence and rejects actual nested stack fit. It
identifies residual supplied/owner/optional-host aggregate moves and prescribes
one fixture-only inout phase split with exact lifetime, file and validation
limits. Compiler realization/whole nested fit remain unproved; no source edit
or build ran in that review. All historical budgets stay closed, P08/R07 open.

**Supported nRF link PASS; actual nested gross-stack FAIL. STOP for separate
Strong result review. P08/R07/T8.1/HC-RD-003 remain open.** This is execution
evidence, not independent acceptance of the implementation or package exit.

Reviewed direction71c833a9, design19d07b6e and source38ba440d implement explicit
caller backing without changing the workload, capacities, stack/heap limits,
portable owners, compiler, recipes or runtime. Resume dispatchf376a81c continued
fromf1c7eccb after the recorded selected-model interruption; no native reruns,
model substitution, source repair or guard reset occurred.

| Current source route | Result | Evidence |
| --- | --- | --- |
| macos-static | exit0;1,349,555 assertions/zero failures;24/24 | [invocation](native-invocation.json), [receipt](macos-static/result.json) |
| macos-dynamic | exit0;1,349,501 assertions/zero failures;24/24 | [invocation](macos-dynamic-invocation.json), [receipt](macos-dynamic/result.json) |
| raspberry-pi-armv6 | exit0;28/28;221matching inputs; compilation only | [invocation](raspberry-pi-armv6-invocation.json), [receipt](raspberry-pi-armv6/result.json) |
| nrf52840-embedded | exit0;26/26;208matching inputs; compilation only | [invocation](nrf52840-embedded-invocation.json), [receipt](nrf52840-embedded/result.json) |

Both native194-input receipts still match current source. Pi/nRF refreshed once
sequentially; commits7dbc69a8 and2baf059e preserve their outcomes. No target was
executed. Existing Pi linked-image evidence predates38ba440d; this continuation
makes no new current-source Pi image claim.

The one [supported firmware invocation](firmware-invocation.json) uses fresh
`.build/nrf52840/contracts/p08-counter-bpvu3ztk` and actually exits0. Final emitted
ELF/HEX/map/DTS paths, hashes,361object/archive identities, source handoff,
compiler commands, scripts/config and reports are preserved adjacent. Current
ELF is `.build/nrf52840/signal-analyzer-static/rfc014-counter-firmware/zephyr/zephyr.elf`.

[Linked checks](linked-image-summary.json): ARMv7E-M/VFP pass; flash298932 of1048576,
RAM152320 of196608, configured heap0/mainstack27648/ISR2048. Caller BSS is exactly
120704bytes at0x20000330–0x2001dab0 (four30176-byte slots). GOT20bytes at
0x48cec–0x48d00 precede ROM accounting end0x80000; VMA=LMA flash. Twelve zero
header bytes precede Thumb refs swift_setDeallocating0x26927 and
swift_initStackObject0x405. Initialized RAM copy begins at LMA0x48d00, after
GOT; no remaining ELF relocations. No malloc/calloc/realloc/aligned_alloc or
k_malloc/k_calloc/k_realloc FUNC symbols. Existing Swift allocation thunks
remain, and posix_memalign returns12; swift_allocObject traps on null. Heap0
is not dynamic proof that every path avoids allocation.

[Exact linked stack failure](gross-stack.json), with [full relevant bodies and
root attribution](linked-host-stack-attribution.txt): main0x21608 calls C entry
0x44192, which tail-branches to Swift entry0x215c8. That entry calls graph0x211c8
then host0x19474 sequentially. Graph local frame is2248; host base3968 plus at
most15bytes dynamic alignment. Final profile initialization is19848bytes;
these differ from provisional route-object measurements.

The selected host's nested control closure at0x17bd0 is named inside
CounterEmbeddedProfileStorage.runCounterHost. Its semantic-body caller has
actual branches at0x17b22/0x17ba6 to that closure. The linked prologue saves
32bytes and subtracts71680+496: **72208local bytes, exceeding27648 by44560**
before any caller/descendant/IRQ overlap. This alone establishes no fit. Root
frames improving does not establish a viable stack. Graph/host sequential
frames are not summed; no complete P11 peak audit or dynamic watermark is
claimed. The compiler cause of this remaining large closure is unresolved.

No further compiler/build variant or source repair followed the failure.
Historical helper2/2, B031/1, GOT diagnostic1/1 and earlier image1/1 remain
closed; this backing slice's single supported image invocation is consumed.
The two-consecutive-unproductive-repair rule is preserved, not reset or
silently declared exhausted. Separate Strong review must assess the exact
remaining closure and any smallest contract-supported continuation. SPEC-015
remains implementing and its plan active; P09–P12 and hardware are untouched.

Independent678e5880 accepts the narrowed evidence and authorizes a candidate
fixture phase split. Pre-edit analysis then found required Static escape-test
generator maintenance outside that one-file handoff. [Exact finding and proposed
seam](phase-split/seam-finding.md) is stopped for separate Strong review. No
source edit, compiler/check/build invocation, guard reset or human contract gate.

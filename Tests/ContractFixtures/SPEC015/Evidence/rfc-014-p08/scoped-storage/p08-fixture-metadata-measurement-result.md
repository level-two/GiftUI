# P08 fixture metadata measurement — source-readiness handoff

**Diagnostic PASS, not P08 acceptance.** The one authorized existing-module
compilation at `7e6a7ae4` exited 0 in about 24 seconds; unchanged strict constant
decoding proved 31/31 roots. No source implementation, link, runtime or image ran.
The [design](../../../../../../docs/implementation-designs/spec-015-p08-fixture-metadata-scratch.md)
now includes the measured ledger and concrete source/validation boundary, ready
for implementation after [independent measurement/readiness PASS](p08-fixture-metadata-independent-measurement-readiness-review.md)
at `c35f541a`; no fit or contract change is inferred.

| Existing object | Size / stride / alignment | Offset / full-stride end |
| --- | --- | --- |
| P08EmbeddedOuter | 776 /776 /4 | 0 /776 |
| P08TypedBackingOwner | 1006 /1008 /8 | 776 /1784 |
| P08ReuseFingerprint | 5188 /5192 /8 | 1784 /6976 |
| InlineArray14 original inventory | 392 /392 /4 | 6976 /7368 |
| P08HostReuseTranscript | 600 /600 /8 | 7368 /7968 |
| Foreign observable root | 810 /812 /4 | 7968 /8780 |
| Foreign CounterControl | 6920 /6920 /8 | 8784 /15704 |

Every count is 1. Independent checked roundup reproduces all seven offsets,
cursor 15,704, maximum alignment 8, rounded extent 15,704. The four-byte gap before
foreign control is included, and donor tail padding is 19,016. All four original
slots remain fully charged: 4×34,720=138,880. The 15,704 metadata bytes occupy part of one
already-charged donor slot.
The finite active/donor map, including surplus active S0+S1 with donor S3, is
unchanged. No guessed extent or uninitialized object was used in this diagnostic.

The measured fingerprint is the **existing** complete owned baseline. A proposed
mutable/linear noncopyable baseline can change its type layout; final seven-object
target facts must be remeasured from actual implementation types. Caller-stack
custody/phase/prefix bytes and cold constructor temporaries are outside this pack.
Neither donor fit nor scalar folding proves source borrowing, stack reduction,
complete resource fit or behavior. The current source's 71,088 stack lower bound and
138,880 backing rejection remain in force until replaced by actual current evidence.

The [immutable execution packet](fixture-metadata-layout-diagnostic/measurement-result.json)
pins the archive entries and binary hash. The compressed facts retain actual
root binding/visibility/table/index, body/tail/relocation proofs and decoded values:

- Object SHA256:`96554585cba9c08fb9071e67e674ed61453f4502ac8713120c6ec952fafdcd7f`.
- Uncompressed facts SHA256:`1b696467d75eb3ec7d80ba6b0e8444895989c308ea032cebc6faa19ad4907211`.
- Diagnostic result SHA256:`8f3b93a3cc7d83b487a6d591261e191449385699bc349d9901f35acdcec3352f`.
- Wrapper result SHA256:`058f9fca908a9904e92cfa2e68bbf82621aa4e8c6317d51d2fa836e81541b195`.

Objects stay under `.build/nrf52840/p08-fixture-metadata-layout-diagnostic/`;
`execution-receipts.tar.xz` preserves the exact compiler argv/invocation and wrapper
receipts/logs; stdout/stderr are empty. The original prepared packet remains
unchanged. Documentary validation rechecked hashes, archived bytes, 31 roots and
all checked packing arithmetic; no extra compiler invocation or decoder variant.

Under the continuing user authorization, the next **new**, separately recorded
internal implementation package is one grouped initial candidate plus at most two
cause-grouped corrective cycles, stop after two consecutive unproductive cycles
or a genuine contract/resource decision. Proposed correction count 0/2; no source
candidate yet. Historical closed budgets and the consumed diagnostic 1/1 remain
closed. Independent readiness review precedes source; independent source review
precedes execution. This adds no human microapproval barrier for routine internal
work and authorizes no limit, ownership contract, capacity or workload change.

P08 remains blocked. Next proof is source realization with typed disjoint loans,
full single-baseline comparisons, complete prefix/backing-last cleanup and final
metadata measurement; then early focused nRF stack rejection screening and Native
borrow controls before any expensive full required coverage/image work.

# Independent backing-result review — 2026-10-13

Reviewed cleanc3eda302/source38ba440d, sequential Sol6.1 High / Strong.
**Accept the narrowed route/link/backing evidence; reject R07 stack fit. One
fixture-only phase-split correction is supported as a candidate local
realization, not proven compiler or image feasibility.** No compile, link,
test, variant, source edit or hardware action ran in this review.

The four receipts record native1,349,555/1,349,501, Pi28/28 and nRF26/26;
target receipts are compilation only. Final supported image records VFP,
GOT20, heap0, flash298932 and RAM152320, including caller BSS120704. Retain
the allocation-thunk/refusal-stub qualification and historical Pi-image
applicability. These results do not establish counter stack safety or P08 exit.

## Exact residual mechanism

The preserved linked root calls graph0x211c8 and host0x19474 sequentially.
The semantic-body branches0x17b22/0x17ba6 reach the named control closure
0x17bd0 inside `CounterEmbeddedProfileStorage.runCounterHost`. Its prologue
saves32bytes and reserves71680+496:72208local bytes, already44560 over27648.
The improved graph2248, host3968(+alignment), and initializer19848 do not
replace this actual nested frame or form a complete peak bound.

Source identifies remaining aggregate ownership which the BSS change did not
remove. `CounterHostProbe.swift` takes the2412-byte owned interaction state
from its slot into `keys`, then moves it and owned geometry into `supplied`,
`CounterHostOwner` and finally the optional/full preset host. `CounterHostState`
still holds supplied/active/retired aggregate payloads. Its active pipeline
contains inline interaction, geometry and complete-identity values. The six
rejected-binding proposals and full host activation/corpus/teardown all occupy
the same nested source closure.

Linked instructions corroborate residual aggregate materialization: the
control closure calls the outlined `CounterHostState` enum-tag-store at0x160e8
and repeatedly copies state/host-sized values, including an explicit7284-byte
memcpy beginning at0x17df2. This is not another full30176-byte profile returned
from the BSS initializer. The exact72208bytes cannot be assigned one-to-one to
source variables from this packet; repeated owned/optional/enum temporaries
are a supported mechanism, not a complete compiler allocation explanation.
No unsupported claim of optimizer defect or lifetime-contract impossibility.

## One bounded correction and validation

SPEC-015 permits bounded caller-owned/inline storage and scoped host/profile
backing. It does not require these finite checks to share a single generated
function frame. Private fixture helper boundaries which borrow existing scopes
and mutate the same owner/host in place are local realization under current
authorization. No human contract gate is required. Moving a nonescapable host
into raw persistent memory or erasing its borrow dependencies is not an
acceptable shortcut.

Before edits, append the exact phase/argument/live-interval map to the existing
receipt. Allowed edit scope is `CounterHostProbe.swift` only; a single coherent
shape, preserving this order inside the existing model→semantic→Canvas→
geometry→control scopes:

1. Construct the same supplied state and owner once. Call a private
   `counterCheckRejectedBindings` helper taking **inout** `CounterHostOwner`,
   borrowed canonical/foreign model and root scopes, both control pointers,
   immutable audit/report and expected snapshots. Move the existing six
   proposals and their exact assertions/count into it, without consuming,
   reconstructing or returning the owner. Keep the same failed proposal order
   and unchanged-owner/snapshot checks.
2. Construct the same selected preset host through its existing factory. Call
   a private `counterRunHostLifecycle` helper taking **inout** that host, the
   same control pointer, immutable report/failure selectors and accumulated
   check count. Move existing valid-state/pre-activation, activation/failure,
   paced opportunity, corpus, repeated-activation, teardown, stopped-admission
   and input assertions into it in their existing order. Return only the small
   count; no host/owner/supplied value returned through another aggregate.
3. Mark these two private helpers `@inline(never)` to make this chosen source
   lifetime/frame boundary explicit. This single fixture implementation choice
   is not a compiler-flag change or a license for an attribute/optimization
   sweep. No portable owner or `CounterHostOwner.swift` change in this slice.
   If existing lifetime rules reject the proposed inout/borrow signatures,
   preserve that exact result and stop; do not widen signatures or erase
   dependencies to make compilation pass.

Both helpers execute entirely within the original enclosing borrows and
activation backing lifetime. Keep foreign backing live, all logical profile
instances/IDs and BSS slots unchanged; no alias, scratch-bank repurposing,
earlier deinitialization, shortened read lifetime, omitted assertion, corpus
reduction, additional heap/BSS, ABI/recipe/GOT/flag or capacity change. Source
helper separation alone does not prove that Swift avoids the same temporaries
or that their caller/callee frames no longer overlap beyond the stack limit.

Budget: **one mapped source correction, one current native-Static gate, fresh
affected four-route receipts, and one supported nRF image validation; zero
automatic follow-on repairs or compiler/link variants.** Format first, capture
all exits and source/receipt/output identities, and stop for separate Strong
review after any failure or the linked result. No unchanged native rerun before
the source step. Refresh source receipts through existing unchanged checkers;
do not silently relabel prior results current. P09–P12 untouched.

Expected outcome is identical corpus/assertion/negative behavior with the same
owner and host mutated through each phase. Inspect final actual calls and
prologues for both helpers, construction, enclosing closures, initialization
and selected corpus/click paths. A reduced72208frame or each local frame below
27648 is insufficient: account the feasible nested caller/callee live frames,
alignment and applicable IRQ overlap against unchanged27648, with RAM196608,
flash1048576 and heap0. This remains a finite P08 gross-fit gate, not a broad
P11 audit. If inconclusive or still failing, preserve the evidence and obtain
independent disposition before any further implementation; do not infer a need
to relax the contract solely from this candidate's failure.

The first backing correction narrowed root/profile placement and exposed a
different nested aggregate frame. That is productive narrowing, not two
consecutive unproductive same-blocker repairs. The package stop rule stays
active; no count is reset. Historical helper2/2+B031/1, GOT diagnostic1/1 and
earlier supported-image/backing-image1/1 allowances remain closed. No hardware
or target execution. SPEC-015 implementing/plan active; R07/P08/T8.1 open.

# P08 structured operations — initial result and grouped correction approach

**Focused behavior/layout PASS; current main-stack rejection.** Source `3065c574`,
independent SOURCE PASS `c966aa8b`, exact three-profile checkpoint `6863f491`.
Correction0/2; the [independent result and approach review](p08-structured-operations-initial-independent-result-review.md)
confirms the main-stack rejection and correction1 APPROACH PASS at `678b7f7d`.
Ready for the authorized grouped source correction; not implemented in this result.
Historical allowances remain closed.

[Focused receipts](structured-operations-initial-collections/result.json) preserve
nRF25pass/202notrun and Dynamic/Static42pass/384notrun. All13 reuse labels,5
exclusivity and2 projection controls pass per Native route;3,472,564 assertions,
zero failures. focused_passed=true, collection_complete=false, passed=false.
The160 strict current facts preserve active34713/alignment8, four34720 slots,
138880 retained, final metadata15760/alignment8 and18960 unused donor tail.

The [current bounded object proof](structured-operations-initial-screen/result.json)
pins object `00dac6a4094135eed22d7f693c20c1fa9afaf65ea8c8b552978b843f744d30d5`
and every archived prologue/relocation/selected full-section dump. Fixed decrements
include SUBW. These are entry lower bounds, not complete stack/IRQ bounds.

| Required selected second-host path | Section | Entry bytes |
| --- | ---: | ---: |
| Two-host case → one-host operation |4242 /4273|4632 +8336|
| Main root lender → root body → semantic lender/body → scoped body |210 /4006 /10345 /4013 /4017|520 +1104 +520 +1056 +336|
| Live session → host phase → reuse → stale origins |3975 /3952 /3875 /3835|3824 +1528 +2688 +6072|
| Sensitivity → fingerprint → runtime field → slot match |3752 /3740 /3704 /3708|16 +2328 +8 +2920|
| Endpoint suffix → actual recording match |7411 /6731|656 +200|
| **Conservative required subset** ||**36744**|

The second host is required by the original `.twoHosts` branch and transcript
hosts==1. Its initial sensitivity full match traverses the captured current
endpoint/recording before any mutation. Source `runP08StaticHost` retains original
root→semantic→canvas→withStorage callbacks. Object4273 calls root lender210; its
callback thunk13852/14131/11982/12087 reaches4006. Semantic lender10345 calls the
provided12301→4013 callback; scoped body12305→4017 calls3975. BL/BLX have returning
continuations and teardown/retirement follows them. The main lender210 BLX atc8
and semantic10345 BLX at344/3ee retain their frames.4017 calls3975 atd0 then common
completion;3975 calls host3952 at16e.3952→3875→3835→3752→3740→3704→3708→7411→6731
are exact relocation/source edges.4242 uses outlined15842, which preserves the
original return link and tail-branches to4273; it does not remove4242's frame.

Omitted outer/corpus/custody/dispatch, withStorage3441's3056, callback thunks,
additional callees, alignment and IRQ are additional, never zero. Already36744
exceeds main27648 by9096. Backing plus this subset175624 leaves20984 under total
RAM196608, **not a fit/upper-bound certificate**. Unlike the previous rejection,
this subset alone does not disprove total RAM. Main still rejects the candidate.
No full202 collection/image is justified before the remaining source cause is handled.

The intended reductions are real: two-host21968→4632; session12664→3824;
sensitivity9208→16; runtime-field2672→8; recording-field whole operand copies are
replaced by8+200. Constructor3960=8408 returns from3975's BL atb2 before live host
BL16e; construction is not nested into reuse. Required cold selected construction
is still28736 before deeper callees. Separate reconstruction
4242→4277→3891→3501 is4632+976+15088+10120=30816. Cold/live alternatives are not summed.
Cleanup remains unbounded: tryClear4122 alone9024 and original teardown paths still
require it. Native passing cleanup controls are functional evidence, not stack proof.

Concrete remaining materialization is archived: origins3835 copies224-byte old
action and206-byte event into two homes, then at16e/174 copies2128 bytes before
borrowed-host stale-action handler3787. Control.tryClear4122 explicitly loads6920
at9a, calls copy helper15083 ata2, then borrowing vacancy guard3509 ata8. Fresh/
retired guard callers reserve8864/8520; the slot match still reserves2920 around
backend/key/borrowed health facts. Attribution of every byte is not proved.

## Proposed grouped correction1 — source mechanisms, not attribute retries

1. **Original-pointer scalar guards.** In `CounterPipelineOwner`, make the
   vacancy/claim/provenance checks concrete operations reading named fields of the
   actual Control pointer, returning owned facts/Void. Keep the exact7 vacancy
   predicates,4 claim predicates, full owner/origin equality, order and failure
   conditions. Shared owned-Boolean evaluation can serve internal mutating-self
   calls without forwarding whole borrowed Control. No whole Control inout or new
   capability getter may span endpoint/admission/model reentry. This targets the
   observed6920 copy and common construction/quiescence/cleanup callers together.
2. **Original host formal.** Make the finite readonly host observation/action
   operations and stale-action coordinator use the existing inout host formal,
   preserving logical read-only host state and every original immutable action,
   preparation/delivery/model effect and short-circuit. This targets the explicit
   2128 argument copy rather than changing mandatory HostState or stored owners.
   A host owner getter/protocol dispatch may still materialize: measure it.
3. **Finite owned health field operation.** Preserve prefix→health→suffix and
   health's actual endpoint target source, including a misrouted endpoint's target.
   A concrete static operation may read the named installed endpoint target's
   Control.backend.health outside all endpoint loans, returning only owned health.
   Prove the existing Native/Tiled delegate chain (`actual.health→sink.health→`
   `target.health`, Tiled additionally session.health) and preserve actual target
   pointer; never substitute the enclosing Control's health by assumption. This
   avoids passing a complete endpoint to a borrowing health method and retains
   the present disjoint loan map. All full key/backend/record comparisons remain.
4. **Cold caller/reconstruction extent.** Move pure audit/configuration/scheduler
   compatibility validation into a concrete cold preparation operation that
   finishes before original lender callbacks, returning only existing owned
   audit/assembly/check facts. Preserve every invalid-config check/normal result;
   verify purity before reordering relative to foreign scope establishment.
   Reconstruct root/semantic/canvas/Control in finite typed per-object operations
   returning between initializations; keep exact pre-retired/vacant checks,
   deinitialize order, same original addresses/namespaces and final fresh check.
   No uninitialized aggregate trick, changed donor role or extra retained object.

Bounded files: `CounterScopedStorage.swift`, `CounterPipelineOwner.swift`,
`CounterNativeRaster.swift`, `CounterTiledRaster.swift`; only mechanical actual
pointer-query callers in `CounterAdmission.swift`, `CounterApplication.swift` and
`CounterCoordinatorProbe.swift` if required by the same primitive. No core protocol,
mandatory ownership/lifetime/state type, physical inventory, capacity, limit,
flags/toolchain,64 entries/four keys, corpus or label change. Any extra access seam
must be reported precisely. Additional changed inputs must be checked against all
seven actual component argv; rebuild actual compiled dependencies rather than
extend metadata qualification by assumption.

Independent approach review precedes correction1 source. It must cover host loan
reentry, actual-target health provenance, shared scalar guard field parity, pure
cold-check ordering and constructor/cleanup bounds. Then one coherent source pass,
independent SOURCE review and the same three fresh commands collect failures
together. Fresh160 facts/Native complete controls and exact cold/live/cleanup
paths must pass unchanged main27648, with omitted ancestors/IRQ charged, before
full current target controls/image. Even removing the selected9096 excess alone
is insufficient; omitted costs remain. These concrete copy/caller targets offer
no numerical savings or fit guarantee. No source change or compiler/runtime ran
in this analysis. The next step is reviewed correction1 within the current user
allowance, not a limit increase or another blind annotation variant.

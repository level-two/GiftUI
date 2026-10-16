# P08 constructor/caller correction1 result and final correction proposal

**All three focused collections PASS; required cold main-stack lower bound FAIL.**
[Independent result/final correction 2 APPROACH PASS](p08-constructor-caller-cycle1-independent-result-review.md)
confirms the rejecting subset and permits the authorized final grouped source pass.
The review distinguishes plausible destination lifetime syntax and invariant guard
extraction from unproved compiler acceptance, destructor lowering and savings.
Source `42c0a1e2`, SOURCE review `2604ff64`. Initial1/correction1/2; one final
grouped correction remains. The proposal below is not implemented or consumed.
No source/compiler/runtime/image operation was added by this read-only assessment.
Historical closed allowances and main27648/RAM196608/four34720 slots stay unchanged.

## Current receipts and required path

The [receipt manifest](constructor-caller-cycle1-collections/result.json), SHA256
`f67684cf96eb9f2e85f4d46afd1d49c7fb18b6c9db095b51091c4b65e2edb4ee`,
pins actual commands/inputs/logs in the compressed packet. nRF passes25 with202
not run; Dynamic/Static each pass42 with384 not run and all23 selected observations,
including all13 reuse labels/five exclusivity/two projection controls. Native
assertions are1,736,244/1,736,320, total3,472,564, zero failures. All three are
fresh-focused/focused-passed; collection_complete=false/passed=false. There is no
current functional or compilation failure and no full-acceptance claim.

All160 strict roots pass: active cursor34713/alignment8,34720×4=138880;
metadata16584/donor tail18136/additional retained0. Current object
`.build/nrf52840/contracts/p08-counter-2ro_jkcy/P08CounterRuntime.o` SHA256:
`e4cc6cf4a6bc9db0866af3a52f8a251f0599bd48d9a61183c4bbe17cce444fd6`.
The [bounded analysis manifest](constructor-caller-cycle1-analysis-manifest.json)
pins exact sections/symbol-table indices/prologues/relocations/commands and complete
trust-critical bodies in the analysis packet, SHA256
`61766308b315613594fe46aee879c6d727ea1bd9a2ac96c66b8d1e64b2ae6568`.

| Simultaneously retained source operation / current section | Fixed entry bytes |
|---|---:|
| two-host4269 →one-host4281 →prepared4029 | 5288+144+2112 |
| original model lender210 →root body4037 | 520+1104 |
| semantic lender10407 →body4044 | 520+1056 |
| owner.withStorage3433 →scoped callback4048 | 2848+336 |
| session3994 →cold constructor3983 →actual nRF factory3990 | 3824+9328+3360 |
| **Selected required cold lower bound** | **30440** |

This exceeds27648 by2792 before outer/corpus/custody/dispatch, original bank-loan
callbacks/forwarders, deeper factory callees, further alignment and IRQ. Prepared
4029 additionally rounds SP down to16-byte alignment using BFC/mov-SP (0–15 bytes);
the fixed parser does not count that extra reduction. This is a rejecting lower
bound, not a complete upper bound. No total-RAM failure is inferred from
138880+30440=169320, and no current image was built.

Direct BL relocation sites:4269+114/200→4281,4281+236→4029,4029+388→210,
4037+460→10407,4044+240→3433,4048+204→3994,3994+172→3983,
3983+1584/0x630→3990. The actual callback literals are **R_ARM_REL32/type3**:
4029+608→12080→12084→4037,4037+540→12371→4044,
4044+308→12375→4048. The forwarding BLs and PC-relative formation are archived.
Canvas and all fourteen actual bank loans intervene before the scoped callback;
their additional frames are not replaced by a fictional direct3433→4048 call.
Alternative foreign body4033/semantic implementation10411 are excluded.

The two-host default early0/no candidate-failure workload reaches this factory.
Current3994 calls3983 while retaining its preallocated Optional host destination;
3983 calls the factory then branches to a common output-copy epilogue before
restoring SP. Original host use/defer/root shutdown/reconstruction and second-host
inventory checks follow, so caller reservations have not returned. Preparation3429,
installer4301 and join checker3975 have returned before this factory call; live
host/reuse operations begin afterward and are not added to this cold path. Frame
arithmetic includes SUBW:3983=36+9280+12,3994=32+3792. The selected live counterpart
is26512 before omitted callbacks/outer/IRQ, **not a live fit result**.

## What changed, and the remaining actual materializations

The scoped callback shrank960→336 and live session9488→3824. Private noncopyability
preserves the exact source ownership constraints but did **not** remove physical
plan operations: clear3477 remains1656, copying818 current Optional bytes into a
tag-test home, constructing nil atSP+820 and copying818 back. Two-host remains5288,
prepared2112, reconstruction1800. The cold constructor is9328 (previous split8408),
so it still rejects after the successful live reduction.

Two distinct, bounded causes are visible in complete bodies:

* **Caller guard cleanup homes:** two-host4269's two missing-namespace branches
  lead to separate scratch locations (SP+36/SP+1632 and SP+2644/SP+4240). They copy
  the original owner and1596-byte outer, call their destructors, then trap. These
  alternative cleanup homes inflate the single5288-byte frame retained on the
  valid workload too. They are not four simultaneously executed destruction paths.
* **Cold construction ABI:**3983 copies1759 owner bytes to its factory argument
  home atSP+4824 (+0x622). The unchanged factory writes a2128-byte Optional host
  atSP+7160, and the common epilogue copies2128 bytes from there to the caller's
  indirect result (+0x304) before restoring SP. Complete report copies347 and
  audit228 also cross the configuration/join fixture seams; mandatory core owned
  fields remain real costs. This identifies actual transfer regions, not every
  byte of the9328 frame or proof that a source rewrite will elide them.

## Proposed final grouped correction2 — independent approach review first

Retain all successful metadata/compact loans/inout plan and the mandatory types,
actual preset factory, complete core owned values, all predicates/oracles and
scope/cleanup contracts. Proposed source remains CounterScopedStorage plus its
existing parity/qualification glue; no core API, resource limit or physical region
changes. Address these remaining seams together:

1. **Cold namespace check, same phase:** after the same
   `p08InitializeMetadataHostBacking(&owner)` call, obtain the same two nonoptional
   IDs from a private out-of-line checking operation. Move the exact `guard let
   secondModel, let secondSemantic else { preconditionFailure("second namespaces") }`
   there. To preserve the original failure cleanup rather than silently discard
   it, retain the actual `inout P08TypedBackingOwner`/`inout P08EmbeddedOuter`
   parameters in that cold operation; no ordinary-path read/mutation is added.
   It returns only the owned ID pair, no view/owner/capability/callback. Its
   failure/destructor scratch ends before the first host/root callback. The
   caller has no direct missing-ID branch requiring those large local homes.
   Preserve initialize→namespace validation→capture inventory→freshness→host order.
   The helper's own cold peak remains charged separately with its caller.
2. **Complete the cold inout plan seam:** configuration/check compatibility and
   Static/Dynamic full join wrappers receive the same actual `inout P08HostRunFacts`
   rather than owned audit/report fixture parameters. Their bodies still copy
   complete individual values into unchanged core validation/check APIs; two full
   join snapshots and all six checks remain inside the cold wrapper in exact order.
   Neither wrapper/argument homes remains live at the later factory/body. No
   backend/model route receives a plan reference or can reenter its field loan.
3. **One typed Optional destination, explicit dependence:** change the cold
   constructor's result placement, not the preset factory or ownership payload:

   ```swift
   @_lifetime(destination: copy session, copy semantic, copy values,
       copy models, copy root, borrow control, copy activationSpan)
   fileprivate func p08ConstructStaticHost(
       session: consuming P08StorageSession,
       semantic: consuming SemanticRecordStore<CounterPayload>,
       values: consuming CanvasStagedValues<SemanticRecordReference, CounterValueTable>,
       activationSpan: Span<UInt8>,
       models: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>,
       root: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>,
       foreignModels: borrowing ObservableModelScope<CounterOwnedModel, CounterModelSchema>,
       foreignRoot: borrowing ObservableStateRootScope<CounterOwnedModel, SemanticCompleteIdentity>,
       control: borrowing UnsafeMutablePointer<CounterControl>,
       foreignControl: UnsafeMutablePointer<CounterControl>,
       facts: inout P08HostRunFacts, failAfterRuntime: Bool, early: UInt8,
       destination: inout P08StaticHost?,
       completion: inout P08HostConstructionFacts
   ) { /* same cold transitions; destination = unchangedPresetFactory(...) */ }
   ```

   Dynamic uses its original exact analogous union/types/factory. The innermost
   original caller creates **one initialized-nil** Optional host, lends its actual
   field to this private one-call constructor, then uses/defer-tears down that same
   payload. No raw uninitialized storage, scoped pointer, synthetic lifetime or
   second logical owner. Early1/2/3 perform original reset/retirement/eight hooks,
   write the same owned completion and return with destination still nil. Ordinary
   construction assigns the actual factory result once; factory nil still takes
   the same invariant-failure disposition. The private source call-site contract
   is vacant destination, established by its initializer; no new aggregate-valued
   nil guard/return is added. All loans including the destination end before the
   original callbacks return, and plan clear/reconstruction remains after teardown.

   This names the **same complete original union on the mutated output** instead
   of suppressing a genuine dependence. Pinned Swift6.4 stdlib27602–27604 contains
   `@_lifetime(source: copy source)` on an inout parameter, and the old constructor
   compiles the full original union. Their source/hash excerpt is archived. The
   composite destination signature is **not compiled or proven accepted**; the
   approach reviewer must assess this concrete lifetime update and may BLOCK it.
   Assignment may still materialize a factory result or old-nil destructor home;
   no codegen saving is asserted from syntax alone.

For scale, candidate targets are the two-host cleanup homes (~5208), configuration
audit/report homes (~576), constructor join argument homes (~576) and the2128 local
return copy. If all materializations disappear, the selected30440 subset would be
21952, leaving5696 for **all** omitted costs. The ten measured callback representatives
sum4048 and four main forwarders600; that is a planning allowance, not proof that
all representatives form one route or bound every omitted callee. Even charging
that allowance leaves only1048 for outer/custody/deeper calls/alignment/IRQ. This
is explicitly **not fit evidence** and not permission to exclude those frames.
If the concrete destination lifetime cannot be realized under existing flags/
contracts, or actual complete paths retain insufficient headroom, report that
bounded obstruction; do not consume a final cycle on a smaller guard-only variant.

Source review must verify all early paths/actual field loans/whole union, the exact
namespace predicates/destruction/timing, one nil destination, complete full-state
comparisons/64 recordings/four keys/backend observations and all corpus/cleanup
coverage. After SOURCE PASS, collect the same three registered fresh focused
commands independently with a new exact qualification. Then measure complete
cold/live/cleanup/outer/original-callback paths, SUBW/alignments/REL32/tail semantics
and exception entry separately. IRQ/main accounting and total linked RAM remain
unknown; do not allocate an arbitrary allowance or infer upper-bound PASS from a
helper/subset. Only viable complete current paths justify full202/image. No source
correction2, test run, resource waiver or contract change was made here.

Correction1 was productive (compilation/selected behavior/layout pass and measured
scoped/live reduction), while resource rejection remains. No budget is reset.
Archive members match their SHA256 manifests. Governance passes (204 nodes/2036
edges;7 features/76 lifecycle artifacts/9 skills) and whitespace checks pass;
known unrelated pycache stays untouched.

# P08 donor metadata — final focused passes, resource rejection

**STOP: current focused behavior/layout PASS; required stack still fails RAM.**
Source `6449093d`, independent SOURCE PASS `dbb4cc5b`. Both corrective cycles are
consumed. The [independent exit review](p08-fixture-metadata-final-independent-review.md)
confirms the current resource FAIL and STOP; source, focused behavior and layout passes
do not establish P08 acceptance. No source variant, compiler, runtime, debugger, image or hardware execution
was performed during this read-only artifact analysis.

## Three current focused collections

[Immutable collection packet](fixture-metadata-cycle2-collections/result.json),
committed `a40009fe`, preserves the exact three wrapper/module receipts, commands,
logs and source/compiler/binary identities. All three have fresh_focused=true,
focused_passed=true, collection_complete=false, passed=false.

| Current build | Passed including preparation | Not run | Actual behavior |
| --- | ---: | ---: | --- |
| nRF `h1u9xtq0` | 25 | 202 | compiled module and all160 strict layout roots PASS; no target runtime |
| Dynamic `1pdo01gw` | 42 | 384 | all23 selected controls PASS;1,736,167 assertions,0 failures |
| Static `ua74pjq_` | 42 | 384 | all23 selected controls PASS;1,736,243 assertions,0 failures |

Both Native routes pass all13 reuse observations, all5 exclusivity controls and
both projection compiler controls. Combined actual Native assertions:3,472,410,
zero failures. The invalid-key trap is gone on these completed routes. These are
current functional successes, not a full compiler matrix or target fit pass.
No previous full collection or image is represented as current-source coverage.

Current nRF object SHA256
`dd79863da870e9b78fedbfd140d5b60d77f9da0cddf974da349a4c752384c257`;
module receipt `13ca84838686a79448e42c2ef1e94c400a4ccebb9e354e314103f20ec4a8d67c`;
accepted layout `bd047b0157ecac4c18ba438bd9ba5edab65d71303d28d8d2331a5015fd7be844`.
All129 active and31 final metadata roots strictly decode: active cursor34713,
alignment8,34720×4=138880 retained; metadata15760, donor tail18960, additional
retained storage0. Metadata is already included in the four slots, not charged twice.

## Required current stack lower bound

[Exact section/symbol/index, raw prologue, full critical-body and relocation packet](fixture-metadata-cycle2-screen/result.json)
pins the same current object. The bounded extraction reads named source areas,
not an executing target. Push/STMDB, SUB/SUB.W/**SUBW** are counted. Only fixed
entry decrements are included. Register-derived alignment and later allocations
are explicit omissions, never silently treated as an upper bound.

| Source-feasible second-host first-baseline-match path | ET_REL section | Fixed bytes |
| --- | ---: | ---: |
| `p08RunMetadataTwoHosts` | 4152 | 21968 |
| original static session phase | 3874 | 12664 |
| static host phase | 3866 | 1528 |
| reuse host | 3789 | 2688 |
| old-origin checks | 3749 | 6072 |
| full baseline sensitivity | 3666 | 9208 |
| full fingerprint match | 3654 | 4944 |
| runtime-slot field match | 3626 | 2672 |
| actual runtime-slot baseline match | 3630 | 4360 |
| **Required counted subset** | | **66104** |

The two-host case uses the same custody pair across both hosts and reconstructs
only after the first host returns quiescent. Its second `runP08StaticHost` retains
the original synchronous foreign/main-root→semantic→canvas→actual owner.withStorage
lenders. Actual object connectivity is preserved separately from source reasoning:
4152 calls root lender210@0x7e2 and references callback13698@0xa94;
13698 calls13938@0x2, whose bounded body tail-jumps11836@0xc;11836 calls11941@0x8,
which calls main-root body3916@0x108. That body calls semantic backing10203@0x1e6
and references adapter12155@0x238. Adapter12155 calls semantic body3923@0xc0;
3923 calls original owner.withStorage3441@0xf2 and references session adapter12159
@0x138;12159 calls session body3927@0xb8;3927 calls session3874@0xd0.
REL32 references alone are not calls: the existing synchronous lender/callback
source operations establish which referenced bodies are invoked. Their positive
frames are omitted from66104, not assumed absent or tail-eliminated.

The remaining chain is direct R_ARM_THM_CALL:3874→3866@0x6c8,3866→3789@0x1c,
3789→3749@0x6e,3749→3666@0x166,3666→3654@0x10,3654→3626@0x86,
3626→3630@0x1a. Nonnull transcript and hosts==1 select old-origin checks on the
second host. Sensitivity's first match follows once-only capture, before any
intentional mutation; full match calls its runtime-slot comparison first. No
mutually exclusive failure/current-action or already-returned cold frame is summed.

Full critical bodies show the counted frames remain live at those calls. In4152,
the36-byte saved-register push plus21888+44 fixed subtraction remain allocated.
Its register-derived initial alignment can add0…15. Before the second root loan,
0x752 saves SP;0x758 subtracts120,0x760 rounds down16,0x764 writes SP and0x7cc
subtracts8. The0x7e2 call occurs before restoration at0x7f0. These *additional*
bytes are excluded from66104. The helper13938 tail hop is not charged as an
additional frame; no caller frame counted in the table was inferred from that hop.
Sensitivity uses36+9152+20=9208 and restores only after its final match.

**138880+66104=204984 >196608 by8376**, before outer corpus/host/custody/dispatcher,
the listed lender/callback frames, other callee temporaries, alignment surplus,
other retained globals, IRQ or hardware costs. Main27648 is exceeded by38456.
Even dedicating *all* RAM left after required backing to stack leaves only57728,
already less than66104. A stack-budget-only increase cannot make this realization
fit the unchanged RAM ceiling. No current linked image or complete upper bound
is needed for this necessary-condition rejection, and neither is claimed.

## Effect and remaining physical causes

The intended coordinator reductions are visible: dispatcher4133 is64 versus the
old shared31776; prepare4067 is56 versus17456; destruction4099 is24 versus16944.
Separate cold construction still has real costs (outer init10352, its cold wrapper
928; baseline initializer8344, its wrapper5264; foreign Control init/deinit wrappers
6936). Cold frames returned before host execution are not added to the live path,
and those individual values do not establish a complete cold maximum.

The remaining live cost is concrete, not a request for another arbitrary attribute:

- `CounterScopedStorage.swift:3354` keeps two-host initialization, full inventory,
  inlined host construction/closures and reconstruction in the21968-byte leaf.
  Its exact per-field home attribution is not fully recovered; inout source syntax
  did not prove zero temporary construction. The original session at2352 still
  materializes12664 through its required owner/host construction chain.
- Sensitivity at1778 now retains9208 while exercising all four valid complete-key
  alternatives and64 recording probes. The earlier invalid ordinal had pruned
  this continuation, so the former tiny frame is not equivalent useful coverage.
  Key/observation temporaries share a live function frame; exact individual byte
  ownership within it is not asserted without further proof.
- The actual field seam at1598 still invokes borrowed
  `CounterRuntimeSlotBaseline.matches` (`CounterPipelineOwner.swift:991`). Section3626
  loads2652 at0x10 and calls outlined14754@0x14, whose sole target is
  `__aeabi_memcpy8`, before calling3630@0x1a. Thus a complete runtime-slot field
  is materialized on stack despite the enclosing actual inout baseline formal.
  This is compiler physical realization evidence, not a claim of a second logical
  owner or a violated noncopyable contract.
- Recording at1602 invokes `CounterRecordingObservation.matches` (pipeline842).
  Section3634 copies1148 bytes through14750→`__aeabi_memcpy4`, then projects the
  actual `control.pointee.lastFrame` and performs a further memcpy4 through14726
  before3638. Its2312 frame and the callee's2288 are real alternative comparison
  costs, not added to the runtime-slot branch in the table. Full match1703 remains
 4944; joins/semantic/admission finite leaves preserve all original fields.

The original complete baseline, exact four keys, backend facts, independent
lastFrame,64 entries, fourteen inventory objects, five banks/geometry, actual
original scopes, all48/2266 selections and8 additive prefix controls remain.
These source-backed copies identify what another ownership/materialization design
would need to address. They do not prove that another helper/attribute will fix it
or that accepted architecture must change.

## Package boundary

Correction2 was productive for compilation, complete focused Native behavior and
the planned coordinator reduction, but **resource fit FAIL**. Stop the expensive
current nRF202/full-image path: it cannot reverse this lower-bound contradiction.
No new compiler, source variant, limit change or automatic third correction follows.
Keep main27648/RAM196608 and the four original slots unchanged. A further structural
realization package would need an explicit evidence-grounded scope and review;
this result does not preapprove a design or require a contract amendment.

P08/R07/T8.1/HC-RD-003 and all nine SO acceptance criteria remain open. Current full
profile coverage, complete peak/IRQ/allocator/Dynamic accounting and current image
are unproved. I4-07/analyzer, P09–P12, hardware and timing residuals remain. All
historical stops/receipts and the current successful focused results are retained.

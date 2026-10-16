# P08 donor metadata — first compiled screen and Native collection handoff

**Compilation/layout PASS; resource rejection and an independent control defect.**
Source `3a1d1d32`, one fresh nRF screen, about60seconds. Result has25pass/202notrun,
focused_passed=true, collection_complete=false, passed=false. No runtime, image,
new compilation, source correction or hardware ran in this read-only assessment.

[Exact packet](fixture-metadata-initial-screen/result.json) archives module/wrapper
receipts, accepted/raw facts and logs. Object SHA256
`14c42d3063994718055d19747054b854b0485f80f8567dedc76cd7c8a763643d`;
accepted layout `118c6d22a9383fa813b4c211bea529515c8529e5f1ec6abbab446f823e380915`;
wrapper `940ef276a1da17bc120f2e4bd9e7d69acf74fe7f78182b9783b79d568a3456c3`.
All160 roots strictly prove: active cursor34713/alignment8,34720×4=138880 retained;
final metadata cursor/extent15760/alignment8, donor tail18960, additional retained0.
Baseline size5241/stride5248 replaces the old diagnostic's5188/5192; all other
measured types and four retained slots remain fully charged. This is current
compiled layout evidence, not stack/behavior/P08 acceptance.

## Bounded required stack rejection

Exact ET_REL sections/symbol-table identities, relocation calls and raw prologues
are in `bounded-frames-and-calls.json.xz` and `prologue-N.txt.xz`. The analysis
counts SUBW as well as SUB/SUB.W and saved-register pushes. These are fixed entry
**lower bounds**; register-derived alignment/later allocations are not silently
declared zero or certified as an upper bound.

| Required second-host first-baseline-match path, counted subset | Section | Bytes |
| --- | ---: | ---: |
| Embedded corpus | 4087 | 64 |
| Host cases | 4079 | 64 |
| Caller custody run | 4053 | 112 |
| Finite metadata case operation | 4057 | 31776 |
| Original static session phase | 3854 | 12664 |
| Host phase | 3846 | 1528 |
| Reuse host | 3769 | 2688 |
| Old-origin checks | 3729 | 8672 |
| Frozen baseline sensitivity | 3646 | 240 |
| Full fingerprint match | 3626 | 7904 |
| **Counted fixed lower bound** | | **65712** |

Caller connectivity is concrete: corpus calls host@76, host calls custody@124
for twoHosts; custody calls metadata case@388. The twoHosts branch executes both
hosts without releasing custody. Its nonnull transcript reaches session3854,
which calls host3846@1740; host calls reuse3769@28. The second transcript has
hosts==1, selecting oldOrigins3729@200. That helper calls sensitivity3646@314,
which calls its first match3626@8 **before** the independent invalid-key trap.

The intervening original synchronous foreign/main-root→semantic→canvas→actual
owner.withStorage lenders are still live. Their callback records are explicit:
case4057 references the runStaticHost adapters (e.g.13602), adapter→13834→11736→
11841→root-body3896; root-body carries semantic adapter12055→body3903, which calls
actual owner.withStorage3441 and carries adapter12059→session-body3907→session3854.
Root/semantic lender functions and these adapters have additional positive frames;
they are conservatively omitted from65712, not assumed absent. C-entry callers,
other indirect/callee frames, alignment surplus and IRQ are also unbounded here.
No mutually exclusive case frames or already-returned cold frames were summed.

Even this subset exceeds main27648 by38064. Backing138880+65712=204592 exceeds
RAM196608 by7984 **before** those omitted costs. This is another decisive object
rejection, not a complete maximum or image measurement. The prior71088 remains
historical; different counted subsets do not prove an exact5376 saving.
Cold prepare4019=17456 directly calls outer initializer3493=10352; corpus/scoped/
custody add64+96+112, giving28080 before deeper helpers. Cold destruction4023 is
16944; its outer/control cleanup is partly inlined, so outer-deinit6936 is not
added without a call edge. These cold and live paths never coexist.

## Additional defect and evidenced next correction scope

The new sensitivity function's four `fixedChild ordinal:31` probes violate
SemanticRuntimeRecords.swift's `ordinal<5` rule. Actual section3646 performs the
first root append and ends in UDF; section3729 ends in UDF immediately after that
call. Later stale/current continuation is compiler-pruned on this route. This is
not a valid successful corpus and no later action/cleanup path is claimed reached.
The bound above uses the earlier first-match path, not that unreachable continuation.
Bodies3646/3729 and their exact outlined append/memcpy helpers are preserved.

Actual oldOrigins@0x12e loads size5241; @0x132 calls outlined helper14813, which
tail-calls __aeabi_memcpy8, before sensitivity receives the stack address. Thus
the pointer-pointee borrowing call still materializes a complete baseline home.
The shared case function reserves31776 for every branch and contains independent
graph/host/early/failure/reuse/exchange bodies; cold prepare/destruction also share
large object temporaries. Match3626 still calls whole owned Optional join/semantic/
admission comparison witnesses and reserves7904. These are concrete remaining
homes, not proof that another arbitrary attribute would help.

One grouped correction2 remains, **not started**. Before choosing it, collect the
Native failures below. The evidenced candidate is finite per-case operation leaves
receiving actual typed inout/borrowing objects (no new consuming carriers), separate
cold per-object initialization/destruction calls, and a typed inout baseline entry
that loans a formal baseline rather than evaluating its pointer getter as a value.
Complete heavy field comparisons can use concrete borrowed operations instead of
whole-field value equality homes. Restore all four valid complete-key mutations
using the actual codec; retain every control, one frozen baseline, all cases/loans/
cleanup and slots. No fit saving is promised; the final codegen must be screened.
This is a preliminary cause bundle pending Native results and independent review,
not authorization for a third variant or a resource-limit change.

## Ready for Luna: two profile-matched fresh focused collections

[Exact argv/receipt pins/23 selected labels per profile](fixture-metadata-initial-screen/native-focused-handoff.json)
select runtime16 (link/execute/summary+13 reuse observations), native exclusivity5
and projection positive/negative2, plus fresh required preparation. Dynamic uses
the original **ezcy1qan macos-dynamic** host; Static uses **hzs5q7za macos-static**.
Matching compiler hashes alone do not justify substituting host recipes.

```sh
scripts/contracts/run-spec-015.sh --profile macos-dynamic --corpus rfc-014-counter --runtime-build .build/contracts/spec-013-runtime-cycle/tmpi1u8hyk5/macos-dynamic --host-build .build/contracts/p08-scoped-host-ezcy1qan --collect-failures --fresh-focused --select-family runtime --select-family so06-native-exclusivity --select-family control-resident-projection
```

```sh
scripts/contracts/run-spec-015.sh --profile macos-static --corpus rfc-014-counter --runtime-build .build/contracts/spec-013-runtime-cycle/tmpmynn4963/macos-static --host-build .build/contracts/p08-scoped-host-hzs5q7za --collect-failures --fresh-focused --select-family runtime --select-family so06-native-exclusivity --select-family control-resident-projection
```

Do not waive the known runtime trap. Collect independent exclusivity/projection
failures; blocked positives cannot validate negatives. Omitted base384 controls
remain notrun, and a focused pass is never aggregate success. No full nRF202 or
image is warranted for the currently rejected realization. Pause for these two
bounded runs; no correction2 source or new experiment was applied here.

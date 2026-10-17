# Matched Native allocation findings — 2026-10-17

**Measurement/replay PASS; current Native Static zero-heap criterion FAIL.**
All three fresh Static processes contain the same **11 allocations/336 requested
bytes (336 usable-reserved),112-byte simultaneous peak,64 bytes retained into
reuse** on actual first-use action/interaction runtime paths. Reuse adds zero
allocations for this subset. These are not a complete cold bound or an allocator
arena measurement. P08/R07/T8.1 remain open pending independent review and an
explicit contract-versus-implementation decision.

## Reproducible observation

[Compact packet manifest](native-allocation-attribution/manifest.json) freezes
33members in a1,798,780-byte archive, including six complete PC dictionaries,
exact full-path groups, summaries, commands, measured image/source identities and
all raw artifact hashes. Raw119–121MB event files/process and executables remain
unchanged in `.build/contracts/p08-native-allocation-matched-repair1-20261017/`;
wrapper is
`.build/contracts/p08-integrated-activity/20261017T014700636872Z-p08-native-allocation-matched-repair1/`.
The [read-only analyzer](native-allocation-attribution/analyze.py) requires those
exact images and rechecks the original artifact hashes before replaying attribution.
The [offline compact verifier](native-allocation-attribution/verify.py) verifies
member/analysis hashes and the11/336 subset without a compiler or workload run:

```sh
python3 -B Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-allocation-attribution/verify.py
```

All six processes have nonzero identical cold/reuse entry results: Dynamic
1,734,943 and Static1,735,019. All original event replays pass; saturation,
truncation, bad-chain, I/O, foreign-thread and allocator-failure flags are zero.
Max captured chain is137frames. The repaired observer is unchanged from
`cf0b8b57`; exact25object/201current-input guards/profile and qualified retained
runtime/host recipes remain intact. Neither observer capture nor replay calls
Swift in the window. Source/object identities are pinned; this analysis changes
no application code and performs no further matched execution.

Actual loaded Swift is `/usr/lib/swift/libswiftCore.dylib`, UUID
`83794fb3de9b3d23ab5e2c1d5d30f134`; allocator is system `libsystem_malloc`, UUID
`d969a9073e43395193658c2db3812e9d`. The compiler-bundled runtime is not a substitute.
Each process reports stack soft/pthread extent8,372,224bytes, hard67,092,480,
unblocked signals, default signal dispositions and disabled alternate stack.
These are host assumptions/inventory, not complete stack or physical-fit proof.

## Selected Static counterexample

The full captured path is `giftui_rfc014_counter_entry` → `p08CounterHost` →
original prepared Static session/host lifecycle → actual complete pipeline →
admission/gesture or dispatch → Swift witness/metadata cache → typed malloc.
[Full stacks and attribution](native-allocation-attribution/attribution.json.gz),
[readable totals](native-allocation-attribution/summary.json) and
[actual linked instructions](native-allocation-attribution/selected-static-codegen.txt)
retain exact PCs; [disassembly commands/image SHA](native-allocation-attribution/codegen-commands.json)
bind their addresses. Main-image PCs below are return offsets from its base;
all observed allocations use `malloc_type_malloc`, with16/48-byte requests.

| Actual first-use path | Return offset(s) | Count | Requested/usable bytes |
| --- | --- | ---: | ---: |
| `CounterPipelineOwner.admitAndSeal`, resolver witness | `0x138e2c` | 2 | 32 |
| `ExecutionGestureAdapter.down`, metadata/witness | `0x6e3dc`, `0x6e3f8` | 3 | 112 |
| `InteractionState`, metadata helpers | `0x71538`, `0x71548` | 2 | 96 |
| `CounterPipelineOwner.applyAdmittedWork`, witness | `0x1393b4` | 2 | 32 |
| `RuntimeRecordInteractionBridge.dispatch`, metadata | `0xa143c` | 2 | 64 |
| **Total, each Static repetition** | | **11** | **336** |

The linked admission call at `0x100138e28` binds via stub `0x10017527c` to
`swift_getWitnessTable` and feeds the actual gesture call; it precedes the
separate print-argument allocations. None of these11stacks contains print or
`counterTrace`. Seven allocations/272bytes are retired; four16-byte records
remain live (64bytes) after both windows. Subset peak is112usable bytes;
its transient-only peak is48. These annotations do not infer total cache capacity.

Two further cold allocations/96bytes in the selected host are explicitly
excluded from this rejecting subset: they initialize the independent
`counterHostCorpus` three-element input-array literal's type metadata.
Its buffer allocations and traced gesture/wake argument arrays/boxes are also
separately source/codegen identified. This corrects the preliminary13-event
classification; only11/336 are asserted as actual runtime-path evidence.

The route first runs common Static graph and scoped-storage/oracle work.
The common graph already accounts for952cold metadata/witness events, including
an actual `StaticObservableRootAdapter.init` cache allocation. Therefore the
selected-host subset is **prewarmed**: neither11events nor336bytes can be a full
cold metadata ceiling or the size of a proposed exception. Construction itself
also cannot be declared zero from this measurement arrangement.

## What the other measurements establish

Across both windows about180.5k allocations/profile have explicit print/debugPrint
frames. Remaining print preparation, reuse labels, role transcript and corpus
literals are tagged separately by exact source/call sites. Common graph/scoped
custody tags are not normative exemptions;916cold common scoped oracle/library
events still need their detailed ownership/header split. Full all-event totals
and peaks are preserved; they are not the selected runtime's heap charge.

Directly attributed Dynamic storage/object paths add **338allocations per window**,
537,037requested/620,288usable-reserved cumulative bytes; simultaneous peak is
51,507requested/59,488usable, with7,981maximum simultaneous usable-size rounding.
All these objects retire within their originating window; this is an observed
transient heap peak across repeated sessions, not a single retained-capacity sum.
Figures are identical in every Dynamic run and are obtained from its own event
paths, not subtraction of the Static run. Swift headers/control are already inside
requests; their complete per-array/class split remains unproved. A96-byte trace
array's32-byte prefix is visible in the linked code, but usable-minus-requested
never measures Swift headers or allocator arena/VM bookkeeping.

Public symbol interception still has its independently demonstrated direct-zone
callback blind spot; raw VM, coroutine/temp slab/cache and allocator-internal
reserve coverage remain open. `swift_coroFrameAlloc` import presence neither proves
nor excludes a reached allocation. This gap can hide additional cost; it cannot
make the witnessed336bytes zero. No complete allocation/stack/physical claim follows
from process success,137captured frames or zero capture-error flags.

## Contract boundary and concrete choices

[SPEC-013](../../../../../../docs/specs/spec-013-runtime-profiles.md) explicitly says
“Static construction and every later phase allocate zero heap” (baseline
amendment and Performance Requirements); S13.2/RP-SO-003 retains actual profile
resource/zero-heap proof. [SPEC-015 Performance Requirements](../../../../../../docs/specs/spec-015-host-configuration.md#performance-requirements)
explicitly includes Static action dispatch/fact admission and forbids heap and
reflection. Both include Native Static among the supported configurations.
No accepted clause excludes ordinary Native generic metadata/witness allocation.
Existing larger-nRF-RAM approval and later performance work do not waive this.

The smallest decision is either:

1. **Preserve the current zero-heap contract:** authorize a new bounded design/
   implementation allowance specifically to eliminate actual Native Static first-use
   allocations, including cold construction and first action/dispatch. Existing
   application repair allowances remain closed. A helper annotation or cache warmup
   is not an evidenced solution; no implementation candidate is proposed here.
2. **Explicitly amend the Native Static boundary:** permit and separately charge
   ordinary Swift first-use generic metadata/conformance costs, including first
   actions, while retaining zero heap for profile-owned storage/later operations
   and unchanged Embedded Static guarantees. This requires a precise accepted
   authority change and complete cold/runtime accounting;11/336 is not an upper
   bound and a constructor-only exception is insufficient. This packet grants
   no exception and does not move required counter safety to P09–P12.

After that decision, remaining Native/Pi ledgers still require source-feasible
construction/live/action/failure/cleanup/callback/recursion paths and actual library
callees, temporary/copy homes, signal premises and once-only section/storage
charges. Native must resolve actual system-cache Swift/OS bodies (the named dylib
is cache-only; installed cache files exist but `dyld_shared_cache_util` is absent),
then bound rooted metadata/allocator/stdio paths against its recorded process
stack. Pi must close the existing ELF `c1c6682e` ARMv6 paths and dynamic
libc/libm/libstdc++/libatomic/libgcc identities plus deployment stack/physical-memory
assumptions. No nRF ceiling or Thumb byte count transfers, no absent library frame
is zero, and no unproved complete bound is now proposed. Independent review of
this counterexample precedes affected closure; nRF's accepted proof, all control
coverage and historical repair limits remain unchanged.

Governance, local links, source/object/packet hashes, attribution/replay conservation
and whitespace checks pass. Five external analyzer/CMake/shell edits and known
pycache remain untouched/uncommitted. No target execution, firmware build,
application source change or lifecycle transition occurred.

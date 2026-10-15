# P08 stack candidate A — source freeze

**Frozen candidate `3d69aba9`: independent Strong source review BLOCKED; screen 0/1.**
[Review B01](p08-stack-candidate-a-independent-source-review.md) identifies five
introduced transcript receiver errors. The source/manifest below remain the
reviewed failing candidate identity; no compiler result is claimed.
The [activity](p08-stack-candidate-a-activity.md) records current user direction
and the [independent design PASS](p08-resource-design-independent-review.md)
at `a90841e0`. One grouped candidate and one fresh nRF screen are allowed, with
zero automatic repair variants. Historical 2/2 stays closed. No compiler, build,
runtime, image, debugger or target experiment was executed in this source step.
27,648-byte main stack, 196,608-byte RAM, zero heap, capacities, workload,
toolchain and flags remain unchanged. P08 fit remains failed.

## Exact source

The [manifest](stack-candidate-a/manifest.json) pins five baseline/candidate Swift
hashes, driver/qualification hashes, exact diff, all 384/202 compiler labels,
five native controls per profile and 26 runtime reuse labels. Manifest SHA-256:
`cf1df40f3f0f85be21cec293dbffaff6446048a076ebdd5796afb0520117f0e8`.
[Source diff](stack-candidate-a/source.diff) SHA-256:
`7068598a573a128d35bf047f98ce9447d1ef2857496e5666fbe798654a4c9e64`.

| File | Realization and preserved obligation |
| --- | --- |
| `CounterScopedStorage.swift` | 18 original runtime-field projections. All five full current/before comparisons now use short non-inlined `p08MatchesReuseFingerprint`: borrow the existing owned expected facts, construct the same complete current fingerprint, use unchanged synthesized equality, return only Bool. Selected currently inlined cleanup `supply` and `checkJoins` gain boundaries. Large already out-of-line `constructOwner`, `constructHost`, `run` and `finish` remain unchanged. |
| `CounterHostOwner.swift` | Boundaries on base `CounterHostState.activate`, `attachRoot`, `runOpportunity` and four borrowing observations (`observeModelValue`, `observeProducedAction`, `prepareProducedAction`, `deliverProducedAction`). Existing separate specializations do not prevent their witnessed inlining into long callers. No mechanical annotation of quiescence/release/reset or every state method; all cases, initializer, consuming rewrites, lifetime unions and ticket/span order remain identical. |
| `CounterWakeIntegration.swift` | Six original nested-field reads replace forwarding getters; complete admission/wake/pacing and count/completion baselines remain. |
| `CounterHostProbe.swift` | Eight original nested-field reads; same activation/retirement/join predicates and full owned join snapshots. |
| `CounterHostCorpus.swift` | Three original nested-field reads; complete independent semantic/action/pixel oracles and borrowing control signature remain. |

All 35 direct projections still read the same original `runtime.admission`,
context or unavailable field through the existing synchronous pointer/borrow.
The expected fingerprint stays live in its original reservation; each current
snapshot ends in the helper after the preceding client operation. No borrow
spans callbacks; no pointer/capability/result escapes. The new helper owns only
the same inert observation values, not scoped authority. Every fingerprint field,
stale zero-effect check, guard, producer origin, actual mutating-path correlation,
required label and deferred/backing-last cleanup remains. No new owner, bank,
heap allocation, region, state case, exposed projection or getter API is added.
Changed call nesting is **not** evidence of a smaller peak or upper bound.

## Exact component applicability

[New qualification](p08-stack-candidate-a-applicability.json) pins seven exact
unchanged component receipts and the new CounterScopedStorage hash. All recorded
Swift argv sets exclude **all five** candidate files. Only CounterScopedStorage
was a recorded noncompiled metadata input; the other four are absent from those
receipt input maps. Full receipt/old-source hashes, sorted recorded input counts/
digests and five-file exclusion maps remain pinned. Counts are
53/53/112/173/173/159/172 for the seven predecessor component recipes.

The counter driver changes only qualification path and exact activity pin.
Current/old source hashes, complete argv exclusion and actual compiled input/
artifact/compiler/macro checks remain mandatory. No old qualification or receipt
is rewritten. This cannot qualify any changed compiled counter module or whole
old counter receipt; new counter routes rebuild current preparation/selected
source. The existing image handoff still rejects partial receipts.

## Checks and next screen

- Pinned formatter `env PATH="/Users/eugene/work/GiftUI/.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin:$PATH" scripts/format-swift.sh` exits 0 and changes no maintained source. Its established exclusion of contract fixtures preserves their current formatting.
- `python3 -B -m unittest discover -s scripts/contracts -p test_p08_check_collection.py`: **29 passed**, no compiler.
- Isolated AST loading of the current qualification functions accepts all seven exact predecessors and rejects wrong current/receipt hashes and a newly included compiled-source argv. All five files preserve every existing lifetime annotation, guard/precondition/oracle count and reuse label, plus five complete fingerprint comparisons. These are source/documentary checks, not Swift syntax/compiler/lifetime/codegen/runtime/fit evidence.
- Final source/glue/qualification/manifest hashes, new local links and `git diff --check` pass. `scripts/validate-governance.rb` passes (200 authority nodes, 2,026 edges; seven features, 76 lifecycle artifacts). Unrelated generated `scripts/contracts/__pycache__` remains untouched.

After independent source review the parent runs exactly:

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter \
  --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded \
  --host-build .build/contracts/p08-scoped-host-hzs5q7za \
  --fresh-focused --select-family so07-layout-facts
```

This uses the **new** qualification and emits a fresh build. The 202 compiler
controls, native runtime/exclusivity, Pi and images remain not run; the screen
is explicitly partial, never aggregate coverage. Inspect the actual target
object by section plus exact symbol, SP operations and feasible nested calls,
including the new comparison helper and preserved large cleanup frames. A
retained over-limit lower bound rejects further expensive follow-up; finding
none is not fit. Preserve exact command/result/bytes on either outcome; zero
automatic repair variants follow.

## Affected coverage and gaps

All four counter compiled-source identities change via shared fixtures; old
full receipts remain immutable old-source evidence. Future diagnostics, **not
authorized/run by this freeze**, follow the design's fresh native Dynamic/Static
runtime plus five exclusivity controls and complete selected host-backing/
consume/owned-return/closure/task/async/overlap families with positive twins;
Pi compiles those selected families. No declaration/case/lifetime constraint
changed; any such future change requires reconsidering the complete union/
carrier/erasure matrix. Focused native/Pi receipts stay partial with omissions
explicit. Current complete nRF 202-control coverage precedes the registered
image; actual ELF layout/ABI/RAM/flash/full-main/IRQ/allocator proof remains.

The linked ≥213,120-byte path and historical ≥58,648/30,096 failures remain
failed baselines. Complete costs, independent final exit, P08/R07/T8.1/HC-RD-003,
I4-07/analyzer, P09–P12, hardware and timing remain open. This freeze claims
source readiness for independent review only.

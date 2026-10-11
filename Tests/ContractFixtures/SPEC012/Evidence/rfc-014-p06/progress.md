# RFC-014 P06 progress

## Independent repair exit-review recommendation — 2026-10-11

[Separate Strong repair review](repair-exit-review.md) resolves P06-R1 and
recommends **PASS for finite P06**, subject to parent package disposition.
The original counterexample now yields zero beginPath calls, invalidModelAccess
and one release; its historical inputs/report are unchanged. Independent
verification matches all 602 inputs, 812 artifacts, receipts/compiler/tool
identities, unchanged physical layouts and historical controls. No other blocker
was found. No production repair was performed by the reviewer.

Counter remains **0/2**. T10.1, DR-RD acceptance and P07–P12/full-conformance,
resource and target-execution obligations remain open. Review records and links
passed `scripts/validate-governance.rb` and `git diff --check`.

## P06-R1 final repair handoff — four profiles refreshed, independent review pending

Implementation repair: `72438931..431293f9`; following evidence-only commit
contains this handoff. Strong `gpt-6-astra` / `high`, C3/R3, performed the single
productive repair. Counter remains **0/2**. No new contract or scope decision,
constraint suppression, capacity change or successor work was introduced.

The [current index](final-index.json) and four copied receipts now describe the
repair. Native Static has **43 checks / 13 negatives / 4,042 assertions**;
native Dynamic has the same. ARMv6 and nRF each have **42 checks / 13 negatives**,
rooted target component/ABI/layout evidence only, with no board execution.
Native assertion components are 364 staged/semantic, 13 mapping, 24 finite table,
17 geometry and 3,624 raster checks. Both staged lenders use the actual P03
owner for the new binding-order controls.

[Implementation-side reconciliation](repair-evidence-verification.json), rerunnable
with `python3 Tests/ContractFixtures/SPEC012/Evidence/rfc-014-p06/verify-repair-evidence.py`,
verifies **602 input hashes, 812 artifact hashes/sizes, seven immutable geometry/
raster controls**, all expected negative diagnostics, native/target ABI logs,
and unchanged physical layouts against the pre-repair receipts. There are no
mismatches. It also verifies the original blocked review, reproduction, logs and
independent verification artifacts are byte-identical to `72438931`. The original
`verify-exit-evidence.py` and reproduction are historical scripts for their frozen
review input, not current repair success gates. Old receipts remain in that Git
revision and their original `.build` artifact directories.

Static was collected during the repair at dirty `72438931`; all its actual inputs
match `431293f9`. Dynamic, ARMv6 and nRF were collected from clean `431293f9`.
The lowerer SHA-256 is
`7f1486a71ea138a5a5909c3f8e5fddabe1a338f70b3578f70d7730e34435ab81`;
the refreshed macro tool SHA-256 is
`9bbb7c7532d763b1908cdcabbe4b9b87c6a7eb0c07e83cc93cc9bb154b313285`.
Compiler SHA-256 remains
`d8e40107da0e2c1c59640a983faea326d5d2bddfe81f7609db14bade43c4a5b9`.
Full receipt and object identities are in the index and receipts.

Exact refreshed commands, following `scripts/format-swift.sh` and the two
platform doctors (both passed pinned Swift 6.3.2 and SDK checks):

```text
scripts/contracts/run-spec-006.sh --profile macos-static --compiler-baseline rfc-014
scripts/contracts/run-spec-012.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/dd5d4849463055f2-hwlll28l/macos-static
scripts/contracts/run-spec-006.sh --profile macos-dynamic --compiler-baseline rfc-014
scripts/contracts/run-spec-012.sh --profile macos-dynamic --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/189dda86d331e15d-wpk82ft7/macos-dynamic
scripts/contracts/run-spec-006.sh --profile raspberry-pi-armv6 --compiler-baseline rfc-014
scripts/contracts/run-spec-012.sh --profile raspberry-pi-armv6 --compiler-baseline rfc-014 --giftui-build .build/raspberry-pi/contracts/spec-006-rfc-014/189dda86d331e15d-w03qxe3s/raspberry-pi-armv6
scripts/contracts/run-spec-006.sh --profile nrf52840-embedded --compiler-baseline rfc-014
scripts/contracts/run-spec-012.sh --profile nrf52840-embedded --compiler-baseline rfc-014 --giftui-build .build/nrf52840/contracts/spec-006-rfc-014/189dda86d331e15d-xnmh_sbd/nrf52840-embedded
```

All reserved physical layouts are unchanged: 196 Counter slots cost 7,056 bytes
(+784); Analyzer costs 7,840 native (+1,568) / 7,056 target (+784). Complete selected
Counter banks cost 30,616 bytes. Eleven emitted nRF staged/invocation bodies have
no direct allocator calls; full linked/transitive allocation, application hosts,
stack/RAM overlap and target execution remain outside this component evidence.

### Separate Strong repair review packet

Independently review `72438931..431293f9` plus the evidence-only handoff commit,
using the original P06-R1 proof and SPEC-012 lines 118–120 / 177–178. Check the
complete deterministic captured-key prologue, immediate facade discard, keyless
Canvas behavior, existing error mapping and identity/order precedence. Inspect
both staged-lender adversarial controls (drawing before read, read-free branch,
stale/wrong owner, competing capacity, valid controls, no later occurrence,
exactly-once release and ended read). Verify the new receipt applicability and
unchanged physical resource/geometry claims. No routine four-profile rerun is
needed merely for commit metadata; use a focused reproduction for any actual
concern. The parent owns package disposition after this independent review.
**P06 is not marked passed; T10.1 and P07–P12 remain open.**

## P06-R1 implementation repair — native validation complete, review pending

Input `72438931`; one productive repair, counter **0/2**. The generated witness
now prebinds every captured typed model key in sorted property-name order before
any authored statement, using the existing checked drawing facade initializer.
Each temporary is immediately discarded. Keyless witnesses remain empty; table
case/payload and producer identity/order checks retain their precedence. No
constraint, error map, lifetime annotation, bank count or capacity changed.

The registered Counter fixture reads inside withPath and includes a read-free
branch. Actual P03 scope plus both staged lenders now exercise stale-key
path-before-read and stale/wrong-owner read-free paths against a deliberately
failing beginPath, valid-key read-free capacity/success controls, and malformed
identity/order competing with stale binding. Failed binding admits no second
path or later occurrence; all three staged values release once and discovery
confirms the read ended. Expected order is SPEC-012 lines118–120/177–178 and
ADR-037, with the independent blocked review retained below as historical proof.

After `scripts/format-swift.sh`, the refreshed native Static core route passed
28 checks/120 assertions plus P03/P04 30/58/57 controls at
`.build/contracts/spec-006-rfc-014/dd5d4849463055f2-hwlll28l/macos-static`.
The P06 owner route with that exact `--giftui-build` passed43 checks/13 negatives
at `.build/contracts/spec-012-protocol-canvas/tmp0jaw1r5b/macos-static/result.json`:
364 staged/semantic +13 mapping +24 table +17 geometry +3,624 raster =4,042
runtime assertions. Remaining profile receipts will be refreshed next because
the lowerer/macro identity changed. The prior independent review/reproduction
remains untouched; its defect-specific assertion is historical, not a current
success oracle. P06 is not passed and no successor is authorized.

## Independent exit-review result — 2026-10-11

[Strong review](exit-review.md) recommends **BLOCKED** on P06-R1: generated model
binding is lazy within the authored draw body, so path construction can execute
before a stale-key failure and change failure precedence. The narrow actual-owner
[reproduction](exit-review-binding/result.json) confirms one beginPath call and
capacityExhausted instead of invalidModelAccess, with one staged release.
Production is unchanged. Parent owns sequential repair and package disposition;
no successor is authorized. Counter remains **0/2**.

[Independent evidence verification](exit-review-evidence-verification.json)
matches 602 P06/core input hashes, 812 artifact hashes/sizes, all receipt/compiler
identities, negative diagnostics and seven baseline-unchanged controls. Dirty
Static/nRF inputs match final implementation source. P07–P12 and T10.1/full
acceptance remain open. Review validation: `scripts/validate-governance.rb` and
`git diff --check` both passed.

## Independent exit-review dispatch — 2026-10-11

- Input clean `5a24a271`; review `a17724b2..5a24a271`, with implementation
  ending at `909a7dab` and approved exact constraint amendment `e6f10f67`.
  P03/P04 prerequisites and sequential P05 boundary passed.
- Scope: finite P06 / SPEC-012 T10.1 and DR-RD-001–004 applicable portions,
  retained geometry/ownership/failure contracts. Read the separate review packet
  below, owner matrix, approved amendments, ADR-035/036/037 and retained ADRs,
  resource bounds and exact four-profile receipts. No new contract is delegated.
- Strong `gpt-6-astra`/`high`, C3/R3, independent of implementation. Inspect
  source lowering/witness completeness, actual owner/backing lifetime ties,
  staging/read/transfer/release paths, marker-only semantic publication,
  finite bounds, error precedence and immutable geometry/pixel oracle evidence.
  Assess complete reserved union growth and the limits of allocator claims.
- Expected outcomes come from approved contracts and preserved controls, not
  merely the implementation-authored fixtures. Allow source inspection and
  narrowly justified reproductions. Independently verify receipt hashes and
  dirty-but-matched source provenance; no default rerun of all four routes.
- Allowed output: review report, reproducible evidence-verification artifact,
  associated task-evidence links and committed review receipt. No production
  repair, contract edit, successor work or parent package-pass disposition.
- Commands: `git diff a17724b2..5a24a271`, hash verification based on
  `final-index.json`, focused reproductions only for identified concerns,
  `scripts/validate-governance.rb` and `git diff --check` for final review records.
  Do not repeat the unverified optional P05 global dependency investigation.
- Counter remains **0 of 2** across all handoffs. Return blockers to the parent
  with exact lines/reproduction; contract/scope decisions require the maintainer.
  Preserve component/native/cross-build versus P07–P12 evidence boundaries.
  P06 exit remains pending this separate review and parent disposition.

## Implementation handoff — finite P06 evidence complete, review pending

Implementation source ends at `909a7dab`. The final evidence index and owner
cross-references are a following documentation-only commit. This implementation
pass does **not** mark P06 passed or authorize any successor package.
Counter remains **0 of 2**. No unresolved contract decision is known.

[Final index](final-index.json) identifies all four receipt paths, copied receipt
hashes, compiler hashes and verified core inputs. Every recorded input and output
artifact hash was reconciled with the current files before copying the receipts.
Native Static and nRF receipts were collected during the coherent resource step
and accurately retain `source_dirty: true`; their recorded inputs match final
implementation source. Native Dynamic and ARMv6 were collected from clean
`909a7dab`. No result is silently relabeled as clean or board-executed.

| Profile | Checks | Negative checks | Execution |
| --- | ---: | ---: | --- |
| [macos-dynamic](macos-dynamic.json) |43|13|3,944 native runtime assertions|
| [macos-static](macos-static.json) |43|13|3,944 native runtime assertions|
| [raspberry-pi-armv6](raspberry-pi-armv6.json) |42|13|Rooted component object, ARMv6/VFP ABI and layouts; no board execution|
| [nrf52840-embedded](nrf52840-embedded.json) |42|13|Rooted component object, ARMv7E-M/VFP ABI, layouts and direct allocator attribution; no board execution|

Each native total is266 staged/semantic assertions,13 error mappings,24 finite
witness assertions,17 retained production geometry checks and3,624 raster
checks. All17 independent golden vectors run both encodings and full/one-row
tiled damage against literal masks/palette bytes. The unchanged Q160 oracle
passes separately. Wrong owner and indexed out-of-bounds execute through actual
generated witnesses. Negative cases include missing authored/compiled witness,
async/effect/inout/legacy closure use, wrong domain, escaped read/context, and
escaped/copied source/staged values. Ordinary Body inference and context aliases
remain covered.

Exact final owner commands (all after formatter):

```text
scripts/contracts/run-spec-012.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/d4469901da4c0259-9wtdw756/macos-static
scripts/contracts/run-spec-012.sh --profile macos-dynamic --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/1ebb999f319d770c-7z96f1lo/macos-dynamic
scripts/contracts/run-spec-012.sh --profile raspberry-pi-armv6 --compiler-baseline rfc-014 --giftui-build .build/raspberry-pi/contracts/spec-006-rfc-014/1ebb999f319d770c-rghi6e_f/raspberry-pi-armv6
scripts/contracts/run-spec-012.sh --profile nrf52840-embedded --compiler-baseline rfc-014 --giftui-build .build/nrf52840/contracts/spec-006-rfc-014/25124cd324d60cb1-2hchpear/nrf52840-embedded
```

Each core directory came from the matching
`scripts/contracts/run-spec-006.sh --profile <profile> --compiler-baseline rfc-014`;
native P02/P04 regression assertions and target selected builds passed. Exact
compiler commands are retained in each receipt and artifact directory.

Resource interpretation: two unchanged98-slot payload pools cost7,056 bytes
for Counter on all targets; Analyzer costs7,840 native/7,056 target, compared
with6,272 baseline. Counter's complete two semantic banks (including unchanged
record/path/scalar extents) cost30,616 bytes. The additional784/1,568 payload
bytes must be included in P11's full overlap budget, not hidden as live-only
usage or treated as authority to raise a limit. Both staged profile lenders use
the configured extents. Selected nRF staged/invocation bodies show no direct
allocator calls; full transitive/linked heap, stack, complete hosts and target
execution remain unproved here.

### Separate Strong review packet

Review `a17724b2..909a7dab` plus the final documentation-only evidence commit;
the exact constraint approval is `e6f10f67` and must not be reinterpreted as a
broader generic or lifetime exception. Strong `gpt-6-astra`/`high`, C3/R3, must
review independently of this implementation pass. Focus on:

- Compiled Canvas/source-lowering contract, finite case completeness, ordinary
  Body inference, typed key/domain agreement and error/raw9 owner mapping.
- Actual owner+staged backing lifetime dependence, fresh per-invocation reads,
  painter order/local bounds, no suffix after failure and exactly-once cleanup
  including producer rejection before acquisition.
- Pending semantic value transfer/fences, partial failure cleanup, preservation
  of prior publication, marker-only published semantics and both profile stores.
- Applicability of immutable geometry/pixel controls, actual source/compiler/
  artifact hashes, reserved union slot costs and scope of direct allocator claims.

This is selected component evidence, not complete GiftUIDrawing/Runtime host
adoption or application/firmware conformance. Existing Static analyzer geometry
workspace retains its five/five profile; its only production change is the
approved status case. P07 coordinator implementation, P08/P09 application/host
adoption and P10/P11/P12 full gates remain outside this pass. There is no new
bank, application, retained closure fallback, limit authority or successor work.
Independent review may require repairs before the parent records package exit.

## Step 9 — target layouts and rooted Embedded component evidence

After formatting, native resource checks passed at
`.build/contracts/spec-012-protocol-canvas/tmpq2rsgmp0/macos-static/result.json`,
using core `d4469901da4c0259-9wtdw756`. The nRF route passed42 checks at
`.build/nrf52840/contracts/spec-012-protocol-canvas/tmp0qtf6fi1/nrf52840-embedded/result.json`,
using verified core `25124cd324d60cb1-2hchpear`. Both platform doctors passed
Swift6.3.2 and tracked SDK pins. nRF includes the existing firmware
`-DGIFTUI_NRF_EMBEDDED` define (SignalAnalyzer CMakeLists line355), giving the
retained raster's bounded wide-integer division implementation. Exported fixture
roots materialize actual static store/transfer and other component bodies; the
artifact is ARMv7E-M ELF32 with VFP register calling convention, not a linked
firmware or board execution result.

Sixty target-derived size/stride/alignment constants are in layouts.json.
All196 reserved semantic payload slots are charged, along with unchanged448
scalar slots and both126-record/378-prefix banks. Native Counter slots32→36B
cost+784B; Analyzer slots32→40B cost+1,568B. nRF both slots32→36B cost+784B.
Counter semantic backing totals30,616B. Native staged3 Counter112B/staged5
Analyzer244B; nRF staged5 Analyzer184B. Source adapter stride64B native/32B nRF.
These are concrete selected representations, not new count/limit authority or
proof of full overlapping host RAM/stack feasibility. Eleven emitted nRF
staged/invocation bodies have no direct allocator calls; their hashes and exact
claim are in allocation-attribution.json. This does not establish transitive
linked zero-heap or complete application costs (P11).

Narrow fixture repairs: `tmphi6e8_hf` required the explicit CounterCanvasTable
import for Embedded serialization; `tmp_uxknwyv` required UInt64 typing on each
golden literal before a ternary on32-bit targets; `tmprn86stic` crashed compiler
IR generation when a separate module re-instantiated imported noncopyable
CanvasModel test bodies. Placing exported roots in the original probe module
and emitting its IR resolved that compiler boundary without unsafe annotations
or relaxed tests. Generated wrong-owner and indexed out-of-bounds witnesses now
execute their real mapped failures as well. Counter remains0/2.

## Step 8 — authored context alias preservation

Finite lowering already tracked draw's local context alias for its body, but
emitted a hardcoded local witness parameter name. The witness now preserves
that local name while retaining the required external `context` label.
CounterTrace uses `context drawing:` and its existing execution verifies the
alias through scoped withPath. After formatting, P02/P04 native regression
passed at `.build/contracts/spec-006-rfc-014/d4469901da4c0259-9wtdw756/macos-static`;
the exact P06 owner route against that verified input passed at
`.build/contracts/spec-012-protocol-canvas/tmp6zqd51ki/macos-static/result.json`.
No signature contract, oracle or ownership behavior changed. Counter0/2.

## Step 7 — retained production geometry and independent pixel controls

The owner route now compiles the unchanged path/plan storage and workspace
algorithms from SignalAnalyzerTargetHost as a selected module. The only
production repair was adding the approved invalidModelAccess/raw9 case to its
closed status switch, which the new compile exposed (`tmp85vca3za`).
`CanvasGeometryProbe.swift` exercises scoped two-inout paths, invalid path/style,
immutable snapshots, subpaths, surface translation, empty strokes and
discard/reset access. It fills the retained analyzer workspace's exact five
Canvas/five stroke admission, without changing that profile or any limit.

`generate-spec-012-raster-probe.py` translates all17 immutable YAML vectors to
inline fixture data; expected masks and encoded bytes are copied literally from
the normative palette. Production RasterStrokeCoverage and CanonicalEncodedPixel
execute both encodings against full-surface and one-row tiled damage regions.
The unchanged independent Q160 Ruby oracle also passes. The negative-origin
surface is translated to the required zero-origin descriptor coordinate system;
points and clips move together, and expected pixels are unchanged. Clip tuples
are half-open edges, while surface tuples are origin/size. A UInt64 untouched
sentinel cannot alias any four-byte white pixel.

After formatting, the exact native owner command passed at
`.build/contracts/spec-012-protocol-canvas/tmpypvd_x2n/macos-static/result.json`.
Preserved harness failures: `tmpgqt8wxtf` initially rejected the negative surface
origin; `tmpm2j0q6yv` exposed the fixture's incomplete five/five profile before
seal; `tmp0qj256vc` isolated the clip tuple parsing error at the negative-origin
vector. Debug-only probe builds diagnosed those failures. Corrections followed
the retained profile and oracle input definitions; no expected mask/byte or
production raster/geometry algorithm changed. Counter remains0/2.

## Step 6 — both transfer profiles and staged adversarial checks

Both Dynamic and Static now execute the same semantic transfer/fence/failure/
retry fixture using their own staged and semantic backing. New native checks
exercise exact capacity/first excess, duplicate identity, repeated invocation,
idempotent release and empty witness on both stores. Staged-value copy/escape
compiler negatives preserve the lexical backing requirement. After formatting,
the existing exact native route passed at
`.build/contracts/spec-012-protocol-canvas/tmp76p6g43s/macos-static/result.json`.
No production source changed. Counter remains0/2.

## Step 5 — finite witnesses and scoped fixture repair

Strong C3/R3 diagnosed the Standard handoff as fixture lifetime placement:
FrameRead created outside the workspace callback was captured across that
callback. Constructing it inside the callback from the same live InlineArray
span keeps the borrow lexical. No production change, unsafe annotation, or
weakened negative was needed. The exact handoff route passed after formatting:
`.build/contracts/spec-012-protocol-canvas/tmp1zdctush/macos-static/result.json`.
Counter's two witness cases and Analyzer's indexed read execute; generated
case IDs, payload sizes, absent types, out-of-range lookup and mismatched
payload/ID checks pass. Existing error/store/semantic checks remain green.
The retained failure is `tmpt7qpmsm0/macos-static/CanvasStoreProbe.log`.
Counter remains0/2; final evidence and independent review remain open.

## Strong lifetime-fixture handoff — 2026-10-11

Standard `gpt-6-sol`/`medium` committed fixed error-mapping evidence in
`2fbfad32`. The next finite-table fixture reached a scoped-read lifetime
diagnostic and stopped without production changes. Uncommitted work is
`CanvasTableProbe.swift`, its driver registration and the Analyzer fixture's
package initializer. Preserve this diff; do not restart P06 or repeat passed
checks only because of the model switch.

Reproduction: `scripts/contracts/run-spec-012.sh --profile macos-static
--compiler-baseline rfc-014 --giftui-build
.build/contracts/spec-006-rfc-014/f28bb03491f0640c-ot0b940_/macos-static`.
Failure: `.build/contracts/spec-012-protocol-canvas/tmpt7qpmsm0/macos-static/CanvasStoreProbe.log`.
The compiler reports `read`/`analyzerRead` escaping when values derived from
InlineArray spans are passed through the workspace context closure (probe
lines 77/87 and 105/113 at handoff). Existing production source is unchanged.

Strong `gpt-6-astra`/`high`, C3/R3, owns diagnosis of the lexical borrow and
the smallest approved-contract repair. Inspect the actual source and lifetimes;
do not relax escape controls or fabricate backing annotations. Rerun the exact
focused route after a justified change, record proof/cause, and commit a coherent
passing step before resuming remaining fixed evidence. Contract/scope changes
still return to the maintainer. The prior Standard packet remains the bounded
remaining work list; separate final Strong review is still required.
Counter remains **0 of 2** across handoff; no unproductive repair was attempted.

## Step 3 — bounded semantic transfer, ready for sequential evidence slice

The semantic candidate codec now stages the concrete typed union in the existing
generic payload pool with a pendingCanvas tag. Publication and consumer views
reject pending values. CanvasSemanticTransfer transfers occurrence identities
into staged storage and clears semantic values to markers; partial transfer
failure releases its staged prefix and discards the candidate. Published prior
semantics survive, and the next candidate can reuse the same banks. The generic
payload slot size can increase; final resource evidence must include every
reserved slot in both banks rather than only live Canvas payloads.

After formatting, the native owner route passed **216 assertions** (176 prior
stores plus 40 semantic/actual Layout transfer checks), 5 authored lowering
negatives and 6 compiled negatives. The authored ordinary HStack Body remains
inferred. The semantic fixture exercises a real P03 owner, P04 record store,
P05 borrowed Layout/Render consumers and production Layout. Its final draw uses
the actual scoped invocation adapter with the instrumentation workspace; this
is not yet production geometry/raster evidence. Both staged profiles run the
store matrix; the semantic transfer fixture currently uses Static backing.

Exact validation:

- `scripts/format-swift.sh` completed before the final run.
- `scripts/contracts/run-spec-006.sh --profile macos-static --compiler-baseline rfc-014`
  passed 28 checks/120 assertions, 30 traversal, 58 bank and 57 records checks
  per profile. Verified core directory
  `.build/contracts/spec-006-rfc-014/110c46dd2d3f6ca3-7luv6r5o/macos-static`;
  copied receipt [step-3-core-regression.json](step-3-core-regression.json).
- `scripts/contracts/run-spec-012.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/110c46dd2d3f6ca3-7luv6r5o/macos-static`
  passed. Artifact directory
  `.build/contracts/spec-012-protocol-canvas/tmpcfs5jy8a/macos-static`;
  copied receipt [step-3-macos-static.json](step-3-macos-static.json), including
  source/compiler/macro/artifact hashes and all exact compiler commands.

Failures preserved: `tmpmkoqqz97/macos-static` diagnosed a borrowed copyable
table descriptor captured by the transfer callback; explicit descriptor copy
fixed it. `tmp80xamygc/macos-static` compiled but trapped at semantic assertion12;
an Onone fixture rebuild plus LLDB isolated an incorrect test expectation that
Canvas would flex in HStack. SPEC-007 “Stacks and spacer” transposes the absent
main-axis proposal, and SPEC-012 baseline lines940–941 resolves absent Canvas
axes to zero. Those independent clauses corrected the expected width/origin to
zero; production Layout and its oracles were unchanged. Final optimized run
passed. These were productive narrowed repairs; counter remains **0 of 2**.

### Sequential Standard packet — fixed-rule evidence only

Dispatched after clean Step3 commit `032d827a`: **C2/R2**, Standard
`gpt-6-sol`/`medium`. The bounded assignment adapts enumerated fixtures and
collects fixed evidence under the rules below; it does not own representation,
lifetimes, budget interpretation or package acceptance. No implementation
choices beyond harness plumbing are delegated. Separate Strong review is
mandatory. Counter remains **0/2**; escalation preserves the current diff and
exact failed check rather than restarting this package.

Parent may dispatch Standard `gpt-6-sol` / `medium` after the coherent Step3
commit. No concurrent implementation. Read this receipt, exact Step3 commit,
AGENTS, implementation-executor/deferred-work-curator, SPEC012 amendment and
its baseline, and the current static-canvas design note. Keep P06 open for
separate Strong review. Commit each coherent completed evidence step. Stop and
return ownership/lifetime implementation fixes, unexpected resource excess,
oracle disagreement, or unresolved contract meaning to Strong; do not change
production algorithms, approved constraints, limits or baseline golden vectors.

Fixed work and authority:

1. Extend `RuntimeDerived/CanvasStoreProbe.swift`, `CanvasSemanticProbe.swift`
   and the registered `check-spec-012-protocol-canvas.py` owner route. Exercise
   every generated table case, including Counter EmptyCanvas and Analyzer
   indexed read; dense IDs1...count, ID0/count+1 reject, payload/ID disagreement
   rejects, unknown primitive has no payload, duplicate occurrence rejects,
   exact capacity accepted/first extra rejects, repeated invoke rejects and
   repeated release does not increment. These derive from SPEC012 DR-010 and
   amendment per-type witness/owned-value rules. Test staged copy/escape
   negatives as well as existing source/read negatives. Existing array values
   3/7/3 and sizes5x7/15x21 are fixture inputs, not production-derived oracles.
2. Execute all five AccessFailure-to-DrawingError mappings (amendment): wrong
   owner/schema/stale -> invalidModelAccess; invalid phase -> invalidPhase;
   out-of-bounds -> invalidValue. Execute raw value9 and one-byte production
   enum checks plus `GiftUIDrawingFailureAdapterFixture.fact` mapping to
   invalidIdentity/rendering/activeCycle/contained. The runtime failure adapter
   has the same case but needs only bounded selected evidence, not a new host.
3. Extend semantic transfer coverage to Dynamic staged/semantic backing using
   the same already-tested identity/order/fence assertions. Preserve no
   Canvas value in published semantics. Test empty Canvas, zero occurrences,
   cleanup and fresh retry without adding a P07 coordinator. Existing stores
   cover initial phase/reentry/acquire rejection (caller discard), stale second
   key, path/client error, stroke capacity, layout order mismatch and seal
   failure, each suffix uninvoked and all values released exactly once.
4. Preserve/run `scripts/contracts/check-spec-012-raster-vectors.rb` and its
   `Tests/ContractFixtures/SPEC012/raster-vectors.yaml` Q160 oracle unchanged.
   The Ruby checker alone is not a production pixel check. Add selected
   production geometry/raster fixture execution to the owner route, reusing
   the immutable expected masks/bytes and geometry expectations in
   `Tests/GiftUIRasterCoreTests/RasterStrokeCoverageTests.swift`,
   `Tests/GiftUIDrawingTests/PathConstructionTests.swift`,
   `StrokeSnapshotTests.swift`, `DrawingLifetimeTests.swift` and
   `DrawingWorkspaceFixtures.swift`. RasterStrokeCoverage.rasterize's direct
   API is shown in the golden-mask test at line381. Adapt only harness plumbing
   for the selected compiler/modules; do not derive expected outputs from the
   implementation. Full app/old host closure migration remains P07/P10 scope;
   compilation difficulty is not permission to omit finite P06 oracle checks.
5. Record target ABI size/stride/alignment using constant exported functions
   and LLVM IR under the selected profile flags (see
   `scripts/contracts/check-spec-006-runtime-records.py` for established pattern).
   Include Counter/Analyzer concrete Canvas values, generated unions, witness
   descriptors, staged entries with SemanticRecordReference, metadata, source
   adapter, semantic wrapper and optional wrapper versus old standard payload.
   Report both98-slot banks, unchanged224 scalar slots per bank, and configured
   staged occurrence counts; do not present union enlargement as only live
   payload cost. Inspect selected Embedded artifacts for closure fallback/heap
   dependencies and report actual reachable component limitations. Complete
   application stack/linked resources remain P11 and must not be claimed here.
6. Read platform skills before cross checks. Doctors already passed earlier,
   but rerun if environment changed. For each of macos-dynamic, macos-static,
   raspberry-pi-armv6, nrf52840-embedded run
   `scripts/contracts/run-spec-006.sh --profile <profile> --compiler-baseline rfc-014`,
   then `scripts/contracts/run-spec-012.sh --profile <profile> --compiler-baseline rfc-014 --giftui-build <the verified core directory>`.
   Compiler inputs/macro must match, as enforced by the driver. Native runs
   execute; cross results are compile/ABI/artifact evidence, not board execution.
   Output roots remain `.build/contracts`, `.build/raspberry-pi/contracts`,
   `.build/nrf52840/contracts`. Format before validation; do not run the optional
   global dependency checker that was unverified in P05.

Evidence destination remains this one directory/receipt. Copy final per-profile
result JSON and a small index of paths/hashes; update T10.1 evidence mappings and
the existing static-canvas note as needed. Register any additional focused
checks within the current owner route. Preserve actual failure output and
counter. Do not mark P06 passed. At completion provide parent exact committed
span and separate Strong review packet with scope/limitations/residual findings.

Remaining implementation choices are **not delegated**: any needed ownership
repair, representation/resource-budget change, new generic suppression beyond
approved exact corrections, error-precedence ambiguity, or geometry change.
Current code is a local realization under existing limits; tests/resource
measurements may expose issues requiring Strong. No successor task is started.

## Approved resumption dispatch — 2026-10-11

Eugene approved the precise source-constraint proposal at `67331c11` with
“Approved. Please proceed”. The [approval record](../../../../../docs/iterations/iteration-003-review/rfc-014-spec-approval.md#scoped-canvas-source-constraint-amendment--2026-10-11)
and updated SPEC-012 resolve the contract blocker; the proof/earlier stop remain
historical. Input tree was clean at `67331c11`. Safe step 1 is `58cf89c7`.

Resume the existing P06 packet below using Strong `gpt-6-astra`/`high`, C3/R3.
Implement only the approved protocol/producer/helper suppressions and their
lifetime-bearing adapter, then the already-scoped staged stores, semantic joins,
runtime/negative/geometry/error/resource checks and four-profile receipts.
Keep all method signatures, bounds, error order and caller cleanup duties.
The concrete adapter lifetime must depend on actual owner and staged backing.
Record exact commands before checks, preserve independent oracles and artifact
identities, format before validation, commit each coherent step and stop at P06.
The prior implementation context/receipt remains the handoff; do not restart
passed work solely due to this approval. Separate Strong exit review remains
required. Counter **0 of 2** is preserved, not reset by resumption.
No successor work or further contract/scope change is authorized.

## Entry and implementation dispatch — 2026-10-11

- Input `a17724b2`, clean tree. P03/P04 prerequisite exits passed; sequential
  P05 exit also passed after separate Strong review `42b5f639`.
- Package: P06 protocol Canvas; SPEC-012 DR-RD-001–004 applicable portions,
  retained DR requirements, owner T10.1. No successor package is authorized here.
- Read AGENTS/implementation-executor and required governance/orientation, the
  bounded sequence/task context, SPEC-012 current checkpoint/matrix and runtime
  amendment with referenced baseline clauses, accepted ADR-035/036/037 and
  retained geometry/raster ADRs, P02 lowering/P03 ownership/P04 banks/P05 borrowed
  Layout/Render receipts and current relevant design notes.
- Allowed footprint: GiftUI Canvas, GiftUIMacros finite witness lowering,
  GiftUIDrawing invocation/plan adapters, both profile staged-value stores,
  directly necessary semantic/consumer joins and corresponding tests/fixtures/
  registered owner driver/build wiring. Update existing traceability/design
  records; do not create a new design-note workstream or alter algorithms.
- Source entry points: `Sources/GiftUI/Canvas.swift`,
  `Sources/GiftUIMacros/FiniteSourceLowering.swift`,
  `Sources/GiftUIDrawing/CanvasPlanProducer.swift`; exemplars
  `Tests/GiftUIDrawingTests/CanvasPlanProducerTests.swift` and
  `DrawingLifetimeTests.swift`, preserved geometry/pixel controls.
- Settled contract: authored Canvas protocol refines View with Never Body;
  finite lowering supplies typed `_giftUIDraw` with a fresh exact-model read;
  ordinary custom Body inference remains. No escaping Canvas closure fallback.
  Stage once per actual occurrence, invoke after Layout in painter order using
  checked local bounds, preserve scoped two-inout withPath and geometry/raster.
  Each acquired staged value/read is discharged exactly once; caller retains
  cleanup duty on rejection before producer acquisition. No staged value reaches
  publication/backend; existing one-shot geometry offer/retry rules remain.
- Expected independent results: zero/multiple/repeated occurrences, exact model
  selection, local dimensions/order, missing witness/wrong-domain/escape/effect
  rejection, all early/binding/draw/plan failures release correctly and suppress
  later invocation; unchanged geometry/pixel oracles. Error addition/mapping and
  one-byte/compact bounds follow the approved amendment exactly.
- Remaining implementation choices: bounded concrete-value/profile store and
  private invocation bridge realization within the contract. Strong may decide
  local realization only; missing authority or contract/scope conflict goes to
  the maintainer before affected work continues.
- C3/R3 → Strong `gpt-6-astra`/`high`. Standard=`gpt-6-sol`/`medium` and
  Economy=`gpt-6-luna`/`medium` only after an exact bounded packet is supplied.
  All execution remains sequential; separate Strong review follows implementation.
- Checks: `scripts/format-swift.sh` before validation; exact focused commands
  recorded before running; preserve/register the SPEC-012 migration owner route
  under `--compiler-baseline rfc-014` for macos-dynamic, macos-static,
  raspberry-pi-armv6 and nrf52840-embedded, using pinned verified inputs. Read
  platform skills first, record source/compiler/artifact identities, actual
  payload/witness layouts and native versus target compile/ABI limitations.
  Keep independent geometry/pixel controls intact. P10 owns the broad gate.
- Commit each coherent completed step and evidence disposition. Mark SPEC-012
  implementing/plan active when implementation begins; leave T10.1 and final
  conformance gates open. Never mark implemented or P06 passed before review.
- Consecutive unproductive repair count **0 of 2**; preserve across handoffs.
  Stop after two same-blocker attempts without a new pass or narrowed cause.
- Result: dispatched; P06 exit pending. No contract/scope issue identified.

## Step 1 — protocol declarations and finite draw lowering

SPEC-012 is now implementing and its plan active. T10.1 remains open. The
Canvas declaration is the compiled fixed-domain protocol; only Canvas receives
the Never leaf/default traversal. Its private bridge constructs a checked
zero-origin Rect. FiniteSourceLowering emits a typed `_giftUIDraw`, preserves
ordinary Body inference, supports scoped two-parameter withPath, and emits
schema-specific drawing access mapping. The approved invalidModelAccess case
and drawing/owner failure mappings are present; runtime mapping execution is
still part of the remaining P06 tests.

Validation after `scripts/format-swift.sh`:

- `scripts/contracts/run-spec-006.sh --profile macos-static --compiler-baseline rfc-014`
  passed 28 P02 checks / 120 native assertions, then 30 scoped traversal,
  58 bank and 57 actual-record assertions per profile. Core receipt:
  `.build/contracts/spec-006-rfc-014/d18dacad362b4a35-znvim124/macos-static/result.json`.
- `scripts/contracts/run-spec-012.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/d18dacad362b4a35-znvim124/macos-static`
  passed the selected declaration/lowering route. Counter and analyzer authored
  Canvas compile; ordinary custom Body remains inferred. Missing authored and
  compiled witnesses, async/effect/inout uses, legacy closure initialization,
  wrong domain, stored read and escaping context all reject for named diagnostics.
  Receipt: `.build/contracts/spec-012-protocol-canvas/tmpouxbcgc3/macos-static/result.json`;
  copied to `step-1-macos-static.json`. The receipt records dirty-source hashes,
  exact compiler/core/commands and object/module identities. This is component
  compile evidence, not invocation/storage or complete application validation.
- Governance and `git diff --check` pass. Pi/nRF toolchain doctors passed after
  reading all four platform toolchain/build skills; cross compilation has not
  yet run for this step. Full four-profile package evidence remains required.

Preserved development failures were each narrowed and repaired: the private
bridge initially passed a failable Rect directly (core run
`ea4421c9d6f286d8-0awfhpu3`); withPath parsing initially accepted only unparenthesized
parameters (`tmpvacp67bz`); the emitted draw method initially lost leading trivia
(`tmpqx0rf08e`). Their logs remain in the named .build run roots. Each correction
advanced the failing stage and the final native route passes. Consecutive
unproductive repair count remains **0/2**.

Remaining P06: finite witness tables, both bounded staged-value stores, actual
scoped exact-model invocation and cleanup, semantic transfer/consumer joins,
full focused runtime/error/layout/resource checks, and four-profile receipts.
The next adapter step exposed a potential exact-protocol constraint conflict:
actual P03 ObservableModelScope is noncopyable/nonescapable while the normative
CanvasInvocationSource and producer Source are implicitly Copyable/Escapable.
No production constraint change is applied. A concrete minimal compile proof
and narrow proposed correction are being prepared for parent/maintainer review.
No P06 exit or acceptance criterion is marked passed.

## Scoped-source contract boundary — 2026-10-11

Safe step 1 committed as `58cf89c7`. The next adapter step is held at the
[exact Source constraint issue](scoped-source-constraint.md). A reproducible
native compiler proof uses the actual P03 owner scope, distinguishes Copyable
and Escapable rejection, and shows only the proposed protocol/generic changes
compiling. The proposal is confined to Evidence; production constraints and
normative specification declarations are unchanged. No static storage,
invocation adapter or semantic join was started under unapproved constraints.

Parent/maintainer decision is required before the proposed exact package API
amendment. This is a current blocker, not deferred work or a new package. All
remaining P06 exit work and separate Strong review remain open. Counter **0/2**.

## Step 2 — scoped source, typed tables and profile storage

Applied only the approved Source protocol/producer/helper suppressions. Finite
lowering now optionally emits the host/schema-owned typed witness table and
concrete payload union; IDs are per concrete type, not occurrence. Both profile
stores lend bounded initialized entries; the adapter's lifetime depends on the
actual P03 model scope and staged-value scope. Reads open freshly per invocation,
end before release, and closed typed errors cross the boundary without `any Error`.
The static table and directly necessary existing forwarding now accept FrameRead.

After formatter, the registered native command
`scripts/contracts/run-spec-012.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/4a218bc367aa4292-4mpnphal/macos-static`
passes. Latest receipt at `.build/contracts/spec-012-protocol-canvas/tmpm_plhbb9/macos-static/result.json`
records exact source/compiler/module/object identities. It executes **176 native
assertions** across both profile stores using actual P03 backing and generated
Counter Canvas. Independent expected values are A/B/A = 3/7/3, local endpoint
sizes 5×7 and 15×21 (surface origin remains workspace-owned), all releases once,
and two model destructions. Eleven cases include zero occurrences/dimensions,
invalid later identity, client/path/plan failure, invalid layout, early phase/
reentrancy/acquisition rejection, and seal failure. Entering discovery immediately
after invocation proves its read ended. New source copy/escape negatives reject.
The table corpus now includes a second empty Canvas witness; its invocation and
full coverage boundary checks remain part of the next focused test extension.

Development failures and narrowed repairs: `tmp7haws0a2` metadata setter scope;
`tmp7zq88ntb` explicit descriptor copying and lifetime-preserving clone initializer;
`tmpr4gke2_4` driver singleton tuple; `tmpg772le3d` explicit copy of stateless table
into Dynamic lender callback; `tmp88hhj22r` fixture initializer visibility. Final
native checks pass; consecutive unproductive repairs remain **0/2**. No failure
was worked around by a raw lifetime descriptor, escaping callback or weakened
expected result.

Selected modules are listed by the driver. Static model backing is used in both
native cases; full Dynamic coordinator/model-owner adoption, old host wrappers,
complete modules/applications, cross builds, resource certification and P07+
integration are not claimed. P06 still requires semantic payload transfer,
finite coverage/error/boundary extension, retained geometry/pixel controls and
four-profile matched receipts before its independent review.

## Step 4a — fixed drawing error mapping fixture

The registered P06 owner route now compiles the selected drawing failure
adapter and runs 13 independent assertions for all five approved access-error
cases, raw value 9, one-byte enum size/stride, and the four fields of the
invalid-model-access failure fact. This maps SPEC-012's amended failure
requirements to T10.1. The fixture does not change production error semantics.

After `scripts/format-swift.sh`, the exact commands were:

```
scripts/contracts/run-spec-006.sh --profile macos-static --compiler-baseline rfc-014
scripts/contracts/run-spec-012.sh --profile macos-static --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014/f28bb03491f0640c-ot0b940_/macos-static
```

The core receipt is `.build/contracts/spec-006-rfc-014/f28bb03491f0640c-ot0b940_/macos-static/result.json`;
the P06 report is `.build/contracts/spec-012-protocol-canvas/tmpoaxq75u3/macos-static/result.json`.
The native result says `stores assertions=216 errorMappings=13 failures=0`.
The report includes all selected compile and negative checks passing; its
`source_dirty=true` reflects this pre-commit fixture validation. The pinned
compiler SHA-256 is `d8e40107da0e2c1c59640a983faea326d5d2bddfe81f7609db14bade43c4a5b9`.
The report's core-receipt SHA-256 is
`255a8b48f34f85d2ff6626729dc7ca774e8a9cc594722a2f67102709860e745b`.
This is a partial native mapping check. P06 and T10.1 remain open, and the
consecutive unproductive-repair counter remains **0/2**.

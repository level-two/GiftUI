# P08 physical representation and ownership assessment

Status: **measured assessment independently PASS; proposed source design requires G01–G03 completion**.
[Independent assessment review](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-physical-representation-independent-assessment-review.md)
identifies exact callback-exclusivity, slot ownership/reset and physical/observation
proofs before source work. No source candidate executed.
Authority is accepted ADR-039 and implementing SPEC-011/013/015, not this note.
The [assessment activity](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-physical-representation-assessment-activity.md)
records authorization. The preceding implementation allowance remains closed at
2/2. P08 fit remains rejected; this assessment creates no repair allowance.

## Actual cause

The frozen final object has a feasible **66,864-byte** stale-action path, with
separate construction 34,800, current-action 60,512 and cleanup 43,848 lower bounds.
[The immutable result](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/p08-stage-realization-final-result.md)
includes source predicates, exact symbols, section-qualified BL relocations and
caller frames. These are lower bounds, not execution measurements or maxima.
Root/helper splitting reduced some costs, but consuming and borrowing operations
still materialize large aggregate homes. Another annotation-only candidate has
no demonstrated reason to remove them.

One diagnostic-only module compilation, with the original compiler/flags/imported
modules and original source plus scalar roots in a temporary copy, supplies the
missing target type ledger. It constructs no objects, links/runs nothing, and
cannot replace acceptance evidence or the frozen stack object. It exited zero;
all 120 roots have strict constant-return proofs. The original diagnostic parser
wrongly required STV_DEFAULT. Actual roots are exactly STB_GLOBAL/STT_FUNC/
STV_PROTECTED; requiring that exact visibility fixes inventory only. The unchanged
strict byte/relocation/alias/tail decoder proves every fact. The original decoder,
failure reproduction, actual symbol identities, full proofs and command receipts
are [preserved together](../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/physical-representation-diagnostic/README.md).

| Actual target type | Size | Stride | Alignment | Meaning |
| --- | ---: | ---: | ---: | --- |
| Pipeline | 3,532 | 3,536 | 8 | Main payload of active coordinator |
| Coordinator | 3,860 | 3,864 | 8 | Pipeline + binding 272 + admission 50 + packing |
| Mandatory host state | 3,889 | 3,896 | 8 | Inert/active/retired payloads, ticket, span, discriminator |
| Host owner | 4,439 | 4,440 | 8 | State + application + assembly and flags |
| Host / Optional host | 4,808 / 4,808 | 4,808 / 4,808 | 8 | Optional introduces no extra size here |
| Endpoint | 1,868 | 1,868 | 4 | Inline endpoint/session/recording payload |
| Tiled endpoint / adapter / session | 1,862 / 1,728 / 578 | 1,864 / 1,728 / 580 | 4 | Actual raster pipeline, not bank descriptors |
| Full recording sink | 1,148 | 1,148 | 4 | Includes 64 Optional glyph records |
| Complete identity / Optional identity | 206 / 206 | 206 / 206 | 2 | Entire bounded owned path; no Optional size overhead |
| Geometry access | 52 | 56 | 8 | Scoped descriptor, not inline geometry backing |
| Candidate / committed / hit access | 50 / 54 / 54 | 56 / 56 / 56 | 8 | Five original-bank descriptors |
| Shared Interaction wrapper | 318 | 320 | 8 | One transaction state and the five accesses |
| Supplied / retired carrier | 758 / 470 | 760 / 472 | 8 | Retained original scopes, not the active endpoint |
| Assembly / report / endpoint configuration | 474 / 347 / 120 | 476 / 348 / 120 | 4 | Owned validation/configuration metadata |
| Reuse fingerprint | 1,404 | 1,408 | 8 | Full logical baseline; not a 19KB logical snapshot |
| Original CounterControl | 4,200 | 4,200 | 8 | Existing final-region control owner |

The full 40-row numeric ledger is linked in the packet. Counts below use measured
member data sizes, not invented offsets or an aggregate packing formula:

- `CounterPipelineOwner.endpoint` contributes 1,868 bytes. Four independent
  `rootIdentity/actionIdentity/candidateRootIdentity/candidateActionIdentity`
  Optional complete identities contribute 4 × 206 = 824. Together 2,692 bytes,
  about 76% of the pipeline, are private fixture-owned payloads.
- Models 15, root 24, semantic 92, values 14, control pointer 4, geometry 52 and
  Interaction 318 contribute 619 data bytes. Remaining pipeline fields are the
  original phase/IDs/limits/recovery/header/provenance state and packing.
- Coordinator adds 328 bytes to pipeline data size; binding and admission account
  for 322. The coordinator is a direct composition, not a hidden bank allocation.
- Report retention is duplicated at host and owner/assembly levels, but each
  report is 347 bytes, not the main multi-kilobyte source. Validation ledger is
  only 6 bytes. RuntimeActionGenerationAllocator's Identity is a phantom type;
  it does not contain another identity array.

Frozen-object getters independently support the attribution: recording starts at
adapter +580 and endpoint +688; helpers copy 1,148 recording bytes and 1,024 glyph
bank bytes; actual endpoint copies 1,862 and its control pointer is at +1,864.
Each Optional glyph has size 13/stride 16; 64 × 16 = 1,024. The diagnostic agrees
with these original-object facts. It does not prove all future codegen unchanged.
The 19,272-byte stale helper frame therefore includes several carrier/call homes;
it cannot be charged solely to its 1,404-byte owned baseline.

## Authority versus physical choice

| Mechanism and source | Governing clause | Assessment |
| --- | --- | --- |
| `InteractionState` / `InteractionOwnedKeyState` | SPEC-011 S11.1; ADR-039 decision | Exactly five lifetime-bearing accesses, one transaction machine, owned counters and complete independently owned keys are mandatory. No replacement pointer/lease field or second machine in these types. Already compact; leave unchanged. |
| Supplied/pipeline/retired generic scope types | SPEC-015 S15.1 | Preserve original model/root/semantic/values/control, private geometry/Interaction, constructor lifetime unions and consuming retirement. Do not replace scoped accesses with raw state pointers. |
| State inert/active/retired payloads | SPEC-015 S15.1 | Logical and concrete carrier cases are expressly required. A tag plus external coordinator pointer, separate active owner or heap box would need an approved amendment; it is not a private enum refactor. |
| Static/Dynamic coordinators | SPEC-013 S13.1 and scoped coordinator amendment | Keep stored binding/admission/opportunity, getters, consuming initializer and lifetime union. A borrowed global/heap coordinator is not selected. |
| Endpoint + four pipeline identity fields | Counter fixture; ADR-038 construction joins; SPEC-013 ownership/accounting | These owned values are required for behavior, but their current inline placement in every pipeline carrier is not a mandated core type layout. A private physical realization may change only with explicit ownership, reset and measured cost. |
| Control-resident admission controller | `CounterAdmission.controller` | Existing precedent: private `_modify` yields the original typed control field. It avoids another stored controller in admission; it is not a new unbounded pointer capability. |
| Complete physical/resource proof | SPEC-013 S13.2; SPEC-015 HC-SO-002/003 | Every added nested control field, four slot instances, padding and construction/deinitialization temporary must be charged. Smaller carriers or successful linking are insufficient. |

The five banks are already in original final regions and consumed only as scoped
descriptors. Re-externalizing them or erasing their lifetimes does not target the
remaining mass. Complete keys cannot become hashes, prefixes, semantic-bank
references or borrowed paths: candidate rollback and retained dispatch require
independent full values. Existing current/candidate identity distinctions remain.

## Recommended next design: owned runtime payload in original control

Develop **one concrete private physical-storage candidate**, rather than another
helper/attribute variant. Keep all mandatory core/shared types, carrier cases and
scoped fields unchanged. Add a typed nested runtime-payload slot to the **existing
original CounterControl field**, containing the one endpoint and the four complete
owned identity values. Remove those same stored values from the moving pipeline.
There is one live payload, not a mirrored state or second transaction machine.
The CounterControl physical region is distinct from candidate bank `c0`.

The pipeline continues to own the exclusive logical use of these values through
its original control dependence. No new raw pointer field, lender, constructor
argument, exposed capability getter, protocol relaxation, heap allocation or
global is needed. Only ordinary owned endpoint/key values enter control storage;
geometry and shared Interaction remain in their mandated fields. Existing actual
control provenance/join checks remain authoritative for both constructors.

The next design must spell out this lifecycle before source work:

1. Original typed CounterControl initialization creates an empty runtime slot.
   Before active construction require it empty. Construct the endpoint in that
   final typed field from the same validated endpoint configuration. Complete
   identities start absent. Do not first construct a second full payload local.
2. Pipeline operations access that original field directly, with private typed
   operation/mutation seams where needed. An endpoint offer must not hold an
   overlapping whole-control or whole-pipeline mutation while its synchronous
   producer touches other fields. The existing admission `_modify` is useful
   precedent, not proof of this more complex callback's exclusivity/codegen.
3. Keep `lastFrame` separate: it is the latest accepted-frame oracle. Reusing it
   as in-progress recording would corrupt refusal/pending and zero-effect checks.
   All 64 glyph records, all snapshot fields and positive/negative effects remain.
4. Quiesce/finish transferred frame before clearing the endpoint. Clear exactly
   the single slot before handing off retired semantic/geometry/Interaction.
   Every early activation failure and repeated teardown must reach the same
   once-only disposition; inert paths must not clear an unowned active payload.
   Retirement still resets semantic, geometry, then Interaction, backing last.
   The ordinary owned `returnWorkspaces(checks:)` consumption path must clear
   this same slot too; implicit destruction of the old inline endpoint must not
   become retention until the enclosing control owner eventually ends. Both
   Static and Dynamic host aliases use this shared pipeline implementation.
5. Fresh session/reconstruction must see an empty slot, no stale keys/endpoint
   phase, and original origin/address. Extend owned observations and all relevant
   empty/zero-effect checks to cover the new slot without returning a capability.

This is a proposed within-contract realization using the existing control owner,
not approval to implement it. Independent design review must confirm the original
control lifetime bounds every new operation and cleanup path. If it instead needs
another physical owner, escaping pointer, relaxed protocol or altered state case,
stop and seek the precise SPEC-013/015/ADR amendment rather than hide that choice.

The gain has a concrete physical cause: remove about 2,692 data bytes plus changed
packing from repeatedly materialized pipeline/state/host carriers. It is not a
prediction of a 2,692-byte stack reduction or fit. The cost is retained storage in
each of four original control regions: 4 × 2,692 = 10,768 payload bytes before
Optional/slot packing and alignment. New exact layout may differ and must be
measured; 32,000 is the old derived minimum, not an immutable resource ceiling.
All four slots and the full C reservation remain charged. As illustration only,
adding 10,768 to historical image RAM 159,744 gives 170,512, leaving 26,096 under
196,608; this is neither a new image measurement nor sufficient resource proof.
No stack or total RAM limit is changed. Native Dynamic must use the same logical
slot policy with its actual bounded retained/allocation costs, not a hidden COW
alias or an unreported extra allocation.

## Other options and validation boundary

Compact recording (64 initialized glyph records plus a presence mask) could save
roughly 248 payload bytes versus 64 Optional strides, but needs unchanged complete
observations and has no credible evidence of closing the 39,216-byte path excess.
Sharing the accepted-frame slot would weaken behavior. Eliminating owned keys or
mandatory enum payloads, adding reference boxing, or moving runtime state behind
an unchecked scoped pointer is an upstream contract choice. Raising the stack
alone remains unsupported by the current lower bound and historical RAM arithmetic.
Compiler/toolchain changes are outside this package.

Bounded candidate files: `CounterPipelineOwner.swift` (typed payload, constructors,
access/retirement/reset), `CounterScopedStorage.swift` (full lifecycle/reuse
observations, empty checks), and `StaticCounterEmbeddedBacking.swift` plus C
reservation source (only if newly measured complete layout requires it). Keep
`CounterHostState`, both core coordinators, Interaction types and logical capacities
unchanged. Update exact applicability/driver pins only with actual seven-component
source exclusions; changed compiled sources never qualify for reused controls.

First screen after a separately approved source freeze, using the existing recipe:

```sh
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded --corpus rfc-014-counter --runtime-build .build/nrf52840/contracts/spec-013-runtime-cycle/tmpnueg79c8/nrf52840-embedded --host-build .build/contracts/p08-scoped-host-hzs5q7za --fresh-focused --select-family so07-layout-facts
```

Review actual object path frames for construction, stale rejection, current action
and cleanup, including all caller homes, before expensive corpus/image work. A
required lower bound over 27,648 rejects fit immediately. A promising lower bound
does not pass: all feasible nesting/IRQ and current linked RAM/flash/ABI/zero-heap
proof remain required. Native Dynamic/Static full behavior and exclusivity must
exercise moved initialization/reset, every failure, original producer/namespace
reuse and complete positive twins. Pi ABI/layout and all 384/202 compiler labels,
5 native controls and 26 reuse labels remain required on changed compiled source;
focused screen omissions cannot become complete coverage. No further compiler
experiment is needed to finish this assessment; source review precedes any candidate.

Recommended decision for the next package is therefore this original-control
payload realization with unchanged contracts/ceilings, rather than a budget
increase or new protocol ownership model. Its retained-memory tradeoff is real
and explicitly charged; fit remains an experimental outcome. If independent
design review cannot establish exclusive original-control ownership, the minimal
upstream question is permission for a distinct typed endpoint/key workspace and
its lender/retirement contract in SPEC-013 S13.1 and SPEC-015 S15.1. That fallback
is not selected here and must not silently change the mandated state payloads or
SPEC-011's six named scoped protocols.

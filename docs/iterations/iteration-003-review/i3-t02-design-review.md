# I3-T02 runtime design review and adoption sequence

**Verdict: not ready for RFC approval or production implementation.**
The bounded design package is delivered with named blockers. This is an
executor self-review of [draft RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md),
not independent reviewer approval or target validation. Initial design commit:
`2d0a034d`; the final review commit also contains the corrections below.

## What this step established

- One runtime decision boundary is now separate from RFC-013's external package,
  API and setup decisions, under accepted PROPOSAL-007 and I3-04. Both RFCs remain
  draft. Existing implemented owner Specifications and accepted ADRs remain
  authoritative; no current Spec was edited to adopt the proposal.
- The draft specifies emitted records, exact cross-revision path identity,
  model/capture access, callback isolation, failure/publication/teardown, and
  explicit simultaneous storage. It preserves the current modules and the
  corrected scheduling/raster/layout behavior from I3-T01.
- The analyzer reservation sketch includes a fourth 6,464-byte snapshot for
  staged replacement, with a conditional total of 120,928 bytes. The counter
  sketch totals 30,368 bytes. Both are unapproved and unvalidated proposals;
  incomplete codec, external model ownership and stack obligations prevent a
  feasibility or memory-improvement claim.
- No build, benchmark, firmware operation or experimental invocation occurred.
  No SPIKE-067/068 budget was reopened. Source review and arithmetic do not
  replace compiler, target, lifetime or connected evidence.

## Review findings and resolution

| Finding | Severity / location | Resolution in final draft |
| --- | --- | --- |
| Fourth capture slot contradicts an accepted architectural decision | Blocker; Capture access / Memory; ADR-034 | Added B0 and explicit ADR-034/RFC-012 references. Either seek a reviewed architecture amendment preserving retention, or demonstrate a safe three-slot replacement design. Specs/limits cannot change first. |
| An all-pairs identity comparison could violate SPEC-006's linear-expansion requirement | Blocker; Runtime records / Performance | Removed as an implementation option. Proposed paired path-trie traversal with a fixed vocabulary fanout; exact counts, bound and implementation evidence remain B2. Record indices are never persistent identity. |
| Registration retirement does not prove the application released its model | Blocker; Model storage / Capture access / Memory | Require both framework and application ownership to end before slot reuse. A live/staged pair and four captures are insufficient if retired models remain externally owned. The actual finite pool bound and failure behavior remain B1/B2. ADR-024 is preserved. |
| A view carrying runtime leases or packed firmware representation into Domain would reverse ownership | Blocker; Capture access | Require a typed application read boundary with target-supplied storage adaptation; no runtime module, firmware offsets or packed record format in Domain/Presentation. Exact declarations remain B1. |
| `borrowing`, a generation token and Void callbacks do not establish non-escape by themselves | Blocker; Non-escape boundary | Explicitly retained as B1. Successful native tests cannot settle it. Exact supported binding/lowering and all framework-owned escape/callback routes need evidence. |
| The reservation sketch is not a complete resource proof | Blocker; Memory / Binary Size | Exact path prefixes, payloads, copied interaction keys, model/control storage, capture size, external model pool and complete stack remain B2/B3. No uncharged headroom or implicit limit increase. |
| Removing generated graph inputs is distinct from removing all code/resource generation | Adoption blocker; Compatibility / B4 | Require producer/consumer inventory and declaration perturbation. Fonts, typed roles and finite syntactic Canvas/model lowering may remain; expanded topology may not. |
| Current nRF 4 MHz transfer exceeds the frame budget independent of graph construction | Iteration performance blocker; Backend / Performance | Preserved. This package selects no SPI speed, framebuffer, damage strategy or requirement waiver and makes no four-FPS claim. |

Non-blocking suggestions: keep the first record codec easy to inspect; avoid
adding indexing beyond the linear identity requirement before a measured need;
reuse current oracles where their assumptions still apply. These are optional
implementation choices, not additional studies or commitments. No new optional
feature was discovered that needs a Future Work record.

## Contract-change map

These are proposed amendment boundaries, not already approved changes.

| Owner | Clauses / criteria affected | Required change or proof |
| --- | --- | --- |
| SPEC-001 | Portable capture/presentation declarations, retention resources; SA-AC-008–015, 021–025, 028–031, 039–040, 045 | Keep owned capture semantics; specify separate frozen read view, replacement storage and portable waveform adaptation. Preserve 404 records/five seconds and source/state/action behavior. |
| SPEC-006 | Structural identity, expansion/work limits; DV-001–011, 013, 015–017 | Preserve exact identity and linear work. Specify any new storage/record contract only if existing SPI cannot represent it; no relocation of semantic authority. |
| SPEC-010 | Public bound State access, registration and lifetime; OS-001–012 | Resolve concrete Static model/context/lowering, non-escape, external owner lifetime and callback isolation without hiding API changes. |
| SPEC-011 | Committed identity/target records; IN-003–013 | Prove identity keys survive bank reuse and refusal; keep target/action generations and one-shot typed dispatch. New key layout may be private; any changed contract needs review. |
| SPEC-012 | Static capture lowering and cycle lifetime; DR-001–005, 007–013 | Admit the exact scoped capture-view representation, prove capture-at-declaration meaning and per-occurrence release; preserve fixed table/source-lowering requirement. |
| SPEC-013 | Exact storage audit, stage sequence, failure/recovery; RP-001–015 | Review proposed record/payload/path/control budgets and lease checks, both profiles, bank swapping and complete byte/stack accounting. |
| SPEC-015 | Host workload/presets, validated ownership, quiescence; HC-001–006, 009–018 | Exact analyzer replacement resources and independently derived counter workload/resource bounds; supported source/build inputs and platform facts. |
| SPEC-007/008/009/014 | Existing layout/render/execution/backend contracts | Regression owners; no amendment selected by this RFC. If implementation exposes a contract conflict, stop that choice and route it explicitly. |

The proposed fourth-slot branch explicitly conflicts with ADR-034, which says
“No fourth buffer or heap fallback is introduced.” Existing authority remains
binding. An ADR-034 successor/amendment is required for that branch; the design
alternative is a three-slot replacement with complete failure/lifetime proof.

Potential ADRs after RFC approval: runtime record identity/publication and scoped
model/capture ownership. No ADR was authored as accepted or inferred from source.
If final API/lifetime decisions conflict with an accepted ADR, amend that
architectural decision explicitly before any dependent Spec approval.

## Conditional implementation order

All rows below are **blocked for production**. The same rows are linked from
the affected per-Spec plans; historical approved tasks retain their dispositions.
This dependency sequence is not a ready plan or a new execution authorization.

| Order | Scope and owner | Prerequisite | Completion evidence |
| --- | --- | --- | --- |
| R0 | Resolve B0 capture-slot architecture direction, then close B1/B2 declarations, ownership/cardinality and exact application resource proposals | Review of RFC-014; any proof experiment requires an explicit bounded recipe and separate authorization | Concrete binder/read-view contract, lowerable source shape, complete model owner/pool lifecycle, exact codec/count budget for both apps; no proof by annotation |
| R1 | RFC decision → ADR extraction → affected Spec amendments | Resolved approval blockers and explicit human approvals at each gate | Accepted architecture and approved declarations/limits/errors; then ready per-Spec task sections |
| R2 | Runtime record builder, exact identity and independent semantic oracle (SPEC-006/013) | R1 | Both bank and branch-shift tests, linear work bound, bounded failures, no pre-expanded graph inputs |
| R3 | Typed model/context, capture lease and transaction cleanup (SPEC-010/012/013) | R1; join with R2 | Replacement/removal/external-alias cases, callback isolation, actual compiler non-escape/no-heap evidence, exact release trace |
| R4 | Finite counter composition (SPEC-011/012/013/015) | R2/R3, approved counter bounds | All ten values and complete action/Canvas workload; state/identity/pixel parity; separate target compositions |
| R5 | Analyzer read-view adaptation and runtime host migration (SPEC-001/011/015) | R2/R3; reuse R4 integration mechanisms where contracts match | Existing capture/action/failure/pixel oracles, generated graph inventory removed, all four hosts use actual traversal |
| R6 | Complete integrated adoption validation | R4/R5 and exact frozen artifacts | Four-profile owner gate, exclusive byte ledger, full feasible-path stack/IRQ bounds and matched memory evidence; independently authorized connected workload checks |

R2 and R3 may inform each other but neither authorizes bypassing R1. Counter-first
integration reduces application complexity; it does not waive the analyzer or
turn counter success into complete stack/lifetime evidence for the larger app.
Iteration-3 delivery is not complete if the 4 MHz performance gate remains
unresolved; its remedy is an explicit adjacent decision, not an extra R6 repair.

## Next actionable decision

Resolve **B0**, the concrete architecture direction: permit the proposed fourth
snapshot through an ADR-034 amendment, or retain three slots and require a
proved replacement protocol. In either branch, **B1** still needs the concrete
supported Static binding/capture-read lifetime and **B2** the external-model
ownership bound. These choices are not approved by the instruction to draft
the design. B1 work can proceed without selecting the fourth-slot branch;
the current three-slot contract remains the default until explicitly amended. The draft
identifies the exact existing APIs and escape paths; it does not supply compiler
proof. Before authorizing any prototype, fix its concrete API candidate, complete
source/composition boundary, required negative cases, target compilers and one
numeric invocation/repair/time ceiling. Do not restart the archived aggregate
candidate or launch another general feasibility review. This package requests no
RFC approval while these blockers remain.

## Validation and disposition

`scripts/validate-governance.rb` and `git diff --check` pass for this documentation
package. Local links, reciprocal Proposal/RFC/manifest references, resource
arithmetic and all seven conditional per-Spec sections are checked. Production
source and approved Specs are unchanged; the I3-T01 74-check result remains the
last code validation and is not relabeled as validation of RFC-014.

I3-T02 finishes as **design delivered with named approval/adoption blockers**.
Its final time accounting and commits are recorded in the
[current activity plan](memory-efficiency-plan.md#i3-t02--runtime-derivation-design-package).

# RFC-014 C: application storage and ownership ledger

> **Revised working direction, 2026-10-10:**
> [Stable reads without a mandatory snapshot copy](rfc-014-stable-read-revision.md)
> supersedes this document's separate frozen-bank baseline and its assumption
> that the frontend must derive concrete Body aliases. The remaining text
> preserves the previous candidate and its evidence; it is not the current
> implementation direction. Lifetime, ownership and source-coverage questions
> remain open. No accepted contract changed.


Current accounting: [SR-Q4](rfc-014-stable-read-revision.md#sr-q4--storage-copy-term-removed-retention-policy-remains-open)
removes F0 under the same K=2 non-sharing assumption: four banks / 25,856
transition bytes. This remains one bank above ADR-034, before other costs, and
is conditional arithmetic rather than a measured or accepted allocation.

**2026-10-10 — proposed capacity contract, not approved limits or measured RAM.**
Parent: [RFC-014](../../rfcs/rfc-014-runtime-derived-records-and-scoped-model-access.md).
Read with the [C access/lifecycle contract](rfc-014-c-contract.md) and
[source ownership audit](rfc-014-ownership-audit.md). No experiment was run.

## Proposed finite application capacities

Use the same model cardinality proposal for both selected applications:

| Resource | Proposed maximum | Meaning |
| --- | ---: | --- |
| Allocated current model slots K | 2 | Installed, newly created/staged and detached application-owned models all compete for these two slots. No hidden third slot. |
| Frozen model slots F | 1 | One frame's one root model; frozen properties have distinct backing from current. |
| Simultaneous frame epochs | 1 | Release all earlier frame access before another freeze. |
| Application owning tickets | 2 | At most one unique application ticket per allocated model in this candidate; non-owning identity copies are not additional tickets. |
| Active root State associations | 1 | Stable root of each selected application; candidate replacement does not create a second structural location. |
| Registration reservation during replacement | 2 | Old active plus attaching candidate; existing registration-generation semantics apply. |
| Per-Canvas model owner tickets | 0 | Concrete payload stores safe identity/epoch; one frame owner covers every read. |
| Analyzer Canvas occurrences / concrete types | 5 / 2 | One grid plus four channel traces; type count differs from occurrence count. |
| Counter Canvas occurrences / concrete types | At most 1 / 1 | Zero in the non-Canvas mode; one in the Canvas mode, even when value zero emits no stroke. |

K=2 does **not** promise installed + detached former + another candidate at once.
If a former application owner remains, both current slots are occupied and the
next model creation/replacement is refused before association changes. The frame
can still render the installed model because F has independent backing.
This explicitly supports one retained former model without pretending an
unbounded replacement history fits. Larger capacities require declared storage.

For native Dynamic, aliases of the same retained class ownership object refer
to one owning ticket whose release occurs when its last owner releases it.
Static proposes one noncopyable application ticket and copyable safe keys.
The exact cross-profile ownership API and Static caller-storage lifetime must
be proven: ordinary class-shaped schema syntax does not automatically implement
that ticket protocol. Ownership ends through the owner API, not by destroying
a View or detaching its sink.

Both portable workloads have one root observable state in this proposed source.
The maintained analyzer has one `@State` declaration; the counter's single root
is a workload requirement, not evidence from a finished counter implementation.
F=1 excludes two distinct model identities participating in the same frame.
A source change adding a second state/model reader must update capacity or fail
binding before the new reader runs; it cannot borrow an uncounted second bank.
Old/new locations during structural migration are separately capacity checked.

## Analyzer mapping and exact transition-backing cost

| Physical bank | Role | Transition bytes |
| --- | --- | ---: |
| S | Acquisition repository live capture | 6,464 |
| A | Existing admission snapshot backing | 6,464 |
| C0 | Current model slot 0 | 6,464 |
| C1 | Current model slot 1: candidate, installed or retained former | 6,464 |
| F0 | Frozen frame copy of whichever current slot is installed | 6,464 |
| **Reserved transition backing** | **5 × 404 × 16** | **32,320** |

This is **12,928 bytes more** than ADR-034's approved three-bank 19,392-byte
reservation. It is an explicit B0 architecture proposal, not an allowed change
to current constants. Two model slots do not each receive a permanent frozen
copy: only the one frame-participating model uses F0. Detached models retain
current data and application ownership but have no frozen bank by default.

Each current/frozen bank also needs owned capture count, duration, retained
lower bound, four channel baselines and revision metadata. The proposed analyzer
schema contains acquisition state, visible window, diagnostic, capture revision
and the separate presentation capture field. Keep the capture revision and
its metadata consistent; do not independently snapshot duplicate state fields.
All model, ownership, registration, model-value revision, dirty, frame-map and alignment bytes are
additional and remain B2 layout obligations. No reuse of RFC-014's earlier
1,024-byte model/control estimate is assumed.

Current publication/fact APIs still use owned Domain values. Any Dynamic
copy-on-write sharing may reduce actual copying only if immutable backing and
peak retained allocations are accounted for; it does not reduce this Static
reservation by implication. Physical admission/fact queues remain separate
from A; their existing bytes are not replaced by this table.

The eager freeze copies at most 6,464 transition bytes plus metadata for the
one analyzer frame model. At four freezes per second that term alone is 25,856
bytes/s of copying. It excludes source/admission/model updates and replacement
copies and makes no CPU, stack or deadline claim. Copy by bounded indexed
operations; do not construct a full capture-valued Swift temporary on the stack.

## Counter mapping

C0 and C1 each store the one current `UInt8` value in 0...9; F0 stores the frozen
value. Their property payload is **three scalar bytes before metadata/alignment**,
not three bytes of total model storage. Model/owner/frame identities, registration,
dirty and result state still need measured fixed layouts. The ten bounded strings
and Canvas code belong to their own tables, not to each property bank. The
counter imports no analyzer capture pool, acquisition owner or transition ABI.

Its application-owned update, Increment/Reset and root-replacement transcripts
use the same sequencing below. Retaining an old counter model consumes C0/C1;
there is no reason to allocate a 404-record capture for it.

## Replacement and frame ledger

S and A are permanently reserved in every analyzer row below and are not
reused for model/frozen data. “Free” describes a role's unused reservation,
not bytes returned to a heap. Scalar counter banks use the same roles.

| Boundary | C0 | C1 | F0 / readers | Required result |
| --- | --- | --- | --- | --- |
| Before materialization | Free | Free | Invalid / none | No public model access; inert seed only |
| Root A installed | A current, runtime association plus application ticket | Free | Invalid / none | One registration; frozen revision absent |
| Freeze A | A stable current | Free | Complete copy of A, epoch E / frame owner | Mark ready only after metadata and backing copied |
| Body, Layout, grid + four trace occurrences | A stable current | Free | A(E), immutable / same frame owner | Repeated trace types/keys do not create model owners or extra frozen captures |
| Canvas success or any draw failure | A current | Free | Release all readers/staged values, then invalidate | No partially derived plan offered; mutation not rolled back |
| Begin replacement A → B | A current and active registration | B candidate current, reserved ticket/registration | Invalid / none | No live frame or Canvas borrow during replacement |
| Candidate attach fails | A unchanged | Candidate registration undone; reclaim B only if no application owner remains | Invalid / none | Preserve association A; an independently owned unattached B still consumes C1 |
| Attach succeeds; association commits | A detached; reclaim if no owner, otherwise retained current | B installed current | Invalid / none | Retire A registration; retarget host current-root routes now |
| Freeze/draw B while A retained | A retained by application | B installed | Complete B(E+1) / one frame owner | Valid at K=2, F=1; A cannot be silently overwritten |
| B derivation subsequently fails | A retained or free | B still installed and dirty | Discard frame copy/readers | Do not revert association to A or replay replacement |
| Request replacement B → C while A retained | A retained | B installed | Invalid / none | Refuse reservation before candidate attachment; no third current model exists |
| Release last A ticket | Free after all A owners/pins end and a permitted owner boundary | B installed | B frame, if active, finishes first | Defer control mutation/reuse until the owner can perform it safely; never release B's bank |
| Retry replacement B → C | C candidate | B installed until commit | Invalid / none | Reuse C0 with fresh allocation generation; old A keys remain stale |
| Publish root removal | Detached model current only if still owned | Other owned slot if any | Release after final frame access | Retire association at publication; discarded candidate does not remove root |
| Teardown | Release only after owning tickets end | Same | Drain/cancel, release contexts/values first | Caller storage must outlive outstanding owning tickets; safe-key copies alone cannot read it |

A failed replacement's new model can be independently application-owned before
attachment. Its ticket is returned/preserved on failure rather than destroyed
by the runtime. If the host created it solely for this attempt, the host releases
that ticket as part of failed-attempt cleanup. Capacity checks count both cases.
A construction failure reports the proposed `modelStorageCapacityExhausted`;
replacement adapts the same lack of a candidate slot to existing
`replacementStagingCapacityExhausted`. Exact code allocation belongs in Spec review.

## Host migration needed to realize the ledger

- **Lifecycle/status/acquisition:** replace long-lived cached model objects with
  a typed current-root route plus the host's explicitly managed ownership ticket.
  Keep stable service ownership separate from model versioned data.
- **Failure effects:** replace the failure owner's `let model` capture with the
  same current-root route. A failure recorded while frozen cannot mutate current
  through that route immediately. Release/drain the frame, then apply the effect
  through the coordinator's authorized mutation path, preserving the existing
  failure policy/order. Its exact adapter sequence and bounded pending-effect
  storage are C-P3 evidence obligations; do not introduce reentrant cycles.
- **Presentation attempts:** store a frame-stamped non-owning model identity in
  the attempt. It always addresses the attempt's frozen map. A successful
  interaction commit must not be the mechanism that eventually retargets host
  services; replacement already did that in the mutation phase.
- **Embedded model location:** replace the single current slot assumptions with
  the typed K=2 pool and F=1 frame map. Existing raw model/report handles cannot
  become the public copied fields of Canvas. Registration and model allocation
  generations remain separate.
- **Counter host:** construct the same finite ownership roles independently,
  including application-owned mutation/replacement and stale-input rejection.
  The old declaration-only probe is not a runnable implementation of this design.

New source must prove these changes across all four configurations. The source
audit identifies the required changes, not evidence that they have happened.

## Alternatives and decision boundary

| Storage realization | Benefit | Obligation / disposition |
| --- | --- | --- |
| **Five-bank non-sharing baseline** | Straightforward current/frozen copy plus retained-old replacement; explicit ledger above | Working candidate for contract/evidence; requires ADR-034 amendment and complete B2/B3 proof. Not approved. |
| Reuse staging bank as frame backing | Can reduce some non-overlapping reservations | With A retained and B installed, both current banks are occupied while B still needs a frozen copy. Simple four-bank reuse does not implement the above K=2/F=1 behavior. Reject that shortcut without a different proved policy. |
| Alias current and frozen while mutation is prohibited | Could avoid the extra frame copy/backing | Requires whole reachable-state immutability, safe read access and strict no-overlap proof. It changes the physical realization, not two logical views. No such proof is supplied or selected here. |
| Versioned/COW sharing or delta propagation | Potentially fewer copies or occupied banks | Needs an explicit complete lifetime/update/peak-capacity algorithm. No hidden allocation or history is permitted. It is not needed to specify this baseline. |

The contract does not add a fourth or fifth bank to production. Before B0 approval,
choose the resource branch on complete accounting and evidence. The old
120,928-byte arithmetic cannot be carried forward by adding 6,464 alone:
model schemas, owner tickets, frozen maps, dispatch payloads and actual stack
must all be re-accounted. The independent 4 MHz performance failure remains.

No correctness obligation is deferred. The alternatives stay in RFC-014 until
its storage decision is made; none opens a new experiment or optimization task.

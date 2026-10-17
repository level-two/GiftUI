# Independent final correction boundary review — 2026-10-17

**Evidence PASS; earliest compile/privacy FAIL confirmed. Activity stopped.**
Reviewed `3ae67711` against the [final-cycle design amendment](p08-native-cold-pipeline-correction2-design-review.md)
and [frozen failure packet](native-cold-pipeline-correction2-result/README.md).
**2/2 corrective cycles are exhausted.** The partial source overlay remains
unaccepted/not adopted. No third candidate, compiler/runtime retry, source repair,
restoration or allowance reset follows from this review.

## Verified result and scope

Offline verification passes all27 archive members. Current four macro source
hashes and the unchanged authored Counter.swift/schema hashes match the record;
external five-file hashes and complete diff hash also match. The maintained change
is confined to the approved finite lowerer: ABI attributes on generated finite
nominals/signature dependencies, without editing authored Counter.swift or private
State. It does not introduce the prohibited new backing/alias/projection mechanism.
This is scope verification of a failed attempt, not full source acceptance.

The presentation compiler reports24 errors, including exactly five direct private
backing violations:

- Generated evaluate reads `_model._giftUIKey()` four times: the displayed value,
  increment-disabled condition, reset-disabled condition and Canvas model key.
  Error sites are generated Counter.swift63,64,65,66; each points back to the
  unchanged private `@State` declaration at52.
- The generated declaration visitor passes `&_model` at macro expansion line6.
  This is access to the original state wrapper, not a copied or substitute owner.
  It too is rejected from an inlinable function.

The remaining facade initializer/getter, Canvas field/initializer and State-key
ABI-visibility errors are unfinished dependencies; repairing those alone cannot
remove the private backing violations. A compiler's rejection here is not a
passing private-client negative control. No new presentation module/object exists,
so no physical body presence, concrete consumer, privacy/lifetime/partial-init,
Layout/other-owner qualification, actual cold/reuse, allocation, suite or image
gate ran. Macro/lowering/schema success proves only that preparation.

The record candidly preserves an attribute-trivia preparation fix, two macro
compile/link and two schema compile invocations. Those occurred before the first
presentation gate; that material gate failed once and was not retried. This does
not conceal another corrective cycle or renew the exhausted allowance. Earlier
runtime/image/resource receipts qualify their frozen revisions, not this overlay.

## User decision and recommended direction

The strict contract remains authoritative. **Recommend renewing a narrowly bounded
strict implementation activity for checked State serialization while retaining
privacy**, rather than amending the contract on this evidence. No general
impossibility, necessary heap exception, required unchecked API or compiler defect
has been established. The ABI-usable enclosing nominal solved an identified
eligibility prerequisite but exposed this next incompatible direct access shape.

A renewed design must specify the exact checked declaration/read boundary that
keeps authored State private while making the required concrete operation usable
across serialization. It must identify the lowerer/member-macro/State declarations,
actual original wrapper borrow and mutation/read exclusion, provenance and failure
ordering,14 original loans/Optional lifetime union, cleanup and generated access
controls. It must demonstrate why its checked boundary can specialize without
copying State, introducing a second owner/alias, exposing backing or creating an
unchecked capability. Keeping private access inside its owning implementation and
serializing only checked forwarding is a design direction to assess, not an
already approved or demonstrated solution.

That decision needs a concrete new activity/allowance record and independent design
review before execution: exact candidate/source boundary, finite repair count and
compile/privacy/physical-body/actual-host cold-screen stops. This review grants
none of those extra attempts. Do not disguise new implementation as another
diagnostic. No broad suite is needed before an early safety/feasibility gate.

Contract amendment is a separate user choice only if the user wishes to relax a
normative requirement, or a later concrete design requires changing source privacy,
scope/ownership/lifetime APIs, zero heap, required exclusivity or compiler/runtime
policy. Route that actual change through its ADR/Specification authority; the
present failure provides no basis to waive it implicitly. More internal design
work or more files alone is not such an upstream change.

Current P08 block: no accepted compiling strict Native candidate, with the active
source experiment stopped at private State serialization and no remaining repair
allowance. P08/R07/T8.1 and SPEC-015 conformance remain open. Other owner/codegen,
private-client/lifetime, affected-profile/image and complete rooted allocation,
Native/Pi stack, Dynamic/physical-cost and caller/exit ledgers remain required after
a future accepted candidate; they are not silently closed or deferred into P09.

Review performed existing-artifact/source inspection, offline verification and
documentation checks only. No compiler, decoder, workload, source edit, cache
mutation or restoration. Governance, links and whitespace pass. External five
files and existing pycache remain untouched. **Stop this activity here.**

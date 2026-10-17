# Independent checked State serialization design review — 2026-10-17

**Design PASS, with the recorded structural matching clarification.** Reviewed
design/activity commit `96a1dabe` independently against current source and accepted
authority. The derived note is amended in this review; its original author and
provenance remain intact. No maintained source, compiler, decoder or runtime work
occurred. New initial candidate **0/1**, corrective cycles **0/2**, material gate
attempts **0**. Historical Native cold pipeline **2/2** remains closed, and
`3ae67711` remains an unaccepted overlay. No implementation or resource PASS follows.

## Authority and boundary

SPEC-015 is implementing and its implementation plan active. ITERATION-003
revision 5 I3-04/I3-05 requires the finite counter dependency path before analyzer
migration; ITERATION-001's common application/macOS Static validation remains the
reference requirement. Consulted FEATURE_LIFECYCLE, AI_AGENT_RULES, documentation
and iteration rules, implementation-designer/spec-reviewer/deferred-work-curator
guidance, SPEC-006/010 scoped View/visitor contracts, SPEC-013/015 scoped ownership
clauses and accepted ADR-036/039/040. ADR-040 changes counter physical SRAM only.
No missing upstream approval is identified for this internal realization. P08,
R07/T8.1, all affected conformance/resource/exit gates remain open.

## Findings and disposition

- **Original wrapper and lifetime semantics: compatible design.** `_modify` yields
  the actual private field inside the existing bound transient declaration; it
  adds no wrapper copy, alias, owner or get/set writeback. `_read` borrows that
  field, and the opaque key helper returns only the existing inert key after
  `_giftUIKey` checks binding. Existing facade checks still validate phase, owner,
  schema, occupancy and allocation generation. Four authored key reads retain
  order and errors. No read context, binder, capability or closure crosses the
  opaque fixed-schema seam. Exact field identity, exclusive self access and every
  coroutine end/unwind must be established in gate 3, not inferred from spelling.
- **ABI usability: internal implementation boundary, not a contract amendment.**
  Making State.Storage/storage internal ABI-usable permits serialized existing
  checked operations to reference their implementation. It grants no source
  access to another module; existing package bound/initial/key operations retain
  package access and no unchecked constructor becomes public/package. State's
  initial/bound single-case representation and public signatures are preserved.
  This creates an internal ABI commitment for emitted clients, whose matching
  rebuild/identity is already required; it selects no new supported client API
  or ownership boundary. Added review text explicitly forbids incidental
  `@frozen`/layout or constructor exposure and requires same-package and external
  client negatives without privileged imports. Failure to compile while honoring
  these restrictions is an attempt failure, not authority to widen access.
- **Helper selection omission: corrected in the derived note.** Names/signatures
  alone could select a computed projection of another wrapper or an unchecked
  key helper. The reviewed design now requires lowerer input-collision rejection,
  unique same-nominal/same-State structural matching, exact original-field yield
  and checked-key bodies, and diagnostics for malformed reserved members. No
  substring heuristic, application name, cross-expansion cache or unprovable
  generated-origin trust may select the route. Negative controls cover swapped
  fields, wrong schemas, incomplete pairs, overloads, replacement/get-set bodies
  and lookalikes; multiple/nested positives protect lexical ordinals. Public macro
  names and protocols remain exact. Ordinary inputs without reserved members keep
  the existing direct route. This resolves the design omission before source;
  implementation must prove it rather than claiming tests already passed.
- **Strict feasibility: unresolved and correctly gated.** A concrete schema does
  not prove that generic `CounterScreen<D>` access needs no Self metadata,
  coroutine context or dynamic exclusivity TLS. Opaque helpers may retain those
  costs; serialization of State enum operations may also require seed/bound
  metadata, conformance, destruction or Optional handling. The actual consumer
  object/call graph and continuation/unwind paths must reject allocating lookup,
  context, TLS or hidden copies. Static nongeneric D metadata is permissible only
  with evidence that no allocating lookup is used. Added text distinguishes an
  opaque serialization boundary from an optimizer policy; disappearance of a call
  is not cost proof. No prewarm, merged module, synthetic domain, generic opaque
  callback, metadata waiver or disabled exclusivity is selected.
- **Owned storage invariants: retained.** No amendment changes fourteen original
  simultaneous actual-owner loans, private provenance, Optional destination and
  complete lifetime union, frame mutation exclusion, first-failure suppression,
  reverse successful-prefix unwind, quiescence or consuming backing-last release.
  The safety gate must requalify these on affected source; old receipts do not.

## Actionable continuation

The author may proceed sequentially within the existing activity: freeze the
combined exact file/function inventory, implement this one candidate, format,
then run the smallest fresh actual-counter provider/privacy screen. Stop on its
first material failure and preserve the failed attempt before any grouped repair.
Next require physical evaluate/traverse/visitor bodies plus owning helper-object
definitions, and inspect the actual concrete binder/schema/domain consumer before
finishing the other named pipeline dependencies. Include only minimal named
Layout dependencies when the real consumer requires them; additional dependencies
need a recorded design amendment, not an annotation sweep or new allowance.

Only then run the focused safety and unchanged ordinary/host-first cold/reuse
screens with exact counts, windows, baselines and complete stacks. Actual Static
allocation at construction, actions or teardown fails. A focused pass permits the
affected registered profiles/images, complete allocation/Native-Pi stack/physical
ledgers, matched Dynamic costs, caller reconciliation and independent P08 exit.
The allowance/progress guard remains exactly as recorded in the activity; source
work begins its initial candidate and is not authorized by this review alone.

Documentation/links/governance/whitespace checks are recorded with this review's
commit. The five external modifications and existing pycache are excluded and
untouched. No restoration, deploy, flash or global toolchain change. No deferred
item was created: remaining compiler/resource uncertainty blocks current acceptance.

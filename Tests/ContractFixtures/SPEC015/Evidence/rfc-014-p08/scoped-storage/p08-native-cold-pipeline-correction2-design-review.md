# Independent final grouped correction design review — 2026-10-17

**APPROVED for bounded corrective2 under the standing strict implementation
authorization.** Reviewed `24590caf`, its [physical decode and release rule](native-cold-pipeline-serialization-result/README.md),
the existing lowerer/member macro, State representation and prior design.
This is an evidence-backed internal serialization repair, not a compiler-policy,
architecture or contract change requiring renewed human approval. **1/2 corrective
cycles remain consumed at this review; corrective2 has not begun.** The first
source edit starts the final grouped cycle and records2/2 in progress. A failed
compile/codegen/safety/cold gate consumes it; no third candidate or reset follows.

## Independent evidence assessment

Offline verifier passes all34 archived members and the complete31-function index.
The six reserved identifier IDs, function-name hashes, FunctionIDs/bit offsets,
selected raw record prefixes and matching0/1003 schema agree. Traversal ID26 /
Function28 at bit167594 is `PUBLIC_EXTERNAL`, serializedKind0, with only two
argument-effect records and zero blocks. Evaluate ID30 / Function27 also has no
body; the control ID24 / Function3 has serializedKind1 and one block. The complete
index has no corresponding private read-closure body entry. This resolves physical
absence in this exact module, rather than inferring it from final consumer SIL.

Archived `DeclContext.cpp`587–605 requires public formal access scope before
honoring inlinable semantics. `Decl.cpp`5319–5322 treats ABI-usable declarations
as public for that calculation, and5485–5489 caps members by their enclosing
nominal. `TypeCheckAttr.cpp`3771–3785 permits `@usableFromInline` on internal or
package declarations. The generated package CounterScreen lacks that enclosing
annotation. This supports the proposed nominal change; `-enable-testing`'s
effective linkage does not remove the formal-scope restriction. The physical
declaration-only record and serializer rule explain why the frozen consumer
cannot obtain this body. No complete CMO rejection history, compiler defect or
whole cold-path feasibility is claimed.

## Exact derived design amendment and allowlist

The [existing pipeline design](../../../../../../docs/implementation-designs/spec-015-p08-native-cold-pipeline.md)
is amended only as follows. Retain all previous contracts and function-level
boundaries; these are additional directly required serialization dependencies:

- In `GiftUIMacros/FiniteSourceLowering.swift`, annotate emitted finite View/Canvas
  enclosing nominals with ABI usability while preserving original package source
  access. Actual targets are CounterScreen and CounterCanvas. Use the existing
  finite declaration classification, not an application-name special case or a
  blanket annotation of every struct. The attached member macro cannot rewrite
  its enclosing nominal; it retains ownership of generated method annotations.
  **Do not edit authored Counter.swift to insert these attributes.**
- In the same schema/presentation emitters, permit only the directly referenced
  CounterReadDomain requirements, CounterModelSchema/Seed and seed fields/checked
  initializer, CounterRead and its checked read/drawing initializers/getter,
  CounterAction, counterText, and actual generated model fields/typealias/checked
  accessors required by traversal/evaluate/draw serialization. Retain package
  source access for existing package declarations; ABI usability is not a reason
  to make anything public. Emit attributes on the transformed declarations through
  existing finite inventory rules. A named dependency is not permission to change
  its algorithm, effects, evaluation order or all adjacent declarations.
- Serialization-only module-internal storage/helpers may become ABI-usable when
  directly required; they must remain source-inaccessible to other modules.
  Keep the authored State property's privacy and checked read/bind behavior.
  Private synthesized backing is a real compile risk, not already solved by the
  nominal annotation. This review does **not** approve a new State backing
  representation, second owner/alias, manual unchecked projection, public/package
  backing access or unchecked scope initializer. If the existing checked mechanism
  cannot satisfy serialization/privacy together, stop the final cycle with that
  exact blocker rather than introducing another mechanism.

The generated facade retains `~Escapable`, exact `@_lifetime(copy read)` /
`copy drawingRead` and field/slots origins. No new source-callable constructor
may create a scope/read/provenance capability. Original fourteen simultaneous
loans, Optional destination and lifetime unions, capacity/identity/first-error
ordering, registration ownership, failure-prefix reverse cleanup and backing-last
retirement remain unchanged. Attributes may expose ABI symbols without granting
Swift source construction; required private-client rejection checks must verify
that distinction. No proof of it follows merely from this design approval.

## Final cycle execution order

1. Record the exact grouped source allowlist/diff and2/2 in-progress accounting.
   Retain the failed experiment and immutable baseline; do not restore or adopt
   it implicitly. Format maintained Swift. Build the changed macro tool, run its
   existing `lower-command.json` recipe, and compile matching generated schema /
   presentation with the existing frozen command recipes and unchanged pinned
   target/SDK/optimization/lifetime/package policy. Use fresh outputs/imports;
   never mix old generated interfaces or macro output with new source. No new
   compiler flag or alternative source candidate is hidden in preparation.
2. **Gate before wider owner work:** require compile success and focused positive/
   negative private-access/construction checks, including generated State access
   and facade provenance. Then use the already qualified physical decoder/index
   interpretation on the new presentation module. Require traversal/evaluate
   bodies and all needed read-closure operations, either serialized explicitly or
   demonstrably incorporated into those bodies. Hash/freeze the new module and
   records. No repeat of old import/observer diagnostics is needed absent a new
   concrete identity concern. Attributes or an empty ABI report are insufficient.
3. Compile the actual concrete consumer against those matching modules. Require
   the selected host path's formerly rejected generic/metadata seam to be resolved
   as designed, with its recursion/helper chain inspected. A common probe clone
   does not replace this check. Missing bodies or unresolved selected operations
   stop this cycle; no broad collection is justified by partial success.
4. Only after that early gate, complete the existing correction's named pipeline
   rows and matching changed owners. Include the known Layout private-inlinable /
   directly referenced serialization visibility errors in this same final grouped
   correction. They are not waived or a separate fresh allowance. Rebuild every
   affected owner/interface; candidate1/copied objects cannot qualify changed
   source. Preserve payload bytes/IDs/digests, physical layout and behavior.
5. Require all reviewed codegen rows, private-client/lifetime/overlap/partial-init
   controls and actual fresh ordinary plus host-first cold/reuse screens with the
   original baseline pairing/runtime identities. A strict heap or safety failure
   stops before full collections/images. Passing focused screens still leaves
   affected profile/image/ABI evidence, complete rooted allocation, Native/Pi
   stack, matched Dynamic/physical costs and caller/exit ledgers before P08 exit.

No declaration/file expansion beyond this amendment and the existing reviewed
pipeline map is implied. A substantive new ownership/API/algorithm or compiler/
runtime policy change needs its actual upstream decision; difficulty alone does
not create one. This review ran only existing-artifact/source inspection and the
offline verifier/document checks, with no compiler, decoder, runtime, source edit
or restoration. External five files and pycache remain preserved. P08/R07/T8.1
and SPEC-015 conformance remain open.

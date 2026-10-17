# Independent checked-State candidate1 and corrective1 design review — 2026-10-17

**Frozen failure evidence PASS; exact corrective1 design amendment PASS.**
Reviewed `ad9ae8de`, its [immutable packet](checked-state-candidate1/README.md),
current State/lowerer/member-macro source, the emitted schema/presentation and
their directly invoked serialization dependencies. Initial **1/1 consumed**,
new corrections **0/2**; historical Native pipeline **2/2 stays closed**.
Corrective1 has not begun. No compiler, decoder, workload or maintained-source
edit occurred in this review. Source remains unaccepted; no privacy/codegen/cold
or resource PASS is inferred.

## Verified failure and source boundary

Offline verification passes all46 archive members. All21 current compiled-source
files match the archive; five external and two authored source/schema hashes
match the initial freeze. The exact five invocations are macro compile, macro
link, lowering, fresh GiftUI compile (all PASS), then schema compile (FAIL).
The raw schema log contains one error: its serialized drawing facade initializer
calls package `DrawingError.init(accessFailure:)`, which lacks ABI usability.
No presentation or later gate ran and no hidden corrective variant is recorded.

Source inspection confirms private authored State and original-field `_read` /
`_modify` helpers remain opaque. The key helper uses the existing checked State
operation; four reads retain their positions. Member matching compares complete
syntax structure, owner-local fields/schema and the exact helper pair, consumes
each reserved member once and diagnoses lookalikes without fallback. The lowerer
rejects reserved authored collisions, including escaped identifiers. Added
multiple/nested and malformed-pair tests are still unexecuted. These source facts
do not substitute for actual macro/private-client or original-field-yield proof.

## Exact grouped dependency amendment

Add only `Sources/GiftUI/DrawingSurface.swift`, extension DrawingError,
`package init(accessFailure: _GiftUIAccessFailure)`, to the derived function map.
Permit **`@inlinable` on this existing initializer**, retaining package access and
its body verbatim. It implies the needed ABI usability; neither a public access
change, redundant mapping nor a forced-inline policy is needed.

The switch's complete dependency closure is public `_GiftUIAccessFailure` and
public `DrawingError` with their existing cases. It maps invalidPhase→invalidPhase,
wrongOwner/wrongSchema/staleModel→invalidModelAccess and outOfBounds→invalidValue,
exactly as [SPEC-012's approved access-error contract](../../../../../../docs/specs/spec-012-canvas-path-stroke-drawing.md#access-errors-and-migration-tests)
requires. It uses no private storage, descriptor, scope/provenance constructor,
generic callback, heap operation or owner/lifetime authority. Serializing this
checked finite enum map is a replaceable implementation change under the existing
ADR-036/039 and SPEC-006/010/012/013/015 contracts; no upstream amendment is needed.

Reviewed adjacent direct dependencies together: generated read-domain requirements,
schema/Seed, seed fields/initializer, facade slots/index, public Span, ABI-usable
FrameRead.slots, checked bind/getter calls and exact lifetime-copy annotations.
They are already usable or covered by the existing generated dependency scope.
Nested/indexed generator branches reuse this same error mapper; the actual scalar
counter introduces no other such branch dependency. State's serialized operations
depend on its already reviewed internal Storage/storage, bound/initial cases and
key fields. The generated Canvas key field/initializer, counterText/CounterAction
and opaque State helpers are also already named. No additional newly unallowlisted
direct dependency is identified by this read-only closure assessment; compiler
success and optimizer behavior remain unproved. Do not widen DrawingSurface's
unrelated path/context functions or enums.

## Execution disposition

The author may start corrective1 under the existing user-authorized activity,
recording the amendment and source freeze before the first maintained edit.
That edit consumes corrective cycle1/2. Format, then rebuild fresh GiftUI, generated
schema and presentation with unchanged flags/recipes and source hashes; complete
ordinary macro and separate-client privacy/checked-construction controls. Stop and
freeze on the next material failure before another source variant. A schema pass
alone does not accept this candidate or permit broad collection.

On complete provider/privacy PASS, follow the existing physical module-body,
owning-helper object and actual concrete binder/domain/host consumer gates. Retain
coroutine continuation/unwind inspection, fourteen loans, provenance, Optional
lifetime union, failure-prefix cleanup, exclusivity and strict construction/action/
teardown zero heap. Only then finish other named pipeline dependencies and run
the unchanged focused safety/cold screens. Broader profiles/images, full physical/
allocation/stack ledgers, matched Dynamic costs and independent P08 exit stay open.
No compiler/runtime policy, source privacy, schema or corpus change is authorized.

Governance, local documentation targets and whitespace checks pass. Five external
changes and pycache remain untouched. No restoration, deploy, flash or global
toolchain mutation. This amendment creates no extra allowance or deferred item.

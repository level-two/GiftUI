# Analyzer P02 ABI inventory and proposed bounded continuation

Date: 2026-10-18. Inspected HEAD: `655d22d8`.
Disposition: **documentation only; candidate 2 remains STOP**.

The [static continuation preparation packet](analyzer-abi-continuation-preparation/README.md)
freezes the proposed selectors, scratch source texts/categories, command recipes
and pre-execution boundaries. It grants no allowance and contains no executed
compiler or producer result.

This inventory follows the [candidate 2 failure](README.md), its immutable
[diagnostic](AnalyzerSchema.log), and its copied [schema](AnalyzerSchema.swift).
The current assignment classifies this as a P02 prerequisite encountered inside
P08, with no demonstrated normative amendment. That classification does not
authorize this proposal's source changes or validation. Candidate 2's candidate
1/1 and run 1/1 are consumed, automatic repairs 0/0; every earlier closed
allowance remains closed. No maintained/generated source was edited; no compiler,
test, formatter or retry was invoked by this inventory.

## Authority and reason this dependency matters

SPEC-006 and SPEC-010 are `implementing`; their RFC-014 amendments are approved,
ADR-036 is accepted, and the owner plans remain active. [SPEC-006 compiled View
and traversal](../../../../../../../../docs/specs/spec-006-declarative-view-semantics.md#compiled-view-and-traversal)
and DV-RD-001 require separate core/schema/presentation/host modules, inferred
Body, typed source lowering, preserved expression order, and diagnostic escape
rejection. [SPEC-010 model read, ownership and mutation](../../../../../../../../docs/specs/spec-010-observable-reference-state.md#model-read-ownership-and-mutation-contract)
requires owned scalar returns, scoped aggregate facades, checked indexed reads,
and live backing ownership. [ADR-036](../../../../../../../../docs/adrs/adr-036-scoped-model-access-and-bounded-ownership.md)
owns that boundary and permits internal compiler/lifetime realization while
preserving authored semantics.

The ITERATION-001 reference analyzer established shared presentation across the
four stacks. This is post-MVP ITERATION-003 I3-04/05 work under its approved
revision 5 and existing P01–P12 plan. P08 requires the maintained P02 producer,
whose complete registered declaration corpus includes this Analyzer probe.
Repairing that prerequisite does not start full P09 analyzer migration or close
I4-07, P08/R07/T8.1, current-callee proof, cold, resources or conformance.

This record uses the implementation-executor and deferred-work-curator rules:
these are required current dependency questions, so they stay visible here
rather than being deferred. No optional design, new lifecycle artifact,
manifest/status change or new package is introduced.

## Inspected inputs and provenance

Paths below are repository-relative. The uncommitted TargetHost/build-script/
CMake changes and `scripts/contracts/__pycache__/` are excluded and untouched.

| Input | SHA-256 |
| --- | --- |
| `Sources/SignalAnalyzerDomain/AcquisitionState.swift` | `a2fb47cf52972d8610a78e7ffe4d1e8771ea8fff315ca72aec2d29ca33776755` |
| `Sources/SignalAnalyzerDomain/SignalPrimitiveValues.swift` | `c37d6271a0c077fbc99e694b98d0c094e311a0f42681f1c09bbcc64f1ae101c1` |
| `Sources/SignalAnalyzerDomain/SignalAnalyzerDiagnostic.swift` | `f44b7d121c9d290f877ad43c361b4d90d79ecb27a3f8ac1e112062077b53dcf4` |
| `Tests/ContractFixtures/SPEC006/RuntimeDerived/Analyzer.swift` | `455f88cda1ddc91c4c38db7fb469c8c809d4df18505b1f5e16e7cbfb150209b2` |
| `Tests/ContractFixtures/SPEC006/RuntimeDerived/Analyzer.schema.json` | `291cf667a93110a8a9dfbd68f7c67370f4b6f5e0d95f22acc92e5a67050c151a` |
| `Sources/GiftUIMacros/FiniteSourceLowering.swift` | `1873e5f07d48ea3caeda3fa906e3b0936ca33d975db3813207c2603ce8a77a07` |

Read the actual producer, `scripts/contracts/check-spec-006-typed-lowering.py`,
its `DeclarationHost.swift` and `Main.swift`, the candidate 2 preparation and
STOP receipts, current task context/plan, governance, and the above authority.
The lowerer emits `@usableFromInline` schema nominals/protocol and `@inlinable`
facade bodies at lines 818–960; the body rewrite emits `@inlinable` evaluation
and preserves authored stored-property access. The producer compiles exactly
the three Domain files above before AnalyzerSchema, AnalyzerPresentation and
DeclarationHost, then executes native declarations and invokes registered P04.

The existing run's generated presentation was also read, without regeneration:
`.build/contracts/spec-006-rfc-014-swift64/a8a3a315f9ee95ca-s9gcp7qu/macos-static/AnalyzerPresentation.swift`,
SHA-256 `b38b6f4c7efc10f276bf922d3e5438a478956b263cfc14235657ca6150f4c765`.
It is not a successful compile artifact. Its relevant bodies are transcribed
below so this inventory survives generated-directory cleanup.

## Direct serialized schema boundary

The diagnostic contains seven errors: the two protocol result requirements,
the scalar facade property, both indexed facade result signatures, and repeated
signature/body diagnostics for the indexed returns. It establishes failure at
AnalyzerSchema only; AnalyzerPresentation/DeclarationHost and dependent stages
have no passing result in this attempt.

| Generated selector | Serialized dependency and disposition |
| --- | --- |
| `AnalyzerReadDomain.bind(_:slots:)` | `_GiftUIModelKey<AnalyzerModelSchema>`, `Span<Slot>`, `Int`, `_GiftUIAccessFailure`; existing framework/public or generated ABI-qualified dependencies. No Domain value returned. |
| `AnalyzerReadDomain.AnalyzerRead_state_acquisitionState(at:slots:)` | Result `AcquisitionState` is package without ABI qualification: observed failure, schema line 5. |
| `AnalyzerReadDomain.AnalyzerRead_state_capture_count(at:slots:)` | `UInt16`, `Int`, `Span<Slot>` only; no new application ABI dependency. |
| `AnalyzerReadDomain.AnalyzerRead_state_capture_transition(_:at:slots:)` | Result `SignalTransition` is package without ABI qualification: observed failure, line 7; index and typed access failure are existing contracts. |
| `AnalyzerRead_state.acquisitionState` | Inlinable property returns the above type via the above domain requirement: observed failure, line 51. |
| `AnalyzerRead_state_capture.transition(_:)` | Inlinable result `SignalTransition`, typed `_GiftUIAccessFailure`, requirement call: observed failure, lines 70–71. |
| `AnalyzerRead_state_capture._giftUIDrawing_transition(_:)` | Same result, `DrawingError`, catch conversion `DrawingError(accessFailure:)`: observed failure, lines 74–77. This method is generated even though this probe has no Canvas. |
| Both root facade initializers | Key/schema, `Span<D.Slot>`, `Int`, `D.bind`, FrameRead slots; drawing variant maps the same typed failure. Existing qualified framework/generated dependencies. |
| `AnalyzerRead.state()`, `AnalyzerRead_state.capture()`, nested initializers, count getter | Generated scoped facade types/initializers, slots/index and scalar count; all generated nominals/storage already qualified. Lifetime dependencies must remain exact. |
| `AnalyzerModelSchemaSeed.init()` and schema `Seed` alias | Empty seed, generated qualified nominal/alias. No seed fields or hidden Domain payload. |

There is no generated schema construction of a `SignalTransition`, no access
to its fields in those facade bodies, and no generated diagnostic construction.
The compiler cannot establish that only `.running` will be returned: the
`AcquisitionState` type includes all four original cases.

## Transitive types and actual serialized member expressions

The generated `AnalyzerReadProbe<D>` and Domain alias are already qualified by
the lowerer. Its stored `model` and `index` remain authored package declarations
without ABI qualification. The emitted inlinable evaluate body is:

```swift
let state = (try AnalyzerRead<D>(model, read: read)).state()
Text<D>(state.acquisitionState == .running ? "RUNNING" : "STOPPED")
Text<D>(BoundedText(Int32((try AnalyzerRead<D>(model, read: read)).state().capture().count)))
if (try AnalyzerRead<D>(model, read: read)).state().capture().count > 0 {
    Text<D>(BoundedText(Int32(try (try AnalyzerRead<D>(model, read: read)).state().capture().transition(index).channelID.rawValue)))
}
```

| Dependency edge | Exact extent |
| --- | --- |
| Evaluate → `model`, `index` | Both existing stored-property getters are named in serialized code. Their types become the existing qualified model key/schema and standard `Int`. Both need ABI eligibility; this is predicted from source, not an observed diagnostic yet. |
| Evaluate → `AcquisitionState.running`, `AcquisitionState.==` | Enum case construction and synthesized Equatable witness are used by `== .running`. Preserve all cases and synthesized equality. Qualifying the enum is expected to make cases/witness available without new bodies or separate case annotations; pinned compiler acceptance remains unproven. |
| `AcquisitionState.failed` → `SignalAnalyzerDiagnostic` | Associated-value type of an ABI-usable enum case is a transitive nominal dependency even though this probe selects `.running`. Include the existing diagnostic nominal in the candidate; do not drop `.failed` or substitute a scalar. |
| `SignalAnalyzerDiagnostic` → private storage and helpers | Stored `SignalAnalyzerDiagnosticStorage` (24 UInt32 words), private `storage`/`count`, private initializer and UTF-8 helpers remain implementation details of a non-frozen struct with nonserialized methods. Their bodies are not reached by the probe's serialized code. No attribute/access change is proposed for them. Synthesized Equatable/Sendable remain unchanged. |
| Evaluate → `SignalTransition.channelID` → `SignalChannelID.rawValue` | The two concrete member getters and intermediate nominal must be ABI usable. `rawValue` returns standard `Int`, converted by standard `Int32` then existing `BoundedText`. Do not replace the expression or change channel semantics. |
| `SignalTransition` → `timestamp: Duration`, `level: DigitalLevel` | Existing stored payloads and synthesized Equatable/Sendable implementation remain unchanged. Neither field getter, constructor nor equality is called in the serialized probe. With no `@frozen` or serialized constructor/body added, this does not require qualifying `DigitalLevel` or these accessors for this candidate. |
| Host implementation → transition/channel constructors, `.zero`, `.high` | `DeclarationHost.AnalyzerDomain.AnalyzerRead_state_capture_transition` constructs `SignalTransition(channelID: SignalChannelID(rawValue: 1), timestamp: .zero, level: .high)` in an ordinary package, non-inlinable function. Package access suffices there. No constructor/DigitalLevel annotation is justified by that use. |

`SignalChannelID.isStandard`, `SignalChannelLevels` and its initializer/subscript/
`allLow`, `SignalAnalyzerDiagnosticConstruction`, diagnostic package
methods/constants, capture owner/storage, and real application ViewModel are
not serialized dependencies of this schema/probe. Do not blanket-annotate the
Domain file or follow these unused APIs into unrelated owners.

## Proposed source candidate — unapproved, eight selectors in four files

Add exactly `@usableFromInline` to the following existing declarations, retaining
their original access modifiers, declarations, conformances and bodies:

| File | Exact selector(s) | Count |
| --- | --- | ---: |
| `Sources/SignalAnalyzerDomain/AcquisitionState.swift` | `AcquisitionState` nominal | 1 |
| `Sources/SignalAnalyzerDomain/SignalPrimitiveValues.swift` | `SignalTransition` nominal; its `channelID` stored property; `SignalChannelID` nominal; its `rawValue` stored property | 4 |
| `Sources/SignalAnalyzerDomain/SignalAnalyzerDiagnostic.swift` | `SignalAnalyzerDiagnostic` nominal only | 1 |
| `Tests/ContractFixtures/SPEC006/RuntimeDerived/Analyzer.swift` | `AnalyzerReadProbe.model`; `AnalyzerReadProbe.index` | 2 |

No new `@inlinable`, `@frozen`, public/open access, case/witness implementations,
constructor/default changes, body/expression changes, ownership conversion,
new field, type alias, module/dependency, lowerer change, schema change or
generated-output patch is part of this candidate. `AnalyzerReadProbe.init(model:index:)`
is called by ordinary host code and is not called from its serialized evaluate
body, so it remains untouched. The existing private diagnostic representation
and helpers remain private. Attribute-only eligibility is not a claim of public
API stability or resource equivalence of a rebuilt image.

**Exact uncertainty:** this eight-selector closure is source-derived and has
not been compiled. The consumed run stops before proving enum case/payload and
synthesized witness eligibility, the downstream property getters, or additional
diagnostics in AnalyzerPresentation/DeclarationHost/P04. If the pinned compiler
requires an explicit equality body, private representation exposure, frozen
layout, a wider member set or different serialization policy, stop and report
the exact diagnostic. Those are outside this candidate, not automatic ninth
selectors. No contract defect has been demonstrated by the present diagnostics.

## Proposed controls and validation order — no execution authority

Prepare a new candidate-specific source/input/compiler/recipe freeze and fresh
output directory; the consumed candidate 2 runner must not be reused. Record
all added control source and argv before any invocation. Use the existing
sequential validation lock and approved Swift 6.4 flags/toolchains. Preserve
real nonzero diagnostic statuses and source locations; do not accept any
failure merely because compilation failed.

1. Static source review: exactly eight attribute additions, unchanged syntax
   tokens/bodies after attribute removal, exact match count one per selector,
   same access and private declarations. Format only the three maintained Swift
   files through the repository formatter policy, then freeze any formatting
   delta separately before repository validation. The fixture is outside
   formatter scope. Do not format unrelated dirty files.
2. Prepare positive/negative twins using packet-owned scratch inputs, without
   editing maintained/generated inputs in place. A valid same-package,
   separately compiled Domain → schema → presentation positive must exercise
   the actual expressions above and preserve the original failed diagnostic
   nominal as an associated value. Negative twins remove one relevant qualifier
   from a scratch copy at a time: direct result types, failed diagnostic payload,
   channel nominal/getters and probe fields. Require an ABI access diagnostic
   naming that dependency; unexpected acceptance or a different failure stops
   and narrows this proposal rather than causing an implementation change.
   Positive equality controls cover idle/running/stopped/failed with equal and
   different diagnostics; transition controls cover channel/timestamp/level.
   No hand-written replacement equality is permitted.
3. Privacy positives use ordinary package constructors/methods without
   serialization; negatives attempt diagnostic `storage`, `count`, private
   storage type, private initializer/helper access from another same-package
   file/module and package nominal/member access from outside the package.
   Require private/inaccessible diagnostics and a working positive twin.
   Existing key/read-construction privacy, facade/visitor copy/escape,
   mixed-domain, unsupported-effect and bounds controls remain required.
4. Run the maintained P02 producer once per profile, sequentially:
   `scripts/contracts/run-spec-006.sh --profile <profile> --compiler-baseline rfc-014`.
   Proposed order: macOS Static (the failed cell), ARMv6, Embedded, macOS
   Dynamic, with the above ABI/privacy twins using the same profile flags and
   actual fresh module outputs. Each route includes full AnalyzerPresentation,
   DeclarationHost, native execution where supported, negatives and registered
   P04. ARMv6 requires v6/VFP object evidence; Embedded requires v7E-M/VFP.
   Cross compilation does not execute a target. This explicitly proposed
   four-route allowance requires a new disposition; none is currently granted.
5. After every P02/control route passes, use the actual new macOS Static core
   receipt for one registered P07 run, then schema-4 activation join/negatives,
   then the complete native counter 384 controls, in the same dependency order
   and command shapes as candidate 2's prepared recipe. Verify every source,
   compiler/flag, dependency and artifact hash, fresh producer discovery and
   P04/P07/core/host links. Stop at the first material stage/receipt failure;
   later stages remain unrun. Preserve the counter collector's existing
   independent-control policy and dependency blocking.

The previous macro source, 19-method test registration and macro compiler
inputs are unchanged by this proposed eight-selector batch. Its compile/link/
test PASS may be retained only with an explicit exact-identity qualification
of those inputs and dependencies. Rebuild the macro tool as the maintained P02
driver normally does; do not treat a historical executable as a fresh result.
If qualification fails, the new recipe must include the full fresh macro stage
before P02 rather than silently reusing it.

These packet controls are proposal-level acceptance evidence for the bounded
batch. Any decision to add a permanent focused test driver must identify its
maintained files/selectors and top-level registration before source work; this
document does not add an unregistered gate or enlarge this eight-selector scope.

The existing native oracle remains 120 checks/zero failures: successful index 0
produces three primitives, out-of-bounds index 1 fails before any primitive is
traversed, and count 0 excludes the indexed read and produces two primitives.
Retain that oracle and its typed failure/order meaning. This finite probe
does not validate real capture ownership, application pixels or analyzer P09.

## Suggested bounded allowance and unresolved decisions

Suggested only: one eight-selector source candidate, zero automatic source
repairs; one newly frozen sequential validation campaign with the explicit
four P02/profile cells and dependent native chain above, each once, zero
retries. The scratch diagnostic twins are predeclared controls, not candidate
variants or exploratory compiler retries. Freeze the exact control count and
source before execution. No alternate route, flag/compiler change, generated
patch, extra enum/helper annotation or failed-control reclassification is an
automatic continuation. A new material failure freezes logs/artifacts and
unrun dependencies for separate review; every historical stop/guard remains.

Required next dispositions are (a) review the minimal closure and the enum/
synthesis/privacy assumptions, (b) explicitly select or narrow this proposed
new source and validation allowance, and (c) prepare/review the exact recipe and
control manifest before execution. No evidence here grants any of them.

No broad suite, strict cold, linked image, resource limit, hardware, flash,
deployment, P09–P12 start, conformance acceptance or Specification transition
is authorized by this proposal. Existing complete-application and resource
obligations remain open even if a future prerequisite campaign passes.

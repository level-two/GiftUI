# P06 scoped drawing source constraint — 2026-10-11

**Resolved contract blocker by explicit maintainer approval on 2026-10-11.**
Eugene replied “Approved. Please proceed” to this committed proposal (`67331c11`).
The [approval record](../../../../../docs/iterations/iteration-003-review/rfc-014-spec-approval.md#scoped-canvas-source-constraint-amendment--2026-10-11)
and amended SPEC-012 authorize the narrow correction. Implementation and P06
exit proof remain required. The original analysis below preserves the preapproval
state and compiler evidence; its proposed/unchanged language is historical.

Step 1 is committed as `58cf89c7`. P06 is incomplete. The package's next scoped
invocation adapter cannot retain its actual P03 owner lifetime through the exact
currently specified Source constraints. This is not a request for a different
architecture or a new investigation.

## Exact boundary

[SPEC-012 Types / APIs](../../../../../docs/specs/spec-012-canvas-path-stroke-drawing.md)
lines 516–526 specify `package protocol CanvasInvocationSource { ... }`.
The five existing requirements remain:

- associated Identity, Equatable and Sendable;
- canvasOccurrenceCount;
- canvasIdentity(at:);
- mutating invokeCanvas(at:context:size:) throws(DrawingError);
- mutating releaseCanvas(at:).

Lines 721–733 specify CanvasPlanProducer.derive with
`Source: CanvasInvocationSource`. Both declarations implicitly require Copyable
and Escapable in the pinned Swift compiler. The runtime amendment lines 123–128
preserves the lookup/invoke/release signatures and requires the host/schema
adapter to supply a fresh FrameRead internally and end the read before release.
ADR-036/037 require stable backing and lexical scoped access, with no global
current-root resolver or escaped borrowed descriptor as proof of ownership.

The actual P03 `ObservableModelScope<Model, Schema>` is `~Escapable` and contains
lifetime-bearing model/ledger access. Retaining it in a drawing adapter requires
an enclosing nonescapable value. The concrete scoped binder is also deliberately
noncopyable, as in the already approved P03 scoped semantic binder.

This differs from a purely local choice of private fields or borrowing parameter
spelling: the candidate conformer fails the protocol's inherited constraints,
and a corrected conformer still fails derive's generic default constraints.
P05 borrowed consumer work did not make this distinct Source protocol support
such conformers. The approved requirement for fresh scoped reads explains why
the change is needed, but the exact normative declaration is not silently
rewritten on that basis.

## Reproduction and evidence

Run from the repository root:

```text
python3 Tests/ContractFixtures/SPEC012/Evidence/rfc-014-p06/constraint-proof/reproduce.py
```

The script pins the actual final step-1 core receipt and matching P04
ObservableState module. It verifies compiler, core objects/modules and relevant
ObservableState source hashes before compiling. `constraint-proof/result.json`
records hashes, and `commands.txt` records complete compiler commands. The
compiler is project-local Apple Swift 6.3.2 on native arm64 macOS with the
approved LifetimeDependence/Lifetimes flags.

`RuntimeDerived/ScopedSourceConstraint.swift` holds the actual
ObservableModelScope with an explicit lifetime-dependent initializer. Its
invoke method deliberately only throws: this is a declaration/constraint proof,
not an implementation or proof of correct draw invocation.

| Check | Actual result |
| --- | --- |
| Actual production CanvasInvocationSource | Rejects: conformer does not conform to Copyable |
| Proposal with only Copyable suppressed | Rejects: conformer does not conform to Escapable |
| Proposal with both suppressions | Compiles through object emission |
| Isolated derive-equivalent Source constraint, with corrected protocol | Rejects: generic requires Copyable and Escapable |
| Same isolated generic with both suppressions | Compiles through object emission |

The producer checks isolate its exact Source constraint; they do not claim a
full production CanvasPlanProducer build. Proposal-only source files live beside
the reproduction under Evidence. Neither production Source nor producer
constraints were changed. Cross-target constraint proofs and runtime safety tests
remain pending, rather than being inferred from this host compile result.

## Considered contract-preserving realizations

An escaped read facade is expressly forbidden. A stored escaping callback cannot
capture the actual scoped owner; a raw pointer descriptor merely loses the
compiler-enforced backing lifetime. A global resolver violates fixed-domain and
exact-selected-model access. Dynamic retained owners cannot serve Static's
zero-heap profile. Moving the actual Static owner into Source also cannot satisfy
Copyable: StaticObservableModelStorage is noncopyable and activation must remain
stable throughout its lifetime. A parallel producer or extra read argument would
change more API surface and duplicate the existing invocation ownership boundary.
None supplies a smaller contract-preserving implementation of the selected
lexical adapter. This is an assessment of the concrete existing ownership API,
not a claim that no imaginable alternative implementation exists.

## Narrow proposed amendment

1. Declare `package protocol CanvasInvocationSource: ~Copyable, ~Escapable`.
2. Change the publicized package producer Source constraint to
   `Source: CanvasInvocationSource & ~Copyable & ~Escapable`.
3. Forward those suppressions through its private validate/fail helpers and
   directly necessary adapters. Preserve every lookup/invoke/release signature,
   associated type, bounds, failure ordering and caller early-rejection cleanup.
4. The lifetime-bearing adapter itself must be noncopyable/nonescapable, tied to
   the actual borrowed P03 owner and staged-value storage. Suppressions permit
   existing owned source conformers; they do not require all sources to borrow.

No ADR change is proposed: this realizes accepted ADR-036/037. SPEC-012's exact
API declarations and the runtime-amendment explanation require maintainer
approval before the production constraints change. DR-001/003/009/011 and
DR-RD-001–004 retain their existing outcomes and bounds; no acceptance criterion
is removed or relaxed.

After approval, P06 must prove noncopy/escape rejection, fresh exact-selected
model binding, normal/throwing and early-rejection cleanup, finite witness
coverage and order across all four pinned configurations. Existing geometry/
pixel oracles and resource accounting remain required. This proof grants none
of those results. The parent owns escalation and the subsequent independent
Strong review. Consecutive unproductive repair count is **0/2**.

# Independent review: P08 activation resolution bench

Reviewed 2026-10-11 by the independent Strong agent (Astra 6 Medium).
Frozen evidence: `8c1bf351`, with final failure classification `a7d4697e`.
Scope: the bounded activation join experiment under
[authorization](authorization.md), not P08 acceptance or
the complete SPEC-015 conformance review. No compiler invocation, runtime
execution, source edit, or hardware operation was performed by this reviewer.

**Disposition: reject adoption of this candidate. The actual activation join
compiles, but activation-callback lifetime containment fails.** The exhausted
12-call bench remains closed; its result does not establish language
impossibility or authorize changing the contract.

## Blocking finding

`run-12/OutliveNegative.swift:14–55` explicitly retains dependence on the mutable
profile receiver, assigns the activated/quiesced owner into an outer optional at
line 44, and returns it after every lending callback has ended at line 55.
[Run 12](run-12/result.json) exits successfully with empty
diagnostics. The negative therefore fails; it must not be counted as protection
against escape. [SPEC-015](../../../../../../docs/specs/spec-015-host-configuration.md)
lines 771–775 require compiler-checked dependence and expressly prohibit escape
from an activation callback.

This is not made valid by keeping the profile's physical allocation alive:

- `Sources/GiftUIObservableState/ObservableModelScope.swift:18` defers model
  activation cleanup, which clears occupied model slots.
- `Sources/GiftUIObservableState/ObservableStateRootScope.swift:110–117` shuts
  down the root and finishes a stopped activation on callback exit.
- `Sources/GiftUISemanticCore/SemanticRecordStore.swift:56–59` clears both banks.
- `Sources/GiftUIDrawing/CanvasStagedValues.swift:48` discards staged values.

Those are semantic retirement boundaries, independently of allocation lifetime.
The returned value still contains the scoped coordinator. Quiescence does not
waive the host's no-escape requirement. Run 12 does not separately test destruction
of the physical profile backing, and makes no post-return coordinator call; these
are limits of the evidence, not reasons to reclassify the accepted escape as a
passing negative.

## What the evidence does support

Run 9 uses real model/root, semantic, Canvas, workspace-buffer and control-pointer
scopes. The supplied carrier is generic over actual geometry and stores private
scoped fields. Runtime pipeline/endpoint, binding, admission and coordinator are
first constructed by `LayoutAOwner.activate`; no coordinator or endpoint is
preconstructed in the inert case. Run 10 rejects copying for the intended
noncopyable-type diagnostic. Run 11 rejects an invalid annotation and is correctly
excluded from lifetime evidence.

The two overlay changes only add scoped-control initializer overloads in test
fixture source. They do not change maintained runtime modules, compiler features,
the public host role, or the activation contract. The owner is not yet a generic
`MVPHostInstance` integration and its simplified lifecycle is not production
lifecycle evidence. No opportunity, executable runtime assertion, full teardown,
workspace restoration, resource result or platform result is established here.

`Control.swift:3–4` borrows an escapable pointer descriptor. Its dependence alone
cannot prove pointee validity, as ADR-036 expressly requires. The real supplying
scopes provide the backing proof only while the host stays inside them; run 12
demonstrates the missing containment.

Read-only verification checked all 189 entries in the frozen `manifest.json` and
the ledger's 12 invocations. The positive, copy-negative and callback-escape
outcomes match the raw receipts. Historical 2/2 guards remain unchanged.

## Bounded correction direction

A private, noncopyable callback-local activation token is a plausible internal
fence: establish it within the innermost real backing callback, borrow that token
in the control carrier, then preserve that dependence through copied carrier
lifetimes. The token would not own pointees; actual supplying callbacks must still
establish initialization, alignment, disjoint access and backing lifetime. Its
constructor must not permit callers to substitute a longer-lived unrelated token.
This is a proposed mechanism, not a reviewed working result.

Any separately authorized bounded continuation should first establish a positive
join with this dependency and matching rejection of active callback escape and
physical-backing expiry. Both negatives must use the returned owner after the
forbidden boundary and reject for the intended lifetime reason. Adoption then
requires actual generic host activation, opportunity and teardown regression
evidence without bypassing validation or changing failure/activation semantics.
These are current correctness obligations; no new deferred work or scope is
created by this review.

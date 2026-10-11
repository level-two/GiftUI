# P08 activation resolution bench — 2026-10-11

**Stopped at 12/12 compiler invocations. Actual activation join compiles;
required activation-callback lifetime containment FAILS. No maintained source
changed and no production adoption is claimed.** Strong Astra 6 Medium,
sequential, under [authorization](authorization.md), committed before all calls.
Historical production and investigation guards remain 2/2, unchanged.

## Findings

- Runs 1–4 reduce four noncopyable-copy diagnostics to the supplied struct alone:
  no actual caller, enum transition or runtime construction is necessary.
- Run 5 retains all four diagnostics when integrated with actual P07 test fixture
  sources. It is conservatively counted unproductive1/2.
- Run 6 passes with exactly the four scoped stored fields made private. This
  isolates their synthesized exposure. It is only an inert-definition pass.
- Run 7 explicit borrowing accessors localize the same four errors to scope
  field borrows. Actual activation also retains local/receiver lifetime errors.
- Run 8 makes supplied storage generic over its real geometry type. All
  noncopyable-copy diagnostics disappear; only activation lifetime errors remain.
- Run 9 adds a scoped control carrier and two fixture initializer overloads.
  **The actual backing caller, inert host owner, activation-time pipeline/endpoint,
  binding/admission/coordinator construction and quiescence compile successfully.**
  The existing enum transition works; a consuming transition helper was not needed.
- Run 10 rejects explicit owner copying for the intended noncopyable reason.
- Run 11 is not accepted negative evidence: its attempted lifetime annotation
  incorrectly used borrow self with a mutating receiver.
- Run 12 corrects that annotation to the compiler-requested `@_lifetime(&self)`.
  **It compiles, so it is not accepted lifetime-negative evidence.** It returns
  the quiesced owner beyond nested lending callbacks, with dependence on the
  still-live profile receiver. Independent Strong review identifies this as a
  forbidden callback escape: the model/root, semantic and Canvas callbacks
  finish/reset their activation state on exit even while the profile backing
  remains allocated. The candidate therefore FAILS required activation-lifetime
  containment. A separate physical-backing-expiry negative was not compiled.

The last two unsuccessful negative attempts are conservatively charged2/2.
The numerical12/12 budget is independently exhausted. No additional correction,
negative, link or execution was performed. No compiler-bug root cause or language
impossibility is claimed.

## Candidate and safety boundary

[Supplied.swift](Supplied.swift) is generic over the actual Geometry type and
keeps the four noncopyable scoped fields private with explicit copied-lifetime
borrowing methods. [Control.swift](Control.swift) preserves the original supplied
control dependency instead of re-borrowing an escapable pointer descriptor from
temporary supplied state. The carrier is constructed only within the actual
`withUnsafeMutablePointer(to: &control)` callback nested inside model/root,
semantic, Canvas and geometry scopes in [Positive.swift](Positive.swift).
Borrowing a pointer descriptor alone is not evidence that its pointee survives;
the actual backing scopes and rejection of owner escape remain essential.

[Layout.swift](Layout.swift) contains no preconstructed runtime in its inert
case. Its activate method first constructs the actual `CyclePipelineOwner`
(including actual endpoint), `CycleExecutionBinding`, `CycleAdmission` and
`StaticRuntimeExecutionCoordinator`. The two [overlaid fixture files](overlays/)
add initializer overloads only; all existing signatures and implementations are
retained. They change no production runtime module, compiler feature or public
host contract. Lifetime annotations use copied scoped-control dependence.

This owner is an internal storage join control, not an `MVPHostInstance`
conformance or validated preset. It does not prove lifecycle reentrancy,
activation failure, runtime opportunities, nine-stage validation, final cache
teardown or P08 completion. There was no executable link/run or hardware action.

## Recorded evidence

[ledger.json](ledger.json) records every compiler call, manual disposition and
historical guard. Each run directory contains its exact source snapshots,
command, complete stdout/stderr and immutable raw receipt with SHA256 values.
Run9's actual join source is unchanged for runs10–12; the latter add negative
sources only. The runner reserves budget before invocation and checks pinned
compiler and schema inputs/artifacts. Integrated runs additionally verify the
complete runtime receipt, its165 source inputs and143 artifacts before using
its sources/dependencies. Final read-only verification rechecks those identities.
No copied fixture file replaces a maintained source during this bench.

Independent Strong review distinguishes the successful activation compilation
from the failed callback-lifetime containment. The current candidate must not be
adopted. Further evidence or adoption
requires a separately bounded continuation under the user's resolution request;
this exhausted bench does not silently extend its allowance.

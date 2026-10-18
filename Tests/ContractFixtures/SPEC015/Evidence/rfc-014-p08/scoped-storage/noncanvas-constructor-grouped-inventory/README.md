# Finite non-Canvas constructor ABI proposal — 2026-10-18

**Read-only proposal; independent review next.** This groups the two known
non-Canvas constructor boundaries under one name-independent finite rule:
CounterScreen and ChildScreen. [Exact map](correction-map.json) has three
implementation selectors in two maintained files: a pure owner/initializer
predicate, initializer emission, and the existing actual-lowerer test family.
No source, fixture, compiler, test, decoder or runtime was changed/run. No new
candidate or repair allowance is allocated; all historical budgets remain closed.

The [reviewed frozen failure](../p08-canvas-writer-transfer-boundary-review.md)
is generated nested evaluator ChildScreen<D>() at70 calling package init() at92.
FiniteSourceLowering serializes that evaluator and qualifies its nominal, but
currently qualifies constructors only inside Canvas. This valid maintained
composition predates the Canvas candidate. CounterScreen has the same ordinary
constructor producer gap; CounterCanvas already follows the Canvas branch (NOOP).

Propose only `@usableFromInline package init() {}` (also internal/default-internal)
for explicit ordinary zero-argument constructors directly owned by top-level,
nongeneric finite non-Canvas Views with ABI-eligible owners. The initializer stays
ordinary; its private State initialization is not made an @inlinable body. Source
access, body, defaults, required arguments and authored State/_model stay exact.
The predicate follows original syntax ownership, not inherited insideView: nested
noninventory helpers, local/extension/conditional owners and name collisions do
not inherit eligibility. Private/fileprivate owners or initializers stay unchanged;
public/already-ABI initializers receive no redundant attributes. @available is
preserved; other attribute/modifier combinations remain outside this predicate.

This is intentionally the existing zero-argument profile, not a generic Swift
constructor ABI algorithm. Overloads are assessed individually. Parameterized or
defaulted, failable, throwing, async, generic/where and other attributed forms
keep existing lowering and diagnostic behavior; no new syntax is accepted/rejected.
They are negative predicate tests, not claimed semantic compilation successes.
No default argument is added, including Optional nil defaults, and no synthesized
constructor is replaced. A future live call outside this profile needs its own
bounded review; it is not silently promoted.

Authority: [SPEC006 finite lowering design](../../../../../../../docs/implementation-designs/spec-006-finite-source-lowering.md)
Data and Control Flow / Algorithms preserves original expression order, ordinary
custom composition and compiler validation. SPEC010 State binding/ownership and
SPEC015 private P08/session/14loan requirements remain unchanged. Matched compiler
[formal-access/fragility rules](../observable-grouped-inventory/matched-compiler-rule.json)
explain why an ordinary ABI-visible constructor can retain private implementation;
ABI access is the minimum of member/enclosing nominal scope. No property/State
backing qualification is necessary or permitted by this proposal.

[Validation proposal](validation-proposal.json) keeps one combined, prerequisite-gated
package: fresh macro17 and generated artifacts → fresh registered25 + main/nested/
multiple pairs → privacy → complete physical indexes/object/42SIL. Unchanged pinned
compiler/SwiftSyntax/macOS dependencies may be hash-qualified; changed macro producer
and all generated outputs must be fresh. Existing failure receipts remain intact.
Full safety/strictcold/P08 acceptance and ordinary constructor resource costs are
still unqualified. No actual architecture/ownership contract change is proposed.

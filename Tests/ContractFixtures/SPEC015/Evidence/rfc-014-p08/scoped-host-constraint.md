# P08 scoped host contract decision — 2026-10-11

**Affected P08 host integration is stopped for a contract decision.** No
production implementation, schema-4 edit, Specification amendment or P08 pass is
made by this packet. P07 remains passed at `9fa495dd`; its exhausted historical
stop and resumed guard history are unchanged. P08 consecutive unproductive
repairs: **0/2**. This current correctness prerequisite cannot be deferred.

[Independent Strong review](independent-blocker-review.md) at frozen `2579e980`
recommends the exact proposal for human approval consideration. All seven
compiler controls independently reproduce. This is no approval or integration
pass; validation, activate-time construction and complete teardown remain binding.

## Proven boundary

[SPEC-015](../../../../../docs/specs/spec-015-host-configuration.md) explicitly
spells `package protocol MVPHostInstance: ~Copyable` at line 739. The matching
production declaration in `Sources/GiftUIHostConfiguration/HostConfigurationResults.swift`
also retains an implicit `Escapable` requirement. A host retaining either actual
P07 concrete coordinator must carry the coordinator's nonescapable activation
lifetime. The pinned Swift 6.3.2 compiler rejects that host's conformance solely
for inherited `Escapable` after the probe's actual audited-binding constraints
are supplied.

An evidence-only copy that adds `~Escapable` compiles unchanged host methods,
activation/owner failure types and lifecycle values with both imported actual
Static/Dynamic coordinator types. A separate concrete-return control compiles
an internal result with the existing invalid/constructed cases and a return
lifetime dependent on the consumed coordinator. Copy and escape controls reject.
This is language/type feasibility, not executed host validation or proof that
live model storage, lifecycle cleanup, complete construction or resources work.
The report, audit and validation-result payloads are explicitly inert scaffolding;
the coordinator modules and exact host protocol/method declarations are real.

The source-only `MVPValidatedHostInstanceFactory.Instance` separately retains
implicit Copyable/Escapable requirements. Its exact current declaration rejects
the proposed scoped host. Naively suppressing those associated requirements is
also rejected by pinned Swift 6.3.2. Therefore the one-token normative correction
alone does **not** complete the existing generic bootstrap. No newer associated-
type compiler feature, escaping raw pointer, retained alias, per-opportunity
storage activation or new external host abstraction is proposed as a workaround.
The finite concrete construction route must be integrated and validated after
approval. SPEC-015 prescribes concrete per-preset construction functions; it does
not freeze the source-only factory/enum declarations. Independent review must
verify that internal propagation and return annotations can preserve that exact
construction duty rather than silently changing it.

## Authority and smallest proposed decision

Accepted [ADR-036](../../../../../docs/adrs/adr-036-scoped-model-access-and-bounded-ownership.md)
requires stable accounted backing, nonescaping reads, separate tickets/pins/
registrations and producer/drain/retirement before backing release. ADR-035/037
preserve the actual runtime graph and scoped Canvas ownership. Approved SPEC-009/
013 permit scoped coordinators; their [approval](../../../../../docs/iterations/iteration-003-review/rfc-014-spec-approval.md#scoped-coordinator-constraint-amendment--2026-10-11)
explicitly leaves SPEC-015 host lifetime separate. Neither the ready P08 plan nor
"Please proceed" implicitly amends SPEC-015's exact declaration.

**Proposed, not approved:** change only the host protocol constraint and add an
explicit construction-lifetime clarification. The exact [draft diff](proposed-spec-015.diff)
is reviewable without applying it. The protocol edit is:

```diff
-package protocol MVPHostInstance: ~Copyable {
+package protocol MVPHostInstance: ~Copyable, ~Escapable {
```

The accompanying proposed paragraph requires a scope-bearing instance returned
by the existing concrete construction function to remain lifetime-dependent on
its supplied backing/consumed coordinator. Validation still precedes live-owner
construction and exposure; lifecycle methods remain the only activation/run/
teardown entry. An instance cannot escape a backing owner's activation callback
or survive backing release. Existing escapable conformers remain permitted. No
method, result, failure, role/cardinality, pacing, policy, limit or hardware duty
changes. Review must determine whether this clarification is sufficient and
compatible with the existing concrete-return construction contract. The successful
compile-only concrete return is not a promise that the full factory route has
already been implemented.

If this narrowly coordinated contract correction is not approved, retain the
current exact contract and keep affected host integration stopped; return the
ownership realization upstream. This packet does not select an alternative
architecture. Do not approve only the spelling while treating construction and
ownership obligations below as optional.

## Reproduction

From the repository root:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-host-proof/reproduce.py --runtime-build .build/contracts/spec-013-runtime-cycle/tmpwj8mqyyn/macos-static
```

The script verifies all **165** P07 receipt source hashes, **143** artifact
hashes, compiler/core receipts, and the exact current host declaration before
compiling. [Receipt](scoped-host-proof/result.json), [commands](scoped-host-proof/commands.txt),
all seven source controls and complete diagnostics are retained in
[scoped-host-proof](scoped-host-proof/). Objects remain under the recorded
`.build/contracts/spec-015-lifetime-boundary/` directory. No target compilation,
execution, linked image, heap, stack, pixel or package conformance is claimed.

| Control | Required and observed result |
| --- | --- |
| Current | Exact host protocol rejects inherited Escapable |
| Proposed | Only host constraint changed; unchanged signatures compile |
| ConcreteConstruction | Lifetime-dependent concrete return compiles for both actual coordinator types |
| CopyHost | Explicit copy of a noncopyable host rejects |
| EscapeHost | Escapable container retaining scoped host rejects |
| FactoryCurrent | Current source-only associated Instance rejects Copyable |
| FactorySuppressionRejected | Naive associated suppressions reject on the pinned compiler |

An initial temporary fixture omitted the concrete coordinators' audited-binding
conditional-conformance constraint. Adding that already-required constraint
removed unrelated diagnostics; it was a productive fixture correction, not a
production repair or exhausted guard. The seven preserved controls all have
their expected result. P08 guard remains **0/2**.

## Required production proof after approval

- Implement concrete per-preset construction under the same eighteen-role graph,
  pure ordered validation, valid-only instance exposure and exact report/audit;
  preserve first error and partial-construction cleanup. Do not reuse the
  compile-only inert report/audit payloads as an implementation oracle.
- Preserve consuming coordinator ownership and return dependence through the
  real supplied model/root/semantic/Canvas backing factories. Compile actual
  Static/Dynamic hosts on all four configurations and reject host copy, escape,
  use after consume, escape through a returned construction result, and reuse
  after closed backing activation. Existing escapable conformers must still work.
- Prove partial activation failures and teardown from every reachable state:
  stop admission/producers, drain callback/IRQ handoffs, finish active attempt
  cleanup, retire routing/registrations and stale generations, release independent
  host cache tickets and frame pins, then release backing last, exactly once.
- Demonstrate real retained-owner replacement success/refusal, guarded callback
  rejection, live frame reads, shutdown stale dispatch rejection and later fresh
  reconstruction with no replay or independent ownership hidden in a root alias.
- Complete schema-4 explicit bounds/audits, actual UInt8 0–9 Increment/Reset/
  disabled/optional-stroke counter, four-route corpus and early linked target
  RAM/stack/allocator checks in P08; separate Strong exit review still required.
  Full P10–P12 conformance and P09 analyzer migration remain separate.

No optional discovery was promoted to deferred work. The exact contract conflict
is the present blocker and requires independent review plus explicit maintainer
approval before affected production changes.

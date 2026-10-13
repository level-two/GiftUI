# SO-03 correction-1 independent Strong review — 2026-10-13

Reviewed clean outcome `e82c17ff`, sole fixture correction `8d996626` and clean
native entry `16499074`, under sequential independent Strong task
`p08_so03_correction_review`, C3/R3. Its receipt dispatch preceded this review.
**SO-03 remains blocked by a local initializer-only fixture lifetime error. No
contract defect is demonstrated. No further source correction or run is authorized.**
No source/driver edit, compiler, probe, test/build, experiment, target/image,
hardware or subagent ran. Documentation checks are recorded in the shared receipt.

## Authority and correction adherence

Accepted [ADR-039](../../../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md),
[S11.1–4](../../../../../../../../docs/specs/spec-011-interaction.md#s111-scoped-storage-and-state-declarations)
and [S13.1](../../../../../../../../docs/specs/spec-013-runtime-profiles.md#s131-physical-owner-session-and-coordinator-contract)
govern. The [SO-03 packet](../../so02-execution-proposal.md),
[SO-02 design](../../../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md)
and [preceding independent review](../independent-review.md) are derived records.
The correction follows the preceding review's representation boundary. Only
`Tests/ContractFixtures/SPEC011/RuntimeDerived/ScopedStorageProbe.swift` changed;
production declarations, algorithms, measurement, analyzer factories, Package and
driver are unchanged. Specifications 011/013/015 remain implementing, plans active.
ITERATION-003 I3-04/I3-05 requires the finite runtime-derived counter and measured
four-stack validation; closed ITERATION-001 analyzer/stack controls persist. Full
RFC-015 delivery and actual analyzer factory integration remain mandatory I4-07,
with the separate P09/P10–P12 handoff.

The initializer-only family keeps five independent MutableSpan dependencies,
actual InteractionState/failable InteractionOwnedKeyState initialization, the
unchanged direct/generic five-input union declarations, scoped move/failable-none,
owned Optional copy/return and scoped-copy controls. Exchange now traps explicitly;
this family is never passed to the real operation helper. The ten positive/escape
pairs still remove only their named dependency from so03Union's output annotation.
They have not executed or passed in this run.

The executable family is closed and fixture-private. The noncopyable reservation
owner is constructed only inside five nested typed reservation borrows over five
separate local SO03Bank objects. Its sole factory takes that owner inout, admits
no client conformer/callback, checks inactive state and holds all five final typed
pointee borrows through its fixed operation body. SO03SessionLifetime's annotation
depends on **borrowing the actual owner**, whose enclosing exclusive inout access
remains active; the token is not derived from a pointer-local lifetime. Its numeric
provenance identifies the reservation but is not itself lifetime enforcement.
Every ~Copyable/~Escapable access stores the immutable token and declares
`@_lifetime(copy sessionLifetime)` on construction. It exposes no pointer/bank/
descriptor getter or scoped result. Ordinary role descriptors remain private.

Factory source checks common provenance, distinct original bank identities,
disjoint full typed extents and equal logical R/H pair capacities sufficient for
the unchanged two-action/two-hit limits before access construction. Actual typed
six-element banks cover those capacities. Descriptor exchange carries address,
count, capacity, retained extent and original physical identity together; immutable
tokens stay in place and payloads never swap. Closed construction/no external body
excludes a supported alias/reentry route. A defer resets keys on ordinary body
return; outer typed locals retain physical destruction responsibility. These are
source adherence findings for this finite fixture, not production SO-04 owner,
initialization-prefix, reuse, teardown, exclusivity-test or resource conformance.
Neither the token nor private pointers remove the need for the missing compiler
and runtime evidence.

The real accepted/refused/generation/root/Canvas/gesture/owned-dispatcher assertions
remain. No no-op executable exchange, lifetime erasure, blanket suppression,
mutable capability duplication, public factory or disabled exclusivity appears.
No additional source defect or scope/architecture change is established by this
inspection. Absence of a diagnostic in this failed module is not acceptance of
the common-session implementation or its instantiated operations.

## Evidence and precise failure

Read-only verification matches **122 frozen source inputs, 128 driver inputs,
24 unaffected core/factory pins and 80 partial artifact hashes/sizes**. Compiler,
macro tool and reused core receipt match their pinned identities. The sole frozen
source delta is the fixture. The committed source diff matches the snapshot after
its documented blank-context whitespace normalization. The original attempt-1
result hash and original attempt tree remain unchanged.

All **43 planned argv/oracles/labels** match the precompiler plan after only the
fresh output-directory substitution. Attempted argv is exactly its first 14 cells.
The 33 tracked files with immutable output counterparts match byte-for-byte; the
additional artifact-hash receipt agrees with result.json. Raw invocation output
preserves the failure and its terminal blank line. Binary modules/objects remain
in `.build/contracts/spec-011-owned-keys/tmpg36aookh/macos-dynamic` and match the
artifact receipt. No evidence is overwritten or trimmed.

[Invocation](attempt-1/invocation.json) and [driver result](attempt-1/result.json)
agree: exit **1**, one rerun, **14 compiler cells, 13 pass / 1 fail**. Both
prerequisites, Interaction/Observable/Static/Dynamic and all six actual RuntimeCore
consumers compiled; the existing 14-value layout IR check passed. OwnedKeyProbe
failed. **All 27 focused probes, link and execute were unreached.** No conditional
owned/Optional acceptance, expected-negative success, operation instantiation,
common-session executable semantics or resource fit follows.

[OwnedKeyProbe.log](attempt-1/OwnedKeyProbe.log) has **five primary diagnostics**
(ten primary/echoed error occurrences), all at frozen fixture line 532:
`precondition(state.committedRecordCount == 0)`. Each depends on one scoped mutable
access to c/h0/r0/r1/h1 in the preceding so03Union call at lines 529–530. The result
is unwrapped and used after those temporary accesses. The pinned Swift interface's
InlineArray.mutableSpan is a mutating getter with `@lifetime(&self)`; an unchanged
array variable's lexical lifetime does not extend that temporary exclusive access.
The diagnostic therefore identifies an initializer-control **call-site lifetime
realization error**, not failed exchange, missing initializer union or an observed
compiler/production contract defect. The precondition autoclosure is not separately
proved to be the cause; replacing only its spelling while keeping the escaping
result would not address the diagnosed dependency boundary.

Old partial-reinitialization/cross-argument exchange diagnostics are absent. That
is a narrowed observation, not proof that all replacement code compiled, linked,
ran or satisfied the transaction contract. This newly introduced selected-path
fixture failure cannot use the pre-existing analyzer residual policy.

## Guard disposition and smallest proposed handoff

The one authorized correction produced a **narrower concrete cause**: the old
exchange representation diagnostics are replaced by one initializer call-site
lifetime boundary, with all 13 earlier exact checks retained. This is productive
under the existing rule's “new passing check or narrowed cause” test. It does not
establish two consecutive unproductive repairs. Record **one correction**, not
zero repairs or a new cumulative 0/2 budget. Automatic follow-up repairs remain
**0**. Original SO-03 and correction-1 native allowances each remain **1/1 consumed,
0 remaining**. Historical helper 2/2, B03 1/1, GOT/image/backing/phase/IR allowances
and SPIKE-075's seven closed experiments stay closed. No counter is reset and
productive classification creates no execution authority.

The smallest recommended next change is confined to the initializer-only call
site in the same fixture: introduce a private helper taking the same five
**consuming independent access inputs**, call the unchanged so03Union, consume/
unwrap its actual failable Optional and inspect committedRecordCount **inside
that helper**, then return only the owned UInt16 count. Invoke this helper while
the five temporary mutableSpan arguments are still in the same call expression,
following the existing so03Move/so03Failable owned-result pattern. Preserve the
zero-count assertion and the subsequent common-session/retained-owned checks.
Do not return scoped state from this helper or substitute common-session inputs.
Keep so03Union/so03GenericUnion and every omitted-input annotation, original
positive twin, negative cause, copy/failable control, 27 labels and 43-command
plan unchanged. No driver edit or production change is needed for this proposal.
This preserves independent lifetime discrimination rather than making a missing
input redundant. Its compiler acceptance remains unproved.

**Proposed, NOT AUTHORIZED:** one such local fixture correction, source/freeze/
unchanged-plan commit after formatter/governance/diff and read-only pin checks,
then exactly one fresh native invocation of the existing command:

```text
scripts/contracts/run-spec-011.sh --profile macos-dynamic --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014-swift64/af66aaf967e3fe8f-__4p5wu2/macos-dynamic
```

Maximum **42 compiler + 1 existing execute**, fresh immutable output, first
prerequisite/positive failure or wrong negative cause stops; zero automatic
follow-up repairs and separate independent Strong result review. No preliminary
probe, retry, repository suite, target/image, SO-04–09 or hardware is included.
Keeping the present stop is also valid. The maintainer must grant a new finite
allowance because both explicit run allowances are exhausted, not because a new
contract or architecture defect is established.

All nine SO criteria, HC-RD-003/P08/R07/T8.1 and **58,648 versus 27,648 stack failure**
remain open. Counter/Cycle full-graph compatibility, physical fit, mandatory I4-07
and separate P09–P12/hardware/timing duties remain unproved. No new deferred item
is created: this is a current selected-path blocker, and existing residuals keep
their owners. Manifest/statuses/authority are unchanged.

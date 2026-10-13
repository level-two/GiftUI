# SO-03 independent Strong source/result review — 2026-10-13

Reviewed clean outcome `522bd23f`, source `f18125fb..4c7e8bc2`, under sequential
Strong task `p08_so03_result_review`; only its receipt dispatch was dirty.
**SO-03 remains blocked on a new local fixture realization defect. No contract
defect is demonstrated; no repair or renewed invocation is authorized here.**
No compiler, test/build, source repair, experiment, hardware action or subagent
ran during review. Documentation checks and commit are recorded in the receipt.

## Authority and source assessment

Accepted [ADR-039](../../../../../../../docs/adrs/adr-039-scoped-storage-ownership.md)
and live [S11.1–4](../../../../../../../docs/specs/spec-011-interaction.md#s111-scoped-storage-and-state-declarations)
govern; [S13.1](../../../../../../../docs/specs/spec-013-runtime-profiles.md#s131-physical-owner-session-and-coordinator-contract)
governs the actual-owner/common-session mechanism. The reviewed
[SO-03 packet](../so02-execution-proposal.md), [readiness verification](../so02-independent-review.md#so-03-authorized-packet-readiness-verification--2026-10-13)
and [SO-02 design](../../../../../../../docs/implementation-designs/spec-015-p08-scoped-storage-ownership.md)
are derived records, not substitute authority. SPEC-011/013/015 remain
implementing, plans active. ITERATION-003 I3-04/I3-05 requires the finite
runtime-derived counter and four-stack validation while preserving closed
ITERATION-001 analyzer controls; full RFC-015 reconciliation remains I4-07.

Source inspection finds the six exact scoped protocol headers, all original
requirements/Identity equalities, five stored lifetime inputs and consuming
initializer union, state-dependent failable wrapper and four conditional owned
conformances. No second state machine or added lease/pointer field appears.
Both withBacking APIs and all four callback users are removed. Gesture and
the six RuntimeCore files carry the prescribed operation/retained bounds;
RuntimeInteractionDispatcher retains owned Records/Handler/TargetAccess.
Transaction/gesture/dispatch algorithms are unchanged by those source edits.
The two Package target feature-flag additions are limited to Interaction and
RuntimeCore. No production SO-04 physical owner/session or host adoption exists.

The ordinary `InteractionOwnedBankMeasurementSource` remains implicitly
Copyable/Escapable: it is **not a seventh scoped-Self protocol** and adds no
requirement to the six approved contracts. Its owned-only state extensions
return fixed value facts for five banks, without callback/storage capability.
Static inline facts use the concrete bank's layout; Dynamic facts preserve
actual reservedPayloadBytes and retainedElementCapacity, including spare
capacity. Counter/Cycle measurement and region formulas preserve their owned
bank/key accounting rather than substituting a scoped adapter's layout.
The four signature additions in counterValidateBacking, cycleValidateBacking,
cycleConcreteCoordinator and exercisePipeline propagate exactly those owned
measurement constraints to existing callers. ReturnedWorkspaces remains owned
without an instrumentation requirement. This is a suitable local realization
of S11's owned measurements; the complete Counter/Cycle fixture graphs did not
compile in this component run, so their compatibility remains unproved and
must be checked at their governed later routes. Scoped physical accounting
still belongs to SO-04 onward.

The unchanged analyzer factory hashes match the accepted
[applicability disposition](../../../../../../../docs/iterations/iteration-003-review/rfc-015-delivery-allocation.md#accepted-pre-existing-integration-gap-disposition--2026-10-13).
Actual model/root/target/factory compatibility and owned-return evidence remain
mandatory unresolved I4-07 work with the separate P09/P10–12 handoff. No new
analogous pre-existing nonselected integration gap was identified. The present
fixture defect is newly introduced on the selected validation path and cannot
use that residual policy.

## Frozen evidence and exact failure

Read-only verification matches all **122 source-freeze hashes, 128 driver input
hashes, 24 unaffected core/factory pins and 80 artifact hashes**. Compiler,
macro tool and reused core receipt hashes match their frozen identities.
The precompiler 43-command plan matches the actual plan after the sole output
directory substitution. The source.diff's 24 source sections match the committed
source changes; section ordering and the newly tracked file's Git index line
are presentation differences only. Tracked logs/plans/IR/result match the
immutable `.build/contracts/spec-011-owned-keys/tmpubqsj1v5/macos-dynamic`
copies. Attempted argv is exactly the first 14 cells of the frozen plan.

[Invocation](attempt-1/invocation.json) and [driver receipt](attempt-1/result.json)
agree: exit **1**, one invocation consumed **1/1**, zero automatic repairs;
planned **42 compiler + 1 execute = 43 commands**. Actual **14 compiler cells:
13 pass / 1 fail**. Both prerequisites, Interaction, Observable, Static/Dynamic
and all six real RuntimeCore consumer sources compiled; the existing 14-value
key-layout IR check passed. OwnedKeyProbe failed. **All 27 focused probes, link
and execute were unreached.** These passes establish those exact module/layout
facts only, not scoped operation instantiation, conditional-owned/Optional
compatibility, expected-negative acceptance, runtime semantics or resource fit.

The [eight primary diagnostics](attempt-1/OwnedKeyProbe.log) all arise from
new ScopedStorageProbe.swift exchange methods: committed lines 68/70 and hit
lines 101/103 partially reinitialize self/other after consuming MutableSpan
fields; methods 64/97 additionally acquire each other's independent lifetime
and fail to return within the original argument lifetime. Fixing only field
initialization, or spelling a whole-value swap, does not answer the separately
observed cross-argument lifetime problem. No compiler bug, target issue or
diagnostic failure is established.

This fixture deliberately constructs five independent typed spans to exercise
the initializer union. Its executable operations also try to exchange those
independent dependencies, without the common actual-owner session prescribed
for descriptor exchange. The declarations are not proven impossible by that
representation failure. The actual SO-04 final-owner exchange remains untested.
Immediate stop and preservation of the failing source/output obey the allowance.

## Guard disposition

This is **productive bounded implementation evidence** under the existing rule:
13 exact checks pass and the remaining cause narrows to two new fixture methods
with two explicit diagnostic classes. It is the first source realization, with
**zero repair attempts**, and does not establish two consecutive unproductive
repairs of this blocker. Do not invent a fresh cumulative 0/2 counter or reset
any historical stop. Historical helper 2/2, B03 1/1, GOT/image/backing/phase/IR
allowances and SPIKE-075's seven closed experiments stay closed. The original
SO-03 **1/1 invocation consumed, 0 remaining** stays consumed. Passing/narrowed
evidence creates no extra compiler entitlement. The 58,648/27,648 stack failure
and all nine SO criteria, HC-RD-003/P08/R07/T8.1 remain open.

## Smallest concrete correction and proposed allowance

**Recommended local correction:** change only
`Tests/ContractFixtures/SPEC011/RuntimeDerived/ScopedStorageProbe.swift`.
Separate the independently scoped initializer-only input family from the
executable operation family. The former continues to instantiate the **actual**
InteractionState and failable InteractionOwnedKeyState initializers in all five
direct/generic positive/omitted-input pairs; its banks are never exchanged or
used to claim transaction execution. Explicitly guard that limitation rather
than implementing an apparently working cross-lifetime exchange. Retain scoped
move, failable-none, owned Optional copy/return and scoped-copy controls.

The executable family must use a closed fixture-private common-session factory:
hold the actual owner's exclusive typed borrow and all five disjoint final
typed bank borrows through the owned-result body; derive immutable lifetime/
provenance evidence from that owner, not a pointer variable; validate distinct
banks/common provenance/equal logical pair capacity before constructing accesses.
Keep address/count/extent in complete private owned role descriptors so exchange
changes descriptor roles under the common token, not MutableSpan dependencies
or physical payload ownership. All accesses remain ~Copyable/~Escapable and
retain the session dependence. Bank-local count and original physical identity
stay together through swaps. Retain the existing real accepted/refused,
generation, root replacement, Canvas, gesture and owned-dispatcher assertions.
This is a minimal test realization of approved S11/ADR-039, **not adoption or
validation of SO-04's production owner, cleanup, layout or resources**.

Keep the existing **27 labels, positive twins, omitted-input causes and owned
dispatcher negative** unchanged. Shared-session operations alone cannot replace
the independent-input matrix: that would make an omitted input potentially
redundant. Existing driver label wiring may change only if essential to choose
the two fixture families, with no added compile cells/looser negative matching.
Prefer no driver edit. No Interaction/RuntimeCore/measurement/analyzer/Package
change is proposed. No payload-copy exchange, no-op executable exchange,
lifetime erasure, blanket suppression, pointer-only token, public factory,
arbitrary conformer entry or disabled exclusivity is an acceptable correction.

**Alternative:** keep the current stop and reuse the same common-session fixture
mechanism when separately authorized SO-04 source work supplies it. That is a
larger dependency/sequence choice, not a reason to retry unchanged SO-03 or an
authorization to start SO-04. A field-only reconstruction is not a sufficient
repair option because it leaves the second diagnostic class unanswered.

The precise next request is **one bounded fixture correction, then exactly one
fresh native SO-03 driver invocation; zero automatic follow-up repairs**. Freeze
and commit the corrected unvalidated source/27 labels/argv before entry, with
formatter/governance/diff and read-only pin checks. Use the same command:

```text
scripts/contracts/run-spec-011.sh --profile macos-dynamic --compiler-baseline rfc-014 --giftui-build .build/contracts/spec-006-rfc-014-swift64/af66aaf967e3fe8f-__4p5wu2/macos-dynamic
```

Maximum remains **42 compiler cells + 1 existing execute**, in a fresh immutable
directory; never overwrite attempt-1. Stop on the first positive/prerequisite
failure or wrong negative cause; preserve evidence and commit for sequential
independent Strong review. No preliminary compiler probe, retry, target/image,
repository suite or SO-04–09 allowance is included. Syntax/acceptance is unproved
until that separately authorized invocation. The new request is required because
the original explicit zero-repair/one-invocation allowance is exhausted, not
because a new architecture or pre-existing analyzer decision was discovered.

No new deferred item is created: this defect blocks current selected validation;
existing mandatory I4-07 residuals and later gates retain their prior owners.

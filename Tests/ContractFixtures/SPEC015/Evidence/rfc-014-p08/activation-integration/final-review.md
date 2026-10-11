# Independent review: integrated generic-host activation

Reviewed 2026-10-12 by independent Strong Astra 6 Medium at `4b1d642b`, under
approved compiler correction `267616c9`, normative update `470137b7` and pin
step `b594997b`. No additional compiler invocation or executable run.

**Pass for the bounded generic-host activation component.** The maintained
fixture exercises actual activation through `SignalAnalyzerPresetHostInstance`
and `MVPHostActivationController`, with real coordinator execution and cleanup.
The four ownership/lifetime negatives reject for their intended reasons. Fresh
maintained-checker and compiler-baseline regression receipts remain separate
requirements before the parent closes the activation blocker. This review does
not approve full P08 completion.

## Semantic review

The supplied owner stores real scoped model/root, semantic and Canvas values,
geometry, interaction and scoped control. It contains no pipeline, endpoint,
binding or coordinator before activation. Their first construction occurs in
`constructRuntimeAndEndpoint`, reached from the existing host's `activate`.
No production role, host/controller signature or lifetime escape override changed.

The callback-local InlineArray marker is created inside the innermost control
pointer callback, inside all real backing lenders. Its Span survives inert,
active and retired states. The marker does not own model/pointer backing; the
actual surrounding scopes supply that ownership and remain live until after
the host finishes. Negative diagnostics also preserve dependencies on real
model/root, semantic, Canvas and control captures. This is not a claim that an
arbitrary caller-supplied marker alone proves pointee safety.

The accepted real opportunity invokes the existing pipeline and endpoint. Actual
coordinator quiescence invokes existing presentation termination, which retires
root registration, pointer/routing/recovery state and admission storage. The
fixture releases its scoped runtime state before the reset-profile stage, then
returns from the surrounding backing callbacks. The failure case occurs after
actual runtime construction and confirms that containment quiesces once before
ordinary teardown. Repeated activation and opportunities outside the active
state are refused by the real host/controller; repeated teardown is idempotent.

The 48 positive assertions cover these component states, ordered adapter calls,
report runtime-use invalidation, progress reset and retained report identity.
The non-runtime application/source/platform adapters are trace stubs; their
order is tested, but real application services or platform releases are not.
The report is explicitly synthetic, with a real profile audit. It provides no
nine-stage validator or complete validation-purity evidence.

## Negative controls and provenance

- Run 2 is a mechanical oracle adaptation failure and is not counted as lifetime
  evidence. Run 3 corrects the raw-owner method to host teardown and rejects
  reachable callback escape, explicitly identifying `activationBacking`.
- Run 4 reports the actual generic host owner consumed more than once. Additional
  escape diagnostics do not obscure the intended ownership diagnostic.
- Run 5 rejects the same callback escape with the constant marker `[1]`.
- Run 6 additionally identifies the scoped access to local `profile` at its
  forbidden return. Its `immortal` declaration is a rejected proof obligation,
  not an unchecked extension used by the implementation.

All negatives have reachable mains and were never executed. Positive execution
returns 48 assertions successfully. The closed 6/12 ledger and raw receipts
agree with these classifications.

Independent verification checked all 179 original manifest entries, seven
maintained source identities, 233 dependency source identities, 50 fresh Swift
6.4 artifacts, compiler/macro hashes and all six per-run source snapshots.
No old GiftUI module/object search path was found. Existing macro reuse remains
a declared separate process; complete fresh macro/baseline validation belongs
to the parent's separate regression evidence.

The pin/setup record distinguishes project-local compiler/SDK setup and metadata
doctors from actual target validation. This component retains the historical
Dynamic-profile compilation flags with the Static coordinator; it does not
establish native Static-profile, ARMv6 or Embedded execution, ABI/resource costs,
finite counter, early images or the full P08 acceptance package.

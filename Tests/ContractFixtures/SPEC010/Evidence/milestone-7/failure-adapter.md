# SPEC-010 T7.1 Failure Adapter Evidence

`GiftUIObservableStateFailureAdapterFixture` is the first narrow target that
imports both Observable State and Failure Core. It retains the exact local
error and finite detecting context and constructs a fact only after mandatory
effects are reported complete. Sixteen legal error/context rows cover initial
and candidate binding, replacement, candidate/replacement attachment, retired
reports, active-cycle phase/reentrancy failures, generation exhaustion, and
runtime invariants with exact condition, observable-state origin, scope, and
containment.

The exhaustive Cartesian context test rejects every illegal error/context
pair, and every row rejects mapping before mandatory effects. The adapter has
no Execution, runtime, backend, diagnostic, policy, dynamic carrier, or
fallback dependency.

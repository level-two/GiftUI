# P08 callback lifetime correction — 2026-10-11

This is the next bounded assignment under the maintainer's explicit instruction
to resolve P08 and delegate bounded assignments without asking each time. The
12-call activation-resolution bench is closed at `a7d4697e`, with a failed
callback-containment criterion. Its ledger and earlier guards are not reopened.

The bench established a compiling actual activation join and rejected copying.
Independent review identified a concrete remaining defect: an owner can escape
the callbacks which retire the model/root, semantic banks and Canvas values.
Physical profile lifetime alone does not keep that activation valid.

## One corrective hypothesis

Add a private noncopyable activation token created inside the innermost supplying
callback. The scoped control value borrows that token as well as the supplied
control pointer. Copied lifetime dependence through supplied state, pipeline,
binding and coordinator must retain this callback-local dependence in both inert
and active host states. No unchecked annotation, lifetime override, preactivation
coordinator, new public role, compiler change or weakened escape requirement is
permitted. This is an internal implementation correction under SPEC-015 and
ADR-036, not a contract amendment.

Strong Astra 6 Medium owns at most eight fresh compiler invocations, including
all setup corrections, positive/negative compiles and executable linking. Record
each command and exact source/diagnostic/input identity before continuing. Stop
after two consecutive attempts without a passing check or narrowed cause, budget
exhaustion, or completion of the evidence below. No alternative storage layout or
unrelated investigation is assigned. No nested delegation.

Required controls:

- Actual supplied-profile initialization, activation-time runtime/endpoint
  construction, opportunity and quiescence compile and execute inside callbacks.
- Copying rejects for noncopyability.
- An active owner used after the supplying callbacks close rejects for lifetime
  escape even while the physical profile still exists.
- An owner returned beyond a locally owned profile rejects for lifetime escape.

Negative setup failures do not count as passing ownership controls. Do not execute
an accepted negative that could access retired backing. Freeze and commit the
finite result for independent Strong review. A passing pattern may then be
adopted with actual generic host/controller regression under the unchanged
approved contract and the user's existing implementation authorization.

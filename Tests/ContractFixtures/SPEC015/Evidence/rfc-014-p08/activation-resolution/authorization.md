# P08 activation blocker resolution — 2026-10-11

The maintainer requested: “Please resolve P08 blocker. You may delegate bounded
assignments without asking each time. Use Astra 6 Medium for Strong, Sol 6.1
Medium for Standard, and Luna 6 Medium for Economy. And please commit each step”.

This is new authorization to resolve the activation join under the unchanged
approved SPEC-015 contract, including bounded diagnosis, implementation of a
verified internal pattern, and independent review. It does not amend architecture,
compiler selection, activation ordering, resource limits, or package acceptance.
The historical production 2/2 stop and completed evidence investigation remain
unchanged. The latter's final independent review is complete, not pending.

## Step 1: bounded diagnosis and feasibility

Strong assignment: Astra 6 Medium. One sequential compiler owner; no nested
delegation. At most 12 fresh compiler invocations, including reductions, changed
module builds, positive/negative controls and executable linking. Record commands,
exact source snapshots, compiler/input hashes, complete diagnostics, and outcomes
before selecting a follow-up. Stop after two consecutive attempts that produce
neither a new passing check nor a narrower cause; preserve the failed evidence.
Stop the bench at a verified actual activation pattern or budget exhaustion.

Named hypotheses, based on read-only inspection:

1. The original optional initialization and later enum/optional transitions need
   separate lifetime controls. A small scoped state roundtrip can discriminate
   initialization from extracting/replacing a lifetime-dependent field.
2. Pipeline and binding initializers explicitly borrow an escapable control
   pointer descriptor. Borrowing that descriptor from temporary supplied state
   may make the coordinator depend on the temporary or mutable host. A private
   scoped control carrier can instead preserve the original supplied lifetime.
3. If state transfer remains an independent failure, a consuming whole-state
   helper with explicit copied lifetime dependence can be tested. This must
   remain behind the existing mutating host entry point.

Any successful candidate must compile initialization, activation, and teardown
inside the actual supplied profile scopes. Copy and outliving-backing negatives
must reject for the intended ownership/lifetime reason; failed positives skip
their negatives. Passing reduced controls alone do not establish the actual join.
No unsafe lifetime escape, preconstructed runtime/endpoint, new host role,
toolchain/feature changes, or hardware operation is in scope.

## Subsequent steps

An independent Strong review checks the bounded result and unchanged contract.
If the join is verified, adopt the smallest internal change and a maintained
regression gate; run relevant lifecycle/runtime checks and update the current
P08 checkpoint. Commit each completed step. The user has authorized this
within-contract implementation; another permission round is not required merely
because diagnosis and implementation are separate steps.

If evidence requires a contract or architecture change, prepare its concrete
reviewable proposal under the normal lifecycle instead of silently changing it.
P08 package completion, SPEC-015 implemented transition, P09, and hardware work
are not implied by resolving this blocker.

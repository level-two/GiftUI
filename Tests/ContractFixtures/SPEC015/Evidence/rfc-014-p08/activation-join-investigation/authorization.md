# Bounded P08 activation-join investigation authorization — 2026-10-11

Eugene explicitly replied **“Agree, Please proceed”** to the
[independently reviewed bounded proposal](../activation-join-stop/independent-stop-review.md#concrete-next-authorization-option).
Entry revision: clean `984a0afc`. Strong Sol6.1 High, sequential, no delegation.
This is evidence-only investigation, **not production resumption**. The historical
P08 production repair guard remains exhausted at **2/2**; prior controls and stop
remain unchanged.

Named question: can an initially inert scoped containing owner retain supplied
backing, construct/store the actual coordinator and endpoint only in `activate()`,
and enforce the backing lifetime on pinned Swift6.3.2?

## Finite allowance and stop conditions

- At most **six fresh compiler invocations total**, including every correction
  and rerun, and at most **two candidate internal storage layouts**.
- Each candidate reserves one positive compile covering initialization,
  activation and a real caller nested within **all** supplying backing scopes;
  one explicit-copy negative; and one outliving-backing negative.
- If its positive fails, skip its negatives. Negative rejection must be relevant
  ownership/lifetime rejection, not an unrelated syntax/import failure.
- Stop at the first candidate passing all three controls, six invocations, or
  two consecutive unproductive candidate attempts, whichever occurs first.
- No production integration, new compiler controls/features, unsafe lifetime
  escape, preconstructed coordinator, new host abstraction, contract changes,
  P09 work, agents or hardware. No frozen historical probe rerun or hidden extra
  compiler invocation is authorized by this allowance.

Before each compile, reserve its number in the persistent ledger. Preserve exact
source, command, complete stdout/stderr, exit and source/artifact/compiler hashes.
Report each run and remaining budget to the parent. After the finite result,
commit evidence/current checkpoints for read-only independent review and a
separate explicit production-resumption decision. A compile result cannot pass
P08 or certify full host validation/lifecycle/resource obligations.

## Two candidate hypotheses (fixed before compilation)

**Candidate A — single scoped enum state.** The containing owner is an internal
evidence-only enum with inert supplied-owner and active actual-coordinator cases.
Its initializer stores an actual supplied lifetime anchor, with no empty optional
coordinator. `activate()` consumes/reinitializes the enum state and constructs the
pipeline endpoint, admission, binding and actual Static coordinator only then.
Hypothesis: replacing the empty optional initialization with a lifetime-bearing
inert case avoids the observed initializer rejection while allowing a checked
state transition. No success or root-cause attribution is assumed.

**Candidate B — optional anchored enum state.** Only if A fails, an internal
scoped struct contains an optional of the same inert/active state, initialized to
`.some(.inert(supplied))`. `activate()` uses the existing optional transfer operation
and reinserts the active coordinator state. Hypothesis: anchoring initialization
to supplied storage while avoiding a direct consuming transition on `inout self`
may satisfy both initialization and mutation rules. This is the second and final
layout, not authorization for further factoring or a new host role.

Both candidates use the actual existing P07 focused owners/modules and concrete
coordinator. Their real caller owns the root/model, semantic arrays, Canvas value
array, layout/render/path/plan workspaces, interaction state and control storage,
and enters their supplying scopes before creating an inert owner. These are
compiler/storage controls; they are not the P08 counter or production authority.

## Entry counters

Fresh compiler invocations **0/6**; candidate layouts **0/2**; consecutive
unproductive candidate attempts **0/2**. Historical production guard **2/2**.

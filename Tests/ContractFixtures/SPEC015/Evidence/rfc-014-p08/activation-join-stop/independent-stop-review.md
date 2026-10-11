# Independent P08 activation-join stop review — 2026-10-11

**Disposition: stop confirmed; P08 remains incomplete.** Ready for human
consideration of the bounded investigation below, not production resumption.
Strong Sol 6.1 High, sequential. Frozen reviewed revision:
`2a382a677a906dd14cf10681280642fc2edf5a6c` (clean at entry). This is a read-only
review of recorded controls; no compiler, reproduction script, new probe or repair
was run. Only this review and its packet link are added.

## Evidence and authority

All four saved source SHA-256 values match [observed-controls.json](observed-controls.json).
Their differences agree with the [stop record](stop.md): property-default nil,
explicit initializer nil, removal of the complete activation method, and consuming
transfer of the four scoped fields. Repair2 retains the inert reduction; it does
not retest an activation method. Recorded commands use pinned Swift6.3.2 and the
actual P07/schema modules. Every recorded result is exit1 with initializer
diagnostic `lifetime-dependent variable 'self' escapes its scope`. These are
preserved diagnostic excerpts, not independently rerun complete logs.

The empty optional coordinator followed by activation-time construction addresses
the existing [SPEC-015 activation order](../../../../../../docs/specs/spec-015-host-configuration.md#activation)
(line1118). Its approved scoped-host requirement (lines771–778 of the same Spec)
still requires compiler-checked dependence on supplied backing, validation before
live-owner construction/exposure, and no survival beyond backing. This authorizes
no preconstructed coordinator, unsafe escape, new host role or compiler/contract
change. Earlier validated host/schema checks do not prove this storage join or
the counter lifecycle.

The initial failure is not a repair. Explicit nil and consuming transfer leave
the same initializer blocker. Removing activation excludes its body as a necessary
trigger, but identifies neither root cause nor a lawful initializer. Preserving
the conservative **2/2** stop is appropriate under the
[plan's repair guard](../../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md)
(lines118–122). The diagnostic reduction and earlier component passes do not
authorize resumption. Exact-source rejection establishes neither a compiler bug
nor impossibility of the approved contract. No substantiated contract alternative
is available for approval.

## Concrete next authorization option

Authorize an **evidence-only investigation of at most six fresh compiler
invocations and at most two candidate internal layouts**, on the same pinned
Swift6.3.2 and actual modules. Named question: can an initially inert scoped
containing owner retain supplied backing, construct/store the actual coordinator
and endpoint only in `activate()`, and enforce the backing lifetime?

For each candidate, reserve one positive compile covering initialization,
activation and a caller inside all supplying scopes, then separate explicit-copy
and outliving-backing negative controls. A positive compile alone is insufficient;
negative failures must arise from ownership/lifetime constraints, not unrelated
syntax or imports. Skip negatives on a failed positive. Every correction or rerun
consumes the six-invocation budget. Stop at the first candidate passing all three
controls, budget exhaustion, or two consecutive unproductive candidate attempts,
whichever occurs first. No success is promised.

This proposed allowance requires explicit authorization; renaming the task does
not reset the existing guard. Preserve the original2/2 record. Isolate experiment
sources/results from maintained production code, with no integration, normative
edits, compiler changes or additional layouts after the cap. Report the finite
outcome for review and a separate production-resumption decision. A passing shape
would prove only this compiler/storage question, not P08 acceptance. Alternatively,
leave P08 stopped. SPEC-015 remains `implementing`, the plan remains `active`, and
the remaining package gates stay open.

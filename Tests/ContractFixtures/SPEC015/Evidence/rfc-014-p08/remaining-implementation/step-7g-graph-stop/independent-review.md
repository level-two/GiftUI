# P08 step7g independent stop review

2026-10-12. Separate read-only Strong review by Sol 6.1 High after implementer
stopped at clean `cfaa57af`. No compiler invocation, build, source repair or
guard reset occurred. This records the reviewer findings; it is not P08 exit
review or authorization to resume.

## Disposition

**Stop upheld.** Last validated source remains `48a987cd`, with 1,348,627
assertions and 23 controls. Local conservative guard remains **2/2**; all
historical guards remain closed. Graph integration, four registered routes,
early linked target images and independent P08 exit remain incomplete.

Both frozen manifests' 28 listed files match their SHA-256 values. The pinned
compiler hash is `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`.
Both complete 70-line diagnostics identify Swift 6.4 AST-to-SIL lowering of
`CounterHostState.constructedRuntimeProjectionIsValid` and the same null
insertion assertion. The second candidate removes only the nested optional
cache inspection in both host-state helpers; it yields no passing or narrower
compiler evidence. All five changed fixture files at review match the second
frozen candidate, and the driver change is preserved in Git.

The diagnostic localizes the assertion to the new static borrowing helper;
the dynamic analogue is also unvalidated. It does not prove that the source
is valid, establish a compiler defect, or demonstrate ownership impossibility.
The earlier claim that WIP was uncommitted has been corrected: `b3950465`
contains evidence and `cfaa57af` contains the unvalidated source checkpoint.

## Dependency inventory finding

SPEC-015's Component Graph and Construction section requires exact
compiler-visible direct dependencies. It does not expressly limit them to
retained constructor references. The proposed table therefore needs a precise
role-to-owner/factory trace before acceptance; valid masks alone are insufficient.

In particular, the dependency-free `CounterApplicationOwners.gate` value and
the enclosing application owner must not be interchanged as the executor role:
the latter retains profile control. The review found no demonstrated
constructor-required forbidden forward edge. This does not approve omission of
other compiler-visible dependencies. The root review also identified the typed
`CounterFactUseCases.start` source/repository arguments for explicit disposition
in that trace; absence of retained fields alone does not justify their omission.
Any actual conflict with the required role order must be escalated before repair,
rather than changing the graph interpretation to make it pass.

## Smallest proposed bounded continuation

Requires fresh explicit user authorization; **not authorized by this review**:

1. Complete and review the role/factory dependency trace under the existing
   contract. Escalate any unresolved contract or scope question before editing
   dependent implementation.
2. Replace only the two new whole-coordinator borrowing helpers and activation
   call sites with direct checks through the existing proven `controlPointer`
   projection. Preserve root/model association at existing initializer
   preconditions, prior cache-lifetime proof, and actual application/endpoint
   checks. Inspect actual root presence, committed records, admission state,
   canonical wake and scheduler through backing.
3. Permit **one native counter validation attempt with no automatic repair**,
   using the unchanged pinned compiler and flags. Preserve the exact candidate,
   command and result, commit the step, and stop for review of that result.

This is an untested candidate, not a known workaround. No third compiler run was
performed under the exhausted allowance. The proposed allowance does not reset
the historical or current 2/2 records and does not itself authorize target
collection or a P08 pass.

## Evidence

- [Stop packet and proposed inventory](stop.md)
- [First complete diagnostic](ww2ukmjc/counter-model.log)
- [Second complete diagnostic](fbi5sbvm/counter-model.log)
- [Last validated wake controls](../step-7f-wake-controls/result.md)

SPEC-015 remains implementing, its plan active, and T8.1 incomplete.

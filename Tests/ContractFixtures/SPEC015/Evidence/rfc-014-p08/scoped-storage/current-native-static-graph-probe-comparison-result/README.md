# Graph allocation probe comparison — scoped compiler PASS

**Current disposition, 29 October 2026:** complete annotated caller evidence identifies an unnecessary synthesized equality dependency retained before optimization. Replacing only the graph probe's first `== nil` comparison with an Optional case check passes the allocation compiler gate against the exact preserved role-mapping Host candidate. Independent package review accepts this finite proof/correction. No maintained product source or ordinary fixture was changed or adopted by this package.

## Result and applicability

The annotated original failed with `[performance_callee_unavailable]` at line 7:69. In [all complete caller snapshots](semantic-attempt2-complete-snapshots.sil), the final body is lines 5731–6021; the imported `HostConfigurationError.__derived_enum_equals` reference/application is at 5765–5766. `bb0` stores Optional.none as the right operand. Equality's `bb3` requires that operand to be Optional.some, so the arm is semantically infeasible but structurally retained. The last printed phase is Mandatory Diagnostic Passes / InlineAlwaysInlining; the checker's internal traversal is not printed. Later annotation-removed optimized SIL had already removed this arm and could not expose it.

The [one-expression correction](probe-case-pattern/source.diff) preserves the validation call, annotation, all eight invalid controls, return-nine oracle and separate 256-value mapping oracle. The [exact compile](probe-case-pattern/launch.json) uses the same 42 original Counter inputs and retained candidate Host module, with only the corrected probe path and output destinations changed. It exited zero with empty stdout/stderr in 29.623 seconds; no guard event occurred. [Independent review](independent-review.md) verifies source/module applicability and output identities. No behavior execution is claimed. Successful compilation is scoped to this candidate and checker, not complete product allocation eligibility.

The preserved Host candidate has client-emitted validator/helpers and explicit equivalent role mapping. This result does not establish which of those earlier candidate edits is necessary. Its two source snapshots and original provenance are under `prior-role-candidate/`; the repository's maintained Host sources remain at accepted `3f9ba09d` bytes. The generated module/object stay in the original local build directory and are not committed; their exact independent hashes are in the review.

## Failures and accounting

Original outcomes remain unchanged. The initial `outcome.json` documentation-blocker classification is superseded by `outcome-current.json` and this result. Two failed LLVM-help invocations lacked an action then an input; neither proved flags absent. A deterministic empty-input help invocation succeeded and exposed documented dump options.

Semantic attempt 1 stopped before the checker at an unnecessary 150 KiB nonbody context sublimit because optional pass-name tracing included unrelated functions. Its complete snapshots/context and terminal are preserved. Buffered output after termination was not drained; the full 64 MiB forecast remains conservatively charged, rather than treating read bytes as total emission.

After reassessment, attempt 2 removed only optional pass-name tracing. It completed normally, exit one, retaining all 16 complete annotated caller bodies plus raw diagnostics. No body was discarded. Combined semantic retention is 734,746 bytes / 7,494 lines, below 1 MiB / 32,768 lines. The subsequent correction is a normal compile without another dump, not a restarted diagnostic acquisition.

The session's original 09:00:35.113979 UTC deadline, 7,200-second ceiling, 512 MiB cumulative processing cap, shared 8 MiB retention/transcript cap, original group limits and compiler-output 2 GiB / protected 32 MiB reserve remain. Conservative final processing provision is 536,088,810 / 536,870,912 bytes, including independent review and up to 6 MiB root packaging. No large compiler/object rehash or further acquisition is permitted within that provision. Root's scope manifest records exact copied inputs; binary outputs are retained only once locally. Package publication is bounded with 1 MiB reserved for counted transcript/closing metadata under the shared retention limit. No historical failed attempt is requalified.

## Consolidated remaining blockers and next action

- The accepted full Static entry still fails qualification; this package did not compile or run that entry. `CounterScopedStorage.swift:3070` contains a similar nil comparison, but its checker-phase attribution remains unproved. Production `CounterHostAssembly.validate` uses `if let`. Do not infer graph-algorithm failure or full-entry repair from the probe result.
- The minimal necessary Host visibility/mapping change is unselected. The preserved candidate is not adopted, and its scoped compiler PASS transfers to no restored baseline module.
- Complete current callee/provider/first-use eligibility and required U03 safety, declaration/error/Model/layout obligations remain open or unexamined as recorded. Counts and this one compiler gate do not close Batch A, P08/R07/T8.1 or any Specification.
- U04/U05 physical/window/cold costs, required target/resource and route acceptance remain behind complete applicable safety/callee prerequisites. Historical Unit FAILED and Interaction UNEXECUTED remain; prior accepted functional/resource baselines keep only their original applicability.

Next dependency is a grounded correction/attribution of the actual complete-entry comparison sites with the smallest justified Host realization, followed by necessary matching validation and independent review. No speculative annotation, runtime experiment, cold/live/hardware action, contract relaxation or iteration closure is authorized by this proof.

This supports ITERATION-003 I3-04/05 under implementing SPEC-013/015 and accepted ADR-038/039/041, tracing to the analyzer and four-stack reference requirement of ITERATION-001. It changes no lifecycle status, architecture, contract, analyzer limit or deferred-work commitment. Existing FW-038/039/040 remain sufficient.

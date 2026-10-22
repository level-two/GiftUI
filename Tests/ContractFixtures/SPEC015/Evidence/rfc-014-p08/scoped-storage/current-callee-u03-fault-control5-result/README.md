# Focused stopped-activation fault control 5

**PASS for this native bridge control only:** three cases,41 assertions; final compile exit0 (0.711055833s), control exit0 (0.484512542s). Exact returned records and combined output are retained in compile-link-direct.json/.log and run-coordinator.json/.log.

The positive baseline destroys its owned sink on successful detach while an independent ticket keeps the model alive. In both negative cases, the ticket survives the root callback, but stopped-activation cleanup destroys the remaining model/private sink before withRoot returns. The retired-unregister case also refuses detach; it is not an isolated unregister-only case. No callback is invoked after lifetime expiry.

Runtime observes destruction **before withRoot returns**. The stronger placement **inside the report-storage borrow** comes separately from the authenticated library source order: ObservableStateRootScope.swift185–199 (defer190), ObservableModelScope.swift96–110 and ObservableModelOwnership.swift128–138. Runtime does not directly instrument that internal borrow boundary. result.json preserves this distinction and exact current/original source hashes.

Reproduction is the two explicit commands in focused-invocation.txt, using the project-local Swift6.4 compiler, SDK26.5 and retained source-bound GiftUI, GiftUIObservableState and transitive GiftUISemanticCore module/object pairs. final-dependencies.json records exact fixture/compiler/executable/dependency hashes; result.json records SDK provenance and command reconstruction limits. These local raw evidence paths are intentional and do not imply historical files are maintained tests.

Original cache denial, two fixture diagnostics, aborted corrected request, missing System library, and missing SemanticCore descriptor link failures remain preserved in their separate receipts. The final method uses direct compiler execution without shell redirection, with returned combined output retained afterward. The unused retry-cache helper was never executed and is historical local material, not a maintained runner.

This is neither the full counter producer nor four-profile/cost/heap/cold/conformance evidence. P08 and wider obligations remain open. The full40-minute package budget is NONQUALIFIED after long blocked approvals; process durations do not reset or certify that clock. No production source was changed; the coordinator owns review and commit.

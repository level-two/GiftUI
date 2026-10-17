# Final checked-State correction — WIP, runner not executed

**Final source gate pending. No mechanism PASS or FAIL.** Initial1/1 consumed;
correction2/2 source began under review `7817573d`; no further source variant is
authorized. Historical Native pipeline2/2 stays closed. Source remains unaccepted.

Source changes only the existing helper append to provide leading newline trivia
and adds the maintained actual `lowerGiftUISource` output regression. The regression
reads verbatim emitted Counter/multiple-State/nested stateful-child presentation,
parses actual output and checks distinct original-wrapper helpers. It also requires
two separator diagnostics on the immutable corrective1 emitted bytes. Multi-State
adds one inert inventoried CounterModel seed; child composition uses the existing
finite calls and keeps builder arity. No generated-output repair or replacement
assertion oracle is used.

Fresh macro compile/link PASS. The first standalone test runner compile fails
because its **runner scaffolding** incorrectly names `XCTMain`/`testCase`, APIs
unavailable in installed macOS XCTest. The maintained regression never executed;
no emitted-output positive failed. The log separately contains three
`sandbox-exec: sandbox_apply: Operation not permitted` messages. Do not attribute
the unavailable-API diagnostics solely to sandboxing or infer a production failure.

The parent authorized one mechanical runner-only repair, retaining failed logs and
candidate bytes. Installed headers confirm `XCTestCase.init(selector:)`,
`XCTestSuite(name:)`, `addTest`, and execution/failure/skip counters. The prepared
macOS runner selects the **exact maintained throwing regression method**, calls
`suite.run()`, and requires executionCount==1, totalFailureCount==0 and skipCount==0.
XCTest records thrown errors as failures. It cannot certify a no-op suite.

A separate request to run the corrected continuation outside the sandbox was
**aborted by the user after346.9 seconds**. It did not execute: no setup1 argv/log,
regression executable/output or later provider log exists. That approval outcome
is distinct from the original compiler/sandbox observations. No retry or alternate
route was attempted after abortion. The source candidate was not changed by the
runner repair.

## Readiness erratum after `dbbf96a6`

The original receipt incorrectly said the corrected files were prepared and that
`evidence.tar.gz` contained “both runner files” and the “continuation scripts”.
Those historical claims were false. Read-only inspection found only original
`TestMain.swift` and `provider.py` in the workspace and original35-member archive;
`TestMain-macos.swift` and `continue-provider.py` were absent from both. The aborted
escalated shell command contained **the file writes as well as execution**, so
none of those actions happened. The author wrongly treated only execution as
aborted. No earlier corrected runner bytes or execution are asserted.

After that observation, the two corrected files were first actually written by a
separate successful default workspace patch, without running any compiler, test
or continuation. `prepared-runner.tar.gz` now contains exactly those two files;
its separate manifest pins file/archive hashes. Independent membership/hash
verification checks this new archive and the actual workspace files. The original
`evidence.tar.gz` is unchanged and still does not contain the corrected files.
This erratum preserves and corrects the historical claim rather than rewriting
the original archive. Repaired execution remains pending user approval.

[Independent readiness review](../p08-checked-state-runner-readiness-review.md)
passes the actual prepared files for the pending approved execution step. No
compiler, selector invocation or regression result is inferred from that review.

## Ready command for read-only review and explicit approval

From `/Users/eugene/work/GiftUI`:

```sh
python3 .build/contracts/p08-checked-state-correction2/continue-provider.py
```

Prepared runner: `.build/contracts/p08-checked-state-correction2/TestMain-macos.swift`.
The output stays `.build/contracts/p08-checked-state-correction2/`.
The continuation preserves all failed argv/logs, compiles the corrected runner once,
executes the exact maintained regression once, then only on PASS runs the remaining
actual lowering/fresh GiftUI/schema/presentation recipes unchanged. It records
new stage logs and refuses overwrite. It runs no application/cold workload or full
suite. Private/physical/actual-consumer/safety/cold gates remain after provider PASS.
The user must approve the pending command; this WIP record is not that approval.

`evidence.tar.gz` freezes exact current sources, the original failed runner,
compiler logs/argv, fresh macro object-map/link-list identities and original
provider script. It does not contain the corrected runner or continuation; those
newly prepared bytes are in `prepared-runner.tar.gz` as corrected above. `result.json` distinguishes setup failure, sandbox messages,
approval abortion, execution contract and unrun stages. `installed-api.json` pins
consulted headers. Macro objects remain at the preserved output path; archived
source/tool recipes and hashes describe them, not a completed regression.

Offline verifier executes no compiler/test. Governance, links and whitespace pass.
Five external files and pycache stay preserved. P08/R07/T8.1 remain open.

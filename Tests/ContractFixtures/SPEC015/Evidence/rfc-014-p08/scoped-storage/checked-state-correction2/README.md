# Final checked-State correction — WIP, runner not executed

Latest boundary: linker setup2 **compiles/links PASS**. The linked binary then
terminates in dyld (-6) before XCTest because XCTestCore cannot be found for
XCTestSwiftSupport's direct dependency. No maintained test/provider ran. A new
runtime-only continuation is actually prepared and archived, but unexecuted.
Source2/2 remains pending/unaccepted. Earlier “setup2 unexecuted” text is historical.

Current follow-up: the user approved execution after the earlier readiness
erratum. The parent ran the exact prepared continuation once. macOS runner/test
Swift source and selector compile, but **setup1 link fails**; no regression or
provider executes. The separately scoped linker setup2 below is prepared only.
Final source2/2 stays pending/unaccepted; no production feasibility PASS/FAIL.

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

## Approved setup1 execution and separate linker setup2 preparation

The original `regression-compile-macos-setup1-command.json`/log are frozen in
`linker-setup1-evidence.tar.gz`; their entries are separate from the original
unavailable-API failure and the earlier aborted approval. The user later approved
setup1, which failed at linking. The preceding snapshot's “not executed” statements
record its earlier boundary and do not describe this new approved invocation.
No test ran and no application result is inferred.

Read-only argv/library/symbol inspection finds:

- The original import-flag harvesting copied the `-F` inside `-Xcc -F -Xcc path`
  as if it were a driver option, producing literal `-F -Xcc`. This explains
  `ld: warning: search path '-Xcc' not found`.
- Xcode platform `Developer/usr/lib/libXCTestSwiftSupport.dylib` exports the exact
  unresolved XCTAssert and force-load symbols; that directory was an `-I` but
  was missing its `-L`/runtime search path.
- The already-imported pinned Swift6.4 `usr/lib/swift/macosx/testing/libTesting.dylib`
  exports the exact unresolved `Testing_toolchain.SourceLocation`, Issue and
  Comment symbols. Its interface identifies ABI module Testing_toolchain. Its
  existing `-I` likewise supplied no `-L` or runtime path. Xcode's Testing.framework
  is a distinct install name/ABI and does not replace this toolchain library.

Only the malformed two-argument pair is removed; exactly the following two
installed directories are added as `-L` and executable rpaths, in this order:

1. `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/usr/lib`
2. `/Users/eugene/work/GiftUI/.toolchains/p08-comparison/expanded/swift-6.4.0-RELEASE-osx/swift-6.4.0-RELEASE-osx-package.pkg/Payload/usr/lib/swift/macosx/testing`

Runtime review retains existing framework-root and pinned Swift runtime rpaths.
XCTest.framework has installed loader-relative rpaths for its PrivateFrameworks
and Xcode SharedFrameworks dependencies. XCTestSwiftSupport uses XCTest,
Testing.framework and _Testing_Foundation from those roots. Both Testing libraries
reference `lib_TestingInterop.dylib`: Xcode's version1 precedes toolchain version0
and exports the same two C event-handler symbols, satisfying both required
compatibility versions. The selected runner/library hashes are pinned. The
SwiftUICore implicit-link warning is not permission to link that restricted
framework directly; no such flag or library is added. Runtime success remains
unproved until the actual test executes.

New prepared command from the unchanged repository root:

```sh
python3 .build/contracts/p08-checked-state-correction2/continue-provider-linker-setup2.py
```

This is a **separately scoped mechanical linker setup**, not another production
source correction or an allowance reset. It preserves setup1 script/argv/logs,
pins the original argv and source/runner/macro/library hashes, asserts the exact
four prior stages, validates the only permitted argument delta, and refuses any
stage command/log overwrite. It compiles once, runs the unchanged exact maintained
regression once (one execution/zero failures/zero skips), then permits remaining
unchanged provider recipes only on PASS. No source/assertion/oracle/runtime-policy
change is selected. No setup2 compiler/test command ran during preparation.

`linker-setup2-prepared.tar.gz` contains exactly the actually prepared new file.
`linker-setup-manifest.json` verifies both new archives; the independent verifier
also compares the live prepared file. Previous archives/manifests are unchanged.
The next step is independent read-only command review, then mechanical execution
through the tool approval flow under the user's existing proceed instruction.

## Runtime-only setup3: same linked binary, complete search roots

`runtime-setup2-evidence.tar.gz` freezes the successful setup2 compile/link argv/log,
original failed runner argv/dyld log, checks snapshot, exact linked binary and
read-only dependency traversal. The binary was not patched or relinked afterward.
My prior claim that XCTest.framework's loader-relative rpaths would resolve all
support dependencies was incorrect: XCTestSwiftSupport needs XCTestCore directly,
and that sibling image's rpaths are not available for this lookup. The raw dyld
log proves failure before any XCTest method ran.

Read-only recursive `otool -L` inspection found **26 installed non-system images,
zero unresolved dependencies** under the explicit roots below. Absolute `/usr/lib`
and `/System/Library` dependencies remain the installed OS dyld-cache boundary;
this is an installed-file closure, not proof of successful loading. The traversal
uses default slices because installed CoreDevice has arm64e rather than an arm64
slice; no application/compiler invocation occurred during inspection. It covers
XCTestSwiftSupport/XCTestCore/XCTestSupport, Testing/_Testing_Foundation,
XCUIAutomation/XCTAutomationSupport, Xcode symbolication/result/connection/
instruments frameworks, CoreDevice/Utilities, loader-relative DTRemoteServices
and absolute Mercury. Nested/absolute paths exist without an added search root.

The prepared test subprocess alone receives `DYLD_FRAMEWORK_PATH`, in order:

1. `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Frameworks`
2. `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/PrivateFrameworks`
3. `/Applications/Xcode.app/Contents/SharedFrameworks`
4. `/Library/Developer/PrivateFrameworks`

Its `DYLD_LIBRARY_PATH` contains the two already reviewed library directories,
Xcode platform `Developer/usr/lib` then the pinned6.4 `macosx/testing` directory.
This pins the qualified Xcode interop1 preference without overriding the Swift
runtime directory. Existing executable rpaths and OS system libraries stay as
linked. All26 image bytes plus runner/source/macro bytes are checked by hash
before invocation. No global environment, library installation, production
compiler flags, framework contract, source assertion or binary changes are made.
Provider subprocesses inherit the original environment, not these runner-only
DYLD variables.

New command for independent inspection and parent tool-approved execution:

```sh
python3 .build/contracts/p08-checked-state-correction2/continue-provider-runtime-setup3.py
```

The actual file is preserved in one-member `runtime-setup3-prepared.tar.gz`, with
archive/live hashes in the verifier. It expects the exact six recorded prior
stages, refuses regression-output and named command/log receipt overwrites, invokes
**the same linked binary once** under the explicit environment, and stops on any
failure. That binary still executes the unchanged maintained regression and
requires exactly one execution, zero total failures, zero skips. Only PASS permits
the unchanged remaining provider recipes once. No source cycle reset, production
repair, prewarm, application workload or broad suite is included. No setup3 command
was executed in this preparation; final strict feasibility remains unproved.

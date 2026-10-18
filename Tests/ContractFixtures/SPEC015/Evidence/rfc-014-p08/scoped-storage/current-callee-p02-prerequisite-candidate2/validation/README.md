# Candidate 2 validation recipe — prepared only

Fixed source commits: `778233fc` plus format commit `34601caa`.
The four candidate source hashes are checked against the latter commit. All
selected input hashes are freshly read; historical freezes are provenance only.
The preceding campaign remains unchanged.

The single sequential runner uses the previously working macOS macro compiler,
linker and XCTest environment from `noncanvas-constructor-candidate1/macro`.
`prepared.json` records every exact argv and the runtime environment.
`Objects.LinkFileList`, `outputs.json`, `macro-sources` and `TestMain-macos.swift`
are packet-owned. The test main registers exactly the 19 current maintained
`ObservableStateHostMacroTests` methods and requires 19 executions, zero failures,
and zero skips. No historical test executable or macro artifact is reused.

Order: compile maintained macro sources, link the fresh macro executable, build
and run all 19 maintained macro tests; one fresh P02 producer including full
CounterPresentation, AnalyzerPresentation/DeclarationHost and its registered
P04; P07; schema-4 activation join and negatives; complete 384 counter controls.
All stages hold the ordinary repository validation lock. Producers allocate
fresh receipt directories through their maintained commands. The runner keeps
logs and qualification evidence under the unique, initially absent directory
`.build/contracts/p08-current-callee-p02-prerequisite-candidate2-validation1`.

Fresh receipts must be uniquely discovered from actual producer output, under
`.build/`, and created after their stage started. Every reported input and
artifact hash is verified; source inputs must also match this packet's freeze.
P04/P07/core/runtime/host receipt links must match the actual fresh prior receipts.
The registered P04 expected rejection keeps its real nonzero compiler status;
its maintained producer validates the diagnostic. Counter requires a complete,
passing, unfocused receipt with 384 distinct planned scoped labels. Its maintained
`--collect-failures` policy collects independent controls and blocks dependencies.
No driver, diagnostic, or test criteria change is proposed.

Preparation performs only:

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation/run.py --validate
```

A later authorized execution uses the same command without `--validate`.
The runner stops at the first material stage or receipt failure, leaves dependent
stages unrun, and refuses output reuse. One attempt, no retry, zero source
repairs, no generated-output patch, no cold, hardware, deployment, resource-limit
change or P08 acceptance. Full current-callee proof, cold and resources remain
open even if this prerequisite passes.

Preexisting dirty analyzer sources, nRF CMake/build script, Pi build script and
pycache are excluded. Python bytecode writes are disabled for future execution.
The freeze selects stable source/fixtures/scripts and the prior macro environment's
actual compiler, SwiftSyntax modules/library, C headers and XCTest dependencies;
it excludes unrelated historical executables and mutable SwiftPM outputs.

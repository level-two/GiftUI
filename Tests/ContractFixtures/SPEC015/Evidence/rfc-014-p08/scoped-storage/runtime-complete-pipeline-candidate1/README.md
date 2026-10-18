# RuntimeCompletePipeline grouped candidate1 — prepared

Source and recipe frozen; compiler unexecuted. Explicit user authorization follows
[design READY](../p08-runtime-complete-pipeline-grouped-design-review.md) at
amended d98fd154/ec2fc8e2. The new [activity](../p08-runtime-complete-pipeline-candidate-activity.md)
is ONE candidate1/1 with zero automatic source repairs; previous exhausted budgets
remain exhausted.

Exact reviewed53 sites in six files are applied:50 existing declaration edits and
three internal memberwise-equivalent constructors. All14 constructor arguments
remain required, with no defaults. Three private generic helpers become internal
serialized ABI; ordinary cleanupStage becomes internal ABI. Bodies, ownership,
lifetimes and nonselected access remain unchanged. The23 latent stage symbols and
Counter/Pi witness declarations have no edits. [Token/source audit](source-edits.json)
and [exact diff](source.diff) record the allowed changes; targeted Swift formatting
passed and567 other prior frozen inputs remain unchanged.

The [structured recipe](prepared.json) reuses the established sequential fresh
25-owner runner with canonical8 Static/13 Dynamic inputs and actual42-source host.
All project imports use its fresh isolated module directory; no stale owner module
is accepted. Pinned compiler flags, SDK and macOS framework/library environment are
unchanged. Macro reuse requires exact unchanged source/artifact identities, and
fresh lowering must match all three generated hashes. The [input freeze](input-freeze.json)
pins319 inputs; [recipe freeze](recipe-freeze.json) pins the runner and packet.
Current source imports, dependency order and registered source lists were checked.
`--validate` passed without invoking compiler, decoder or runtime.

From the repository root, execute once (expected30–90 seconds):

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/runtime-complete-pipeline-candidate1/run.py
```

Output: `.build/contracts/p08-runtime-complete-pipeline-candidate1` (must be absent).
The runner collects all independently runnable owner failures and marks dependent
owners blocked. Any material failure freezes this sole candidate; no automatic
source mutation, repair or retry. Preserve full logs/result and before/after hashes.

Compilation PASS is only the next boundary. Applicable privacy/constructor controls,
physical run/three helpers/six prior roots, concrete actual-host/all42/private-callee/
State-borrow/metadata/TLS/context/observer checks, full14-loan/Optional/lifetime/
provenance/exclusivity/failure-cleanup safety and strict cold remain unexecuted.
P08/R07/T8.1 and the combined source candidate remain unaccepted.

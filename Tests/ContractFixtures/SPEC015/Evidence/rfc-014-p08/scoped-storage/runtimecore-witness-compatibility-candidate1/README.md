# RuntimeCore witness compatibility — candidate1/1 freeze

**Source/runner frozen; compiler unexecuted.** Explicit human authorization starts
[one new exact activity](../p08-runtimecore-witness-compatibility-activity.md), with
no automatic source repairs and no reset of any exhausted historical budget.
Implements only the three previously reviewed/diagnosed `@usableFromInline`
annotations on ObservableCanvasInvocationSource's canvasOccurrenceCount,
canvasIdentity(at:) and releaseCanvas(at:) witnesses. [Per-site/token receipt](source-edits.json)
and [exact diff](source.diff) confirm every other access/body/signature/default/
ownership/lifetime/hint token unchanged. Targeted formatter PASS;306 other prior
frozen inputs, including protected5/pycache, State/macros/Counter, remain unchanged.

Run once from the repository root (expected30–90 seconds):

```sh
python3 Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/runtimecore-witness-compatibility-candidate1/run.py
```

`--validate` PASSED with no compiler invocation. The established [structured argv](prepared.json)
and sequential runner are reused with only isolated output paths and activity
accounting changed. Actual imports/DAG and canonical8 Static/13 Dynamic source
lists verify. All25 owners compile fresh; only accepted unchanged macro identity
is reused, Counter freshly lowered with accepted generated hashes. Sole project
import directory/output is `.build/contracts/p08-runtimecore-witness-compatibility-candidate1`;
preexistence rejects execution. SDK, package, optimization, lifetime flags and
macOS DYLD framework/library paths are unchanged. [309 pinned inputs](input-freeze.json)
and [recipe hashes](recipe-freeze.json) validate before and after execution.
Collect every independently runnable diagnostic sequentially; block dependents,
never publish failed modules or use stale inputs. Any material failure freezes
this sole candidate; no automatic source repair, retry or successor.

Compile PASS still gates applicable normal-import privacy twins, full14-loan/
Optional/lifetime/provenance/failure-cleanup safety, physical six bodies/all42
origins/callee/concrete CounterPipelineOwner codegen and observer attribution.
Only complete codegen+safety PASS permits unchanged strict host-first cold/reuse.
Current physical/host/safety/cold remain untested, metadata/observer/key-failure
first-use costs unresolved. Source candidate/P08/R07/T8.1 remain unaccepted.
Historical grouped initial1/1+corrective2/2 remain exhausted, unchanged.

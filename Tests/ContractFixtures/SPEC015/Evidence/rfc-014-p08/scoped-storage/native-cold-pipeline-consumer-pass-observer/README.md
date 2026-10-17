# Consumer pass observer replay — 2026-10-17

The prepared observer from `../native-cold-pipeline-consumer-loading-result/` was run once, unchanged, using its pinned source/module inputs and original module cache. The runner's preflight passed and the compiler exited 0 after 69.187653 seconds. No runtime was executed; corrective-cycle use remains 1/2.

The filtered compiler output contains 28 SIL dumps of `CounterScreen._giftUITraverse<A>(_:)`. Each is declaration-shaped and closes immediately without a basic-block body. The log records `PerformanceSILLinker` at `EarlyModulePasses` (#34962) and again at `HighLevel,Module+StackPromote` (#455183). This establishes only that the observer output did not show a body for the filtered function. It does not establish that the physical module lacks serialized SIL, nor why a body was not present in these dumps. No source repair or compiler defect is inferred.

The original three-file module cache remained unchanged. The compiler emitted 54,386,109-byte SIL and 460,307,015-byte stderr log; stdout was empty. Exact argv, timestamps, exit, output hashes and before/after cache inventories are in the raw output directory recorded in `result.json`. The prepared observer's source/compiler/plugin/module preflight is retained in the preceding committed packet; its observer command SHA256 is `73b31353a0f84f3826c05d47545901a35a48414a9015d46454798c946b85b7bc`.

This diagnostic does not close runtime, heap, or P08 acceptance gates. The five external edits and `scripts/contracts/__pycache__/` were preserved and are excluded from this evidence commit.

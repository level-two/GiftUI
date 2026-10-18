# P08 Analyzer ABI campaign11: P07 STOP

One campaign11 invocation ended at P07 with exit 1 and status `STOP_first_material_failure_dependents_unrun_no_retry_zero_repairs`. The first material failure is the compiler diagnostic in `Cycle.swift:74:12`: property `show` is not package-visible for use from `@inlinable`. No repair or retry occurred.

The campaign record contains 180 stages and 80 control receipts; all 80 control receipts qualify. P07 failed after those controls. Schema4 activation and counter384 are unrun. This archive does not claim those later stages or campaign completion.

`manifest.json` records the exact terminal result, all available campaign stage stdout/stderr, all producer receipts and authentication audits, both copies of the run freeze, relevant scratch Swift, and generated regression Swift. Each entry includes its original path, byte count, and SHA-256.

Large compiler caches, modules, executables, object files, and other binary build products remain in `.build/contracts/p08-analyzer-abi-continuation-campaign11`; they are not duplicated here.

Archival verification only: no parser, compiler, runner, retry, repair, formatter, or test was invoked.

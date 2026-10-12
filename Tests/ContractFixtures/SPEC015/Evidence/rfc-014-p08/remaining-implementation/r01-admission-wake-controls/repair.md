# R01 bounded test compilation correction

The initial driver invocation exited1 compiling counter-model before any control
executed. Its only two diagnostics were missing `NormalizedPointerEvent` names
at new test-function lines141/182. The file does not import the owning module.
The parent authorized one bounded test-only correction on this narrowed finding.
Both explicit local declarations were removed; submission calls now construct
the same values via contextually inferred `.init` inside `counterWakeControls`.
No import, production API, behavior, finite bound or oracle changed.

Initial source and exact diagnostics/invocation are preserved in `attempt-1/`.
A second validation is for this changed test source. It does not reopen historical
repair2/2 or B03 invocation1/1. Stop if its cause exceeds assigned controls.

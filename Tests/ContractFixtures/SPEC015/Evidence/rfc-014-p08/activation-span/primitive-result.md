# Direct span primitive — PASS

Run1 compiles, links and executes the direct callback-local InlineArray.span
positive. Run2 compiles the reachable negative main and rejects the captured
span escaping its marker at callback return. The marker uses a runtime-derived
byte; callback and span read functions are noinline. Complete source/diagnostic
snapshots and execution hashes are retained.2/8 compiler calls consumed.

This establishes only the primitive comparison. Actual supplied host-state
integration and all required actual-owner negatives remain to be tested under
the existing scope. No unsafe negative was executed.

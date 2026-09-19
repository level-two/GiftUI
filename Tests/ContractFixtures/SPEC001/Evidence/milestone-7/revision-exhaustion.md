# SPEC-001 T7.3 Capture Revision Exhaustion

- Evidence kind: hardware-free semantic corpus
- Operations: transition processing and Clear
- Result: pass

Both paths succeed from `UInt32.max - 1` to `UInt32.max`. The following
operation rejects before capture mutation, preserves the last complete state,
emits exactly one normalized reserved terminal fact, emits no ordinary failed
acquisition-state callback, bypasses residual policy, quiesces the repository,
and permits recovery only through a fresh object graph.

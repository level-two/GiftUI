# SPEC-008 T4.4 Render Producer Lifecycle Evidence

`RenderProducer.produce` is the exact generic package entry point joining the
two bounded traversals. Its first action checks `workspace.isActive`; reentry
returns `.reentrancyViolation` without inspecting any input, reading sink
capacity, acquiring, resetting, beginning, or discarding. An inactive
workspace is acquired exactly once; acquisition refusal returns
`.invariantViolation` without reset or input/sink access.

After successful acquisition, one deferred cleanup resets the workspace on
every preflight failure, begin refusal, post-begin failure, and success. The
entry point retains no semantic, layout, metrics, operation, resource, pointer,
or replay state after return.

Focused tests prove successful preflight/streaming with one acquisition and one
reset, invalid-input failure with the same cleanup, active reentry with zero
input/sink access and no reset of the caller's active attempt, and inactive
acquisition refusal with no reset.

Reproduce with:

```text
swift test --filter 'producer|streaming|RenderPreflightTests'
scripts/contracts/check-spec-008-render-producer-lifecycle.rb
```

This is host execution and source evidence only. It performs no simulator run,
deployment, connected-hardware execution, or flashing.

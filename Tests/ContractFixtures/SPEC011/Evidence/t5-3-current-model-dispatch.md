# SPEC-011 T5.3 Current-Model Dispatch Evidence

`GiftUIInteraction` now exposes the exact `InteractionDispatcher` contract and
a borrowed committed-record view. The target-composed Runtime Core adapter
immediately re-reads identity, action generation, enabled state, and current
target generation, performs total typed action decoding, and borrows the model
only for one synchronous handler call.

The adapter is generic over the concrete record view, handler, and target
access. It retains no model, callable registry, existential handler, or action
value in Interaction or capture state.

Reproduce with:

```sh
swift test --filter RuntimeInteractionDispatcherTests
```

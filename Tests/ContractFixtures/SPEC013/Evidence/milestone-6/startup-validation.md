# SPEC-013 T6.2 Startup Validation Evidence

Evidence kind: host execution and inspection. No simulator, connected target,
deployment, service restart, or flashing was used.

## Result

The shared Runtime Core validator rejects the six canonical startup failures
in their required order: invalid limits, incompatible limits, missing storage,
insufficient storage, checked byte-total overflow, and invalid Static callable
metadata. Each local error maps to the exact SPEC-003 condition, origin,
runtime scope, and containment recorded in `startup.yaml`.

The simultaneous-fault test proves the first applicable error wins. The
startup-purity test retains zero uses for client, attachment, input, wake,
policy, backend, and endpoint probes across all six failures. Static metadata
lookup is independently poisoned and remains untouched until the preceding
five validation steps pass.

## Reproduction

```sh
scripts/format-swift.sh
swift test --filter GiftUIRuntimeCoreTests.RuntimeProfileValidationTests
swift test --filter GiftUIRuntimeFailureAdapterTests
scripts/contracts/check-spec-013-startup-corpus.rb
scripts/contracts/check-spec-013-harness.rb
```

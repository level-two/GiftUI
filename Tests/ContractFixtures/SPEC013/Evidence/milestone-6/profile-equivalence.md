# SPEC-013 T6.6 Dynamic/Static Equivalence Evidence

Evidence kind: host execution and inspection. No simulator, connected target,
deployment, service restart, or flashing was used.

## Result

The conformance fixture constructs both concrete profile bindings with equal
common limits and equal sixteen-byte storage audits. Both receive the same
normalized root, resources, initial model, facts, pointers, capabilities,
endpoint script, and policy tokens and execute the same common pipeline owner.

The resulting validation, lifecycle, admission, mutation, Semantic, Layout,
Drawing, Render, Interaction, offer, failure, cleanup, and final result records
compare value-for-value with zero tolerance. Only the Specification's explicit
private representation fields are excluded: addresses, private bytes,
allocation strategy, generated-code addresses, and diagnostic volume.

## Reproduction

```sh
scripts/format-swift.sh
swift test --filter dynamicAndStaticBindingsProduceEqualCanonicalTranscripts
scripts/contracts/check-spec-013-equivalence.rb
scripts/contracts/check-spec-013-harness.rb
```

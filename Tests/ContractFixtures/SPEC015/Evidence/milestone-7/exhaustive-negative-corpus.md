# SPEC-015 T7.1 Exhaustive Negative Corpus

The maintained corpus covers the ordered component graph, one-shot nine-stage
validation ledger, every runtime and text failure family, schema-1/malformed/
stale schema-3 inputs, semantic-structural and all render-workspace source/limit relations, Drawing
and capability independence, all capability contribution permutations,
endpoint/action/input projections, 28/32/33 fact boundaries, producer limits,
policy and no-policy routing, lifecycle/teardown states, diagnostic isolation,
checked arithmetic, and injected focused-owner failures.

The audit also retains the forbidden-import and portable-source scans. It is
reproduced from the repository root with:

```text
ruby scripts/contracts/check-spec-015-negative-corpus.rb
ruby scripts/contracts/check-spec-015-source-boundaries.rb
swift test --disable-sandbox -Xswiftc -DGIFTUI_DYNAMIC_PROFILE \
  --filter GiftUIHostConfigurationTests
```

The Dynamic profile flag is required because the focused suite includes the
conditional target-host Canvas and presentation fixtures even when the selected
SPEC-015 product is cross-compiled separately. The 2026-09-20 run passed the
audit and all 158 focused host-configuration tests. No connected target,
simulator, deployment, remote access, or flash was used.

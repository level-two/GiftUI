# T7.2 Signal Analyzer Render Surface

The manifest now enumerates the approved application title and subtitle,
time-ruler label and bounded values, four explicit channel labels, HIGH/LOW
levels, four status values, six controls, and a nonempty bounded acquisition
error. Five foreground roles and six rectangular-background roles use only
opaque RGB components.

The maximum failed/five-second/four-channel hierarchy contains 32 laid-out
occurrences, 21 foreground text scopes, and 9 background scopes, for 62
semantic render scopes. Its 21 text groups contain 139 positioned ASCII glyphs
and combine with 9 fills for 30 operations. The fixture records layout,
traversal, line, clip, and foreground high-water separately and proves every
value fits the exact common render limits, structural workspace capacity, and
sink capacity. The 352 logical workspace bytes consist of two 128-byte visit
sets and exactly 32 three-byte `Color` slots.

These are backend-free fixture limits and high-water values, not final
production-host budgets or connected-target evidence.

Reproduce with:

```console
scripts/contracts/check-spec-008-signal-analyzer.rb
scripts/contracts/check-spec-008-harness.rb
```

# SPEC-007 T3.3 Preflight Counter Evidence

`LayoutCounters` owns the five checked `UInt16` totals and sticky first
failure. Its focused tests prove equality-at-limit success, one-over rejection
without counter mutation, overflow rejection, balanced scope depth, maximum
depth high-water, and declared/traversed scope agreement.

The generic entry compares every call limit with its corresponding reported
workspace capacity before acquisition or semantic/metrics access. The
semantic validator then rejects a declared scope count above the call limit
before reading the root identity. Further probes cover missing in-range child,
modifier, and scalar values; invalid public payloads and Unicode scalars;
transparent root/modifier cardinality; and exact canonical text instance,
mapping, and metrics availability.

Reservation-order probes establish that:

- the second scalar is not read after scalar capacity is exhausted;
- the scalar that is an explicit break is read, but no later scalar is read
  when line capacity is exhausted; and
- the second glyph mapping is not requested after glyph capacity is
  exhausted.

Proposal-dependent wrapping in T5.2 consumes this same global line counter;
it does not introduce a separate count or admission path.

Reproduce with:

```text
swift test --filter GiftUILayoutTests
```

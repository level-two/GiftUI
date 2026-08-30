# SPEC-004 T3.4 Profile Equivalence and Static Storage Evidence

The macOS contract driver compares each executable profile transcript directly
with its counterpart when present. After running static then dynamic, both
profile reports contain:

```text
status=byte-for-byte-equal
```

The compared transcript contains the same 42 ordered rows for arithmetic,
resolver role permutations, negative boundaries, instrumentation, all four
normalized configurations, one-shot ownership, and precedence.

The static allocation probe exercises the complete initialization and access
path inside its measured 10,000-iteration loop:

1. construct all four bounded contribution values;
2. insert them into the fixed role-addressed contribution buffer;
3. resolve through caller-owned two-slot workspace;
4. inspect the bounded validation-result enum;
5. construct and store an optional `CapabilitySnapshot`; and
6. repeatedly read the immutable effective row bytes from that snapshot.

The measured allocation count is zero. The same report records these bounded
layouts:

| Value | Size / stride |
| --- | ---: |
| `RasterPresentationContributions` | 93 / 96 bytes |
| `RasterPresentationResolverWorkspace` | 52 / 52 bytes |
| `EffectiveRasterPresentation` | 40 / 40 bytes |
| `CapabilitySnapshot` | 40 / 40 bytes |

Contribution storage contains four fixed role slots and a duplicate mask;
workspace storage contains two fixed candidate slots; result and snapshot are
bounded values. No collection, registry, heap owner, or retained borrow enters
the static path. The production resource-image symbol check separately proves
the operation instrumentation is compiled out.

Validated on 2026-08-30 with static and dynamic macOS drivers in both direct
comparison directions, followed by the ARMv6 and nRF52840 hardware-free
drivers. All passed; no deployment or flashing occurred.

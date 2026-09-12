# SPEC-012 T5.4 Combined Render Offer-Failure Evidence

The focused combined-production matrix injects five independent offer-time
faults against the canonical fill/stroke/glyph stream:

| Fault | Result | `begin` | `finish` | `discard` |
| --- | --- | ---: | ---: | ---: |
| idle sink refusal | `sinkRefused` | 1 | 0 | 0 |
| actual capacity below the expected header | `invariantViolation` | 0 | 0 | 0 |
| expected-header drift | `invariantViolation` | 0 | 0 | 0 |
| first stroke refusal after begin | `invariantViolation` | 1 | 0 | 1 |
| streaming completion plan-summary corruption | `invariantViolation` | 1 | 0 | 1 |

The accepted control case completes one begin/finish pair with no discard.
Every row resets the caller-owned render workspace exactly once. The
streaming-corruption fixture shares one immutable-plan observation counter
across the producer's two plan views so preflight completion succeeds and the
paired streaming completion detects the later disagreement before `finish`.

Reproduce the evidence with:

```sh
swift test --filter canvasProduction
```

This is host fault-injection evidence. SPEC-009 owner-adapter integration and
cross-profile failure comparison remain assigned to T7 and T9.

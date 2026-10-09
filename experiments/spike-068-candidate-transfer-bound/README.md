# SPIKE-068: transfer lower bound

Disposable evidence for the [one-candidate assessment](../../docs/iterations/iteration-003-review/candidate-go-no-go.md).
**Result: the candidate fails G3. Experiments stopped.**

The native probe uses the production nRF generated semantic control, common
Layout and shared Render to record the fill operations for the running normal
screen. It omits Canvas strokes through Render's existing empty extension and
ignores text pixel costs. This understates the retained transfer work.

| Quantity | Result |
| --- | ---: |
| Root bounds | 320 × 220 |
| Root background alone | 70,400 pixels / 140,800 bytes |
| Nine background fills, including painter-order overlap | 127,120 pixels / 254,240 bytes |
| Configured display SPI maximum | 4,000,000 bits/s |
| Root background wire lower bound | 281.6 ms |
| All fills wire lower bound | 508.48 ms |
| Required frame budget | 250 ms |

The result is a physical lower bound, **not measured device time**:
`254240 bytes × 8 bits/byte ÷ 4000000 bits/s = 0.50848 seconds`.
Commands, bus gaps, glyphs, strokes and all CPU work add to it. Even sending
only the root background is already over budget.

Why overlapping fills count: `RenderStreaming` emits the backgrounds in painter
order; `RasterFillCoverage` visits every clipped pixel; the operation-major
session submits each operation's tiles before the next operation. The tile
emitter forwards affected runs to the nRF transport, which calls
`spi_tft_write_rgb565`. That driver sends every RGB565 byte over its configured
single SPI data path. There is no retained-frame comparison or controller-side
rectangle-fill command eliminating those bytes. Source identities for that
chain are retained in [decision.json](evidence/decision.json).

Reproduction, from the repository root, in an otherwise fresh output directory:

```sh
python3 experiments/spike-068-candidate-transfer-bound/run.py --repair 1
```

The argument preserves the successful attempt's original output-path identity;
it does not authorize reopening the completed assessment. The driver refuses
to overwrite an existing attempt. Outputs reside in
`.build/iteration-003/spike-068/repair-1/`. `/usr/bin/swiftc` was Swift 6.3.3.
The combined fixture removes imports and includes the exact semantic-variant
enum from `StaticPreset.swift`; it is not the firmware's separate-owner build.
The unresolved macro-plugin declaration warning is retained. No macro expansion
is used by this generated-control geometry fixture.

Retained evidence:

- [Successful source/recipe/compiler identities and commands](evidence/attempt-2.json)
- [Clipped rectangles and total](evidence/attempt-2-run.log)
- [Successful build log](evidence/attempt-2-build.log)
- [Initial failed build record](evidence/attempt-1.json) and [diagnostics](evidence/attempt-1-build.log)
- [Gate decision and accounting](evidence/decision.json)

One probe repair added the omitted production semantic-variant enum and
unwrapped the known-valid surface rectangle. The first compiler failure is not
classified as a framework or candidate defect. Two compiler drivers and one
native execution were invoked. Compiler/linker child processes were not traced
individually; the full 24-invocation allowance is conservatively charged closed,
with no exact child-process count claimed. One of two repairs was used.

No new candidate, target firmware, hardware operation, memory/stack claim,
counter implementation or sustained workload pass was produced. The candidate
preserves this operation/transport strategy, so G3 can be rejected without
finishing its otherwise unproved G1/G2 implementation. A different renderer,
damage policy, transport configuration or requirement is a separate decision.

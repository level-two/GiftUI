# Module-resolution diagnostic replay — 2026-10-17

Subsequent [consumer-only replay and observer recipe](../native-cold-pipeline-consumer-loading-result/README.md)
omits the conflicting optional trace flag and establishes the frozen physical
imports. Function-body serialization/optimizer reasoning is still unresolved;
no corrective2 or runtime occurred.

This packet records the one provider replay and the one consumer replay authorized by the independent setup review at `../native-cold-pipeline-module-resolution-diagnostic/independent-setup-review.md`. Both used frozen archived sources and the original module cache. No source, compiler input, cache contents, flags, or maintained configuration were changed.

## Result

The provider replay passed. It loaded the fresh `GiftUI` and `P08CounterSchema` modules from `.build/contracts/p08-native-cold-correction1-codegen`; the emitted `P08CounterPresentation.swiftmodule` SHA256 is `aa24dafcd48c8dc1079bae766633e723f980767af04240b7f11bd4b125e71439`, identical to the frozen counterpart. Its macro expansion output shows generated `_giftUITraverse` and `_giftUIVisitObservableStateDeclarations` declarations and attributes. Module-serialization remarks were emitted, but these diagnostics do not decode per-function serialized bodies.

The consumer replay exited 1 after 0.089 seconds with:

```
<unknown>:0: error: cannot have '-emit-loaded-module-trace-path' with '-supplementary-output-file-map'
```

It produced no SIL, module, or loaded-module trace. As directed by the review, there was no retry or flag variation. Consequently, this replay does not establish the consumer's physical module imports or any consumer body-availability observation. The earlier optimized SIL's generic apply remains independent evidence; body availability, rejection reason, and compiler limitation remain unresolved.

The original cache's three inventoried files were byte-identical before and after each replay; no files were added or removed. Provider exit was 0; consumer exit was 1. The source correction allowance remains 1/2; these source-unchanged diagnostic replays consume no correction cycle. No runtime or acceptance claim follows from this packet.

## Reproduction record

Raw commands, argv, timing, stdout/stderr, hashes, loaded-module trace, provider outputs, and before/after cache inventories are retained in `.build/contracts/p08-native-cold-correction1-module-resolution-diagnostic-replay2-actual/`. Its `preflight.json` records HEAD `1f83f71b58ffd35e8128825e9ef8a7170dd4b6f2`, compiler SHA256 `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69`, macro SHA256 `a3f145cb593164dc9bbb9a19f960efe4e63244a0069a78bd7c6d0675080df306`, and physical module inventories. Provider ran 2026-10-17 09:57:15.798556–09:57:16.128325 UTC; consumer ran 09:57:28.583387–09:57:28.672563 UTC. Provider stderr SHA256: `5ef086b7063d7654f06c052273f832389e2702c36e66741b7a0389312bf694e6`; consumer stderr SHA256: `6a412c69139c843b6543df5698c8a36bf60b80e1bb4c49de505453427ecedc06`.

The five pre-existing external edits and `scripts/contracts/__pycache__/` were preserved and are not included in this evidence commit.

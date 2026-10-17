# Corrective1 module-resolution diagnostic — 2026-10-17

The [independent setup review and exact repair](independent-setup-review.md)
approves one provider/consumer replay using the hash-verified original cache in
place. The copied PCM is not relocatable. This is setup repair, not corrective2;
the confirmed diagnostic flags do not promise physical SIL-body decoding.

**Stopped at the provider replay.** The archive and all 228 members verified; the pinned compiler, fresh macro, ten physical module candidates, archived source inputs, SDK identity, and ordered import search paths were recorded in `.build/contracts/p08-native-cold-correction1-module-resolution-diagnostic/preflight.json`. The one `swift-frontend -help-hidden` query exited 0 and confirmed all five requested diagnostic flags.

The provider replay used the archived `diagnostic/Counter.swift`, exact archived command flags and ordered `-I` entries, with only module-cache and output paths redirected. It exited 1 before module loading completed: the copied `SwiftShims` PCM embeds the original cache path (`.build/contracts/p08-native-cold-correction1-codegen/cache/71QIQMNC0J8X`) but the replay supplied `.build/contracts/p08-native-cold-correction1-module-resolution-diagnostic/cache-copy`; the frontend rejected that PCM and reported `missing required module 'SwiftShims'`. No provider module/object or loaded-module trace was emitted. Provider stdout was empty; stderr SHA-256 is `d9039fd93460b4a0bfc1a7d429e1cdb29bc5f7f5d35a9841cd58c3b2932ebacd`.

The copied and original cache inventories were unchanged by the failed invocation. The consumer replay was not run. Consequently, physical import selection, macro-expanded output, and serialized/deserialized body availability remain unresolved; this diagnostic gives no new evidence that a body is absent or unavailable. The review’s independently verified concrete host apply at `0x54874` remains the surviving call observation. No runtime, source edit, restoration, or corrective2 action occurred. The five external diffs retain SHA-256 `731edcb6d8b9458a3c7519ea0efd9f3988314b510b105ddfef718013394c2ac7` and pycache remains preserved. Corrective-cycle accounting remains **1/2**.

Raw commands, help output, cache inventories, and stderr are preserved under `.build/contracts/p08-native-cold-correction1-module-resolution-diagnostic`; the complete provider argv and timestamps are in `provider/command.json` and `provider/result.json`. The immutable corrective1 packet remains at `Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/native-cold-pipeline-correction1-result`.

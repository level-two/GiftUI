# A4 successor proposal identity map

Status: **PROPOSED; read-only provenance snapshot, not an execution freeze.**

All paths below are relative to this proposal's parent `validation-result/`
directory unless stated otherwise. SHA-256 values were read from file bytes on
2026-10-18 without importing/running the parser or a compiler. This map identifies
the inspected evidence; it does not authorize modification, reuse or resumption.

## Frozen packet and archived evidence

| Path | Bytes | SHA-256 |
| --- | ---: | --- |
| `analyzer-abi-continuation-campaign2-preparation/execute-proposal.py` | 24949 | `96ac75eb4653830f4ec6288bb491f1a2a4acc9ada8c952e9ccb954ee9b2f579e` |
| `analyzer-abi-continuation-campaign2-preparation/controls.json` | 18461 | `3cee9a943e1dc1a2e67c6319ac992a7f78c652e2e20772c50fa6c80792435553` |
| `analyzer-abi-continuation-campaign2-preparation/recipe.json` | 17444 | `ea0ef0dcec29a5ca471ac1246f7fe787d6c8f0dad329014aac1c63e4018e47e9` |
| `analyzer-abi-continuation-campaign2-preparation/packet-hashes.json` | 1996 | `0ab5ddbc1fb10df947b54eebb258b36e52c9aa0a287fdb7c5511c3f5af2d3a3e` |
| `analyzer-abi-continuation-campaign2-preparation/scratch-sources.json` | 29930 | `785599545b58e75b03cce6cabe5884f803519ebeba975b3057c1fb226bb9ea76` |
| `analyzer-abi-continuation-campaign2-preparation/selectors.json` | 4489 | `6c401231bf2c0dc4905b178df977ab3674506b9ef70d672af428af6a1898c17f` |
| `analyzer-abi-continuation-campaign2-preparation/provenance.json` | 8134 | `7943954bace95bf7efa94e8f4c8f0877d9067931c120c2e18b63cedbfd17de24` |
| `analyzer-abi-continuation-campaign2-preparation/diagnostic-synthetic-cases.json` | 40358 | `f79bc14bbfdb36cd20f9178fa6aaef1f299233533cec7b485cd006e2ee4b3c99` |
| `analyzer-abi-continuation-campaign2-preparation/diagnostic-static-validation.json` | 4842 | `e3fbc99a572f00852c10cb998c6984eeb75773e711b80c449b09a4b9de51f8be` |
| `analyzer-abi-continuation-campaign2-result/result.json` | 114678 | `a78a8d0986e689dfe42326e2f3c9b8030bf96f903fc3eab97fe2cf83e2efa9db` |
| `analyzer-abi-continuation-campaign2-result/manifest.json` | 23502 | `12b0cd0910b2a0a1f10dc718aecde701cb6378e779ce11510d718a85a5752f12` |
| `analyzer-abi-continuation-campaign2-result/postformat-freeze.json` | 86847 | `0cb2c32520e4344940c4801c9bfea21206e828dd2d6db07dfb8ae06dd4840333` |
| `analyzer-abi-continuation-campaign2-result/logs/macos-static-negative-A4-SignalAnalyzerDomain.stderr` | 766 | `391335ae6ec9476f0bcdd8171297309390cf67f1fc6d115832c7cbdcb5d6b624` |
| `analyzer-abi-continuation-campaign2-result/logs/macos-static-negative-A4-SignalAnalyzerDomain.stdout` | 0 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `analyzer-abi-continuation-campaign2-result/negative-A4-inputs/SignalPrimitiveValues.swift` | 1564 | `9c19b9df952323041e6b0f4e7bce3bcfe73d3557af2e40c47719c19e55993e1d` |

## Logical identity and authority map

| Item | Identity and proposed treatment |
| --- | --- |
| Historical campaign | `campaign2`; terminal STOP; one allowance consumed; zero repairs/retries |
| Exact stopped stage | `macos-static-negative-A4-SignalAnalyzerDomain`; exit 1; stdout empty; stderr hash above |
| Historical cell | `/Users/eugene/work/GiftUI/.build/contracts/p08-analyzer-abi-continuation-campaign2/macos-static/scratch/negative-A4` |
| Historical primary | Exact cell path plus `/inputs/SignalPrimitiveValues.swift`, line 22 column 17 |
| Control identity | `negative-A4`; `abi-negative`; removed selector A4 only; first stage `SignalAnalyzerDomain` |
| Immutable expected category/symbol | `serialized-ABI-access` / `SignalChannelID` |
| Primary pattern identity | Original A4 `primary_message_patterns_all` in the controls file above; not widened |
| Display excerpt identity | Same primary path, input hash above, declaration line 1 and exact gutter bytes in README |
| ABI symbol evidence | Primary target row 22; display excerpt/note contributes no evidence |
| Source candidate | Existing eight-annotation candidate and complete 541-input postformat freeze; no source edit or new candidate created here |
| Original freeze path | Repository-relative `Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/scoped-storage/current-callee-p02-prerequisite-candidate2/validation-result/analyzer-abi-continuation-freeze/postformat-freeze.json`; archived identical copy is pinned above |
| Compiler | Repository-relative `.toolchains/host/swift-6.4.0-RELEASE-osx/usr/bin/swiftc`; provenance pins resolved driver SHA-256 `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69` |
| Target and SDK | `arm64-apple-macosx26.0`; `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk`; exact archived argv is in result.json |
| Flags and plugin | Exact archived stage argv and recipe above; no inference that SDK/plugin paths alone establish future byte identity |
| New parser identity | None yet: this directory contains documentation, not a successor implementation |
| Proposed policy scope | Only the specified macOS Static A4 display note; other existing controls/categories retain existing expectations |
| Feature lifecycle | `giftui-mvp-architecture` / SPEC-015 implementing; P08/R07/T8.1 open; no manifest/status edit |
| Existing architecture | Accepted ADR-035/036/037, ADR-039; no normative defect/change proposed |
| Future campaign | Unallocated; new packet, roots, complete inventory, freeze applicability review and explicit human allowance required |
| Qualification | A4 still unqualified; no retroactive pass or strict-cold/resource/conformance claim |

The archived result's `postformat_freeze_sha256` agrees with the pinned copy.
This document does not requalify all 541 inputs, artifacts or receipts. A future
packet must perform its own reviewed identity checks and cannot use this table
as a substitute for its complete producer/module/plugin/SDK inventory.

See [the policy and fixture proposal](README.md) for the exact proposed behavior,
finite adversarial matrix, current uncertainty and separate human gates.

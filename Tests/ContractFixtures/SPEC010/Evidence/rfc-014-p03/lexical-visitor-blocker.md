# P03 lexical visitor safety blocker — 2026-10-10

Status: P03 stopped pending Strong review of the bounded realization. The unsafe
prototype was removed before commit. This is a demonstrated implementation
safety defect, not yet proof that an approved contract must change. No P03 exit,
whole-module or integration claim is made.

The public SPI in `Sources/GiftUI/ObservableState.swift:147–157` declares
`_GiftUIObservableStateDeclarationVisitor` and `_GiftUIObservableStateHost` with
ordinary Copyable/Escapable generic `Visitor`. A conforming host can copy the
visitor into an escaping closure and invoke `visit` after the original call.
The durable [adversarial fixture](../../RuntimeDerived/EscapingVisitorProbe.swift)
compiles successfully under the pinned native compiler. It is deliberately
never executed with a stale backing address. A private concrete visitor type or
its private initializer does not prevent a generic public witness from copying
that value. Therefore a temporary visitor holding raw model/ledger/root pointers
cannot claim scoped safety merely because generated witnesses are synchronous.

The rejected prototype held those raw pointers to adapt the public witness to
`ObservableStateRootScope`. It and its untested candidate-offer/reconciler work
are omitted. Existing direct root callbacks remain noncopyable/nonescapable and
are tested separately. The fixed report callback repair does not depend on this
visitor and is retained.

## Evidence

- Reproduction result: compiler exit 0; no diagnostics; no execution.
- Driver: `scripts/contracts/check-spec-010-model-identities.py --giftui-build .build/contracts/spec-006-rfc-014/58ab1755cf57c634-0urm4i3k/macos-static`
- Component receipt: `.build/rfc014-p03/state/tmpgqre2h5_/macos-static/result.json`.
- Fixture SHA-256: `728a47dfc0f7b809aaa2ff8b23c2d8839be9afeba7f69845e8c7cc95d8b9530a`.
- Compiler: `.toolchains/host/swift-6.3.2-RELEASE-osx/usr/bin/swiftc`.
- Compiler SHA-256: `d8e40107da0e2c1c59640a983faea326d5d2bddfe81f7609db14bade43c4a5b9`.
- Core receipt SHA-256: `79b03e07ac632a9f9e73e92ba021f932ee92abbc59d3a1ef2607285d28dbf0f6`.
- Source commit at check: `e1cb8711efabbde1afa274c061ceb3c2de95dd2f`; exact modified inputs are
  hashed in the receipt. The following is the exact compiler invocation:

```text
/Users/eugene/work/GiftUI/.toolchains/host/swift-6.3.2-RELEASE-osx/usr/bin/swiftc -swift-version 6 -Osize -whole-module-optimization -enable-experimental-feature LifetimeDependence -enable-experimental-feature Lifetimes -package-name giftui -module-cache-path /Users/eugene/work/GiftUI/.build/rfc014-p03/state/tmpgqre2h5_/macos-static/cache -disable-sandbox -target arm64-apple-macosx26.0 -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX26.5.sdk -load-plugin-executable '/Users/eugene/work/GiftUI/.build/rfc014-p02/tool/debug/GiftUIMacros-tool#GiftUIMacros' -I /Users/eugene/work/GiftUI/.build/contracts/spec-006-rfc-014/58ab1755cf57c634-0urm4i3k/macos-static -parse-as-library -I /Users/eugene/work/GiftUI/.build/rfc014-p03/state/tmpgqre2h5_/macos-static -enable-testing -module-name P03EscapingVisitor -emit-object /Users/eugene/work/GiftUI/Tests/ContractFixtures/SPEC010/RuntimeDerived/EscapingVisitorProbe.swift -o /Users/eugene/work/GiftUI/.build/rfc014-p03/state/tmpgqre2h5_/macos-static/escaping-public-visitor.o
```

## Smallest options for review

1. Audit an owned-value two-pass implementation under the current contract:
   collect bounded typed `State` values without backing pointers, bind them in
   the root scope after that call, then write back only bound nonowning values.
   This is unimplemented and unproven. Check SPEC-010 baseline lexical
   enumeration/pre-body binding (`Build-time state-host generation`,
   `Declaration discovery and reconciliation`, OS-001) and amendment discovery,
   first-failure, candidate ownership and bounds. It must not add State location
   capacity, evaluate a seed twice, attach twice, or execute a body before every
   declaration is bound. If compatible, this may be a bounded implementation
   repair with no public-contract change.
2. If a pointer-backed visitor is necessary, propose noncopyable/nonescapable
   lifetime constraints for the public visitor/host SPI through its owning
   SPEC-006/010 contracts. Existing generated witnesses and all consumer
   signatures would need matching negative-escape evidence. No amendment is
   authorized by this record.
3. A sealed/generated-only boundary would need enforceable restrictions, not a
   convention about who implements the public protocol. No such enforcement or
   contract authority has been established; it is not a current safe fallback.

Strong review must distinguish a valid current-contract repair from a necessary
contract decision before human escalation. Repair counter remains 0 consecutive
unproductive attempts of 2: the adversarial probe produced decisive new evidence;
no repeated speculative repair was attempted. Stop is for safety/authority,
not exhaustion of the repair budget. No Future Work item is created for this
in-scope blocker, and no downstream package is started.

# Independent review: frozen compiler comparison

Reviewed 2026-10-12 by independent Strong Astra 6 Medium at `8b3b3a89`.
Read-only source, command, receipt, diagnostic and hash review; no compiler
invocation or executable run by this reviewer.

**Swift 6.4 is a verified remedy candidate for the exact native minimal control.
Swift 6.3.3 is not. Neither compiler is adopted for P08 by this review.**

| Package | Positive | Wrapped-owner callback escape | Direct Span.take escape |
| --- | --- | --- | --- |
| 6.3.3, reports 6.3.3 | Compiles, links, executes successfully | Accepted; never executed | Intended lifetime rejection |
| 6.4.0, reports 6.4 | Compiles, links, executes successfully | Intended lifetime rejection | Intended lifetime rejection |

The 6.4 wrapped-owner diagnostic identifies `escaped`, its dependence on the
callback-local `marker`, and callback return as the escaping use. The direct
Span negatives identify the same intended boundary. These are not syntax,
feature, SDK or link failures. Both positive outputs and successful execution
receipts match. The 6.3.3 accepted negative was never executed.

All six source sets match the frozen historical controls byte-for-byte. Every
command matches its historical command except compiler, output and module-cache
paths. Target remains `arm64-apple-macosx26.0`, SDK remains macOS 26.5, and
`-Osize`, whole-module optimization, language mode and lifetime features remain
unchanged. No GiftUI source/object is imported or linked. Historical search and
plugin arguments are retained but are not exercised by these Swift-only sources.

Independent integrity verification checked all 54 frozen manifest entries,
all source hashes, both downloaded package hashes, both compiler hashes and
both signature-record hashes. The setup records retain successful signature
verification and official package URLs; extraction stayed project-local. The
closed six-call ledger agrees with raw receipts. This review adds its own
manifest entry without changing the frozen runs.

## Acceptance boundary

The result supports a concrete compiler-remedy decision. It does not identify
an upstream implementation fix or prove that every 6.3.2 representation fails.
The accepted 6.3.2 baseline was not recompiled in this matrix; prior frozen
controls supply that comparison.

No actual supplied runtime owner, generic `SignalAnalyzerPresetHostInstance`,
activation failure, full teardown, copied-owner negative, physical-backing-expiry
negative or constant-marker control was tested on 6.4 here. Native minimal
success does not establish ARMv6 SDK compatibility, Embedded Swift behavior,
linked zero heap, target ABI, resources, or complete repository regressions.
Availability of a target SDK alone would not close those gates.

Therefore this evidence can support an explicit proposal to change the relevant
compiler-baseline authority and then validate the actual join; it cannot be used
to mark the original P08 blocker resolved or silently change pins. SPEC-015's
compiler-checked backing/callback containment contract remains unchanged. Any
approved migration must preserve its positive and negative controls while
obtaining fresh applicable target and component receipts.

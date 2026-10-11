# Independent review: Swift 6.4 actual activation feasibility

Reviewed 2026-10-12 by independent Strong Astra 6 Medium at `ceaed326` plus
`6a0fb348` (complete frozen text snapshots). No compiler invocation or executable
run by this reviewer.

**Pass for the bounded actual activation feasibility pair.** Fresh Swift 6.4
dependencies compile, the unchanged actual positive executes its runtime
opportunity and quiescence, and the unchanged reachable callback escape rejects
for an intended lifetime reason. This supports presenting the concrete baseline
correction for approval; it does not resolve P08 or adopt the compiler.

## Evidence and provenance

Independent checks verified all 352 frozen manifest entries, all 233 current
source hashes, governing receipt hashes, compiler and separate macro-tool hashes,
and 51 generated module/object/executable artifacts. All 27 commands preserve
their historical flags and sources, with only compiler and output/cache/import/
link artifact paths remapped. Each `-I` path and linked GiftUI object resolves in
the fresh `.build/contracts/p08-native-6.4` tree. No Swift 6.3.2 GiftUI module or
object reuse was found.

Calls 1–25 build the declared dependency graph successfully. Call 26 compiles
and executes the frozen actual positive, retaining the successful opportunity,
publication/rendering trace, five fixture lifecycle assertions and coordinator
quiescence. Its execution exit and retained output hashes agree with the receipt.
Call 27 exits 1 with six escape diagnostics; it was not executed.

Some call-27 notes identify lifetime dependence on captures as unsupported. That
alone would warrant caution when classifying a negative. Here a separate
diagnostic explicitly identifies local `activationBacking` and callback return
as the escaping use, while the matching positive with the same definitions and
real backing scopes compiles and executes. The pair therefore establishes the
intended callback boundary rather than an unrelated setup rejection.

The existing macro executable is declared, hashed and used as a separate plugin
process. It is not reused as a linked module/object, but it was not rebuilt.
Consequently this result does not establish a fully migrated macro toolchain.
The original `GIFTUI_DYNAMIC_PROFILE` definition is preserved and the concrete
fixture uses the Static coordinator: this is not a Static-profile build result.

## Limits and approval recommendation

The 27/32 scope is closed with no source repair or command correction. Accepted
pins, maintained drivers/sources and normative contracts remain unchanged.
The generic `SignalAnalyzerPresetHostInstance`, copy and backing-expiry negatives,
constant-marker control, lifecycle-failure matrix, final resource accounting,
native Static route, ARMv6 and nRF52840 remain unverified by this pair.

The proposed compiler-baseline correction at `ba9fc7ce` is suitable for user
presentation after its native-feasibility links are updated to this frozen result
and review. It requests a precise configuration correction, retains historical
authority/evidence, leaves public containment semantics intact, and expressly
requires later native/target and resource validation. The ARMv6 published package
identity and bundled nRF module establish candidate availability, not target
compatibility. No additional architecture gate is inferred solely from the version
change; any later public-semantic change must follow the stated architecture route.

Approval of that proposal would authorize migration and integration work, not
declare the activation blocker resolved or P08 accepted. The existing host's
validation, activation ordering, failure containment and backing-last teardown
must still be checked through maintained integration evidence.

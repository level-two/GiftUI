# P02 implementation progress

Input: `df7f8da6` (P01 passed). Package: P02; owner: SPEC-006 T10.1;
criteria: DV-RD-001 and DV-001/002/011/015–017. P02 is **in progress**.

## Step 1 — declaration ABI and existing macro build route

GiftUI's existing declaration files contain the new fixed-domain ABI in place.
The existing GiftUIMacros target owns the `--lower-source` invocation. There is
no new lowering target, duplicate declaration directory or migration ifdef.
The direction correction was explicitly requested by Eugene on 2026-10-10.
The baseline remains reproducible at P01's recorded revision; downstream
runtime owners have not yet migrated and whole-repository conformance is not
claimed at this checkpoint.

Validated with project-local Apple Swift 6.3.2 (swift-6.3.2-RELEASE):

- `giftui_swiftpm` from `scripts/lib/swiftpm.sh`, compiler selected through
  `GIFTUI_SWIFT_EXECUTABLE`, `build --target GiftUI --configuration debug`,
  scratch `.build/rfc014-p02/tool`, cache `.build/rfc014-p02/tool-cache`:
  GiftUI and GiftUIMacros compile and the macro executable links.
- `GiftUIMacros-tool --lower-source` with
  `Tests/ContractFixtures/SPEC006/RuntimeDerived/Counter.schema.json` and
  `Counter.swift`: emits separate CounterSchema and CounterPresentation.
- Both generated modules compile with `-swift-version 6`,
  `-enable-experimental-feature LifetimeDependence`,
  `-enable-experimental-feature Lifetimes`, `-package-name giftui`,
  `-parse-as-library -emit-module`. Module search roots are the scratch
  `debug/Modules` and `.build/rfc014-p02`; native target defaults to arm64 macOS.
- `scripts/format-swift.sh`, governance validation and `git diff --check`.

The counter input exercises nested owned declarations, inferred Body, typed
read binding, pure bounded text formatting, typed actions, disabled modifiers
and lazy conjunction. Compilation caught and corrected preserved-token trivia,
a builder-domain inference cycle, and Swift's untyped rethrows propagation.
The builder now infers a common domain from its children; lowering explicitly
lifts empty expressions. Typed conditional expressions preserve lazy operands.
No caught error is force-cast and no default/custom Never body is supplied.

This step does not claim native execution, four-profile P02 exit, complete
source-inventory coverage, stable model ownership, State binding, protocol
Canvas, full application migration or resource conformance. Those checks and
package dispositions remain open.

## Step 2 — declaration exit suite

The driver now invokes the existing macro executable, emits separate core,
application schema, Presentation and host modules, and retains unique run
receipts with source/compiler/SwiftSyntax hashes, commands, logs and artifact
sizes/hashes. It is registered as `SPEC-006-rfc-014-<profile>` beside the existing
owner checks. Historical owner checks are preserved; their baseline revision
remains the reproduction point until P10 completes consumer migration.

The native development suite passes 120 assertions: all digits 0–9, builder
arities 0–5, nested/free/member view helpers, nested read facades, indexed read
failure, custom and stateful accessor dispatch, optional/conditional/switch
selection, lazy `&&`/`||`/`??`, left-to-right argument failure and early sibling
termination. Twelve negative controls cover compiler-enforced domain/lifetime/
construction restrictions and original-source-located unsupported effects.
The same production macro passes six existing expansion goldens plus both
UInt16 declaration-limit controls, compiled with SwiftPM's pinned SwiftSyntax
prebuilt and its shim paths. No additional package target is introduced.

`DeclarationHost` is an isolated traversal oracle, not the runtime owner or
Semantic Core implementation. Its Analyzer input uses nested state/capture
syntax and three actual Domain value files; it does not compile the complete
Signal Analyzer. Shared inventory routes remain assigned to P03/P04/P06/P08/P09
for their storage, runtime, drawing, action and application integration portions.
The final four-profile receipt follows the implementation commit. SPEC-006
T10.1 and all complete-application/resource criteria remain open.

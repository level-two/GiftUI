# Proposed RFC-014 compiler-baseline correction

**Status: proposed; explicit maintainer approval pending — 2026-10-12.**
This review packet is non-authoritative. It does not change a lifecycle status,
the supported compiler configuration, or any implementation acceptance result.

## Problem and proposed decision

The P08 activation investigation found a scoped-owner callback escape accepted
by the pinned Swift 6.3.2 configuration. Swift 6.3.3 accepts the same minimized
escape. The official Swift 6.4.0 package, reporting `Apple Swift version 6.4
(swift-6.4-RELEASE)`, rejects the unchanged negative while executing the unchanged
positive. The [independently reviewed comparison](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/compiler-comparison/final-review.md)
records exact sources, commands, compiler/package identities and diagnostics.

**Proposed approval:** replace the RFC-014 migration compiler baseline with this
verified project-local Swift 6.4 toolchain and its matching Swift 6.4.0 ARMv6 SDK,
while preserving all accepted public semantics, lifecycle entry points,
ownership requirements, feature flags, target triples, ABI obligations and
resource ceilings. Authorize the coordinated pin/driver correction, fresh
validation and P08 activation integration under the existing bounded repair and
independent-review process. Approval is not a declaration that these later
checks have passed or that P08 is complete.

The [fresh native activation feasibility result](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/compiler-native-join/result.md)
also passed [independent review](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/compiler-native-join/final-review.md).
All 25 dependency modules rebuilt with Swift 6.4; the unchanged actual activation
positive executed its opportunity and quiescence, and its unchanged callback
negative rejected for the intended lifetime. This preserves the actual Static
coordinator fixture's original Dynamic-profile settings. The separate existing
macro-tool process was recorded rather than rebuilt. This is bounded feasibility
evidence, not generic-host integration, full baseline migration or P08 acceptance.

## Exact replacement configuration

| Component | Proposed identity |
| --- | --- |
| Official host package | `swift-6.4.0-RELEASE-osx.pkg`; SHA256 `8fd03185b98fe27f54a54631c2449decf75d5b466ce8e34abbd414141063c6aa` |
| Compiler executable | `Apple Swift version 6.4 (swift-6.4-RELEASE)`; SHA256 `79ae5c26645489fb783ae980f0f1bdae810f90fb180c9ac39808807b65e9fd69` |
| Raspberry Pi SDK | `swift-6.4.0-RELEASE-raspios-bookworm-armv6-sdk.tar.gz`; published SHA256 `3332907e1fe366a24cdd9b4af566cb4f1a1f39aa8fad785cb328af17c7484848`; download must be verified before use |
| nRF Swift module | Bundled `armv7em-none-none-eabi.swiftmodule`; SHA256 `15912e1951ad3738d0dd98e10c5d08d8a48189ad918e59a7156764578705836b` |
| Existing language/features | Swift language mode 6, `LifetimeDependence`, `Lifetimes`, internal lifetime annotations; Embedded Swift only where already required |
| Existing targets | `arm64-apple-macosx26.0`, `armv6-unknown-linux-gnueabihf`, `armv7em-none-none-eabi`; preserve each route's optimization and ABI flags |

The [setup receipt](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/compiler-comparison/setup-receipt.json)
includes official URLs, trusted package-signature/notarization results and exact
local paths. The [target availability record](../../../Tests/ContractFixtures/SPEC015/Evidence/rfc-014-p08/compiler-comparison/target-availability.md)
separates published/bundled artifacts from target compatibility evidence.
All tools remain under `.toolchains/`; no installer, Xcode selection or global
Swift setting is changed. Zephyr 4.3.0, Zephyr SDK 0.17.4, supported boards,
hard-float conventions and hardware authorization rules remain unchanged.

## Authority reconciliation on approval

This is a configuration correction preserving accepted architecture. RFC-014
and ADR-036 explicitly require a new architectural decision when a compiler
change forces different public semantics; the proposal does not authorize such
a change. If later validation exposes one, stop the affected work and route it
through the RFC/ADR process.

Apply the approved correction coherently:

- Preserve RFC-014 and ADR-036's original Swift 6.3.2 choice as historical
  provenance, and add an explicit dated link recording that the unchanged
  semantics now use the approved Swift 6.4 migration configuration. Do not leave
  the initial pin presented as the current supported migration pin.
- Update SPEC-013's **Compiler, capability and performance contract** and
  SPEC-002's **RFC-014 runtime amendment** to select the exact configuration above.
  Record this as an explicitly approved Specification correction.
- Make the RFC-014 applicability of SPEC-002/003/004 resource configurations
  explicit. Preserve historical baseline rows and receipts; fresh migration
  measurements use the newly approved compiler for both baseline and candidate.
- Update the affected implementation plans, conformance checkpoints, feature
  manifest and shared compiler/target pins together. Keep their implementation
  statuses and unmet acceptance criteria honest.

FEATURE_LIFECYCLE's contract-clarification route requires approval before relying
on the changed Specification. The general request to resolve P08 supplied the
authority for investigation; this packet requests the precise normative pin
replacement. No new host role, runtime fallback, unchecked lifetime extension or
relaxation of SPEC-015's callback-containment clause is proposed.

## Work required after approval

1. Apply the coordinated compiler/SDK pin and driver changes. Verify exact
   identities and fail clearly for missing tools/features. Retain historical
   6.3.2 evidence without reusing its binary artifacts as 6.4 validation.
2. Integrate the verified activation mechanism through the existing concrete
   host wrapper, keeping validation pure and the first coordinator/endpoint
   construction inside activation. Add maintained positive, lifecycle-failure,
   copy, callback, backing-expiry and constant-marker controls.
3. Rebuild and run the applicable native Dynamic/Static regression routes. Build
   ARMv6 and nRF52840 routes with matching tools, verify CPU/VFP attributes,
   ownership diagnostics and the required ABI/value-size/allocation/resource
   evidence. Native execution cannot replace target artifact or resource checks.
4. Obtain independent Strong review of the integrated fix and its exact evidence
   before marking the activation blocker resolved. Full P08 counter, four-route
   application/early-image and package acceptance obligations remain open until
   separately completed under the existing sequence.

## Alternatives and limits

Keeping 6.3.2 or switching only to 6.3.3 does not remedy the tested containment
failure. Changing enum/struct storage, callback markers, extraction style and
receiver annotations did not produce an adoptable 6.3.2 candidate. This does not
prove every possible 6.3.2 representation impossible. Relaxing containment or
substituting runtime checks would violate the accepted requirement and is not
recommended. The 6.4 proposal follows a demonstrated source-preserving remedy;
target artifact availability alone does not prove target compatibility or costs.

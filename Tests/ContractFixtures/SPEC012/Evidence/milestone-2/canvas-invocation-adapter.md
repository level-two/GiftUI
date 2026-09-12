# SPEC-012 Canvas Invocation Adapter Evidence

Plan task: `SPEC-012 T2.1`

The focused dynamic profile fixture expands Canvas through SPEC-006's generic
primitive payload seam and copies the concrete payload into bounded storage
under the existing structural identity. Its drawing-attempt adapter is the
only package client that calls the non-returning Canvas invocation bridge.

The fixture proves that root Canvas expansion emits one semantic event with
zero children and no body evaluation or drawing invocation; invocation later
receives the exact resolved size; release makes the occurrence inaccessible;
multiple occurrences retain traversal order and distinct identities; lookup
is nil outside the half-open range; and staging refusal discards the entire
candidate result.

Reproduce from the repository root:

```text
swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE --filter CanvasInvocationAdapterTests
scripts/contracts/check-spec-012-module-contract.rb
scripts/contracts/check-spec-012-declarations.sh --profile macos-dynamic
scripts/contracts/check-spec-012-declarations.sh --profile macos-static
scripts/contracts/check-spec-012-declarations.sh --profile raspberry-pi-armv6
scripts/contracts/check-spec-012-declarations.sh --profile nrf52840-embedded
```

The module audit admits bridge references only in `GiftUI/Canvas.swift` and the
focused semantic-result adapter. The four package-interface checks require the
exact typed non-returning bridge and reject closure-returning package lookup.
Dynamic profiles retain the private closure; static declaration profiles do
not. Generated static dispatch and production rejection of the declaration-
only fallback remain assigned to T6.

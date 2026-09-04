# SPEC-006 T1.2 Builder and Wrapper Evidence

## Contract surface

`Sources/GiftUI/DeclarativeView.swift` defines the approved bounded
`ViewBuilder` overloads and the seven structural wrapper declarations. Wrapper
construction and stored children or branches remain package implementation
detail; ordinary clients receive wrapper values only through builder lowering.
Every wrapper supplies its framework traversal override, so normal traversal
does not evaluate its recursive `Never` body.

The registered `scripts/contracts/check-spec-006-builder-surface.rb` check
rejects a dynamic-array overload, public wrapper construction or storage, type
erasure, missing wrapper types, missing bounded overloads, and missing wrapper
dispatch.

## External compile corpus

The fixture manifest compiles independent external-client examples for:

- zero through five direct children;
- six children split across a nested bounded group;
- both conditional branches;
- optional content;
- builder properties and builder functions.

It also requires compilation to fail for six direct children and a `for` loop.
The negative fixtures match stable compiler diagnostics and therefore prove
that neither an accidental sixth overload nor `buildArray` is available.

## Profile result

The immutable reports referenced by the four `latest-*` pointers passed on:

- `macos-dynamic`;
- `macos-static`;
- `raspberry-pi-armv6`;
- `nrf52840-embedded`.

These are hardware-free contract results. The report intentionally remains
conformance-incomplete until later SPEC-006 milestones provide the remaining
semantic, resource, and platform evidence.

## Boundary

This task establishes the construction surface and compile behavior required
by T1.2. T1.3 separately owns proof of exact lowering identities, inaccessible
storage, inactive-branch behavior, and allocation/reflection/existential
absence. T1.4 owns the complete underscored payload and traversal protocol
surface; T1.2 introduces only the visitor operations needed by wrapper
self-dispatch.

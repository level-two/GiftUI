# SPEC-005 Exact Declarations and Raw Surface

Plan task: `T1.1`

Date: 2026-09-01

## Implemented surface

`GiftUITextResources` now owns the twenty package-visible declarations named
by SPEC-005: four exact identity families plus the digest, descriptor and
metric values, mapping/raster records, both view protocols, the generic
package, local validation result/error vocabulary, and validator namespace.

Focused tests preserve all digest words, zero and maximum identity raw values,
every initializer field, `UInt8` raster/error raw values, `UInt16` glyph and
realization raw values, equality/hashability, and `Sendable` conformance. Stub
views compile every protocol requirement and construct the exact generic
package.

## Access and admission boundary

The generated public interface contains no text-resource declaration. The
generated package interface contains the exact declaration set and records the
required raw widths, optional-returning accessors, `withPayload` `rethrows`
shape, generic constraints, and borrowing validator argument. No class, actor,
pointer, reference, string, closure, existential, or platform handle is added
to identity storage.

Milestone 1 intentionally admits no package. The validator entry point remains
fail-closed with `.integrityMismatch` until T2.1 replaces that temporary body
with the complete nine-class deterministic predicate pass. Initializers and
accessors are not treated as admission.

This task introduces no canonical-byte algorithm, accessor behavior,
payload-borrow implementation, concrete package, layout/render/backend API, or
connected-hardware evidence.

# SPEC-006 Action and Custom View Surface

Plan task: `T1.1`

Date: 2026-09-04

`GiftUI` now exposes the approved `GiftUIAction` raw-value boundary, the Rank
0 `View` requirement, its ordinary default `_giftUITraverse` witness, and the
recursive `Never: View` conformance. The default witness passes the borrowed
declaration and one nonescaping body accessor to `visitCustomView`.

Focused tests prove the three fixture action cases preserve their exact
`UInt16` codes, an ordinary custom view receives the default witness, its body
accessor runs exactly once when requested, and a `Body == Never` leaf can be
visited without reading `Never.body`.

The four-profile compile registry includes an external custom conformance with
no handwritten witness, a valid finite `UInt16` action domain, and negative
fixtures for a `UInt8` raw value and an associated-value enum. The surface
audit rejects a public numeric domain identifier, handler/model/generation
machinery, runtime-only facilities, and the retired `_visit`/`ViewVisitor`
compatibility API.

Only the one-child builder operation needed to type-check this first public
slice is present. T1.2 owns zero and two-through-five arities plus conditional,
optional, and fixed wrapper declarations; T1.4 owns the remaining sealed
visitor categories.

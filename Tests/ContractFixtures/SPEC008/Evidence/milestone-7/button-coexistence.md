# T7.5 Button Coexistence Audit

The visual Button projection uses the canonical direct render views: a
structural occurrence containing a red foreground scope, blue background, and
two-glyph label. Its executable transcript emits the blue fill before the red
label glyph group, preserving SPEC-008 painter order.

The companion fixture assigns disabled state, hit geometry, action identity,
pointer capture, dispatch, and the runtime-owned hit map exclusively to
SPEC-011 and marks every one excluded from the render projection. The audit
also rejects those facts from semantic render views, normalized operations,
and lowering. It introduces no Button or Interaction implementation.

Reproduce with:

```console
scripts/contracts/check-spec-008-button-coexistence.rb
swift test --filter visualButtonProjectionLowersOnlyLabelStylesAndPainterOrder
```

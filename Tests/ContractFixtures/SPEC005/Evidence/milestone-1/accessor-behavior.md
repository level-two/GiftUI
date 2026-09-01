# T1.3 Total Accessor and Resource-Format Evidence

Task `T1.3` adds bounded default scalar mapping plus reusable package-internal
identity, checked-geometry, record-partition, bitmap, and packaged-outline
seams. Invalid scalars, CR, LF, mismatched resources/instances, and out-of-
range identities produce absence; valid unmapped scalars use only the exact
instance replacement glyph. Mapping stops after at most 256 records.

Focused fixtures cover all Unicode scalar boundaries, all 95 printable ASCII
scalars plus U+00B0, unsupported valid scalars, distinct upper/lowercase
mapping, CR, LF, and CRLF consumption. Metric and raster fixtures reject every
mismatched or out-of-range identity and make record metadata independent of
payload availability.

Geometry fixtures cover exact ink origins, advances, offset overflow, advance
overflow, and rectangle-edge overflow through SPEC-002 checked arithmetic.
Bitmap fixtures prove row-major MSB-first coverage, exact row width, checked
byte count, exact dimensions, zero padding, bounds, and gap-free payload
partitioning. Outline fixtures cover the version-1 big-endian header, all six
commands, exact fixed/variable arities, signed-coordinate bytes, the quadratic
implied-point sentinel, close/end termination, structural truncation, invalid
opcodes, and trailing-byte rejection.

`check-spec-005-accessors.rb` makes these production seams fail-closed in all
four compiler profiles. Evidence is hardware-free and claims no raster output,
deployment, connected execution, or flashing.

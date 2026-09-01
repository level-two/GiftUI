# T1.4 Exact Payload-Borrowing Evidence

Task `T1.4` adds one reusable package-internal payload-slice seam for concrete
raster views. It requires the exact catalogued record and realization, a valid
glyph range, an available exact payload, an exact declared whole-payload byte
count, and a checked record range before rebasing the borrowed buffer. It
materializes no payload copy, mutable pointer, collection, or retained source.

Focused fixtures prove that a valid nonempty record invokes the body exactly
once with the exact slice, and a valid zero-byte record invokes it exactly once
with an empty buffer. Changed records, invalid glyphs or realizations,
unavailable payloads, whole-payload count mismatches, and range failures return
`nil` without invoking the body. A throwing body produces a sentinel unchanged
after exactly one invocation; a separately compiled nonthrowing call proves
availability and validation paths cannot manufacture that error.

Lifetime instrumentation owns mutable test storage only outside the production
seam. It marks the source active during the callback, overwrites every source
byte immediately on return, revokes subsequent availability, retains only the
observed numeric address rather than a pointer, and proves a second borrow is
rejected. `check-spec-005-payload-borrow.rb` fail-closes on loss of the exact
guards, checked range, rebased borrow, body-only `rethrows`, or introduction of
allocation/mutable storage in the production helper.

# T2.3 Common Catalogue and Payload-Subset Admission Evidence

Task `T2.3` adds a certified synthetic catalogue with one instance, one glyph,
one mapping, and both bitmap and packaged-outline realizations. The complete
composition validates once with each realization required. Bitmap-only and
outline-only compositions retain byte-for-byte equal descriptors, record
tables, payload digests, canonical byte count, and `FontResourceID`; only the
linked payload optionals and availability results differ.

Each payload-subset composition validates when its linked realization is
required and returns exactly `.incompatibleViews` when the omitted realization
is required. A composition that claims availability while refusing a complete
record borrow is also incompatible, even when another realization is selected.
Malformed record metadata in an omitted unselected realization still returns
`.malformedRasterRecord`, proving the common catalogue is fully checked.
Coordinate-only corruption in an available unselected outline remains
structurally valid but returns `.integrityMismatch`, proving every linked
payload is hashed regardless of selection.

`check-spec-005-common-catalogue.rb` fail-closes on loss of any composition or
negative control. All evidence is host or cross-built only; no raster output,
simulator, remote service, deployment, board execution, or flashing is claimed.

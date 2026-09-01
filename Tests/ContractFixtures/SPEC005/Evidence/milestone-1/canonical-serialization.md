# T1.2 Canonical Serialization and Digest Evidence

Task `T1.2` implements a single streaming schema-version-1 byte seam and a
fixed-state SHA-256 implementation in `GiftUITextResources`. The production
path materializes no manifest collection, parses no runtime file, imports no
crypto or platform framework, and does not serialize struct memory. Signed
geometry is reinterpreted as its `Int32` bit pattern; every multi-byte field
and digest word is emitted most-significant byte first.

Focused tests cover the official SHA-256 empty, `abc`, and multi-block vectors;
an exact 135-byte SPEC-005 manifest vector; digest word order; a byte from
every schema region; direct payload-digest participation; and exclusion of
filenames, timestamps, locale, table addresses, display names, and raw payload
bytes. A missing declared table entry produces no certified digest.

`check-spec-005-canonical.rb` fail-closes on loss of the literal schema prefix,
fixed 64-round SHA-256 state, signed-bit-pattern encoding, or introduction of
dynamic byte arrays, Foundation/Data, platform crypto, host-endian helpers, or
struct-memory serialization. The four standalone contract profiles compile
the same source with their pinned compilers; their reports remain explicitly
hardware-free and make no deployment, flashing, simulator, or connected-board
claim.

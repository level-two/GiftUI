# T2.2 Isolated and Pairwise Validation Corpus Evidence

Task `T2.2` adds a fault-composable synthetic validation package and registers
45 normalized host cases: one isolated fixture for each raw error value and
all 36 unordered pairs. Every pair executes twice with reversed fault input
order and returns the lower raw value. The corpus checker rejects a missing,
duplicate, malformed, or incorrectly ordered pair.

Focused subfixtures independently cover both schema views; every count and
byte ceiling; zero, missing, extra, and mismatched enumeration; instance,
replacement, realization, record, resource, and invalid-availability
identities; descriptor and selected-realization incompatibility; unavailable
and unborrowable payloads; every line-metric sign/sum rule; advance and ink-
edge overflow; invalid, surrogate, CR/LF, nonascending, duplicate, and invalid-
glyph mappings; record gaps/ranges/order/dimensions/row widths/byte counts;
bitmap padding; outline header/opcode/arity/sentinel/termination errors; and
payload, manifest-count, and resource digests.

A separately certified zero-byte bitmap payload with a single zero-byte glyph
record validates as an empty partition. Zero required counts and a zero
manifest count remain `.invalidCount`. Rejected inputs remain immutable and
the validator returns only its local enum, so no repaired, substituted,
partially selected, or diagnostic-bearing package can escape.

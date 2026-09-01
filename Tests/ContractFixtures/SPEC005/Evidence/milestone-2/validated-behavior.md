# T2.4 Validated Behavior Evidence

Task `T2.4` adds a package that first passes the complete validator and then
exercises the consumer-visible resource behavior. Its golden line metrics are
ascent 12, descent 3, and line gap 2, yielding a checked baseline step of 17.
From the explicit baseline point `(20, 30)`, the golden glyph has ink origin
`(18, 21)`, ink size `(7, 9)`, advanced origin `(31, 30)`, and next baseline
y-coordinate 47.

The behavior fixture proves exact and replacement mappings, explicit LF and CR
classification, and invalid-scalar rejection. A gated view validates while
complete and then refuses an exact mapping lookup. The test-only validated-view
adapter classifies that refusal separately from expected line-break `nil` and
prevalidated invalid input, preserving the detecting-owner distinction without
introducing production layout or rendering policy.

Checked negative fixtures cover line-metric accumulation, next-baseline
accumulation, x and y offsets, right and bottom ink edges, and advance
accumulation. Every overflow returns `nil`; no partial point or rectangle is
accepted. `check-spec-005-validated-behavior.rb` fail-closes on loss of these
goldens and distinctions. This is contract-local host/cross-build evidence and
makes no backend, simulator, deployment, board, or flashing claim.

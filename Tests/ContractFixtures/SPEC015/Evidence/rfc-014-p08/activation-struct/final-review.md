# Independent review: invariant struct primitive

Reviewed 2026-10-12 by independent Strong Astra 6 Medium at `81c9a13b`.
No compiler invocation or executable run. All 25 frozen manifest entries match
their SHA256 values.

**Reject progression to actual host integration for this candidate.** The minimal
positive compiles, links and executes, but the reachable callback-escape negative
also compiles and links. The latter executable was never run. The mandatory
primitive stop at 2/8 is correctly preserved; no actual-owner trials occurred.

The struct has an immutable private `Span<UInt8>` field and Boolean state. It
does not consume/reconstruct the complete receiver or use an inert/active enum.
Its acceptance therefore shows that enum reconstruction is not necessary for
the observed negative outcome. It does not establish that the struct field is
the cause, or that all compiler-checked wrappers are impossible.

## Remaining extraction mismatch

The previously rejected direct Span control reads `escaped!`. This negative
instead calls `escaped.take()!`, then borrows the extracted owner to read its
span. Noncopyable wrapping and optional extraction both differ.

The installed Swift 6.3.2 `arm64-apple-macos.swiftinterface:16321–16328` defines
`Optional.take` for `~Copyable, ~Escapable` wrapped values. It declares result
dependence `@lifetime(copy self)`, consumes `self` into a result, resets `self`
to `nil`, and returns the result. Source inspection alone cannot determine
whether that path accounts for the accepted escape.

The narrow next discrimination is two controls on the unchanged helper and seed:

1. Direct Span capture followed by `escaped.take()!` and the same out-of-line read.
2. This same struct capture observed through a borrowing/nonconsuming optional
   switch, without `take` or consuming extraction.

These are recommendations for a separately bounded assignment, not experiments
performed or authorized by this review. If the first accepts and second rejects,
the extraction path becomes the isolated issue. A borrowing negative would then
be useful diagnosis, not sufficient replacement evidence: an accepted extraction
escape must not be hidden by changing the test. The full compiler-checked host
containment contract remains in force under the pinned compiler.

No maintained source, public role, activation ordering or toolchain feature
changed. This is primitive evidence only; it establishes no actual join, generic
host conformance, target result, resource result or P08 completion.

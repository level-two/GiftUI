# Independent review: matched callback boundary

Reviewed 2026-10-12 by independent Strong Astra 6 Medium at `0fc6e14d`.
Read-only review of frozen sources and receipts; no compiler call or executable
run. All 85 manifest entries match their SHA256 values.

**Reject adoption.** Run 1 executes the actual positive join under the matched
out-of-line callback and externally derived marker. Run 2 still compiles and
links the reachable actual callback escape. Run 3 also compiles and links the
minimal enum-only escape. Accepted negative executables were not executed.
The 3/6 bench is closed, and the unused calls are not continuation authority.

The previous marker/callback difference is now narrowed: the actual negative
uses the direct primitive's callback helper and runtime seed. The minimal
`EnumComparison.swift` contains no GiftUI imports and retains Span in both enum
cases, with copied-lifetime initialization and receiver-dependence annotations.
It performs the inert-to-active transition and reads the escaped owner after
callback return through the reachable main. The accepted negative therefore
reproduces the failed containment without the real runtime module graph.

This does not establish a general enum language/compiler defect or impossibility.
It isolates an exact tested shape: noncopyable/nonescapable enum payloads,
consume-self reconstruction, optional capture, and post-callback read. No blanket
conclusion about other wrappers or mutation paths follows.

The scoped backing requirement remains unchanged: semantic callback retirement
cannot be extended by keeping the enclosing profile allocation alive. Actual
first coordinator/endpoint construction remains inside activation. No maintained
module, toolchain or public host-role changes occurred. Positive execution is
mechanism evidence, not full host validation, generic host conformance, complete
failure/teardown coverage, resource accounting or P08 acceptance.

The next discriminating implementation hypothesis is a private immutable Span
field in a struct, outside its mutable inert/active state enum. Test the minimal
struct positive and reachable escape against the identical helper first. Only
after intended rejection should the real state join adopt that shape, preserving
the span without consuming/reconstructing the complete struct during transitions.
This can remain the existing single host role with private representation changes;
it creates no contract authority and is not yet verified.

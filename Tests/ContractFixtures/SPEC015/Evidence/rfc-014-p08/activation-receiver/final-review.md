# Independent review: receiver annotation comparison

Reviewed 2026-10-12 by independent Strong Astra 6 Medium at `ab2a14e1`.
No compiler call or executable run. All 25 frozen manifest entries match SHA256.
The owner differs from the extraction candidate by exactly the removed
`@_lifetime(self: copy self)` line; the negative source is byte-identical.

**Receiver annotation removal does not repair containment.** The positive
compiles, links and executes; the reachable callback-escape negative still
compiles and links and was never run. The assignment correctly closes at 2/3
and stops representation trials for upstream assessment.

The smallest retained reproducer has a noncopyable/nonescapable struct holding
an immutable private Span, a Boolean-only mutating activation method, checked
copied-lifetime initialization, and a borrowing read. The callback uses an
out-of-line boundary and externally derived marker; observation uses the prior
plain optional switch. No actual runtime modules are needed to reproduce the
accepted escape. The comparison rules out this explicit receiver annotation as
a necessary cause of acceptance in the tested source; it does not establish a
compiler root cause or universal pinned-compiler impossibility.

No actual-owner candidate is verified for adoption. The experimental positive
join exists, but the required lifetime boundary remains unproved. Changing a
negative oracle, relying solely on private lexical discipline, or silently
changing the supported compiler would not meet the current contract.

An explicitly bounded, evidence-only comparison of frozen controls on official
project-local candidate compilers can inform a concrete remedy decision without
changing authority. Any passing result must remain separate from the accepted
6.3.2 baseline until normal approval and actual integration/regression evidence.
This review neither adopts a candidate nor advances P08, SPEC-015, resource or
hardware status.

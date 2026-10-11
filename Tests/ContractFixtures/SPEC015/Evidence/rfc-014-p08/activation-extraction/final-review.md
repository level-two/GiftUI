# Independent review: optional extraction comparison

Reviewed 2026-10-12 by independent Strong Astra 6 Medium at `c6b4c55f`.
No compiler calls or executable runs. All 20 frozen manifest entries match
their SHA256 values.

**The extraction hypothesis is not supported. No candidate becomes adoptable.**
Direct Span capture still rejects for the intended marker/callback lifetime
reason when observed through `Optional.take`. The unchanged minimal owner
still compiles and links when observed through the requested plain optional
switch, without `take` or an explicit consuming extraction. Its executable was
not run. The assignment closes at 2/4 as recorded.

The wrapper's creation-side `escaped = consume owner` remains unchanged. The
plain switch's source calls a borrowing `read`; this review does not claim to
have inspected its lowered ownership. The reliable result is narrower:
removing the `Optional.take` call does not restore rejection, and adding `take`
does not erase rejection for direct Span. Optional extraction alone is therefore
not a sufficient explanation of this control pair.

The original construction/activation positive is solved in experimental source:
prior recorded candidates compile and execute actual opportunities/quiescence.
Production adoption remains blocked by missing wrapped-owner callback containment,
not by a demonstrated impossibility of compiling the positive. Current evidence
supports reporting the exact minimized wrapped-owner acceptance path upstream;
it does not identify its compiler phase or prove all pinned-compiler shapes fail.

One remaining source difference is the minimal wrapper's explicit receiver
result-dependence annotation on `activate`, although that method only writes a
Boolean and never replaces its Span field. Removing only this unnecessary
annotation is a justified separately bounded positive/negative control before
concluding representation trials. It is not performed or authorized by this
review, and must preserve all other control details.

If that control also accepts the escape, the next useful artifact is a concrete
compiler-remedy decision packet with the minimal reproducers and retained
contract. SPEC-015 requires compiler-checked dependence and forbids callback
escape; ADR-036 pins Swift 6.3.2 and forbids unchecked fallback. Private lexical
discipline alone does not meet that compiler guarantee. Compiler baseline or
supported-contract changes require their normal explicit approval; a different
negative must not be substituted as a purported fix.

No maintained source, API, toolchain setting, actual host integration, target
result or P08 completion is established by this diagnostic pair.

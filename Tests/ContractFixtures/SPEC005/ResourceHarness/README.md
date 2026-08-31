# SPEC-005 Matched Resource Harness

`Baseline` and `Candidate` are checked-in matched source roots for later
resource evidence. Both variants must use identical entry signatures,
normalized corpus inputs, observable fixed-width sinks, compiler mode, linker
support, and runtime/test support. Baseline must not import or link production
text-resource modules; Candidate exercises only the SPEC-005-owned path under
measurement.

Generated sources, build products, link maps, and reports belong under the
deterministic generated and report roots documented by the parent fixture
README. They never belong in these checked-in roots.

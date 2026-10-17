# Witness annotation fixture-only continuation — PASS

This continuation runs exactly the five invocations authorized by
p08-witness-annotation-compatibility-fixture-review.md, after verifying all
81 frozen hashes from the candidate1 freeze. Three public ordinary fixtures
replace only CounterReadDomain with public _GiftUIReadDomain; the explicit
D.Type scope twin is byte-identical. Compiler/module/plugin/provider inputs
and flags retain their frozen values. Only fixture path and module-cache path
were remapped to the fresh continuation output.

All five stages passed. The three corrected public fixtures and same-package
scope twin compile successfully. The outside-package twin fails with exactly
'_GiftUIFrameRead<D>' initializer is inaccessible due to 'package' protection level;
all diagnostics were inspected. No further diagnostic occurred. No codegen or
runtime stage ran. Candidate1/1 and the original 18-attempt STOP receipt remain
unchanged; this result establishes fixture validity only and does not accept
the source candidate or close P08/R07/T8.1/conformance.

Raw compiler logs, exact argv, frozen input hashes and corrected fixture copies
are included in this evidence directory.

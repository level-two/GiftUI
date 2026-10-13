# Independent failed-capture and P08 boundary review — 2026-10-13

Reviewed cleanff2d5d3a, sequential Sol6.1 High / Strong. **Accept the recorded
finite diagnostic failure; no lowering/design conclusion or further compiler/
source allowance follows. R07/P08 remain incomplete.** No compiler, link,
test, source repair, diagnostic variant or hardware action ran in this review.

## Provenance and result

Independently compared the148-element argument arrays: the only differences
are index7 (`-c`→`-emit-ir`),105 (isolated output map) and108 (isolated module
output). Other argument bytes match. The39-source map redirects outputs rather
than replacing source inputs. The receipt records364 prior firmware object/
archive identities checked before capture and482 frozen files checked afterward
with zero mismatches. This review inspected those receipts; it did not rerun
the compiler or expand the input audit.

The actual recorder reports one compiler invocation, exit-5. `capture.log`
is zero bytes. The output manifest contains only the precreated output-map
input, with no emitted IR/module artifact. Recorder tool walltime includes
hash/receipt work and is not a compiler-only measurement. These facts establish
a failed capture, not its compiler/driver/host/output-mode cause or an upstream
bug. No alternative output-map key, flag, optimization or retry is justified
by absent diagnostics.

The last validated source remains63e717d1: nativeStatic1,349,555 and
nativeDynamic1,349,501 assertions/zero failures; Pi28/28 and nRF26/26 are
compile-only routes. Its supported image passes link/ABI/VFP/GOT checks with
RAM152320, flash299332 and configured heap0, retaining the documented Swift
allocation-thunk/refusal-stub qualification. Actual selected construction
frame58648 exceeds mainstack27648 by31000 before overlap. No current-source
Pi linked-image or target execution claim. Capture failure neither invalidates
these passing results nor narrows the proven stack failure.

The prior7284/7807/8155-byte linked transfers remain machine-level observations.
Without emitted lowering information this packet cannot assign source-variable
allocas/lifetimes, distinguish avoidable construction intermediates from
necessary payload/scratch, or select a concrete source correction. A consuming
switch, additional helper or raw in-place scoped host is not supported merely
because IR capture failed.

## Package guard and smallest remaining options

IR capture1/1 is consumed and stays closed. The mapped phase correction/image
and every historical allowance also stay closed. This diagnostic failure is
not a source repair; it does not establish two consecutive unproductive repairs
of the same blocker. Prior image/frame/helper narrowing remains productive.
Preserve the exact package rule—two consecutive repairs with no passing check
or narrowed cause—without declaring it exhausted or resetting it. No renewed
compiler/source experiment is selected here.

The smallest remaining **in-scope** work is design only: produce one explicit
construction-flow proposal for `CounterHostSupplied`→`CounterHostOwner`→the
existing optional preset factory→mutable host. It must name exact source
statements/types, consumed/borrowed ownership at each step, required retained
state versus proposed removable intermediary, and the unchanged factory
validation/Static escape-provenance oracle. It must explain why no raw storage
erases a scoped lifetime and give exact files and finite success/failure checks.
Use the existing source and linked-transfer table; mark compiler storage and
nested-fit claims unproved. Independent review may reject that design before
any implementation. This bounded design is permitted by the original P08
authorization; it requires no new human contract approval and grants no new
capture/build allowance. This review does not supply or approve that design.

If no such ownership-preserving proposal can be supported, record that exact
evidence gap and leave P08 stopped. A broader compiler/output-mode/crash
investigation is a different work commitment: present its specific question,
cost bound and expected evidence to the maintainer before adding it to this
package. Do not label it an upstream-bug fix or automatically create a new
Spike, package, toolchain comparison or diagnostic budget. Likewise any actual
stack/heap/RAM/workload/ownership/public-contract change must present its real
trade-off through the existing lifecycle. None is established or approved by
this empty capture result.

This is the package boundary: passing routes/link and preserved local fixes;
failed actual Embedded gross stack; no supported next implementation; complete
nRF safety/resource acceptance and independent P08 exit still missing.
Main27648/heap0/RAM196608/flash1048576 unchanged. SPEC-015 implementing/plan
active, T8.1/HC-RD-003 open. No P09–P12 or hardware. Stop this diagnostic and
implementation continuation after committing this disposition.

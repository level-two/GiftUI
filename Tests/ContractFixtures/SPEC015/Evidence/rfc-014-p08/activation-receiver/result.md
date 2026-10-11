# Receiver-dependence comparison — complete, 2026-10-12

**Removing the explicit receiver-dependence annotation does not restore callback
escape rejection. The final primitive pair is complete at2/3 calls; representation
trials stop here for upstream review.** Strong Astra6 Medium, sequential, under
[scope](scope.md), committed as `a2d4284e` before either compiler invocation.

Run1 compiles, links and executes the matching positive. Run2 compiles and links
the reachable switch-observation negative; that executable was **never run**.
No syntax or setup corrections were needed.

The sole implementation delta from the frozen extraction comparison is removal
of `@_lifetime(self: copy self)` from MinimalSpanOwner.activate. The method still
only sets its Boolean flag. Copied-span initializer, private invariant Span field,
read method, helper, external runtime seed and negative source remain unchanged.
The helper and switch negative are byte-identical to their prior frozen sources;
the owner differs by exactly that one removed annotation line. Thus the explicit
receiver-dependence update is not necessary for this accepted escape.

This does not establish a compiler root cause or prove every possible lawful
host implementation impossible. Together with the retained direct-span rejection,
it supplies a small reproducible accepted wrapped-owner escape for upstream
assessment. It does not justify weakening callback lifetime, replacing the
required oracle, changing compiler flags, or adopting any tested owner.

[execution-1](execution-1/result.json) contains the positive's complete output and
binary hash; it ran once. Each compiler run retains command, source snapshots,
complete diagnostics and compiler/input hashes. The pinned compiler and schema
inputs/artifacts passed identity checks before both calls. [ledger.json](ledger.json)
closes the assignment; the unused third numerical call is not continuation
authority. [manifest.json](manifest.json) covers this finite result.

No actual-host integration, maintained source, approved contract, compiler,
resource, lifecycle, platform or hardware change occurred. Independent Strong
review and the upstream blocker packet are next; no further representation
trial is authorized by this scope.

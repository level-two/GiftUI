# P07 focused workaround bench — 2026-10-11

## Authorization and boundary

Eugene explicitly instructed: “Please add this as a task to the next iteration.
And please proceed with your options 1 and 2 - in a focused test bench try to
find workaround.” The preceding options were (1) localize the exact compiler
failure and seek a contract-preserving workaround, then (2) test the already
passing consuming-transfer arrangement, auditing while owned or explicitly
returning ownership after quiescence within the enclosing lifetime.

This authorizes those focused experiments on pinned Swift 6.3.2. It does not
approve a compiler upgrade, contract/scope change, P08, or adoption of unproven
bench code. SPEC-013 remains implementing, P07 incomplete. The original stop
and exhausted 2/2 allowance remain immutable historical evidence. This explicit
maintainer decision grants only the additional bounded bench below.

## Sequence and bounds

- Start from validated c234058e and the preserved attempted-source.patch;
  keep maintained production/fixture sources unchanged. Put reproducible bench
  sources and scripts here; generated copies/builds go under .build/.
- Reproduce the exact failure first. Option 1 may use at most twelve diagnostic
  compile variants to reduce/localize it. Count variants and record changes,
  compiler commands, exit codes and diagnostics. Reductions are not passing
  production implementations and cannot silently relax the acceptance surface.
- Then allow at most two workaround candidates total, sequentially: one focused
  repair of the localized shape, and one consuming-ownership alternative.
  Stop after two consecutive unproductive repairs with no passing check or
  narrower cause. No new context, factoring or compiler resets this bound.
  If no defensible option-1 repair emerges, use fewer candidates.
- Preserve lifetime dependence, single ownership, real backing identity and
  exact cleanup. Positive controls must be accompanied by unsafe escape/use
  rejection checks. Show quiescence and audit access on the same backing where
  the bench claims them. Do not manufacture a 26-field production audit.
- Finish with a committed result and a concrete recommendation at this bench
  boundary. A small passing probe is evidence for a possible repair, not P07
  completion. No further implementation is included in this continuation.

## Authority and evidence

This is focused debugging for the existing P07 obligation, not a new package
or independent Spike. Governing ADR-035/036/037 and the approved SPEC-009/013
amendments are unchanged. ITERATION-003's analyzer/counter runtime and four-route
obligations remain; the closed MVP defines regression behavior. Refer to the
[shared sequence](../../../../../../docs/iterations/iteration-003-review/rfc-014-implementation-plan.md)
and [historical stop](../audited-construction-stop/stop.md).

Compiler-upgrade assessment is separately scheduled in ITERATION-004 I4-05 /
I4-AC-006 ([FW-036](../../../../../../docs/future-work/fw-036-swift-compiler-upgrade-assessment.md)).

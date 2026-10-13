# SPIKE-075 continuation exit review — 2026-10-13

**Stopped / inconclusive; candidate not falsified.** Sequential Strong review
used Sol 6.1 High. It inspected the continuation already committed as `1dbe456b`
and saved run `743e8cf8`; no compiler calls were repeated during this review.
The maintainer's “Yes, sure, please go ahead” authorizes the previously proposed
one-helper correction and bounded continuation, not further repairs or RFC
approval. The original run and its report remain unchanged.

## Observations

| Check | Saved result | Disposition |
| --- | --- | --- |
| Corrected native copy negative | Exit 1, only Copyable requirements for the three scoped bank types | PASS for the intended isolated copying rejection |
| Native Escape0 | Exit 0, empty diagnostics, object emitted | Intended negative accepted; runner correctly stopped immediately |
| Native Escape1–4 and all other profiles | Not run | No new evidence |

The [receipt](evidence/run-2/receipt.json) records two compiler experiments and
one identity query in 0.5166 seconds. Cumulative counts are five experiments,
two identity queries and one authorized helper correction, with zero further
repairs. Native module/positive evidence is reused from the verified original
run. The continuation did not rebuild them or query the Embedded compiler.

Review verified all 38 archived file hashes, 28 source snapshots, six reused
artifacts including all four native module companions, and the emitted
`escape-0.o`. No mismatch was found. All ten Swift inputs match the original
snapshots except the exact helper correction. Saved SDK hashes match run-1;
the review did not independently rehash SDK trees.

## Why this is not a demonstrated unsafe escape

Escape0 creates a trivial `InlineArray<1, UInt64>` inside an inner `do` block,
then uses the dependent wrapped state later in the same enclosing function.
Ending lexical visibility does not establish that physical backing has been
destroyed or cannot remain alive through the last dependent use. No saved
destruction/access-boundary evidence or executed observation establishes that
the read occurs after the owner's actual lifetime ends.

Therefore acceptance is not evidence sufficient to claim a compiler bug, lost
five-bank dependence, an unsafe read or a falsified RFC architecture. The
fixture's expectation was stronger than its demonstrated lifetime boundary.
Both prior preflight and this result remain recorded; the negative is not
retrospectively converted into a successful lifetime-safety check.

## Proposed next minimum scope — pending disposition

Prepare one positive/negative pair using a **function-return boundary** instead
of a lexical block. The positive helper returns the same wrapped state borrowed
from five caller-supplied spans, with all five declared lifetime inputs. The
negative helper declares dependence on an incoming anchor span but constructs
one bank from its own local InlineArray, then attempts to return the wrapped
state; the other four banks use the live anchor. This isolates the local-owner
return question without changing the RFC declarations or physical architecture.

Review that pair's semantics before compiling. Proposed bounds: one new control
pair, at most two native object compilations plus one compiler identity query,
five minutes, no repairs, no target matrix or production changes. Reuse only
hash-verified original module/compiler inputs and stop at the first unexpected
result. Preserve cumulative counts. This is a proposal, not a new allowance or
an automatic use of the continuation's unspent calls.

## Package boundary

The approved continuation has stopped and is closed. Further fixture changes or
calls require the next bounded disposition. Historical production repair/image
budgets and the two-consecutive-unproductive-repairs rule remain unchanged.
Full carrier/session/retirement feasibility and ownership/cleanup planning are
still open. RFC-015 stays draft; no downstream ADR or Specification is approved.

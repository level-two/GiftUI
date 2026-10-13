# SPIKE-075 package exit — 2026-10-13

**Stopped / inconclusive; candidate not falsified.** Strong exit review used
Sol 6.1 High, sequentially after the run. No review invocation compiled or
changed the fixture. Scope is `722f5862`, reviewed fixture is `861f012b`, and
initial raw evidence was committed as `452d243a`.

## Observed result

Run `20261013T155029Z-b1c24da8` attempted three compiler experiments and one
compiler identity query. The recorded compiler window was 0.9404 seconds.

| Check | Result | What it establishes |
| --- | --- | --- |
| macOS Dynamic shadow module/object | PASS | Exact RFC protocol/state declarations and conditional conformances are expressible in this shadow composition |
| macOS Dynamic positive client/object | PASS | Owned state copy/return/storage and scoped consumption through the wrapper/Optional compile across the module boundary |
| macOS Dynamic copy negative | STOP, compiler exit 1 | Helper confounds Copyable with implicit Escapable; the strict diagnostic matcher correctly refuses acceptance |
| Five individual-bank escape negatives | Not run | No evidence yet that every input constrains the returned state |
| macOS Static, ARMv6 Dynamic, Embedded Static | Not run | Compiler path selection only; no target acceptance, Embedded identity query or runtime/resource evidence |

The copy diagnostics report three Escapable and three Copyable requirements at
`requireCopy(wrapped)`. `requireCopy<T: Copyable>` implicitly requires Escapable,
so this is a fixture isolation defect, not rejection of a selected RFC
declaration. Preflight missed that implicit requirement. The original preflight
and failed run remain preserved; the copy check is not retrospectively marked
passed and its diagnostics must not be hidden by widening the matcher.

All attempted subprocess stdout/stderr, including target path-selection setup,
are preserved in [run-1](evidence/run-1/receipt.json) with
[hashes](evidence/run-1/SHA256.json). Review found no receipt/source hash mismatch.
The original build directory retains emitted module/object files and source
snapshots; immutable fixture commit `861f012b` and receipt hashes preserve the
reproduction inputs. [Emitted artifact fingerprints](evidence/run-1/emitted-artifacts.json)
were captured at package exit, before any repair, to support verified reuse of
the unchanged native module. This is compile-only evidence, with no linked or executed
artifact.

## Proposed minimum continuation — not authorized by this package

Change only the negative helper to:

```swift
func requireCopy<T: Copyable & ~Escapable>(
    _ value: borrowing T
) -> UInt64 { 1 }
```

This is an untested harness correction; it leaves RFC declarations and the
strict diagnostic matcher unchanged. No correction has been applied and no
compiler retry has occurred.

A concrete bounded continuation would permit **one fixture-only correction**,
then at most **30 further compiler experiments**: the corrected native copy
test and five native escape tests against the unchanged, hash-verified emitted
module, followed only on success by the eight original checks on each remaining
profile. Allow at most two identity queries, a 20-minute window, sequential
execution and no further repair. Preserve the first run: combined experiment
count would be at most 33, including its failed copy test, not a reset to zero.
If the existing emitted module cannot be verified, stop rather than rebuild
outside that continuation bound. This proposal needs maintainer disposition
because the current package explicitly has zero repair rounds.

## Boundary

The package has ended at its first unexpected result. No production repair,
layout/image allowance, historical stop count, compiler baseline, RFC contract
or lifecycle approval changed. The two-consecutive-unproductive-repair rule is
preserved; this package performed zero repairs. Do not turn unused invocations
into an automatic continuation. Full carrier/session/retirement feasibility and
the ownership/cleanup plan remain distinct from this state gate; production
migration and linked resource acceptance remain downstream work.

## Repository validation

Governance validation passed (196 authority nodes, 1993 edges); all 20 archived
evidence-file hashes and `git diff --check` passed. No maintained Swift source
changed. Disposable experiment sources are outside the maintained formatter and
repository test gate; no additional compiler or production tests were run.

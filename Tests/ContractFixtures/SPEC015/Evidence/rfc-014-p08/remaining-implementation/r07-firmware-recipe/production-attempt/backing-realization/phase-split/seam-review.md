# Independent phase-split seam review — 2026-10-13

Reviewed clean3e4f3f52, sequential Sol6.1 High / Strong. **The proposed
Static-negative seam adaptation preserves the original criterion and is
required test maintenance within P08.** Amend678e5880's allowed implementation
files to exactly `CounterHostProbe.swift` and
`scripts/contracts/check-spec-015-counter.py`. No contract/user approval gate.
No source implementation, compiler, test, link or variant ran in this review.

The finding is correct: moving lifecycle code removes the old indented text
range, and placing the injection inside the new helper would change where
`escaped` lives. Neither a fake anchor nor a weaker oracle is acceptable.

## Exact checker adjustment accompanying extraction

Place both private phase helpers before `package func p08CounterHost(` so
the existing Static-negative source prefix includes their definitions. Keep
the678e5880 phase/argument map and the same scoped host factory. Use this
single-line call as the real return in its original control-pointer closure:

```swift
return counterRunHostLifecycle(host: &host, control: pointer, report: assembly.report, failAfterRuntime: failAfterRuntime, joinChecks: joinChecks)
```

The corresponding helper parameter labels must match. The checker matches
the complete indented line, with exactly40leading spaces, rather than a
prefix, helper name, ellipsis or a range through its top-level definition.
Assert its occurrence count equals1 in the generated Static source before
replacement. Replace that one actual call with the existing escape body at
the same indentation:

```swift
_ = host.activate()
escaped = consume host
return 1
```

Keep the generated method rename to `rejectCounterHostEscape`, its outer
optional `escaped` declaration before validation, and its post-scope
`escaped.take()`, `runOpportunity()` and teardown use. Assert exactly one
method-name seam, declaration insertion seam and post-scope return seam as
well; use complete current source lines, not indentation-substring matches.
Keep the existing `ownedChecks = 0` projection needed by the copied prefix.
Fail generation immediately on any absent/ambiguous seam; do not fall back to
old anchors or compile an unmodified positive as a supposed negative.

The host consumed by the injection is the same factory-produced value in
the original activationBacking/control/geometry/Canvas/semantic/model scope.
The lifecycle helper is bypassed only in this generated negative, exactly as
the old entire lifecycle block was replaced. The rejection helper still runs
before the factory. No raw pointer storage or escaped helper return replaces
the scoped host. Top-level private helper definitions remain available in
both the positive source and copied negative source with their file-private
ownership; no exported fixture helper API is needed.

The required Static oracle stays exactly the existing diagnostic tuple:
`lifetime-dependent variable 'escaped' escapes its scope`, `activationBacking`,
`root.withLifetime`, `semantic.withLifetime`, `canvas.withLifetime`,
`withUnsafeMutablePointer`. Keep noncopyable host-copy and Dynamic negative
generation/oracles unchanged, including the existing Embedded Dynamic absence
rule. Do not accept any failure merely because compilation was unsuccessful;
the unchanged expected lifetime/provenance diagnostics must match.

## Unchanged bounded checks and stop

This adds necessary checker maintenance to the same single source-correction
slice; it creates no extra repair or validation allowance. Record the two-file
patch and generator seam counts in the existing receipt. Formatter, one fresh
nativeStatic gate including all original negatives and assertion count, then
required nativeDynamic/Pi/nRF receipt refreshes and one supported nRF image.
Keep exact argv/exits/source identities. Stop on any failure or after the
linked result for separate Strong review; no automatic repair/option sweep.

Actual final helper/construction/caller/corpus/initializer nested frames,
alignment and applicable IRQ overlap must fit27648. Smaller individual frames
alone do not pass. RAM196608, flash1048576, heap0, BSS slots, all logical
instances/IDs, order, checks, corpus, scoped reads and teardown remain unchanged.
Historical closed allowances and package two-consecutive-unproductive rule
remain intact. No budget was consumed by this pre-edit seam finding/review.
Source38ba440d remains the last validated source;72208frame failure persists.
P08/R07/T8.1 open, P09–P12 untouched; no hardware or target execution.

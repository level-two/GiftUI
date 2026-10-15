# Candidate A B01 — corrected pre-execution freeze

**One mechanical review correction; same optimization candidate; screen 0/1.**
[Independent source review](p08-stack-candidate-a-independent-source-review.md)
`e33f57ea` identifies five incorrect transcript receivers. Under Eugene's standing
instruction to correct routine errors without per-barrier approval, the parent
authorized this exact pre-execution correction. It adds no optimization variant,
annotation, function, scope or resource decision. Historical 2/2 remains closed.
The original [source freeze](p08-stack-candidate-a-source-freeze.md), qualification,
manifest/diff and failed review remain immutable.

The **only Swift change** from `e33f57ea`/`3d69aba9` restores
`transcript.pointee.runtime.admission` → `transcript.pointee.admission` at five
sites: four original stale admission submissions and the retained handle
assignment. No current-host handle is substituted. Producer identity and complete
pointer/state/completion zero-effects remain. Current candidate A has **30
legitimate original Control projections** (13 scoped, six wake, eight join/probe,
three corpus); the historical erroneous 35 included these five transcript sites.

[Corrected source-only diff](stack-candidate-a-review-correction/source.diff)
and [manifest](stack-candidate-a-review-correction/manifest.json) pin those five
replacements, five current Swift hashes, unchanged 384/202 labels, five native
controls and 26 reuse labels. Corrected CounterScopedStorage SHA-256:
`c426e971ec50636a7323d7c63661f57608ce7ba07f63777f7dc57b7f7a1b2e8f`.
Manifest SHA-256:
`cc405f6c34ed6f218f27a10321f1b551aebd88cf31441c878877143fe9329528`.

[New qualification](p08-stack-candidate-a-review-correction-applicability.json)
SHA-256 `cda1a6e231fa50509f8d709b10ecd3f8a3c99cbb86e244f3b3d8c717c09af335`
pins the same seven exact component receipts/argv/exclusions with the corrected
source hash. The driver changes only the qualification path; activity and every
current-source/receipt/compiled-input/artifact/compiler/macro guard remain.
No old receipt or compiled counter result is updated/promoted.

Necessary compiler-free verification checks all seven qualifications, static
manifest/label counts, unchanged lifetime/guard/oracle lists and exact five-
replacement-only Swift diff. Formatting is unchanged at those fixture lines;
no additional formatter or test-suite invocation is needed. No compiler,
runtime, build, image or target execution occurs.

Focused independent reassessment precedes the unchanged one screen command in
the original freeze, now using the new qualification. Screen remains 0/1;
202 controls and all other-profile/runtime/exclusivity/image coverage remain
not run. It is partial evidence, not fit. All original acceptance/resource/
IRQ/allocator/Dynamic, later-package and hardware/timing gaps remain.

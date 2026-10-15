# P08 remaining full collections checkpoint

Status: **SO-07 four-profile collection PASS; P08 remains open**.

Final source is `0d3e3c7d`, independently reviewed in `51544daa`.
The [archive manifest](remaining-full-collections/manifest.json) records exact
receipt, wrapper and member identities. The [evidence archive](remaining-full-collections/evidence.tar.xz)
contains 2,897 files, 604,132 bytes, SHA-256
`501e27348c305a78794193df44c9a2a90e6ccd555c24f27c3912f700e741574a`.
Every archived member and current recorded collection input hash was verified.

| Profile | Passed checks | Actual build directory |
| --- | ---: | --- |
| macOS Dynamic | 424 | `.build/contracts/p08-counter-_hfz7w26` |
| macOS Static | 424 | `.build/contracts/p08-counter-apvcuupb` |
| Raspberry Pi ARMv6 | 409 | `.build/raspberry-pi/contracts/p08-counter-x8bt078_` |
| nRF52840 | 227 | `.build/nrf52840/contracts/p08-counter-c5_asovq` |

All four receipts report complete collection and pass, with no failed checks.
Native Dynamic executed 1,736,082 assertions; Static executed 1,736,158,
all passing. Target checks are compilation/object evidence, not hardware execution.
Existing component evidence is reused only through the recorded exact-input
checks and reviewed applicability qualifications from the final source freeze.

The nRF extraction reports cursor 31,993, maximum alignment 8, rounded slot
32,000 and four-slot total 128,000; `executed=false`. This is object layout
proof, not complete firmware resource fit.

During collection, separately authorized documentation changes were committed
as `eeb2dcbf`. Static's 201 receipt inputs were checked unchanged, as were final
collection inputs during archival. The historical source-freeze activity-document
hash is historical; its subsequent status/policy edits are not source changes.

Corrections remain **2/2 consumed**. Next are the two registered hardware-free
SO-08 image builds, full resource/caller reconciliation and independent exit review.
No automatic source correction, additional full suite, hardware action, fit claim,
Specification implemented transition or P08 closure follows from this checkpoint.

# SPIKE-006 generated evidence

- Revision: `d97853c496f9eb4816c978c79483e74ee6642073`
- Swift: `Apple Swift version 6.3.2 (swift-6.3.2-RELEASE)`
- Zephyr: `4.3.0`; SDK: `0.17.4`
- Board: `nrf52840dk/nrf52840`; Swift target: `armv7em-none-none-eabi`
- Compile mode: `-Osize`, Embedded Swift, Cortex-M4F hard-float
- Candidate source SHA-256: `233248c38304e9d5d5a4af584b1836042bc37d4c56bd8fc3148445b325287df4`
- Baseline ELF SHA-256: `d644afe2b1e7bc850e1d8f7666e255654a6349267fe808dda0dd2555aadf0f0e`
- Candidate ELF SHA-256: `bada71fdc8b20c01252e3911d052cfc10de835141cc7b4896d2d325263e30eec`

| Metric | Baseline | SPEC-010 declaration fixture | Delta |
| --- | ---: | ---: | ---: |
| Linked flash bytes | 25780 | 25796 | 16 |
| Linked RAM bytes | 6016 | 6016 | 0 |

The exact SPEC-010 public declaration spellings for `State`,
`_GiftUIObservableChangeSink`, `_GiftUIObservableReference`, and
`_GiftUIObservationAttachment` compile and link in one Embedded Swift image.
The fixture instantiates `@State var model: ObservableModel`, conforms a
bounded typed handle to the consuming-sink protocol, transfers and reports
through the noncopyable sink, and detaches the returned attachment.

The candidate ELF reports ARMv7E-M and VFP register arguments. Both configured
heaps are zero. The candidate retains no allocator entry point and introduces
no linked reflection, Objective-C, task, thread, or allocator symbol relative
to the configuration-equivalent baseline. The fixture was not flashed or run
on connected hardware.

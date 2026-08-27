# SPIKE-008 generated evidence

- Revision: `554af348332c42f3808697402c60a7ba627b8561`
- macOS Swift: `Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)`
- Embedded Swift: `Apple Swift version 6.3.2 (swift-6.3.2-RELEASE)`
- Zephyr: `4.3.0`; SDK: `0.17.4`
- Board: `nrf52840dk/nrf52840`; Swift target: `armv7em-none-none-eabi`
- Candidate source SHA-256: `d7d686392332538c68ab19e92de6d12ed33d73f45de12015fcd2124c71c9a14d`
- Candidate ELF SHA-256: `c8dbbfa789c614908a3fafaaa50ebb205604af4b967c7e1505a23b0c4c40b9bc`

## Result

The corrected SPEC-012 declarations and generated bounded callable compile and
link on macOS and Embedded Swift. The callable exercises concrete typed
`DrawingError` throws and the two-`inout` `withPath` source form, including
stroke-mutate-stroke reuse of one scoped Path. The macOS runtime fixture passes
both normal and throwing `withPath` cleanup paths.

Illegal outer-context access, borrowed-Path consumption, and `withPath` Path
escape fixtures fail compilation on both compilers as intended. The exact
diagnostics are retained beside this summary.

| Metric | Baseline | Declaration fixture | Delta |
| --- | ---: | ---: | ---: |
| Linked flash bytes | 25780 | 26180 | 400 |
| Linked RAM bytes | 6016 | 6016 | 0 |

The candidate ELF reports ARMv7E-M and VFP register arguments. Both configured
heaps are zero. The candidate introduces no linked `any Error`, reflection,
Objective-C, task, thread, exception-runtime, or allocator symbol relative to
the configuration-equivalent baseline. No board was flashed or operated.

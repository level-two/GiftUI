# SPIKE-008 generated evidence

- Revision: `4146f4d83dab602ceea4227f5b265790d69adce1`
- macOS Swift: `Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101)`
- Embedded Swift: `Apple Swift version 6.3.2 (swift-6.3.2-RELEASE)`
- Zephyr: `4.3.0`; SDK: `0.17.4`
- Board: `nrf52840dk/nrf52840`; Swift target: `armv7em-none-none-eabi`
- Candidate source SHA-256: `bac379c534e39aa61c5bdf6c37c31dbac8fefc5b006e485ad5fcde38c1e2be6e`
- Candidate ELF SHA-256: `91f65fac9e2a65a531ee51083e732d8a7c854e20756bf9639ba5c7ad8d9e65b7`

## Result

The individual SPEC-012 declarations, including the generated bounded
callable's exact throwing `inout GraphicsContext` / `Size` signature,
noncopyable values, and borrowed stroke argument, compile and link on macOS
and Embedded Swift when concrete thrown values are disabled. The macOS runtime
fixture passes both normal and throwing `withPath` cleanup paths.

The exact throwing implementation does **not** compile in Embedded Swift.
Every concrete `throw DrawingError...` expression is rejected because the
compiler cannot use the required `any Error` protocol value.

The intended supported composition does **not** compile on either compiler.
Calling `context.stroke(path, ...)` inside `context.withPath { ... }`
overlaps the modifying access held by `withPath`. Moving the stroke outside
the closure is unavailable because `Path` is noncopyable and cannot escape.
The exact diagnostics are retained beside this summary.

Illegal borrowed-Path consumption and `withPath` Path escape fixtures fail
compilation on both compilers as intended.

| Metric | Baseline | Declaration fixture | Delta |
| --- | ---: | ---: | ---: |
| Linked flash bytes | 25780 | 25780 | 0 |
| Linked RAM bytes | 6016 | 6016 | 0 |

The candidate ELF reports ARMv7E-M and VFP register arguments. Both configured
heaps are zero. The candidate introduces no linked reflection, Objective-C,
task, thread, or allocator symbol relative to the configuration-equivalent
baseline. No board was flashed or operated.

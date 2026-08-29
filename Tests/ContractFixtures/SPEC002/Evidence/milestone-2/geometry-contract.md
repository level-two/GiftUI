# SPEC-002 Geometry Contract Evidence

This record covers the atomic `T2.1`–`T2.4` Foundation geometry change.

## Implemented surface

- `GeometryScalar` is the public `Int32` alias.
- `Point`, `Size`, `Rect`, and `ProposedSize` expose only the approved public,
  immutable value surface.
- Negative present dimensions return `nil`; absent proposal dimensions remain
  independently absent.
- `GeometryArithmetic` is package SPI and returns `nil` for addition,
  subtraction, or multiplication overflow.
- `Rect` construction validates both exclusive edges through checked addition;
  successful rectangles expose total edges and half-open containment.
- No old error taxonomy, trapping compatibility helper, downstream module, or
  public raw input family was introduced.

## Reproduced checks

```text
$ scripts/test.sh
pass: governance
pass: driver-registry
pass: root-tests
pass: SPEC-002-macos-dynamic
All macos-dynamic checks passed

$ scripts/contracts/run-spec-002.sh --profile macos-static
SPEC-002 macos-static contract surface passed

$ scripts/contracts/run-spec-002.sh --profile nrf52840-embedded
SPEC-002 nrf52840-embedded contract surface passed
```

The root suite executed 12 tests with zero failures. Its table-driven corpus
covers zero, ordinary values, both scalar limits, symmetric overflow operand
orders, negative dimensions, independent proposal absence, maximum valid
rectangle extents, rejected x/y edges, exact total edges, empty rectangles,
copy/equality behavior, and half-open containment. Host layout assertions pass
the SPEC-002 maxima for every geometry value.

The same public compile fixture passes with Apple Swift 6.3.3 dynamic/static
flags and the project-local Swift 6.3.2 Embedded compiler using
`armv7em-none-none-eabi`, `-Osize`, whole-module optimization, Embedded Swift,
and Cortex-M4F hard-float flags. Raspberry Pi compiler evidence remains the
Milestone 5 cross-profile gate because its ignored local toolchain is absent.
No connected hardware, remote access, deployment, or flash occurred.

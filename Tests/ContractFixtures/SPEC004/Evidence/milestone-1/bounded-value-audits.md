# SPEC-004 Milestone 1 Bounded Value Audits

Plan task: `T1.4`

Date: 2026-08-30

## Source, interface, and binary boundary

`check-spec-004-value-boundary.rb` audits the production source and emitted
public interface for strings, concrete collections, array literals, stored
closures, existentials, reflection, exceptions, registries, reference
storage, unsafe/heap-backed provenance, and concrete platform identities. It
also audits undefined binary symbols for allocation entry points and concrete
String, Array, Dictionary, or Set metadata.

The production option-set validation masks use direct fixed raw values; no
production array literal remains. Standard `OptionSet` binaries still mention
the language's `SetAlgebra`/`ExpressibleByArrayLiteral` protocol requirements,
but the audit observes no concrete Array metadata or allocation entry point.
A checked-in source regression detects every forbidden source category, and a
symbol regression detects malloc, Swift object allocation, String metadata,
and Array metadata.

## Allocation and layout instrumentation

Both optimized macOS profiles warm 100 construction iterations, reset a
malloc/calloc/realloc interposer, then measure 10,000 iterations that construct
the complete typed requirement and contributor family, fill the four
role-addressed slots, record a duplicate, and construct usable workspace
capacities `0...2`. Dynamic and static runs report the same checksum
`3103108848` and `allocation_count=0`.

Both Apple Swift 6.3.3 profiles recorded the same 64-bit layouts:

| Type | Size | Stride | Alignment | Ceiling |
| --- | ---: | ---: | ---: | ---: |
| `RasterPresentationRequirement` | 21 | 24 | 4 | 32 |
| `RasterRealizationContribution` | 24 | 24 | 4 | 40 |
| `RasterBackendContribution` | 48 | 48 | 4 | 88 |
| `SurfaceDisplayContribution` | 20 | 20 | 4 | 40 |
| `RasterPresentationPolicy` | 16 | 16 | 4 | 32 |
| `RasterPresentationContributions` | 93 | 96 | 4 | 192 |
| `RasterPresentationResolverWorkspace` | 52 | 52 | 4 | 96 |
| `EffectiveRasterPresentation` | 36 | 36 | 4 | 48 |
| `RasterPresentationUnavailable` | 12 | 12 | 4 | 16 |
| `CapabilitySnapshot` | 36 | 36 | 4 | 56 |

The layout checker rejects missing, duplicate, malformed, or over-ceiling
rows. Its checked-in regression proves a 193-byte contribution buffer fails
the 192-byte ceiling. Full 32-bit layout and linked-resource reporting remains
assigned to `T5.3`; this task establishes the early host breach detector.

## Four-profile scope

The same production source and boundary regressions pass macOS dynamic,
macOS static, Raspberry Pi ARMv6, and nRF52840 Embedded Swift profiles.
Allocation execution is a macOS host observation; ARMv6 and nRF results are
hardware-free cross-build evidence only. No remote access, deployment,
restart, or flashing occurred.

# SPEC-005 Authority and Fixture Audit

Plan task: `T0.1`

Date: 2026-08-31

## Lifecycle authority

The complete implementation gate is present and authoritative:

| Artifact | Evidenced status | Reciprocal SPEC-005 relationship |
| --- | --- | --- |
| PROPOSAL-003 | accepted | lists SPEC-005 |
| RFC-002 | approved | lists SPEC-005 |
| RFC-003 | approved | lists SPEC-005 |
| RFC-004 | approved | lists SPEC-005 |
| RFC-005 | approved | lists SPEC-005 |
| ADR-005 | accepted | lists SPEC-005 |
| ADR-006 | accepted | lists SPEC-005 |
| ADR-008 | accepted | lists SPEC-005 |
| ADR-009 | accepted | lists SPEC-005 |
| ADR-010 | accepted | lists SPEC-005 |
| ADR-021 | accepted | lists SPEC-005 |
| ADR-022 | accepted | lists SPEC-005 |
| ADR-023 | accepted | lists SPEC-005 |
| SPEC-002 | implementing approved contract | lists SPEC-005 |
| SPEC-003 | implementing approved contract | lists SPEC-005 |
| SPEC-005 | implementing approved contract | links the chain above |
| SPEC-005 implementation plan | active | points to SPEC-005 |

`docs/features.yaml` registers SPEC-005 under
`giftui-mvp-architecture`, whose stage is already `implementation` because
approved sibling contracts are also being implemented. The progress
transition does not require a manifest-stage change.

SPEC-007, SPEC-008, SPEC-014, and SPEC-015 reciprocally list SPEC-005 and
retain ownership of production layout, render, backend, and host adapters.
Their existence does not make plan task `T4.4` dependency-complete.

## Evidence and deferred boundaries

SPIKE-005 is `completed` and links SPEC-005. Its adopted source, license,
canonical bytes, hashes, and measured calibration are evidence inputs; its
generator, validator, and firmware organization remain disposable.

FW-001, FW-002, and FW-003 are `captured`, link SPEC-005, and preserve complex
typography, text interaction/accessibility geometry, and advanced resource
delivery. None is triggered or promoted by implementation start.

## Acceptance labels and non-goals

The approved Specification and active plan each contain exactly these thirteen
labels once and in order:

```text
TR-001 TR-002 TR-003 TR-004 TR-005 TR-006 TR-007
TR-008 TR-009 TR-010 TR-011 TR-012 TR-013
```

The fixture boundary introduces no public `Text` API, layout constraints,
wrapping or truncation, positioned-glyph production operation, render order,
backend raster algorithm, cache or atlas policy, capability family, host
product policy, runtime registration, complex shaping, editing, accessibility
geometry, or general typography platform.

## MVP justification

The substantially shared Signal Analyzer presentation requires deterministic
titles, subtitles, channel names, levels, status, controls, visible-window
values, and bounded error text on macOS dynamic, macOS static, Raspberry Pi 1
Linux, and nRF52840. SPEC-005 is the approved contract for equal logical glyph
selection and geometry across those stacks while permitting exact
target-selected raster realizations.

## Fixture contract

The fixture README, ordered manifest, normalized-corpus schema, matched
resource-harness roots, deterministic generated/report roots, and distinct
host, cross-built, simulator, and connected-target evidence labels are checked
in. No production target, semantic implementation, remote access, deployment,
service restart, simulator execution, or flashing was introduced by this
audit.

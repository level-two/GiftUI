# SPEC-004 Authority and Fixture Audit

Plan task: `T0.1`

Date: 2026-08-29

## Lifecycle authority

The complete implementation gate is present and authoritative:

| Artifact | Evidenced status | Reciprocal SPEC-004 relationship |
| --- | --- | --- |
| PROPOSAL-004 | accepted | lists SPEC-004 |
| RFC-004 | approved | lists SPEC-004 as related |
| RFC-006 | approved | lists SPEC-004 as related |
| ADR-010 | accepted | lists SPEC-004 as related |
| ADR-017 | accepted | lists SPEC-004 as related |
| ADR-018 | accepted | lists SPEC-004 as related |
| ADR-019 | accepted | lists SPEC-004 as related |
| ADR-020 | accepted | lists SPEC-004 as related |
| SPEC-004 | approved | links the accepted/approved chain above |
| SPEC-004 implementation plan | ready | points to SPEC-004 |

RFC-002 and RFC-005 remain approved integration context. They are not used to
replace any accepted capability ADR or the approved Specification.

`docs/features.yaml` registers `capability-system` at Specification stage with
PROPOSAL-004, RFC-006, ADR-017 through ADR-020, and SPEC-004. RFC-004 and
ADR-010 remain registered under their owning `giftui-mvp-architecture` feature
and reciprocally reference SPEC-004 rather than being duplicated in the
capability-system entry.

SPEC-002 and SPEC-003 each list SPEC-004 and state the reciprocal Foundation,
failure, and capability ownership boundaries. No conflicting authoritative
relationship was found.

## Acceptance labels

The approved Specification contains exactly these 17 labels:

```text
CR-001 CR-002 CR-003 CR-004 CR-005 CR-006 CR-007 CR-008 CR-009
CR-010 CR-010A CR-011 CR-012 CR-013 CR-014 CR-015 CR-016
```

The ready implementation plan contains the same set once each in its
acceptance-criterion matrix. `CR-010A` is an independent label and is not
collapsed into `CR-010`.

## MVP justification

The Signal Analyzer must use one portable presentation across macOS dynamic,
macOS static, Raspberry Pi/PiScreen, and nRF52840/TFT. Those stacks require
different full-surface and bounded tiled raster paths. SPEC-004 is the approved
MVP mechanism for proving one identity-free `rasterPresentation` promise
before startup; it is stack-validation infrastructure, not a post-MVP general
capability catalogue.

## Fixture contract

The fixture README, ordered compile manifest, normalized corpus schema,
raw-adapter/typed-resolver boundary, matched resource roots, deterministic
generated/report roots, and host/cross-build/connected-target evidence labels
are checked in. No production target, placeholder owner contract, remote
access, deployment, or flashing was introduced by this audit.

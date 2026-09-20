# SPEC-013 / SPEC-015 Layout-Capacity Amendment Review

**approved for implementation** — the maintainer explicitly approved the
measured additional layout scopes on 2026-09-20. The amendment changes a
bounded workload capacity and its directly derived storage projections; it
does not change layout semantics, hierarchy ownership, or accepted
architecture.

## Evidence reviewed

- The production Dynamic semantic-to-layout join measured 52 layout scopes in
  the diagnostic-absent hierarchy and 53 in the diagnostic-present hierarchy.
- The 53-scope maximum comprises 13 stack containers, 21 text primitives, 3
  spacers, 5 Canvas primitives, 6 button action proxies, and 5 disabled-
  modifier scopes.
- At the former 32-scope preset the production join fails closed with
  `LayoutError.capacityExhausted` before layout publication.
- Existing text, positioned-glyph, line, and depth limits already admit the
  measured maxima. Only the layout-scope relation was deficient.

## Resource projection

The existing profile representations establish 40 layout-candidate bytes and
64 render-workspace bytes per Dynamic scope, and 32 and 48 bytes per Static
scope. Applying those sizes to 53 scopes yields:

| Profile | Layout candidate | Render workspace | Checked total |
| --- | ---: | ---: | ---: |
| Dynamic | 2,120 bytes | 3,392 bytes | 33,816 bytes |
| Static | 1,696 bytes | 2,544 bytes | 30,608 bytes |

All unrelated audit fields remain unchanged.

## Review findings

The amendment conforms to ADR-006 profile equivalence and ADR-008 ownership.
It makes the existing SPEC-013 relation between layout and render-workspace
capacities true for the already approved SPEC-001 hierarchy. Exact-limit,
first-excess, generated-artifact freshness, four-preset comparison, and
resource-audit evidence remain required before implementation conformance may
be claimed.

The Specifications remain `implementing`; approval authorizes this amendment
but does not mark either Specification implemented.

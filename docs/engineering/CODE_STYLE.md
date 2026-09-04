# GiftUI Code Style

This document defines the repository-wide baseline for maintained Swift code.
It is an engineering policy, not an architecture or feature-lifecycle artifact.

## Authority

Code MUST conform to accepted ADRs and approved Specifications before it
conforms to this guide. When an authoritative artifact prescribes an exact
declaration, term, module boundary, ownership rule, or resource behavior, that
contract overrides a general style preference.

Use the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
for naming and API clarity unless GiftUI's authoritative artifacts require a
more specific spelling or structure.

## Automated formatting

The repository uses the `swift format` command bundled with the selected Swift
toolchain and the checked-in `.swift-format` configuration. Do not install or
select a global formatter for repository checks.

From the repository root:

```sh
scripts/format-swift.sh
scripts/format-swift.sh --lint
```

The first command rewrites in-scope files. The second performs the same check
without changing files and fails when formatting is required. The default
`scripts/test.sh` gate runs the lint form.

Formatting applies to maintained Swift package manifests, library sources,
unit tests, the Signal Analyzer reference application, and the Raspberry Pi
toolchain probe. It intentionally excludes:

- generated sources, whose generator owns their representation, including
  explicitly registered generated files outside a `Generated/` directory;
- `ThirdParty/`, whose upstream source owns its style;
- `Tests/ContractFixtures/`, where exact or deliberately rejected source can
  be part of contract evidence;
- `experiments/`, whose Spike sources are disposable and non-authoritative.

A newly maintained Swift area MUST be added to `scripts/format-swift.sh` in
the change that introduces it. Do not broaden formatting scope incidentally
while performing unrelated work.

Use a formatter suppression only when formatting would damage a contract,
fixture, generated representation, or compiler/tooling workaround. Keep the
suppression as narrow as possible and explain the reason in an adjacent
comment. Aesthetic preference alone is not a reason for suppression.

## Source conventions

- Use four spaces for indentation and spaces rather than tabs.
- Keep source encoded as UTF-8, use Unix line endings, and end files with a
  newline.
- Prefer one primary type or closely related type family per file. Small value
  types and private helpers MAY remain beside their sole owner when that makes
  ownership clearer.
- Name files after their primary type or responsibility. Keep the established
  target and module names when an approved Specification defines them.
- Order imports deterministically. Import only modules used by the file, and
  do not introduce Foundation or platform modules into portable targets unless
  an authoritative contract permits the dependency.
- Prefer the narrowest access level that satisfies the approved contract.
  Public API surface is a contract decision, not a formatting convenience.
- Keep comments focused on rationale, invariants, ownership, resource bounds,
  or non-obvious constraints. Do not narrate syntax.
- Use documentation comments for public declarations when their behavior,
  constraints, or failure semantics are not already obvious from the name and
  signature. Documentation MUST not promise behavior beyond the governing
  Specification.

## Tests

- Give tests behavior-oriented names that identify the condition and expected
  result. Existing XCTest tests use the `test...` naming convention.
- Keep Arrange/Act/Assert structure visually clear, but add section comments
  only when the phases are not evident from the code.
- Prefer observable behavior and contract evidence over private implementation
  details.
- Preserve exact raw values, memory bounds, allocation bounds, profile
  distinctions, and failure behavior required by approved Specifications.
- A formatting-only change MUST NOT update expected values or weaken an
  assertion to make a check pass.

## Change discipline

Format files changed by a code change before running tests. Keep pure
repository-wide formatting migrations in dedicated commits so semantic review
is not obscured by mechanical edits.

Changes to `.swift-format`, formatting scope, or this policy require normal
review and MUST explain the repository-wide effect. A style-policy change does
not authorize changes to architecture, public contracts, or MVP scope.

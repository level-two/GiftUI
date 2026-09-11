# SPEC-008 Contract Fixtures

This directory contains the profile-neutral fixture and evidence schemas
derived from approved SPEC-008. The
corpus fixes symbolic semantic/layout inputs, normalized rendering results,
ordered recording events, exact local failure mappings, and the Signal Analyzer
rendering manifest without defining pixel output, backend behavior, frame
disposition, runtime-profile storage, or host policy.

## Canonical manifests

`fixtures.yaml` is the canonical rendering corpus. Every case contains all
fields listed in `fixture-fields.tsv`, has a globally unique lowercase
kebab-case name, cites at least one `RD-001` through `RD-011` criterion, and
uses only the closed result, event, failure, damage-mode, and evidence tokens
registered here. `signal-analyzer.yaml` uses the separately frozen fields in
`signal-analyzer-fields.tsv` and the same naming, criterion, and evidence
rules.

The initial manifests intentionally contain no cases or variants. Later
owning tasks add complete rows without changing the frozen schemas. Case or
variant names listed in `required-evidence.tsv` must exist and reciprocally
cite that criterion. The harness rejects duplicate names, missing or unknown
fields, unknown references, and unreferenced symbolic identity or resource
data.

## Symbolic identities and recording values

`symbolic-tokens.tsv` freezes the token namespaces. Identity tokens are
nominal fixture values written as `identity:<name>`, where
`<name>` is lowercase kebab-case. They preserve equality relationships only;
they are never raw identity bytes, pointers, addresses, hashes, metatype
addresses, or profile-private storage. Resource tokens are written as
`resource:<name>`, `instance:<name>`, and `glyph:<name>` and preserve the exact
nominal identities owned by `GiftUITextResources`.

Each canonical case declares its complete `identityTokens` and
`resourceTokens` arrays. Every declared token must be referenced elsewhere in
that case, and every referenced token must be declared. Tokens are scoped to
one case and have no persistent meaning.

`recording-events.tsv` fixes the closed vocabulary in the Specification's
notation order and the fields required by each event. Each case's
`expectedRecordingEvents` sequence fixes the actual painter order; fills and
glyph groups may interleave. `normalized-results.tsv` fixes success/failure
result shapes.
`failure-schema.tsv` fixes all seven local errors, their precedence, and exact
SPEC-003 mappings. Its arithmetic row is exercised by direct value mapping and
source audit because safe SPEC-002 rectangles cannot make intersection
overflow; fixtures never forge invalid rectangle representations. Workspace
call records separately cover foreground current/push/pop operations, stack
high-water, visits, and reset. Tests compare nominal identities and numeric
fields, not a string or byte serialization of a rendered result.

## Evidence registry

`required-evidence.tsv` contains exactly `RD-001` through `RD-011`. Every row
begins `pending`; T0.1 establishes only a fail-closed evidence registry and
does not satisfy an acceptance criterion.

Evidence classes remain distinct:

- `host-execution` executes pure focused fixtures on the build host.
- `cross-build` compiles a non-host artifact without executing it.
- `inspection` examines interfaces, layouts, symbols, sections, stack, or link
  maps without target execution.
- `simulator` executes through an explicitly named simulator.
- `connected-hardware` executes on an explicitly selected physical target and
  requires separate user authorization.

No SPEC-008 fixture or schema command deploys, restarts a service, flashes a
board, or claims connected-hardware evidence. SPEC-008 conformance requires no
connected hardware.

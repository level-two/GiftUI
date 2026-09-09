# SPEC-007 Contract Fixtures

This directory contains the profile-neutral fixture and evidence schemas
derived from approved SPEC-007. The corpus fixes symbolic Semantic Core input,
canonical source-token layout transcripts, normalized results, exact local
failure mappings, and acceptance evidence without defining rendering, runtime
storage, backend behavior, platform integration, or host policy.

## Canonical corpus

`fixtures.yaml` is the canonical layout corpus. Every case contains all fields
listed in `fixture-fields.tsv`, has a globally unique lowercase kebab-case
name, cites at least one `LY-001` through `LY-009` criterion, and uses only the
closed result, transcript-event, failure, token, and evidence vocabularies
registered here. The initial manifest intentionally contains no cases. Later
owning tasks add complete cases without changing the frozen schemas.

`fixture-manifest.tsv` is the ordered fixture registry. Drivers reject an
unregistered fixture file, duplicate order or domain, unknown collection, or
evidence-class drift. Case names listed in `required-evidence.tsv` must exist
and reciprocally cite that criterion.

## Source tokens and normalized observations

`source-tokens.tsv` freezes nominal fixture namespaces. `scope:<name>` tokens
represent only SPEC-006 identity equality relations and canonical source
order; they are never raw identity bytes, pointers, addresses, hashes,
metatype addresses, or profile-private storage. `instance:<name>` and
`glyph:<name>` tokens stand for exact nominal identities owned by
`GiftUITextResources`. Every declared token must be referenced by its case,
and every referenced token must be declared.

`source-token-transcript.tsv` fixes the complete staged event vocabulary and
required fields. Scope, text-line, and glyph events occur in the canonical
depth-first order required by SPEC-007. `normalized-results.tsv` fixes the
success and failure shapes; comparisons use field values and identity
relations rather than a production serialization. `failure-schema.tsv` fixes
all five local errors, their raw values, and exact SPEC-003 mappings.
Reentrancy remains the first entry check; other coincident failures are
resolved at their normative traversal or injection point rather than by
inventing a global error ordering.

## Evidence registry

`required-evidence.tsv` contains exactly `LY-001` through `LY-009`. Every row
begins `pending`; T0.1 establishes a fail-closed registry and satisfies no
acceptance criterion by itself.

Evidence classes remain distinct:

- `host-execution` executes pure declaration, semantic-view, or layout
  fixtures on the build host.
- `cross-build` compiles a non-host artifact without executing it.
- `inspection` examines interfaces, value layouts, symbols, sections, stack,
  link maps, or ELF attributes without target execution.
- `simulator` executes through an explicitly named simulator.
- `connected-hardware` executes on an explicitly selected physical target and
  requires separate user authorization.

No SPEC-007 fixture or schema command deploys, accesses a remote target,
restarts a service, flashes a board, or claims connected-hardware evidence.
SPEC-007 conformance requires no connected hardware.

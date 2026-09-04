# Governance Tooling Improvements — Implementation Specification

**Status:** Draft engineering tooling specification

**Scope:** Repository-local governance discovery, implementation traceability,
and contract-evidence tooling

**Created:** 2026-09-04

**Lifecycle classification:** Lightweight repository-engineering improvement;
this document is not a numbered GiftUI product Specification and does not
authorize changes to product architecture or approved contracts

## 1. Purpose

GiftUI's lifecycle records deliberately distribute product motivation,
architecture, contracts, implementation tasks, and conformance evidence across
different artifacts. That separation preserves authority, but it also creates
avoidable implementation overhead:

- agents and maintainers repeatedly rediscover the same authority chain;
- task-to-requirement and task-to-evidence relationships are mostly embedded
  in prose;
- concurrent profile runs may overwrite report directories;
- compiler fixtures may accidentally observe modules produced by earlier
  steps in a shared scratch directory;
- broad test gates are sometimes rerun when a focused gate would be sufficient;
  and
- SwiftPM cache and sandbox behavior is handled inconsistently by callers.

This specification defines repository-local tooling that reduces that
overhead without weakening the existing Proposal → RFC → ADR → Specification
authority model.

## 2. Governing Rules

The implementation MUST preserve and defer to:

- [Feature Lifecycle](FEATURE_LIFECYCLE.md);
- [Documentation Rules](DOCUMENTATION_RULES.md);
- [AI Agent Rules](AI_AGENT_RULES.md);
- [Implementation Documentation](IMPLEMENTATION_DOCUMENTATION.md);
- [Code Style](CODE_STYLE.md); and
- [the feature registry](../features.yaml).

Generated indexes, context packs, task manifests, and reports are navigation
or evidence aids only. They MUST NOT become an alternative authority channel.
If generated output conflicts with a source artifact, the source artifact wins
and validation MUST fail until the generator or its inputs are corrected.

## 3. Goals

The implementation MUST:

1. resolve the authoritative artifact chain for a feature, Specification, or
   implementation task without semantic search;
2. generate compact, deterministic task context containing exact source text,
   provenance, status, and hashes;
3. expose task-to-requirement, task-to-check, task-to-profile, and
   task-to-evidence mappings in a machine-checkable form;
4. prevent profile evidence from being silently overwritten or compared across
   different input states;
5. isolate positive and negative compiler fixtures from undeclared modules;
6. provide focused, profile, Specification, and repository validation levels;
7. standardize repository-local SwiftPM cache and sandbox options; and
8. remain usable offline with repository-managed tools.

## 4. Non-Goals

This work MUST NOT:

- introduce a vector database, embeddings, external search service, hosted
  index, or network dependency;
- summarize normative text and then treat the summary as authority;
- change lifecycle stages, approval rules, document precedence, or human
  approval requirements;
- allocate or approve Proposal, RFC, ADR, or Specification IDs;
- infer missing relationships from textual similarity;
- modify product modules, public APIs, runtime profiles, backends, or target
  behavior;
- claim connected-hardware evidence from compilation or simulation; or
- require Raspberry Pi deployment or nRF52840 flashing.

## 5. Terminology

- **Source artifact:** A tracked lifecycle, engineering, scope, architecture,
  implementation, or deferred-work document.
- **Authority graph:** A generated navigation graph whose nodes and edges come
  only from explicit registry entries and document metadata.
- **Context pack:** A generated Markdown and/or JSON bundle containing exact
  relevant source sections and provenance for one task.
- **Task evidence manifest:** A tracked operational index mapping plan tasks to
  requirements, files, checks, profiles, evidence, and blockers.
- **Input-set hash:** A SHA-256 digest over the sorted path-and-hash inventory
  declared by a contract driver.
- **Run identity:** The repository revision plus input-set hash used to isolate
  generated evidence.
- **Focused gate:** The smallest registered validation command that proves one
  task or tightly related group of changes.

## 6. Required Components

### 6.1 Authority graph generator

The repository MUST provide:

```text
scripts/governance/build-authority-graph.rb
```

The command MUST read only tracked repository sources. At minimum, inputs are:

- `docs/features.yaml`;
- lifecycle documents under `docs/proposals/`, `docs/rfcs/`, `docs/adrs/`, and
  `docs/specs/`;
- deferred records under `docs/future-work/`, `docs/explorations/`, and
  `docs/spikes/`; and
- implementation records under `docs/implementation-plans/`,
  `docs/implementation-designs/`, and `docs/conformance/`.

Its default output MUST be:

```text
.build/governance/authority-graph.json
```

The generated file MUST be deterministic and MUST contain this top-level
shape:

```json
{
  "schemaVersion": 1,
  "generatedFrom": [{"path": "docs/features.yaml", "sha256": "..."}],
  "nodes": [],
  "edges": []
}
```

Each node MUST contain:

```json
{
  "id": "SPEC-005",
  "kind": "specification",
  "feature": "giftui-mvp-architecture",
  "title": "Deterministic Text Resource Contract",
  "status": "implementing",
  "path": "docs/specs/spec-005-text-resources.md",
  "sha256": "...",
  "authoritative": true
}
```

`authoritative` MUST be derived from artifact kind and exact allowed status,
not from age, detail, references, or implementation existence. Proposal and RFC
nodes remain context even after acceptance or approval. Accepted ADRs and
approved, implementing, or implemented Specifications are authoritative in
their documented precedence order.

Each edge MUST name an explicit relationship and its source:

```json
{
  "from": "SPEC-005",
  "to": "ADR-023",
  "relationship": "related_adrs",
  "declaredBy": "docs/specs/spec-005-text-resources.md"
}
```

The generator MUST fail for:

- duplicate IDs;
- unknown IDs;
- invalid status values or transitions visible in current metadata;
- missing registered lifecycle artifacts;
- broken supersession pairs;
- missing reciprocal deferred-work links;
- a document feature key absent from `docs/features.yaml` when registration is
  required;
- conflicting paths for one ID; or
- malformed required metadata.

It MUST support `--check`, which regenerates in memory and returns nonzero for
any validation error without changing files.

### 6.2 Deterministic task context packs

The repository MUST provide:

```text
scripts/governance/context-for-task.rb \
  --spec SPEC-005 \
  --task T5.1 \
  --format markdown
```

Supported formats MUST be `markdown` and `json`. Default outputs MUST be placed
under:

```text
.build/governance/context-packs/<spec-id>/<task-id>.<extension>
```

A context pack MUST contain:

1. requested Specification and task IDs;
2. feature lifecycle stage from `docs/features.yaml`;
3. governing accepted ADRs and the approved/current Specification;
4. relevant Proposal and RFC links clearly labeled as context rather than
   implementation authority;
5. the exact implementation-plan task text;
6. every acceptance criterion mapped to the task;
7. current design notes and prior evidence explicitly linked by that task;
8. downstream prerequisites and their current evidenced status;
9. linked deferred items and revisit triggers;
10. exact source paths, section headings, line spans, and SHA-256 hashes; and
11. a generated input-set hash for the pack.

Normative content MUST be copied verbatim as complete selected sections. The
tool MUST NOT use an AI-generated summary as a replacement for source text.
Non-normative navigation annotations MUST be labeled `Generated navigation`.

Selection MUST be driven by explicit IDs and the task evidence manifest. The
tool MUST NOT infer a relationship merely because two documents contain
similar words.

If a byte or section limit would truncate normative content, generation MUST
fail with a request to narrow the task or selection. It MUST NOT silently
truncate a MUST/MUST NOT requirement, acceptance criterion, task description,
blocker, or exception.

The command MUST support `--stdout` and `--check`. `--check` MUST verify that an
existing pack matches current input hashes. Context packs are generated build
artifacts and MUST NOT be committed by default.

### 6.3 Task evidence manifests

Each actively implemented Specification SHOULD provide:

```text
Tests/ContractFixtures/<SPEC-ID-without-hyphen>/task-evidence.yaml
```

For existing fixture naming, `SPEC-005` therefore uses:

```text
Tests/ContractFixtures/SPEC005/task-evidence.yaml
```

The schema MUST be versioned:

```yaml
schema_version: 1
spec: SPEC-005
plan: docs/implementation-plans/spec-005-implementation-plan.md
tasks:
  T5.1:
    disposition: completed
    requirements:
      - TR-003
      - TR-004
      - TR-006
    implementation:
      - scripts/contracts/run-spec-005.sh
    checks:
      - scripts/contracts/compare-spec-005-profile-semantics.rb
    profiles:
      - macos-dynamic
      - macos-static
      - raspberry-pi-armv6
      - nrf52840-embedded
    evidence:
      - Tests/ContractFixtures/SPEC005/Evidence/milestone-5/four-profile-semantic-corpus.md
    blockers: []
```

Allowed dispositions MUST be `pending`, `in_progress`, `completed`, `blocked`,
`changed`, `removed`, and `not_applicable`.

The implementation plan remains the human-readable source for ordering,
rationale, and task prose. The manifest is an operational index, not a product
contract. A validator MUST fail if plan checkboxes/completion records and
manifest dispositions disagree.

For a `completed` task:

- every listed file and check MUST exist;
- at least one evidence path MUST exist;
- every mapped acceptance criterion MUST be declared by the governing
  Specification; and
- required profiles MUST have a registered driver or explicitly scoped host
  check.

For a `blocked` task, `blockers` MUST be nonempty and each blocker MUST name an
artifact ID, task ID, target, or file whose absence or status is
machine-verifiable where practical.

The validator MUST also report:

- acceptance criteria with no tasks;
- completed tasks with no evidence;
- evidence files referenced by no task;
- checks referenced by no task or registry; and
- product files changed by implementation but absent from every relevant task
  entry.

### 6.4 Immutable contract report identities

Contract drivers MUST stop treating a profile-only path as durable evidence.
The canonical report path MUST be:

```text
.build/contract-reports/<spec>/<run-id>/<profile>/
```

where:

```text
run-id = <full-HEAD-revision>-<first-16-hex-of-input-set-sha256>
```

The input-set hash MUST be calculated from a lexicographically sorted UTF-8
stream containing each declared repository-relative input path, one tab, its
lowercase SHA-256 digest, and one newline. The inventory MUST include the
driver, helper checks, source files, fixtures, manifests, generator inputs,
generated tracked assets, and applicable engineering configuration.

Dirty working trees are allowed for local iteration, but the content hash—not
the boolean dirty flag—MUST distinguish their reports. Metadata MUST still
record `repository_dirty=true|false`.

Each driver MUST:

1. calculate the complete input inventory before compiling;
2. create a unique temporary report directory under the same filesystem;
3. write metadata, commands, logs, hashes, transcripts, and measurements there;
4. verify report completeness;
5. atomically rename the temporary directory to its canonical run path; and
6. refuse to overwrite a different existing report.

If the canonical directory already exists and every tracked report hash is
identical, the driver MAY report an idempotent match. Otherwise it MUST fail.

A convenience pointer MAY be written as:

```text
.build/contract-reports/<spec>/latest-<profile>.txt
```

The pointer MUST contain only a run ID plus newline. It is mutable convenience
state and MUST NOT be cited as durable evidence.

Cross-profile comparison MUST require the same full revision and input-set
hash. Comparing mixed report identities MUST fail before comparing semantic or
resource results.

### 6.5 Compiler-fixture isolation

Every compile fixture MUST declare its permitted imported modules. The fixture
manifest SHOULD use an explicit field such as:

```text
id  expectation  access  entry  patterns  allowed_modules
```

Before compiling a fixture, the driver MUST create a fixture-local module
directory containing only the declared modules and their required transitive
dependencies. It MUST NOT pass a shared product build directory through `-I`.

Negative import fixtures MUST therefore prove absence from their declared
boundary, regardless of which products were compiled earlier or concurrently.
Fixture results MUST be invariant under a reversed build-step order.

The fixture report MUST record:

- the exact compiler command;
- allowed module names;
- copied module/interface hashes;
- expectation and exit status; and
- matched diagnostic patterns for negative fixtures.

### 6.6 Staged validation gates

The repository MUST expose four validation levels:

| Level | Purpose | Required behavior |
| --- | --- | --- |
| Focused task | Fast iteration on one task | Run only task-manifest checks and directly listed tests/checkers |
| Profile | Reproduce one contract profile | Run the exact standalone profile driver |
| Specification | Compare every required profile and task disposition | Require matching immutable run identities and run cross-profile checks |
| Repository | Merge-readiness regression gate | Run formatting, governance, root tests, and registered default contract profiles |

The preferred command surface is:

```text
scripts/check-task.sh --spec SPEC-005 --task T5.1
scripts/check-spec.sh --spec SPEC-005 --profile macos-dynamic
scripts/check-spec.sh --spec SPEC-005 --all-hardware-free
scripts/test.sh
```

Existing stable profile commands MUST remain valid. Wrapper commands MUST
delegate to registered drivers rather than duplicate their behavior.

Focused-task validation MUST NOT implicitly run unrelated cross toolchains.
The repository gate MUST continue to fail if formatting, governance, or its
registered default profiles fail.

Every gate MUST print:

- its level and selected scope;
- each command before or as it runs;
- pass, fail, or skipped disposition for each registered check;
- the immutable report run ID where applicable; and
- a final nonzero status if any required check fails.

### 6.7 Repository-local SwiftPM execution wrapper

The repository SHOULD provide one shared shell library or command for
host-side SwiftPM invocations. It MUST:

- place module, manifest, and build caches under `.build/` or `/private/tmp`;
- accept an explicit package path, scratch path, configuration, target/product,
  and additional Swift flags;
- use `--disable-sandbox` only where supported and explicitly requested by the
  calling workflow;
- print or record the final command;
- preserve repository-managed compiler selection;
- never install a compiler, SDK, formatter, or dependency globally;
- never change Xcode selection;
- never hide a permission failure or retry outside an agent sandbox without
  the caller's authorization; and
- preserve the existing Raspberry Pi and nRF52840 project-local toolchain
  scripts as the owners of cross-compilation environment setup.

The wrapper MUST distinguish a compiler/test failure from a host permission or
sandbox failure in its diagnostic text.

## 7. Determinism and Data Handling

All generated JSON MUST use stable key ordering. All generated path inventories
and arrays whose semantics are unordered MUST be lexicographically sorted.
Files MUST use UTF-8, Unix newlines, and a final newline. Hashes MUST use
lowercase hexadecimal SHA-256.

Generated artifacts MUST contain repository-relative paths unless an absolute
toolchain or SDK path is necessary evidence. Host usernames, home-directory
paths, temporary directory names, timestamps, process IDs, and random values
MUST be normalized out of cross-run comparisons.

The tools MUST NOT read or index files outside the repository inputs they
explicitly declare. They MUST NOT include environment-variable values, local
credentials, Git credential configuration, or untracked files unless a driver
explicitly declares a particular untracked file as an input and records that
fact.

## 8. Compatibility and Resource Constraints

Governance tools SHOULD use the Ruby and shell environments already required by
the repository. New third-party runtime dependencies require a separate
justification and MUST be pinned.

Host governance tools do not become target dependencies. Product targets,
Raspberry Pi artifacts, and nRF52840 firmware MUST NOT link governance parsing,
YAML, JSON, hashing, or report-management code.

On the primary macOS development environment:

- authority-graph validation SHOULD complete within 5 seconds;
- context-pack generation for one task SHOULD complete within 5 seconds; and
- focused task selection overhead, excluding the selected checks themselves,
  SHOULD complete within 2 seconds.

These are workflow budgets, not GiftUI runtime requirements. A measured miss
requires evidence and optimization or an explicitly reviewed budget update;
it does not permit skipped validation.

## 9. Failure Behavior

Every new command MUST return zero only when its requested output is complete
and valid. Diagnostics MUST identify the failing artifact, task, relationship,
path, profile, or hash.

The tooling MUST fail closed for:

- stale or malformed generated output;
- ambiguous task IDs;
- missing authority or an unapproved required contract;
- conflicting authoritative artifacts;
- incomplete task evidence;
- mixed report revisions or input-set hashes;
- undeclared fixture modules;
- report overwrite attempts; and
- unsupported profile or gate names.

Failure MUST NOT mutate lifecycle status, delete earlier reports, rewrite source
documents, or broaden the selected validation scope.

## 10. Migration Plan

Implementation SHOULD proceed in these independently reviewable steps.

### Step 1 — Authority graph

- Implement the graph generator and schema.
- Add fixtures for valid, duplicate, unknown, superseded, deferred-link, and
  invalid-status cases.
- Integrate `--check` into governance validation.
- Do not change lifecycle artifact authority or status.

### Step 2 — SPEC-005 task evidence pilot

- Add the task evidence schema and validator.
- Encode the existing SPEC-005 plan without changing task dispositions.
- Cross-check plan tasks, TR acceptance criteria, evidence files, and contract
  checks.
- Refine the schema before migrating other Specifications.

### Step 3 — Context packs

- Implement exact section extraction using the authority graph and task
  evidence manifest.
- Add Markdown and JSON outputs, provenance, input hashing, and stale checks.
- Verify SPEC-005/T5.1 and at least one blocked task such as SPEC-005/T4.4.

### Step 4 — Immutable report layout

- Add input-set hashing and temporary-to-atomic publication to one driver.
- Pilot with SPEC-005's four hardware-free profiles.
- Update cross-profile comparison to reject mixed run identities.
- Preserve a transition reader for existing profile-only reports until all
  registered drivers migrate.

### Step 5 — Compiler-fixture isolation

- Extend fixture manifests with allowed modules.
- Build fixture-local import roots.
- Prove results are identical when reference/product compilation occurs before
  and after negative fixtures.

### Step 6 — Staged gates and SwiftPM wrapper

- Implement focused task and Specification wrappers.
- Centralize host SwiftPM cache/sandbox options.
- Keep existing stable commands as compatibility entry points.
- Integrate the new checks into `scripts/test.sh` only after focused and
  Specification-level gates are stable.

### Step 7 — Remaining Specification migration

- Migrate one Specification at a time.
- Require manifest/plan agreement and stable report reproduction before
  declaring each migration complete.
- Remove transition readers only after all registered drivers use immutable
  report identities.

Each step SHOULD be committed separately with focused tests and its relevant
documentation update.

## 11. Required Tests

The implementation MUST include automated coverage for:

1. every supported artifact kind and status;
2. authoritative versus contextual classification;
3. missing, duplicate, malformed, and superseded graph relationships;
4. reciprocal deferred-work links;
5. stable graph and context-pack output from two fresh temporary roots;
6. context packs containing exact, untruncated normative sections;
7. task-manifest and implementation-plan agreement;
8. completed, blocked, pending, changed, removed, and not-applicable task
   dispositions;
9. uncovered acceptance criteria and orphaned evidence;
10. dirty-tree input-set identity changes;
11. identical reruns producing the same report identity;
12. different inputs never overwriting an existing report;
13. rejection of mixed cross-profile report identities;
14. positive and negative fixture isolation under reversed build order;
15. focused gates excluding unrelated toolchains;
16. existing stable profile commands continuing to work; and
17. repository-gate integration.

Temporary-root tests MUST use disposable directories and MUST NOT modify the
caller's working tree, global Swift configuration, `.toolchains/`, connected
hardware, or remote systems.

## 12. Acceptance Criteria

- [ ] **GT-001:** `build-authority-graph.rb --check` validates every registered
  lifecycle artifact and rejects all required malformed-graph fixtures.
- [ ] **GT-002:** Two fresh-root graph generations from identical tracked
  inputs produce byte-identical JSON and the same input-set hash.
- [ ] **GT-003:** The graph labels accepted ADRs and approved/implementing/
  implemented Specifications as authoritative while keeping Proposal, RFC,
  implementation, and deferred records correctly contextual.
- [ ] **GT-004:** `context-for-task.rb` produces complete Markdown and JSON
  packs for SPEC-005/T5.1 containing exact task, requirement, authority,
  evidence, status, source-line, and hash data.
- [ ] **GT-005:** Context generation fails rather than truncating normative
  content or resolving an undeclared semantic relationship.
- [ ] **GT-006:** SPEC-005 has a schema-valid task evidence manifest whose task
  dispositions agree exactly with its implementation plan and whose TR
  criteria have no unexplained coverage gaps.
- [ ] **GT-007:** Completed and blocked task fixtures fail when evidence or
  blocker data is absent, stale, unknown, or inconsistent with the plan.
- [ ] **GT-008:** Contract report run IDs change when any declared input changes
  and remain identical for two runs with byte-identical inputs.
- [ ] **GT-009:** Concurrent or sequential runs cannot overwrite evidence from
  a different revision or input-set hash.
- [ ] **GT-010:** Cross-profile comparison rejects mixed run identities before
  comparing semantic results.
- [ ] **GT-011:** Every migrated compiler fixture sees only its declared module
  allowlist, and negative import results are unchanged by build-step order.
- [ ] **GT-012:** Focused, profile, Specification, and repository gates expose
  the required scope and preserve existing stable driver commands.
- [ ] **GT-013:** Host SwiftPM workflows use repository-local caches, report
  exact commands, distinguish sandbox failures, and do not mutate global or
  cross-toolchain selection.
- [ ] **GT-014:** All new tooling runs offline and introduces no vector,
  embedding, external index, credential, telemetry, or network dependency.
- [ ] **GT-015:** Governance validation, formatter lint, focused tooling tests,
  migrated Specification checks, and `scripts/test.sh` pass from a clean
  checkout.
- [ ] **GT-016:** User documentation explains source authority, generated
  artifact locations, cleanup, focused workflows, immutable report lookup, and
  how to diagnose stale or mixed evidence.

## 13. Deliverables

The completed implementation is expected to include:

```text
scripts/governance/build-authority-graph.rb
scripts/governance/context-for-task.rb
scripts/governance/check-task-evidence.rb
scripts/check-task.sh
scripts/check-spec.sh
scripts/lib/swiftpm.sh                 # or one equivalently scoped wrapper
Tests/GovernanceTooling/**
Tests/ContractFixtures/SPEC005/task-evidence.yaml
docs/engineering/GOVERNANCE_TOOLING.md
```

Driver-specific changes SHOULD be limited to input declaration, immutable
report publication, fixture import isolation, and registered gate integration.
Any product-source change discovered during this work is outside scope and
must follow its governing approved Specification.

## 14. Implementation Completion

This tooling initiative is complete when all GT criteria have reproducible
evidence, the SPEC-005 pilot and repository gate pass from a clean checkout,
and a maintainer has reviewed the resulting engineering-process changes.

Completion of this document does not approve, implement, or change any GiftUI
product Specification.

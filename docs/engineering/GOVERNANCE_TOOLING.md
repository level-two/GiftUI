# Governance Tooling

GiftUI's governance tools make authoritative inputs easier to find and
implementation evidence harder to mix accidentally. They are navigation and
validation aids only. If generated output disagrees with a tracked lifecycle
artifact, the tracked source wins and the generated output must be rebuilt.

## Source Authority

Use [Feature Lifecycle](FEATURE_LIFECYCLE.md),
[Documentation Rules](DOCUMENTATION_RULES.md), and
[AI Agent Rules](AI_AGENT_RULES.md) to determine authority. In particular,
accepted ADRs and approved, implementing, or implemented Specifications are
authoritative within their documented scopes. Proposals and RFCs preserve
motivation and design context; plans, manifests, context packs, indexes, and
reports do not amend product contracts or imply approval.

The feature registry and explicit document metadata are the only inputs to the
generated authority graph. The tools do not infer relationships from similar
wording.

## Generated Artifacts

All generated governance state is under `.build/` and is untracked:

- `.build/governance/authority-graph.json` is the deterministic authority and
  navigation graph.
- `.build/governance/context-packs/<spec>/<task>.md|json` contains exact,
  provenance-labeled source sections selected by a task manifest.
- `.build/contract-reports/<spec>/<run-id>/<profile>/` is immutable contract
  evidence. A run ID combines the full repository revision and the declared
  input-set hash.
- `.build/contract-reports/<spec>/latest-<profile>.txt` is a mutable lookup
  convenience, not a durable evidence citation.

Tracked task evidence manifests live at
`Tests/ContractFixtures/<SPEC>/task-evidence.yaml`. They index an implementation
plan's dispositions, acceptance criteria, implementation files, checks,
profiles, evidence, and blockers; the plan remains the source for task prose
and ordering.

To clean generated governance output, remove only `.build/governance/`. To
discard local contract evidence for one Specification, remove only its
`.build/contract-reports/<spec>/` directory. Neither cleanup changes tracked
authority or evidence documents.

## Common Workflows

Validate the repository authority graph without writing generated output:

```sh
scripts/governance/build-authority-graph.rb --check
scripts/validate-governance.rb
```

Generate or check an exact task context pack:

```sh
scripts/governance/context-for-task.rb --spec SPEC-005 --task T5.1 --format markdown
scripts/governance/context-for-task.rb --spec SPEC-005 --task T5.1 --format markdown --check
```

Use the narrowest gate that proves the change:

```sh
scripts/check-task.sh --spec SPEC-005 --task T5.1
scripts/check-spec.sh --spec SPEC-005 --profile macos-dynamic
scripts/check-spec.sh --spec SPEC-005 --all-hardware-free
scripts/test.sh
```

The focused gate runs only checks explicitly registered by that task. The
profile gate delegates to the stable contract driver. The Specification gate
runs registered profiles and any cross-profile comparator. The repository gate
adds formatting, governance, root tests, and default contract profiles.
Host-side SwiftPM calls made by repository scripts use `scripts/lib/swiftpm.sh`
so caches remain repository-local and permission failures remain visible.

## Immutable Report Lookup

After a profile run, read its exact run ID from
`latest-<profile>.txt`, then cite files under that run directory. Before using
the report as durable evidence, record the run ID itself rather than relying on
the mutable pointer. Registered drivers never use the former profile-only
layout.

Cross-profile comparison requires every pointer to name the same run ID and
checks matching repository revisions, input-set hashes, and inventories before
semantic output. Run all profiles from the same repository state with
`scripts/check-spec.sh --spec <SPEC-ID> --all-hardware-free` when a comparison
is required.

## Diagnosing Stale or Mixed Evidence

- A missing-pointer error means the requested profile has not produced an
  immutable report in this checkout. Run that profile's registered driver.
- A stale context-pack error means a tracked selected source changed. Generate
  the pack again; do not edit generated text.
- A mixed-run error means profiles were produced from different revisions or
  input sets. Rerun the complete Specification gate without changing tracked
  inputs between profiles.
- An input-inventory mismatch identifies a driver declaration or repository
  change, even when semantic output happens to match. Reproduce all affected
  profiles rather than copying reports or changing pointers manually.
- A report verification or overwrite error means canonical evidence differs
  or was modified. Preserve it for diagnosis, remove only the specific local
  run if it is disposable, and rerun the driver; never overwrite another run.

These workflows are offline and do not deploy to Raspberry Pi, flash an
nRF52840 board, install toolchains globally, or claim connected-hardware
evidence.

# SPEC-014 T8.1 Canonical Loader and Driver Evidence

Date: 2026-09-13

`SPEC014::FixtureLoader` reads the five ordered corpus files and the shared
field schema as authority. It requires exact fields in exact order, globally
unique stable IDs, registered criteria/evidence classes/profiles, explicit
shapes for every expected value, and no nested profile-keyed expectations.

The acceptance manifest admits only explicit `pending` or `complete`
dispositions. The standalone driver hashes the loader, failure checker, and
profile comparator and confines its report, staging, SwiftPM scratch, and
cache paths to `.build/spec-014/`.

`compare-spec-014-profiles.rb` parses canonical JSON fields, rejects duplicate
or unequal fixture-ID sets, and compares semantic results by ID rather than
row order, memory address, or implementation identity.

Run from the repository root:

```sh
scripts/contracts/check-spec-014-fixtures.rb
ruby -c scripts/contracts/spec014_fixture_loader.rb
ruby -c scripts/contracts/compare-spec-014-profiles.rb
scripts/contracts/check-driver-registry.rb
```

All checks pass.

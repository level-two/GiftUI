# SPEC-015 T7.2 Four-Profile Driver

`scripts/contracts/run-spec-015.sh` now fails closed unless every profile runs
the fixture/schema audit, exhaustive negative-corpus audit, source/import
boundaries, generated-manifest freshness check, nine-stage validation purity
check, package-surface positive and negative compilation, and all focused host
configuration tests before its profile-specific compile, link, execution, or
cross-build inspection.

Every invocation is wrapped by the repository immutable-report publisher. The
report records exact commands and logs, labels host execution versus cross-
build inspection, and states that remote access, deployment, connected-target
execution, and flashing are false. Generated report data is confined to the
driver staging directory; platform build artifacts remain in the repository-
mandated `.build/raspberry-pi/` and `.build/nrf52840/` roots.

Exact standalone commands remain:

```text
scripts/contracts/run-spec-015.sh --profile macos-dynamic
scripts/contracts/run-spec-015.sh --profile macos-static
scripts/contracts/run-spec-015.sh --profile raspberry-pi-armv6
scripts/contracts/run-spec-015.sh --profile nrf52840-embedded
```

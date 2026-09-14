# SPEC-012 T9.1 Interface and Boundary Audit

Date: 2026-09-14

All four standalone drivers published run ID
`a028735b8e7ba8684190df71cde1b14b61b1cec2-5b2115319d8cb4b3`. Each report runs
the exact declaration/API and negative compile checks, value-layout probe,
fixture/schema/migration audits, static Canvas manifest generator audit,
independent raster-vector oracle, package dependency checker, and SPEC-014
module-owner checker. The driver records the corpus, SPEC-013 profile
implementation, and SPEC-014 backend evidence as complete prerequisites while
retaining fail-closed acceptance rows for later conformance review.

The four reports record compiler/SDK/target identity, optimization, full
commands, repository revision and dirty state, and fixture digest. They also
record no remote access, deployment, service restart, simulator execution,
connected-target execution, or flashing.

```sh
for profile in macos-dynamic macos-static raspberry-pi-armv6 nrf52840-embedded; do
  scripts/contracts/run-spec-012.sh --profile "$profile"
done
```

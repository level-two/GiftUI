# Real-run discovery follow-up — 2026-10-05

The first combined invocation `run-Lj2rdEks` was deliberately interrupted after
its governance/tooling checks passed. Recursive discovery descended into every
historical child report and their build trees, adding tens of seconds per check.
The retained interruption ledger records its active check; it is not a gate pass.

Discover latest pointers and incomplete staging only at their specified immediate
child locations (`contract-reports/<spec>/latest-*.txt` and `<spec>/.tmp-*`).
Published identities still come directly from the publisher; no archived data is
removed. The overlap/failure/interruption fixture passes 3 tests/28 assertions
after this correction. A new combined invocation will supply final integration.

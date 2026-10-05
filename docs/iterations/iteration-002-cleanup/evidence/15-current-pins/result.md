# Current downstream-source pins — 2026-10-05

The explicit prerequisite audit exposed two stale maintained source-of-truth
hashes: SPEC-008 and SPEC-013 Signal Analyzer fixture YAML. Their underlying
production capacities had already changed in the approved MVP integration;
this retention step did not alter those owner fixtures. The current navigation
pins now match their actual accepted fixture bytes; strict hash refusal remains.
Historical reports and their hashes are unchanged.

`ruby scripts/contracts/check-spec-001-prerequisites.rb` passes: 14 owner
contracts and 12 pinned downstream inputs. [Exact old/new hashes](changes.tsv).
Only current fixture pin metadata changed during the pending aggregate native
check; no product source, check command or owner input changed. All subsequent
profile reports capture the current pins. This metadata correction does not
turn the preceding stale-pin refusal into a pass.

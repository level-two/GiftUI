# Five-second production storage — 2026-10-05

T12.1 complete under approved RFC-012/ADR-034 and coordinated contracts.
Domain/Data and nRF history retain five seconds inclusive; all three slots now
hold 404 16-byte entries, aggregate 19,392 bytes. C allocation/export/startup/
production/build guards and current native/Swift fixtures agree. Unrelated
regions and stacks are unchanged; source schedules are unchanged.

`format-swift.sh` and 29 focused tests in four suites pass: cutoff inclusivity,
equal-time insertion, 404/405 values, capacity/replay, snapshot survival/Clear,
model mutations, 30s synchronized delivery and independent full-history levels.
The full-history test evaluates all three 1/2/5s left edges for four channels
at 601 synchronized cycles, plus baselines/exact retained transitions.
Final delivery is 2,404, retained count 404, cutoff 25s, duration 30s.
An initial run failed on old last-index fixtures (2,403) and is preserved;
corrected current indices are 403/404, first-shortfall count 403.

The nRF cross-build/ABI/resource checks pass; linked RAM is 95,104 bytes,
exactly 96,000 below the prior 191,104-byte maintenance image. Full paired
inspection and fresh combined/profile integration remain T12.3.
The accelerated production-pattern rehearsal delivers 2,400 seeded events
whose source duration ends at 201,770ms; an independent merged timestamp
schedule yields 61 events in its final five seconds (previously 359 in 30s).
Its delivered revision remains 2,404. That schedule-specific expectation is
separate from the synchronized 30s/80-event/s boundary oracle, which retains 404.

Authorized restoration of the previous firmware completed before implementation;
new firmware deployment and scoped lifecycle evidence remain T12.4/T11.7.
[Raw log hashes](identities.json). T12.2 corpus/profile/pixel validation is next;
no whole-stack or physical timing success is inferred from these results.

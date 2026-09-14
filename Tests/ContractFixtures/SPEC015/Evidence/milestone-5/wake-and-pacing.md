# SPEC-015 Wake and Pacing Evidence

`HostWakePacingController` is fixed-size host storage that consumes the
validated pacing policy and target-supplied monotonic microsecond timestamps.

The focused tests prove:

- the first accepted fact produces one wake directive and later reasons
  coalesce without synchronously entering a runtime;
- an opportunity waits just before 250,000 microseconds, begins at the exact
  boundary, and remains valid through the inclusive 250,000-microsecond fact
  service deadline;
- observing the controller after that deadline fails closed;
- a fact admitted after the seal creates a new service window and wake;
- opportunity entry is non-reentrant and quiescence is terminal and
  idempotent;
- timestamp regression and checked-addition overflow fail closed; and
- eighty evenly spaced facts over one second produce exactly four paced
  opportunities and four empty-to-nonempty wake directives.

Reproduce with:

```sh
swift test --filter HostWakePacingControllerTests
```

This is hardware-free host-execution evidence. Concrete scheduler callbacks,
`MVPHostInstance.runOpportunity()`, report-identity exposure, and target-root
latency evidence remain later T5/T6 work.

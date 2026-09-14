# Four-preset host structural-gate evidence

The SPEC-015 workload generator consumes both the host-independent workload
descriptor and SPEC-001's checked-in portable hierarchy descriptor. Their
ordered bytes form the generated preset identity. Generation rejects any
change to the exact `SignalAnalyzerView` root, single `SignalAnalyzerViewModel`
state, six controls/actions, or five ruler/channel Canvas occurrences, as well
as any mismatch with the workload counts.

All four immutable generated presets pass their exact runtime storage audits.
The host validator tests require the Drawing B2 structural workload gate and
the independent SPEC-004 capability resolver before endpoint, action/model,
input/wake, and policy validation. The complete eighteen-role graph is ordered,
single-owner, and acyclic. Validation constructs no runtime, application,
endpoint, input, scheduler, source, observation, or lifecycle owner.

Reproduction:

```sh
ruby scripts/contracts/check-spec-015-generated-workload.rb
swift test --filter GeneratedSignalAnalyzerPresetTests
swift test --filter HostConfigurationTests
scripts/contracts/check-spec-015-source-boundaries.rb
```

# SPEC-001 T6.7 Dynamic Pi Lifecycle Owner

The production `DynamicSignalAnalyzerPiLifecycleOwner` now aggregates the
generated Dynamic limits, concrete display-owning presentation owner,
deterministic source and repository, bounded fact admission, normalized input,
correlation allocation, and shared pacing state. The existing
`MVPHostActivationController` remains the lifecycle-ordering authority.

`DynamicSignalAnalyzerPiAssembly.validate()` constructs every authoritative
startup projection from the generated Raspberry Pi preset and runs the
nine-stage checked host validator before a Linux framebuffer or input device
needs to be opened. Four existing host configuration values now expose
package-scoped initializers so production composition, rather than only
`@testable` fixtures, can enter that validator without weakening any check.

Its seven activation calls construct the runtime/endpoint and application
owners, attach the root candidate, install both repository observations under
the bootstrap producer scope, accept the first physical presentation, invoke
the committed Start action through normalized input and the serialized
application opportunity, and establish the paced host loop. Input is eligible
only after the first accepted frame, and source callbacks remain deferred in
bounded admission.

The focused hardware-free test uses the production pipeline and a synchronous
fake framebuffer sink. It proves active input and source state, admits one
scheduled transition under the transition producer scope, services six
deferred facts at the generated frame boundary, commits the replacement
presentation, and then delegates all eight teardown calls to the controller.
After teardown the source, input, platform-owning presentation, pacing,
profile storage, and assembly-report runtime use are unavailable; repeated
teardown is inert.

The ARMv6 executable now has an explicit `--run-signal-analyzer` production
entry. It validates the immutable assembly before opening `/dev/fb0` or
`/dev/input/event0`, then uses `CLOCK_MONOTONIC` to poll decoded contacts,
advance deterministic-source deadlines, and service the shared frame pacing
owner. SIGINT and SIGTERM request an orderly exit through the controller's
eight-step teardown; input, pacing, clock, and source-schedule failures also
unwind through the same `defer`. The existing inspection and finite adapter
diagnostics remain separate modes.

Validation commands:

```text
swift test --disable-sandbox -Xswiftc -DGIFTUI_DYNAMIC_PROFILE \
  --filter dynamicPiLifecycleOwnerRunsSevenStepsAndEightStepTeardown
scripts/contracts/check-target-dependencies.rb
scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6
```

This is hardware-free lifecycle evidence. It performs no remote access,
deployment, service restart, or connected-target execution. T6.7 remains open
for console ownership/restoration and the separately gated connected
application scenario.

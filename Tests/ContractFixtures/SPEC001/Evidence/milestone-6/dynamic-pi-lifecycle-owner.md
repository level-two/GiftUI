# SPEC-001 T6.7 Dynamic Pi Lifecycle Owner

The production `DynamicSignalAnalyzerPiLifecycleOwner` now aggregates the
generated Dynamic limits, concrete display-owning presentation owner,
deterministic source and repository, bounded fact admission, normalized input,
correlation allocation, and shared pacing state. The existing
`MVPHostActivationController` remains the lifecycle-ordering authority.

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

Validation commands:

```text
swift test --disable-sandbox -Xswiftc -DGIFTUI_DYNAMIC_PROFILE \
  --filter dynamicPiLifecycleOwnerRunsSevenStepsAndEightStepTeardown
scripts/contracts/check-target-dependencies.rb
scripts/raspberry-pi/build.sh --product SignalAnalyzerRaspberryPiARMv6
```

This is hardware-free lifecycle evidence. It performs no remote access,
deployment, service restart, or connected-target execution. T6.7 remains open
for the Linux monotonic process loop, console ownership/restoration, and the
separately gated connected application scenario.

# SPEC-012 T6.5 Profile Canvas Storage Equivalence

The production Dynamic wrapper and generated Static occurrence now share one
focused differential fixture. Both stage one semantic occurrence, invoke the
same path/stroke meaning, expose the same one-stroke immutable-plan counts,
derive the same ordinary-plus-stroke operation count, preserve `.invalidValue`
on the throwing path, release once immediately after invocation, and reject a
later invocation as `.invariantViolation`.

Reproduce the closure-enabled comparison with:

```sh
swift test -Xswiftc -DGIFTUI_DYNAMIC_PROFILE \
  --filter dynamicAndStaticCanvasStorageProduceEqualLifetimeTranscripts
```

The profile owners' already checked-in SPEC-013 reports supply the resource
portion of this joint task:

- `Tests/ContractFixtures/SPEC013/Evidence/milestone-7/resource-instrumentation.md`
  separates heap, peak heap, stack stages, capture and storage bytes;
- `Tests/ContractFixtures/SPEC013/Evidence/milestone-7/target-inspection.md`
  records forbidden symbols/facilities, target ABI, sections, RAM, and flash;
- `Tests/ContractFixtures/SPEC013/Evidence/milestone-7/pristine-profile-builds.md`
  records reproducible profile builds and input identities.

Those reports prove hardware-free build and inspection behavior only. They do
not claim deployment, flashing, or connected-target execution.

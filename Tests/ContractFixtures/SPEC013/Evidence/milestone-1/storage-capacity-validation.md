# T1.3 Storage Capacity Validation

`RuntimeProfileValidator` performs the six SPEC-013 startup checks in order:
focused limit construction, aggregate compatibility, required storage
presence, storage sufficiency with exact render-workspace equality, checked
audit representability, and static Canvas metadata.

The validator accepts only structural values, capacities, byte counts, and
read-only generated-table metadata. Its type surface has no client body,
Canvas invocation, model attachment, admission, wake, policy, diagnostic, or
endpoint callback. The ordering tests combine failures from multiple later
steps and use poisoned static metadata to prove that the first earlier failure
wins without table method invocation.

Focused tests cover every required dynamic storage family, every sized
capacity family, both smaller and larger render-workspace mismatch, static
capture presence and sufficiency, checked byte overflow, invalid generated
metadata, and successful dynamic/static audits.

Reproduce from the repository root:

```sh
swift test --filter RuntimeProfileValidation
scripts/contracts/check-spec-013-module-contract.sh
scripts/format-swift.sh --lint
```

This is host structural-validation evidence. It invokes no portable client or
backend and does not claim concrete profile storage or connected hardware.

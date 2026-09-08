# SPEC-010 T3.3 Structural Reconciliation Evidence

## Scope

This evidence covers the profile-neutral, caller-storage-independent location
lifecycle required by SPEC-010 T3.3. It does not select dynamic heterogeneous
storage or static generated slot packing; those remain assigned to T6 and
SPEC-013.

## Implemented behavior

- A vacant or retired slot stages one materialization and publishes it live.
- A live slot preserves the same structural identity, declaration ordinal,
  and compatible model discriminator without attaching the repeated
  initializer.
- Different declaration ordinals occupy distinct fixture slots.
- Incompatible associations and duplicate ownership fail before attachment
  and preserve the prior owner.
- An unencountered live slot stages removal; publication retires and detaches
  it, while discard restores the prior live association.
- Candidate-only materialization is detached on failed-derivation discard.
- Reinsertion after published removal materializes fresh state.
- Shutdown invalidates the slot, detaches each installed sink once, is
  idempotent, and rejects later candidate entry, encounter, and report
  admission.
- Removal and shutdown invoke no application start/stop lifecycle effect.

## Reproducible validation

```sh
swift test --filter ObservableStateAssociationLifecycleTests
ruby scripts/contracts/check-spec-010-structural-reconciliation.rb
```

The focused Swift suite uses explicit caller-owned slots and typed model
storage. The registered source audit rejects dynamic containers, type erasure,
reflection, suspension, prohibited owner imports, and public/package exposure
of the replaceable internal lifecycle mechanism.

## Boundary

Attachment-generation allocation, full attachment validation, replacement,
dirty reporting, execution admission, profile packing, and failure-to-SPEC-003
mapping remain assigned to later milestones. No backend, platform, runtime,
Interaction, application model, start/stop hook, or failure-policy authority
is introduced here.

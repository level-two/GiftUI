# SPEC-009 Recording Derivation Evidence

`RecordingDerivationTransaction` is an internal, fixture-finite proof of the
Milestone 4 derivation boundary. Mutation membership freezes exactly once.
Invalidations admitted before that boundary coalesce into the current epoch;
invalidations arriving after it coalesce into one later semantic wake.

Changed derivation validates the committed-action bound, reserves every staged
action generation, then reserves the semantic revision. Only after all
reservations succeed does it replace the published revision. Capacity, action-
generation, and semantic-revision failures therefore preserve the prior
publication; reservations already consumed before a later exhaustion remain
retired rather than being reused.

An unchanged semantic result with no presentation obligation returns
`unchanged` without allocating a semantic revision, action generation,
candidate-frame identity, or frame. An existing presentation obligation is a
separate recovery result and still does not manufacture a changed semantic
revision.

The two action slots are bounded fixture storage used to exercise ordering and
exhaustion. They do not define the production coordinator's eventual capacity.

Reproduce the focused evidence with:

```sh
swift test --filter RecordingDerivationTransactionTests
scripts/contracts/check-spec-009-recording-derivation.rb
scripts/contracts/run-spec-009.sh --profile macos-dynamic
scripts/contracts/run-spec-009.sh --profile macos-static
```

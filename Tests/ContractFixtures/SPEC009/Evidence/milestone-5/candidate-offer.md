# SPEC-009 Candidate Offer Evidence

`RecordingCandidateOfferCoordinator` reserves a candidate frame and then a
presentation revision at the end of publishing for a new semantic revision,
or at the end of deriving for unchanged presentation recovery. The resulting
provenance contains the already-complete semantic revision and the fresh
candidate identity before the one synchronous endpoint offer.

Candidate-identity exhaustion produces no candidate. Presentation-identity
exhaustion aborts the already-reserved candidate. Required-facility loss is
covered both before and after candidate allocation; direct contract failure
is detected before endpoint entry. All preserve the semantic revision and
make no body call.

An invalid envelope enters `offer` once, is rejected before body entry, and
aborts the candidate. A second offer attempt for the same coordinator is
rejected as reentrancy without another endpoint or body call.

Reproduce the focused evidence with:

```sh
swift test --filter RecordingCandidateOfferCoordinatorTests
scripts/contracts/check-spec-009-candidate-offer.rb
scripts/contracts/run-spec-009.sh --profile macos-dynamic
scripts/contracts/run-spec-009.sh --profile macos-static
```

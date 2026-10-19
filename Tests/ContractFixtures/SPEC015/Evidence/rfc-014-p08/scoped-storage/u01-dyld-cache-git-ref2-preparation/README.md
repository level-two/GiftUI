# U01 exact Git ref route 2 preparation — 2026-10-19

**Preparation only; network execution not ready.** Following the independently
reviewed [HTTP 403 STOP](../u01-dyld-cache-macos-2662-ref1-result/independent-review.md)
at `1a7339aa9386197d916d6855882177caffe06866`, the human continuation “Please
proceed” covers preparation of a separately bounded route and independent
review. No new network operation ran. The consumed API GET remains consumed.

The proposed route is one smart-HTTPS Git `ls-remote` session against Apple's
already identified distribution repository, restricted to candidate
`refs/tags/macos-2662` and its peeled form. [Request and stops](request.md) and
[exact argv and limits](request.json) pin the proposal. The remote identity is
supported by retained metadata; the candidate spelling is inferred from the
retained release naming convention and has not been established as a published
release. This route answers only whether the candidate ref resolves and, if so,
its advertised object ID. It cannot establish build 25G83, a dyld revision or
installed-cache applicability. A source mapping remains a later separately
prepared and reviewed dependency.

The proposed session accepts at most two logical HTTP requests, 1 MiB aggregate
response bytes and 30 seconds. Bare Git cannot enforce the first two limits;
`http.maxRequests=1` limits concurrency only. Independent review must resolve
that execution-envelope gap before launch. Neither a review of this preparation
nor the human continuation silently waives the gap. No launch controller is
provided or executed by this packet.

[Offline inspection](inspection.json) records exact retained-metadata hashes,
the five dirty-file hashes, one-file cache membership/hash and three marker
device/inode identities. All preservation checks match the prior baseline.
Markers remain each 1/1 consumed, repairs 0, retries 0. Header candidates/bytes
remain 0/3 / 0. No header, Git object, cache parser or dyld tool was read/run.

This remains post-MVP ITERATION-003 revision 5 I3-04/I3-05 evidence under accepted
ADR-039/040 and implementing SPEC-015. Closed ITERATION-001 analyzer/stack
obligations are preserved. No architecture, contract, scope, criterion, resource
exception, lifecycle status or repair allowance changes. S and old B remain
closed. U01/R01–R04, ordinary loaded identity, standalone/cache equivalence,
Error size/body/transitive costs, U02–U05, complete callee/safety, strict cold,
four-profile ABI/resources, P08/R07/T8.1 and conformance remain open. No new
deferred discovery or actual contract/scope choice arose; any relaxation goes
upstream for the requested Astra Medium decision.

[Independent Strong review](independent-review.md) confirms **STOP / readiness
NOT READY**. B01 requires a concrete enforcing request/byte/time/receipt
controller; B02 requires explicit isolation from parent repository configuration.
The proposed empty descendant Git directory does not itself provide isolation.
No network/source/header/parser/controller/runtime/compiler/build/test,
acquisition, repair or retry is cleared.

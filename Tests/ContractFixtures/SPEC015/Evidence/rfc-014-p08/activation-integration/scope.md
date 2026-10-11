# Approved activation integration bounded step — 2026-10-12

Authority: maintainer approval267616c9 of the exact Swift6.4 correction, approved
SPEC-015 scoped-host amendment, accepted ADR-036, active RFC-014 P08 and SPEC-015
T8.1. Implementation-executor and implementation-designer roles apply. This
component step serves ITERATION-001 reference-stack ownership validation within
ITERATION-003 migration; it does not complete P08 or the reference application.

Strong Astra6 Medium owns ActivationJoin*.swift under SPEC015/RuntimeDerived and
only a directly demonstrated lifetime-forwarding correction in existing
GiftUIHostConfiguration. No new host role or contract is permitted. Parent owns
normative documents/design links; Standard owns pins/setup; no checker edits here.

Source inventory: derive inert supplied state, scoped control, fixture initializer
extensions and actual coordinator state from frozen activation-boundary; compile
alongside unchanged P07 RuntimeDerived sources as RuntimeCycleProbe. Integrate
through existing SignalAnalyzerPresetLiveOwner, SignalAnalyzerPresetHostInstance
and MVPHostActivationController. Actual coordinator/endpoint construction occurs
only inside constructRuntimeAndEndpoint called by host.activate. A synthetic
component HostAssemblyReport is explicitly not nine-stage validator evidence.

Maintain package p08ActivationJoin()->Int; test initial valid/inert opportunity
refusal, actual accepted opportunity, repeat activation, ordered/idempotent
teardown, report invalidation/backing-last ordering, and failure after runtime
construction. Maintain actual generic-host copy, reachable callback escape,
constant-marker callback escape and local backing-expiry negatives. The marker
must originate at the trusted innermost supplying callback and retain lifetime
through both states. No unchecked escape or lifetime override is permitted.

Budget: at most12 fresh compiler/link attempts total, including dependency rebuild
for any allowed forwarding change, corrections, positive and negative controls.
Stop after two consecutive failed attempts without a pass or diagnostic narrowing;
stop at budget or completed component controls. Never run an accepted negative.
Before compiling, verify6.4 compiler and fresh dependency/source hashes against
compiler-native-join; reuse only its6.4 modules/objects, record macro subprocess
reuse. Freeze snapshots, commands, diagnostics, input/artifact hashes and ledger.
Format changed maintained Swift before gates. Commit coherent evidence/source
steps and obtain independent Strong review before blocker closure. No cross-target,
full resource, counter/four-route acceptance or P08 exit claim is in scope.

# P08 control-resident payload — final correction 2 freeze

**Corrections 2/2 consumed; independent source review pending.** The first
measurement at `b673d6fa` failed before counter object emission: 23 preparations
passed, counter-model failed, layout blocked, 202 cases not-run. Exact original
logs/commands/receipts, input hashes and failed source are preserved in
`control-resident-initial-measurement-failure/`; there were no raw target facts.
This correction ran no compiler/build/runtime/image and claims no acceptance.

All eight emitted primary errors concern the same new helper extension:
`extension CounterPipelineOwner { ... clearOwnedRuntimeSlot ... }` implicitly
specialized Geometry/Candidate/Committed/Hits to Copyable and Escapable. The actual
scoped retirement caller correctly does not satisfy those owned constraints.
The correction repeats the original concrete protocols, ~Copyable/~Escapable
permissions and SemanticCompleteIdentity equalities in that extension's where
clause, matching the already-correct scoped constructor extension. It changes
neither helper body, access level nor caller/lifetime/cleanup semantics. The
preexisting returnWorkspaces extension intentionally stays Copyable/Escapable.
No unsafe conformance, ownership erasure or contract change is introduced.

Two compiler-free regressions audit all pipeline extensions, reject the exact
bare-extension form and independently remove each of eight required permissions.
All **77 compiler-free tests PASS**; pinned formatter and whitespace checks pass.
No other new extension has the same missing constraints. Existing full backend/
endpoint/four-key/64-record/lastFrame observations and all base/supplemental labels
remain unchanged. Exact source patch/hashes are in
`control-resident-cycle2-source/manifest.json` and `source.patch`.

[New exact applicability](p08-control-resident-cycle2-applicability.json) is pinned
by hash in the driver. Fresh checks again prove eight candidate exclusions from
seven actual component compiler argvs, 895 compiled/generated Swift inputs, 180
core Swift inputs, all artifacts/compiler/macros and 11 dependency receipts.
This cannot qualify any changed counter compiled input or failed runtime result.
Previous freezes/qualifications and failure evidence remain unchanged.

After focused source PASS, the parent may run the one affected collecting fresh
nRF measurement command from the initial freeze. The old 32,000-byte Swift/C
reservation is unchanged: any newly decoded actual minimum must first be retained
as unvalidated diagnostic facts, then exact measured constants and pins completed
under the already planned sizing step and independent review. This is not a third
optimization variant. A further frozen source/validation failure stops automatic
repair under this package. P08 fit and complete acceptance remain open.

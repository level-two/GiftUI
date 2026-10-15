# P08 measured sizing — independent resource boundary review

**Evidence verification PASS; current realization resource FAIL; stop broader
validation for this source.** The [current result](p08-measured-sizing-stack-preflight-result.md)
correctly records compilation and strict layout success, with a conclusive required
RAM lower bound. It does not establish a complete peak or current linked-image fit.

The current ET_REL object hashes to
`dd12ac00c0d5558e18b9ad1afc975a44c321a04eada6773723c82030cb105ea7`.
Current object/receipt/layout and bounded-packet hashes verify. Source identities
match. The current receipt has 25 preparation/module/layout passes and 202 controls
not-run: fresh_focused and focused_passed true, collection_complete and passed
false. Strict 129-root layout evidence establishes 34,720-byte slots, full four-slot
backing 138,880, alignment 8 and zero surplus. This is current finite layout proof,
not full behavior, runtime or image acceptance.

Nine frame allocations were independently decoded from raw Thumb bytes, including
SUBW, STM/PUSH register saves and narrow SP subtraction:
11,680 + 11,872 + 12,664 + 1,528 + 2,680 + 9,136 + 8,552 + 5,208 + 7,768
= **71,088**. Actual section-qualified SHT_REL sh_link/symbol-index targets and
BL encodings verify the selected factory 3829 → reuse closure 3938 and the deep
session 3869 → host 3861 → reuse 3760 → old origins 3720 → stale action 3672 →
fingerprint match 3637 → initializer 3617. The two alternative match calls are
counted once, and initialization is nested inside matching rather than combined
with its later equality branch.

The callback gap is supported by actual records, not a presumed direct call.
Closure 3938's second host call at 654 passes the callback at relocation 864;
actual forwarders 12628 → 11294 → 11305 reach body 3903. Further exact callback
relocations/direct forwarding bind 3903 → 10992 → 3911, 3911 → 11309 → 3918,
and 3918 → 11313 → 3922; body 3922 calls session 3869 at 204. The foreign lender's
BLX and typed synchronous source callback, then root/semantic/canvas/storage loans,
keep both counted outer frames live. Postcallback same-inventory checks, retirement
and destruction require their continuation. Session early=0, nonnil reuse and the
second host select the stale path; no mutually exclusive branches or overlapping
logical observations are added as separate stack allocations. Uncounted lender,
forwarder, outer-entry, deeper and IRQ frames are additional costs, not zero claims.

Full retained backing plus this simultaneous stack alone is **209,968 bytes**, or
**13,360 over** the unchanged governed 196,608-byte application RAM ceiling
([resource authority](../../../../../../docs/iterations/iteration-003-review/candidate-go-no-go.md)).
No other-RAM assumption is needed. The old conditional 53,632-byte main-stack
maximum is also below this lower bound, but is not current-image evidence. Current
ELF/allocator/timing and complete main/IRQ maxima remain unproved; those unknowns
cannot rescue this necessary sum under the same compiled-object/link recipe.

Stopping the 202 omitted compiler controls and image build is justified: they
cannot establish resource acceptance for this realization under unchanged limits.
Tooling and measured sizing completed productively; unused tooling corrections
remain 0/2 and authorize no representation optimization or limit change. Historical
repair allowances remain closed. P08, all nine SO criteria and R07/T8.1/HC-RD-003
remain open; historical full-suite/image successes stay historical.

The next decision is a separately bounded physical-realization proposal targeting
the retained construction/reuse/fingerprint homes while preserving all identities,
64-record observations, one baseline and cleanup, or an explicit resource-authority
review with complete revised costs. No proof here requires a contract change, and
no proposed higher numeric ceiling or automatic source variant follows. Another
stack-only adjustment cannot make this current realization fit governed RAM.

This bounded review read existing source/object/proof records only. It performed
no source edit, compiler, test, build, runtime, image or hardware invocation.

# R03 native result — 2026-10-12

PASS2,696,981 assertions/zero failures,23/23 checks. Both actual native hosts
run old three-retry terminal and an additional fresh endpoint nonretryable
terminal instance. Every successful instance now replaces a backpressured intent
with a newer published semantic revision/count0 and superseded event, followed
by a fact/action-free accepted recovery without another application mutation.
Immediate endpoint refusal returns exact nonRetryableRefusal(endpoint), performs
one newly sealed mutation, invokes no stream body, clears intent, cancels capture,
and disables input/wake. Post-terminal submissions and paced service remain
unavailable without runtime invocation. Existing unused terminalRetry Bool is
only a fixture selector; no layout/API/production behavior change.

Attempt1 preserves exact compiler typo: FrameOfferDisposition has no
endpointRefused member (FrameStreamResult spelling). One test-only correction
to .nonRetryableRefusal narrows this cause and attempt2 passes. No recurrence of
an exhausted compiler shape. Historical helper2/2/B031/1 stay closed.

Format exits0/no edits; authored diff whitespace check passes. All496 pins pass
preflight. Existing command/input/check identities in [attempt2](attempt-2/invocation.json)
and [summary](attempt-2/result-summary.json); full exact reports/logs, source
patch and artifact hashes are adjacent. Generated binaries remain in
`.build/contracts/p08-counter-ibs389qo`. No dependency/compiler refresh or target
build. R04/R05 and independent P08 exit remain open; P09–P12 pending.

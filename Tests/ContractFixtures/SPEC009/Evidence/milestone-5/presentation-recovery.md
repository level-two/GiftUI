# SPEC-009 T5.6 Presentation-Recovery Evidence

The recovery matrix exercises every configured retryable-refusal maximum from
`1...255`. Each value below the limit remains pending with the exact checked
count; equality clears the intent and becomes terminal. An injected maximum
stored count proves checked increment failure cannot wrap or request a wake.

Retry exhaustion, both non-retryable refusal origins, and required-facility
loss all clear the pending intent and captured action, mark presentation intent
unavailable, quiesce presentation-coupled input, and exclude paced retry from
the residual-policy boundary. Facility loss before candidate allocation leaves
the frame not produced, while loss afterward aborts it and reports the exact
required-facility error.

Presentation admission remains closed after every terminal transition. Only an
explicit host reassembly reopens it; reassembly does not restore a capture,
pending intent, refused payload, or candidate.

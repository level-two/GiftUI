# SPEC-009 T7.4 Recovery and Signal Analyzer Corpus Evidence

Seven recovery cases distinguish backpressure from retryable refusal, retain or
checked-increment counts exactly, exercise first/below-limit/at-limit behavior,
supersede older pending revisions, pace only at a later idle opportunity, and
make non-retryable refusal, exhaustion, and facility loss terminal and
quiescent. The Signal Analyzer case records 80 explicit timestamps split into
four 250 ms windows of exactly 20 facts. Each window produces one coalesced
wake, publication, and offer, with one pending intent as the high-water mark.

# Scheduled opportunity evidence

`HostScheduledOpportunityController` binds the immutable validated assembly
report to the fixed-size wake/pacing state and calls `MVPHostInstance` only
from a serialized scheduled service entry. Fact and dirty wake recording
returns before runtime entry. Lifecycle and report mismatches invoke no owner;
just-before boundary waits and the exact boundary runs.

The integrated sustained fixture admits 80 ordered transition facts at 12,500
microsecond spacing, applies and reports every fact in order, coalesces wake
requests to four, and performs exactly four derivations at 250,000-microsecond
boundaries. Quiescence rejects all later wake and runtime service.

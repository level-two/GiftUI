# Endpoint health and reconstruction evidence

`HostEndpointHealthController` observes the live endpoint-owned health value;
it retains only monotonic counters and never creates a second mutable health
owner. A post-acceptance failure is exposed for residual routing only after
presentation responsibility transfer, one-shot draining, and the endpoint's
health update are all observable. The resulting mandatory-effect set includes
stream drain, health update, and presentation-coupled input quiescence.

The focused tests distinguish transport unavailability from a backend
invariant, reject missing drain/transfer evidence and counter regression, and
make the controller terminal after either failure. All approved restart causes
-- terminal unavailability, identity exhaustion, graph, resource, extent,
policy, or other immutable-configuration change -- produce only a fresh-host
construction requirement; the controller exposes no reactivation path.

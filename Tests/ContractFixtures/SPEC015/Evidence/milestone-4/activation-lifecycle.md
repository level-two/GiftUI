# Activation lifecycle evidence

`HostActivationControllerTests` embeds the production activation controller in
a concrete `MVPHostInstance` fixture with a finite inline failure sum. The
fixture proves the seven activation operations run in their specified order,
each operation preserves its original failure payload, partial runtime,
observation, and source progress triggers ordered mandatory containment, and
success reaches `active`.

Repeated activation from both `active` and `failed` returns the fixture's exact
invariant case without calling an owner. The shared controller remains partial
SPEC-015 T4.3 evidence: each concrete preset must still supply its focused
activation-failure sum and live owner implementation.

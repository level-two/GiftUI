# Verified Pi deployment — 2026-10-05

The maintainer supplied suffix `.44`. This Mac reports address 192.168.55.2,
mask 255.255.255.0, gateway 192.168.55.1; the resulting target is 192.168.55.44.
Strict SSH verification against saved alias `giftui-pi.local` succeeds. The
[target identity](identity-before.log) reports `armv6l` and hostname `giftui-pi`.

Stable command:

```sh
scripts/raspberry-pi/deploy.sh --product SignalAnalyzerRaspberryPiARMv6 --no-build --resume --host 192.168.55.44 --host-key-alias giftui-pi.local
```

[Deployment](deploy.log) completes successfully. [Deployed hash](deployed-hash.log)
matches the tested local ARMv6 artifact exactly:
`90dec11ef8cfd39480b888eb0cdef90ac9695d454ef7f9bdd12466ab7c8fa211`.
The stable tool verifies staging before atomic installation under the user's
home; no service restart is requested or performed. [Log hashes](file-hashes.json).
A separate read-only upload-progress SSH attempt timed out; the deployment's
subsequent hash/installation and this post-deployment verification succeed.

This resolves the network/deployment blocker, superseding packet 20's observed
hostname failure. Required bounded connected checks are running separately;
no task completion or iteration closure is asserted by deployment alone.

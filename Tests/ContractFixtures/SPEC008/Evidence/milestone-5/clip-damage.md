# Clip and Damage Evidence

A background fixture uses bounds extending beyond every surface edge and a
partially intersecting logical clip. The emitted fill retains those exact
unclipped bounds and carries only the checked logical-clip/surface
intersection. Moving the same clip entirely off-surface emits no fill while
the attempt still succeeds atomically.

A second fixture runs complete-surface, root-intersection, then
complete-surface damage with fresh workspaces. The headers are respectively
the exact surface, the smaller unclamped root intersection, and the exact
surface again, proving the caller-selected mode and absence of first-frame
history. Existing lifecycle coverage rejects nonzero surface origins and
tracks structural clip depth.

Run:

```sh
swift test --filter backgroundKeepsUnclippedBoundsAndOmitsOnlyAnEmptyFinalClip
swift test --filter damageModeIsExplicitAndRetainsNoFirstFrameHistory
scripts/contracts/check-spec-008-clip-damage.rb
```

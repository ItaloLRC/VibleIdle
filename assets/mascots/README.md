# Agent mascots

`ember.svg` is an editable transparent vector inspired by the supplied pixel
creature: terracotta body, cutout eyes, arms and four feet. No external references.

`catalog.json` is the source of truth. Each record has a stable `id`, name, RGB
color and pixel rows: `#` paints, `.` is transparent. Maximum32x32 cells and64
merged rectangles. Run `python tools/generate_mascots.py` after editing. It exports
SVGs here and equivalent `src/client/MascotCatalog.luau` geometry. The verifier
checks exact source coverage and rejects stale generated files.

The reusable native object is `src/client/AgentMascot.luau`:

```lua
local Mascot = require(script.Parent.AgentMascot)
local mascot = Mascot.new(parentFrame, "ember")
mascot.frame.Position = UDim2.fromOffset(18, 54)
mascot.frame.Size = UDim2.fromOffset(64, 40)
mascot:setMascot("another_registered_id")
mascot:destroy()
```

Add a record and regenerate to register another mascot. Use
`desk:setAgentMascot(agentIndex, "id")` to swap one CLI; index1 is main. Unknown
IDs return false and retain the old artwork. Invalid initial IDs fall back to
the default. STATS has no mascot. The64x40 slot (32x20 in main title) stays16:10;
different artwork fits centered inside. Parts are reused and excess parts hidden.
Instances are independent. Choices survive snapshots, purchases and layout during
the client session. No picker, server/profile fields or input listeners.

SVG is the standalone editable deliverable. Roblox uses the same rectangles as
native Frames with genuine transparent holes; no upload or image asset is needed.

Dance is a reusable cosmetic behavior: desk updates setStreak(count) from confirmed
server stats and tickDance(dt, enabled) from the existing loop. Artwork is nested
inside a fitted moving group; its outer slot stays stationary. Streak0 and reduced
motion restore neutral; paused instances preserve phase without catch-up. Parameters
cap at40 hits. Do not add independent Heartbeat/Tween/timer loops per mascot.

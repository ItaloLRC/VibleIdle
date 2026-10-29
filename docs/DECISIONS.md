# Decisions

## 2026-10-27 - Gentler pixel navigation and black framing

User asks for dynamic UI, soft text, fewer abrupt transitions and black borders.
Keep PressStart/native hit geometry and authored colors, introduce black framing
and a bounded cosmetic owner using the existing tick. Replace tall page drops
with a short once-commit fade and small reveal, animate status opacity/hover
highlights without changing money/token/skill authority. Block covered input and
restore focus on settle; reduced mode immediate. No gameplay or schema change.
See task115 and mock/native QA distinction.

## 2026-10-27 - Durable behavior metrics and bounded native analytics

User requests time per player, SELL usage, hit/miss, premium purchase timing and
each upgrade. Persist server-owned counters in the leased profile/schema18,
separate reported UI/focus estimates and retain metrics through prestige. Avoid
per-click storage/logging; aggregate native events with a budget/fair bounded
queue and isolate failure. Keep premium metric delivery in the same benefit/
proof transaction and distinguish pass ownership discovery from product receipts.
Provide server-only live/last-saved UserId reports plus documented Creator Hub
charts, no public admin remote/external collector. Never fabricate old history
or estimate Robux revenue from target prices. See task114/PLAYER_ANALYTICS.md.

## 2026-10-27 - Launch screen, guided cycle and production persistence

User requests integrity review, saved progress, start screen and an interactive
grey spotlight tutorial. Add those features with real confirmed actions, no
demo rewards, skip/replay and a single saved cosmetic preference. Local/Studio
MEMORY remains isolated; published games automatically resolve VibeIdle cloud
stores. Do not publish or activate commerce. Fix the concrete delayed-lease
clock bug and expose delayed saves. Preserve production session/receipt guards.
Native Studio and real cloud tests remain explicit release work. See task113
and LAUNCH_READINESS.md; optional next features are recorded without scope creep.

## 2026-10-26 - Readable collection pages

User asks for larger subtexts in every icon page, then explicitly asks to enlarge
icons and surrounding elements to fit the letters. Keep14px supporting text and
16px important values, expand shared card/recipe/offer geometry, reduce columns
on narrow pages and use scrolling. Stack prestige summaries/bonuses and move
reset copy into its scrollable dashboard while preserving explicit confirmation.
Keep economy/schema16 and disabled billing unchanged. See task112.

## 2026-10-26 - Ready-to-configure Robux store

The user asks for inexpensive temporary boosts/agents and a100-Robux permanent
Money+Chips bundle in the same collection style, and confirms that IDs have not
been created yet. Prepare full UI/Marketplace integration while leaving IDs0,
MEMORY and buying disabled. Targets:10 Money1h,15 Chips1h,20 run agent,100
Forever Duo pass. Actual per-player price comes from Roblox. Native confirmation
and server-only receipt/ownership authority are mandatory. Use explicit run-agent
reset disclosure and saved credits for receipts arriving at cap. Time stacks,
multiplier stays2x. Bonus-Chips accounting distinguishes boosted claims from
base entitlement instead of allowing expiry/rebuy to remint past Chips. Durable
profile proof then permanent receipt archive handles retries/crashes without
duplicate benefits; bounded CHECK reconciles existing proofs only. Preserve
isolated persistence and all prior progress under schema16; no publication or
real purchase. Setup docs link primary Roblox docs. See task111.

## 2026-10-26 - Hidden visitor amounts and larger header

The user asks for louder prestige, receipt-only fragment feedback and larger
feature/currency visuals. Multiply only vortex gains2.25, preserving player
effects/mute. Keep family/rarity on visitors, emit exact confirmed +N fragments
once through a separate bounded popup pool so actor fade/reuse cannot cut the
effect short. Do not estimate from the offer or pay from visuals. Keep zero
receipt values, pause/reduced/dedup and existing heartbeat. Enlarge icon art to
48px/targets64px and money/Chips base54/38px. Narrow screens pan one fixed-size
shortcut strip; clipping must also reject stale/covered callbacks. Retain native
currency fitting and initial CLI/Shop clearance. No economy/schema/service or
asset upload. See task110.

## 2026-10-26 - Shared collection artwork and efficient prestige motion

The user asks for Lab to resemble Cards and a slower, smoother prestige with a
vortex SFX. Extract the exact existing collection builders so both pages share
one visual source. Use a horizontal family deck plus four recipe cards without
altering crafting or inventory. Extend normal prestige to3.02s; prebuild its
168 pieces and animate parent transforms with easing rather than spending each
frame on piece geometry. Suspend redundant hidden UI work during presentation;
keep one existing heartbeat. Use three existing effect voices for built-in wind
and low tones, phase-locked to confirmed transition age and honoring mute/pause/
cleanup. No new asset upload, loop, protocol or schema. Native FPS and listening
claims require Studio and are distinct from mock regressions/previews. Task109.

## 2026-10-26 - Family fragments and deterministic Lab crafting

The user replaces cosmetic Lab tests and skill-driven appearances with random
clickable visitors, fragments and rarity crafting using fragments/money/Chips.
Use one fragment currency per family, four explicit recipes and one copy per
variant. No paid random outcome or implicit equip. New profiles start Common
Ember; protect previously granted Common cards/decks. Tier skins are authored
offline trims of each family, not uploaded art. Independent active-play polling
on the existing heartbeat avoids skill dependency and offline catch-up; server
chooses and locks every visitor reward, with expiry, nonce and bounded receipts.
Collection skills now boost fragments. Persist resources in schema15 with exact
craft Chip spend included in existing prestige accounting. Raise the cap just
enough for the entire tree/collection while remaining below integer precision
limits. Keep existing Command/read-only recovery, agent clock/locked award and
prestige transition safeguards. See task108.

## 2026-10-26 - Confirmed prestige vortex

User requests a Cookie Clicker-style full-screen vortex and return to Main CLI.
Animate the actual existing roots with reusable UIScale/rotation plus original
native spiral/core geometry, then restore under a dark veil. Start only after a
matching explicit prestige success with count+1; never from request press or
baseline snapshot. Existing correlated read-only recovery can trigger once.
Keep the original server reset/payment path, schema14 and all progression.
Input/automation waits for presentation; reduced motion is a short static fade,
and resize/disconnect/teardown restore neutral. Reuse the terminal heartbeat;
no captures/uploads, new assets/remotes or per-effect loop. See task107.

## 2026-10-26 - Radial54-node progression map

User requests a larger tree using the supplied reference. Keep old skill prices/
effects/parents and add27 functional side paths and convergence nodes. Use
original native hex geometry, existing pixel icons, branch colors, bidirectional
pan and a CORE shortcut. Total19,973 Chips requires raising the ceiling to20K;
confirmed lifetime cap8e15 supports it under the same cubic formula and remains
below2^53. Schema14 gates new IDs to their introduction, keeps old schema caps
and refuses legacy discounts on new nodes. Existing Chip balances/purchases are
not reset or refunded. New max100 streak/10x luck/19% per-Chip remain server-owned,
with old fixed awards,55/s agent cap and40-hit decorative/difficulty caps intact.
See task106 for implementation and verification.

## 2026-10-26 - Inflate production and costs together

User requests larger incremental numbers across shop/tree progression. Keep $1
first Common token; lower first value upgrade to $10 with1.4x price growth,
linear35% base and stacking10x production milestones per10 levels. Keep first
agent/context $2K/$100, raise successive growth to6x/4x. Tree prices rise to
3,200 with7,673 total below10K available lifetime Chips. Cubic prestige and
existing effects stay. Schema13 grandfathers exact old skill debits via an owned
legacy subset after validating old costs; no invented earnings/Chips/refunds.
This supersedes task103's later shop growth and task104's skill prices. Sources,
math, real-module simulation and validation are documented in task105.

## 2026-10-26 - Permanent token rarity branch

Lucky tokens I..IV cost2/8/30/100 Chips after New boot and set total special
chances to2x/3x/4x/5x base. Multiply all four special tiers equally, transferring
integer weight from Common while keeping10,000 total tickets and fixed money
multipliers. Preserve all preissued offers; unlocks affect only new drafts or
new context slots. Guide percentages describe new issuance. Reuse existing
skill ownership/purchases and core pixel icons; no new schema/profile fields.
See task104 for acceptance and validation.

## 2026-10-26 - Double agent and context prices

User direction sets the next agent price to2000 *2^(owned count-1) and the next
context upgrade to100 *2^context level. Keep the free initial agent, existing caps,
Token value prices/rewards, stored progression and frozen migration refunds.
Shared server quotes apply to all single/bulk/MAX purchases. Implemented0.60.1;
see task103 for validation. This supersedes task102's agent/context prices only.

## 2026-10-23 - Pixel font and fast letter reveal

Latest user font request supersedes RobotoMono/Arimo. Use built-in PressStart2P
(Arcade font enum), measured native token/badge widths and readable wrapped Store/
STATS content. Fast MaxVisibleGraphemes reveal uses the existing loop, keeps chip
size fixed, respects reduced motion and never gates Send or payment. No external
font/asset, per-letter event/timer or new economic behavior.


## 2026-10-23 - Fix command time and add one Send button

Latest user request permits a Send control alongside native Enter, superseding the
previous prohibition of Send. Keep +Token/Undo/Clear absent. Both controls share
finite queued composition and one dispatch/receipt path. Capture one server request
time for both advance and submit; independently sampling advance makes submission
appear backward. Fresh client queues never backdate the first token. Retain strict
server rate/context/duplicate validation, and exercise clocks advancing between reads
with different client epochs in the production-code mock harness.


## 2026-10-23 - Token pieces and explicit Store recovery

Use pooled token Frames with word labels, rarity borders/tints and multiplier badges
so object separation is visible. No listeners per piece; cache unchanged rendering.
Store Reconnect starts another bounded sync without replaying economic commands.
Validate profile/build before rendering and explain restart for mismatched Play.
Read-only Studio log showed last0.6.0 and missing-test startup failures; current
Rojo serves the fixed source. Do not claim new native QA or force a Studio restart.


## 2026-10-23 - Native CLI, STATS, startup and pixel wallpaper

Latest user steering removes the token toolbar and resource rectangle. Use a native
TextBox with authored words as individual colored labels and Enter/mobile Return.
Fast keystrokes queue at purchased typing speed; explicit Enter may finish that
finite queue then submit once. Backspace edits. STATS is a draggable CLI with money,
actual earned money/s over10s, counts, speed/context/base and tier odds/collected.
No passive income. Draw an original procedural pixel orb inspired by supplied art.

Start remotes before protected optional Studio tests. Initial readiness requires
a draft, not just balance; bounded force-sync recovers a missing initial draft.
Production-code mock harness now includes actual GameService/server Bootstrap.
Schema7 adds typingLevel, migrates1..6 to0 under leases and retains schema6 endpoints.


## 2026-10-23 - Manual money prompts and pages

Latest user direction supersedes auto dispatch, pinned main and shop drawer. Money
is earned only on explicit Send/Enter, with a context-bounded authored-word prompt.
Server-issued draft IDs and token tiers make pre-send rarity highlighting consistent
with payout while rejecting forged/duplicate/stale requests. Fixed exclusive special
odds are 1/50 x3, 1/100 x10, 1/1000 x50 and 1/10000 x250; common is 96.89% x1.
Only a draft ID and prefix length cross the submit remote. Sync/clear/page changes
never reroll; context extension appends; transient drafts/receipts are not saved.
No passive server money; global workers/agents/CPU scale prompt payout, context
increases length. Keep internal credits/schema 6 and isolated MEMORY namespace.
All windows use normal foreground stacking with covered pointer guards. CLI/Store/
Guide are separate pages. One receipt triggers one bounded solid rising/fading +$
amount; reduced motion is static. No external art/font/API/service introduced.

## 2026-10-23 - Persistent shop, pinned main and global workers

User corrections supersede 0.3.1 automatic dismissal/per-agent targeting: shop stays
open through all purchases, main is pinned above agent windows, and covered pointer
callbacks are rejected before any focus/drag/dismissal. Global worker purchase is
payload-free, debits once and increments each existing agent up to 16. New agents
inherit the minimum worker width; this defines the global level for historical
uneven valid profiles without resetting/downgrading them. Keep schema 6 and MEMORY
namespace; no real records migrated. Old targeted add_neuron protocol is removed.

## 2026-10-23 - Floating terminal desktop

The user's supplied CLI screenshot and request for independent stacked terminals
supersede the VS Code shell. Remove Explorer, use an original navy/violet procedural
background, charcoal rounded windows and terracotta accents. One confirmed agent
equals one window (max eight); workers stay per selected agent. Main CLI remains
the only input/transport/job presentation. Background windows show simulated
snapshot status, can be arranged by their titles and remain reachable through the
dock. Keep upgrades in a closed-by-default drawer at every viewport width. Retain
bold native fonts. No external artwork or copied branding/mascot.

## 2026-10-23 - VS Code-inspired interface

The user's request for a VS Code-like interface and thicker lettering replaces
VibeIdle's inherited XP palette, bevels and Arcade branding. Keep a fullscreen
terminal-led game, flat dark editor panels, blue active/tab/status details and
native RobotoMono Bold/Arimo Bold FontFaces. See VISUAL_STYLE.md. The parent
NeuralIdle visual direction and files remain untouched.

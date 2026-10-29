# Architecture

Latest0.72.0 adds one UiMotion owner on safe-inset ScreenGui26, between tutorial24
and prestige30. Existing terminal.onTick drives0.1s eased cover/once-only page
commit and0.22s reveal with8px native content motion. terminal.uiTransition
pauses edit/automation; page/desk/skill/free-space/shop/progression guards reject
covered input, no queued gesture replay. Focus defers to settle, including menu-
open reduced-motion changes. Pause freezes age; reduced mode commits immediately;
disconnect/prestige cancel without stale commit; teardown restores all values.

Up to64 explicit status labels watch Text changes for0.18s cosmetic opacity fade
and up to48 controls get passive hover/focus gleams, all with fixed bounds and
bounded listeners. Money HUD/token letters/skill dial do not use these fades.
Theme uses black native pixel rims/strokes; authored colors stay inside frames.
No per-control Tween/Heartbeat/task or protocol/economy/schema18/analytics change.
Historical callback fixtures settle presentation immediately;5 new scenarios
run actual animation, pause/reduced/focus/resize/input/cleanup paths. Task115.

Latest0.71.0 rewrites Telemetry as a dependency-injected bounded session owner.
State schema18 authors/validates/copies analytics scalars, allowlisted maps,
24 recent context entries and first premium observation; migrate1..17 to zero
metrics and preserve all fields through prestige. Existing server heartbeat
settles monotonic connected time, drains native batches every15s and logs JSON
summaries every60s/exit. FIFO64 keys,4 in-flight calls/batch,8/min tokens/burst4,
one retry and pcall failure isolation; no per-click tasks or external service.
GameService instruments accepted server transactions/results. Commerce adds
optional protected hooks; receipt delivery metrics share the benefit/proof save,
so retry/archive/reconcile do not recount. Pass discovery is labeled separately.
Native monetization remains the revenue authority; telemetry never grants.

analytics_pulse accepts only bounded requestId/button/enter, focused bool and
allowlisted page. Existing client tick batches cumulative UI counts every15s;
server dedup,10s gap,120 delta caps and25s focus freshness mark these as estimates.
Pulses return before gameplay advance and cannot mutate awards/clock budgets.
ServerStorage.VibeIdleAnalyticsReport is a server-only BindableFunction returning
deep-copied live totals/session or read-only last-saved DataStore data, never a
client remote or profile lease/write. Logs contain UserId/session ID, no chat,
name/IP/location. Config SEND_ANALYTICS enables published native events only;
ANALYTICS_LOGS controls summaries; profile counters remain. Task114/guide.
Gameplay snapshots omit analytics entirely via State.copy(state,true), avoiding
history copying/replication on every skill/agent response. Client fromSnapshot
validates the same gameplay schema with local empty metrics; storage still uses
strict fromStored and rejects a missing analytics field. Reports keep real data
server-only and deep-copy it on demand. No client history/admin reporting path.

Latest0.70.0 adds client Onboarding on safe-inset ScreenGui24, above skill22 and
below prestige30. Four native masks leave the current action clear; a stepped
pixel dialogue owns skip/completion. Start mode pauses terminal edit/automation;
tutorial suppresses auto checks/sales, gates covered actions and pages, hides
Shop, positions the real circle/SELL/one real actor for readable guidance. Skill
and sale advance only from existing matching receipt reconciliation; visitor
advances only for a clicked ID and its confirmed fragment receipt. The actor's
cosmetic position is restored on skip/expiry; source ID/reward/timing unchanged.
Onboarding ticks through terminal.onTick, owns no listener/timer/remote/reward.
Guide replay and disconnect/readiness/resize/teardown use existing owners.

Schema17 validates boolean tutorialDone, migrates1..16 as false, deep-copies and
preserves it on prestige. Strict tutorial_complete/requestId is cosmetic and
idempotent, with no payment or progression nonce. GameService resolves a copied
config to DATASTORE only outside Studio with published GameId and explicit
PUBLISHED_STORAGE_MODE; local default MEMORY and disabled commerce remain.
Published namespace is VibeIdle_Profiles_v1, never NeuralIdle. Existing autosave/
exit/concurrency path now exports read-only persistence status/lastSavedAt.
Repository acquire/save read the clock inside every UpdateAsync callback, so
network delay/retries cannot validate an expired lease with a stale timestamp.
Cloud failures never install an overwritable default profile. See task113.

Latest0.69.0 is presentation-only. CollectionStyle owns192x304 shared cards,
144px medallions and96x60 portraits. CardsPage/Lab expand their content extents;
Lab recipes use160x100 portraits, RobuxShop uses96px icons and456px offer cards.
PrestigePage stacks summary/bonus fields below520px, scrolls reset copy with
its dashboard, retains a sticky deliberate action and64px skill icons. Native
14px support text/16px values replace small captions. Existing listeners,
heartbeat, clipping/input guards and all schema16/server/commerce paths remain.

Latest0.68.0: PremiumRules authors four offers and deterministic duration/agent
benefits. Balance.premiumMultiplier is the shared2x cap. Schema16 strictly
validates premium Unix expiries (<=2100), cached pass bool, saved agent credits,
bonusChips and <=256 unarchived receipt proofs. Migration1..15 creates no premium
entitlement and preserves all progression. Prestige preserves premium metadata;
baseClaimed =totalClaimed -bonusChips prevents duplicate boosted claims. Current
caps permit20,800 base +20,800 bonus; validation keeps exact Chips+skill/craft
spend ==totalClaimed and the base lifetime threshold. PromptSession uses captured
server Unix time at sale for money2x; capped unpaid amounts never earn lifetime.

CommerceService is dependency injected and installs one ProcessReceipt handler.
Live readiness requires explicit enable +DATASTORE +published universe outside
Studio +valid distinct IDs. Server prompts accept only authored SKU/requestId.
Profile mutation during receipt/save is guarded; a pending proof and its benefit
share the leased profile save before a permanent per-PurchaseId archive record
is written. Then proof can prune and PurchaseGranted return. Failed saves retain
local benefit/proof without regrant on retry; archive failure retains saved
proof for reconnect. Archive reads use UpdateAsync to avoid stale GetAsync cache.
Concurrent/busy/unknown/absent/invalid/lease-lost receipts defer. CHECK and join
reconcile at most4 existing proofs without granting anything new. Pass ownership
is queried server-side; native product prompt closure never grants consumables.
Record receiptBusy blocks mutations and client generation, close waits for both
receipt/save, and normal saves do not overlap receipt writes. Agent clocks begin
when confirmed state becomes live. Separate isolated VibeIdle receipt namespace;
default MEMORY, IDs0 and disabled config remain unchanged.

RobuxShop shares collection trim/panels/fonts/backdrop, one highlighted full-width
pass card plus three responsive product cards. GetProductInfoAsync runs locally
on configured IDs for per-player prices; unavailable/invalid prices disable buy.
Native prompt request, check and credit redemption use strict existing Command
actions. Single pending UI correlates status IDs, times out to explicit CHECK
and never resends a paid action. Server snapshot Unix time drives countdowns in
the existing tick. Fifth generated feature icon extends the native shortcut
strip; full page/clip/input/pending/blur/teardown safeguards remain. Task111.

Latest0.67.0: StreakAvatar's resource caption contains family/rarity and no award
amount/FragmentBonus attribute. BackdropDancers.showFragments accepts only the
matching current actor receipt, nonnegative bounded integer fragments and a
per-activation collectionShown latch. A separate prebuilt10-label passive pool
on the same DisplayOrder21 layer outlives the0.65s avatar fade/reuse; each0.9s
popup displays the exact receipt integer, including zero, rises up to40px and
fades text/outline. Normalized origin and clamped placement support resize.
Existing Dancers tick advances only eligible CLI effects; hidden/blurred states
hide/pause without catch-up. Reduced mode removes rise, retaining fade. Expiry,
rejection and repeated snapshots cannot emit; destroy owns all labels. No new
loop/input/remote/profile or payment path. Vortex source gains multiply2.25;
voice/phase/mute/failure safeguards stay.

Bootstrap's feature dock becomes one clipped horizontal ScrollingFrame with
64x64 targets/48px integer3x art, fixed76px spacing and bounded canvas pan. Native
scrolling supplies narrow access; pointer callbacks require both button and
viewport containment, and the entire visible strip rejects covered CLI/free-skill
input. Existing hover guards include the scroll viewport.54/38px MoneyHUD text
fits up to480px/120px header, with native measurement on narrow screens and the
same confirmed snapshot authority. Initial Main CLI and Shop clearance derive
from the larger header; compact shortcuts clear the bottom skill surface. No
schema/economy/asset changes. See task110.

Latest0.66.0: CollectionStyle extracts Cards' passive card/medallion/caption/panel
builders for both CardsPage and AgentLab. Existing card properties/geometry stay;
Lab has nine fixed128x176 family cards in a clipped horizontal scroller and four
responsive396px-high recipe cards using the same art. Reused previews retain
input/pending/clip safeguards; family selection remains local. The Lab title tag
and striped background follow Cards. No asset/economy/protocol/schema change.

PrestigeMotion extends normal phases to2.1/.12/.8s, with smoothstep easing.
PrestigeTransition builds144 spiral strips and24 core spans once per start, then
changes parent Rotation/UIScale instead of recalculating their geometry each
frame. Continuous positions avoid pixel quantization in motion. Individual part
visibility changes only at phase boundaries. CardsPage layout callbacks freeze
through collapse. Terminal's existing heartbeat delegates only presentation/audio
while paused; Bootstrap skips unrelated hidden-page/mascot/skill housekeeping.
Restore/cover, input shield, snapshot confirmation/dedup and reduced mode remain.
No added Heartbeat/RenderStepped/Tween/timer.

Soundtrack supplies vortexCue/vortexMix. AudioController uses three of the six
existing effects voices: built-in action_falling.ogg wind (verified in the local
Roblox content) and two volume_slider.ogg tone layers, looped only during the
transition with continuous pitch/gain envelopes. Initial three-source preload
is best effort. The same confirmed transition start ID watermarks the SFX.
Audio phase follows transition age, not elapsed pause time. Muting/effects0,
pause/disconnect/early finish/failure/teardown stop voices without replay on
resume or snapshots; reduced fade uses a quiet short version. See task109.

Latest0.65.0: Balance owns nine families, four crafting tiers and36 definitions.
AgentCrafting validates quote/affordability and atomically debits fragments,
credits and Chips, then grants owned/crafted IDs. craft_card accepts identity
only via existing Command, shares progressionSequence/reply/prestige_sync and
never retries paid actions. Schema15 stores dense nine-family0..1e6 fragments
and a true-only crafted ownership map. Exact chips + skill costs + authored
crafted costs == claimed; rarer owned cards require a crafted entry. Legacy
schemas cannot contain variant IDs or exceed historical ceilings. Old Common
ownership/decks stay, migrations invent no fragments; schemas1..10 retain their
historical nine starters. Prestige copies fragments/crafted ledger.20,800 Chips
and8,998,912,000,000,000 lifetime remain below2^53.

StreakCollectibles.poll/collectFragments/expire implement live visitors; old
issue/collect remain historical pure fixtures only. avatar_poll shares12/s
collector limiter, carries a monotonic ID, accepts at most one scheduling step
per.75s and resets5..10s deadline after gaps>2.5s. Server random family/tier,
fragment boost, ID,24s expiry and normalized position are locked at spawn. Fixed
pool10; bounded64 collection receipts dedup without adding again. avatar_sync
only reads; no reroll/recollection. Skill paths never issue visitors or clear
resource actors on loss. Existing Dancers heartbeat polls once/s while eligible;
resource StreakAvatar objects retain multicolor art, fixed mellow dance and
family/rarity/fragment badge, fade on removal/expiry. No new loop or remote.
Lab reuses13 static previews, gates clip/page/pending/focus/input and exposes
four recipes and Cards navigation. Cards/roster resolve variant IDs to native
art. Offline catalog generator expands authored rarity trim recipes into27
SVG/native variants and checks cutout preservation. See task108.

Latest0.64.0: PrestigeMotion supplies bounded cosmetic phase/spiral math;
PrestigeTransition owns four reusable UIScales,144 passive spiral strips,24
stepped core spans and a DisplayOrder30 full-screen input shield/veil. The
existing terminal tick advances it; there is no new event loop/Tween/task/input
listener. A passive opaque backing under the wallpaper prevents world exposure.
PrestigePage retains pending action/baseline count locally, emitting a confirmed
event only on a matching successful reply. Bootstrap additionally requires a
prestige action and count+1; snapshot validation/order still precede rendering.
Initial sync/unrelated/rejected snapshots never play it. presentationPaused
blocks composing/agents/skills while responsive layout freezes during collapse;
transforms restore under cover before switching to CLI and refreshing layout.
Reduced preference changes neutralize immediately, pause has no elapsed-time
catch-up, and resize/disconnect/destroy restores all owned transforms. No server,
schema, reward or remote changes. Mock tests verify contracts; actual UIScale/
rotated GUI rendering still needs Studio. See task107 and its API references.

Latest0.63.0 / schema14 adds27 Balance.PRESTIGE_NODES with introducedSchema14 and
no legacyCost. State validates each node's introduction, original schema ceilings
and exact mixed debit accounting. Legacy flags require an owned allowed node
with a real legacyCost; old schema13 envelopes migrate under unchanged leases.
No automatic Chip claim or current-price rewrite. MAX_LIFETIME_EARNED8e15 remains
below2^53 and the cubic ceiling20K makes all19,973 Chips of content reachable.
SkillTreeLayout is a pure authored radial placement/hex/link renderer contract.
PrestigePage builds passive geometry once, shares existing page input/pan and
request/reconciliation lifecycle, and preserves fixed native node sizes during
resize. No extra heartbeat, remotes or external artwork. Tooling/Studio/CLI tests
include the new pure module; tools/preview_skill_tree.py emits an offline native
geometry proxy with approximate type, never a claimed engine screenshot.
See task106.

Latest0.62.0 / schema13: Balance.valueMultiplier bounds the10x-per10 milestone
power before exponentiation. PromptSession.baseReward uses it for authoritative
payouts and the existing shop preview; final base also caps at MAX_CREDITS.
Geometric costs remain shared in UpgradeRules, including atomic bulk/MAX.
Tree nodes hold current cost and frozen legacyCost. State.fromStored validates
pre13 Chip accounting using legacyCost, then records legacyPrestigeSkills for
exact old/new debit accounting. Current profiles require a valid boolean legacy
subset of owned allowed nodes and chips + correct spent == prestigeClaimed.
State.copy/Prestige.ascend deep-copy this map; new buys never add legacy entries.
Repository accepts schema12 envelopes under the existing lease checks. No direct
paid retry, currency rebase, refund or reward from time/UI. No new remote/loop.
Models use actual live modules plus an explicitly frozen0.61 reference; reached
flags distinguish24h horizon failures. See task105 and build/inflation-*.csv.

Latest0.61.0 adds four authored luck nodes to Balance.PRESTIGE_NODES and resolves
the highest owned rarityBoost through Balance.progression. PromptSession.tokenWeights
keeps10,000 integer tickets by multiplying special weights and reducing Common.
Both server draft builders use these weights only for missing/new offers; existing
offers/awards survive unchanged. SPECIAL_TOKENS and denominator fields retain
canonical tier metadata/baseline odds; live Guide percentages use tokenWeights
on validated snapshots. No new payload/profile field, schema or persistence path.
PrestigePage extends its existing passive tree to1632px for column5. See task104.

Latest0.60.1 updates Balance's agent/context bases to2000/100 and their live
growth factors to2. UpgradeRules.quote remains the shared source for server
purchases and shop previews, including successive bulk/MAX costs. Token value
pricing/rewards, frozen historical migration refunds and schema12 stay unchanged.
See task103; task102's agent/context prices and model are historical.

Latest0.60.0 / schema12 implements real run and permanent progression. Context
is8..64. Token value has no former20-level gameplay cap, with geometric costs
and a milestone factor every10 levels. Eight lifetime-earned stages add cash
and survive resets. Cubic prestige grants only new Chips; every claimed Chip
adds5% cash including spent Chips, evolvable to12%. The23-node permanent tree
adds cash, agent speed, stronger clickable-agent buffs, Auto sell and automatic
skill checks every2s. The GLOBAL streak cap starts5 and grows10/15/20/25/30/
35/40/50 through the tree; manual and collectible sources share the cap. Auto
checks issue no words, human grades or collectible rolls. Auto sell queues only
on a fresh accepted agent grant filling context; one flight, collection generation
lock, focus/menu/chat pause and no paid retry remain. Feature-page automation
continues. Schema12 migrates1..11 and refunds removed context levels once at
frozen historical prices. Pixel tree grab-pan, cards, native art, MEMORY namespace
isolation and existing heartbeat remain. See task102 for formulas, sources,
model assumptions and verification; older entries below are historical.

Latest0.59.0 enlarges current tokens by1.5x: words18px, multipliers15px,
chip height33, row35, padding/gaps9, corners5 and9x24 caret/inset5. Shared live/
sold metrics retain native width measurement, wrapping, pooled objects and all
tokens. Keep the wider Main CLI, vertical growth/outer overflow, unrelated fonts
and all sale/generation/rarity/streak safeguards. No global scale, asset, input,
loop, protocol, server/economy or schema change. See task101.

Latest0.58.0 increases the currently reduced tokens by roughly1.2x, rounded
to native pixels: words12, multiplier10, chip height22, row23, padding/gaps6;
restore3px corners and6x16 caret/inset3. Share live/sold token metrics, measured
widths/wrapping, placeholder and input. Keep Main's wider88%/1040px policy,
pooled objects, all tokens, vertical growth and sale/reveal/rarity safeguards.
No global scale, art, listener, loop, gameplay, protocol, economy or schema change.
See task100; this supersedes the token sizing from task099 only.

Latest0.57.0 widens Main CLI to88% of the initial workspace (cap1040px), up
from66%/760px, preserving320px minimum, centering, full-root dragging under shop
and vertical-only growth for tokens. Reduce token appearance to roughly80%,
rounded native pixels: words10px, multipliers8px, chip height18, row19, padding/
gaps5, corners2 and caret5x13. Share metrics for live/sold tokens, measured badge
widths, wrap, placeholder and read-only input. Keep pooled objects, all tokens,
rarity/streak rewards, reveal/sale locks and unrelated UI fonts. No global scale,
assets/listeners/loops, gameplay, protocol, economy or schema change. See task099.

Latest0.56.0 adds cyclic1X/5X/10X/25X/MAX to the shop. Show aggregate ascending
prices and batch previews. Fixed batches clamp only at caps and require the full
price; MAX also clamps at the current balance. Server Rules.quoteMany/purchaseMany
plan privately and grant/debit atomically, bounded25. Only{requestId,quantity}
on existing three upgrade actions; reject trusted prices/counts/targets. Keep
legacy nil singles for fixtures. Session-only upgradeSequence/reply deduplicates;
one client flight and correlated upgrade_sync checks never retry paid requests.
Remove AUTO and shop Reconnect; Guide Reconnect performs read-only recovery.
Unavailable shop text is red; grey/orange/gold card states remain. Accelerate
sale press to0.16s and ordered token collection to8..45ms/token (max16/tick,
about1s for128), preserving generation lock/dedup and server-only payout.

Skill-tree nodes grow280x176 with48px icons,16px titles/buttons,13px mock notes,
256x52 unlock buttons,6px borders/branches,328/232 strides and976x912 canvas.
Tree heading22px/wallet16px; retain native readable text, grab-pan, clipping,
root centering, saved/clamped pan, states/costs and all drag/purchase guards.
No new art, listener, loop, money source, profile/schema or persistence change;
new upgrade request fields/read-only action are bounded server-authoritative.
See tasks097/098; prior page animation and unrelated UI remain.

Latest0.55.0 animates the four top-icon pages (Lab/Cards/Tree/Prestige) with a
0.28s cubic downward entrance, light2..6px landing bump and2px rebound, settled
by0.44s. Translate the existing fixed-size Pages frame at integer pixels and
clip to the root; native control geometry follows. Hide other workstation UI
immediately and keep Back fixed/accessibly above the entering page. Only top
icon actions start it. Back/page changes/resize/teardown reset; reduced motion
skips or finishes immediately, and blur/menu/chat/modifiers finish next tick.
Use existing heartbeat, with no new listener, tween, task, art, geometry, remote,
profile or economic change. Off-page agents/receipts remain. See task096.

Latest0.54.0 removes the three shop pixel-art icons and their hover hooks;
keep the four top navigation icons and all other art. Increase shop native type:
title/price14..16, stats14..18, SHOP18..22, Reconnect13, quantity16 and AUTO12.
Use full-width stacked text rows, measured current/next wrapping and taller
strips with existing scroll; narrow shop is176px. Wallet money40/Chips28 have
existing thick black outlines in an up-to400x90 area. Fit large numbers only as
needed and compact Chips with the shared number formatter. Stacked feature rows
and any horizontally overlapping shop sit below the taller wallet. Preserve
shop colors/press/audio/purchases, full-root CLI dragging and all sale locks.
No assets, economy, protocol, schema or loop change. See task095.

Latest0.53.0 adds eight short gesture sound families with four local pitch
variations: skill, shop, navigate, back, select, sell, collect and confirm. Wire
after existing guarded user callbacks, never from snapshots/reconciliation or
automatic page setup. Accepted SELL intent sounds once; duplicates cannot queue
sounds or payments. Preserve independent confirmed Good/Great and rare coin cues.
Use existing two built-in sound assets,6 effects voices, effects volume/mute,
existing envelope tick and teardown. No gameplay RNG, new assets/IDs/listeners/
loops/remotes/schema/economy changes. See task094; listening QA stays in Studio.

Latest0.52.0 lets Main CLI drag beneath the fixed foreground shop using the
full root width; keep its initial left composition and native text size. Covered
CLI pointers must reject focus, drag and SELL before state changes. Whole shop
strips use snapshot/quote-driven grey (unavailable), orange (affordable), gold
(MAXED) palettes. Only affordable rows dispatch purchases, still server-priced.
A click presses/rebounds the passive face within0.22s using the existing tick;
input bounds stay fixed and reduced motion/page reset restore neutral. Keep gold
icon hover, scroll, sale lock, progression and all nonce/payout safeguards. No
new geometry, asset, loop, protocol, schema or economy change. See task093.

Latest0.51.0 makes clickable navigation/shop icon contours gold on mouse hover,
then black on leave. Recolor only existing passive outlines with pixel gold;
keep authored colors, integer scale, border thickness and fixed click bounds.
Use native mouse enter/move/leave on the actual feature button/shop strip and
existing heartbeat for eligibility; disabled/hidden/clipped/covered/menu/blur/
drag states cannot highlight. Page changes clear hover; existing teardown owns
all listeners. No extra animation, geometry, loop, remote or gameplay action.
See task092; sale-generation locks and all progression remain unchanged.

Latest0.50.0 adds strong black native silhouettes to top/shop icons, preserving
integer authored colors and fixed hit bounds. Explicit SELL freezes generation
through queued writing, uncertain payment and the entire sequential collection,
including paused/off-page collection; resume only after the last sold token.
Repeated presses never queue another sale. SELL's existing passive pixel face
presses/rebounds within0.27s through the existing tick, with static reduced motion
and immediate page-pause reset. Captured rarity selects five short rising coin
chimes with quiet special-token harmonies; keep6 effects voices, dedup, mute and
server-only payouts. No new assets, remotes, profile fields, loops or server
clock/economy changes. See task091; this supersedes simultaneous collection and
new-context generation from task070.

Latest0.49.0 restyles the shop as3 broad stacked pixel strips based on the
supplied reference: malva token-value row, coral agent/context rows, stepped
lilac borders/highlights/shadows, upper-right prices/MAXED and current > next
values below. Each full strip is one buy target; keep original3 actions, quotes,
caps and server-only purchase authority. Next base value uses existing pure
PromptSession.baseReward, never Simulation.advance or a client payout. Preserve
Reconnect/read-only recovery, scroll and narrow readable layouts. Passive1X
and AUTO category badges describe single purchases/agent automation; no bulk or
auto-buy control is introduced. No schema/remote/asset/loop/economy change.
See task090; other pages retain their current designs.

Latest0.48.0 further polishes Agent cards toward the supplied collectible-card
reference and prestige screen. Shared128x176 deck/inventory cards use stronger
rose/terracotta framing, gold corner fittings, ivory clasps and dark shadows.
Original80x50 agent portraits sit in static96px stepped medallions with authored
per-character colors; these colors add no rarity/buff semantics. Gold value and
mint/coral speed/tradeoff labels sit in a separate dark plaque. Keep source buffs.
Full-screen Cards has prestige's subtle cached256-part diagonal backdrop,
terracotta title tab, shadowed plum/lavender section panels and native pixel text.
Center deck/inventory rows, keep8 ordered positions, plus/locks, selection and
native scroll/clipped callback bounds. Existing select/equip/remove nonce/sync,
profile schema, currencies, automation, remote and heartbeat rules stay unchanged.
See task089. Reference art guides style; original agent art remains native.

Latest0.47.0 further polishes prestige toward the supplied reference. Use a
subtle stepped diagonal backdrop (bounded256 passive parts, resize cache),
terracotta title tab, deeper plum panels with lavender highlights/drop shadows,
shadowed off-white/gold/mint text, and original gold star Chip art. Center the
icon/gain pair by measured text width instead of a half-width label. Larger
summary/bonus figures, responsive dense/roomy native layouts and progress framing
retain readable mobile type. Reset action/review remain fixed below the scroller;
validate pointer against its visible action bar and keep two-step confirmation.
Tree, cards, economy, schema, remotes and heartbeat remain unchanged. See task088.

Latest0.46.0 follows the now-readable layout/reference images: centered draggable
Main CLI in the left workspace, wallet at top-left,4 pixel feature icons above,
3 compact upgrades centered vertically on the right, Studio tools in the dock.
All feature/Guide/Tools destinations are full-screen pages: hide workstation,
shop, HUD, feature icons, dock, skill dial and celebration layer; own pixel Back
button restores Main/draft. Hidden shop/dock/feature callbacks reject actions.
Automatic agents retain normal off-page production and all receipt/nonce guards.
Prestige uses original native pixel Chip art, two wallet/per-Chip panels, gain,
next-Chip progress and current/after permanent bonuses. All numbers derive from
validated snapshots and existing1% bonus; preserve two-step reset/no extra payout.
Cards use matching plum/charcoal panels, stepped violet/gold frames, terracotta
rails, larger existing pixel portraits, buff strips and selected/locked states.
Keep8 ordered deck slots,9 unique cards, existing equip/remove flow/buffs. Skill
tree grab-pan/positions remain. No new asset/upload/remote/schema/economy/loop.
See task087; supplied art is aesthetic guidance, not copied/imported artwork.

Latest0.45.0 makes the mock skill tree native pixel art:8 authored8x8 icons,
stepped4px node borders, pixel price buttons,4px orthogonal branches and a passive
pixel grid. Keep all8 mock skills, Chip costs, parents and server confirmation.
Tree navigation uses held mouse/touch grab-pan in both axes with a6px threshold,
bounded CanvasPosition and no scrollbar/native scrolling. A drag release cannot
unlock a skill; a new click or gamepad activation may. Preserve position across
pages/snapshots; first opening reveals the root and resize clamps the viewport.
Reject covered/menu/chat/modifier/blur starts; cancel on page exit, blur, resize,
menu or teardown. Disconnect the bounded input listeners; use existing tick only.
Prestige keeps its normal scroll behavior. No economy/schema/assets/remote/new
heartbeat change. See task086.

Latest0.44.0 moves Studio tools from the fixed shop into its own scrollable
page, opened/toggled by the bottom Studio tools shortcut replacing Store.
Studio-only visibility/remote guards remain; published sessions have no tools
page or active shortcut. Keep the right shop limited to the3 normal upgrades
and Reconnect. Tools have independent scroll preservation, full-size +/- rows,
responsive dock widths and gamepad focus. Hidden/collapsed/menu/blur/drag/clipped
pointer callbacks reject. Returning Main CLI retains unsold words; checks pause
on Tools and automatic agents retain normal page behavior. No server/economy/
profile/assets/new loop change. See task085. The attached visual reference
rendered entirely black; broader visual restyling awaits a readable reference.

Latest0.43.0 compacts CLI tokens:13px words (from15),10px multiplier badges
(from11),22px pieces (from24),24px row pitch (from28),6px gaps/padding.
PromptComposer.TOKEN_STYLE supplies both measured wrapping and native live/sold
piece geometry, preserving readable PressStart2P text, rarity badges, stable
letter reveals and sequential sale collection. CLI desktop/log scrollbar tracks
are hidden; native wheel/touch scrolling and canvas bounds remain available for
large contexts. All tokens remain rendered, with vertical-only window growth.
Store/Guide scrollbars and gameplay stay unchanged. See task084.

Latest0.42.0: skill checks never write tokens. Every fresh server-graded nonce
updates streak/best/difficulty/expiry and existing audio/avatar/press feedback,
including at empty, partial and fully awarded context. Receipt wordCount is0;
checks neither create nor rewrite token awards or spend agent typing capacity.
Only AgentAutomation grants new words, locking existing rarity/card/streak
rewards at generation. Future agent output/value still follows current streak.
Client skill acknowledgement cannot append tokens, including delayed replies and
read-only syncs. Keep one shared-prefix flight, packet limits, continuous phase,
full-context guards and explicit queued SELL. Guide/welcome/empty hints explain
agent-only production. No schema/profile/remote/asset/loop change. See task083.

Latest0.41.0 enlarges top-left money/Chips to32px/20px PressStart2P with
opaque pure-black3px contextual text outlines, keeping mint/amber fills and a
black money shadow. Transparent passive HUD grows to320px max width/66px height;
long values fit responsively with stroke padding and no wrapping. Header icons
keep48px targets, move below HUD when needed, and use52px rows on short screens.
Compact prestige/tree panels hide their duplicate wallet header to retain room
for action controls; currency remains visible in the global HUD. Keep validated
snapshot-only values, pointer exclusion and all accounting/schema/protocol rules.
No new asset, loop or interaction. See task082.

Latest0.40.0 activates Cards as an agent-card deck/inventory page. Always show
8 ordered deck positions; only the leftmost owned-agent count are unlocked.
Empty unlocked positions show a pixel plus, locked ones a native pixel padlock.
Nine original mascot cards form the starter collection, one unique copy each.
Select a free inventory card then an empty unlocked position to equip; select
an equipped position and REMOVE to return it. No auto-placement, duplicate copy,
card purchase/currency cost or gacha. Deck scrolls horizontally; mini inventory
sits below with its own grid in a vertical page. Preserve native sizes, clip/
hidden/menu/chat/modifier/blur/pending/gamepad guards and bounded cleanup.
Cards grant agent-specific automatic value/output/typing buffs (including shown
tradeoffs), authored only in Balance.AGENT_CARDS. Speed multiplies that agent's
cadence and purchased cap up to55/s. Retiming preserves phase and old budgets,
never refills capacity or alters another agent's clock. Total caps/output sum
actual agents; client refreshes absolute next-agent time when deck/run changes.
Card value locks into each fresh server Agent award, never rewrites old words,
manual precision/rarity or pays directly. Explicit queued SELL remains required.
Equipped card supplies the corresponding Main CLI avatar; Laboratory edits only
empty positions and restores that prior cosmetic when a card is removed. Static
card previews reuse native art; no image uploads/per-card tick/heartbeat.
Schema11 stores deep-copied cardOwned and fixed8-entry cardDeck (false for empty).
Validate allowed owned IDs, unique placement, unlocked positions and exact shape.
Migrate1..10 with starter collection and empty deck, retaining all prior money/
prestige/upgrades under leases. Prestige preserves collection and slot1, returning
cards from newly locked slots2..8 to inventory. MEMORY namespace stays isolated.
Strict equip_card/unequip_card IDs use the existing single progression nonce and
read-only prestige_sync reconciliation, no client buffs/prices/time, no automatic
mutation retry. Existing snapshot sequence rejects delayed stale inventory/decks.
No new remote or loop; no extra agent CLI. See task081 and agent-cards-verification.

Latest0.39.0 removes all background agent CLI windows. The only live window
is Main CLI; each confirmed owned agent adds one passive avatar in its roster
below the title bar (up to8). Reuse the eight AgentMascot objects/phase offsets,
48x30 art in64x50 labelled slots,72px column spacing and58px rows. Wrap the roster
on narrow Main CLI widths; reserve its height above log/composer so avatars never
cover tokens. Initial window placement clears the money/feature header; content
grows downward from its current origin and outer scroll includes its position.
Drag remains free across the full viewport, with existing foreground guards.
Purchases never create/focus another window or change Main CLI width/placement.
Live workstation geometry is count-independent; historical multi-window pure
layout fixtures are unused by runtime. Remove the CLI-cycle dock button, leaving
Main CLI/Store/Guide. AgentLab now targets agent avatar slots (not CLIs), preserving
local per-agent art choices across snapshots/purchases/resize. Streak avatars
read their source artwork from desk.agents. Retain confirmed dance/pause/reduced
motion and cleanup through the existing tick, no per-avatar input/heartbeat.
Server-owned count, independent agent typing budgets/TPC/speed, money, prestige,
profile/schema and all command/nonce/rate safeguards are unchanged. See task080.

Latest0.38.0 context growth is vertical only. Preserve Main CLI's current
responsive width while additional token rows grow the composer/window height.
Never widen it automatically to fit tokens within viewport height. All tokens,
native15px text/badges, retained grown height across sends/undo and outer desktop
scroll remain. Viewport/agent layout may still choose an initial responsive width;
context itself cannot change it. Same rule applies to sold-token collection plus
new tokens. No economy/protocol/schema/loop change. See task079.

Latest0.37.0 introduces server-authoritative prestige and Chips. Only confirmed
prompt rewards accumulate lifetimeEarned (cap1e15); purchases, idle/skill checks,
Studio money and capped unpaid rewards do not count. Total eligible Chips =
floor(cubeRoot(lifetimeEarned/1000)), capped10000; mint eligible minus the total
prestigeClaimed, never minus unspent balance. Each earned Chip, spent or not,
adds1% permanent token value. Prestige resets money/normal upgrades/agents/draft/
streak, preserves lifetime/Chips/skills, uses a current-draft nonce and explicit
review/confirm UI. No automatic prestige. Eight MOCK tree nodes have authored
costs/parent links and one-time server unlocks; they have no gameplay effects.
Schema10 strictly validates finite earnings, Chips/claimed/count, allowed skills,
all parents and exact chips+spent==claimed. Migrate1..9 with zero recorded lifetime
and no invented Chips, retaining normal progression; preserve leases and isolated
MEMORY default. New PrestigeRules/PrestigePage modules use existing Command and
heartbeat. Strict prestige/buy_skill IDs and correlated read-only prestige_sync;
no client price/amount/level, automatic paid retry or duplicate mint/debit.
A monotonically increasing snapshotSequence rejects delayed old-run snapshots.
Prestige requests preserve leased profile identity and reset receipts/independent
agent clocks, retaining challenge/draft nonce sequences. Local single-flight
progression blocks generators, bounded3 sync attempts then explicit Reconnect.
Top native pixel ascending-chip icon opens prestige; tree icon opens the actual
scroll/pan graph. Original16px multicolor art is generated from feature catalog.
MoneyHUD adds Chips below money; adaptive header stays reachable. Mock labels,
preview/reset consequences, gamepad/pointer/clip/hidden guards, and teardown stay
explicit. No new loop, external art/services, parent store, offline catch-up or
publication. Optional Studio tests start after GameService and include prestige.
See task078 and build/prestige-verification.log. Native Studio QA pending.

Latest0.36.0 permits skill checks at full context, with zero generated words.
The same skill_click/skill_sync payload can address the bounded index after the
last slot (up to129 for128 words). Server requires all context slots to already
have fixed awards, then grades/consumes the check and changes streak normally.
No award is added or rewritten; no buffer, payment or future word is created.
Preserve nonce/cooldown/packet guards and zero-word receipt dedup, including a
queued SELL waiting for the check. Existing agent words retain their locked bonus.
Shop is now three compact transparent rows separated by a subtle rule:32px
native pixel icons, name/current value and one40px price button,102px rows or
132px on narrow screens. Retain prices/caps, Reconnect/scroll and Studio tools.
Remove the STATS window/dock action/order/drag/layout/render path entirely.
Confirmed money stays in a passive transparent MoneyHUD at top-left, mint
PressStart2P text with a two-pixel dark shadow. Adapt only the text size to fit;
feature icons move to a second row when needed. Keep the amount visible across
pages, update only after snapshot validation, and block covered CLI/free-skill
callbacks over the HUD. Server statistics remain internal; Guide keeps chances.
Four-button dock, existing heartbeat/teardown and pointer rules. No new asset,
loop, remote/schema/profile field, price or automatic sale. See task077.

Latest0.35.0 keeps SELL's normal terracotta pixel face/dark label in empty,
busy, queued and in-flight states. A visible eligible CLI accepts one explicit
SELL/Enter intent even during a skill/agent confirmation or letter reveal. The
single slot stores its draft ID; repeats coalesce and in-flight repeats do not
queue a future prompt. Pause new skill/agent generation while queued, finish the
current grant and all letter reveals, then submit once through the existing
payment path/cooldown. Show SELL QUEUED; keep button text SELL. A settled empty
or failed grant clears intent without selling a future word. Backspace, leaving
the CLI, focus/menu blur and disconnect keep existing cancellation behavior.
Hidden/covered/drag/chat/modifier guards still apply. No word buffer, automatic
full-context sale, paid retry, server/protocol/schema/profile or new loop change.
Existing heartbeat reveals letters before dispatch/agents; receipt reconciliation
never dispatches recursively. See task076. Native Studio QA remains pending.

Latest0.34.0 removes the skill word buffer. Each confirmed skill click appends
its context-clamped words directly to the current draft. Full context waits for
Enter/SELL; overflow is discarded, never retained for another prompt. Presses
while a skill/agent mutation or sale is pending are not sent, stored or replayed.
Manual late receipts still reconcile once off-page. Agent clocks stay independent;
a manual reconciliation may service one due agent immediately, while an agent
reply returns control until the normal heartbeat instead of chaining requests.
Removed skill_queue, server enqueue/drain/handover state, local pendingKeys,
QUEUED status and the two Studio queue controls (26 controls remain). Read-only
skill/agent sync, fixed awards, nonce/context/packet limits, continuous phase,
manual sales and receipt-driven collection remain. No new remotes/schema/profile
fields, offline catch-up or payment path. See task075. Native Studio QA pending.

Latest0.33.0 adds a third top feature button, Skill tree, with original mint
pixel foliage, a terracotta trunk and three gold nodes. It uses the same48px
click target/32px integer-scaled art as Laboratory and Cards. Clicking selects
it, plays the existing tap and shows Skill tree / coming soon; no skill system,
page switch, profile, command or economy change is introduced. Header geometry
uses actual feature count, adapting gaps/columns while preserving hit size.
Existing Laboratory gallery, fixed shop and pointer/teardown rules remain.
Art source:assets/features/catalog.json, generated SVG/native catalog equality.
See task074. Native Studio visual/input/device QA remains pending.

Latest0.32.0 activates Laboratory as AGENT LAB, a cosmetic test page alongside
CLI and Guide, with the fixed right Shop still visible. Choose an owned CLI via
arrows, then click one of9 appearance cards. Ember is preserved; eight artistic
variations are Sprout, Volt, Frost, Nebula, Forge, Glitch, Coral and Sage. Distinct
silhouettes and multicolor themes retain the original16x10 cutout-eye language.
Cards stays a future-feature placeholder. Laboratory toggles back to CLI; the
Main CLI dock shortcut also returns. Choosing art never buys/creates agents.
Per-CLI choices remain local to the session and survive snapshots/purchases/
resize; new agents start as Ember. Reuse each live AgentMascot and its existing
dance/slot, with static reusable gallery previews and no new animation loop.
assets/mascots/catalog.json generates ORDER/taglines and exact colored SVG/native
geometry via generate_mascots.py. Original Ember retains11 rectangles unchanged.
Gallery interaction honors page/clip/pointer/drag/menu/blur guards and teardown.
No remote, saved field, schema, reward, odds or payment change. Existing streak
avatars use the selected source silhouette with their established rarity tint.
See task073 and build/agent-roster-preview.png for the roster.

Latest0.31.0 adds two always-visible top-center feature buttons in the left
workspace: Laboratory and Cards. Original16x16 pixel art shows a mint laboratory
flask with bubbles and three sequentially stacked playing cards with a red heart.
48px native stepped buttons contain32px integer-scaled passive artwork; no upload
or external font. Click feedback is selection, the existing soft tap and an
English coming-soon hint only. There are no new gameplay features, page switches,
network commands, persistent fields, money or token changes.
Controls sit above floating CLIs and remain on Guide. Their pointer bounds reject
covered CLI focus/drag and free-skill callbacks. Activation honors menu/app focus,
drag and foreground-avatar guards, and dies with the owning GUI. Shared icon
exporter checks assets/features/catalog.json SVG/native equality independently
from the three Store icons. No new heartbeat/timer/global input listener.
See task072 for acceptance/evidence; all existing sale/collection/shop rules stay.

Latest0.30.0 overrides separate Store pages and square upgrade grids. Shop is an
always-visible rectangular root panel fixed8px from the right/top, above the dock.
CLI and Guide use the workspace to its left; Store is only a focus shortcut and
never suspends CLI input, production, mascot dance or sequential collection.
Three rectangular upgrade options form a single scrollable column. Confirmed
prices/caps, Reconnect, persistent scroll and all Studio controls remain.
Original gold coin, mint/terracotta agent trio and violet context-stack pixel art
comes from the editable store catalog. Colored SVG/native rectangles are generated
and checked for equality, scaled by integer pixels, passive with no asset upload.
On narrow screens the CLI keeps a minimum320px virtual canvas and native15px text;
the desktop pans horizontally/vertically instead of shrinking the interface.
The skill surface stays within the left workspace; store bounds exclude free
background/covered CLI callbacks, and purchases retain overlay/drag guards.
Money popups stay within the workspace after resize. No economy, protocol,
persistence, schema or loop change. Enter/SELL remains manual. See task071.

Latest0.29.0 sells with sequential token collection after server confirmation.
Each sold chip disappears in order, a quiet coin cue plays, and that token's
actual +$ value rises from its position. The compact receipt adds read-only
tokenRewards copied from existing server outputs; balances, awards and payout
still settle once on the server, independent of animation. No client amounts,
new command/remote/profile/schema or automatic sale is introduced.
TokenCollection runs in the existing heartbeat, with4 receipt batches max and
at most512 lazy reused passive sold chips. Extreme rapid sales quietly finish
the oldest cosmetic batch at capacity.24 popup labels and the existing6 effects
voices stay bounded. New words/manual sales continue while collection displays;
old/new chips share readable CLI layout with temporary height growth. Pausing
pages/chat/menu/modifiers/focus/disconnect freezes collection without catch-up.
Reduced motion keeps money static; mute/effect levels and teardown still apply.
See task070 for acceptance and verification. Manual Enter/SELL remains required.

Latest0.28.0 overrides every earlier full-context auto-send direction. Tokens
are sold only when the player presses Enter/mobile Return or the CLI SELL button.
Full context stops new agent words and waits; skill words may remain in the
existing bounded queue, without payment. Queued/agent/manual receipts, snapshots,
idle frames, page/focus changes and reconnect never create sale intent. Only
sendPrompt sets sendRequested; dispatch checks intent, active input and pending
mutations. One flight and server-authoritative payout/nonce/draft safeguards stay.
The fixed96x40 SELL button uses native passive stepped terracotta rectangles,
a dark block shadow and built-in PressStart text. No smooth corner/stroke,
extra loop/input listener, external art, remote, schema or balance change.
All-token CLI growth and the three-upgrade Store remain. See task069.

Latest0.27.0 prompt visibility overrides the fixed-height token scroller. All
current tokens fit inside the main CLI composer at native15px text and full chip
sizes. Composer.windowLayout measures actual word/badge rows, expands the panel
and main window, and uses extra viewport width when height is insufficient.
Grown window dimensions survive ordinary sends/undo; responsive page/viewport
layout can reset them. Welcome/log yield space before any token row is clipped.
On small screens the complete natural terminal can exceed viewport height; the
outer TerminalDesktop scrolls as a whole, with dock/skill bottom clearance.
There is no nested token scroller, font/interface shrinking, new loop, remote,
profile/schema field or economy/auto-send change. See task068 for validation.

Latest direction0.26.0 supersedes earlier Store upgrade lists: exactly three
purchasable upgrades, Token value, Agent count and Context. Existing server prices,
limits and internal computeLevel/layerSizes/tokenLevel mappings remain. Worker,
typing, click and divisor commands are removed from the live Protocol allowlist;
their historical saved levels/bonuses and pure regression math are preserved.
New profiles keep base workers2, typing4/s, base words1 and C5. No migration,
refund, reset, new remote or storage/schema change. Store rows/columns derive
from the actual three cards; reconnect, draft/page/scroll and native font remain.
See tasks/067-three-main-upgrades.md for current acceptance and evidence.

Standalone VibeIdle 0.33.0, derived from NeuralIdle 0.11.0. Own default.project.json,
build/VibeIdle.rbxlx and manifest; no parent mappings. Schema9 adds divisorLevel0..3; schemas1..8 migrate to zero.
Schema8 clickLevel remains validated, with schemas1..7 migrating to zero.
Schema7 typingLevel remains validated; schemas1..6 migrate typing to zero.
Schemas6/7 retain input width4, older schemas retain their explicit conversion.
MEMORY is default with VibeIdle_Profiles_v1_TEST, never NeuralIdle's store.

SkillCheckController no longer excludes agentPending, composer.flight, sendRequested
or full context from fresh input. It chooses skill_queue when those conditions or
a backlog apply; otherwise the immutable draft-bound skill_click path remains.
Both accept only draftId/checkId/tokenIndex on Command and share the48/s limiter.
Queue acceptance never waits for prefix capacity: Skill.enqueue grades at current
server time using the issued check, prepares the next challenge atomically and
stores a server-owned award/count in a bounded512-word FIFO. No client word count,
grade, timestamp, amount or multiplier is accepted. Queue-full rejects atomically.
One own outstanding skill check still gates further gameplay requests, while the
button's physical squash/rebound always remains immediate. A queued check does
not reserve or block the shared terminal prefix; no delayed input intent is replayed.

PromptSession retains only the immediately submitted challenge for queue handover.
GameService bounds it to the configured prompt response window (default5s), and
enqueue requires the immediately following challenge with no intervening accepted
check/collection. A queued acknowledgement remains correlated across draft changes;
no old direct click is accepted and consumed/expired handovers reject. Queued click
receipts survive sends until replaced, enabling existing read-only skill_sync.

Existing agent_type drains Skill.drain before generating more automatic words.
Server release budget defaults128 words/s, cap16 words/receipt; each grant consumes
only fixed queued awards that fit the current draft and returns a normal nonce/
prefix receipt with queued=true. Restorations retain old awards without consuming
queued ones. Auto deadlines/budgets are not spent/reset by queue release. Client
appends correlated receipts atomically, complete text, and auto-sends only when
actual context fills. One prefix mutation/payment remains in flight; queued skill
grading is independent. Backlog survives sends/loss, pauses for chat/menu/focus,
and resets with the session. No offline production, payment retry, loop, remote,
profile/schema or asset is added. CLI title shows QUEUED N; Guide explains limits.

AgentAutomation now computes productionRate=min(server TPC/agentInterval, per-agent
typing cap). Each agent owns period=1/productionRate, nextAt, phase and ordinal,
alongside its existing one-second fresh-word budget. New agents start at purchase
time with zero budget and a stable golden-ratio phase offset. Accepted words
advance deadlines by one period with alternating bounded jitter (default6%, zero
mean over pairs); other agents, sends and ordinary clicks cannot reset the clock.
Changes in actual production rate preserve remaining phase instead of restarting.
All C calculations still use UpgradeRules.streakDivisor centrally.

Client agent requests are limited to20/s through the existing shared-prefix
one-flight mutation path and separate24/s burst16 server limiter. Source counts
can include only already-due words within a bounded transport/frame window
(AGENT_COALESCE_WINDOW0.15s). When deadlines are stale beyond that window, discard
missed cycles and resume one word per agent with phase retained; no offline burst.
Snapshots expose existing absolute nextAgentAt plus read-only current per-agent/
total production rates. Accepted words append atomically, with immediate per-word
reveal starts rather than a second paced visual queue. Terminal applies confirmed
totalAgentWordsPerSecond before receipts:2+ actual words/s or8+ TPC makes all text
fully formed and finishes active reveals immediately, including off-page. Use
actual combined output, never the purchased typing cap. Below both limits only
new words animate; Studio revealScale cannot override instant mode.
Manual input, locked award generation, nonce/sync and payment guards
stay unchanged. Existing heartbeat only, schema9 and profile namespace unchanged.

PixelSkillDial now owns passive fixed pools for the full stepped drop shadow,
dark raised base and terracotta center cap. setPress transforms only cap rows and
CLICK text, rounding local edges to pixels. Ring samples, pivot, marker and native
TextButton bounds never move. SkillCheckController immediately sets depth1 after
spatial/pause checks, before gameplay context/pending/readiness checks. Cosmetic-only
busy presses therefore react without sending another request, playing success
feedback or minting words. Existing physical-release dedup suppresses duplicate
visual pulses. Its existing tick eases depth to0 over the session's buttonReturn
duration (default0.14s); repeated presses replace this one scalar age/state.
Reduced motion or hidden/paused input clears the pose. No new input connection,
Heartbeat, task, tween, external asset, gameplay remote or persistent field.

SkillCheckController keeps two passive sibling shadow labels behind the large
TPC/Nx counters. Existing render/layout mirrors text, native font, size constraints
and boxes at a fixed3px/4px offset. Counter/circle pointer rectangles remain fixed;
shadows do not enter exclusion bounds or capture input. Small captions and their
milestone/result-feedback bookkeeping are removed. Pending CLICK text and all
server reconciliation/callback paths remain unchanged. No new loop or assets.

Balance.INSTANT_TOKEN_TPC defaults to8. TerminalController derives effective TPC
from confirmed stats.streak, clickLevel and streakDivisor before applying grants.
At/above the threshold, existing reveals finish, cosmetic agentRevealTimes clear,
and new words use MaxVisibleGraphemes=-1 without a reveal record or visual queue.
Large late manual batches also skip reveal. Falling below the threshold affects
only subsequent words; existing complete words never restart. Server per-agent
clocks/budgets, nonce/payout handling and pooled chip/badge geometry stay unchanged.

StudioTuning is the shared catalog for28 bounded preset controls, including queue
release rate and packet batch size. Only the existing
StudioCommand endpoint can cycle a recognized action with an optional +1/-1
direction; extra arguments, arbitrary values and unknown actions reject. Settings
are per-session skillSettings, outside the profile. Studio-only snapshots carry
copied effective values; clients never mutate shared Balance/Skill/Items constants.
Published sessions expose neither tools nor tuning data/endpoint.

Retuning settles agent budgets at the old rate, changes cadence relative to the
existing deadline and updates speed without minting budget/catch-up. Challenge
retiming preserves target/ID and absolute phase. Streak timeout changes retain
last actual click time; unrelated controls cannot renew it. Server enforces optional
prompt cooldown and supplies absolute readiness to the existing single-flight
client dispatch. Reset tuning preserves money, upgrades, drafts and locked awards.
Reducing spawn capacity retains live actors and blocks new ones until below cap.
Effects take instance/session timing overrides in existing ticks, preserving pools,
reduced motion and teardown. Music drops excess fast-tempo steps after the existing
two-step cap, preventing an accumulated backlog. See task060 for the control table.

StreakCollectibles.SPAWN_PERCENT centrally defines30% issuance per fresh accepted
GOOD/GREAT click. After eligibility/capacity checks, issue draws a1..100 ticket;
only successful tickets draw rarity/source and consume a collectible ID. Existing
avatar RNG stays separate from word rewards. Skips do not alter streak or its
deadline, and snapshots cannot replay the draw. Guide reads the same constant.

GameService owns money, cooldowns, rate limiting, drafts, randomness, purchases and
snapshots. Protocol accepts submit_prompt({draftId,tokens}), skill_click and
read-only skill_sync({draftId,checkId,tokenIndex}), sync, upgrade_workers,
add_layer, upgrade_compute, upgrade_tokens and upgrade_typing. Upgrades are payload-free. Reject old
string prompts, targeted add_neuron, extra fields/arguments, invalid/nonfinite counts
and IDs. Client cannot supply money, words, prices, rolls or multipliers.

PromptSession creates session-local monotonically increasing draft IDs and fixed
offers. Random.NextInteger(1,10000) selects exclusive SPECIAL_TOKENS tiers; words
come from PromptRules' canonical vocabulary. Editing/sync do not reroll; context
upgrades append to existing offers. A submission consumes the requested prefix.
Validate current ID, context and finite nondecreasing server time, calculate actual capped money, and
prepare the next draft before synchronous commit. Invalid RNG cannot partly pay.
Reset clears cursor/draft but preserves ID sequence. Duplicate/stale submissions
cannot pay twice; rejection forces the current draft back to the client.

Prompt submission has no minimum interval or acknowledgement delay. Enter/Send
and full-context auto-send dispatch as soon as eligible, with one in-flight
request. GameService's general packet limiter still bounds requests; agent
deadlines and cosmetic letter reveals do not delay submission. Legacy portable
PromptRules/PromptDraft fixtures retain their separate pacing constants.

Skill.STREAK_TIMEOUT is5 seconds. Accepted skill clicks and collectible claims
refresh session.streakExpiresAt using Workspace server time. GameService expires
it before command processing/agent grants and during existing periodic snapshots.
Expiry resets current streak/factor, invalidates collectible IDs and restores base
challenge difficulty while preserving phase, target, nonce, best and locked awards.
Client recolors same-ID difficulty updates; existing snapshot/fade/dance/music paths
reflect loss. No new loop, remote, profile field or persisted timer is introduced.

PromptRules.typingRate =4 +2*typingLevel, maximum44 tokens/s. PromptSession keeps
a session-local typing budget (one initial token, accrual at purchased speed,
cap128). Only accepted prompts consume it; time never grants money. Sync, draft
replacement or edits cannot reset/mint budget. Settle elapsed time at the old rate
before upgrading; no client clock/rate is trusted. Fast submissions reject before
RNG/payment. Studio reset clears the budget. ProfileRepository accepts schema6
under existing lease guards and saves schema7 with validated typingLevel.

Base per token is round-to-cents((1 + floor(total workers / 3)) *
(1 + CPU level * 0.35)). Sum each submitted offer's multiplier times this base,
capping each amount at remaining balance. GameService never calls Simulation.advance;
time grants no money. Simulation.batchReward remains the capacity helper. Snapshot
legacy rate stays zero; STATS uses moneyPerToken and stats.moneyPerSecond. Each successful prompt increments batches.

Compatibility mappings remain internal:

| Field/action | VibeIdle meaning |
| --- | --- |
| credits / MAX_CREDITS | money / balance ceiling |
| layerSizes[2..n-1] / add_layer | agents with worker widths |
| upgrade_workers | one worker per current agent, one global debit |
| computeLevel / upgrade_compute | global CPU multiplier |
| tokenLevel / upgrade_tokens | context length |
| typingLevel / upgrade_typing | global tokens/s for composition |
| batches | number of accepted prompts; no passive-income activation |

Global worker level is the minimum validated agent width. Quotes depend on this
level; purchases increase all widths capped at 16. New agents inherit this level.
Uneven valid profiles are not downgraded or normalized on load. Existing schema
validation, migrations, leases and unknown-data refusal remain. Drafts/receipts
are transient, never persisted. No actual store records accessed or migrated.

Snapshots include an aggregate receipt and best actual token, omitting per-token
accounting. Compact draft wire data contains id, startToken and rank array; shared
constants reconstruct words and tier metadata. Send offers only on ID/length change
or explicit/rejection sync. Heartbeat snapshots do not reroll or repeat the offers.

Client modules:

- DeskTheme: palette, built-in PressStart2P FontFace, rounded windows, controls, $ formatting.
- Bootstrap: fullscreen camera/background, CLI/Store/Guide pages, global store,
  persistent store scroll, device layout and collapsed Studio grant/reset. No resource bar.
  Hidden pages suspend terminal capture and window dragging; purchases never switch page.
- SkillCheck (shared pure model): immutable server-issued ID/start/target; clockwise
  2.4s initial phase on Workspace:GetServerTimeNow. Green72 degrees x1.5, gold24
  x2, Normal x1. Streak dynamically shrinks zones/period; grace is capped by the
  great width as well as120ms. One accepted click consumes
  the challenge; next check starts1/typingRate later. Per-word first-result map
  survives edit/sync/context append; prefix submit/reset clears it, check sequence
  survives. Invalid next RNG leaves state intact. Client sends no grade/clock/money.
  Physical clicking cannot be proven; this is server timing evaluation.
- SkillCheckController: one fixed bottom-center procedural ring with90 static
  segments, one rotating needle and CLICK label. Existing loop updates phase;
  recolor only on new challenge.120px/84px diameter in148px/112px reserved space
  above44px dock, keeping it outside desktop clip bounds. Mouse/touch only, radial
  acceptance, bounding-box pointer guard. Pending click locks edit/Send, consumes
  exactly one matching receipt; duplicate/light snapshots cannot add another word.
  After3s, correlated read-only skill_sync reconciles without repeating a click.
  Reject/sync responses carry request IDs so older replies cannot cancel newer
  clicks. Deferred word restoration waits for editing eligibility across pages.
  Input disabled during pause/full context/flights; absolute phase resumes without
  idle reward. Needle remains essential gameplay in reduced motion; no flashes.
- TerminalController: read-only native TextBox with authored words rendered as128
  reusable token Frames, child word/multiplier labels and UIStroke. Tier-colored
  text/border/background and xN badges. No per-token events/timers. Arbitrary text
  is cleared without adding words; arbitrary keyboard input cannot generate words.
  Key-down tracking prevents Enter repeats; external text/chat, processed shortcuts,
  menus, focus loss and hidden pages remain excluded. No mobile keyboard popup.
  Enter/native Return callbacks and one Send share once-only dispatch. Backspace
  edits queued/latest words. Finite accepted-word queue is paced at purchased
  speed, with bounded catch-up. One loop updates queue/reveals/skill/jobs/cash/sync.
  No dispatch without Enter/Send or automatic retry. PromptComposer validates wire
  data, context, flights and dedup; server timing/drafts/payment stay unchanged.
- TerminalDesk: one main plus seven reusable agent views, plus an always-available
  STATS window at index9. STATS joins the same order, drag, bounds and occlusion
  rules. It shows server money, actual10s earned money/s, session counts, typing/
  context/base and per-tier odds/collected counts. Confirmed agent count
  controls visibility. Every window may foreground. Before pointer focus/drag,
  check desktop clipping, source bounds and all higher window rectangles. Preserve
  return-control source identity. One shared movement/release pair handles dragging;
  normalized arrangements survive purchases and clamp on resize. No per-agent loop.
- PixelWallpaper:576 static native frames (32x18), analytic dark purple orb with
  quantized magenta/violet fill and warm lower rim inspired by the supplied image.
  No image asset, gradient animation, external font or service.
- AgentSession: immutable receipt summaries, 1.4-second simulated jobs, at most
  four pending previews, 72 bounded history lines, receipt baseline/dedup and layout.
- CashFeedback: one aggregate +$ effect per positive confirmed receipt, eight-label
  pool, ease-out rise then fade, 1.8-second expiry, static reduced mode. It cannot
  mutate money. Root overlay remains visible when a confirmation arrives on Store.
- Soundtrack: original128-step elevator/lounge score at88 BPM, bounded transport,
  soft envelopes and original
  eight-note pentatonic phrase indexed by confirmed streak; GOOD/GREAT share lead.
  Bundled Roblox timbres only; no uploaded/network audio IDs.
- AudioController: 16 pooled music voices and6 effect voices in explicit
  Music/Effects SoundGroups; music EQ/reverb and short effects reverb. Existing
  tick fades in the bed and shapes cues. 128-step fixed-tempo score clock; no streak-driven tempo.
  Immediate subdued tactile feedback; matching nonce/watermark confirms one cue,
  reused/offpage results suppressed. Menu/focus/disconnection/mute stop voices.
  Guide session-local levels, protected setup/play/preload, complete GUI teardown.
  No new listeners, per-note tasks, remotes or server money/schema changes.

Window/page selection never replays the receipt path. Initial sync/repeats/reset
never replay money or jobs. Destruction disconnects input/loop/layout/camera/settings
listeners; Instance-owned button connections die with their controls. No per-token
timers, external framework, font, artwork, real shell or AI/HTTP API.

Legacy Simulation.rate/advance, PromptDraft, PromptRules.submit/OUTPUT_TOKENS and
NetworkLayout/NetworkFlow remain portable regression helpers, outside live dispatch.
The old neural renderer is not mapped into the place. CLI and Studio runners execute
111 baseline +56 current manual-prompt/speed/stats/skill/streak/dance/audio Specs. tools/client_smoke.py also bundles
the production GameService/server Bootstrap/Telemetry/Config and client modules
with fake Instances/services/remotes/clock for63
callback scenarios. That harness is not embedded in the playable world. These
checks do not establish native rendering, hit testing, Luau types or network timing.

Session.statistics tracks accepted money, prompt/token/special/tier counts and a
rolling10-second actual reward history, at most34 entries under server cooldown.
Snapshot stats are copies, transient and reset with session. Money/s is sum/10,
becomes zero after idle, and never grants money. Purchases do not count as earnings.

Bootstrap starts GameService before protected optional deferred Studio Specs. Missing
or failing test modules warn without preventing remotes/player records. Client sends
at most five initial sync requests at0/2/4/8/12 seconds. Readiness requires an actual
draft: a light balance snapshot after a lost initial draft must not stop retries.
At14s display unavailable state; paid prompts are never retried. Old behavior could
remain Connecting if tests failed, or accept balance but have no draft to submit.

0.7.1 Store recovery: Reconnect starts a fresh bounded sync cycle; opening Store
without readiness does the same. Existing drafts/scroll stay intact. Validate server
build and profile before updating cards; protect render callbacks and disable buys
on incompatible/incomplete data. Restart/rejoin instructions explain a mixed Play
version. Reconnect never submits prompts/purchases or generates new token offers.

0.7.3 clock fix: advance(record, now) accepts the command's captured os.clock value.
submit uses that same value; advance must not independently sample a later time,
because Session.advanceTyping correctly refuses a backward timestamp. Other tick/
close callers may still sample current time. Before appending to an empty input
queue, clamp nextType to actual now; the first word must not use catch-up from before
queue creation. Later queued frame catch-up remains bounded. No client clock is
trusted by the server. Native Enter, mobile Return and the40px Send button all call
sendPrompt/dispatch and share one flight; button guards check visible window/page.

0.7.4 presentation: DeskTheme uses Font.fromName(PressStart2P) for all text. Cached
TextService:GetTextSize with Enum.Font.Arcade measures word/badge widths; optional
measurement injection keeps Composer.tokenLayout portable. Do not estimate with the
old9px RobotoMono advance. STATS automatically sizes vertical text; Store cards
reserve156px with wrapped title/copy and40px buy controls.

Composer.revealCount is pure: min(120ms, word length/100, 0.85/typingSpeed) duration,
monotonic visible letter count. Terminal tracks only active reveals (index/word/age/
lastTime), uses MaxVisibleGraphemes, and reuses the existing Heartbeat. No per-letter
coroutines/events/tweens. Do not count time before birth or paused page/menu/app time.
Chips retain final geometry while the caret follows measured visible letters. Reduced
motion finishes all; undo/draft changes remove stale entries before pooled reuse.
Animation does not gate economic dispatch or mutate token rarity/count/money.

0.8.1 mascot objects:
- AgentMascot: independent passive new/setMascot/destroy object. Fixed transparent
  16:10 slot and centered fitted canvas keep different art from moving text. Reuses
  rectangle Frames across swaps, hides excess; invalid IDs preserve artwork. Main
  owns its title mascot; Desk owns background objects and exposes setAgentMascot.
  Updates/layout never reset selection. No listeners, loop, assets or server state.
- MascotCatalog: generated from assets/mascots/catalog.json by generate_mascots.py.
  Merged rectangles export transparent SVG and native geometry. Generator checks
  exact source coverage/bounds/nonoverlap; verifier rejects stale files. Ember uses
  11 rectangles per instance,8 instances maximum. Native Frames avoid SVG import.

0.9.0 skill payout: PromptSession multiplies each submitted offer's base/rarity by
its recorded server skill factor, rounds/caps at remaining balance and records the
actual extra in receipt.skillBonus/stats.skillBonus. Unattempted words remain x1
under the inherited validated prefix protocol. skill_click never grants money.
Client-supplied amount/grade/time/multiplier fields reject; stale checks never
consume or pay twice. Fixed word results prevent rerolling with Backspace. Native
sync time is separate from the captured os.clock used by the token timing budget.

Skill packets use a separate bounded48/s,12-burst limiter to support the existing
44 words/s upgrade ceiling; general commands retain10/s. Challenge IDs/deadlines
still gate accepted clicks at purchased speed. A production regression runs70
rapid correctly paced clicks at level20, then one capped-context prompt payment.

0.10.0 streak: SkillCheck owns current/best count and streakMultiplier on the prompt
session, surviving submit but cleared by Session.reset. Milestones3/5/10/20/35 give
x1.25/1.5/2/3/4. Fresh successful words increment; Normal attempts reset current,
including a missed reused word. Successful reused words do not increment. The
first award fixes precisionMultiplier, streakMultiplier, streak and their product
in multiplier; PromptSession payout continues using this immutable combined factor.
Prepare next target/randomness/difficulty before committing count/award, preserving
atomicity. New challenge stores its difficulty from the post-hit count. Linear
progression caps after40 hits at1.2s/28-degree good/8-degree great, counter9999.
Skill.view copies counts, per-word factors and widths to clients; stats add current/
best/factor without profile fields. Renderer colors actual server-issued widths,
shows count/factor inside fixed circle and next tier below. Token attributes expose
streak-at-hit/factor; badges already show the combined multiplier. No new loop.

0.10.1 mascot dance:
- MascotDance is a pure cosmetic parameter/phase/pose model. Confirmed streak0 is
  identity;1..40 progressively reaches4.5Hz,16-degree tilt,4% horizontal sway,
  8% lift and6% squash. Parameters cap at40. Phase wraps modulo2pi, frame advance
  caps100ms. Pose blends in over about167ms; rotated bounds fit the fixed16:10 slot.
- AgentMascot caches parameters when setStreak changes and transforms one passive
  inner Dance Frame; Artwork stays interchangeable/fitted inside it. Outer slot
  and hit bounds never move. Rest restores identity; zero count also clears phase.
  No per-object input/listener/Heartbeat/Tween/task allocation.
- Desk.update reads server stats.streak, including main. Existing terminal.onTick
  calls Desk.tickMascots; hidden/unpurchased/suspended/reduced instances rest.
  Terminal.canEdit gates chat/menu/modifiers/app blur/disconnection. Pausing keeps
  phase but resets blend, resuming without catch-up. Guide/OS reduced settings call
  Desk.setReducedMotion for immediate neutral. Destruction follows existing owners.
No server reward, session, payload, persistence or catalog geometry changes.

0.12.0 continuous skill check: server phaseOffset preserves needle angle when a
new challenge changes speed, during its click cooldown, and across prompt sends.
The client keeps rotating during pending acknowledgement; input cooldown and
nonce/server grade authority remain. Default1.8s revolution, speed x1.045 per fresh
hit, capped at0.55s; zone width progression remains72/24 to28/8 degrees.
Large streak count sits immediately right of circle in an equal-diameter box;
multiplier remains inside. Existing reserve/dock/native scale remain.
Store > Studio tools adds initial-spin and per-hit multiplier cycling controls.
Studio-only server validates fixed choices per session: initial rev/s 0.56/0.75/1/0.4,
multiplier1.045/1.065/1.09/1.025. They preserve awards, streak, balance and phase.
No published tuning remote, profile change or client-supplied speed/grade/money.
Verification:168 pure Specs,65 production mock scenarios,36 syntax sources,
78 instances/33 embedded sources. Native motion/latency/compact text QA pending.

0.12.1 latest user override: reaching the context limit now requests submission
once through the existing paced/single-flight dispatch. Partial prompts retain
Enter/Send and Backspace. Only confirmed/queued words reaching the actual limit
trigger it; idle snapshots never schedule a send. No automatic retry after rejection
or timeout. Existing server budget/payment/nonce checks remain. Hidden/paused input
waits for normal eligibility. Acknowledgement opens the next draft without repeats.
Verified168 pure Specs and66 production mock scenarios, including automatic eighth
skill word, queued full prompt, partial editing/manual send, and delayed receipt/
timeout without retry. Native Studio input/network QA remains pending.

0.12.2 latest user override: CLI desktop uses the full root viewport for dragging,
including the former skill reserve and screen edges. Initial window sizes stay
readable; all CLI/STATS drag clamping and normalized resize positions use full
bounds. Store/Guide retain their page layouts. Dock remains an overlay.
SkillCheckLayer stays above the entire Pages subtree; circle, in-circle multiplier
and large streak remain foreground. Circle and streak bounds reject covered CLI
activation/drag/Send callbacks; streak label also consumes native pointer input.
No new input loop, remote, money or server change. Full tools/verify.py passed168
pure Specs and67 production mock scenarios, including all CLI types dragged to
both screen corners and overlapping skill/streak priority. Native rendering/touch/
scroll routing and visual fit on target devices remain pending.

0.13.0 latest direction: replace the needle with a passive round red OrbitDot on
radius0.43, using the same continuous server-time pivot and grade. Default initial
spin is1.0 rev/s; progressive growth/cap and Studio tuning remain.
Words per click = (1 + clickLevel) * (floor(post-hit streak / 5) + 1), clamped to
remaining context. Base upgrade is global,1..4 words, three levels, initial$6.
Fresh GOOD/GREAT clicks grow streak once per click, not per generated word. Normal
resets streak and generates the purchased base. Restoring old words grants just
one word, no new streak or bonus typing permission. Existing cash streak/precision
multipliers remain; each generated word retains its own preissued rarity and fixed
award. No spill into a new prompt when current context fills; full-context auto-send
still triggers once. Extra words receive one-time bounded server typing permission.
Client queues exactly the matching confirmed wordCount at the existing typing pace;
late/synced results cannot repeat it. Input payload still IDs/index only.
Store Words per click card caps4; STATS shows base and streak factor, ring displays
effective words per click. Guide explains the formula. Schema8 adds clickLevel0..3;
known schemas1..7 migrate to0 without changing progress or leases. MEMORY default
and own namespace remain; no actual DataStore records accessed or migrated.
Full tools/verify.py PASSED172 pure Specs (111 +61 current),70 production mock
scenarios,36 source/test syntax files,78 instances/33 embedded sources. Native
Studio visual/touch/network QA remains pending. Parent project remains untouched.

0.13.1 user audio override: replace adaptive score/tempo/chords with one sustained
looped tonic at fixed pitch/gain, soft0.8s attack and music EQ/reverb. No change
from streak, grades, Send, pages or idle; one music voice replaces16. Focus/menu/
disconnection/mute stop it; resuming starts one bed, never musical backlog.
Successful clicks follow an original eight-note A-minor pentatonic phrase:
A C D E G E D C, cycling by confirmed post-hit streak. GOOD/GREAT share the lead;
GREAT adds a quiet octave, not a different melody.0.65/0.7s tails and subtle effects
reverb connect notes; tactile click reduced to gain0.06/55ms. A miss restarts the
phrase on the next success. Server streak keeps phrase continuity across Send,
pages and mute; reused/offpage results/snapshot replay cannot emit success audio.
Guide labels updated; separate volumes/mute and all gameplay remain unchanged.
Verification:172 pure Specs and71 production mock scenarios pass,36 syntax files,
78 instances/33 embedded sources. New production phrase test covers successive
GOOD/GREAT leads, Send/page/sync continuity, miss restart and restored-word silence.
Replaced obsolete adaptive-score tests with sustained-tone and phrase checks.
Native listening/loop seam/timbre balance and device audio QA remain pending.

0.13.2 latest music direction: replace the single sustained tone with an original
mellow elevator/lounge arrangement at fixed88 BPM. Eight bars/~21.8s loop with
Cmaj7/Am7/Dm7/G7 voicings, softly voiced keyboard melody, root bass and very quiet
percussion. No streak-driven speed/layers. Connected skill-click phrase unchanged.
16 pooled music voices plus6 effects, existing tick only.128-step transport drops
frozen-frame backlog; pause/mute/disconnect restart cleanly, pages preserve clock.
Music/Effects levels, global mute, failure isolation and teardown remain.
No uploaded track, external service/dependency or copied asset; original relative-
pitch arrangement uses existing bundled Roblox timbres. Native listening/timbre/
loop/mix and target-device audio QA remain pending.
Full tools/verify.py PASSED172 pure Specs and71 production callback scenarios,
36 syntax files,78 instances/33 embedded sources. Replaced sustained-tone tests
with score/tempo/pool-budget/no-backlog and cross-page playback checks; effects
continuity, volume/mute, pause, fallback and gameplay checks still pass.

0.14.0 latest direction: one server-resolved C replaces fixed5 in the words formula:
base * (floor(post-hit streak / C) + 1). Rules.streakDivisor resolves base C5 minus
global divisorLevel, then optional authored add/multiply modifiers, bounded1..100.
New Store Streak interval C upgrade reduces5 ->4 ->3 ->2, three levels, initial$12.
Quotes/purchase are server-owned atomic debits, capped and payload-free. Snapshot
streakDivisor drives ring/Guide/STATS and music; Skill.click receives server C.
Previously awarded words stay fixed when C changes. Base words still capped4.
Schema9 validates divisorLevel0..3; known1..8 schemas migrate to0 under existing
leases without losing workers/typing/click upgrades. MEMORY/own namespace remain.
No actual persisted records accessed or migrated.
Music stays lounge below C, then four original electronic rock arrangements at
C,2C,3C,4C, cappedIV. Tempos88/112/132/152/176 BPM. Increasing power-chord/riff/bass/
drum density and smoothed distortion; same bounded16 music/6 effects pools and
clock, no restart on tier/page change or extra loops. A miss resets streak and
returns lounge. C changes apply immediately to music thresholds. Connected skill
cue phrase, separate levels/mute, focus pause, fallback and teardown remain.
Original score uses existing bundled timbres; no uploaded/copyrighted track.
Full tools/verify.py PASSED176 pure Specs (111 +65 current),74 production mock
scenarios,36 syntax files,78 instances/33 embedded sources. Four pure and three
production scenarios added for schema/lease migration, C purchase/modifiers/
protocol/word formula, all music thresholds/tempos/density/pool budgets, actual
server C purchases, paid words, four live stages/miss and preserved old awards.
Native listening/mix/transition/device QA remains pending. Parent project intact.

0.14.1 latest user direction: clicking/tapping empty background on CLI page also
presses the skill check. A transparent nonselectable full-root button lives below
Pages, not above controls. Pointer must begin there and still be spatially free
on activation: inside root, outside all visible CLI/STATS rectangles, dock strip
and skill/streak control bounds, with no drag. CLI press released over background
cannot fire. Hidden/unpurchased windows do not reserve free space.
SkillCheckController uses the same physical-input type, readiness, nonce, pending,
context, focus/menu/chat/modifier and flight checks; only the radial position check
is replaced with Bootstrap's free-space predicate. Circle path remains radial.
No synthetic center click, new remote/loop/server rule or client-supplied grade.
Guide mentions background shortcut. Input connections are cleaned with GUI.
Full tools/verify.py PASSED176 pure Specs,77 production callback scenarios,
36 syntax files,78 instances/33 embedded sources. Three production tests added:
mouse/touch grade-to-payout and once-only activation; CLI/control/dock/streak/circle
exclusion and dragged-release guard; paused pages/chat/menu/focus/modifier/drag,
pending acknowledgement and teardown. Native GUI routing/CoreGui/insets/mobile
release behavior and real network/device QA remain pending. Parent untouched.

0.15.0 user direction: each fresh confirmed GOOD/GREAT click spawns one agent
mascot dancing/vibing at a random background position. BackdropDancers reuses ten
AgentMascot objects behind all main GUI/input (backdrop DisplayOrder19 vs20).
Randomly choose only purchased agent artwork, respecting each CLI's swapped ID.
Try12 positions to minimize CLI overlap, falling back to the least-covered one;
normalized placement stays inside viewport above dock and adapts on resize.
Each figure fades in/out and lives four beats (minimum1.4s), dance rate follows
current lounge/rock BPM. Pool cap10 reuses oldest ring slot, no unbounded objects.
All parts passive/nonselectable, so empty-background skill clicks remain valid.
Use matching skill-result callback only; snapshots, restored words, misses and late
offpage confirmations cannot spawn figures. Reduced motion shows static figures;
pages clear immediately, chat/menu/modifiers/app blur/disconnection clear on tick.
Destroy the whole pool/layer with GUI. Existing heartbeat only; no per-particle
connections/tasks, uploaded art, remote, server reward/schema changes or exterior.
Full tools/verify.py PASSED176 pure Specs,80 production callback scenarios,
37 syntax source/test files,79 instances/34 embedded sources. Three production
scenarios verify fresh-only/dedup/passive animation, bounded reuse/random positions/
resize/expiry/free-click compatibility, and reduced motion/offpage late results/
artwork swaps/focus/teardown. Native Studio layering/visual feel/device performance
and music-listening QA remain pending. Parent project remains untouched.

0.15.1 user direction: animated red/orange fire wraps the skill circle, inspired
by the supplied flame outline. SkillFlame renders12 curved tapering quadratic
ribbons, six segments/two colors each (144 reusable passive strips), plus a red
ember halo. Behind opaque circle and right-hand count, above ordinary windows.
Confirmed streak grows flame height/width and sway rate through40 hits, then caps.
Zero streak hides immediately. Existing skill tick updates smooth growth and
bounded phase; no tween, task, extra heartbeat, asset upload, SVG decoding or
external image required. Native procedural geometry scales with120px/84px circle.
Reduced motion freezes phase immediately and uses static target-size flames;
hidden/paused input stops ticking. Hit area stays the original circle and all
flame parts remain passive/nonselectable, so free-background input and CLI/dock
priority stay intact. Destructor releases flame geometry with skill GUI.
Full tools/verify.py PASSED176 pure Specs,83 production callback scenarios,
38 syntax files,80 instances/35 embedded sources. Three production tests cover
confirmed growth/motion/miss, bounded reusable passive finite geometry at both
sizes/max streak, free-background click compatibility, reduced motion, page pause,
resize and teardown. Native rendering/clipping/performance QA remains pending.
A local Pillow geometry proxy was inspected (build/streak-fire-geometry-preview.png),
not an engine screenshot or native visual approval. No server/schema/economy or
parent changes; existing audio/background dancers remain.

0.15.2 user direction: each eligible skill click immediately emits a floating word,
including normal/reused clicks and the free-background shortcut. Random phrase
from Wow/Vibing/__skillcheck/Flow/Nice!/Locked in/Keep going, muted mint/amber/ivory/
terracotta pixel text,16..22px. Random screen location above the skill area; text
rises ease-out up to56px and fades over1.4s. No extra reward or actual prompt token.
FloatingWords reuses12 passive nonselectable labels in overlay Z15, below skill/
fire/count Z20 and above ordinary CLI pages. Geometry adapts on resize. Local
onPress hook only, so pending/cooldown/blocked clicks never emit, and server sync/
late receipts cannot replay. No per-label timer/tween/connection; existing tick.
Reduced motion keeps labels static/opaque until expiry. Pages clear immediately,
chat/menu/modifiers/focus loss/disconnection clear on tick. Destroy with GUI.
Full tools/verify.py PASSED176 pure Specs,86 production callback scenarios,
39 syntax files,81 instances/36 embedded sources. Three production tests verify
immediate circle/background/delayed-ack feedback and dedup, bounded reuse/random
phrases/passive rise/fade/resize/expiry with unchanged balances/requests, and
reduced motion/page/focus/chat/teardown. Native Studio placement/font/readability/
input routing and device performance QA remain pending. Parent/schema/server/
protocol/economy unchanged, no external font/art/service.

0.15.3: existing Main CLI dock shortcut made prominent: persistent mint button at
left,128px wide on desktop and24% of compact dock. Readable dedicated type size,
40px target and stable MainCLIShortcut name. One click returns from any page and
foregrounds main without changing its position/draft; other controls remain.
Reflowed dock/status offsets to prevent overlap. No duplicate shortcut/keyboard
binding or game/network change. Full verify passed176 pure Specs/86 production
scenarios,39 syntax files,81 instances/36 embedded sources. Native visual QA pending.

0.16.0 user direction: Store redesigned as a responsive grid of square upgrade
cards, with permanent upgrade name at top, authored colored SVG/pixel icon in
center, current level/status and one Buy / $price button at bottom. Existing
charcoal/mint/amber/terracotta palette and PressStart2P retained. Cards are at
least216px,1..4 columns,12px gaps, scrolling at native readable scale. Store
content max1080px; footer message and collapsed Studio tools span below the grid.
Explicit grid/canvas layout updates on root/shop size and Studio disclosure,
preserving Store page and scroll on purchases. All seven global upgrades and
server costs/affordability/caps/reconnect handling remain. Typing speed uses the
same Buy/price format; its rate/level appears separately in card status.
assets/store/catalog.json is the authored16x16 pixel/vector source; generator
exports seven transparent SVGs and StoreIconCatalog. StoreIcon draws exactly
those rectangles natively, no asset upload or SVG runtime dependency. Verifier
checks catalog reconstruction and SVG/generated source equality.
Full tools/verify.py PASSED176 pure Specs,87 production callback scenarios,
41 syntax files,83 instances/38 embedded sources. Added production square grid/
icon identity/passive geometry/buy-price/nonoverlap/viewport/bounds and actual
purchase check; existing page/scroll/global upgrade/cap/reconnect tests pass.
Inspected a local art/geometry proxy (build/store-grid-geometry-preview.png), not
a native screenshot. Native Studio fonts/layout/scroll/device QA remain pending.
No external artwork/fonts/dependencies, schema/economy/remote or parent changes.

0.16.1 user direction: background agent avatars may occupy any viewport position,
including behind CLIs and the dock. Remove overlap avoidance and reserved dock/
margin positioning; normalized positions span the complete screen while artwork
stays inside viewport and adapts on resize.
Avatars persist at their original positions for the whole streak, without a timed
expiry. Send, idle, Store/Guide, menus/chat/app blur and reconnect snapshots do not
clear them. They pause dancing when editing is suspended, preserving visibility/
position; they continue on return. Existing ten-avatar pool is retained: once full,
new hits do not replace or hide existing avatars. Current streak/BPM drives their
dance. Losing streak (including synced reset/reused miss/offpage result) starts a
0.65s fade from current opacity, then deactivates. Reduced motion keeps pose static
while preserving the loss fade. Late offpage successes do not spawn new avatars.
Destruction still cleans everything. All art remains passive behind main UI.
Full tools/verify.py PASSED176 pure Specs,88 production callback scenarios,
41 syntax files,83 instances/38 embedded sources. Updated persistent dancer tests
and added exact viewport-corner/CLI-overlap, idle/page/chat retention and smooth
loss fade/reduced-motion check. Pool reuse, resize, input, pause, swaps and teardown
regressions pass. Native Studio visual/input/performance QA remains pending.
No new assets, remotes, server reward/schema/store changes; parent untouched.

0.17.0 user direction: agents automatically type words using current TPC. One
server-authorized batch per second, count = owned agents * current TPC, clamped
to remaining context. Starting agent participates. Words use existing typing-speed
queue/reveal and auto-send at full context; Enter/Send still submits partial drafts.
Automation continues on Store/Guide without focusing main, resetting scroll or
switching page. Menus/chat/modifiers/app blur/disconnected state pause new batches.
Agents never increase/break streak or earn precision/streak multipliers: each
new automatic word locks an Agent x1 award, keeping its preissued rarity; restored
manual awards stay unchanged. Only normal accepted prompt submissions pay money.
This explicitly overrides earlier manual-input-only/no-idle-generation direction.
Shared AgentAutomation grants words only after strict draft/index/requestId and
server cadence/owned-count/TPC validation, authorizes bounded typing permission
once per fresh word, never consumes RNG or directly pays. Existing nonce/grade/
rarity/context/balance/global upgrade authority remains. Session-only bookkeeping,
no profile/schema/namespace change. New payload-free computed values: client never
supplies TPC/count/streak/price/time; agent_type and read-only agent_sync carry only
requestId/draftId/tokenIndex, using existing bounded general command limiter.
Client matching pending receipt queues one batch, preventing manual/skill overlap.
Three read-only reconciliation attempts; after12s uncertain word requests unlock
with fresh nonce/fixed prefix, never retry a possibly paid prompt. Stale/repeated
snapshots cannot append twice. Reset clears agent bookkeeping. No offline catch-up.
Large TPC number added left of circle with caption; right streak now Nx with same
style, font/size constraints and box. Both counters have input priority. Circle
uses width-safe diameter on narrow screens to fit all three, max120/84 by height.
Background agent CLIs describe auto typing. Guide explains cadence and neutral words.
Full tools/verify.py PASSED179 pure Specs (111 +68 current),93 production callback
scenarios,42 syntax files,84 instances/39 embedded sources. Three pure and five
production automation cases cover cadence/payload/cap/award/budget/no-direct-money,
actual idle typing/full-send on Store, TPC/owned-count/UI bounds, neutral streak,
late/lost/repeated-lost acknowledgements, paused inputs and no money/word replay.
Legacy scenarios freeze agent time via their fixture Balance clock constant;
automation scenarios explicitly use the actual production one-second cadence.
Native Studio networking/rendering/fonts/gameplay balance/device QA remain pending.
Parent project intact; no new assets, external services, real shell or AI.


0.18.0: streak celebrations now use independent StreakAvatar objects. Each owns
its stable ID, source-agent attribute, artwork swaps, normalized viewport position,
dance and fade/teardown. BackdropDancers only coordinates confirmed spawns, its
bounded pool and streak state. Public API is documented in
tasks/050-independent-foreground-streak-avatars.md.
Dedicated full-screen VibeIdleStreakAvatars ScreenGui DisplayOrder21 places these
actors above all workstation CLIs/pages/skill controls (DisplayOrder20). Every
visual remains passive to input. Ten-actor capacity, no active replacement,
streak-duration persistence,0.65s loss fade, reduced motion and existing tick
remain. No server/protocol/schema/assets/economy change.
Full tools/verify.py PASSED179 pure Specs,94 production callback scenarios with
mock services,43 syntax files,85 instances/40 embedded sources, deterministic
two-pass export. Updated foreground assertions plus independent-actor test cover
identity/source, movement, appearance isolation, invalid swap, opacity/layer,
fade isolation and idempotent cleanup. Evidence: build/streak-avatar-verification.log.
Native Studio rendering/input/device QA remains pending.


0.18.1: SkillFlame now uses the user's bolas-de-fogo-circulos-pretos.zip artwork.
All36 source SVG frames are preserved in assets/skill-fire. Offline generator
converts the five flame colors into SkillFireCatalog; the black circle is omitted
from rendering so the real skill circle, arc, red dot and labels remain visible.
Source circle center/27px diameter align all tiers at both native control sizes.
Low intensity below C, medium at C, high at2C. Twelve frames at10fps per tier,
continuous phase across hits/tier changes, cap253 passive reused Frames. Geometry
updates only on frame/intensity/layout changes. Reduced motion uses static frame1;
miss hides/reset, pause stops motion, teardown destroys pool. No external image
upload/HTTP/runtime SVG decoding or new heartbeat/server/economy/schema behavior.
Verifier checks all SVG pixels/bounds/palette/no overlaps and generated equality.
Four production scenarios cover all36 frames at both sizes, intensity/C changes,
phase continuity/source timing, fixed pool, passive input, miss/reduced motion,
pause/resize/teardown. Full179 pure Specs and95 callback scenarios pass with mocks;
44 syntax files,86 instances/41 embedded sources, deterministic two-pass export.
Evidence: build/supplied-fire-verification.log. Inspected geometry proxy:
build/supplied-fire-geometry-preview.png (not a Studio screenshot).
Native Studio rendering/input/performance QA remains pending.


0.19.0 user steering: disable skill fire for now (no SkillFlame object/parts/tick
at runtime); keep supplied SVG/native source available for later. Manual clicks
append their finite context-clamped grant immediately. New skill checks begin
with zero typing cooldown while retaining continuous phase. No prompt-wide typing
permission or typing-too-fast rejection; nonce/context, request limiters,
single-flight and prompt cooldown guards remain. Existing in-progress agent
animation may finish on manual confirmation; only previously server-authorized
agent words enter that flush, with no new agent grant or budget bypass.

Only automatic agents have typing speed,4+2*typingLevel up to44 words/s. Existing
global upgrade_typing stays in Store as Agent typing speed, with the same stored
schema9 level, cost/cap and purchase validation. Auto.advance owns agentPace:
settle elapsed time at old rate, cap budget to one second of that rate, never pay
idle money or build an offline burst. Auto.grant clamps owned-count * TPC by this
fresh-word budget and remaining context. Fixed awards can be restored without
spending new budget. Matching client agent queues retain visual pacing; manual
words and payouts never consume this budget. Server snapshots expose
agentTypingSpeed; Prompt.agentTypingRate names the agent-only computation.

Agent awards lock multiplier1 + serverStreak*0.1 at generation, times their own
preissued rarity/base on normal accepted prompt payout. They never build/break
streak or earn precision bonuses. Loss/edit/sync/restoration cannot reroll or
retroactively change an award. Example: streak10 gives x2; Rare x10 then pays x20
base, even if streak ends before submission. Token badges expose the actual
combined factor; STATS shows agent speed/current reward factor and total token
bonus, Guide explains the difference. No new remotes or profile/schema change.

Full tools/verify.py PASSED181 pure Specs (111 baseline+70 current),94 production
server/client callback scenarios with mock services,44 syntax files,86 instances/
41 embedded sources, deterministic two-pass export and SVG/native equality.
Coverage includes manual full sends with empty agent budget, old-rate upgrade
settlement, no budget from sync/idle, server4->6 agent grant cap, immutable streak
buff through loss/restore/payout, no fire construction, immediate manual clicks,
mixed manual/agent queues, neutral automation and existing no-replay guards.
Evidence: build/agent-speed-streak-verification.log. Native Studio networking,
rendering/input/performance QA remains pending. MEMORY namespace/parent untouched.


0.19.1: skill check artwork uses PixelSkillDial, a passive native renderer.
Two24-row circle masks produce a stepped charcoal face and rim; vertically
merged spans keep a bounded pool. Ninety axis-aligned square arc samples snap
to distinct40-grid centers and retain the same4-degree authoritative target
coloring. Three red rectangle spans form a5-grid pixel marker. Pivot rotates
continuously at the existing server phase; counter-rotation keeps marker pixels
upright. No angle quantization, new animation loops or input dependencies.
Layout rounds rectangle edges to integer local coordinates at84/98/120px and
other width-safe diameters. No UICorner/UIStroke or rotated arc rectangles in
the skill control. Transparent native button keeps the original circular hit
test/foreground input priority, label/counters/font and reduced-motion essential
phase. Fire remains disabled; no server/economy/protocol/profile/asset change.
Full tools/verify.py PASSED181 pure Specs (111 baseline+70 current),95 production
callback scenarios with mock services,45 syntax files,87 instances/42 embedded
sources and deterministic two-pass export. Geometry regression covers stepped
bounds/integer positions, distinct target centers, passive/reused parts, smooth
phase and upright marker at multiple sizes plus actual GREAT token grant.
Existing precision/nonce/free-space/occlusion/payout/agent tests also pass.
Evidence: build/pixel-skill-dial-verification.log. Inspected geometry proxy:
build/pixel-skill-dial-preview.png. Native Studio rendering/input QA pending;
the proxy uses approximate text and is not an engine screenshot.


0.19.2 fixes shared agent speed. Auto.advance now maintains an independent
budget/time/rate object for every owned agent. Each agent gets its own full
4+2*typingLevel (max44/s); the existing global upgrade changes each agent's rate.
Auto.grant gives each up to its own TPC/budget before context clamping; no agent
can consume another's budget. New agents initialize at purchase snapshot time,
without prior idle credit. Old-rate settlement, bounded one-second per-agent
capacity and immutable awards/replay guards remain. Summed budget is diagnostic.
Client combined queue uses per-agent rate * owned count, including next-word
scheduling after snapshots, so presentation no longer serializes the whole group
at one agent's speed. Composer capacity updates immediately on purchases through
its render stamp. Store says Each agent, STATS shows per-agent and total typing
capacity, Guide describes independent rates. Manual input/agent streak buff,
pixel skill dial/no fire, schema9/MEMORY namespace and parent remain unchanged.

Full tools/verify.py PASSED182 pure Specs (111 baseline+71 current),96 production
callback scenarios with mock services,45 syntax files,87 instances/42 embedded
sources and deterministic two-pass export. Pure tests cover independent new-agent
objects, no inherited idle budget, consumption isolation and4->6 per-agent speed
upgrades. Production purchase flow confirms4 words/cycle for one agent,8 for two,
12 after upgrading both to6 with sufficient TPC/context, and completes the queued
words in one cycle at summed speed. Immediate capacity label, Store/page guards,
neutral automation/locked streak buffs and prior input/payout tests pass.
Evidence: build/independent-agent-speed-verification.log. Native Studio networking,
rendering/performance QA remains pending.


0.20.0 fixes manual skill clicks interrupting automatic typing. AgentAutomation
now stores nextAt independently inside every agent's budget object, initialized
at its purchase time. Only that agent's accepted grant advances its deadline;
manual clicks, prompt submissions and other agents never reset it. Auto.grant
returns source counts and only serves due agents. Snapshots carry the earliest
absolute deadline in shared server time, preventing response latency from adding
another cooldown. Client updates its request deadline only for initial sync or
correlated automation reconciliation, not ordinary skill/prompt snapshots.

The mixed player/agent word queue and nextType/lastTypedAt clock are removed.
Server-confirmed manual/agent words append atomically to the bounded shared draft.
Per-agent cosmetic letter schedules live in agentRevealTimes; manual reveal speed
is independent and manual words never flush or reset agent reveals. Each source
uses its own rate for sequential letter appearances, concurrently with siblings.
Late manual acknowledgements commit the accepted word even off-page, leaving no
pending manual queue that could block Store automation. Accepted full contexts
still auto-send exactly once; cosmetic animation never gates payout. Background
send origin is tracked separately from typing state.

After manual reconciliation, an already due producer gets priority before the
next click reserves the shared prefix. One in-flight prefix mutation remains for
nonce/draft safety; this is separate from individual typing clocks. Agents have
their own bounded24/s burst16 packet limiter instead of spending player/general
command allowance. Skill48/s/general10/s guards remain. No new remote/schema or
profile fields; immutable rarity/streak buffs and isolated MEMORY stay unchanged.
Guide clarifies that manual clicks do not reset producer timers or animations.

Full tools/verify.py PASSED183 pure Specs (111 baseline+72 current),99 production
callback scenarios with mock services,45 syntax files,87 instances/42 embedded
sources and deterministic two-pass export. New tests cover staggered per-agent
deadlines across manual activity, preserved source reveal clocks,40 continuous
manual clicks with delayed replies while automatic production continues, sends
not postponing deadlines, and delayed off-page manual acknowledgements without
agent starvation. Reconciliation resumes fresh due work without replaying old
words/payments; timeout/missing/repeated-lost replies, pages/pauses and existing
skill/economy/authority tests pass. Evidence:
build/independent-producer-verification.log. Native Studio networking/input/
rendering/gameplay/performance QA remains pending.


0.20.1 improves stationary skill pointer response and priority. SkillCheckController
listens to UserInputService.InputBegan for mouse/touch press-down inside its exact
circle, independent of hover and gameProcessedEvent (own GUI naturally processes
pointer input). Existing page/chat/menu/modifier/window-focus/pending/context/
server-readiness checks still determine whether an attempt is allowed. A stable
native Active=true hit target avoids flipping input/hover participation during
acknowledgements; Ready is exposed separately as an attribute. Physical gestures
suppress the later Activated release fallback, even if callback InputObjects
change or the same object is reused between presses. Holds never repeat; rejected
busy gestures are not queued against a later timing challenge. All pointer
listener connections are disconnected on idempotent controller destruction.

Skill control/counters now render in VibeIdleSkillPriority ScreenGui DisplayOrder22,
above workstation20 and passive streak avatars21. Its passive root matches the
workstation's CoreUISafeInsets and local pixel dimensions on resize, preserving
existing coordinates/appearance. Empty-background clicks retain their original
press-start/release path; circle input rejects ongoing drags and covered CLI
callbacks retain spatial priority guards. Destroying the main GUI destroys the
extra surface. No server/protocol/economy/schema/agent-clock changes or new loops.

Full tools/verify.py PASSED183 pure Specs (111 baseline+72 current),102 production
callback scenarios with mock services,45 syntax files,87 instances/42 embedded
sources and deterministic two-pass export. Three new production regressions cover
six repeated presses at a stationary reused pointer, processed GUI input,
release callback dedup with different objects, pending->ready with no cursor
movement, held-button nonrepeat, overlay hierarchy/resize, overlapping CLI/drag,
page/menu/chat exclusion and disconnected pointer capture after teardown.
Evidence: build/priority-skill-click-verification.log. Native Studio pointer/
hover/input/rendering QA remains pending; mocks cannot prove engine hit testing.

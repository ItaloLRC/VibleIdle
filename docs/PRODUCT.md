# Product

Latest0.72.0 makes navigation and feedback gentler: a short eased fade/small
slide replaces the large page jump, including returns, start and tutorial steps.
Status text fades briefly; ordinary controls gain hover/focus highlights. Most
panels/cards/windows/buttons use black borders with existing colored accents.
Money updates and token reveal stay authoritative/immediate; hit areas and skill
timing stay fixed. Reduced motion removes cosmetic animation. See task115.

Latest0.71.0 measures sessions/time, core actions, each upgrade and premium
lifecycle. Per-player totals and bounded progression/timing context persist
through prestige; schema18 migrates without inventing past activity. Confirmed
server results are separate from capped reported SELL/Enter/focus estimates.
Native Roblox custom events and JSON server summaries are aggregated/bounded;
failure never changes rewards. Server-only per-UserId live/last-saved reports
require no player-facing admin UI. See PLAYER_ANALYTICS.md and task114.

Latest0.70.0 starts at a pixel welcome screen with START/CONTINUE and HOW TO PLAY.
Play waits for a validated profile and draft; Reconnect replaces indefinite
loading. New players get a grey spotlight tutorial: confirmed Good/Great, sell
agent-written tokens, collect a real random visitor. Skip or replay from Guide;
completion/dismissal persists, with no extra rewards. Published servers save to
isolated VibeIdle DATASTORE automatically; local/Studio remain session-only.
Save delay is visible; unsold tokens and streak remain session-only. Schema17
preserves progression/premium and adds tutorialDone. Commerce stays disabled.
See task113 and LAUNCH_READINESS.md for release QA and future feature candidates.

Latest0.69.0 increases supporting text across all five icon pages to generally
14px and important values to16px. Collection cards, portraits, skill icons,
Robux icons and panels grow to fit. Responsive layouts use fewer columns,
vertical/horizontal scrolling and stacked prestige summaries without shrinking
the interface. Prestige reset details stay in the scrollable dashboard above
the same explicit confirmation path. No economy or billing change. See task112.

Latest0.68.0 adds Robux Shop, reachable from an original fifth storefront icon.
The collection-style page highlights Forever Duo (2x Money +2x Chips forever,
100 Robux target), followed by2x Money1h10,2x Chips1h15 and one run agent20.
Real configured prices are loaded per player; Roblox's native dialog confirms
the final price. At the user's request all IDs remain0, buying disabled and
MEMORY unchanged; the page clearly labels target prices/unavailable purchases.
See docs/ROBux_SETUP.md to configure later.

Temporary boosts use real server time including offline time, stack duration
and stay at2x with the permanent pass. Money multiplies confirmed sales; Chips
multiply only unclaimed base entitlement at prestige, tracking paid bonus Chips
separately so expiry/rebuy cannot reclaim old rewards. Up to41,600 total Chips
can be minted from20,800 base; lifetime curve and all tree/craft prices stay.
The agent adds a normal writer this run (resets at prestige), or a saved credit
if a paid receipt arrives at cap. Credits and all premium metadata survive
prestige. USE CREDIT redeems explicitly. No paid random cards/direct cash grants.
Only server-verified receipts or pass ownership grant benefits, with durable
dedup and CHECK/rejoin recovery. No real purchase/publication from this task.

Latest0.67.0 increases prestige vortex gains2.25x while preserving effects/mute
and quieter reduced mode. Random visitors initially show family/rarity only.
After a confirmed collection, exact receipt fragments rise/fade for0.9s in mint
pixel text with dark outline, including zero at the cap. Press/rejection/expiry
never shows an amount; replies/sync cannot replay it. Normal motion rises40px;
reduced motion remains still with a fade. Effects pause off-page/blur/input pause.
Top Lab/Cards/Skill tree/Prestige shortcuts now have64px targets/48px native art.
On narrow workspaces pan the shortcut strip horizontally; no icon shrinking or
Shop overlap. Money/Chips use54/38px base text with adaptive fitting, larger120px
transparent header and retained foreground guards/CLI clearance. Schema15 and
all resource/collection authority/prices are unchanged. See task110.

Latest0.66.0 brings Laboratory into Cards' collection style: same stepped pink/
gold frames, family-colored pixel medallions, dark striped backdrop, raised
violet panels and shadowed headings. A horizontally scrolling nine-family row
sits above four recipe cards with enlarged144px medallions, fixed128x80 skin
previews, clear buffs/costs and40px craft targets. Crafting/ownership/prices and
schema15 remain unchanged. Prestige now takes3.02s with gradual eased suction
and a softer reveal. Prebuilt spiral/core groups transform continuously through
the existing heartbeat; hidden UI maintenance pauses. An original three-voice
wind/low-tone vortex SFX plays only on confirmed start, follows the visual phase
and respects effects volume/mute, pause and cleanup. No upload or new loop.
Reduced motion keeps its0.36s static fade. See task109.

Latest0.65.0 replaces cosmetic Lab selection with card crafting. Random visitors
appear independently of skills/streak every5..10 active Main CLI seconds, live
24 seconds and give only their family's fragments on click. Common/Rare/Epic/
Legendary chances are75%/20%/4.5%/0.5%, base fragments1/2/4/8. Collection skills
increase fragments; visitors never change streak, money or Chips. Pages/chat/
menus/blur pause new arrivals, with no offline catch-up. Nine equally likely
families each offer four deterministic recipes:3/$100/1 Chip,12/$25K/3,
30/$25M/12 and75/$25B/60. One copy per version, no random paid craft or auto equip.
New profiles start with Common Ember; historical cards/decks remain Common.
Rare/Epic/Legendary skin trims preserve family identity and multiply base value
by1.3/1.8/2.7 and speed by1.05/1.10/1.15, retaining the55/s agent ceiling. Cards
equips exact variant art/buffs. Fragments and crafted ownership survive prestige.
Chips spent crafting still count toward permanent claimed-Chip cash bonuses.
Cap20,800 allows the whole tree plus collection. See task108.

Latest0.64.0 adds an original prestige vortex inspired by the requested reset
style. Only a matching confirmed explicit prestige triggers it, including a late
read-only acknowledgement. The real interface/wallpaper rotate and shrink into
three native pixel spiral arms, a dark center covers the scene, and Main CLI
returns at normal size. Gameplay input/automation wait through the1.87s effect;
no rewards, requests or paid retries come from animation. Reduced motion uses
only a0.36s static fade. Blur/menu/chat/modifiers pause; resize/disconnection
cleanly finish and restore, and owner teardown destroys the overlay. Schema14,
prices, prestige/reset authority and all progression stay. See task107.

Latest0.63.0 / schema14 expands the tree to54 functional skills on a radial
3416x2704 map inspired by the supplied reference. The central New boot core fans
into cash, agent speed, streak, luck, Chip memory and collection paths, with
multi-parent masteries. Stepped240x208 hexagons use original native icons/branch
colors, price buttons and persistent grab-pan; CORE recenters without gameplay.
The27 existing nodes keep their IDs/effects/prices/parents. Extensions bring full
cost to19,973 Chips. Maximum earned Chips is20K with8e15 confirmed lifetime money;
the cubic formula and explicit prestige stay. New max special odds10x yields
Common68.9%, Uncommon20%, Rare10%, Epic1%, Legendary0.1%, retaining all rarity
money multipliers and old offers. Streak reaches100 through permanent skills;
visual/difficulty caps remain40. Collection tops4.5x, per-Chip cash19% and agent
rates still cap55/s. Schema1..13 migration preserves balances/claimed Chips/
ownership/legacy debits; new skills cannot appear in old schemas or use old prices.
See task106. Earlier entries below are historical.

Latest0.62.0 / schema13 follows researched incremental cost/milestone patterns.
Common money/token begins at $1. Token value price is floor(10 *1.4^L); value
multiplier is (1 +.35L) *10^floor(L/10), bounded by the existing money ceiling.
Thus levels10/20/30/40 reach $45/$800/$11.5K/$150K before topology/permanent/
rarity/card/streak bonuses. First agent/context stay $2K/$100, later prices grow
6x/4x respectively. Tree skills cost1..3,200 Chips (7,673 total); all effects and
the cubic lifetime prestige/10K Chips ceiling stay. Existing owned skills retain
historical debits while future buys use current prices. Saved money, unspent and
claimed Chips, upgrades, cards and ownership survive schema1..12 migration under
leases without refunds/new Chips. UI includes T for trillions and the Guide
explains milestone jumps. Task105 documents sources, formulas and model limits.

Latest0.61.0 adds Lucky tokens I..IV after New boot for2/8/30/100 Chips.
These permanent skills set total Uncommon/Rare/Epic/Legendary chances to2x/3x/
4x/5x their baseline, removing matching weight from Common within10,000 tickets.
At maximum the distribution is84.45% /10% /5% /0.5% /0.05%; reward multipliers
stay1/3/10/50/250. Applies to newly issued drafts and newly added context slots;
existing offers/awards stay fixed. Guide shows current chances, and the tree
keeps native sizes with a fifth column. Existing Chip purchase, parent, save,
prestige and reconciliation rules apply without a schema change. See task104.

Latest0.60.1 changes only agent/context prices: next agent costs
2000 *2^(N-1), where N is current owned count (initial agent is free), and next
context upgrade costs100 *2^K, where K is current context level. Single/bulk/MAX
use these same server-owned prices. Token value prices and all rewards remain
unchanged; schema12, caps and existing progression stay. See task103.

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

VibeIdle0.33.0 is a Roblox incremental about a coding-agent workstation. All UI is
English. Click the circular skill check to build authored coding words, review special words, press Enter or Send, earn money
and buy global upgrades. No real shell, AI API or external service. Agents simulate automatic typing.

Agent requests, full context and prompt sends no longer block a fresh skill press.
When busy, the server grades the press immediately and queues its awarded words
instead of reserving terminal space. This session-only FIFO holds up to512 words;
it releases up to128 words/s,16 per packet, before additional agent words. Current
context limits and once-only full sends still apply; overflow waits for following
prompts rather than disappearing. Queued words preserve their confirmed bonuses
after streak loss and appear complete, never paying until actually submitted.
The CLI title shows QUEUED with the remaining count. Store/Guide still allow
automatic release; chat/menu/app blur pause it. Explicit reset clears the queue.
Only the player's own unconfirmed skill request waits for acknowledgement before
another attempt; all spatial/pause checks, finite capacity and packet limits stay.

Automatic agents now add words throughout the second instead of in a one-second
batch. At8 words/s, each word is due about0.125s apart. Agents have different phases
and small timing variations so they do not all write together. Nominal output is
still current TPC per pacing window, capped by each agent's typing speed. STATS
shows current output separately from purchased speed caps. Short network/frame
delays can combine a few already-due words; pauses never accumulate idle output.

The skill circle has a raised terracotta button center and projected pixel shadow.
Pressing squashes the center and returns it to normal over0.14s. Rapid presses
restart the rebound, including while a previous skill click awaits confirmation;
visual reactions alone cannot add words or bypass cooldowns. The clickable area,
target arcs and orbit remain fixed. Reduced motion keeps the button static.

Around the CLICK circle, keep only the large left tokens-per-click number and
right Nx streak counter, both with dark projected pixel shadows. Small TPC,
xN w, next-milestone and result/status captions are removed from this control.
Detailed statistics and explanations remain in STATS/Guide.

At2 or more actual combined agent words/s, or8+ effective tokens per click, all
words appear complete immediately, including manual words. Crossing either
threshold finishes pending letter reveals, even off-page. Only below both limits
do new words animate; reduced motion always shows complete words. Studio letter
speed cannot override instant mode. This is cosmetic and never changes grants,
agent production speed, rarity, money or sending behavior.

In Roblox Studio, open Store > Studio tools for28 live timing/cooldown/spawn
controls, including Click queue release/batch, Button rebound and Agent timing variation. Each row cycles presets forward or backward; Restore tuning defaults
returns all settings to normal without clearing upgrades or money. Controls cover
gameplay, agent production, spawn probability/cap, effects and response timing.
Values apply to that player's current test session only. Published gameplay uses
the normal defaults; no tuning endpoint or saved profile settings are introduced.
Exact controls/defaults are listed in tasks/060-studio-timing-spawn-tools.md.

Each fresh GOOD/GREAT click has a30% chance to spawn a collectible agent, up to10
on screen. The server rolls spawn first, then independently selects the existing
rarity and purchased source agent. Restored words and sync never reroll a spawn.
The5-second streak inactivity limit and collectible rarity bonuses still apply.

Prompt sends have no artificial waiting interval. Enter/Send submits partial
drafts immediately; filling context auto-sends immediately. Each submission still
waits for its server acknowledgement before another prompt can be submitted.

A fixed circular CLICK control sits below the CLIs at bottom center. Its needle
rotates clockwise, starting at one revolution per2.4s. Click with the mouse (or tap) when the needle is
in green for GOOD x1.5 or the smaller gold arc for GREAT x2. A click elsewhere
adds a normal x1 word and breaks the streak, keeping previous word rewards. Each confirmed click generates one authored
word. It never sends a prompt or pays money by itself. Server-issued target and
shared server-time phase determine the result with bounded trailing latency grace.

The multiplier applies to that word's normal rarity/base reward when explicitly
submitted. A Rare x10 word with GOOD becomes x15, GREAT x20. The badge shows the
combined multiplier while the piece retains its rarity color. Results are fixed
on the first attempt for that word; backspace/re-adding cannot reroll. Skill
bonus actually credited is tracked in STATS. No player proof/anti-cheat claim.

Fresh GOOD/GREAT words build a consecutive streak. Additional multiplier tiers:
3 hits x1.25,5 x1.5,10 x2,20 x3,35 x4. The word crossing a tier receives the new
factor. For example, the third GREAT Common word is x2.5 (x2 precision * x1.25
streak), before its global base. Each word locks its own factor; later misses do
not remove earlier bonuses. Normal clicks reset current streak, preserving best.
Restoring an old word cannot grow the streak; a missed restoration still breaks it.

The next challenge gets harder per hit: revolution duration decreases by0.03s,
green width by1.1 degrees and gold by0.4 degrees. Difficulty caps at40 hits:
1.2s per revolution, green28 degrees and gold8. Grace is at most120ms and75% of
the gold width. Streak factor caps atx4 and counter at9999. The ring shows count/
factor and next milestone; STATS shows current and session best. Send, Store,
Guide, sync and context upgrades do not reset or extend the streak deadline.
After5 seconds without an accepted circle/background click or collectible-agent
claim, current streak resets and collectible agents fade. The timer continues on
other pages, menus and focus loss. Automatic typing and prompt sends never refresh
it. Best streak and bonuses already fixed to words remain. Explicit session reset
clears both streak and best. State is session-only, with no profile change.

Main CLI remains the sole composer, with one40px Send button and Backspace editing.
Enter or Send submits early; full context sends once; full context sends automatically. Each word is an independent
Frame with label/border/background. Common grey; Uncommon green, Rare blue, Epic
purple and Legendary gold, with explicit xN badges. Wrap/scroll without shrinking.
Context starts at8 and caps at128. Full context pauses events until edit or send.

Typing speed starts at4 words/s; the global Store upgrade adds2/s per level to
44/s, initial cost$4. It paces words and the post-click gap (1/rate), not the streak-driven
needle speed or target size. Pages, chat/menu/modifiers, app blur, full context and
requests disable input. No raw text, WASD or keyboard CLICK shortcut. Mouse/touch
uses the circle without opening a text keyboard. Pending click confirmation locks
editing/Send; after3s a correlated read-only sync reconciles without replay.
Late acknowledgements retain one word across page changes. Pending prompts also
sync on timeout without resending a possibly paid submission. Physical timing is
judged on receipt with bounded grace; actual network/device QA remains pending.

Server-issued drafts fix each word's tier in advance. Clearing/editing/sync/pages
cannot reroll. Exclusive per-word odds: Common96.89% x1, Uncommon1/50 x3, Rare1/100
x10, Epic1/1000 x50, Legendary1/10000 x250. Only submitted words pay. Payout sums
the server's rarity and skill multipliers times the global base, respecting balance capacity.
Workers/agents/CPU improve base; context increases length; typing improves speed.
All purchases are global. New agents inherit workers; historical uneven valid
widths converge through upgrades without downgrades. At most8 agents/16 workers
per agent, CPU20. No real currency or monetization.

Independent rounded charcoal CLIs sit on an original procedural pixel wallpaper
inspired by the supplied dark purple orb, magenta/violet glow and warm lower rim.
Built-in PressStart2P pixel text and terracotta accents remain. No Explorer/sidebar,
resource rectangle, avatar or exterior. Each agent purchase adds a window; workers
do not. All exposed windows can foreground and titles can drag within desktop
bounds. Covered callbacks cannot activate/drag. Main remains the sole composer.

A prominent STATS CLI at the upper left shows money and actual earned money/s over
the last10s, plus session earnings, prompts, words, special counts, typing speed,
context, base and each rarity's odds/collected count. Money/s drops to zero after
idle; it does not award passive income. STATS has the same foreground/drag/occlusion
rules and a dock shortcut. CLI, Store and Guide are separate pages; purchases retain
Store scroll and switching pages retains draft. Small screens preserve readable
terminal size and use dock navigation rather than shrinking everything.

One confirmed positive receipt creates one solid +$ amount rising/fading over1.8s,
with eight labels maximum. Reduced motion is static. Simulated plan/edit/test/ship
jobs last1.4s with at most four pending previews and72 reused history labels. No
animation grants money or replays old receipts. No flashes or shake.

Initial synchronization retries are bounded and require the actual draft, not just
a balance. Unavailable servers show a finite error. Optional Studio tests cannot
prevent remotes starting. MEMORY is isolated and session-only. Native Studio,
device/performance and player validation remain pending; no retention claims.

Store has explicit Reconnect and reconnects when opened without a session. It can
recover after the initial retry cycle, preserving drafts and scroll. Mismatched
running versions request restart/rejoin; incomplete snapshots show a recoverable
error instead of leaving purchases loading indefinitely.

Fresh input queues start at current time, never a past frame. Server command advance
and submission use one captured timestamp, so correctly paced prompts cannot fail
from a later clock sample. A pending Send shows Typing.../Sending... and disables
duplicate clicks. The same flight, payout and timeout rules apply to both controls.

Words construct themselves rapidly letter by letter, about100 letters/s with a
120ms maximum and faster at high purchased typing speed. Chips reserve their final
size so text does not jump. Rarity color/border/badge remain visible. This is cosmetic:
Send/Enter and money do not wait for the animation. Reduced motion shows whole words
immediately. Font is Roblox built-in PressStart2P throughout; Store/STATS wrap and
scroll at readable size instead of scaling the entire interface.

Ember is a blocky terracotta mascot with cutout eyes, arms and four feet, inspired
by the supplied reference. Each agent has an independent decorative object:
32x20 in the main CLI title,64x40 beside background agent headings. Transparent
SVG and native rectangles share an editable catalog. Swap by ID without economic
state; different proportions fit the same slot. No extra button; cosmetic streak dance uses the existing loop.

Agent mascots dance to the confirmed streak. Low streak gives gentle sway/hops;
more hits progressively add speed, tilt and squash/stretch, capped at40 hits with
4.5 cycles/s and16-degree tilt. Each agent has a slight phase offset. Missing
restores neutral immediately. Fixed slots and bounded inner motion keep text and
window pointer areas steady. Main title and confirmed background agents animate;
unpurchased agents do not. Reduced motion leaves mascots static. Store/Guide, chat,
menus, modifiers, app blur and disconnected state pause motion without catch-up.
Swapping mascot artwork preserves the behavior. Dance is cosmetic, granting no
money or extra multiplier. Catalog SVGs remain unchanged static source artwork.

Audio plays an original soft elevator/lounge loop at fixed88 BPM, with seventh
chords, gentle melody, bass and quiet percussion. Streak never changes its speed. Fresh success clicks continue an eight-note pentatonic phrase.
GOOD and GREAT share each lead; GREAT adds a quiet octave. A miss resets the phrase. Eligible circle clicks give
immediate tactile feedback; fresh server-confirmed GOOD and GREAT add distinct
harmonic cues. Restored words and duplicate snapshots cannot replay success sounds.
Guide has separate Music/Effects levels (0/25/50/75/100%) and global mute, initially
50% each, session-local. Menu, app blur and disconnected state stop audio without
backlog. It uses bundled Roblox timbres and an original score, with no uploaded
track or external service. Native listening/mix QA remains pending.

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

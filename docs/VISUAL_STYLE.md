# VibeIdle visual direction

Latest0.72.0 user asks for smoother dynamic UI/text and black borders on most
elements. Use near-black2px window/common-token strokes and stepped pixel rims
on panels, cards, ordinary buttons and shop rows; keep colored rails/selection,
gold corners/rarity and terracotta faces inside. PressStart sizes stay native,
with a subtle black text stroke. Status copy can fade for0.18s, never interpolate
money or replace token letter reveal. Hover/focus is a small passive gleam with
fixed hit bounds. Navigation dips through an eased0.1s dark cover and reveals
over0.22s with8px movement; remove full-height bouncing pages. Include returns,
start and tutorial changes. Reduced motion is immediate; respect pause/cleanup.
Only the existing tick, no uploaded artwork/fonts or extra animation loops.

Latest0.70.0 launch UI: native pixel welcome panel and grey translucent tutorial
mask with one clear action hole, mint stepped outline and charcoal dialogue.
Native14px support text/16px lesson title,40px pixel actions, no uploaded art or
font. The circle temporarily occupies the full tutorial width and bottom safe
space; Shop hides while covered and SELL pans into view. A real visitor moves
cosmetically below the dialogue without changing its identity/reward. Narrow
layouts preserve font sizes, move the dialogue away from the hole and scroll
welcome copy on short screens. No new animation/loop; reduced mode is static.

Latest0.69.0 user direction: increase supporting letters and grow the surrounding
icons/cards/panels to fit. All five icon pages use generally14px subtext and16px
key values. Shared cards192x304, medallions144px, portraits96x60; Lab recipe
medallions192px/portraits160x100, Robux icons96px and skill icons64px. Keep pixel
geometry/native font, generous spacing and fewer columns with scroll on narrow
screens. Prestige summaries and cash bonuses stack; reset details scroll above
the explicit sticky action. No whole-interface scale reduction. See task112.

Latest0.68.0 Robux Shop matches Cards/Lab: charcoal striped backdrop, stepped
pink/gold card frames, terracotta title tag, centered shadowed captions and
authored native multicolor pixel icons. Full-width Forever Duo is framed in gold
and explicitly says permanent; three smaller cards below show1-hour money/Chips
and one run agent. Actual/target prices are distinguished; unconfigured buttons
say UNAVAILABLE. Agent prestige reset, real-time durations and final Roblox
confirmation are visible product information. Original16px storefront source
exports matching SVG/native art and renders48px in the fifth64px shortcut.
Responsive1..3 product columns retain208x40 buy targets. No external art/fonts,
upload, new loop or runtime SVG. See task111 and native QA limitations.

Latest0.67.0 uses64px top shortcut faces and48px native multicolor art (3x source
pixels), preserving black/gold hover silhouettes. A clipped horizontal shortcut
strip pans on narrow left workspaces while retaining full icon size. Money is
54px mint and Chips38px amber before measured fitting, inside a transparent
120px-high header with dark shadows/outline. Responsive clearance keeps Main
CLI/Shop/dock reachable; no global interface scaling. Fragment visitors show
only family/rarity until confirmed collection. One exact +N fragments label then
rises up to40px/fades over0.9s independently of the fading avatar,18px mint text
with a fading2px dark outline. Reduced motion is stationary. Vortex SFX is2.25x
louder through its existing effects channel. See task110; native QA pending.

Latest0.66.0 shares CollectionStyle between Cards and Laboratory. Both use
stepped pink rails/gold corners, faceted portrait medallions in family palettes,
violet framed panels with dark shadows, striped charcoal backgrounds and centered
shadowed pixel captions. Lab now has a compact terracotta title tag, Cards
navigation, horizontal family cards and four larger recipe cards.144px recipe
medallions use integer12px cells around128x80 static artwork; three resource
costs and40px buttons remain readable in1..4 columns. Fixed128x176 family cards
pan horizontally rather than shrinking on narrow screens. Native geometry
previews are generated from production constructors via mock services; their
fonts are approximate and they are not Studio screenshots.

Prestige lasts3.02s (2.1s suction/.12s cover/.8s reveal), using smooth eased root
motion and continuous prebuilt spiral/core group transforms. No per-frame strip
geometry rounding. Existing168 native parts remain bounded and passive; reduced
mode remains0.36s static. The quieter wind/low-tone SFX follows suction/release.
Actual device FPS, typography, clipping and listening QA remain Studio work.

Latest0.65.0 Lab is a charcoal pixel crafting page: nine family selectors with
fragment counts, four rarity recipe panels with static128x80 native portraits,
value/speed buffs, all three resource costs and40px CRAFT buttons. Common/rare/
epic/legendary use neutral/blue/violet/gold labels. Rare silver fins, epic violet
pauldrons and legendary golden crown/edge details retain each original family's
palette,16x10 bounds and transparent face cutouts. Matching36 SVG/native exports;
no upload/external font. Visitors keep their multicolor skin and readable family/
rarity/fragment badge, independent of streak. Cards display exact rarity below
portrait. Offline source sheet:build/agent-rarity-contact-sheet.png; native Lab
typography, clipping and pointer/device behavior still require Studio QA.

Latest0.64.0 prestige transition pulls actual native GUI roots and the original
orb wallpaper into three muted purple/terracotta spiral arms.144 rectangular
segments and24 stepped dark core spans stay bounded and passive above existing
game layers (DisplayOrder30).1.2s collapse,0.12s opaque handover,0.55s fade back
to normal Main CLI; no bright flash or copied Cookie Clicker artwork. Native
UIScale/rotation is temporary; fonts/layout return exactly. Reduced mode uses
an unrotated/unscaled0.36s fade; pause/resize/teardown remain explicit. A passive
dark backing always hides the exterior. Offline GIF/contact-sheet previews use
real motion equations over illustrative UI, not native Studio screenshots.

Latest0.63.0 replaces rectangular tree cards/vertical columns with an original
radial hex map inspired by the supplied image's composition. Keep the purple/
charcoal workstation identity; original stepped240x208 native faces,48px icons,
14px centered titles,11px effect notes and144x32 price targets. Branch palettes:
amber cash/memory, mint agents, blue streak, purple luck, terracotta collection/
cores. Locked faces dim; available paths use branch color and owned paths gold.
Native4px connectors sit behind nodes with passive dark shadows. Full3416x2704
canvas retains drag-pan/clip; CORE returns to center and the header counts54
unlocks. Existing PressStart2P and authored eight icon patterns are reused.
Reference art is guidance, never imported. No new uploaded art, loop or OS font.
Offline previews are geometry proxies with approximate text, not Studio images.

Latest0.62.0 keeps native tree/shop geometry and artwork. Shared currency text
adds T above B for trillions; existing responsive fitting and pixel font remain.
Guide describes stacking10x value milestones and growing shop prices. Tree
buttons use current server quotes; owned skills continue to display UNLOCKED.

Latest0.61.0 adds Lucky tokens I..IV in a fifth tree column, reusing native core
diamond icons and existing280x176 nodes/328px column spacing. Canvas1632x2304
retains grab-pan and clipping. Effect notes show total odds and new-draft timing;
Guide rarity rows show current exact percentages. No new artwork/font or loop.

Latest0.60.0 keeps the existing purple/charcoal pixel language and token sizing.
Skill tree has23 functional nodes on a1304x2304 grab-pan canvas, with existing
280x176 nodes, authored native icons, parent branches and readable effect notes.
A passive caption below the skill dial shows the general maximum streak and AUTO
when unlocked. The shop's idle status shows the lifetime stage and next target;
pending purchase/recovery messages keep priority. Prestige percentages reflect
owned Chip-memory skills. No external artwork/font, new loop or scrollbars on
the tree. See task102; older entries below are historical.

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

Latest0.26.0 Store override: exactly three square cards, Token value, Agent count
and Context. Use 1..3 columns according to width, minimum216px; no empty fourth
column or rows reserved for retired cards. Token value uses the authored amber
pixel coin icon and displays confirmed money/token plus level on two lines.
Keep all existing terminal/font/palette, page/scroll, focus and pointer rules.

Latest user direction2026-10-23: independent dark CLI windows, a fixed circular mouse skill check
and Enter/Send, independent colored token objects, prominent STATS CLI, no resource
rectangle or token toolbar. Pixel interpretation of the supplied purple orb wallpaper.
Supersedes XP/VS Code/sidebar, pinned main, shop drawer, gradient wallpaper and toolbar.

Busy agents/sends/full context no longer suppress the skill control. Keep the
same fixed circle/counters, immediate squash and pointer exclusions. Confirmed
busy presses queue server-awarded words, not stale input/timing attempts. Queued
words appear complete as validated capacity opens; the existing CLI title shows
QUEUED N. Do not add another panel, popup, timer or letter-animation queue.

Automatic words arrive individually according to independent server production
clocks, with slight timing variation and different agent phases. Do not conceal
once-per-second batches with a letter animation or a future-word visual queue.
At2+ actual combined agent words/s or8+ TPC, every arriving word is already
complete, without letter animation. Finish existing reveals immediately when
either threshold is crossed. Only slow output below both limits retains letter
reveal; Studio letter speed does not override this. Network/frame coalescing stays
bounded to small due groups.

Skill center is now a raised terracotta pixel button, with a darker lower base
and a full stepped dark projected shadow offset3px right/6px down. Squash only
the central cap and move CLICK slightly downward on press; ease back over0.14s.
Keep the native hit area, target ring, red orbit marker and side numbers fixed.
Rapid presses retrigger immediately without cumulative deformation or queued
animations. Use native passive integer rectangles; no smooth bevels, strokes,
external art or extra loops. Reduced motion and paused/hidden UI restore neutral.

Latest skill-control simplification: only CLICK and the two large side numbers
remain. Remove small TPC, xN w, NEXT HITS and footer status/result captions.
Each large number has one deliberate dark pixel-text shadow at+3px/+4px, matching
its font/scaling and sitting behind it. These two passive shadows are the sole
exception to the no-duplicated-text rule; do not use fake-bold outlines elsewhere.
Shadows must not enlarge pointer bounds, capture input or shift the main numbers.

At8+ effective tokens per click, show token text completely at once, including
automatic-agent text. Finish pending letter reveals when crossing the threshold;
do not alter chip size, badges, rarity colors or pointer geometry. Below8, new
tokens retain their existing letter reveal. Reduced motion remains instant.

- Original procedural32x18 flat pixel blocks depict a dark purple orb, violet/
  magenta glow and warm pale lower rim. Coarse blocks and16-step colors keep
  the pixel edges visible, without smoothing. No external wallpaper/image/branding/fonts.
  Charcoal terminals#1f1f23, titles#23242b, terracotta#cd7f61, ivory text, mint money.
  Rounded10px windows, one-pixel outlines, decorative dots with no fake commands.
- Built-in PressStart2P pixel font for terminals, money and controls. Body/
  token objects15px, no duplicated text or fake-bold outlines. Measure the font
  natively; tokens/badges need wider spacing than the old monospace family. Preserve wrapped logs.
  Welcome collapses after first accepted prompt and hides on short screens.
- Main CLI has a read-only composer and > prompt. Each authored word is a
  separate framed piece, wraps and scrolls. Each piece has a word label and border;
  special pieces have tier color, tinted background and an xN badge. Common grey,
  Uncommon green, Rare blue, Epic purple, Legendary gold. Reuse128 pieces. No +Token/Undo/Clear options. A single40px Send button sits beside count/speed;
  Enter and Send both submit;
  Backspace removes. Context/speed/Enter hint is small. Successful WASD events
  generate words at purchased rate. Full context never auto-submits. Pending request shows SENDING.
- STATS starts upper-left with an amber title/border, large mint money and earned
  money/s, then useful counts, speed/context/base and exact rarity odds/collected.
  Scroll on small windows. It is a real independent draggable CLI with dock shortcut,
  same foreground/occlusion rules. No money/resource bar outside STATS.
- Confirmed agents add windows, eight agents maximum plus STATS. Workers do not.
  Click exposed parts to foreground; main has no privileged layer. Covered targets
  cannot activate/drag. Main/dock/typing returns main. Titles drag inside desktop;
  positions survive purchases/clamp on resize. Agents are status, no extra composer.
- CLI/Store/Guide are dedicated pages. Store shows global upgrades, including Typing
  speed level/current/next tokens/s and cost. Buying preserves page/scroll/draft.
  Dock: Main CLI, Store, Guide, STATS, CLI cycle,40px controls in compact columns.
  Hidden pages suppress input/drag. On small screens retain readable terminal size.
- One mint +$ per positive confirmed receipt rises/fades in1.8s, solid first, eight
  labels maximum. Reduced motion is static until expiry. No particles/shake/
  flashes/endless cosmetic loops. Use dollars, two decimals below1K then K/M/B.
- Fullscreen opaque backdrop/safe insets, no avatar/exterior/sidebar. Preserve main
  text scale; never shrink the whole UI. Store uses own page, not a reserved column.

Native Studio QA remains pending:360x640,1280x720,640x360, full128-token scroll/
focus/IME/mobile keyboard, nine windows, STATS reachability/drag, all occlusion,
pixel wallpaper and real hardware UI cost. See TESTING.md.

Store keeps a compact Reconnect control in its title area. Show finite recoverable
connection/build messages and confirmed prices; never simulate money or purchases.

Letter reveal: about100 letters/s, maximum120ms per word, shortening within the
purchased typing interval. MaxVisibleGraphemes keeps full chip geometry stable;
caret follows visible characters. No bouncing/shaking/resizing the chip. Reduced
motion is instant. Use auto-sized STATS rows and taller wrapped Store cards for
pixel font readability; no whole-interface shrinking or external font assets.

Skill check: fixed charcoal CLICK circle, bottom center above dock.120px diameter
in148px reserved vertical space,84px in112px for short screens.90 native arc
segments: muted track, mint good and amber great zones, starting at72/24 degrees and shrinking with streak. White
clockwise needle, centered pixel CLICK, static result/bonus caption below. No
WASD popup, random screen position or keyboard action. Ring stays outside CLI
content; Store/Guide use full content height while the control is hidden. Header/
composer retain native scale on short screens; hide log when space is exhausted.
No extra cosmetic spin/pulse/shake/flash. Essential needle motion uses shared
server time even with reduced motion; only active input animates. Confirmed token
badges show combined rarity/skill multiplier and preserve tier colors.

Ember: terracotta#d87959 pixel creature, transparent eyes/background.11 native
rectangles match its SVG. Main title uses32x20 instead of its decorative dots;
background agents use64x40 beside a wrapped heading, above details. Independent
reusable objects, fixed16:10 slots, centered fit for other shapes. No backplate,
click action or animation.

Streak uses the same circle geometry: a compact9px count/factor below CLICK,
inside the ring, and next multiplier milestone in the existing lower caption.
Result feedback temporarily replaces the milestone; STREAK LOST marks a miss.
Server-issued widths drive actual segment colors; essential needle accelerates
from2.4s to1.2s at40 hits. Green/gold widths cap at28/8 degrees. No extra animation,
flash, popup or vertical area. STATS scroll contains current/best streak and factor.

Streak dance overrides the earlier static-mascot direction. Animate only an inner
mascot group with gentle sway/hop at low streak, increasingly quick tilt/bounce/
squash through40, capped4.5Hz and16 degrees. Rotated/scaled corners must stay in
its fixed slot so no text/window/input shakes. No flashes/color cycling.
Main title mascot and confirmed agents use distinct phases. Zero streak is neutral;
reduced motion is static immediately. Pause off-page/chat/menu/modifiers/app blur/
disconnected, without elapsed-time catch-up. Keep SVG source artwork unchanged.

Audio follows the user's later sound direction: gentle ambient original score,
gradually more rhythmic/faster with confirmed streak, capped at40. Soft immediate
click, distinct GOOD/GREAT harmonic cues, no sync replay. Keep music/effects modest
and independently adjustable with global mute in Guide; no new HUD rectangle.
Use bundled Roblox timbres, no imported track. Native listening QA pending.

Latest direction0.12.0: continuous needle, no success restart/pending freeze.
Large standalone streak count right of ring, equal-diameter box and no backplate;
fit multi-digit count without moving circle. Multiplier remains inside circle.

Latest0.12.2 overrides reserved skill movement area: CLIs can drag across full
root viewport. Skill/streak overlay always draws above Pages, with pointer priority
over covered CLI callbacks. Keep readable initial sizes, bounds and dock access.

0.13.0: replace needle artwork with a small round red dot orbiting radius0.43.
Continuous angle/server zones unchanged. No line from center. Ring lower label
shows effective words/click; large right-hand streak and top pointer priority stay.

Latest0.13.1 audio override: fixed sustained tonic bed; no adaptive music speed,
chord changes or streak layers. Confirmed successes continue an eight-note phrase
by server streak; Good/Great share lead, Great adds quiet octave. Softer tactile
click and short reverb/tails connect notes. Keep mute/levels, dedup and teardown.

Latest0.13.2 background override: original elevator/lounge loop with mellow seventh
chords, keyboard melody, bass and quiet percussion at fixed88 BPM, no streak tempo
changes. Keep connected click phrase and independent levels/mute. Existing tick,
bounded16 music/6 effects voices, no external tracks or uploaded assets.

Latest0.14.0 overrides fixed5 and fixed music: resolve server-owned C centrally
via Rules.streakDivisor, Store upgrade_divisor reduces5..2. Words/click = base *
(floor(streak/C)+1). Music lounge below C, rock I-IV at C/2C/3C/4C; increasingly
fast/dense with capped distortion. Snapshot C drives UI/music; no client C/price/
level allowed. Schema9 divisorLevel0..3 migrates1..8 under leases, isolated MEMORY.
Old awards immutable; keep all nonce/draft/payout/pool/mute safeguards.

Latest0.14.1: empty CLI background clicks/taps may activate skill. Keep transparent
nonselectable target below Pages, press-start identity and spatial exclusion of
visible CLIs/STATS, dock and skill/streak bounds. No drag-release or click-through
actions. Reuse exact skill pending/readiness/pause/protocol and server grading.

Latest0.15.0 permits random decorative background agent dancers on fresh confirmed
GOOD/GREAT clicks. Reuse native2D AgentMascot artwork and existing heartbeat; pool
cap10, fade/expiry, tempo-driven dance, below main UI and passive to all input.
Respect swaps, purchased agents, reduced motion, pause/teardown and no replay.
No 3D/exterior avatars, external art, new remotes or rewards.

Latest0.15.1 permits red/orange fire around skill circle. Grow with confirmed
streak through40, cap geometry/speed, animate through existing tick. Passive
native tapered curved strips behind circle/count; never alter pointer bounds or
cover dot/text. No flashes, extra loops or external art; reduced motion static.

Latest0.15.2 permits floating pixel phrases on each eligible skill press, normal
or special, via same onPress path for circle/free background. Pool12,1.4s rise/fade,
passive overlay below skill/fire/count, static reduced mode and full pause/cleanup.
No input capture, sync replay, extra timers/events, tokens or money from words.

Latest0.16.0 Store: square upgrade cards in1..4 column scrolling grid,216px
minimum, name top, colored authored SVG/native pixel icon center, status and
Buy/price bottom. Palette charcoal/mint/amber/terracotta, readable native font.
Keep all global purchases, prices/caps/reconnect and page/scroll preservation.
Edit assets/store/catalog.json; generate_store_icons.py exports SVGs/native
catalog. Verifier checks equality; never require external art/font uploads.

Latest0.16.1 overrides timed dancers/empty-space placement/clear-on-pause: use
full viewport positions including behind CLIs/dock. Keep avatars for streak duration
without replacing active pool slots; cap10. Pages/chat/focus pause motion only.
Loss/reset triggers0.65s opacity fade, also with reduced motion; destruction cleans
up. No timer expiry or page-switch clearing. Keep passive backdrop input/layering.

Latest0.17.0 overrides manual-only generation: agent_type timed server grants
owned agents * current TPC at up to1 batch/s, context-clamped, through existing
paced queue/full auto-send. Neutral Agent awards never build/break streak. Store/
Guide automation continues; chat/menu/focus pauses. requestId/draftId/tokenIndex
only; correlated read-only agent_sync; no client amount/TPC/time/grade. No direct
time payout, paid prompt retries or offline catch-up. Same large-style TPC left
and Nx streak right; counters retain foreground pointer priority and fit narrow
screens. Schema9 and isolated MEMORY remain, session bookkeeping only.


Latest0.18.0 overrides background layering: streak celebration avatars are
independent StreakAvatar objects, with stable ID/source, appearance/position,
dance and fade lifecycle. Dedicated full-screen passive ScreenGui DisplayOrder21
renders above workstation20 including CLIs/pages/skill controls. Preserve input
pass-through, cap10, persistence until streak loss and0.65s fade, reduced motion,
existing heartbeat and teardown. No server/economy change or new assets.

Latest0.18.1 overrides procedural strip fire: use user-supplied SVG frame artwork
from assets/skill-fire, compiled offline by tools/generate_skill_fire.py. Five
original pixel colors,12 frames at10fps per low/medium/high tier, at1/C/2C streak.
Align source circle center/27px diameter to real button; omit black pixels at
runtime. Keep253 passive parts behind button/counters, unchanged click bounds,
reduced-motion static frame, pause/miss/cleanup and existing heartbeat only.
No runtime SVG/HTTP or asset upload. Streak-avatar foreground21 remains above it.

Latest0.19.0 overrides fire/global typing: skill fire disabled for now; preserve
its source without constructing parts or ticking it. Manual grants append at
once and next skill check has no typing cooldown; no prompt-wide typing budget.
Keep nonce, context, packet limiters, one-flight and prompt cooldown safeguards.
Agent typing speed upgrade only (same schema9 typingLevel/upgrade_typing),4..44/s;
server Auto.advance/grant enforces one-second agent-only budget, no idle catch-up.
Manual words/payouts never spend that budget. Automatic tokens lock multiplier
1 + serverStreak*0.1 at generation, times rarity; never build/break streak or
reroll via edit/sync/loss. STATS/Guide reflect agent-only speed and token bonus.

Latest0.19.1: skill check uses PixelSkillDial's stepped24-grid circle face/rim,
axis-aligned square target samples and red5-grid pixel marker. Native passive
geometry, integer local layout,90 existing4-degree samples. Continuous server
phase; counter-rotate marker to keep pixels upright. Preserve circular hit test,
font/TPC/Nx and foreground input priority. No smooth UICorner/UIStroke in dial,
new loops/assets or fire. Server/economy/agent speed and buffs stay unchanged.

Latest0.19.2 overrides shared agent speed: each owned agent has its own server
budget at4..44 words/s and independent time/rate; global upgrades apply to each.
New agents accrue from purchase time only. TPC/cadence/context still bound output.
Combined client queue must use summed speed, so buying agents increases words
and visible typing capacity. Store/STATS/Guide distinguish per-agent/total caps;
composer capacity refreshes immediately on purchase. Preserve all manual, nonce,
locked streak/rarity and profile/persistence guards. No fire or new loops/assets.

Latest0.20.0 overrides mixed queue/summed typing clock: every agent has its own
server nextAt and speed budget; only its accepted grant changes that deadline.
Player clicks and prompt sends never reset them. Server returns source counts
and absolute next-agent time. Compose accepted words atomically; independent
agentRevealTimes handle cosmetic letters without blocking player/other agents.
No nextType/lastTypedAt shared clock or manual flush of agent animations. Commit
late manual receipts off-page, avoiding an agent-blocking pending word queue.
Prioritize already due automation after manual reconciliation while preserving
one in-flight shared-prefix mutation. Separate agent24/s burst16 packet limiter
from skill48/s and general10/s. Keep nonce/context/payout/reconciliation, schema9,
locked streak buffs, pixel skill/no fire and existing heartbeat/pause safeguards.

Latest0.20.1 prioritizes skill check above other game UI: dedicated ScreenGui22
above workstation20 and streak avatars21, matching safe insets/root size. Capture
mouse/touch press-down by circle geometry through UserInputService.InputBegan,
without hover dependence; keep native button Active through pending/ready state.
Dynamic eligibility stays controller-side; reject chat/menu/page/drag/pending and
context violations. Suppress release Activated after tracked pointer gestures,
no repeated holds or stale queued timing attempts. Preserve free-background and
covered-CLI guards and independent agent clocks; disconnect listener and destroy
priority surface with main GUI. No new loops/assets/server changes.

# Verification and pending Studio QA

Latest0.72.0: full tools/verify.py PASSED302 pure specs (120 baseline +163 prompt
+19 commerce),251 production callback cases,65 syntax sources, art equality and
deterministic107-instance/62-source export. Log:build/fluid-interface-verification.log.
After the final deferred-focus fix for reduced motion while menu is open,
5 animated cases and deterministic export passed again (fluid-interface-focused.log,
fluid-interface-export.log). These test cover/commit/reveal bounds and blocked
actions, scroll/draft preservation, pause/no catch-up, reduced mode/resize/gamepad
focus, status opacity/money timing, clipped hover/fixed hit bounds and mid-effect
teardown, start/tutorial receipts and once-only dismissal. Existing server,
commerce, analytics, input and receipt regressions pass. Historical fixtures use
immediate presentation so they continue isolating their gameplay behavior.

Viewed16 production-geometry previews: preview_laboratory.py --ux. Includes
wide/narrow Lab/Cards/Prestige/Skill tree/Robux/Start, three page fade phases and
scrolled recipes. Renderer now composites alpha and refreshes its draw context;
approximate font/geometry does not prove native UIStroke, PressStart rendering,
touch/controller behavior or FPS. Studio input/visual/performance QA remains.
No economy/schema/asset/protocol or external-service change, no publication.

Latest0.71.0: tools/verify.py PASSED302 pure specifications (120 baseline +163
prompt/progression +19 commerce),246 production callback scenarios,64 syntax
sources, art equality and deterministic106-instance/61-source export.
Evidence:build/player-behavior-analytics-verification.log. Coverage includes
schema18 migration/strict counters/maps/history/copy/prestige/reload; separate
wire snapshots without analytics versus strict stored data; monotonic session
time; capped/deduplicated client estimates with no gameplay authority; FIFO
batch/rate/queue limits and native/log failure containment; premium metric
atomicity with benefit/proof despite save/archive/retry and cancellation/pass
ownership distinction; confirmed core/upgrade/visitor dedup, read-only reports
and cloud save/reentry/offline lookup. Existing economy/UI/nonce/leases pass.

Native AnalyticsService and real Creator Hub dashboards were not exercised.
Mock calls validate authored event shapes/budgets and gameplay isolation, not
platform delivery or report availability. Published cloud/Marketplace, native
input and real performance remain QA. No UI style/asset change, external HTTP,
publication or real purchase. Usage/metric interpretation:PLAYER_ANALYTICS.md.

Latest0.70.0: full tools/verify.py PASSED295 pure specifications (115 baseline
+163 prompt/progression +17 commerce),243 production callback scenarios,64
Lua-compatible syntax sources, art equality and deterministic106-instance/
61-source build/VibeIdle.rbxlx. Evidence:build/launch-onboarding-verification.log.
After a final menu copy correction (MEMORY does not persist between visits),
reran the8 new UI/cloud callbacks and deterministic export:
build/launch-onboarding-final-ui.log and build/launch-onboarding-export.log.

New coverage: schema16->17 flag migration/strict types/copy/prestige/reacquire;
cosmetic-only protocol; lease timestamps after delayed UpdateAsync; start menu
profile/draft readiness and blocked actions; actual Skill->SELL->Visitor cycle
with delayed replies; masks and nonoverlapping dialogue/action on narrow/short
viewports; skip/replay/focus/modifier/teardown; offline/mixed/invalid bounded
reconnect; suppression of owned Auto check/Auto sell; published cloud save/exit/
rejoin and failed loads; save-delay status/expired lease; Studio isolation.
Mocks use coroutine-scheduled autosaves and in-memory UpdateAsync copies, never
real DataStore. No new test weakens existing receipt/payment/input protections.

Reviewed12 production-constructor geometry previews via preview_laboratory.py
--onboarding (1280x900/360x640 and320x360 skill/visitor). Approximate font and
transparency rendering do not prove native PressStart wrapping or hit testing.
Real Studio type checking, mouse/touch/controller navigation, safe insets,
mobile SELL access, performance, cloud reentry/concurrency/shutdown and premium
receipts remain explicit QA in LAUNCH_READINESS.md. No publication/live charge.

Latest0.69.0: full tools/verify.py PASSED292 pure specifications (112 baseline
+163 prompt/progression +17 commerce),235 production callback scenarios,63
syntax sources, generated art equality and deterministic105-instance/60-source
build/VibeIdle.rbxlx. Evidence:build/readable-feature-pages-verification.log.
Existing geometry expectations now reflect larger cards/icons/deck positions;
behavioral clipping, pan, guarded selection, purchases, nonce/reconciliation,
prestige and billing regressions remain passing. No new mirror tests added.

Reviewed production-constructor geometry exports at1280x900 and360x640 for
Lab/Cards/Prestige/Skill tree/Robux, plus recipe/offers/dashboard scroll positions.
Run tools/preview_laboratory.py --readability; images/TSV live in build/readability-*.
These mock previews use approximate Consolas, not native PressStart rendering.
Native Studio font wrapping, touch/gamepad scrolling, very short screens and
performance remain pending; no live Marketplace purchase or publication.

Latest0.68.0: tools/verify.py passes292 pure specifications (112 baseline +163
prompt/progression +17 commerce),235 production callback scenarios,63 syntax
sources, generated art equality and deterministic105-instance/60-source export.
Evidence:build/robux-shop-verification.log. Billing tests cover time extension/
expiry/2x cap, confirmed money/capped unpaid rewards, boosted base-Chip accounting
and41,600 cap, run-agent inheritance/cap credits, schema16 strict fields and
schema15 leased migration, identity-only payloads, native prompt no-grant,
save-before-archive order, retry/crash/concurrent/dedup behavior, unavailable/
unknown/absent/lease-error receipts, proof-only reconciliation and server pass
ownership. Page callbacks cover collection style/target prices, localized quote
display, explicit SKU/nonce only, clipping/hidden/menu/chat/modifier/blur/pending,
native-size responsive layouts, correlated CHECK/no paid retry and free credits.
Existing payouts, collectible/skill/agent clocks, prestige and visual regressions
remain passing.

Viewed mock production-geometry previews from preview_laboratory.py --robux:
build/robux-shop-overview.png, robux-shop-offers.png, robux-shop-mobile.png.
They use approximate fonts and do not establish native typography/focus/touch/
gamepad/performance. All actual purchases remain disabled (user requested IDs
later); no Robux was spent and no products/pass/experience were published.
Live Marketplace/DataStore delivery and Luau type checking remain pending.
Setup and primary Roblox references:docs/ROBux_SETUP.md.

Latest0.67.0: tools/verify.py passes275 pure specifications,230 production
callback scenarios,59 syntax sources, generated art equality and deterministic
101-instance/56-source export. Evidence:build/fragment-header-feedback-verification.log.
New callback checks cover hidden visitor offers, no effect before receipt,
exact/zero/capped confirmed text, rise/fade including outline, read-only/duplicate
dedup, expiry/rejection/drop no-ops, hidden/blur pause, reduced stillness and
teardown. Header checks exercise64px targets/48px art, native narrow scrolling,
clipped pointer rejection, foreground priority and54/38px fitted currency text.
Historical drag fixture now uses an uncovered title point beyond the wider HUD;
covered-pointer rejection remains enforced. Existing vortex voice/mute/pause,
crafting/resource/prestige and retry safeguards remain passing after2.25x gain.

Viewed build/header-fragments-wide.png and header-fragments-narrow.png from
tools/preview_laboratory.py --header. These use production mock geometry and an
illustrative receipt, with approximate fonts and mock CLI log placement; they
are not Studio screenshots. Native typography/scroll/touch/gamepad behavior,
device FPS/listening and Luau type checking remain pending. Only
build/VibeIdle.rbxlx rebuilt; no publication.

Latest0.66.0: tools/verify.py passes275 pure specifications (112 baseline +163
prompt/progression),226 production callback scenarios,59 syntax sources, art
equality and deterministic101-instance/56-source export. Evidence:
build/laboratory-prestige-polish-verification.log. Tests cover3.02s monotonic
eased phases/finite continuous geometry, unchanged per-strip positions/sizes
while parent groups animate, paused terminal/hidden Cards work, confirmed once-
only transition +three pooled SFX voices, swept pitch/volume/finite envelopes,
mute/effects0/pause/no replay/teardown, shared Cards/Lab native art, horizontal
family clipping and responsive recipe targets. Existing crafting, migration,
nonce/payout/recovery and reset/restore scenarios all remain passing.

Viewed production-constructor geometry previews (approximate font/mock sizing):
build/laboratory-polish-overview.png, laboratory-polish-recipes.png and
laboratory-polish-mobile.png, generated by tools/preview_laboratory.py. Updated
vortex GIF/contact sheet samples live motion at60 samples/s over illustrative
UI; not native FPS evidence. Verified built-in action_falling.ogg in installed
Roblox content; no external audio/asset upload. Native Studio/device typography,
clipping, actual frame rate/performance, SFX listening/mix and Luau type checking
remain pending. Build only build/VibeIdle.rbxlx; no publication.

Latest0.65.0:274 pure specifications (112 baseline +162 prompt/progression),
223 production callback scenarios,58 syntax sources and deterministic100-instance/
55-source build. All pass in build/agent-crafting-verification.log.36 generated
SVG/native skins match the catalog; rarity trim preserves transparent interior
cutouts. Source contact sheet generated/viewed via preview_agent_crafting.py.
Coverage includes recipe sufficiency/atomic debit/dedup, no lifetime gains,
combined Chip ledger and full affordability, schema14 lease migration/historical
caps/unknown IDs, dense fragment validation and prestige retention, four visitor
tiers/all nine families, deadline/nonces/TTL/no-catch-up/pool/receipt bounds,
fragment cap/locked skill bonus/no streak renewal, late/stale/read-only recovery,
pointer layering/expiry/reduced motion/pause/teardown, Lab family/recipe selection,
responsive native sizes/clip/hidden/menu/chat/modifier/blur/pending guards and
exact card-variant equip/locked award/speed cap behavior. Obsolete live skill-
spawn/streak-reward scenarios were replaced; historical pure helpers remain
regressed separately. No new heartbeat, paid retry or external service. Native
Studio layout/text/scroll/pointer/device/performance QA and Luau type checking
remain pending; mock services and source-art sheets do not establish those.

Latest0.64.0:262 pure Specs,226 production callbacks,57 syntax sources, generated
art equality and deterministic99-instance/54-source export. Evidence:
build/prestige-vortex-verification.log. New motion tests cover phase/geometry
bounds and static reduced mode. Production tests exercise confirmed once-only
start, late read-only recovery, review/drop/rejection/baseline/unrelated no-ops,
actual root transform properties, gameplay/gamepad exclusion, CLI restore,
simulated responsive-size callbacks, pause/no catch-up, preference switches,
resize, disconnect and teardown. Contact-sheet preview was viewed; its GIF uses
real motion over illustrative UI, not native engine rendering. Actual UIScale/
rotated clip behavior, typography and device/performance QA still need Studio;
Luau type checking remains pending. See task107.

Latest0.63.0:260 pure Specs,221 production callbacks,55 syntax sources, generated
asset equality and deterministic97-instance/52-source export. Evidence:
build/expanded-tree-verification.log. Added complete54-node DAG/budget/placement/
hex/link checks; exact10,000-ticket max luck distribution; each branch's effects;
schema13 ->14 leased migration without new Chips; new-ID/legacy-discount/old-cap
refusal. Actual page callbacks cover54 passive hexes, CORE centering/visibility/
menu/teardown, new price/nonce/reconnect/payouts,320px header fitting and105 manual
checks capped at100 with zero words/money. Offline PNG geometry proxies were
inspected (approximate text, not Studio). Pure module is included in optional
deferred Studio and CLI runners. Native rendering/input/performance/device QA
and Luau type checking remain pending. See task106.

Latest0.62.0:256 pure Specs,218 production callbacks,54 syntax sources, generated
asset equality and deterministic96-instance/51-source export. Evidence:
build/inflation-verification.log. New coverage verifies exact value milestones/
price curves, finite extreme levels, complete tree reachability, schema12 ->13
frozen-debit migration, mixed old/new exact Chip sums, legacy-map validation,
copy/reset preservation and lease refusal/save. Production cases verify milestone
shop previews and confirmed sale amounts, T formatting, capped lifetime earnings,
grandfathered ownership with new-price purchases and read-only reconnect.
Real-module model/curve/price CSVs include the frozen0.61 comparison and reached
flags; assumptions are in task105. Native Studio rendering/input/device QA and
Luau type checking remain pending.

Latest0.61.0 full verifier:253 pure Specs,216 production callback scenarios,
54 syntax sources, generated-asset equality and deterministic96-instance/51-source
export. Evidence:build/token-rarity-skills-verification.log. Rarity tests enumerate
all10,000 tickets at each of five boost levels, verify unchanged old offers and
award/payment multipliers, context extension, skill costs/parents/once-only buys,
save/prestige retention and forged input rejection. Production callbacks exercise
all four luck nodes, fifth-column bounds, live Guide odds, old Common/new Rare
sales with the same RNG ticket and late/lost/duplicate purchase receipts. Native
Studio rendering/input/device QA and Luau type checking remain pending.

Latest0.33.0 verifier:211 pure Specs,159 production scenarios,50 syntax sources,
92 instances/47 sources, deterministic export and generated art equality.
Evidence:build/skill-tree-icon-verification.log. Existing top-feature interaction
scenario now checks all3 buttons across1280x720,360x640,640x360 and320x360, their
nonoverlapping48px targets/32px art, tree selection/coming-soon feedback and no
money/token/network changes. Generated checks include the colored tree SVG/native
coverage. Artwork review:build/feature-icons-preview.png. Native Studio visual/
input/font/touch/gamepad/device QA remains pending.

Latest0.32.0 verifier:211 pure Specs,159 production callback scenarios,50 syntax
sources,92 instances/47 sources, deterministic export and mascot/store/feature
asset equality. Evidence:build/agent-lab-verification.log. New production cases
verify9 distinct silhouettes (Ember plus8), multicolor native/source equality,
original11-part Ember, exact per-CLI selection with no commands/charges, live
object/slot/dance reuse, static thumbnails, independent choices across purchases/
pages/snapshots/four viewport shapes, owned-only target cycling, and hidden/
clipped/covered/menu/blur/drag rejection plus teardown. Old top-icon test now
expects Laboratory to open its appearance area; Cards remains a placeholder.
Artwork review:build/agent-roster-preview.png. Native Studio visual/font/render/
touch/gamepad/listening/device/performance QA remains pending.

Latest0.31.0 verifier:211 pure Specs,156 production callback scenarios,49 syntax
sources,91 instances/46 sources, deterministic export and store/feature asset
equality. Evidence:build/top-feature-icons-verification.log. New checks exercise
both top buttons across1280x720,360x640,640x360 and320x360; verify48px hit targets,
integer32px passive art, selection/coming-soon feedback and Guide visibility;
assert no token/draft/credit/request/page changes; and reject covered CLI/free
skill callbacks, drag/menu/blur/avatar overlap and stale teardown activation.
Artwork review:build/feature-icons-preview.png. Native Studio focus/font/rendering/
touch/gamepad/listening/device QA remains pending.

Latest0.30.0 verifier:211 pure Specs,154 production callback scenarios,48 syntax
sources,90 instances/45 sources, deterministic export and generated asset equality.
Evidence:build/fixed-shop-verification.log. New pure geometry covers1..8 windows
at320x360,360x640,640x360,900x640,1280x720 and1920x1080 with a fixed right panel.
Production checks cover permanent visibility on CLI/Guide, Store focus and global
purchases without suspension/draft loss, integer multicolor art, narrow canvas
pan/native text, free-skill/covered-window exclusion, exact server debit, drag
rejection, ongoing sequential collection, popup resize bounds and valid scroll/
Reconnect preservation. Older page-pause tests now use Guide. Existing pixel art
coverage verifies every colored source cell equals its SVG and native geometry.
Artwork-only review:build/store-icons-preview.png. Native Studio panel/font/input/
scroll/touch/gamepad/listening and hardware QA remain pending.

Latest0.29.0 verifier:210 pure Specs,150 production callback scenarios,48 syntax
sources,90 instances/45 embedded sources, deterministic export/asset equality.
Evidence:build/token-collection-verification.log. New pure tests cover compact
capped per-token amounts, rejected client amounts, ordered once-only consumption,
malformed/baseline/reset receipts, pause, bounded backlog/stalled frames/popups.
Production checks cover delayed receipt gating, one disappearing chip per step,
coin dedup, rising per-token money, rarity/skill rewards and0-money cap clipping,
page/chat/menu/focus pause, static reduced motion, mute/levels, repeated sales,
new unsold words, off-page acknowledgements, teardown, and128 sold plus128 unsold
chips across desktop/portrait/short sizes. No animation changes the server money
or creates a sale. Existing agent/skill stress and manual-only sales still pass.
Native Studio visual/listening/fonts/touch/gamepad/network and hardware QA remain
pending; callbacks with mocks cannot prove native rendering or sound quality.

Latest0.28.0 full verifier:206 pure Specs,144 production callback scenarios,
47 syntax sources,89 instances/44 sources, deterministic export and asset checks.
Evidence:build/manual-sell-verification.log. New scenarios prove full manual,
skill, agent and queued-token contexts never sell from idle/sync/reconnect,
pages/focus or delayed off-page receipts. Explicit Enter/SELL still shares one
payment flight with no duplicate/retry; direct dispatch without intent rejects.
Button checks cover native passive stepped parts, unchanged96x40 hit area,
PressStart text, no UICorner/UIStroke, disabled states and reused instances.
The eight-agent96 words/s stress now simulates explicit player SELL presses,
asserting every submission has a matching press; production never infers one.
Native Studio input/touch/gamepad/font/rendering QA remains pending.

Latest0.27.0 full verifier:206 pure Specs,140 production callback scenarios,
47 syntax sources,89 instances/44 embedded sources, deterministic export and
asset equality. Evidence:build/all-tokens-verification.log. New pure cases cover
full128 legendary/streak-badged token geometry and monotonic retained growth.
Production checks hold a full128-token prompt in flight, for Common/Legendary
at1280x720,1920x1080,360x640 and640x360, then resize back. Every reused chip must
fit the expanded composer, keep15px text, and remain visible without a nested
scroller. Overflow desktop scrolling reaches Send above the skill/dock reserve;
pages, covered pointer checks, acknowledgement and once-only payout remain.
Mock scrolling now offsets child absolute positions like native canvas movement.
Native Studio text measurement/rendering, scroll/touch/gamepad, input hit testing
and hardware/device QA remain pending; these mocks do not prove engine behavior.

Latest0.26.0 full verifier:204 pure Specs,138 production callback scenarios,
47 syntax sources and deterministic export (89 instances/44 sources). Evidence:
build/three-upgrades-verification.log. New production cases cover exactly three
Store cards, confirmed token price/base payout, same-draft context expansion,
scroll/page preservation, all three caps and retired commands rejecting before
charge/grant. Responsive grid checks also reject extra rows for removed cards.
Historical pure economy tests and client progression fixtures intentionally retain
old levels to regress saved-profile bonuses without exposing retired live buys.
Native Studio/device/font/rendering/input QA remains pending.

Latest0.25.0 verifier:204 pure Specs (111+93),135 production callback scenarios,
47 syntax sources and deterministic two-pass export (89 instances/44 sources).
Evidence:build/skill-queue-verification.log. New checks cover ID-only queue input,
immediate server grading, atomic capacity/RNG/nonce rejection, paced drains,
immutable bonuses after expiry, context rollover, restoration, reset, bounded
handover, delayed prompt replies, duplicate/lost packets and Studio queue controls.
Production stress runs eight agents at96 words/s initially,50ms delayed replies,
concurrent skill presses, queued drains and repeated full-context sends. These
are real production callbacks with mock services, not native FPS/network evidence.
Native Studio multi-client/device/render and performance QA remains pending.

Latest0.24.1 full verifier:198 pure Specs,131 production callback scenarios,
47 syntax sources, deterministic two-pass export (89 instances/44 sources).
Evidence:build/instant-output-verification.log. New checks cover complete words
at2+ actual combined output even below8 TPC, finishing current letters off-page,
slowing below the threshold, typing cap versus output and Studio letter speed.
Native Studio rendering/network/device QA remains pending.

Run python tools/verify.py here. Current full pass:183 pure Specs (111 baseline,
72 manual prompt/typing/STATS/reveal/skill/streak/dance/audio),102 production server/client callback scenarios,
45 Lua-compatible source/test syntax checks, deterministic two-pass export/source
equality,87 instances/42 embedded sources and disabled avatar spawn/clipping.
Portable Lua5.4 execution is not Luau type checking or Roblox rendering.

Pure checks include authoritative/global purchases, strict ID/count-only protocol,
immutable offers/exact odds, capped/atomic money, stale/duplicate/cooldown/fast-rate
rejection, queued composition models, late receipts, bounded feedback, schema1..6
typing migration/schema7 corruption/leases, old-rate settlement, bounded STATS
rolling history and128-token object wrapping at multiple widths. Legacy passive,
automatic transport and neural helpers stay regression fixtures outside live code.

ClientSmoke now runs real GameService/server Bootstrap/Telemetry/Config alongside
real client Bootstrap/TerminalController/Desk/Theme/PixelWallpaper/SkillCheckController/AudioController. Fake services,
Instances, input/focus signals, remotes, deterministic RNG and clocks enable63
scenarios: Enter-to-money, finite queued Enter, processed/mobile Return dedup,
colored individual tokens, repeat global purchases, speed upgrades, context/Backspace,
page ownership, STATS/agent foreground occlusion, missing-draft sync recovery,
finite unavailable state, missing/failing Studio tests with live payout, actual
10-second money/s, timeout/late receipt without retry/replay, external input guards
and bounded procedural wallpaper. Skill/streak checks cover circle geometry,
server timing/grace, fresh/reused words, multiplier thresholds/caps and input guards.
Audio checks cover score/tempo/envelopes, bounded voices, confirmed cue dedup,
independent levels/mute, focus/menu/disconnection, teardown and failure isolation.
Legacy queue/payout regressions inject words through queueWords independently of
the new QTE adapter; QTE scenarios use production key/click callbacks. The harness is CLI-only, not in the place.
Native event routing, rendering, font selection and actual networking are not modeled.

Both pure suites run as optional protected deferred Studio tests AFTER GameService
starts. CLI tests remain mandatory for verification. No installed runtime/dependency;
preinstalled Python plus Wireshark/lua54.dll API504 used. MEMORY/telemetry-off remain.
No actual DataStore records read or migrated; private persistence QA required before
changing storage mode, never NeuralIdle's namespace.

Pending native QA (not executed):
- Open current build/VibeIdle.rbxlx and restart Play. Verify server starts even if
  optional Specs modules are missing/fail. Confirm initial sync yields a draft and
  ready Store; delayed/lost startup cannot leave indefinite Connecting.
- Click/tap the fixed CLICK circle. Green gives GOOD x1.5, gold GREAT x2 and
  outside zones a normal word breaking current streak. One word per confirmed
  challenge. Arbitrary keys/paste/corners and repeat clicks cannot add extra words.
  Check server-time needle phase, latency grace and actual paid bonuses on Send.
- Verify pause/resume on Store/Guide, full context, in-flight request, chat,
  shortcuts, menu and app blur; server-time needle resumes without idle reward.
  Events stay above all windows and inside safe bounds at360x640/1280x720/640x360.
  Mouse/touch on the circle cannot activate/drag/send through a covered CLI.
- Enter or Send pays once, with no automatic submission. Touch must work without
  opening the native keyboard. Check native focused Return fallback and processed
  input routing; the old text/paste generation route must remain disabled.
- Test4/s through44/s upgrade: shorter post-hit gap, same streak-driven needle
  speed/zones, no changed rarity. Preserve affordability/limit, one debit and budget.
  Backspace edits without rerolls.128-token pieces wrap/scroll; no toolbar remains.
- STATS starts upper-left, shows correct balance and earned money/s over last10s,
  counts and exact probabilities. Idle money/s becomes0 with unchanged balance.
  Drag/foreground it and every agent; covered title/body/input/return cannot activate.
  STATS is always reachable by dock on narrow screens. No resource rectangle remains.
- Store/Guide are separate pages; buy agents2..8 and upgrades while scrolled: retain
  page/scroll/draft. New agents inherit global workers. Failed buys remain atomic.
- At1280x720,360x640,640x360 and resize, check native bold fonts, pixel orb background,
  rare-word readability, STATS scroll, dock safe targets and readable main terminal.
  No avatar/exterior/sidebar. No whole-interface shrinking.
- Receipt money text is solid first, rises/fades once and has eight-label cap.
  Reduced motion is static. Initial/repeated sync/reset never replays money/jobs.
  Active jobs preserve outputs; four-preview/72-line bounds and manual log scroll hold.
- Native delay/timeouts/rejoin/two clients must isolate balances/drafts and never
  retry possibly paid prompts. Studio grant/reset tools start collapsed. Destroy/
  recreate UI without duplicate input or listeners. Check reset clears stats/speed.
- Measure576 static wallpaper frames, full context/max agents, rapid input and
  network/idle cost on target devices. Viewport emulation does not prove performance.

No screenshots, engine execution, hardware performance or player approval claimed.

0.24.0 streaming production: pure tests generate exactly one word at each eighth
second at8/s, reject an early grant, preserve money/streak and discard a1000s
idle gap. Fine-clock tests verify independent phases, bounded timing variation,
output counts and unchanged reward randomness. Production tests measure eight
individual complete-word appearances over a sustained second at~125ms intervals,
even with high TPC, and verify different agent schedules plus no30s focus catch-up.
Agent packets stay bounded at20/s. Previous batch-count scenarios now check small
due grants, continuous accumulated output, source attribution, purchased budgets,
manual-clock independence and immutable awards. Existing reconciliation, context,
auto-send, streak, tuning and packet-limit regressions pass. Full verifier:198
pure Specs,128 production scenarios,47 syntax sources and deterministic export
(89 instances/44 sources). Evidence:build/streaming-agents-verification.log.
Mocks do not prove native network latency, rendering or device performance.

0.23.0 responsive button: four production scenarios cover32 stationary mouse
presses and32 touch presses at40/s, immediate repeated squash, partial rebounds,
duplicate release suppression and final neutral pose. Ten presses during a delayed
acknowledgement retrigger only the visual, with one request/word and no queued
click after release. Geometry tests cover every cap/base/shadow part at84/98/120px
and multiple poses, integer bounds, passive input and reused objects. The rebound
setting, reduced motion, essential orbit continuity and page/focus pause cleanup
are verified. Existing circle corners/occlusion/context/limiters/payout tests pass.
Full verifier:196 pure Specs,126 production scenarios,47 syntax sources and
deterministic export (89 instances/44 embedded sources). Evidence:
build/skill-button-rebound-verification.log. These are mocks; actual Studio input,
network latency, native appearance/feel and device performance remain pending.

0.22.2 clean counters: production geometry check verifies exactly four large
counter/shadow labels, removed caption/status instances, matching font/text/size,
3px/4px offset, behind-text Z order and passive input at360x640,640x360,1280x720.
Tests cover four-digit shadow updates, snapshot restoration and unchanged counter
pointer bounds. Existing tier/miss/C tests now assert the large numbers and actual
awards instead of removed small text. Full verifier:196 pure Specs,122 production
scenarios,47 syntax sources and deterministic export (89 instances/44 sources).
Evidence:build/skill-counter-shadows-verification.log. Native Studio visual QA
remains pending; geometry mocks do not prove native text/shadow appearance.

0.22.1 high-TPC reveal: three production scenarios use real purchases and clicks
to cross4->8 effective TPC, verify complete labels/no reveal records and fixed
rarity bonuses with once-only Send payout, then exercise instant automatic grants
under unchanged4/s server budgets. A miss back to4 animates only newly added words;
reduced motion completes them. Existing low-TPC agent-clock/letter pacing and
high-streak auto-send regressions pass. Full verifier:196 pure Specs,121 production
scenarios,47 syntax sources, deterministic export (89 instances/44 sources).
Evidence:build/high-tpc-instant-tokens-verification.log. Native Studio QA pending.

0.22.0 Studio tuning: catalog tests cover forward/backward wrap, copied defaults,
unknown actions/directions, lowered-cap live-item retention, server prompt cooldown,
cash durations and bounded high-tempo transport. Six production scenarios exercise
all24 rows in both directions, restore defaults, retained Store scroll, compact
geometry, live spawn/streak/cooldown/agent/effect behavior, immutable old rewards,
no catch-up/payment, forged payload rejection, session isolation and published
absence. Existing optional-Studio-test startup and all gameplay regressions pass.
Full verifier:196 pure Specs,118 production scenarios,47 syntax sources,
deterministic export (89 instances/44 embedded sources). Evidence:
build/studio-tuning-verification.log. Native Studio scrolling/input/font/listening
and actual multi-client/network/device QA remain pending; mocks do not prove them.

0.21.3 probabilistic spawns: exhaustively test all100 spawn tickets for exactly30
successes and separate fixed rarity, skipping rarity/source draws and IDs on misses.
Invalid rolls reject without issuance. Existing exact rarity/pool/claim tests pass.
Production boundaries1/30/31/100 verify success/failure, independent Legendary rarity,
unchanged click rewards/streak and no replay from sync or restored words. The mock
RNG forces successful spawn tickets for existing avatar-lifecycle fixtures; the
probability scenario supplies each boundary explicitly. Full verifier passes192
pure Specs,112 production scenarios,46 syntax sources and deterministic export
(88 instances/43 embedded sources). Evidence:
build/avatar-spawn-chance-verification.log. Native Studio QA remains pending.

0.21.2 inactivity timeout: boundary checks at5 seconds preserve best/locked awards
and challenge phase/ID, clear collectibles and allow a fresh streak. Accepted skill
and collectible clicks extend the deadline; duplicate claims, sync, automatic words
and prompt sends do not. Production checks cover Store automation through expiry,
renewal by both click paths, rejecting an expired claim before the next heartbeat,
unchanged old-word payout and lost-claim cleanup. Older pause/persistence fixtures
now stay within the inactivity limit. Full verifier passes191 pure Specs and111
production scenarios,46 syntax sources and deterministic export (88 instances,
43 embedded sources). Evidence:build/streak-timeout-verification.log. Native
Studio/network/device QA remains pending.

0.21.1 prompt cooldown removal: consecutive full server submissions accept equal
or advancing timestamps; backward/nonfinite times and stale drafts still reject.
Composer tests cover immediate dispatch after a delayed receipt, one-flight and
receipt dedup. Production callbacks exercise Send, native Return and consecutive
full-context auto-sends without advancing the clock, then verify no idle replay.
Full verifier passes189 pure Specs,108 production callback scenarios and46 syntax
sources; deterministic export has88 instances/43 embedded sources. Evidence:
build/prompt-no-cooldown-verification.log. Native Studio/network QA remains pending.

0.7.1 checks: every tier has its own framed word/badge/border/color and attributes;
Store reconnect after initial budget expires preserves draft/rarity/scroll and buys;
mismatched versions explicitly request restart and recover after coherent sync;
incomplete profiles cannot strand rendering and reconnect restores prices. All pass
in production-code mocks. Read-only native Studio log investigation confirmed old
0.6.0 startup/test errors, not native0.7.1 QA. Restart Play with the current Rojo
sources and verify actual token pieces, Reconnect and purchase flow in Studio.

0.7.3 regression: make server os.clock advance between reads while client epoch is
independent. Old code rejected a single valid prompt as typing_too_fast; first
queued words could also be backdated. Both cases reproduced RED before fixes and
pass now. Test queued Send+Enter once-only payout, pending/empty button state,
covered/hidden button guards and12 successive mixed-control prompts. Native QA:
verify actual Enter and mouse/touch/gamepad Send, full context at4..44/s, frame drops,
network latency and narrow-landscape button reachability. Restart Play on0.7.3.

0.7.4: pure reveal checks across1..20 letters and4..44 tokens/s verify monotonic,
bounded counts, completion within interval and instant reduced mode. Three new
production callback checks cover partial/full letters in fixed pieces, paused pages,
reduced motion, pooled Backspace reuse and immediate Send payout. Pixel measurement
adapter models widths; it does not establish actual font metrics/rendering. Native
QA: verify PressStart2P glyphs, all badge multipliers,128-token scroll, Store text,
STATS auto-size, letter/caret pacing at normal/low FPS, reduced mode and touch/gamepad
readability. Existing Enter/Send timing and once-only server checks still pass.

0.8.0 adds local timed key events with no bonus/penalty or new server protocol.
Four pure model and nine production adapter tests passed in addition to all prior
regressions.147 pure Specs,37 production callback scenarios and31 syntax checks.
Native QTE/render/input/device QA remains pending; mock event routing is not proof
of engine hit testing or actual hardware response.

0.8.1: generated mascot checks verify rectangular coverage of the pixel catalog,
transparent SVG/native equality and freshness. Three new production mock scenarios
cover independent passive instances, ID/geometry/color replacement, object reuse,
unknown-ID preservation, session selection retention across snapshots/purchases/
resize, centered fit for a square replacement, text separation at all three
viewports and destruction.147 pure Specs and40 callbacks,33 syntax checks,
75 place instances/30 embedded sources. Native mascot layering/hit propagation,
font/heading spacing and hardware costs remain pending. A local SVG-rectangle
preview was visually checked on white/charcoal; it is not an engine render.

0.9.0 supersedes WASD native QA with the fixed CLICK circle. Ten pure skill checks
replace four old QTE checks;16 new production callbacks replace nine old ones.
153 pure Specs,47 production callbacks,33 syntax checks and deterministic export.
Validate clockwise shared-time phase, green/gold visual-grade agreement under real
latency, mouse/touch, duplicate/early/corner clicks, context, pages/chat/menu/blur,
click acknowledgement loss, correlated read-only sync, late replies across pages,
reset/dedup and old rejection while a newer click is pending. No idle money; only
explicit prompt submission pays the recorded per-word bonus once, respecting caps.
Check combined multiplier badges and STATS skill bonus. Body text, mascots, scroll,
Send and dock must remain reachable with reserved bottom space at360x640,1280x720,
640x360, max agents/context and resize. Store/Guide reclaim full height. Essential
needle remains in reduced motion without extra effects. Native UI/network/device
QA pending; mocked timing/routing is not an engine render or human-input proof.

0.10.0: eight pure streak checks and six production callback scenarios added.
161 pure Specs,53 callbacks. Check all multiplier boundaries and capped9999 count,
monotonic/capped zone/period progression, grace shrinking, third-word paid factor,
miss reset preserving old awards, cross-prompt/context/page/sync retention, reused
word farming, invalid RNG atomicity, reset/nonce and wire-copy authority. Production
checks cover circle/token/STATS fields, next milestone, miss record, late ack/dedup,
Backspace restore and45 consecutive successes with capped difficulty and real prompt
payment. Native QA: ensure9px streak label fits compact circle, shrinking arc/needle
matches actual grade under latency, next-tier caption stays readable, session reset
clears current/best, Enter/Send retain word bonuses and all target viewport controls.
No actual native0.10.0 Studio/network/device/performance verification claimed.

0.10.1 dance: three pure checks test monotonic/capped motion, independent transformed
corner containment across phases/streaks/blends and bounded phase/neutral poses.
Four production callbacks test confirmed/main/purchased-only motion, intensity and
miss reset, immediate Guide/OS reduced motion, pause/no catch-up, ID replacement,
resize/teardown and no animation-issued remotes or money.164 pure Specs,57 mock
callbacks,34 syntax checks,76 instances/31 embedded sources. Native QA pending:
readable32x20/64x40 mascot motion at low/high streak/FPS, no text clipping or pointer
changes, immediate reduced mode, hidden/background cost and max-agent device load.

0.11.0 audio: three pure checks verify monotonic/capped tempo/density, finite local
notes, sixteen-voice score budget, bounded clock/no frozen backlog, envelopes and
normal/GOOD/GREAT cue distinction. Six production tests verify confirmed streak
ramp/miss return, click and success counts, snapshot/reused/late/page dedup, Guide
volume/mute, focus/menu/disconnection, fallback and teardown with live prompt payout.
Native listening QA pending: hear a gentle ambient loop at zero streak, progressively
busier music through40, smooth return after a miss/Store/Guide, clean normal/GOOD/
GREAT cues without clipping, no old chime on reconnect, independent levels/global
mute, app blur/menu silence, and modest volume at max typing speed. Check both
bundled timbres load on target Roblox clients and max-agent/device audio cost.
Current pass167 pure Specs/63 callback scenarios; no auditory engine approval claimed.

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

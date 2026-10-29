# Status - VibeIdle

Build0.72.0, schema18. Updated2026-10-27. Current task:
tasks/115-fluid-pixel-interface.md.
Standalone Roblox variant derived from NeuralIdle0.11.0; parent files untouched.

Implemented latest user steering:
- Fluid pixel interface: near-black stepped borders on panels/cards/buttons,
  black window/token/shop outlines with inner colored accents and subtle native
  text stroke. Short0.1s cover/0.22s reveal replaces full-height page bounce;
 8px eased movement, same-size text, entry/return/start/tutorial transitions.
 64 bounded status text fades and48 hover/focus gleams use the existing tick.
  Inputs pause during cover, commit once, preserve page scroll/draft and reject
  covered gestures. Reduced motion is immediate; pause, focus restore, resize,
  disconnect, prestige and teardown covered. No economy/schema18/analytics change.
  Full verifier passed302 pure specs,251 production callbacks,65 syntax sources,
  art equality and107-instance/62-source deterministic export. Final menu-open
  focus adjustment passed5 focused cases/export;16 mock geometry previews
  reviewed. See task115/build/fluid-interface-verification.log; native QA pending.
- Persisted player behavior metrics: sessions/server-connected time, reported
  focus/SELL/Enter, confirmed sales/tokens/money, Good/Great/miss and automatic
  checks, visitors/fragments, per-upgrade transactions/levels, skill/craft/
  prestige and premium lifecycle. Bounded24-event context and first observed
  premium timing survive prestige. Strict schema18 migrates1..17 with no invented
  history. UI pulses are capped client estimates, never progression authority.
  Native Analytics uses FIFO64-key aggregated queue, budget8/min burst4, bounded
  retry/failure isolation. Structured server summaries and server-only read-only
  per-UserId reports documented in PLAYER_ANALYTICS.md. Existing loop/saves/
  leases/commerce dedup remain; billing disabled. Full verifier passed302 pure
  specs,246 production callbacks,64 syntax sources/art equality/deterministic
  106-instance/61-source export. Gameplay snapshots omit metrics history while
  server reports/storage retain it. Task114 and PLAYER_ANALYTICS.md include
  usage/evidence; real cloud/native Analytics/Marketplace QA/publication pending.
- Pixel start screen with actual profile/draft readiness, bounded Reconnect,
  paused gameplay and honest local/cloud status. Interactive grey spotlight
  tutorial uses confirmed Skill ->SELL ->real Visitor, skip/replay from Guide,
  and one validated persisted tutorialDone flag, preserved through prestige.
  No tutorial rewards, fake actors or timing assistance. Auto check/sell cannot
  finish lessons. Existing heartbeat only; native sizes on narrow screens.
  Published servers resolve isolated DATASTORE; Studio/local remain MEMORY.
  Autosave/exit/lease behavior retained; delayed saves visible. Fixed stale
  pre-network lease timestamp by checking time inside UpdateAsync callbacks.
  Schema17 migrates1..16, preserving progression/premium. Commerce remains off.
  See LAUNCH_READINESS.md, task113 and build/launch-onboarding-verification.log.
  Full verifier passed295 pure specs,243 production callbacks,64 syntax sources,
  art equality and106-instance/61-source deterministic export. Final copy got
  focused8-case UI/cloud and export rechecks. Twelve mock geometry previews
  reviewed; obsolete README gameplay/save instructions replaced.
  Native Studio/cloud/Marketplace QA and publication remain pending.
- Larger subtext throughout Lab, Cards, Skill tree, Prestige and Robux Shop:
  generally14px, with16px important values. Shared cards grow192x304 with144px
  medallions/96x60 portraits; recipe portraits160x100, offer icons96px and skill
  icons64px. Panels/spacing/scroll grow with text; narrow layouts reduce columns
  and stack prestige summaries/bonuses instead of scaling the interface down.
  Reset consequences remain readable in the dashboard, with sticky confirmation.
  Economy/schema16/disabled Robux config remain unchanged. See task112 and
  build/readable-feature-pages-verification.log:292 pure specs,235 production
  callbacks,63 syntax sources/art equality/deterministic build passed. Fourteen
  mock geometry previews reviewed; native Studio QA pending.
- Robux shop added in shared collection style, fifth original pixel shortcut,
  highlighted Forever Duo100 target and Money1h10 /Chips1h15 /run agent20 cards.
  User explicitly requested ready-to-configure IDs: purchases remain disabled,
  IDs0 and isolated MEMORY default. Actual configured client prices/Roblox
  prompts, server-only receipt/ownership delivery, leased profile +receipt
  archive dedup, recovery and saved agent credits are implemented. Schema16
  preserves old progression and validates premium timers/ownership/bonus Chips/
  receipt proofs.2x money applies to sales;2x new Chips at prestige has separate
  bonus accounting, up to41,600 total with20,800 base. No real charge/publication.
  Full verifier passed292 pure specs,235 production callbacks,63 syntax sources,
  art equality and deterministic105-instance/60-source build/VibeIdle.rbxlx.
  Three mock production-geometry previews reviewed. Setup:docs/ROBux_SETUP.md.
  See task111 and build/robux-shop-verification.log; native Studio/Marketplace
  QA remains pending.
- Prestige vortex gain increased2.25x. Visitors show family/rarity without a
  fragment amount; a matching confirmed receipt emits one exact rising/fading
  fragment label from a separate10-slot passive pool. Zero/capped amounts, sync
  dedup, pause/reduced motion and teardown covered; no visual rewards.
  Lab/Cards/Skill tree/Prestige art grows32 ->48px with64px targets. A clipped
  horizontal strip keeps native sizes on narrow workspaces. Money/Chips bases
  grow40/28 ->54/38px with measured fitting and larger transparent header,
  preserving CLI/Shop/skill/dock and pointer clearance. Schema15 unchanged.
  Full verifier passed275 pure specs,230 production callbacks,59 syntax sources,
  art equality and deterministic101-instance/56-source build/VibeIdle.rbxlx.
  See task110 and build/fragment-header-feedback-verification.log. Mock geometry
  header/popup previews reviewed; native Studio visual/input/performance/listening
  QA remains pending.
- Laboratory now shares Cards' exact native card/panel/medallion builders via
  CollectionStyle, with horizontal family cards, four recipe cards, striped
  backdrop, pink/gold trim and shadowed captions. Keeps recipes/guards/prices.
  Prestige slowed1.87 ->3.02s with eased motion;144 strips/24 core spans are built
  once and animated through parent transforms, avoiding per-frame geometry churn.
  Redundant hidden UI/layout updates pause during collapse. Original wind/low-
  tone SFX uses three of six existing effects voices, follows confirmed phase,
  respects effects/mute/pause and stops without replay. Existing heartbeat,
  static reduced fade and all reset/nonce safeguards stay. Schema15 unchanged.
  Full verifier passed275 pure specs,226 production callbacks,59 syntax sources,
  art equality and deterministic101-instance/56-source build/VibeIdle.rbxlx.
  See task109 and build/laboratory-prestige-polish-verification.log. Production
  geometry Lab and illustrative motion previews reviewed. Actual Studio
  rendering/performance/listening QA remains pending.
- Laboratory now crafts36 unique cards: nine families x Common/Rare/Epic/
  Legendary, with authored native skin trims and tier value/speed bonuses.
  New profiles start with Common Ember; old collections/decks remain Common.
  Random server visitors every5..10 active CLI seconds replace skill-driven
  streak pickups.24s TTL, cap10, family-specific fragments only, once-only
  collection, bounded64 receipt history and read-only recovery. Collection tree
  bonuses lock into fragments at spawn. No skill dependency/offline catch-up.
  Server recipes atomically debit fragments/money/Chips; unique ownership and
  shared progression nonces prevent duplicate spending. Fragments/cards survive
  prestige; schema15 validates dense balances and exact combined skill/craft
  Chip spend, preserving historical caps/leases.20,800 Chips support19,973 tree
  +683 crafting spend. Native art equality and source preview reviewed. See
  task108 and build/agent-crafting-verification.log. Full verifier passed274 pure
  specs,223 production callbacks,58 syntax sources and deterministic100-instance/
  55-source build/VibeIdle.rbxlx. Studio QA remains pending.
- Confirmed prestige now pulls the actual workstation/wallpaper/priority roots
  into an original pixel vortex, covers and reveals Main CLI in about1.87s.
  Matching explicit success only; late read-only confirmation plays once, with
  no review/rejection/initial-sync replay.144 native spiral strips +24 core spans
  use the existing heartbeat. Input/generation pause; normal transforms/layout
  return under cover. Static reduced fade0.36s; mid-flight preference changes
  neutralize immediately. Menu/chat/modifier/blur pauses, resize/disconnect and
  teardown cleanup are covered. No new remote/schema/economy/assets. See task107
  and illustrative preview GIF (approximate UI, not Studio). Full verifier:
  262 pure Specs,226 production callbacks,57 syntax sources and deterministic
  99-instance/54-source export; build/VibeIdle.rbxlx rebuilt. Evidence:
  build/prestige-vortex-verification.log. Native Studio QA pending.
- Skill tree expanded27 ->54 functional skills, inspired by the supplied radial
  map: original stepped240x208 hexagons, branch colors, centered core, directional
  links, persistent drag-pan and a guarded CORE shortcut. Adds cash/speed/luck/
  Chip-memory/collection/streak paths and three multi-parent masteries. Max luck
  is10x, streak100, collection4.5x and per-Chip bonus19%; agent55/s and decorative
  caps remain. Full price19,973 fits20K Chips, supported by an8e15 lifetime limit
  and unchanged cubic prestige. Schema14 preserves existing purchases/debits and
  rejects new skills/legacy flags/higher caps in old records. No new remotes or
  loops. Full verifier:260 pure Specs,221 production callbacks,55 syntax sources,
  deterministic97-instance/52-source export; build/VibeIdle.rbxlx rebuilt.
  Evidence:build/expanded-tree-verification.log. Offline layout previews reviewed;
  see task106. Native Studio QA pending.
- Larger-number incremental progression: first Common token remains $1; value
  upgrades start at $10, grow1.4x and give a stacking10x milestone every10 levels
  alongside the existing linear35% base. Common value at levels10/20/30/40 is
  $45/$800/$11.5K/$150K before other bonuses. Agent/context start at $2K/$100,
  then grow6x/4x. Tree prices rise from1 to3,200 Chips (7,673 total), retaining
  the cubic prestige curve and10K limit. Schema13 validates old debits before
  grandfathering owned skills; no Chip grant/refund/reprice of old purchases.
  Read task105 for research and reproducible idealized comparison/curve reports.
  Full verifier:256 pure Specs,218 production callbacks,54 syntax sources and
  deterministic96-instance/51-source export; build/VibeIdle.rbxlx rebuilt.
  Evidence:build/inflation-verification.log. Native Studio QA pending.
- Lucky tokens I..IV add a permanent fifth-column tree branch after New boot,
  costing2/8/30/100 Chips. Total special odds rise to2x/3x/4x/5x baseline while
  Common gives up the corresponding tickets. New drafts/context slots use the
  server-owned bonus; existing offers/awards never reroll. Guide shows current
  percentages from validated profiles. Token multipliers, other upgrades and
  schema12 stay unchanged. Full verifier:253 pure Specs,216 production callback
  scenarios,54 syntax sources and deterministic96-instance/51-source export.
  Rebuilt build/VibeIdle.rbxlx; evidence:build/token-rarity-skills-verification.log.
  See task104; native Studio QA pending.
- New agent prices start at $2,000 and double per purchase; context starts at
  $100 and doubles per level. Token value prices/rewards and other progression
  remain unchanged. Single/bulk/MAX purchases share server-owned pricing.
  Full verifier:250 pure Specs,214 production callbacks,54 syntax sources and
  deterministic96-instance/51-source export. Rebuilt build/VibeIdle.rbxlx.
  See task103 and build/agent-context-prices-verification.log. Studio QA pending.
- Real progression:23 permanent tree nodes, general streak cap5 ->10 ->15 ->20
  ->25 ->30 ->35 ->40 ->50, automatic checks every2 seconds, Auto sell, cash,
  per-agent speed, clickable-agent buffs and per-Chip bonuses. The same server
  cap applies to manual, automatic and collectible streak additions. Context
  tops out at64; value upgrades continue past20. Geometric live prices,10-level
  value milestones and8 lifetime-income stages support repeated rebuilds.
  Prestige keeps the cubic lifetime curve, now+5% per claimed Chip (including
  spent), evolvable to12%. Schema12 migrates1..11 with a frozen once-only refund
  for context levels removed above64. No paid retry after autosell timeout.
  Sources/formulas/model assumptions:task102 and build/progression-model.csv.
  Validation:249 pure Specs,214 production callback scenarios; full verifier
  evidence:build/progression-verification.log. Native Studio playtesting pending.
- Current tokens enlarged1.5x: word18px, multiplier15px, chip33px/row35px,
  padding/gaps9px, corners5px and9x24 caret. Live/sold objects share measured
  widths/wrapping and the same pool. Main's wider layout and vertical growth,
  sales/generation locks and all gameplay remain. Verification:241 pure Specs,
  207 production scenarios,54 syntax files and deterministic96-instance/51-source
  export. Evidence:build/tokens-15x-verification.log. Native Studio typography/
  layout/input/device QA pending.
- Tokens enlarged1.2x from their reduced appearance: word12px, multiplier10px,
  chip22px/row23px, padding/gaps6px, corners3px and6x16 caret. Measured widths,
  wrapping and live/sold pools share metrics; Main retains its wider88%/1040px
  layout. All generation/sale/rarity/progression rules stay. Verification:
  241 pure Specs,207 production scenarios,54 syntax files and deterministic96-
  instance/51-source export. Evidence:build/token-restore-verification.log.
  Native Studio typography/layout/input QA pending.
- Main CLI is wider:88% of its initial workspace, capped1040px (851px instead
  of638px at1280 viewport). Shared live/sold token art is about80%: word10px,
  badge8px, chip18px/row19px, padding/gaps5px, corners2px and5x13 caret. Native
  measurement/wrapping, all token objects, vertical growth and full-root dragging
  below shop remain. Other UI/gameplay/fonts and sale/purchase safeguards stay.
  Verification:241 pure Specs,207 production scenarios,54 syntax files and
  deterministic96-instance/51-source export. Evidence:
  build/wide-cli-verification.log. Native Studio typography/input QA pending.
- Skill nodes now280x176, with48px icons,16px titles/unlock text,13px notes,
  256x52 buttons and6px borders/branches. Larger976x912 canvas and328/232 spacing
  keep readable native type, existing grab-pan and guarded mock purchases.
- Shop quantity cycles1X/5X/10X/25X/MAX. Prices/previews cover the full progressive
  batch; fixed quantities stop at caps and require full cost, MAX buys affordable
  levels. Server atomically quotes/debits/grants from validated quantity/nonce,
  rejects duplicate/forged requests, and retains independent new-agent clocks.
  One UI flight; correlated read-only sync never retries a payment. AUTO and shop
  Reconnect removed; Guide holds recovery. Unavailable text now red. Sale press
  settles0.16s; token collection8..45ms (128 in about1s) preserves generation lock,
  exact ordered values, rarity sounds and dedup. Schema11/MEMORY unchanged.
  Verification:241 pure Specs,207 production scenarios,54 syntax files and
  deterministic96-instance/51-source export. Evidence:
  build/bulk-tree-verification.log. Native Studio visual/audio/input QA pending.
- The4 top-icon pages slide down from above with cubic easing, a light landing
  bump and tiny rebound, resting within0.44s. Fixed-size Pages/native controls
  move together under root clipping; Back stays fixed and other workstation UI
  hides immediately. Page changes/resize/teardown reset, reduced motion skips or
  finishes instantly, and blur/menu/chat/modifiers finish next tick. Existing
  heartbeat only; no gameplay/asset/remote/schema changes. Full verification:
  236 pure Specs,201 production scenarios,54 syntax files and deterministic96-
  instance/51-source export. Evidence:build/page-drop-verification.log. Separate
  production geometry/lifecycle probe:build/page-drop-probe.log. Native Studio
  motion/clipping/input/device QA remains pending.
- Removed the three shop icon instances/hover hooks; four top feature icons stay.
  Shop titles/prices14..16px, stats14..18px, SHOP18..22px, Reconnect13px, quantity
  16px/AUTO12px. Full-width stacked rows and measured value wrapping use taller
  scrollable strips with176px narrow shop. Money40px/Chips28px retain thick black
  outlines in a larger wallet, with compact large Chip counts and fit as needed.
  Header/shop positions reserve the larger wallet. Existing colors, press/sounds,
  purchases, full-root CLI underlap and sale locks remain. Verification:236 pure
  Specs,201 production scenarios,54 syntax files and deterministic96-instance/
  51-source export. Evidence:build/shop-type-verification.log. Native Studio
  typography/layout/scroll/device QA pending.
- Skill taps, shop purchases, navigation/Back, card/agent/settings selection,
  SELL intent, avatar pickup and prestige confirmation now have distinct short
  sounds with four local pitch variations each. Existing Good/Great phrase and
  rarity coin cues remain. Guarded callbacks only, no snapshot/hidden receipt
  replay, no gameplay RNG; same2 built-in assets,6 effects voices, mute/effects
  level, envelope/tick and teardown. No server/economy/loop/assets changes.
  Verification:236 pure Specs,201 production scenarios,54 syntax files and
  deterministic96-instance/51-source export. Evidence:
  build/ui-sounds-verification.log; separate gesture/mute/dedup callback probe:
  build/ui-sounds-probe.log. Native Studio listening/mix/device QA pending.
- Main CLI now drags across the full root, beneath the foreground shop; initial
  left composition remains. Covered CLI focus/drag/SELL and free-skill callbacks
  reject before action. Snapshot-driven grey/orange/gold shop palettes indicate
  unavailable/affordable/MAXED, with only affordable purchases enabled. Eligible
  clicks depress/rebound the passive face over its fixed shadow through the
  existing heartbeat; click bounds stay fixed and reduced motion/page changes
  reset immediately. Existing server prices/caps, icon hover and sale lock stay.
  Verification:236 pure Specs,201 production scenarios,54 syntax files and
  deterministic96-instance/51-source export. Evidence:
  build/shop-overlay-verification.log; separate style/animation callback probe:
  build/shop-overlay-probe.log. Native Studio visual/input/drag QA pending.
- All4 navigation and3 shop icon outlines turn pixel gold on hover and return
  to black on leave. Only enabled visible unobstructed targets highlight; page
  changes reset immediately. Existing outline geometry, click targets, colors,
  production/sale rules and actions remain. Full verification:236 pure Specs,
  200 production scenarios,54 syntax files and deterministic96-instance/51-source
  export. Evidence:build/icon-hover-verification.log. Separate manual callback
  probe covers exact hover colors, leave/disabled/menu/page/reset and no requests
  on all7 icons. Native Studio pointer/rendering QA pending.
- Strong black pixel contours on all4 top icons and3 shop icons. SELL face has
  a short press/rebound animation with unchanged hit bounds and static reduced
  motion. Generation stays locked through queued/uncertain sales and every sold
  token's collection, including when paused off-page. Completion resumes agents
  without replaying any SELL press. Five ascending rarity coin cues use existing
  sounds/6 effects voices, receipt dedup and mute controls. No server payout,
  protocol, schema, clock or generated-art changes. Verification:236 pure Specs,
  200 production scenarios,54 syntax sources, deterministic96-instance/51-source
  export. Evidence:build/sell-polish-verification.log. Inspected offline artwork
  build/outlined-icons-preview.png. Native Studio visual/listening QA pending.
- Shop now has3 broad reference-style pixel strips: malva value, coral agent
  count/context, stepped lilac frames/shadows, top-right prices/MAXED and readable
  current/next values. Whole-row click buys once through existing server actions;
  prices/caps and Reconnect remain. Passive1X/AUTO badges,16px original icons,
  responsive wrap/scroll and full-page/covered pointer guards are preserved.
  Verification:236 pure Specs,196 production callbacks,54 syntax sources and
  deterministic96-instance/51-source export. Evidence:
  build/shop-strip-verification.log. Inspected build/shop-strip-layout-preview.png
  from production geometry with approximate bitmap font. Studio visual QA pending.
- Agent cards now use128x176 collectible frames with rose/terracotta rails,
  gold fittings, ivory clasps and shadows. Larger original portraits sit in
  colored stepped medallions; actual value/SPD buffs and tradeoffs have a dark
  plaque. Full-screen gallery matches prestige's backdrop, title tab and shadowed
  plum panels. Deck/inventory rows center responsively;8 ordered slots, locks,
  unique ownership, selection/equip/remove and all server buffs remain unchanged.
  Verification:236 pure Specs,196 production callbacks,54 syntax sources and
  deterministic96-instance/51-source export. Evidence:
  build/agent-card-polish-verification.log. Inspected native-geometry preview
  build/agent-cards-polish-layout-preview.png (approximate bitmap font).
  Native Studio visual/input QA remains pending.
- Prestige now has a subtle stepped diagonal backdrop, terracotta title tab,
  deeper plum/lavender shadowed panels, original star Chips and shadowed larger
  off-white/gold/mint figures. Measured icon/gain grouping is truly centered;
  compact/roomy layouts retain native pixel type. Reset action/review stay visible
  below scrolling content with clipped pointer validation and existing two-stage
  confirmation. Other pages and all accounting remain. Verification:236 pure
  Specs,196 production callbacks,54 syntax sources, deterministic96-instance/
  51-source export. Evidence:build/prestige-polish-verification.log. Inspected
  build/prestige-polish-layout-preview.png from production geometry (approximate
  bitmap font); native Studio visual/input QA remains pending.
- Readable references now implemented: Main CLI centered in its workspace,
  wallet left,4 icons above,3 compact upgrades vertically centered at right and
  Studio tools dock. Feature/Guide/Tools pages fill the viewport with their own
  pixel Back control, hiding other workstation/HUD/shop/skill/avatar layers.
  Hidden controls reject callbacks; agent production and draft receipts remain.
- Prestige: original native gold Chip sprites, wallet/per-Chip panels, next-Chip
  progress, gain and before/after bonus, with confirmed numbers and existing1%
  economics/two-step reset. Cards: matching plum/charcoal panels, stepped violet
  borders, gold corners, terracotta rails, larger original portraits and buff
  strips. Existing deck/inventory identity/locks and tree grab-pan stay intact.
  Verification:236 pure Specs,196 production callbacks,54 syntax sources and
  deterministic96-instance/51-source export. Evidence:
  build/reference-pages-verification.log. Native Studio visual/input QA pending.
- Skill tree has8 native pixel icons, stepped borders/price buttons,4px branches
  and a passive pixel grid. Mouse/touch grab pans both axes without scrollbars,
  clamped to content;6px threshold separates clicks and drags. Release after a
  drag cannot spend Chips. Fresh opening reveals root, page switches preserve
  position and resize clamps. Page/menu/chat/modifier/focus/covered guards and
  teardown cancellation remain; Prestige scrolling and all mock costs stay.
  Verification:236 pure Specs,194 production callbacks,54 syntax sources and
  deterministic96-instance/51-source export. Evidence:
  build/pixel-tree-verification.log. Native Studio visual/input QA pending.
- Bottom Studio tools replaces the Store shortcut in Studio and opens its own
  scrolling page. The fixed right shop contains3 upgrades and Reconnect only.
  Tools retain expanded controls, +/- tuning, independent scroll and responsive
  dock/gamepad focus, with page/menu/blur/drag/clipped pointer guards. Published
  sessions construct no tools page; shortcut is hidden/inactive. Drafts, automation
  and server authority remain. Verification:236 pure Specs,190 production callback
  scenarios,54 syntax sources and deterministic96-instance/51-source export.
  Evidence:build/studio-dock-verification.log. Native Studio QA pending.
  The initial unreadable reference was replaced with a readable layout in0.46.0;
  that broader layout is now implemented by task087.
- CLI tokens now use13px words/10px badges,22px pieces,24px row pitch and6px
  spacing/padding, shared by native rendering and measured live/sold layouts.
  Hide the CLI desktop/log scrollbar tracks while retaining wheel/touch overflow
  access, all token objects and vertical-only growth. Store/Guide remain unchanged.
  Verification:236 pure Specs,189 production callbacks,54 syntax sources and
  deterministic96-instance/51-source export. Evidence:
  build/compact-cli-tokens-verification.log. Native Studio visual QA pending.
- Skill checks now change streak and feedback only, never writing tokens or
  mutating token awards. Every fresh nonce may build/break streak at the same
  context position; duplicates/stale IDs still reject. Only agents write new
  tokens, preserving their locked rarity/card/streak value and independent clocks.
  Delayed skill replies/sync cannot append words. Full-context checks, explicit
  single queued SELL, effects and pause guards remain. Guide/CLI hints updated.
  Schema11/MEMORY namespace unchanged. Verification:236 pure Specs,189 production
  callbacks,54 syntax sources and deterministic96-instance/51-source export.
  Evidence:build/skill-streak-verification.log. Native Studio QA pending.
- Top-left money/Chips now use larger32px/20px native pixel text and opaque
  pure-black3px glyph outlines, with existing mint/amber fills and black money
  shadow. Transparent passive HUD reserves320px max width/66px height, fitting
  long values without wrapping. Header icon targets stay48px, with tighter row
  gaps on short screens. Compact prestige/tree panels remove their duplicated
  wallet header so controls remain usable. Data remains validated server snapshots
  only; no accounting/schema/protocol/asset/loop change. Verification:236 pure
  Specs,187 production scenarios,54 syntax sources and deterministic96-instance/
  51-source export. Evidence:build/bold-hud-verification.log. Studio visual QA pending.
- Cards now opens an8-position agent deck above a miniature inventory. Agent
  count unlocks positions left-to-right, with native plus/padlock art. Nine starter
  mascot cards, one copy each; choose inventory card then free position, or select
  equipped card/REMOVE. Equipped card supplies that Main CLI agent's avatar and
  server-authored value/SPD buffs for future automatic words. Budget/phase-preserved
  per-agent rates cap55/s; value locks in fresh awards and old words/manual skill
  remain unchanged. No direct payout, gacha or card-currency cost. Actual summed
  output/caps and next-agent timing drive client pacing. Shared progression nonce/
  read-only timeout sync, snapshot order guards and explicit SELL remain. Schema11
  deep copies/validates ownership and fixed unique unlocked deck; migrates1..10
  without altering existing progression. Prestige keeps collection/slot1 and
  returns higher-slot cards. Laboratory cosmetics lock for equipped slots. Native
  static previews, clipped scroll/pan, selection/focus/teardown guards, no new loop
  or remote/agent window. Verification:236 pure Specs,187 production scenarios,
  54 syntax sources, generated-art equality and deterministic96-instance/51-source
  export. Evidence:build/agent-cards-verification.log. Native Studio QA pending.
- Removed background agent CLI construction/focus/drag and the CLI-cycle dock
  button. Only Main CLI remains, with one passive reusable avatar per confirmed
  agent purchase in an internal roster (up to8).48x30 art/64x50 slots wrap at
  narrow widths; reserved height keeps the log/context below the avatars. Normal
  window width/placement is independent of count. Initial layout clears the top
  header, content grows downward and outer scroll includes its origin. AgentLab
  selects agent slots; streak celebration art reads those slots too. Retained
  confirmed dance/appearance choices, pause/reduced-motion/cleanup and full-root
  main drag guards. Server agents still produce on independent clocks; no money,
  prestige/profile/schema/protocol changes. Verification:224 pure Specs,
  177 production scenarios,52 syntax sources, generated-art equality and
  deterministic94-instance/49-source export. Evidence:
  build/agent-roster-verification.log. Native Studio visual/device QA pending.
- Main CLI context now grows vertically only at its existing responsive width.
  Removed the viewport-height-triggered widening fallback from windowLayout.
  More rows expand composer/window height; native15px tokens/badges and all-token
  visibility remain, with outer scrolling when taller than the screen. Retain
  grown height across ordinary sends/undo and the same collection layout. Viewport
  resizing may still reflow the normal initial width. No economy/schema/protocol
  or loop change. Verification:224 pure Specs,177 production scenarios,52 syntax
  sources and deterministic94-instance/49-source export. Evidence:
  build/vertical-context-verification.log. Native Studio visual QA pending.
- Implemented prestige/Chips and a real mock skill tree. Confirmed lifetime
  sales yield floor(cubeRoot(earned/1000)) total Chips less previously claimed;
  thresholds1K/8K/27K. Each earned Chip grants permanent+1% base token value.
  Review/confirm prestige resets the normal run and unsold tokens, keeps Chips
  and eight parent-gated one-time mock unlocks. Mock nodes cost1/2/4/8 Chips and
  have no gameplay effects. Native ascending-chip pixel icon opens prestige;
  tree icon opens the panning graph. Corner HUD now shows Chips below money.
  Schema10 validation/migration1..9 preserves normal progress and leases without
  inventing historical earnings. Dedicated bounded progression IDs/read-only sync,
  no paid retry/duplicate mint/debit; snapshot sequencing rejects old-run replies.
  Same profile object and independent clocks reset safely. Existing MEMORY/store
  namespace, explicit SELL, skill, limits and single heartbeat remain. Verification:
  224 pure Specs,177 production scenarios,52 syntax sources, generated-art equality
  and deterministic export (94 instances/49 sources). Evidence:
  build/prestige-verification.log. Art preview:build/prestige-feature-preview.png.
  Native Studio visual/network/device QA pending; no publication.
- Full-context skill checks now change streak/feedback with0 words. The server
  requires a completely awarded context and validates bounded next-slot index
  (129 at128 words), preserving consumed nonces, packet/cooldown limits, immutable
  old rewards, no buffer and queued-sale reconciliation. Shop now uses compact
  separated transparent rows with32px pixel icons and40px price buttons, retaining
  all three global purchases, Reconnect, scrolling and Studio tools. Removed STATS
  CLI/dock/order/drag/render paths. Passive transparent top-left MoneyHUD uses mint
  pixel text/dark shadow and only validated server balances. Responsive header
  avoids feature-icon overlap and blocks covered input; four-button dock remains.
  No new asset/remote/schema/profile/loop or automatic sale. Verification:
  214 pure Specs,167 production scenarios,50 syntax sources, generated-art equality
  and deterministic export (92 instances/47 sources). Evidence:
  build/minimal-ui-verification.log. Native Studio visual/network QA pending.
- SELL retains normal terracotta pixel art while empty, generating, queued or
  in flight. Enter/SELL now stores one draft-bound sale intent while skill/agent
  confirmation or cosmetic letters finish. Duplicate presses coalesce; flight
  presses never queue a second prompt. Pending sales pause new generators and
  take priority after writing, using the existing one-flight payment path and
  cooldown. SELL QUEUED shows the wait. Empty failed grants clear the intent;
  existing edit/page/focus/menu/disconnect cancellation and pointer guards stay.
  No word buffer, server/protocol/schema/profile or extra loop change. Verification:
  211 pure Specs,164 production scenarios,50 syntax sources, generated-art equality
  and deterministic export (92 instances/47 sources). Evidence:
  build/sell-queue-verification.log. Native Studio visual/network QA pending.
- Removed the skill word buffer: confirmed words enter the current context
  directly, clamped to its remaining slots. Full context waits for manual SELL;
  no overflow, busy press or old challenge carries into the next draft. Removed
  skill_queue, server enqueue/drain/handover fields, local pending-word queue,
  QUEUED status and queue Studio controls (26 remain). Manual/agent/sale requests
  preserve one flight; late manual receipts reconcile off-page once, with a due
  agent serviced after manual reconciliation and no recursive agent reply chain.
  Fixed awards, nonce/packet/context bounds, independent agent clocks, continuous
  phase, explicit sales and coin collection remain. No profile/schema migration.
  Verification:211 pure Specs,159 production scenarios,50 syntax sources,
  deterministic export (92 instances/47 sources). Evidence:
  build/no-word-buffer-verification.log. Native Studio visual/network QA pending.
- Added the third top feature button, Skill tree: original mint pixel tree with
  terracotta trunk and three gold nodes,32px art in the same48px native pixel hit
  target. Selection/tap/coming-soon feedback only, with no page, profile, network
  or economy action. Header now sizes/centers from its actual button count,
  tightening gaps on narrow screens (and wrapping only when physically needed).
  Existing Laboratory gallery, Cards placeholder, pointer guards and teardown
  remain. Generated SVG/native art equality includes the new tree. Verification:
  211 pure Specs,159 production scenarios,50 syntax sources, deterministic export
  (92 instances/47 sources). Evidence:build/skill-tree-icon-verification.log.
  Artwork preview:build/feature-icons-preview.png. Native Studio QA pending.
- Laboratory now opens AGENT LAB, a dedicated local appearance-test gallery.
  Choose an owned CLI with arrows and click an agent card to apply its art.
  Preserved Ember plus8 original16x10 variants: Sprout, Volt, Frost, Nebula,
  Forge, Glitch, Coral and Sage. All have distinct silhouettes; variations add
  leaves, lightning horns, crystal crowns, orbit arms, armor, signal fragments,
  coral fronds and a wizard hat, with authored multicolor palettes/cutout eyes.
  Cards remains a coming-soon placeholder. Fixed Shop remains available.
  Selections are independent per CLI and survive snapshots/purchases/layout;
  new agents retain Ember by default. Static96x60 thumbnails reuse AgentMascot;
  live appearances retain existing slots/dance, no extra loop or stored field.
  Mascot generator exports ordered catalog and matching colored SVG/native art;
  original Ember geometry remains11 parts. Gallery rejects hidden, clipped,
  covered, menu/blur/drag input and cleans previews on teardown. No economy/
  protocol/schema changes. Full verification:211 pure Specs,159 production
  scenarios,50 syntax sources, deterministic export (92 instances/47 sources).
  Evidence:build/agent-lab-verification.log. Artwork preview:
  build/agent-roster-preview.png. Native Studio visual/input/device QA pending.
- Two fixed top-center buttons in the left workspace: Laboratory (mint flask/
  bubbles) and Cards (three staggered playing cards with a red heart). Original
  16x16 colored pixel artwork renders at integer2x inside48px native pixel buttons.
  Clicking selects the icon, plays the existing soft tap and shows coming soon
  in the CLI hint; there is no feature implementation, remote, profile/economy
  action or page switch. Root-level controls remain reachable above CLIs and on
  Guide. Free skill/covered CLI callbacks reject their bounds before focus/drag;
  menu/app blur/drag/foreground-avatar guards and owner teardown apply.
  Editable assets/features/catalog.json generates SVG/native FeatureIconCatalog
  through the shared icon exporter, preserving exactly3 Store upgrades. No image
  upload, external assets/font or new loop. Full verification:211 pure Specs,
  156 production scenarios,49 syntax sources, deterministic export (91 instances/
  46 sources). Evidence:build/top-feature-icons-verification.log. Artwork preview:
  build/feature-icons-preview.png. Native Studio visual/input/device QA pending.
- Shop is now a permanent rectangular panel on the right, outside CLI/Guide pages.
  Store dock shortcut focuses its first upgrade; it never replaces/pauses the CLI.
  Three rectangular options stack vertically with their own scroll, confirmed
  prices/caps and Reconnect. Guide keeps the shop visible and purchases available.
  Desktop/skill stay left of the panel; narrow screens pan a readable virtual CLI
  horizontally rather than shrink its15px tokens. Dock remains reachable. Shop
  geometry excludes free-skill/covered CLI callbacks; buys reject overlay/drag
  input. Coin popups clamp to the workspace even after resize. Studio tools rows
  wrap within the panel and retain all controls. Layout caches avoid price-only
  snapshots relaying out every icon/control.
  Three original multicolor pixel illustrations: gold currency coin, mint/
  terracotta agent trio and violet context-paper stack. Source catalog generates
  matching colored SVG/native parts, rendered at integer pixel scales, passive
  to all input. No upload, external art/font, loop, remote or economy change.
  Full verification:211 pure Specs,154 production scenarios,48 syntax sources,
  deterministic export (90 instances/45 sources). Evidence:
  build/fixed-shop-verification.log. Artwork preview:build/store-icons-preview.png.
  Native Studio layout/input/font/device QA pending.
- Confirmed Enter/SELL receipts collect sold tokens in order. Each chip disappears,
  plays a quiet two-register coin cue and emits its exact server-paid +$ value
  upward from its position. Compact read-only tokenRewards carries the existing
  server output amounts, including clipped/zero rewards; no local payout math.
  Money still settles once on the server. Presentation begins only on matching
  confirmation, deduplicates receipts/coin events, and cannot resubmit/pay money.
  Superseded by0.50.0: generation now waits for collection. Passive sold chips use
  a lazy reused pool (4 batches/512 chips max), with24 popup labels and the existing
  six effects voices/heartbeat. Extreme rapid sales finish the oldest cosmetic
  batch quietly at the cap. Temporary window growth keeps old/new chips readable
  without permanently increasing normal CLI size. Pages/chat/menu/modifiers/blur/
  disconnect pause collection; reduced motion keeps amounts static. Audio levels/
  mute, teardown and retained manual-only sale rules remain. Full verification:
  210 pure Specs,150 production scenarios,48 syntax sources, deterministic export
  (90 instances/45 sources). Evidence:build/token-collection-verification.log.
  Native Studio visual/listening/device QA pending.
- Token sales require an explicit player Enter/mobile Return or CLI SELL press,
  for both partial and full context. Removed every full-context send trigger from
  manual append, skill receipts and agent/queued receipts, plus background-send
  state. Only sendPrompt creates sale intent; dispatch validates it and active
  page/focus/pending state. Full tokens stay visible and wait, including Store/
  Guide agent output and delayed off-page confirmations. No hidden-page payment.
  SELL replaces Send: native stepped terracotta face, block shadow and PressStart
  text, fixed96x40 hit area, passive geometry, no rounded button/stroke. One-flight,
  server pricing/payout and no retry after timeout/rejection remain. Guide/copy
  match explicit sales. Full verification:206 pure Specs,144 production scenarios,
  47 syntax sources, deterministic export (89 instances/44 sources). Evidence:
  build/manual-sell-verification.log. Native Studio/device/visual QA pending.
- All current prompt tokens occupy visible rows in a naturally sized composer,
  without an inner token scroller. Main CLI grows height, then uses the available
  viewport width before overflowing. Native15px text, chip/badge sizes and reused
  token objects stay intact. Growth survives sends/undo to avoid repeated resize
  jumps; viewport/page layout recalculates it. Welcome/log give room to tokens.
  For physically smaller screens the entire terminal desktop scrolls vertically,
  with bottom clearance for the independent dock/skill surface; no token rows are
  clipped inside the CLI. Existing focus/occlusion/Send/automation remains.
  Full verification:206 pure Specs,140 production scenarios,47 syntax sources,
  deterministic export (89 instances/44 sources). Evidence:
  build/all-tokens-verification.log. Native Studio/device/input QA pending.
- Store now exposes exactly three upgrades: Token value (existing computeLevel,
  +35% base per level, cap20), Agent count (1..8) and Context (8..128 tokens).
  Removed worker, typing, click and divisor cards and rejected their commands
  before any server mutation. Historical fields/bonuses and inherited pure
  economy fixtures remain intact; no schema, migration, payout or price change.
  Authored token coin icon replaces CPU art. Guide/agent captions match the new
  names; responsive grid/scroll height uses actual card count, with 1..3 columns.
  Full verification:204 pure Specs,138 production scenarios,47 syntax sources,
  deterministic export (89 instances/44 sources). Evidence:
  build/three-upgrades-verification.log. Native Studio rendering QA pending.
- Agent requests, full context and prompt flight no longer exclude fresh skill
  input. Busy presses use ID-only skill_queue on the existing Command remote;
  the server grades immediately, consumes the check once and locks word bonuses
  in a session FIFO capped512 words. No payment or client-supplied grade/count.
  Existing agent_type drains queued words first, up to128 words/s and16/packet,
  context-clamped through the same prefix mutation/receipt/auto-send path. Queue
  persists across prompts/streak loss, pauses with chat/menu/blur, and clears on
  explicit session reset. A bounded previous-challenge handover handles presses
  during prompt acknowledgement without backdating or replay. Own outstanding
  skill acknowledgements still gate another gameplay attempt; physical squash
  stays immediate. CLI shows QUEUED count; Guide explains input/queue behavior.
  Studio tools adds Click queue release/batch (28 controls). Full verifier:
  204 pure Specs,135 production scenarios,47 syntax sources, deterministic export
  (89 instances/44 sources). Eight-agent96 words/s stress includes50ms delayed
  replies, concurrent clicks and queue drains. Evidence:
  build/skill-queue-verification.log. Native Studio/network/FPS QA pending.
- Words now appear complete at2+ actual combined agent words/s, not just8+ TPC.
  Confirmed output is applied before receipts; crossing either limit immediately
  finishes existing reveals, even off-page. Both manual and agent words skip all
  letter animation; Studio letter speed cannot override this. Slow new words
  below both limits still reveal normally. Production clocks/economy unchanged.
  Full verifier:198 pure Specs,131 production scenarios,47 syntax sources,
  deterministic export (89 instances/44 sources). Evidence:
  build/instant-output-verification.log. Native Studio visual QA pending.
- Agents generate words on independent per-word deadlines instead of once-per-
  interval TPC batches. Preserve nominal output min(TPC/window, typing cap):8/s
  means one word about every0.125s. Stable per-agent phase offsets and bounded6%
  timing variation avoid synchronized output; Studio tools adds Agent timing
  variation (26 controls total). Short transport/frame delays coalesce at most
  150ms of due words; stale deadlines discard elapsed cycles, never idle catch-up.
  Shared-prefix mutation remains one-flight and accepted words append atomically,
  without a second cosmetic word queue. High-TPC text still appears complete.
  STATS distinguishes current output from per-agent/total speed caps; Store/Guide
  wording updated. Skill/general/agent packet limits, fixed awards and payout stay.
  Full verifier:198 pure Specs,128 production scenarios,47 syntax sources,
  deterministic export (89 instances/44 sources). Evidence:
  build/streaming-agents-verification.log. Native Studio/network/device QA pending.
- Skill center is a raised terracotta pixel button with a darker base and a
  full stepped projected shadow. Each eligible physical press immediately squashes
  the cap, then rebounds over0.14s in the existing tick. Repeated presses restart
  the same bounded pose, including while a skill acknowledgement/cooldown is busy;
  only existing eligibility/one-flight rules can send requests or award words.
  Native hit surface, circle geometry, target arc and orbit remain stationary.
  Reduced motion/page/focus/menu pause restores neutral without catch-up. New
  Studio tools Button rebound control expands the catalog to25 session controls.
  Full verifier:196 pure Specs,126 production scenarios,47 syntax sources,
  deterministic export (89 instances/44 embedded sources). Evidence:
  build/skill-button-rebound-verification.log. Native Studio input/visual QA pending.
- Both large skill-side counters have dark passive pixel-text drop shadows,
  offset3px right/4px down, matching font/scaling/bounds. Removed the small TPC
  caption, in-circle xN w and footer milestone/result/status text. CLICK/pending
  label, large numbers and circular skill remain. Shadows never capture input or
  enlarge counter hit bounds; original foreground/covered-CLI guards remain.
  Full verifier:196 pure Specs,122 production scenarios,47 syntax sources,
  deterministic export (89 instances/44 sources). Evidence:
  build/skill-counter-shadows-verification.log. Native Studio visual QA pending.
- At8+ effective words/click, tokens appear fully formed instead of revealing
  letters. Current server-confirmed streak/base/C drives the cosmetic mode.
  Entering high TPC finishes active reveals and clears cosmetic agent deadlines;
  manual and agent grants create no new letter animation there. Large delayed
  manual batches also appear complete. Below8, only new words animate again.
  Server production clocks/budgets, payment, rarity and full-context Send remain.
  Full verifier:196 pure Specs,121 production scenarios,47 syntax sources,
  deterministic export (89 instances/44 sources). Evidence:
  build/high-tpc-instant-tokens-verification.log. Native Studio QA pending.
- Store > Studio tools exposes24 live session controls with next/previous presets
  and Restore tuning defaults. Covers skill speed/growth/floor/delay/cooldown/grace,
  streak expiry (including off), prompt cooldown, per-agent cadence/rate, spawn
  chance/cap, avatar fades, word/cash/job/reveal/dance/music timing, request response/
  reconciliation limits and snapshot cadence. Shared StudioTuning catalog; server
  accepts only catalog actions/directions through existing Studio-only remote.
  No profile persistence or published tuning endpoint. Retuning preserves phase,
  targets, nonce, old word awards and settled agent budgets; no time-based payout.
  Full verifier:196 pure Specs,118 production scenarios,47 syntax sources,
  deterministic export (89 instances/44 embedded sources). Evidence:
  build/studio-tuning-verification.log. Native Studio UI/listening QA pending.
- Collectible agents spawn with30% server-owned probability per fresh GOOD/GREAT
  click, before a separate unchanged rarity/source draw. Full pools, restorations,
  misses and sync cannot roll a spawn. Skipped rolls do not consume collectible
  IDs or change word awards/streak. Guide exposes the shared authored percentage.
  Full verifier:192 pure Specs,112 production callbacks,46 syntax sources,
  deterministic export (88 instances/43 embedded sources). Evidence:
  build/avatar-spawn-chance-verification.log. Native Studio QA remains pending.
- Current streak expires after5 seconds without an accepted skill/background click
  or collectible-agent claim. Server-only session deadline; sends, automation,
  sync, pages and menus never extend it. Expiry preserves best/locked word awards,
  clears collectible claims and uses existing0.65s avatar fade. Current challenge
  keeps ID/target/phase while returning to base difficulty. Existing heartbeat only.
  Full verifier:191 pure Specs,111 production callback scenarios,46 syntax sources,
  deterministic export (88 instances/43 sources). Evidence:
  build/streak-timeout-verification.log. Native Studio QA remains pending.
- Prompt sends have no artificial cooldown on client or server. Enter/Send and
  full-context submission dispatch immediately after the previous receipt.
  One-flight, stale-draft/payment dedup, request limiters, timeout reconciliation
  and independent agent clocks remain. Backward/nonfinite server times reject.
  Verification:189 pure Specs,108 production callback scenarios,46 syntax sources,
  deterministic export (88 instances,43 embedded sources). Evidence:
  build/prompt-no-cooldown-verification.log. Native Studio QA remains pending.
- Priority skill surface above CLIs/avatars; stationary pointer press-down and release dedup without toggling native hit state.
- Player and each agent have independent typing/production clocks; manual clicks cannot starve automatic writing.
- Pixel skill circle/rim, square target blocks and upright red pixel marker; continuous timing.
- Skill fire disabled for now; manual clicks have no typing-speed cooldown.
- Independent per-agent typing capacity4..44 words/s; purchases add capacity, global upgrades improve each agent.
- Agent token rewards lock1 + streak*0.1 at generation, multiplied by rarity.
- Each due agent contributes its own TPC/budget batch through an independent clock;
  full-context prompts auto-send, also on Store/Guide. No automatic skill streak.
- Large TPC left of circle and same-style Nx streak right, with pointer priority.
- Store square card grid: name, colored authored SVG/native icon, level and
  Buy/price. Responsive1..4 columns, same global purchases, page and scroll.
- Eligible circle/background clicks show random floating pixel phrases, rising/
  fading in1.4s with12 passive reused labels and reduced-motion support.
- Supplied fire artwork is preserved as dormant source, with no runtime effect.
- Every fresh success spawns an independent StreakAvatar above all game UI.
  Ten-object pool, fade/beat timing, passive input and reduced-motion support.
- Empty background mouse/touch clicks activate the same skill check, preserving
  CLI/control/dock/skill bounds, drag release, pause, pending and teardown guards.
- Lounge below C, then four increasingly intense rock stages at C/2C/3C/4C.
  Global Store modifier changes C from5 to2; word count uses the same divisor.
  Confirmed clicks follow a connected eight-note phrase keyed to streak.
  Eligible circle clicks give immediate tactile feedback; fresh confirmed GOOD/
  GREAT add distinct cues once. Reused/synced results cannot replay success.
  Guide Music/Effects volume and mute are session-local. Bounded22 sound voices
  use bundled Roblox timbres, existing tick and no new remotes/uploads. Pause on
  menu/app blur/disconnection, teardown/failure isolation. Native listening pending.
- Mascots in main/purchased agent CLIs dance from confirmed streak, with increasing
  sway/hops/tilt/squash and speed through40 hits, capped4.5Hz/16 degrees. Zero
  streak restores neutral. Inner fitted group keeps outer slots and pointer bounds
  steady. Existing tick only, phase offsets per agent, no new asset or reward.
- Reduced motion stops dance immediately; pages/chat/menu/modifiers/app blur/
  disconnection pause without catch-up. Unpurchased agents stay static. Swapping
  mascot ID and resizing preserve animation; teardown disconnects the existing loop.
- Server streak for fresh GOOD/GREAT words, factors3 x1.25 /5 x1.5 /10 x2 /20 x3 /
  35 x4, multiplied into each word's fixed precision reward. Normal resets current
  and preserves previous word awards/best. Reused words cannot grow streak; a
  missed restoration still breaks it. Ring counter/next tier, STATS current/best.
- Difficulty gradually advances per hit, capped after40 at1.2s revolution with
  green28-degree and gold8-degree zones. Grace narrows with gold width. Counts
  survive send/pages/sync/idle; explicit session reset clears current/best.
- Ember SVG mascot and equivalent native AgentMascot object in every agent CLI.
  Transparent terracotta creature,11 rectangles, independent instances and swap
  by catalog ID. Shared editable JSON exports SVG/Luau; verifier checks source
  coverage and generated equality. Fixed slots fit other proportions. Swaps retain
  choice across snapshots/purchases/layout, with no input/economy/server changes.
- Fixed bottom-center CLICK skill circle replaces WASD popups. Server-issued
  clockwise needle/target: GOOD x1.5 (green), GREAT x2 (gold), Normal x1 outside.
  Mouse/touch confirmation generates one word; bonus pays on explicit Enter/Send.
  First result per word is immutable across edit/sync, with combined multiplier
  badges and actually credited skill bonus in STATS. Server owns timing/payout.
- Reserve148px/112px below desktop so control cannot cover main input, retaining
  native scale and short-screen composer.90 static segments, one essential needle
  in the existing loop, hidden off-page and no keyboard generation.
- Strict skill_click/read-only skill_sync ID/index protocol. Pending confirmation
  blocks edit/Send, late reply restores one word across pages; correlated timeout
  sync and reject IDs prevent replay and old replies cancelling newer clicks.
  Existing draft/context/rate/cooldown/money-cap authority stays intact.
- Money and useful statistics moved entirely into the prominent draggable STATS
  CLI. No top resource rectangle. Actual earned money/s over10s, session earnings,
  prompts/words/special counts, typing/context/base and fixed rarity odds/collected.
- Original procedural32x18 pixel interpretation of the supplied purple orb wallpaper,
  with magenta/violet glow and warm lower rim. Coarser576 flat blocks and16-step
  colors make pixelation more visible; native frames only, no asset upload.
- Global Typing speed starts4/s, +2 per level up to44/s at level20. Server-priced
  atomic upgrade, strict payload, bounded token timing budget and schema7 validation.
  Known schemas1..6 migrate to level0 under existing leases without losing progress.
- Existing money-only-on-prompts loop, special tiers, global upgrades, persistent
  Store scroll, separate CLI/Store/Guide pages, all-window foreground/occlusion,
  isolated MEMORY, finite jobs/logs and solid rising money feedback remain.

Connection fixes verified in production-code mocks:
- Studio tests previously ran before GameService. Start gameplay/remotes first;
  optional deferred tests are protected and missing/failing tests cannot block Play.
- A lost initial draft could be followed by a light balance snapshot. Treating that
  as ready left the CLI unable to compose/send. Readiness now requires the draft;
  bounded force-sync retries recover it. Unavailable state replaces infinite loading.
- Earlier focused-TextBox fixes retained native Return fallback. Current0.8.0
  routes own focused Enter directly as well; the read-only QTE composer no longer
  accepts arbitrary text. External TextBox/processed-key guards still apply.

Full tools/verify.py PASSED:183 pure Specs (111 baseline +72 manual/speed/stats/reveal/skill/streak/dance/audio),
102 production server/client callback scenarios with fake services,45 source/test
Lua-compatible syntax checks, deterministic two-pass export/source equality and
no-avatar/clipping checks.87 instances,42 embedded sources. World SHA-256:
`6a79a2d9b114c6c718bd99fafa13e93f0e1e0a9430c5470ff3ef549d6aad3b3f`.

Callback suite now executes real GameService, server Bootstrap, client Bootstrap,
TerminalController/Desk, PixelWallpaper, Theme, Telemetry and Config with fake
services/remotes/time. Includes Enter-to-money-to-purchase, lost draft recovery,
o server, failing/missing Studio tests, queue/Return dedup, STATS, tiers and pages.
Legacy passive/auto-send/neural helpers remain pure regression fixtures, never live.

Native Studio rendering/focus/touch/gamepad, scroll/IME/keyboard behavior, real
network timing/RNG/two clients, fonts and hardware performance remain pending.
No native0.8.0 engine execution, Luau type checking, screenshots or visual approval claimed.
No external assets/runtime installation, real shell/AI/HTTP, store access/migration,
publication or messages. See TESTING.md. Exact primary API links and previously
consulted community guidance are in README/task docs.

New0.7.1 investigation: read the existing local Studio log and Rojo metadata/source
through read-only access. Studio logged missing PromptSessionSpecs before startup,
then last started0.6.0 at2026-10-23T05:27:54Z. This confirms the active Play did not
run the previous0.7.0 fix. Rojo is serving the current VibeIdle sources. Stop/restart
Play is required to execute the new bootstrap; no forced UI/process restart made.

Store now has explicit Reconnect, also retried when opening it while disconnected.
A new bounded sync cycle can recover after startup retries expire, retaining draft/
scroll and never resending a paid prompt or purchase. Profile/build validation and
protected refresh show actionable errors; mismatched builds instruct restart/rejoin.
Four new production mock scenarios cover every token tier, exhausted reconnect,
version mismatch and incomplete profiles, with successful subsequent purchases.

0.7.2 visual edit: coarse32x18 blocks replace48x27, color quantization16 replaces8.
Existing wallpaper expectation updated; full verifier still passes142 pure Specs
and20 production mock scenarios. New native visual approval remains pending.

0.7.3 fixes the reproduced Typing speed limit reached defect: GameService captured
request time, advance sampled a later clock, then submit tried the earlier time.
The strict backward-time guard rejected normal prompts. Command advance/submit now
share the captured timestamp. Client also starts a fresh queue at actual current
time rather than backdating its first token by0.25s. Rate/context/cooldown/duplicate
validation remains authoritative. A single Send button uses the same path as Enter.

Two new regressions failed before these fixes and now pass with clock progression
between reads and distinct client/server epochs. Three additional scenarios cover
queued button+Enter dedup, pending/empty/covered/hidden button state and12 successive
alternating button/Enter payouts.142 pure Specs and25 production mock scenarios pass.
No native0.7.3 Play execution or visual approval claimed; restart Play for new sources.

0.7.4: built-in PressStart2P replaces RobotoMono/Arimo globally. TextService.GetTextSize
with Enum.Font.Arcade (same family) measures and caches token/badge widths. Store
cards/captions have more room and STATS uses automatic vertical content/scroll.
Tokens use MaxVisibleGraphemes for about100 letters/s, at most120ms and within85%
of the purchased token interval. Fixed chip dimensions prevent reflow; caret follows
revealed letters. Only bounded active reveals update in the existing loop. Reduced
motion finishes immediately; pages/menu/app focus pause and undo/draft reuse clear.
Animation never affects money or Send/Enter.143 pure Specs and28 production mock
scenarios pass; native0.7.4 rendering/font/accessibility/device QA remains pending.

0.8.0: pure TimedKeys model and production TimedKeysController implement the new
WASD mechanic using the existing loop. Nine callback scenarios plus four pure
checks cover input/click parity, timeout/pause/capacity/flight/occlusion/destruction
and zero bonus with normal Enter/Send payout. This is local gameplay, not input
verification or anti-cheat evidence. Native0.8.0 Play QA remains pending.

0.8.1: AgentMascot/MascotCatalog and assets/mascots/catalog.json/ember.svg added.
Generator verifies pixel coverage, nonoverlap and equal SVG/native geometry. Main
has32x20 title artwork; background agents have64x40 beside headings. Three new
production mock scenarios verify independence/passive frames, swapping/reuse/
selection retention and target viewport spacing/destruction. SVG rectangle preview
was visually inspected on white and charcoal backgrounds using local Pillow; this
is not native Studio QA.147 pure Specs and40 callbacks pass; native0.8.1 pending.

0.9.0: fixed click skill check replaces the0.8 WASD UI/model. Ten pure timing/
protocol/payout checks replace four old QTE checks;16 production skill scenarios
replace nine old callbacks.153 pure Specs and47 production mocks pass. The new
late-ack test exposed premature cancellation by older periodic snapshots; correlated
read-only skill_sync replies fix it. Resize mock now fires the derived AbsoluteSize
signal so real layout changes are exercised. Native0.9.0 Studio/network/device/
performance QA remains pending. No new assets, schema/store changes or publication.

0.10.0: eight new pure and six production streak scenarios verify thresholds,
post-hit rewards, difficulty/grace caps, reset/record, immutable prior awards,
Backspace farming, cross-prompt/page/context/sync retention, late ack dedup and
45 consecutive actual callback hits with capped difficulty/payout.161 pure Specs,
53 production mock scenarios pass. Native0.10.0 Studio difficulty/label/network/
device/performance QA remains pending. No schema/store/protocol/assets changed.

0.10.1: MascotDance pure model, AgentMascot inner motion group and Desk integration
added. Three pure checks cover progressive/capped parameters, all rotated corners
inside slot at blended poses and bounded phase/rest. Four production checks cover
confirmed/purchased-only motion, intensity/miss reset, OS/Guide reduced mode and
pause/swap/resize/teardown, without new payments/requests.164 pure Specs and57 mock
callbacks pass. Native0.10.1 animation feel, clipping/fonts/device performance and
Studio render/input remain pending. Parent/schema/namespace/protocol unchanged.

0.11.0: Original adaptive audio, local pooled voices and Guide settings added.
Three pure score/clock/envelope checks and six production callback scenarios pass,
including stale/late results, independent volumes/mute, no paused backlog, failure
isolation, actual click-to-money and teardown.167 pure Specs,63 mock scenarios.
Native listening/mix/device-volume QA remains pending. No parent/schema/store/
protocol change, imported track or uploaded audio.

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

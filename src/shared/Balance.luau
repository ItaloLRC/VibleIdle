--!nonstrict
-- Game economy, not a scientific model of neural-network performance.
local EMBEDDING_DIM = 4
-- Original costs below are frozen for pre13 Chip accounting; new prices follow.
local NODES = {
    {id="boot",name="New boot",cost=1,parents={},column=2,row=0,cash=1.10,description="Cash +10%"},
    {id="tokens",name="Token craft",cost=2,parents={"boot"},column=0,row=1,cash=1.25,description="Cash +25%"},
    {id="agents",name="Agent link",cost=2,parents={"boot"},column=1,row=1,speed=1.15,description="Agent speed +15%"},
    {id="focus",name="Auto focus",cost=2,parents={"boot"},column=3,row=1,auto=5,description="Auto check / max 5"},
    {id="cache",name="Auto sell",cost=4,parents={"tokens"},column=0,row=2,autosell=true,description="Sell full context"},
    {id="swarm",name="Agent swarm",cost=4,parents={"agents"},column=1,row=2,collect=1.5,description="Fragments x1.5"},
    {id="context",name="Chip memory",cost=4,parents={"focus"},column=2,row=2,chip=.01,description="Per Chip +1% cash"},
    {id="focus10",icon="focus",name="Auto focus II",cost=8,parents={"focus"},column=3,row=2,auto=10,description="Max streak: 10"},
    {id="core",name="Ascended core",cost=8,parents={"cache","swarm","context"},column=1,row=3,cash=2,description="Cash x2"},
    {id="focus15",icon="focus",name="Auto focus III",cost=20,parents={"focus10"},column=3,row=3,auto=15,description="Max streak: 15"},
    {id="fortune",icon="tokens",name="Golden output",cost=20,parents={"core"},column=0,row=4,cash=1.5,description="Cash +50%"},
    {id="overclock",icon="agents",name="Overclock",cost=20,parents={"core"},column=1,row=4,speed=1.25,description="Agent speed +25%"},
    {id="memory",icon="context",name="Chip memory II",cost=20,parents={"core"},column=2,row=4,chip=.02,description="Per Chip +2% cash"},
    {id="focus20",icon="focus",name="Auto focus IV",cost=50,parents={"focus15"},column=3,row=4,auto=20,description="Max streak: 20"},
    {id="fortune2",icon="tokens",name="Golden output II",cost=75,parents={"fortune"},column=0,row=5,cash=2,description="Cash x2"},
    {id="swarm2",icon="swarm",name="Magnetic swarm",cost=50,parents={"overclock"},column=1,row=5,collect=2,description="Fragments x2"},
    {id="memory2",icon="context",name="Chip memory III",cost=75,parents={"memory"},column=2,row=5,chip=.04,description="Per Chip +4% cash"},
    {id="focus25",icon="focus",name="Auto focus V",cost=125,parents={"focus20"},column=3,row=5,auto=25,description="Max streak: 25"},
    {id="mastery",icon="core",name="Studio mastery",cost=250,parents={"fortune2","swarm2","memory2"},column=1,row=6,cash=2,speed=1.25,collect=3,description="Cash x2 / speed +25%"},
    {id="focus30",icon="focus",name="Auto focus VI",cost=300,parents={"focus25"},column=3,row=6,auto=30,description="Max streak: 30"},
    {id="focus35",icon="focus",name="Streak mastery I",cost=600,parents={"focus30"},column=3,row=7,auto=35,description="Max streak: 35"},
    {id="focus40",icon="focus",name="Streak mastery II",cost=1250,parents={"focus35"},column=3,row=8,auto=40,description="Max streak: 40"},
    {id="focus50",icon="focus",name="Streak mastery III",cost=2500,parents={"focus40"},column=3,row=9,auto=50,description="Max streak: 50"},
    {id="luck",icon="core",name="Lucky tokens I",cost=2,parents={"boot"},column=4,row=1,luck=2,description="Special odds x2\nNew drafts"},
    {id="luck2",icon="core",name="Lucky tokens II",cost=8,parents={"luck"},column=4,row=2,luck=3,description="Special odds x3\nNew drafts"},
    {id="luck3",icon="core",name="Lucky tokens III",cost=30,parents={"luck2"},column=4,row=3,luck=4,description="Special odds x4\nNew drafts"},
    {id="luck4",icon="core",name="Lucky tokens IV",cost=100,parents={"luck3"},column=4,row=4,luck=5,description="Special odds x5\nNew drafts"},
}
local TREE_COSTS={boot=1,tokens=3,agents=3,focus=3,cache=10,swarm=10,context=10,
    focus10=10,core=30,focus15=30,fortune=75,overclock=75,memory=75,focus20=75,
    fortune2=150,swarm2=150,memory2=150,focus25=150,mastery=400,focus30=400,
    focus35=800,focus40=1600,focus50=3200,luck=3,luck2=10,luck3=50,luck4=200}
for _,node in ipairs(NODES) do node.legacyCost=node.cost;node.cost=TREE_COSTS[node.id] end

-- New branches have no historical debit: older schemas cannot own them.
local EXPANSION={
    {id="cash1",icon="tokens",name="Token forge I",cost=5,parents={"tokens"},cash=1.15,description="Cash +15%"},
    {id="cash2",icon="tokens",name="Token forge II",cost=15,parents={"cash1"},cash=1.20,description="Cash +20%"},
    {id="cash3",icon="tokens",name="Token forge III",cost=45,parents={"cash2"},cash=1.30,description="Cash +30%"},
    {id="cash4",icon="tokens",name="Token forge IV",cost=135,parents={"cash3"},cash=1.50,description="Cash +50%"},
    {id="speed1",icon="agents",name="Agent drive I",cost=5,parents={"agents"},speed=1.05,description="Agent speed +5%"},
    {id="speed2",icon="agents",name="Agent drive II",cost=15,parents={"speed1"},speed=1.10,description="Agent speed +10%"},
    {id="speed3",icon="agents",name="Agent drive III",cost=45,parents={"speed2"},speed=1.15,description="Agent speed +15%"},
    {id="speed4",icon="agents",name="Agent drive IV",cost=135,parents={"speed3"},speed=1.20,description="Agent speed +20%"},
    {id="luck5",icon="core",name="Lucky tokens V",cost=400,parents={"luck4"},luck=6,description="Special odds x6\nNew drafts"},
    {id="luck6",icon="core",name="Lucky tokens VI",cost=700,parents={"luck5"},luck=7,description="Special odds x7\nNew drafts"},
    {id="luck7",icon="core",name="Lucky tokens VII",cost=1200,parents={"luck6"},luck=8,description="Special odds x8\nNew drafts"},
    {id="luck8",icon="core",name="Lucky tokens VIII",cost=2000,parents={"luck7"},luck=10,description="Special odds x10\nNew drafts"},
    {id="chip4",icon="context",name="Chip memory IV",cost=25,parents={"memory2"},chip=.01,description="Per Chip +1% cash"},
    {id="chip5",icon="context",name="Chip memory V",cost=75,parents={"chip4"},chip=.01,description="Per Chip +1% cash"},
    {id="chip6",icon="context",name="Chip memory VI",cost=225,parents={"chip5"},chip=.02,description="Per Chip +2% cash"},
    {id="chip7",icon="context",name="Chip memory VII",cost=675,parents={"chip6"},chip=.03,description="Per Chip +3% cash"},
    {id="swarm3",icon="swarm",name="Swarm link I",cost=10,parents={"swarm"},collect=1.75,description="Fragments x1.75"},
    {id="swarm4",icon="swarm",name="Swarm link II",cost=30,parents={"swarm3"},collect=2.25,description="Fragments x2.25"},
    {id="swarm5",icon="swarm",name="Swarm link III",cost=90,parents={"swarm4"},collect=2.75,description="Fragments x2.75"},
    {id="swarm6",icon="swarm",name="Swarm link IV",cost=270,parents={"swarm5"},collect=4,description="Fragments x4"},
    {id="focus60",icon="focus",name="Streak 60",cost=400,parents={"focus50"},auto=60,description="Max streak: 60"},
    {id="focus70",icon="focus",name="Streak 70",cost=700,parents={"focus60"},auto=70,description="Max streak: 70"},
    {id="focus80",icon="focus",name="Streak 80",cost=1200,parents={"focus70"},auto=80,description="Max streak: 80"},
    {id="focus100",icon="focus",name="Streak 100",cost=2000,parents={"focus80"},auto=100,description="Max streak: 100"},
    {id="fusion",icon="core",name="Quantum forge",cost=400,parents={"cash4","speed4"},cash=1.5,speed=1.05,description="Cash x1.5 / SPD +5%"},
    {id="magnet",icon="swarm",name="Magnetic core",cost=600,parents={"swarm6","fortune2"},cash=2,collect=4.5,description="Cash x2 / buffs x4.5"},
    {id="singularity",icon="core",name="Singularity",cost=900,parents={"mastery","chip7","luck8","focus100","fusion","magnet"},cash=2,description="Cash x2 / final core"},
}
for _,node in ipairs(EXPANSION) do node.introducedSchema=14;table.insert(NODES,node) end

local function valueMultiplier(state)
    local milestones=math.floor(state.computeLevel/10)
    -- Bound before exponentiation, including valid historical very large levels.
    if milestones>=12 then return 1000000000000 end
    return math.min(1000000000000,(1+state.computeLevel*.35)*10^milestones)
end
local STAGES={
    {name="BOOT",earned=0},{name="WORKSHOP",earned=100},{name="STUDIO",earned=1000},
    {name="AGENCY",earned=10000},{name="NETWORK",earned=100000},{name="LAB",earned=1000000},
    {name="FLEET",earned=10000000},{name="ORBIT",earned=100000000},
}
local function progression(state)
    local effect={cash=1,speed=1,collect=1,perChip=.05,autoSkillCap=0,autoSell=false,rarityBoost=1}
    for _,node in ipairs(NODES) do
        if (state.prestigeSkills or {})[node.id] then
            effect.cash=effect.cash*(node.cash or 1);effect.speed=effect.speed*(node.speed or 1)
            effect.collect=math.max(effect.collect,node.collect or 1)
            effect.rarityBoost=math.max(effect.rarityBoost,node.luck or 1)
            effect.perChip=effect.perChip+(node.chip or 0)
            effect.autoSkillCap=math.max(effect.autoSkillCap,node.auto or 0)
            effect.autoSell=effect.autoSell or node.autosell==true
        end
    end
    local stage=1
    for index,item in ipairs(STAGES) do if (state.lifetimeEarned or 0)>=item.earned then stage=index end end
    effect.streakCap=math.max(5,effect.autoSkillCap)
    effect.stage=stage;effect.stageName=STAGES[stage].name;effect.stageAt=STAGES[stage].earned
    effect.nextStageAt=STAGES[stage+1] and STAGES[stage+1].earned or nil
    effect.stageBonus=1+(stage-1)*.05
    effect.prestigeBonus=1+(state.prestigeClaimed or 0)*effect.perChip
    effect.money=effect.cash*effect.stageBonus*effect.prestigeBonus
    return effect
end
local FAMILIES={
    {id="ember",name="Ember",value=1.10,speed=1},
    {id="sprout",name="Sprout",value=1.08,speed=1.05},
    {id="volt",name="Volt",value=1,speed=1.20},
    {id="frost",name="Frost",value=1.15,speed=1},
    {id="nebula",name="Nebula",value=1.10,speed=1.10},
    {id="forge",name="Forge",value=1.20,speed=.95},
    {id="glitch",name="Glitch",value=.95,speed=1.25},
    {id="coral",name="Coral",value=1.05,speed=1.15},
    {id="sage",name="Sage",value=1.25,speed=.90},
}
local CRAFT_TIERS={
    {id="common",name="Common",fragments=3,money=100,chips=1,value=1,speed=1,weight=7500,drop=1},
    {id="rare",name="Rare",fragments=12,money=25000,chips=3,value=1.3,speed=1.05,weight=2000,drop=2},
    {id="epic",name="Epic",fragments=30,money=25000000,chips=12,value=1.8,speed=1.10,weight=450,drop=4},
    {id="legendary",name="Legendary",fragments=75,money=25000000000,chips=60,value=2.7,speed=1.15,weight=50,drop=8},
}
local CARDS={}
-- Keep the original nine IDs/order for saved decks; rarer copies follow.
for rank,tier in ipairs(CRAFT_TIERS) do for _,family in ipairs(FAMILIES) do
    local id=family.id..(rank==1 and "" or "_"..tier.id)
    CARDS[#CARDS+1]={id=id,name=family.name,familyId=family.id,mascotId=id,rarity=tier.name,rank=rank,
        value=family.value*tier.value,speed=family.speed*tier.speed,introducedSchema=rank==1 and 11 or 15}
end end
return {
    BUILD_VERSION = "0.72.0",
    SCHEMA_VERSION = 18,
    premiumMultiplier=function(state,kind,unixNow)
        local p=state.premium
        return p and (p.forever or (p[kind.."Until"] or 0)>(unixNow or 0)) and 2 or 1
    end,
    progression = progression,
    valueMultiplier = valueMultiplier,
    AUTO_SKILL_INTERVAL = 2,
    MAX_CARD_TYPING_RATE = 55,
    AGENT_CARDS = CARDS,
    AGENT_FAMILIES = FAMILIES,
    CRAFT_TIERS = CRAFT_TIERS,
    MAX_FRAGMENTS = 1000000,
    PRESTIGE_BASE = 1000,
    MAX_LIFETIME_EARNED = 8998912000000000,
    MAX_PRESTIGE_CHIPS = 20800,
    PRESTIGE_BONUS = 0.05,
    PRESTIGE_NODES = NODES,
    EMBEDDING_DIM = EMBEDDING_DIM,
    STARTING_LAYERS = { EMBEDDING_DIM, 2, 1 },
    STARTING_CREDITS = 0,
    MAX_CREDITS = 1000000000000,
    MAX_HIDDEN_LAYERS = 8,
    MAX_NEURONS_PER_LAYER = 16,
    LEGACY_MAX_COMPUTE_LEVEL = 20, -- migration validation only, never a live cap
    MAX_SAFE_COMPUTE_LEVEL = 9007199254740990,
    LIVE_VALUE_GROWTH = 1.4,
    LIVE_AGENT_GROWTH = 6,
    LIVE_CONTEXT_GROWTH = 4,
    -- Frozen retired-upgrade fixture prices; live prices use LIVE_*_GROWTH.
    UPGRADE_COST_MULTIPLIER = 0.1,
    UPGRADE_GROWTH_MULTIPLIER = 0.25,
    NEURON_BASE_COST = 12,
    NEURON_COST_GROWTH = 1.42,
    LAYER_BASE_COST = 2000,
    LAYER_COST_GROWTH = 2.4,
    COMPUTE_BASE_COST = 10,
    COMPUTE_COST_GROWTH = 1.65,
    TOKEN_BASE_COST = 100,
    TOKEN_COST_GROWTH = 1.5,
    MAX_TOKEN_LEVEL = 7,
    MAX_TYPING_LEVEL = 20,
    MAX_CLICK_LEVEL = 3,
    STREAK_BASE_DIVISOR = 5,
    MAX_DIVISOR_LEVEL = 3,
    DIVISOR_BASE_COST = 120,
    DIVISOR_COST_GROWTH = 2,
    CLICK_BASE_COST = 60,
    CLICK_COST_GROWTH = 2,
    TYPING_BASE_RATE = 4,
    AGENT_INTERVAL = 1,
    AGENT_POLL_INTERVAL = 0.05,
    AGENT_COALESCE_WINDOW = 0.15,
    AGENT_TIMING_JITTER = 0.06,
    AGENT_REQUESTS_PER_SECOND = 24,
    AGENT_REQUEST_BURST = 16,
    TYPING_RATE_PER_LEVEL = 2,
    TYPING_BASE_COST = 40,
    TYPING_COST_GROWTH = 1.8,
    PROMPT_BASE_TOKENS = 8,
    PROMPT_TOKENS_PER_LEVEL = 8,
    PROMPT_MAX_TOKENS = 64,
    INSTANT_TOKEN_TPC = 8,
    INSTANT_TOKEN_RATE = 2,
    PROMPT_MAX_BYTES = 2048,
    CREDITS_PER_NEURON_SECOND = 0.35,
    DEPTH_BONUS = 0.25,
    COMPUTE_BONUS = 0.35,
    MAX_SIMULATION_STEP = 86400,
    SNAPSHOT_INTERVAL = 0.5,
    REQUESTS_PER_SECOND = 10,
    REQUEST_BURST = 12,
    MANUAL_MIN_INTERVAL = 0.12,
    LIVE_SEND_INTERVAL = 0.3,
    LIVE_RECEIPT_TIMEOUT = 5,
    -- Per-token offers, rolled only on the server. Exclusive weights sum to 10000.
    SPECIAL_TOKENS = {
        { rarity = "Common", weight = 9689, multiplier = 1 },
        { rarity = "Uncommon", weight = 200, multiplier = 3, denominator = 50 },
        { rarity = "Rare", weight = 100, multiplier = 10, denominator = 100 },
        { rarity = "Epic", weight = 10, multiplier = 50, denominator = 1000 },
        { rarity = "Legendary", weight = 1, multiplier = 250, denominator = 10000 },
    },
    -- Legacy portable PromptRules.submit/NetworkFlow fixtures only. Live prompts
    -- use the server-issued SPECIAL_TOKENS above, not these old output words.
    OUTPUT_TOKENS = {
        { word = "FIX", rarity = "Common", weight = 7000, multiplier = 1 },
        { word = "PATCH", rarity = "Uncommon", weight = 2000, multiplier = 2 },
        { word = "FEATURE", rarity = "Rare", weight = 800, multiplier = 5 },
        { word = "RELEASE", rarity = "Epic", weight = 150, multiplier = 15 },
        { word = "UNICORN", rarity = "Legendary", weight = 45, multiplier = 50 },
        { word = "NEXT_BIG_THING", rarity = "Mythic", weight = 5, multiplier = 250 },
    },
}

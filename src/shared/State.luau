--!nonstrict
local State = {}
State.METRIC_CAP=1000000000000000
State.METRIC_COUNTERS={"sessions","onlineSeconds","focusedSecondsReported","sellButtonReported","sellEnterReported",
    "sales","saleRejected","tokensSold","moneyEarned","skillGood","skillGreat","skillMiss","skillRejected",
    "autoChecks","visitors","fragmentsCollected","prestiges","tutorialDismissed"}
State.METRIC_MAPS={"upgradePurchases","upgradeLevels","skills","crafts","robuxPrompts","robuxDelivered","robuxCanceled","robuxUnavailable"}
function State.newAnalytics()
    local result={recent={},firstRobux=false}
    for _,key in ipairs(State.METRIC_COUNTERS) do result[key]=0 end
    for _,key in ipairs(State.METRIC_MAPS) do result[key]={} end
    return result
end
function State.copyAnalytics(source)
    local result=State.newAnalytics()
    if not source then return result end
    for _,key in ipairs(State.METRIC_COUNTERS) do result[key]=source[key] end
    for _,key in ipairs(State.METRIC_MAPS) do for id,value in pairs(source[key] or {}) do result[key][id]=value end end
    for _,entry in ipairs(source.recent or {}) do
        local copy={};for key,value in pairs(entry) do copy[key]=value end;result.recent[#result.recent+1]=copy
    end
    if source.firstRobux then result.firstRobux={};for key,value in pairs(source.firstRobux) do result.firstRobux[key]=value end end
    return result
end

function State.isFinite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function integer(value, low, high)
    return State.isFinite(value) and value % 1 == 0 and value >= low and value <= high
end

function State.new(balance)
    local layers = {}
    for index, count in ipairs(balance.STARTING_LAYERS) do layers[index] = count end
    layers[1] = balance.EMBEDDING_DIM
    local owned,deck,fragments={ember=true},{},{}
    for _,family in ipairs(balance.AGENT_FAMILIES) do fragments[family.id]=0 end
    for index=1,balance.MAX_HIDDEN_LAYERS do deck[index]=false end
    return { schemaVersion = balance.SCHEMA_VERSION, credits = balance.STARTING_CREDITS,
        layerSizes = layers, computeLevel = 0, tokenLevel = 0, typingLevel = 0, clickLevel = 0, divisorLevel = 0, batches = 0, milestones = {},tutorialDone=false,analytics=State.newAnalytics(),
        chips=0,prestigeClaimed=0,prestigeCount=0,lifetimeEarned=0,prestigeSkills={},legacyPrestigeSkills={},cardOwned=owned,cardDeck=deck,
        fragments=fragments,cardCrafted={},premium={moneyUntil=0,chipsUntil=0,forever=false,agentCredits=0,bonusChips=0,receipts={}} }
end

function State.copy(state,gameplayOnly)
    local result = { schemaVersion = state.schemaVersion, credits = state.credits, layerSizes = {},
        computeLevel = state.computeLevel, tokenLevel = state.tokenLevel, typingLevel = state.typingLevel, clickLevel = state.clickLevel, divisorLevel = state.divisorLevel,
        batches = state.batches, milestones = {},tutorialDone=state.tutorialDone,analytics=not gameplayOnly and State.copyAnalytics(state.analytics) or nil,chips=state.chips,prestigeClaimed=state.prestigeClaimed,
        prestigeCount=state.prestigeCount,lifetimeEarned=state.lifetimeEarned,prestigeSkills={},legacyPrestigeSkills={},cardOwned={},cardDeck={},fragments={},cardCrafted={},
        premium={moneyUntil=0,chipsUntil=0,forever=false,agentCredits=0,bonusChips=0,receipts={}} }
    for index, count in ipairs(state.layerSizes) do result.layerSizes[index] = count end
    for name, completed in pairs(state.milestones) do result.milestones[name] = completed end
    for id,owned in pairs(state.prestigeSkills or {}) do result.prestigeSkills[id]=owned end
    for id,owned in pairs(state.legacyPrestigeSkills or {}) do result.legacyPrestigeSkills[id]=owned end
    for id,owned in pairs(state.cardOwned or {}) do result.cardOwned[id]=owned end
    for index,value in ipairs(state.cardDeck or {}) do result.cardDeck[index]=value end
    for id,value in pairs(state.fragments or {}) do result.fragments[id]=value end
    for id,value in pairs(state.cardCrafted or {}) do result.cardCrafted[id]=value end
    if state.premium then
        for _,key in ipairs({"moneyUntil","chipsUntil","forever","agentCredits","bonusChips"}) do result.premium[key]=state.premium[key] end
        for id,sku in pairs(state.premium.receipts or {}) do result.premium.receipts[id]=sku end
    end
    return result
end

local function readLayers(layers, balance, inputWidth)
    if type(layers) ~= "table" then return nil, "invalid_layers" end
    local count, result = #layers, {}
    if count < 3 or count > balance.MAX_HIDDEN_LAYERS + 2 then return nil, "invalid_layers" end
    for key, value in pairs(layers) do
        if not integer(key, 1, count) or not integer(value, 1, balance.MAX_NEURONS_PER_LAYER) then
            return nil, "invalid_layers"
        end
    end
    for index = 1, count do
        if not integer(layers[index], 1, balance.MAX_NEURONS_PER_LAYER) then return nil, "invalid_layers" end
        result[index] = layers[index]
    end
    if result[1] ~= inputWidth
        or result[count] ~= balance.STARTING_LAYERS[#balance.STARTING_LAYERS] then return nil, "invalid_endpoints" end
    return result
end

-- Allowlist current data and explicitly migrate known historical schemas.
-- Never downgrade a schema, reset invalid data, or mutate the stored source.
function State.fromStored(data, balance)
    if type(data) ~= "table" or (data.schemaVersion ~= balance.SCHEMA_VERSION
        and data.schemaVersion ~= 1 and data.schemaVersion ~= 2 and data.schemaVersion ~= 3
        and data.schemaVersion ~= 4 and data.schemaVersion ~= 5 and data.schemaVersion ~= 6 and data.schemaVersion ~= 7 and data.schemaVersion ~= 8 and data.schemaVersion ~= 9 and data.schemaVersion ~= 10 and data.schemaVersion ~= 11 and data.schemaVersion ~= 12 and data.schemaVersion ~= 13 and data.schemaVersion ~= 14 and data.schemaVersion ~= 15 and data.schemaVersion ~= 16 and data.schemaVersion ~= 17) then return nil, "unsupported_schema" end
    if not State.isFinite(data.credits) or data.credits < 0 or data.credits > balance.MAX_CREDITS then
        return nil, "invalid_credits"
    end
    local layers, reason
    if data.schemaVersion == 4 then
        if not integer(data.blockCount, 1, balance.MAX_HIDDEN_LAYERS) then return nil, "invalid_blocks" end
        if not integer(data.embDim, 2, balance.MAX_NEURONS_PER_LAYER) then return nil, "invalid_emb_dim" end
        layers = { balance.STARTING_LAYERS[1] }
        for _ = 1, data.blockCount do layers[#layers + 1] = data.embDim end
        layers[#layers + 1] = balance.STARTING_LAYERS[#balance.STARTING_LAYERS]
    else
        layers, reason = readLayers(data.layerSizes, balance,
            data.schemaVersion >= 6 and balance.EMBEDDING_DIM or 2)
        if not layers then return nil, reason end
    end
    layers[1] = balance.EMBEDDING_DIM
    if not integer(data.computeLevel, 0, data.schemaVersion<12 and balance.LEGACY_MAX_COMPUTE_LEVEL or balance.MAX_SAFE_COMPUTE_LEVEL) then return nil, "invalid_compute" end
    local tokenLevel = data.schemaVersion == 1 and 0 or data.tokenLevel
    if not integer(tokenLevel, 0, data.schemaVersion<12 and 15 or balance.MAX_TOKEN_LEVEL) then return nil, "invalid_token_level" end
    local typingLevel = data.schemaVersion < 7 and 0 or data.typingLevel
    if not integer(typingLevel, 0, balance.MAX_TYPING_LEVEL) then return nil, "invalid_typing_level" end
    local clickLevel=data.schemaVersion<8 and 0 or data.clickLevel
    if not integer(clickLevel,0,balance.MAX_CLICK_LEVEL) then return nil,"invalid_click_level" end
    local divisorLevel=data.schemaVersion<9 and 0 or data.divisorLevel
    if not integer(divisorLevel,0,balance.MAX_DIVISOR_LEVEL) then return nil,"invalid_divisor_level" end
    local refund = 0
    if data.schemaVersion<12 then
        -- Frozen 0.59 prices. Refund removed context levels once on migration.
        for level=balance.MAX_TOKEN_LEVEL,tokenLevel-1 do refund=refund+math.floor(2*1.5^(level*.25)) end
        tokenLevel=math.min(tokenLevel,balance.MAX_TOKEN_LEVEL)
    end
    if data.schemaVersion == 3 or data.schemaVersion == 4 then
        if not integer(data.attentionHeads, 1, 8) then return nil, "invalid_attention_heads" end
        -- Historical 0.4/0.5 head prices, frozen independently of future balance.
        -- Current-schema reads cannot refund again, even if obsolete fields exist.
        for level = 0, data.attentionHeads - 2 do refund = refund + math.floor(4 * 1.6 ^ (level * 0.25)) end
    end
    if not integer(data.batches, 0, balance.MAX_CREDITS) then return nil, "invalid_batches" end
    if type(data.milestones) ~= "table" then return nil, "invalid_milestones" end
    local result = State.new(balance)
    if data.schemaVersion>=18 then
        local a=data.analytics
        if type(a)~="table" then return nil,"invalid_analytics" end
        local allowed={recent=true,firstRobux=true}
        for _,key in ipairs(State.METRIC_COUNTERS) do
            allowed[key]=true
            if not State.isFinite(a[key]) or a[key]<0 or a[key]>State.METRIC_CAP or (key~="moneyEarned" and a[key]%1~=0) then return nil,"invalid_analytics" end
        end
        local catalog={upgradePurchases={upgrade_compute=true,add_layer=true,upgrade_tokens=true},upgradeLevels={upgrade_compute=true,add_layer=true,upgrade_tokens=true},skills={},crafts={}}
        for _,node in ipairs(balance.PRESTIGE_NODES) do catalog.skills[node.id]=true end
        for _,card in ipairs(balance.AGENT_CARDS) do catalog.crafts[card.id]=true end
        for _,key in ipairs(State.METRIC_MAPS) do
            allowed[key]=true
            if type(a[key])~="table" then return nil,"invalid_analytics" end
            local ids=catalog[key] or {money_hour=true,chips_hour=true,agent=true,forever=true}
            for id,value in pairs(a[key]) do if not ids[id] or not integer(value,0,State.METRIC_CAP) then return nil,"invalid_analytics" end end
        end
        for key in pairs(a) do if not allowed[key] then return nil,"invalid_analytics" end end
        local eventNames={upgrade=true,skill_buy=true,craft=true,prestige=true,robux_prompt=true,robux_delivered=true,robux_cancel=true,robux_unavailable=true,pass_owned=true,tutorial=true,session_end=true}
        local function event(entry)
            if type(entry)~="table" or not eventNames[entry.event] or type(entry.kind)~="string" or #entry.kind>80
                or not entry.kind:match("^[%w_%-]+$") or type(entry.stage)~="string" or #entry.stage>64 then return false end
            local fields={event=true,kind=true,stage=true}
            for _,key in ipairs({"at","sessionSeconds","onlineSeconds","sessionNumber","agents","computeLevel","context","prestiges","money","chips","amount"}) do
                fields[key]=true
                if not State.isFinite(entry[key]) or entry[key]<0 or entry[key]>State.METRIC_CAP then return false end
            end
            for key in pairs(entry) do if not fields[key] then return false end end
            return true
        end
        if type(a.recent)~="table" or #a.recent>24 then return nil,"invalid_analytics" end
        local count=0
        for index,entry in pairs(a.recent) do if not integer(index,1,#a.recent) or not event(entry) then return nil,"invalid_analytics" end;count=count+1 end
        if count~=#a.recent or (a.firstRobux~=false and (not event(a.firstRobux) or (a.firstRobux.event~="robux_delivered" and a.firstRobux.event~="pass_owned"))) then return nil,"invalid_analytics" end
        result.analytics=State.copyAnalytics(a)
    end
    if data.schemaVersion>=17 then
        if type(data.tutorialDone)~="boolean" then return nil,"invalid_tutorial" end
        result.tutorialDone=data.tutorialDone
    end
    if data.schemaVersion>=16 then
        local p=data.premium
        if type(p)~="table" or not integer(p.moneyUntil,0,4102444800) or not integer(p.chipsUntil,0,4102444800)
            or type(p.forever)~="boolean" or not integer(p.agentCredits,0,1000000) or not integer(p.bonusChips,0,balance.MAX_PRESTIGE_CHIPS)
            or type(p.receipts)~="table" then return nil,"invalid_premium" end
        local count=0
        for id,sku in pairs(p.receipts) do
            if type(id)~="string" or #id<1 or #id>50 or not id:match("^[%w_%-]+$")
                or (sku~="money_hour" and sku~="chips_hour" and sku~="agent") then return nil,"invalid_receipt" end
            count=count+1;if count>256 then return nil,"too_many_pending_receipts" end
        end
        for key in pairs(p) do
            if key~="moneyUntil" and key~="chipsUntil" and key~="forever" and key~="agentCredits" and key~="bonusChips" and key~="receipts" then return nil,"invalid_premium" end
        end
        for _,key in ipairs({"moneyUntil","chipsUntil","forever","agentCredits","bonusChips"}) do result.premium[key]=p[key] end
        for id,sku in pairs(p.receipts) do result.premium.receipts[id]=sku end
    end
    local cardCatalog,craftedSpent={},0
    for _,card in ipairs(balance.AGENT_CARDS) do
        if data.schemaVersion>=card.introducedSchema then cardCatalog[card.id]=card end
    end
    if data.schemaVersion>=15 then
        if type(data.fragments)~="table" or type(data.cardCrafted)~="table" or type(data.cardOwned)~="table" then return nil,"invalid_crafting" end
        local families,entries={},0
        for _,family in ipairs(balance.AGENT_FAMILIES) do families[family.id]=true end
        for id,value in pairs(data.fragments) do
            if not families[id] or not integer(value,0,balance.MAX_FRAGMENTS) then return nil,"invalid_fragments" end
            result.fragments[id]=value;entries=entries+1
        end
        if entries~=#balance.AGENT_FAMILIES then return nil,"invalid_fragments" end
        for id,owned in pairs(data.cardCrafted) do
            local card=cardCatalog[id]
            if not card or owned~=true or data.cardOwned[id]~=true then return nil,"invalid_crafted_card" end
            result.cardCrafted[id]=true;craftedSpent=craftedSpent+balance.CRAFT_TIERS[card.rank].chips
        end
        for id,owned in pairs(data.cardOwned) do
            local card=cardCatalog[id]
            if card and card.rank>1 and not result.cardCrafted[id] then return nil,"unpaid_crafted_card" end
        end
    end
    if data.schemaVersion>=10 then
        local chipCap=data.schemaVersion<14 and 10000 or data.schemaVersion<15 and 20000 or balance.MAX_PRESTIGE_CHIPS*(data.schemaVersion>=16 and 2 or 1)
        local earnedCap=data.schemaVersion<14 and 1000000000000000 or data.schemaVersion<15 and 8000000000000000 or balance.MAX_LIFETIME_EARNED
        if not State.isFinite(data.lifetimeEarned) or data.lifetimeEarned<0 or data.lifetimeEarned>earnedCap
            or not integer(data.chips,0,chipCap)
            or not integer(data.prestigeClaimed,0,chipCap)
            or not integer(data.prestigeCount,0,data.prestigeClaimed)
            or (data.prestigeClaimed>0 and data.prestigeCount==0)
            or result.premium.bonusChips>data.prestigeClaimed-result.premium.bonusChips
            or data.prestigeCount>data.prestigeClaimed-result.premium.bonusChips
            or data.prestigeClaimed-result.premium.bonusChips>balance.MAX_PRESTIGE_CHIPS
            or data.lifetimeEarned<balance.PRESTIGE_BASE*(data.prestigeClaimed-result.premium.bonusChips)^3
            or type(data.prestigeSkills)~="table" then return nil,"invalid_prestige" end
        local nodes,spent={},0
        for _,node in ipairs(balance.PRESTIGE_NODES) do
            if data.schemaVersion>=(node.introducedSchema or (node.icon and 12 or 10)) then nodes[node.id]=node end
        end
        if data.schemaVersion>=13 then
            if type(data.legacyPrestigeSkills)~="table" then return nil,"invalid_legacy_skills" end
            for id,owned in pairs(data.legacyPrestigeSkills) do
                if not nodes[id] or not nodes[id].legacyCost or owned~=true or data.prestigeSkills[id]~=true then return nil,"invalid_legacy_skills" end
                result.legacyPrestigeSkills[id]=true
            end
        end
        for id,owned in pairs(data.prestigeSkills) do
            local node=nodes[id]
            if not node or owned~=true then return nil,"invalid_prestige_skill" end
            for _,parent in ipairs(node.parents) do if data.prestigeSkills[parent]~=true then return nil,"invalid_prestige_parent" end end
            local legacy=data.schemaVersion<13 or result.legacyPrestigeSkills[id]==true
            spent=spent+(legacy and node.legacyCost or node.cost);result.prestigeSkills[id]=true
            if legacy then result.legacyPrestigeSkills[id]=true end
        end
        if data.chips+spent+craftedSpent~=data.prestigeClaimed then return nil,"invalid_chip_balance" end
        result.chips,result.prestigeClaimed,result.prestigeCount=data.chips,data.prestigeClaimed,data.prestigeCount
        result.lifetimeEarned=data.lifetimeEarned
    end
    result.credits = math.min(balance.MAX_CREDITS, data.credits + refund)
    result.layerSizes, result.computeLevel, result.tokenLevel, result.batches = layers, data.computeLevel, tokenLevel, data.batches
    result.typingLevel = typingLevel
    result.clickLevel = clickLevel
    result.divisorLevel = divisorLevel
    if data.schemaVersion>=11 then
        if type(data.cardOwned)~="table" or type(data.cardDeck)~="table" then return nil,"invalid_cards" end
        local catalog,used=cardCatalog,{}
        result.cardOwned,result.cardDeck={},{}
        for id,owned in pairs(data.cardOwned) do
            if not catalog[id] or owned~=true then return nil,"invalid_owned_card" end
            result.cardOwned[id]=true
        end
        local entries=0
        for index in pairs(data.cardDeck) do
            if not integer(index,1,balance.MAX_HIDDEN_LAYERS) then return nil,"invalid_deck" end
            entries=entries+1
        end
        if entries~=balance.MAX_HIDDEN_LAYERS then return nil,"invalid_deck" end
        for index=1,balance.MAX_HIDDEN_LAYERS do
            local id=data.cardDeck[index]
            if id~=false then
                if type(id)~="string" or not result.cardOwned[id] or used[id] or index>#layers-2 then return nil,"invalid_deck_card" end
                used[id]=true
            end
            result.cardDeck[index]=id
        end
    else
        -- Historical schemas1..10 received the original nine Common starters.
        for _,card in ipairs(balance.AGENT_CARDS) do if card.rank==1 then result.cardOwned[card.id]=true end end
    end
    for _, name in ipairs({ "joined", "first_batch", "first_neuron", "first_compute", "first_layer" }) do
        if data.milestones[name] == true then result.milestones[name] = true end
    end
    return result
end

-- Wire snapshots omit server-only behavior history. This is not a storage loader.
function State.fromSnapshot(data,balance)
    if type(data)~="table" then return nil,"invalid_snapshot" end
    local gameplay={};for key,value in pairs(data) do gameplay[key]=value end
    gameplay.analytics=State.newAnalytics()
    return State.fromStored(gameplay,balance)
end
return State

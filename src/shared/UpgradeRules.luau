--!nonstrict
local Rules = {}
local function livePrice(base,growth,level,balance)
    -- Clamp before exponentiation; finite money is a storage guard, not a level cap.
    if level>=math.log(balance.MAX_CREDITS/base)/math.log(growth) then return balance.MAX_CREDITS end
    return math.max(1,math.floor(base*growth^level))
end

local function price(base, growth, level, balance)
    return math.max(1, math.min(balance.MAX_CREDITS, math.floor(base * balance.UPGRADE_COST_MULTIPLIER
        * growth ^ (level * balance.UPGRADE_GROWTH_MULTIPLIER))))
end

function Rules.workersPerAgent(state)
    local workers = state.layerSizes[2]
    for index = 3, #state.layerSizes - 1 do workers = math.min(workers, state.layerSizes[index]) end
    return workers
end

-- Authored modifiers may add/multiply C; never supplied by command payloads.
function Rules.streakDivisor(state,balance,modifiers)
    local value=balance.STREAK_BASE_DIVISOR-state.divisorLevel
    for _,modifier in ipairs(modifiers or {}) do
        value=(value+(modifier.add or 0))*(modifier.multiply or 1)
    end
    return math.max(1,math.min(100,value))
end

-- Historical upgrade math remains for inherited regression fixtures and saved
-- progression. Live availability is strictly limited by Protocol.validate before
-- GameService calls purchase/purchaseMany: value, agent count and context only.
function Rules.quote(state, action, layerIndex, balance)
    if action == "upgrade_workers" then
        if layerIndex ~= nil then return nil, "unexpected_payload" end
        local workers = Rules.workersPerAgent(state)
        if workers >= balance.MAX_NEURONS_PER_LAYER then return nil, "limit" end
        local added = math.max(0, workers - balance.STARTING_LAYERS[2])
        return price(balance.NEURON_BASE_COST, balance.NEURON_COST_GROWTH, added, balance)
    elseif action == "add_layer" then
        local hidden = #state.layerSizes - 2
        if hidden >= balance.MAX_HIDDEN_LAYERS then return nil, "limit" end
        return livePrice(balance.LAYER_BASE_COST, balance.LIVE_AGENT_GROWTH, hidden - 1, balance)
    elseif action == "upgrade_compute" then
        if state.computeLevel>=balance.MAX_SAFE_COMPUTE_LEVEL then return nil,"numeric_limit" end
        return livePrice(balance.COMPUTE_BASE_COST, balance.LIVE_VALUE_GROWTH, state.computeLevel, balance)
    elseif action == "upgrade_divisor" then
        if layerIndex~=nil then return nil,"unexpected_payload" end
        if state.divisorLevel>=balance.MAX_DIVISOR_LEVEL then return nil,"limit" end
        return price(balance.DIVISOR_BASE_COST,balance.DIVISOR_COST_GROWTH,state.divisorLevel,balance)
    elseif action == "upgrade_click" then
        if layerIndex~=nil then return nil,"unexpected_payload" end
        if state.clickLevel>=balance.MAX_CLICK_LEVEL then return nil,"limit" end
        return price(balance.CLICK_BASE_COST,balance.CLICK_COST_GROWTH,state.clickLevel,balance)
    elseif action == "upgrade_typing" then
        if layerIndex ~= nil then return nil, "unexpected_payload" end
        if state.typingLevel >= balance.MAX_TYPING_LEVEL then return nil, "limit" end
        return price(balance.TYPING_BASE_COST, balance.TYPING_COST_GROWTH, state.typingLevel, balance)
    elseif action == "upgrade_tokens" then
        if state.tokenLevel >= balance.MAX_TOKEN_LEVEL then return nil, "limit" end
        return livePrice(balance.TOKEN_BASE_COST, balance.LIVE_CONTEXT_GROWTH, state.tokenLevel, balance)
    end
    return nil, "unknown_action"
end

local function grant(state,action,balance)
    if action == "upgrade_workers" then
        for index = 2, #state.layerSizes - 1 do
            state.layerSizes[index] = math.min(balance.MAX_NEURONS_PER_LAYER, state.layerSizes[index] + 1)
        end
    elseif action == "add_layer" then
        table.insert(state.layerSizes, #state.layerSizes, Rules.workersPerAgent(state))
    elseif action == "upgrade_divisor" then
        state.divisorLevel=state.divisorLevel+1
    elseif action == "upgrade_click" then
        state.clickLevel=state.clickLevel+1
    elseif action == "upgrade_typing" then
        state.typingLevel = state.typingLevel + 1
    elseif action == "upgrade_tokens" then
        state.tokenLevel = state.tokenLevel + 1
    else
        state.computeLevel = state.computeLevel + 1
    end
end

function Rules.purchase(state, action, layerIndex, balance)
    local cost, reason = Rules.quote(state, action, layerIndex, balance)
    if not cost then return false, reason end
    if state.credits < cost then return false, "insufficient_credits" end
    state.credits = state.credits - cost
    grant(state,action,balance)
    return true, cost
end

Rules.SHOP_QUANTITIES={1,5,10,25,"max"}
function Rules.validQuantity(quantity)
    for _,value in ipairs(Rules.SHOP_QUANTITIES) do if quantity==value then return true end end
    return false
end
-- Quote on a private projection, including every successive level's price.
-- Fixed batches clamp only at the cap; MAX additionally clamps at the balance.
function Rules.quoteMany(state,action,quantity,balance)
    if action~="upgrade_compute" and action~="add_layer" and action~="upgrade_tokens" then return nil,"unknown_action" end
    if not Rules.validQuantity(quantity) then return nil,"invalid_quantity" end
    local first,reason=Rules.quote(state,action,nil,balance)
    if not first then return nil,reason end
    local after={computeLevel=state.computeLevel,tokenLevel=state.tokenLevel,layerSizes={}}
    for index,value in ipairs(state.layerSizes) do after.layerSizes[index]=value end
    local count,total=0,0
    -- With $1e12 and the slowest live growth (1.4), fewer than 100
    -- successive value levels are affordable. 512 includes rounding headroom.
    for _=1,quantity=="max" and 512 or quantity do
        local cost=Rules.quote(after,action,nil,balance)
        if not cost or (quantity=="max" and total+cost>state.credits) then break end
        total=total+cost;count=count+1;grant(after,action,balance)
    end
    return {count=count,cost=total,nextCost=first,after=after}
end
function Rules.purchaseMany(state,action,quantity,balance)
    local quote,reason=Rules.quoteMany(state,action,quantity,balance)
    if not quote then return false,reason end
    if quote.count==0 or state.credits<quote.cost then return false,"insufficient_credits" end
    -- One non-yielding transaction; no mutation while planning or on rejection.
    state.credits=state.credits-quote.cost
    for _=1,quote.count do grant(state,action,balance) end
    return true,quote
end

return Rules

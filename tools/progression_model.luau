-- Loaded by model_progression.py after the real shared modules.
local file=assert(io.open("build/progression-model.csv","w"))
file:write("scenario,streak,lifetime_target,seconds,agents,value_level,context,chips_claimed,reached\n")
local previous=false
local function output(state,streak)
    local e=B.progression(state)
    local rarity=0
    for rank,tier in ipairs(B.SPECIAL_TOKENS) do rarity=rarity+Session.tokenWeights(state,B)[rank]/10000*tier.multiplier end
    local rate=(#state.layerSizes-2)*math.min(B.TYPING_BASE_RATE*e.speed,(math.floor(streak/5)+1)*e.speed)
    local cap=math.min(64,8+8*state.tokenLevel)
    local collect=math.max(.008,math.min(.045,.6/cap))*(cap-1)
    local cycle=cap/rate+collect+.15 -- assumed RTT/dispatch overhead
    local value=Session.baseReward(state,B,Sim)
    if previous then
        -- Frozen0.61 reference, not a second live economy implementation.
        value=math.floor(Sim.batchReward(state)*(1+.35*state.computeLevel)
            *(1+.25*math.floor(state.computeLevel/10))*e.money*100+.5)/100
    end
    return cap/cycle*value*rarity*(1+streak*.1),cycle,cap
end
for _,scenario in ipairs({{name="baseline061",chips=0,streaks={0,5},previous=true},
    {name="fresh",chips=0,streaks={0,5}},
    {name="rebuild",chips=14,streaks={0,5}},{name="mastery",chips=19980,streaks={50,80,100}}}) do
    previous=scenario.previous==true
    local prices={};for key,value in pairs(B) do prices[key]=value end
    if previous then
        prices.COMPUTE_BASE_COST=30;prices.LIVE_VALUE_GROWTH=1.15
        prices.LIVE_AGENT_GROWTH=2;prices.LIVE_CONTEXT_GROWTH=2
    end
    for _,streak in ipairs(scenario.streaks) do
        local state=State.new(B)
        if scenario.chips>0 then
            state.lifetimeEarned=B.PRESTIGE_BASE*scenario.chips^3;state.prestigeClaimed=scenario.chips;state.prestigeCount=1
            state.prestigeSkills={boot=true,tokens=true,cache=true}
            if scenario.name=="mastery" then
                for _,node in ipairs(B.PRESTIGE_NODES) do
                    state.prestigeSkills[node.id]=true
                end
            end
        end
        local spent=0
        for _,node in ipairs(B.PRESTIGE_NODES) do if state.prestigeSkills[node.id] then spent=spent+node.cost end end
        state.chips=state.prestigeClaimed-spent
        assert(State.fromStored(state,B))
        assert(streak<=B.progression(state).streakCap)
        local elapsed=0
        local initial=state.lifetimeEarned
        for _,target in ipairs({1000,27000,1000000,1000000000,1000000000000}) do
            local goal=initial+target
            while state.lifetimeEarned<goal and elapsed<86400 do
                local income,cycle,cap=output(state,streak)
                local best,bestROI
                for _,action in ipairs({"upgrade_compute","add_layer","upgrade_tokens"}) do
                    local cost=Rules.quote(state,action,nil,prices)
                    if cost then
                        local projected=State.copy(state);projected.credits=B.MAX_CREDITS
                        assert(Rules.purchase(projected,action,nil,prices))
                        local roi=(output(projected,streak)-income)/cost
                        if roi>0 and (not bestROI or roi>bestROI) then best,bestROI=action,roi end
                    end
                end
                if best and state.credits>=Rules.quote(state,best,nil,prices) then assert(Rules.purchase(state,best,nil,prices))
                else
                    local reward=math.min(B.MAX_CREDITS-state.credits,income*cycle)
                    state.credits=state.credits+reward;state.lifetimeEarned=math.min(B.MAX_LIFETIME_EARNED,state.lifetimeEarned+reward)
                    elapsed=elapsed+cycle
                end
            end
            file:write(string.format("%s,%d,%d,%.2f,%d,%d,%d,%d,%s\n",scenario.name,streak,target,elapsed,#state.layerSizes-2,state.computeLevel,8+state.tokenLevel*8,state.prestigeClaimed,tostring(state.lifetimeEarned>=goal)))
        end
    end
end
file:close()
print("Wrote build/progression-model.csv (idealized expected-value scenarios, not playtests)")

local curve=assert(io.open("build/inflation-curve.csv","w"))
curve:write("value_level,common_token_money,next_value_price,price_in_tokens\n")
local state=State.new(B)
for _,level in ipairs({0,1,5,9,10,19,20,29,30,40,50,60,70,80,1000000}) do
    state.computeLevel=level
    local value=Session.baseReward(state,B,Sim);local cost=Rules.quote(state,"upgrade_compute",nil,B)
    assert(value>=1 and value<=B.MAX_CREDITS and cost>=1 and cost<=B.MAX_CREDITS)
    curve:write(string.format("%d,%.2f,%.0f,%.2f\n",level,value,cost,cost/value))
end
curve:close()
local prices=assert(io.open("build/inflation-prices.csv","w"))
prices:write("kind,step,price\n")
for _,action in ipairs({"add_layer","upgrade_tokens"}) do
    state=State.new(B)
    for level=0,6 do
        local cost=assert(Rules.quote(state,action,nil,B));state.credits=cost
        prices:write(string.format("%s,%d,%.0f\n",action,level+1,cost))
        assert(Rules.purchase(state,action,nil,B))
    end
end
local total=0
local depths={}
for _,node in ipairs(B.PRESTIGE_NODES) do
    local depth=0
    for _,parent in ipairs(node.parents) do depth=math.max(depth,(depths[parent] or 0)+1) end
    depths[node.id]=depth
    total=total+node.cost;prices:write(string.format("%s,%d,%d\n",node.id,depth,node.cost))
end
assert(total<=B.MAX_PRESTIGE_CHIPS)
prices:close()
print("Wrote build/inflation-curve.csv and build/inflation-prices.csv; full tree costs "..total.." Chips")

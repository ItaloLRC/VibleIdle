--!nonstrict
-- Chips are minted only from confirmed lifetime prompt earnings, never balance,
-- idle time, purchases, skill attempts, Studio money grants or client amounts.
local Prestige={}
function Prestige.level(earned,balance)
    local level=math.min(balance.MAX_PRESTIGE_CHIPS,math.floor((earned/balance.PRESTIGE_BASE)^(1/3)))
    while level<balance.MAX_PRESTIGE_CHIPS and balance.PRESTIGE_BASE*(level+1)^3<=earned do level=level+1 end
    while level>0 and balance.PRESTIGE_BASE*level^3>earned do level=level-1 end
    return level
end
function Prestige.view(state,balance,unixNow)
    local level=Prestige.level(state.lifetimeEarned,balance)
    local effect=balance.progression(state)
    local baseClaimed=state.prestigeClaimed-(state.premium and state.premium.bonusChips or 0)
    local baseAvailable=math.max(0,level-baseClaimed)
    local available=baseAvailable*balance.premiumMultiplier(state,"chips",unixNow)
    return {available=available,baseAvailable=baseAvailable,baseLevel=level,level=state.prestigeClaimed,
        nextAt=level<balance.MAX_PRESTIGE_CHIPS and balance.PRESTIGE_BASE*(level+1)^3 or nil,
        perChip=effect.perChip,bonus=effect.prestigeBonus,
        afterBonus=1+(state.prestigeClaimed+available)*effect.perChip}
end
function Prestige.ascend(state,balance,stateModule,unixNow)
    local view=Prestige.view(state,balance,unixNow);local gain=view.available
    if gain<1 then return false,"Earn more lifetime money to gain a Chip." end
    local fresh=stateModule.new(balance)
    fresh.tutorialDone=state.tutorialDone
    fresh.analytics=stateModule.copyAnalytics(state.analytics)
    fresh.chips=state.chips+gain;fresh.prestigeClaimed=state.prestigeClaimed+gain
    fresh.prestigeCount=state.prestigeCount+1;fresh.lifetimeEarned=state.lifetimeEarned
    fresh.premium=stateModule.copy(state).premium
    fresh.premium.bonusChips=fresh.premium.bonusChips+gain-view.baseAvailable
    fresh.prestigeSkills={}
    for id,owned in pairs(state.prestigeSkills) do fresh.prestigeSkills[id]=owned end
    for id,owned in pairs(state.legacyPrestigeSkills or {}) do fresh.legacyPrestigeSkills[id]=owned end
    fresh.cardOwned={}
    for id,owned in pairs(state.cardOwned or {}) do fresh.cardOwned[id]=owned end
    for id,owned in pairs(state.cardCrafted or {}) do fresh.cardCrafted[id]=owned end
    for id,count in pairs(state.fragments or {}) do fresh.fragments[id]=count end
    if state.cardDeck and state.cardDeck[1] then fresh.cardDeck[1]=state.cardDeck[1] end
    -- Keep the leased profile object; reset only this game's normal run.
    for key in pairs(state) do state[key]=nil end
    for key,value in pairs(fresh) do state[key]=value end
    return true,gain
end
function Prestige.node(id,balance)
    for _,node in ipairs(balance.PRESTIGE_NODES) do if node.id==id then return node end end
end
function Prestige.quote(state,id,balance)
    local node=Prestige.node(id,balance)
    if not node then return nil,"Unknown skill." end
    if state.prestigeSkills[id] then return nil,"Already unlocked." end
    for _,parent in ipairs(node.parents) do
        if not state.prestigeSkills[parent] then return nil,"Unlock all connected parent skills first." end
    end
    return node.cost
end
function Prestige.buy(state,id,balance)
    local cost,reason=Prestige.quote(state,id,balance)
    if not cost then return false,reason end
    if state.chips<cost then return false,"Not enough Chips." end
    state.chips=state.chips-cost;state.prestigeSkills[id]=true
    return true,"Permanent skill unlocked."
end
return Prestige

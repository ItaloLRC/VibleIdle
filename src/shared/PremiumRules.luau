--!nonstrict
-- Authored offers and pure benefits. No client amounts, prices, clocks or RNG.
local Premium={MAX_TIME=4102444800,MAX_CREDITS=1000000,MAX_PENDING=256}
Premium.OFFERS={
    {id="forever",name="FOREVER DUO",price=100,kind="pass",icon="prestige",featured=true,
        description="2x Money + 2x Chips\nForever. One purchase."},
    {id="money_hour",name="2x MONEY",price=10,kind="product",icon="money",duration=3600,
        description="Double confirmed sale rewards.\n1 real-time hour."},
    {id="chips_hour",name="2x CHIPS",price=15,kind="product",icon="prestige",duration=3600,
        description="Double new Chips at prestige.\n1 real-time hour."},
    {id="agent",name="EXTRA AGENT",price=20,kind="product",icon="agent",
        description="One writer for this run.\nAgent resets at prestige."},
}
function Premium.new() return {moneyUntil=0,chipsUntil=0,forever=false,agentCredits=0,bonusChips=0,receipts={}} end
function Premium.copy(value)
    local result=Premium.new()
    for _,key in ipairs({"moneyUntil","chipsUntil","forever","agentCredits","bonusChips"}) do result[key]=value[key] end
    for id,sku in pairs(value.receipts or {}) do result.receipts[id]=sku end
    return result
end
local function integer(value,lo,hi) return type(value)=="number" and value==value and value%1==0 and value>=lo and value<=hi end
function Premium.offer(id) for _,offer in ipairs(Premium.OFFERS) do if offer.id==id then return offer end end end
function Premium.validReceiptId(id) return type(id)=="string" and #id>=1 and #id<=50 and id:match("^[%w_%-]+$")~=nil end
function Premium.redeem(state,balance)
    if state.premium.agentCredits<1 then return false,"No agent credits." end
    if #state.layerSizes-2>=balance.MAX_HIDDEN_LAYERS then return false,"All 8 agent slots are full. Credit is saved." end
    table.insert(state.layerSizes,#state.layerSizes,state.layerSizes[2])
    state.premium.agentCredits=state.premium.agentCredits-1
    return true,"Agent joined this run."
end
function Premium.grant(state,sku,unixNow,balance)
    local offer=Premium.offer(sku);if not offer or offer.kind~="product" then return false end
    if sku=="agent" then
        if state.premium.agentCredits>=Premium.MAX_CREDITS then return false end
        state.premium.agentCredits=state.premium.agentCredits+1;Premium.redeem(state,balance)
    else
        local key=sku=="money_hour" and "moneyUntil" or "chipsUntil"
        local nextTime=math.max(unixNow,state.premium[key])+offer.duration
        if not integer(nextTime,0,Premium.MAX_TIME) then return false end
        state.premium[key]=nextTime
    end
    return true
end
return Premium

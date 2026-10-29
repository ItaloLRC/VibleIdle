--!nonstrict
-- Deterministic one-time recipes. No client prices/rewards or random purchases.
local Craft={}
function Craft.definition(id,balance)
    for _,card in ipairs(balance.AGENT_CARDS) do if card.id==id then return card end end
end
function Craft.quote(state,id,balance)
    local card=Craft.definition(id,balance)
    if not card then return nil,"Unknown card." end
    if state.cardOwned[id] then return nil,"Card already owned." end
    local tier=balance.CRAFT_TIERS[card.rank]
    return {cardId=id,familyId=card.familyId,fragments=tier.fragments,money=tier.money,chips=tier.chips}
end
function Craft.affordable(state,quote)
    return quote and (state.fragments[quote.familyId] or 0)>=quote.fragments
        and state.credits>=quote.money and state.chips>=quote.chips
end
function Craft.purchase(state,id,balance)
    local quote,reason=Craft.quote(state,id,balance)
    if not quote then return false,reason end
    if not Craft.affordable(state,quote) then return false,"Need more fragments, money or Chips." end
    -- Prepare/validate first, then debit/grant atomically without yielding.
    state.fragments[quote.familyId]=state.fragments[quote.familyId]-quote.fragments
    state.credits=state.credits-quote.money;state.chips=state.chips-quote.chips
    state.cardOwned[id]=true;state.cardCrafted[id]=true
    return true,"Card crafted. Equip it in Cards."
end
return Craft

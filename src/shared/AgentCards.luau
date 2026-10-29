--!nonstrict
-- One permanent copy of each starter card; agent count unlocks deck positions.
local Cards={}
local neutral={value=1,speed=1}
function Cards.definition(id,balance)
    for _,card in ipairs(balance.AGENT_CARDS) do if card.id==id then return card end end
end
function Cards.effect(state,index,balance)
    if not Cards.validSlot(state,index,balance) then return neutral end
    return Cards.definition(state.cardDeck and state.cardDeck[index],balance) or neutral
end
function Cards.location(state,id,balance)
    for index=1,balance.MAX_HIDDEN_LAYERS do if state.cardDeck[index]==id then return index end end
end
function Cards.validSlot(state,index,balance)
    return type(index)=="number" and index==index and index%1==0 and index>=1
        and index<=balance.MAX_HIDDEN_LAYERS and index<=#state.layerSizes-2
end
function Cards.equip(state,index,id,balance)
    if not Cards.validSlot(state,index,balance) then return false,"Slot is locked." end
    if not Cards.definition(id,balance) or not state.cardOwned[id] then return false,"Card not owned." end
    if state.cardDeck[index] then return false,"Position occupied." end
    if Cards.location(state,id,balance) then return false,"Card already equipped." end
    state.cardDeck[index]=id
    return true,"Card equipped."
end
function Cards.unequip(state,index,balance)
    if not Cards.validSlot(state,index,balance) then return false,"Slot is locked." end
    if not state.cardDeck[index] then return false,"Empty position." end
    state.cardDeck[index]=false
    return true,"Card returned."
end
function Cards.key(deck,balance)
    local values={}
    for index=1,balance.MAX_HIDDEN_LAYERS do values[index]=deck and deck[index] or "" end
    return table.concat(values,"|")
end
function Cards.buffText(card)
    return string.format("$ %+g%%\nSPD %+g%%",(card.value-1)*100,(card.speed-1)*100)
end
return Cards

--!nonstrict
local Protocol = {}
-- Only three upgrades are available in live play. Historical profile fields and
-- pure economy fixtures retain their old meaning, but retired commands reject.
local actions = { avatar_poll=true,craft_card=true,auto_skill=true,upgrade_sync=true,equip_card=true,unequip_card=true,prestige=true,buy_skill=true,prestige_sync=true,submit_prompt = true, add_layer = true, upgrade_compute = true,
    upgrade_tokens = true, collect_avatar = true, avatar_sync = true, sync = true, agent_type = true, agent_sync = true, skill_click = true, skill_sync = true }

function Protocol.validate(action, layerIndex, balance)
    if action=="analytics_pulse" then
        if type(layerIndex)~="table" or type(layerIndex.focused)~="boolean" then return false,"invalid_analytics" end
        local pages={CLI=true,Guide=true,Lab=true,Cards=true,Robux=true,Prestige=true,Tree=true,Tools=true,Start=true,Tutorial=true}
        if not pages[layerIndex.page] then return false,"invalid_analytics" end
        for _,key in ipairs({"requestId","button","enter"}) do
            local n=layerIndex[key]
            if type(n)~="number" or n~=n or n%1~=0 or n<(key=="requestId" and 1 or 0) or n>1000000000 then return false,"invalid_analytics" end
        end
        for key in pairs(layerIndex) do if key~="requestId" and key~="button" and key~="enter" and key~="focused" and key~="page" then return false,"invalid_analytics" end end
        return true
    end
    if action=="premium_buy" then
        if type(layerIndex)~="table" or (layerIndex.sku~="money_hour" and layerIndex.sku~="chips_hour" and layerIndex.sku~="agent" and layerIndex.sku~="forever")
            or type(layerIndex.requestId)~="number" or layerIndex.requestId~=layerIndex.requestId or layerIndex.requestId%1~=0
            or layerIndex.requestId<1 or layerIndex.requestId>balance.MAX_CREDITS then return false,"invalid_premium" end
        for key in pairs(layerIndex) do if key~="sku" and key~="requestId" then return false,"invalid_premium" end end
        return true
    elseif action=="premium_check" or action=="premium_redeem" or action=="tutorial_complete" then
        if type(layerIndex)~="table" or type(layerIndex.requestId)~="number" or layerIndex.requestId~=layerIndex.requestId
            or layerIndex.requestId%1~=0 or layerIndex.requestId<1 or layerIndex.requestId>balance.MAX_CREDITS then return false,"invalid_premium" end
        for key in pairs(layerIndex) do if key~="requestId" then return false,"invalid_premium" end end
        return true
    end
    if type(action) ~= "string" or #action > 32 or not actions[action] then return false, "unknown_action" end
    if action=="upgrade_sync" or ((action=="upgrade_compute" or action=="upgrade_tokens" or action=="add_layer") and layerIndex~=nil) then
        if type(layerIndex)~="table" then return false,"invalid_purchase" end
        local fields=0
        for key,value in pairs(layerIndex) do
            if key=="requestId" then
                if type(value)~="number" or value~=value or value%1~=0 or value<1 or value>balance.MAX_CREDITS then return false,"invalid_purchase" end
            elseif key=="quantity" and action~="upgrade_sync" then
                if value~=1 and value~=5 and value~=10 and value~=25 and value~="max" then return false,"invalid_purchase" end
            else return false,"invalid_purchase" end
            fields=fields+1
        end
        if not layerIndex.requestId or fields~=(action=="upgrade_sync" and 1 or 2) then return false,"invalid_purchase" end
    elseif action=="avatar_poll" then
        if type(layerIndex)~="table" or type(layerIndex.requestId)~="number" or layerIndex.requestId~=layerIndex.requestId
            or layerIndex.requestId%1~=0 or layerIndex.requestId<1 or layerIndex.requestId>balance.MAX_CREDITS then return false,"invalid_avatar" end
        for key in pairs(layerIndex) do if key~="requestId" then return false,"invalid_avatar" end end
    elseif action=="craft_card" then
        if type(layerIndex)~="table" or type(layerIndex.cardId)~="string" or #layerIndex.cardId<1 or #layerIndex.cardId>32
            or not layerIndex.cardId:match("^[a-z_]+$") or type(layerIndex.requestId)~="number"
            or layerIndex.requestId~=layerIndex.requestId or layerIndex.requestId%1~=0 or layerIndex.requestId<1
            or layerIndex.requestId>balance.MAX_CREDITS then return false,"invalid_card" end
        for key in pairs(layerIndex) do if key~="cardId" and key~="requestId" then return false,"invalid_card" end end
    elseif action=="equip_card" or action=="unequip_card" then
        if type(layerIndex)~="table" then return false,"invalid_card" end
        local fields=0
        for key,value in pairs(layerIndex) do
            if key=="requestId" or key=="slotIndex" then
                if type(value)~="number" or value~=value or value%1~=0 or value<1
                    or value>(key=="slotIndex" and balance.MAX_HIDDEN_LAYERS or balance.MAX_CREDITS) then return false,"invalid_card" end
            elseif key=="cardId" and action=="equip_card" then
                if type(value)~="string" or #value<1 or #value>32 or not value:match("^[a-z_]+$") then return false,"invalid_card" end
            else return false,"invalid_card" end
            fields=fields+1
        end
        if not layerIndex.requestId or not layerIndex.slotIndex or (action=="equip_card" and not layerIndex.cardId)
            or fields~=(action=="equip_card" and 3 or 2) then return false,"invalid_card" end
    elseif action=="prestige" or action=="buy_skill" or action=="prestige_sync" then
        if type(layerIndex)~="table" then return false,"invalid_prestige" end
        local fields=0
        for key,value in pairs(layerIndex) do
            if key=="requestId" or (key=="draftId" and action=="prestige") then
                if type(value)~="number" or value~=value or value%1~=0 or value<1 or value>balance.MAX_CREDITS then return false,"invalid_prestige" end
            elseif key=="nodeId" and action=="buy_skill" then
                if type(value)~="string" or #value<1 or #value>32 or not value:match("^[a-z][a-z_0-9]*$") then return false,"invalid_prestige" end
            else return false,"invalid_prestige" end
            fields=fields+1
        end
        if fields~=(action=="prestige_sync" and 1 or 2) or not layerIndex.requestId
            or (action=="prestige" and not layerIndex.draftId) or (action=="buy_skill" and not layerIndex.nodeId) then return false,"invalid_prestige" end
    elseif action=="collect_avatar" or action=="avatar_sync" then
        if type(layerIndex)~="table" then return false,"invalid_avatar" end
        local fields=0
        for key,value in pairs(layerIndex) do
            if key~="id" or type(value)~="number" or value~=value or value%1~=0 or value<1 or value>balance.MAX_CREDITS then return false,"invalid_avatar" end
            fields=fields+1
        end
        if fields~=1 then return false,"invalid_avatar" end
    elseif action == "auto_skill" or action == "skill_click" or action=="skill_sync" or action=="agent_type" or action=="agent_sync" then
        local idKey=(action=="agent_type" or action=="agent_sync") and "requestId" or "checkId"
        if type(layerIndex)~="table" then return false,"invalid_skill" end
        local fields=0
        for key,value in pairs(layerIndex) do
            if key~="draftId" and key~=idKey and key~="tokenIndex" then return false,"invalid_skill" end
            local skillAction=action=="auto_skill" or action=="skill_click" or action=="skill_sync"
            local maximum=key=="tokenIndex" and (balance.PROMPT_MAX_TOKENS+(skillAction and 1 or 0)) or balance.MAX_CREDITS
            if type(value)~="number" or value~=value or value%1~=0 or value<1 or value>maximum then return false,"invalid_skill" end
            fields=fields+1
        end
        if fields~=3 then return false,"invalid_skill" end
    elseif action == "submit_prompt" then
        if type(layerIndex) ~= "table" then return false, "invalid_prompt" end
        local count = 0
        for key in pairs(layerIndex) do
            if key ~= "draftId" and key ~= "tokens" then return false, "invalid_prompt" end
            count = count + 1
        end
        for key, maximum in pairs({ draftId = balance.MAX_CREDITS, tokens = balance.PROMPT_MAX_TOKENS }) do
            local value = layerIndex[key]
            if type(value) ~= "number" or value ~= value or value % 1 ~= 0 or value < 1 or value > maximum then return false, "invalid_prompt" end
        end
        if count ~= 2 then return false, "invalid_prompt" end
    elseif layerIndex ~= nil then
        return false, "unexpected_payload"
    end
    return true
end

return Protocol

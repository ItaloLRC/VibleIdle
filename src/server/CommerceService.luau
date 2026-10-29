--!nonstrict
-- Dependency injected billing. Only Roblox receipts/ownership grant benefits.
local Commerce={};Commerce.__index=Commerce
local function id(value) return type(value)=="number" and value==value and value%1==0 and value>0 and value<9007199254740992 end
function Commerce.new(deps)
    return setmetatable(deps,Commerce)
end
function Commerce:event(record,phase,sku)
    if self.onEvent then pcall(self.onEvent,record,phase,sku) end
end
function Commerce:ready()
    return self.config.COMMERCE_ENABLED==true and self.config.STORAGE_MODE=="DATASTORE" and self.archive~=nil
        and self.published==true and not self.studio
end
function Commerce:asset(sku)
    local value=(self.config.COMMERCE_IDS or {})[sku]
    if not id(value) then return 0 end
    for other,otherId in pairs(self.config.COMMERCE_IDS) do if other~=sku and otherId==value then return 0 end end
    return value
end
function Commerce:sku(productId)
    for _,offer in ipairs(self.premium.OFFERS) do
        if offer.kind=="product" and self:asset(offer.id)==productId then return offer.id end
    end
end
function Commerce:archiveReceipt(receiptId,userId,productId,write)
    local mismatch=false
    local ok,value=pcall(function()
        return self.archive:UpdateAsync(receiptId,function(old)
            if old~=nil and (type(old)~="table" or old.userId~=userId or old.productId~=productId) then mismatch=true;return nil end
            return old or (write and {userId=userId,productId=productId} or nil)
        end)
    end)
    if not ok or mismatch then return false,false end
    return true,type(value)=="table" and value.userId==userId and value.productId==productId
end
function Commerce:view(record)
    local offers={}
    local pendingCount=0;for _ in pairs(record.state.premium.receipts) do pendingCount=pendingCount+1 end
    for _,offer in ipairs(self.premium.OFFERS) do
        offers[offer.id]={assetId=self:asset(offer.id),ready=self:ready() and self:asset(offer.id)>0 and pendingCount==0}
    end
    return {offers=offers,sequence=record.premiumSequence or 0,checkedId=record.premiumCheckId,busy=record.receiptBusy==true,
        pending=record.premiumPrompt and record.premiumPrompt.sku or nil,message=record.premiumMessage,
        serverTime=self.unix(),agentCredits=record.state.premium.agentCredits,pendingReceipts=pendingCount}
end
function Commerce:receipt(info)
    local granted,deferred=self.decisions.PurchaseGranted,self.decisions.NotProcessedYet
    if type(info)~="table" or not id(info.PlayerId) or not id(info.ProductId) or not self.premium.validReceiptId(info.PurchaseId) then return deferred end
    local sku=self:sku(info.ProductId)
    if not sku or not self:ready() then return deferred end
    local player=self.players:GetPlayerByUserId(info.PlayerId);local record=player and self.getRecord(player)
    if not record or record.closing or record.blocked or record.receiptBusy or record.saving or not record.handle then return deferred end
    record.receiptBusy=true
    local freshReceipt=false
    local ok,result=pcall(function()
        local readable,archived=self:archiveReceipt(info.PurchaseId,info.PlayerId,info.ProductId,false)
        if not readable then return deferred end
        if archived then
            if record.state.premium.receipts[info.PurchaseId] and record.state.premium.receipts[info.PurchaseId]~=sku then return deferred end
            record.state.premium.receipts[info.PurchaseId]=nil
            return granted
        end
        freshReceipt=true
        local proofs=record.state.premium.receipts
        if proofs[info.PurchaseId] and proofs[info.PurchaseId]~=sku then return deferred end
        if not proofs[info.PurchaseId] then
            local count=0;for _ in pairs(proofs) do count=count+1 end
            if count>=self.premium.MAX_PENDING then return deferred end
            if not self.premium.grant(record.state,sku,self.unix(),self.balance) then return deferred end
            self:event(record,"delivered",sku)
            proofs[info.PurchaseId]=sku
        end
        -- The benefit and its unarchived proof share the leased profile save.
        -- If storage fails, retain both in memory; a retry never grants twice.
        if not self.save(record,false) then return deferred end
        local archivedOk,done=self:archiveReceipt(info.PurchaseId,info.PlayerId,info.ProductId,true)
        if not archivedOk or not done then return deferred end
        proofs[info.PurchaseId]=nil -- Durable archive now owns permanent dedup.
        return granted
    end)
    record.receiptBusy=false
    if ok and result==granted then
        if freshReceipt then record.premiumPrompt=nil;record.premiumMessage="Purchase confirmed. Thank you!" end
    else record.premiumMessage="Purchase is processing. Rejoin to finish confirmation." end
    self.publish(player,record)
    return ok and result or deferred
end
function Commerce:reconcile(player,record)
    if not self:ready() or record.receiptBusy or record.saving or record.closing or record.blocked or not next(record.state.premium.receipts) then return end
    record.receiptBusy=true
    local ok=pcall(function()
        -- Existing proof already includes its benefit. Never grant from CHECK.
        if not self.save(record,false) then return end
        local count=0
        for receiptId,sku in pairs(record.state.premium.receipts) do
            local productId=self:asset(sku)
            if productId>0 then
                local archived,done=self:archiveReceipt(receiptId,player.UserId,productId,true)
                if archived and done then record.state.premium.receipts[receiptId]=nil end
            end
            count=count+1;if count>=4 then break end
        end
    end)
    record.receiptBusy=false
    record.premiumMessage=ok and not next(record.state.premium.receipts) and "Purchase records checked. No purchase was repeated." or "Purchase is still processing. Use CHECK or rejoin."
    self.publish(player,record)
end
function Commerce:checkPass(player,record)
    local pass=self:asset("forever")
    if not self:ready() or pass==0 or record.passChecking then return end
    record.passChecking=true
    local ok,owned=pcall(function() return self.market:UserOwnsGamePassAsync(player.UserId,pass) end)
    record.passChecking=false
    if self.getRecord(player)~=record or record.closing then return end
    if ok then
        local previous=record.state.premium.forever
        record.state.premium.forever=owned==true
        if owned and not previous then self:event(record,"pass_owned","forever") end
        if owned then record.premiumPrompt=nil;record.premiumMessage="Forever Duo owned. Both bonuses are active." end
    else record.premiumMessage="Could not check pass ownership. Use CHECK PURCHASE." end
    self.publish(player,record)
end
function Commerce:buy(player,record,sku,requestId)
    if requestId<=(record.premiumSequence or 0) then return end
    record.premiumSequence=requestId
    local offer=self.premium.offer(sku)
    local can=self:ready() and self:asset(sku)>0 and not record.premiumPrompt and not record.receiptBusy and not record.saving
    if next(record.state.premium.receipts) then can=false end
    if record.state.premium.forever and sku~="agent" then can=false end
    if sku=="agent" and #record.state.layerSizes-2>=self.balance.MAX_HIDDEN_LAYERS then can=false end
    if not offer or not can then
        if offer then self:event(record,"unavailable",sku) end
        record.premiumMessage="This purchase is unavailable right now.";self.publish(player,record);return
    end
    record.premiumPrompt={sku=sku,assetId=self:asset(sku)};record.premiumMessage="Complete the Roblox purchase prompt."
    self.publish(player,record)
    local ok=pcall(function()
        if offer.kind=="pass" then self.market:PromptGamePassPurchase(player,self:asset(sku))
        else self.market:PromptProductPurchase(player,self:asset(sku)) end
    end)
    if ok then self:event(record,"prompt",sku) end
    if not ok then self:event(record,"unavailable",sku);record.premiumPrompt=nil;record.premiumMessage="Roblox could not open the purchase prompt.";self.publish(player,record) end
end
function Commerce:bind()
    self.market.ProcessReceipt=function(info) return self:receipt(info) end
    self.market.PromptProductPurchaseFinished:Connect(function(userId,productId,purchased)
        local player=self.players:GetPlayerByUserId(userId);local record=player and self.getRecord(player)
        if not record or not record.premiumPrompt or record.premiumPrompt.assetId~=productId then return end
        if not purchased then self:event(record,"canceled",record.premiumPrompt.sku);record.premiumPrompt=nil;record.premiumMessage="Purchase canceled."
        else record.premiumMessage="Waiting for Roblox receipt confirmation." end
        self.publish(player,record) -- Prompt closure never grants consumables.
    end)
    self.market.PromptGamePassPurchaseFinished:Connect(function(player,passId,_purchased)
        local record=self.getRecord(player)
        if not record or passId~=self:asset("forever") then return end
        if not _purchased and record.premiumPrompt and record.premiumPrompt.sku=="forever" then self:event(record,"canceled","forever") end
        record.premiumPrompt=nil;record.premiumMessage=_purchased and "Checking pass ownership..." or "Purchase canceled."
        self:checkPass(player,record)
    end)
end
return Commerce

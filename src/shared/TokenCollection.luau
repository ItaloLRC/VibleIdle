--!nonstrict
-- Receipt-driven presentation only. No profile writes or payment requests.
local Collection={MAX_BATCHES=4,MAX_TOKENS=128,MAX_EVENTS=16}
local function finite(value) return type(value)=="number" and value==value and value~=math.huge and value~=-math.huge end
function Collection.new() return {lastReceipt=0,batches={},revision=0,collected=0,amount=0} end
function Collection.capture(draft,count)
    if not draft or count<1 then return nil end
    local visual={draftId=draft.id,offers={}}
    for index=1,count do
        local copy={};for key,value in pairs(draft.offers[index]) do copy[key]=value end
        visual.offers[index]=copy
    end
    return visual
end
function Collection.accept(state,receipt,visual,baseline,balance)
    if type(receipt)~="table" or not finite(receipt.id) or receipt.id%1~=0 or receipt.id<1
        or receipt.id>balance.MAX_CREDITS or receipt.id<=state.lastReceipt then return false end
    local count,rewards=receipt.tokens,receipt.tokenRewards
    if not finite(count) or count%1~=0 or count<1 or count>Collection.MAX_TOKENS
        or type(rewards)~="table" or #rewards~=count or not finite(receipt.reward)
        or receipt.reward<0 or receipt.reward>balance.MAX_CREDITS then return false end
    local total=0
    for index=1,count do
        local amount=rewards[index]
        if not finite(amount) or amount<0 or amount>balance.MAX_CREDITS then return false end
        total=total+amount
    end
    if math.abs(total-receipt.reward)>0.0001 then return false end
    state.lastReceipt=receipt.id
    if baseline or not visual or visual.draftId~=(receipt.draftId or receipt.id) or #visual.offers~=count then return false end
    -- Fast repeated sales stay bounded; finishing an old visual never pays again.
    if #state.batches==Collection.MAX_BATCHES then table.remove(state.batches,1) end
    local batch={id=receipt.id,count=count,offers=visual.offers,rewards={},cursor=0,
        interval=math.max(0.008,math.min(0.045,0.6/count)),elapsed=0,total=receipt.reward}
    for index=1,count do batch.rewards[index]=rewards[index] end
    if #state.batches==0 then batch.elapsed=batch.interval end
    state.batches[#state.batches+1]=batch;state.revision=state.revision+1
    return true
end
function Collection.tick(state,dt,active)
    local events={}
    if not active or not finite(dt) or dt<0 then return events end
    local batch=state.batches[1]
    if not batch then return events end
    batch.elapsed=batch.elapsed+math.min(dt,0.1)
    while batch.cursor<batch.count and batch.elapsed+0.000001>=batch.interval and #events<Collection.MAX_EVENTS do
        batch.elapsed=math.max(0,batch.elapsed-batch.interval);batch.cursor=batch.cursor+1
        local amount=batch.rewards[batch.cursor]
        local offer=batch.offers[batch.cursor]
        events[#events+1]={receiptId=batch.id,tokenIndex=batch.cursor,amount=amount,rank=offer.rank}
        state.collected=state.collected+1;state.amount=state.amount+amount
    end
    if #events>0 then state.revision=state.revision+1 end
    if batch.cursor==batch.count then table.remove(state.batches,1) end
    return events
end
function Collection.reset(state)
    state.batches={};state.revision=state.revision+1;state.collected=0;state.amount=0
end
return Collection

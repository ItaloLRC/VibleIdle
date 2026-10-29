--!nonstrict
-- Presentation only: bounded solid text rises and fades; never changes a balance.
local Cash = { MAX_LABELS = 24, DURATION = 1.8 }
function Cash.new() return { lastReceipt = 0, items = {} } end
function Cash.accept(state, receipt, baseline, balance)
    if type(receipt) ~= "table" or type(receipt.id) ~= "number" or receipt.id ~= receipt.id
        or receipt.id % 1 ~= 0 or receipt.id > balance.MAX_CREDITS or receipt.id <= state.lastReceipt then return false end
    if type(receipt.reward) ~= "number" or receipt.reward ~= receipt.reward or receipt.reward < 0 or receipt.reward > balance.MAX_CREDITS then return false end
    state.lastReceipt = receipt.id
    if baseline or receipt.reward == 0 then return false end
    if #state.items == Cash.MAX_LABELS then table.remove(state.items, 1) end
    state.items[#state.items + 1] = { id = receipt.id, amount = receipt.reward, age = 0 }
    return true
end
function Cash.token(state,event,x,y)
    if #state.items==Cash.MAX_LABELS then table.remove(state.items,1) end
    state.items[#state.items+1]={id=event.receiptId,tokenIndex=event.tokenIndex,amount=event.amount,
        x=x,y=y,age=0,duration=0.5}
end
function Cash.tick(state, dt, duration, pauseTokens)
    if type(dt) ~= "number" or dt ~= dt or dt < 0 or dt == math.huge then return end
    for index = #state.items, 1, -1 do
        local item = state.items[index]
        if not (pauseTokens and item.tokenIndex) then item.age = item.age + dt end
        if item.age >= (item.duration or duration or Cash.DURATION) then table.remove(state.items, index) end
    end
end
function Cash.pose(item, reduced, duration)
    local t = math.min(1, item.age / (item.duration or duration or Cash.DURATION))
    return reduced and 0 or -(item.tokenIndex and 40 or 76) * (1 - (1 - t) ^ 2), reduced and 0 or math.max(0, (t - 0.55) / 0.45)
end
function Cash.reset(state) state.items = {} end -- Receipt watermark intentionally retained.
return Cash

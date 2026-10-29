--!nonstrict
-- Bounded manual composition. No timers that submit, reroll, retry or grant money.
local Composer = {}
Composer.TOKEN_STYLE={wordSize=18,badgeSize=15,height=33,rowHeight=35,gap=9,padding=9,badgeGap=9}
local function integer(value, maximum)
    return type(value) == "number" and value == value and value % 1 == 0 and value >= 1 and value <= maximum
end
function Composer.new() return { count = 0, lastReceipt = 0 } end

-- Fixed monospace token objects wrap at native scale without a grid of buttons.
function Composer.tokenLayout(offers, count, width, measure)
    local style=Composer.TOKEN_STYLE
    width = math.max(24, width)
    local positions, x, y = {}, 0, 0
    for index = 1, count do
        local offer = offers[index]
        local multiplier=offer.multiplier*(offer.skillMultiplier or 1)
        local hasBadge=multiplier>1
        local text = offer.word .. (hasBadge and (" x" .. string.format("%g",multiplier)) or "")
        local wordWidth = measure and measure(offer.word,style.wordSize) or #offer.word * style.wordSize
        local badgeText = hasBadge and ("x" .. string.format("%g",multiplier)) or ""
        local badgeWidth = measure and measure(badgeText,style.badgeSize) or #badgeText * style.badgeSize
        local size = math.min(width, wordWidth + style.padding*2 + (hasBadge and badgeWidth + style.badgeGap or 0))
        if x > 0 and x + size > width then x, y = 0, y + style.rowHeight end
        positions[index] = { x = x, y = y, width = size, text = text, badgeWidth = badgeWidth }
        x = x + size + style.gap
    end
    if x + style.gap > width then x, y = 0, y + style.rowHeight end
    return positions, x, y, y + style.rowHeight
end

-- Keep the current window width. More token rows grow only the composer/window
-- height at native font size; the desktop scrolls when that height exceeds it.
function Composer.windowLayout(offers,count,width,height,maxWidth,_maxHeight,short,measure,rosterHeight)
    width=math.max(1,math.min(width,maxWidth))
    local minimumPanel=short and 108 or 150
    local _,_,_,tokenHeight=Composer.tokenLayout(offers,count,math.max(24,width-60),measure)
    local panelHeight=math.max(minimumPanel,tokenHeight+66)
    local windowHeight=math.max(height,panelHeight+82+(rosterHeight or 0))
    return {width=width,height=windowHeight,panelHeight=panelHeight,tokenHeight=tokenHeight}
end

function Composer.revealCount(length, elapsed, speed, reduced)
    if reduced or length==0 then return length, true end
    local duration=math.min(0.12,length/100,0.85/math.max(1,speed))
    local visible=math.min(length,math.floor(math.max(0,elapsed)/duration*length+0.000001))
    return visible,visible==length
end

function Composer.update(state, draft, balance, prompt)
    if type(draft) == "table" and type(draft.ranks) == "table" then
        if not balance or not prompt or not integer(draft.startToken, prompt.VOCABULARY_SIZE)
            or #draft.ranks < 1 or #draft.ranks > balance.PROMPT_MAX_TOKENS then return false end
        local expanded = { id = draft.id, startToken = draft.startToken, offers = {} }
        for key, rank in pairs(draft.ranks) do
            if not integer(key, #draft.ranks) or not integer(rank, #balance.SPECIAL_TOKENS) then return false end
        end
        for index = 1, #draft.ranks do
            local rank = draft.ranks[index]
            if not integer(rank, #balance.SPECIAL_TOKENS) then return false end
            local tier = balance.SPECIAL_TOKENS[rank]
            expanded.offers[index] = { word = prompt.nextWord((draft.startToken + index - 2) % prompt.VOCABULARY_SIZE),
                rarity = tier.rarity, rank = rank, multiplier = tier.multiplier, denominator = tier.denominator }
        end
        draft = expanded
    end
    if type(draft) ~= "table" or not integer(draft.id, 1000000000000) or type(draft.offers) ~= "table"
        or #draft.offers < 1 or #draft.offers > 128 then return false end
    for key, offer in pairs(draft.offers) do
        if not integer(key, #draft.offers) or type(offer) ~= "table" or type(offer.word) ~= "string"
            or #offer.word > 32 or not string.match(offer.word, "^[a-z]+$")
            or not integer(offer.rank, 5) or not integer(offer.multiplier, 250) then return false end
    end
    if state.draft and draft.id < state.draft.id then return false end
    local changed = not state.draft or state.draft.id ~= draft.id
    if changed then state.count, state.flight = 0, nil end
    state.draft = draft
    state.count = math.min(state.count, #draft.offers)
    return changed
end

function Composer.push(state, limit)
    if state.flight or not state.draft or state.count >= math.min(limit, #state.draft.offers) then return false end
    state.count = state.count + 1
    return true
end

function Composer.pop(state)
    if state.flight or state.count == 0 then return false end
    state.count = state.count - 1;return true
end

function Composer.clear(state)
    if state.flight then return false end
    state.count = 0;return true
end

function Composer.send(state, now, limit, balance)
    if state.flight or not state.draft or not integer(state.count, math.min(limit, #state.draft.offers)) then return nil end
    local request = { draftId = state.draft.id, tokens = state.count }
    state.flight = { draftId = request.draftId, tokens = request.tokens, sentAt = now }
    return request
end

function Composer.confirm(state, receipt, baseline, now, balance)
    if type(receipt) ~= "table" or not integer(receipt.id, balance.MAX_CREDITS) or receipt.id <= state.lastReceipt then return false end
    state.lastReceipt = receipt.id
    if baseline then return false end
    if state.flight and (receipt.draftId or receipt.id) == state.flight.draftId then
        state.flight, state.count = nil, 0
    end
    return true
end

function Composer.timeout(state, now, balance)
    if state.flight and now - state.flight.sentAt >= (state.responseTimeout or balance.LIVE_RECEIPT_TIMEOUT) then
        state.flight = nil
        return true -- Request sync, never resend a possibly paid prompt automatically.
    end
    return false
end

return Composer

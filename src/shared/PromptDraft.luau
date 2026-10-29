--!nonstrict
-- Client-only presentation state, kept pure for receipt/draft regression tests.
local Draft = {}

function Draft.new()
    return { tokens = 0, revision = 0, lastReceipt = 0 }
end

function Draft.setCount(draft, tokens, limit)
    local nextCount = math.max(0, math.min(limit, tokens))
    if nextCount ~= draft.tokens then
        draft.tokens, draft.revision = nextCount, draft.revision + 1
    end
end

function Draft.submitted(draft)
    draft.submittedRevision = draft.revision
end

function Draft.confirm(draft, receipt, baseline)
    if type(receipt) ~= "table" or type(receipt.id) ~= "number" or receipt.id ~= receipt.id
        or receipt.id % 1 ~= 0 or receipt.id <= draft.lastReceipt then return false end
    draft.lastReceipt = receipt.id
    if baseline then return false end -- First sync must not celebrate an older UI's prompt.
    if draft.submittedRevision == draft.revision then
        draft.tokens, draft.revision = 0, draft.revision + 1
    end
    draft.submittedRevision = nil
    return true
end

-- Bounded live-input transport state. No raw keystrokes, services or credit authority.
function Draft.liveNew()
    return { cursor = 0, queued = 0, offset = 0, lastReceipt = 0, nextSend = 0 }
end

function Draft.livePush(state, vocabularySize, maximum)
    if state.queued >= maximum then return nil end
    local wordIndex = state.cursor
    if state.queued == 0 then state.offset = state.cursor end
    state.cursor = (state.cursor + 1) % vocabularySize
    state.queued = state.queued + 1
    return wordIndex
end

function Draft.liveNext(state, now, limit, balance, vocabularySize)
    if state.flight and now - state.flight.sentAt >= balance.LIVE_RECEIPT_TIMEOUT then
        state.flight = nil -- Never retry an unconfirmed request: it may already have earned credits.
        return nil, "timeout"
    end
    if state.flight or state.queued == 0 or now < state.nextSend then return nil end
    local count = math.min(limit, state.queued)
    local flight = { tokens = count, startToken = state.offset + 1, sentAt = now, baseline = state.lastReceipt }
    state.queued, state.offset = state.queued - count, (state.offset + count) % vocabularySize
    state.flight, state.nextSend = flight, now + math.max(balance.LIVE_SEND_INTERVAL, balance.MANUAL_MIN_INTERVAL)
    return flight
end

function Draft.liveConfirm(state, receipt, baseline, now, balance)
    if type(receipt) ~= "table" or type(receipt.id) ~= "number" or receipt.id ~= receipt.id
        or receipt.id % 1 ~= 0 or receipt.id <= state.lastReceipt then return false end
    state.lastReceipt = receipt.id
    if baseline then return false end
    -- A delayed acknowledgement must not cause the next request to arrive inside server cooldown.
    if now and balance then state.nextSend = math.max(state.nextSend, now + balance.LIVE_SEND_INTERVAL) end
    local flight = state.flight
    if flight and receipt.id > flight.baseline and receipt.tokens == flight.tokens
        and (receipt.startToken or 1) == flight.startToken then state.flight = nil end
    return true
end

function Draft.liveReset(state)
    state.cursor, state.queued, state.offset, state.nextSend, state.flight = 0, 0, 0, 0, nil
end

return Draft

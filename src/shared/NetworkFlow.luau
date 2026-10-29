--!nonstrict
-- Client presentation only. No income, model weights, services or saved state.
local Flow = {}
Flow.MAX_PACKETS = 6
Flow.AUTO_PACKETS = 3
Flow.TOTAL_PACKETS = Flow.MAX_PACKETS + Flow.AUTO_PACKETS
Flow.PREVIEW_TOKENS = 3
Flow.DURATION = 3.4
Flow.STAGGER = 0.18
Flow.AUTO_PERIOD = 3.6

local function finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

function Flow.token(word, prompt, dimensions)
    local id = prompt.tokenId(word)
    if not id then return nil end
    local vector = {}
    for dim = 1, dimensions do vector[dim] = ((id * (dim * 23 + 5) + dim * dim * 7) % 21 - 10) / 10 end
    return { word = word, id = id, vector = vector }
end

function Flow.preview(count, prompt, balance, offset)
    offset = offset or 0
    if not finite(count) or count % 1 ~= 0 or count < 0 or count > balance.PROMPT_MAX_TOKENS
        or not finite(offset) or offset % 1 ~= 0 or offset < 0 or offset >= prompt.VOCABULARY_SIZE then return nil end
    local tokens = {}
    for index = 1, math.min(count, Flow.MAX_PACKETS) do tokens[index] = Flow.token(prompt.nextWord(offset + index - 1), prompt, balance.EMBEDDING_DIM) end
    return { count = count, tokens = tokens, text = prompt.text(math.min(count, 6), balance, offset)
        .. (count > 6 and " ..." or "") }
end

function Flow.new()
    return { lastReceipt = 0, active = false, elapsed = 0, clock = 0, autoTime = 0, tokens = 0, time = 0, packets = {} }
end

local function fill(state, now)
    local pending = state.pending
    if not pending then return end
    for index = 1, Flow.MAX_PACKETS do
        if not state.packets[index] then
            local start = math.max(now, pending.nextStart)
            local lastSample = pending.next == math.min(pending.tokens, Flow.MAX_PACKETS)
            local ordinal = lastSample and pending.receipt.featuredIndex
                and pending.receipt.featuredIndex > Flow.MAX_PACKETS and pending.receipt.featuredIndex or pending.next
            state.packets[index] = { receiptId = pending.id, ordinal = ordinal, offset = pending.offset, start = start,
                lastSample = lastSample, output = pending.receipt.outputs and pending.receipt.outputs[ordinal] or nil,
                receipt = pending.receipt }
            pending.next, pending.nextStart = pending.next + 1, start + Flow.STAGGER
            if pending.next > math.min(pending.tokens, Flow.MAX_PACKETS) then state.pending = nil;return end
        end
    end
end

function Flow.accept(state, receipt, baseline, vocabularySize)
    if type(receipt) ~= "table" or not finite(receipt.id) or receipt.id % 1 ~= 0 or receipt.id <= state.lastReceipt
        or not finite(receipt.tokens) or receipt.tokens % 1 ~= 0 or receipt.tokens < 1 or receipt.tokens > 128 then return false end
    if receipt.startToken ~= nil and (not finite(receipt.startToken) or receipt.startToken % 1 ~= 0
        or receipt.startToken < 1 or receipt.startToken > (vocabularySize or math.huge)) then return false end
    state.lastReceipt, state.tokens, state.offset = receipt.id, receipt.tokens, (receipt.startToken or 1) - 1
    if baseline then
        state.active, state.elapsed, state.packets, state.pending = false, 0, {}, nil
        return false
    end
    if not state.active then state.elapsed = 0 end
    -- Coalesce only unallocated work; preserve rarer pending batches, latest wins ties.
    local oldRank = state.pending and state.pending.receipt.featured and state.pending.receipt.featured.rank or 0
    local newRank = receipt.featured and receipt.featured.rank or 0
    if not state.pending or newRank >= oldRank then
        state.pending = { id = receipt.id, tokens = receipt.tokens, offset = state.offset, next = 1,
            nextStart = state.time, receipt = receipt }
    end
    fill(state, state.time)
    state.active = true
    return true
end

function Flow.reset(state)
    state.active, state.elapsed, state.tokens, state.clock = false, 0, 0, 0
    state.packets, state.pending, state.time = {}, nil, 0
    state.autoTime = 0
    -- Keep the watermark: Studio resets do not reset server receipt IDs.
end

function Flow.span(state)
    return Flow.DURATION + math.max(0, math.min(state.tokens, Flow.MAX_PACKETS) - 1) * Flow.STAGGER
end

function Flow.tick(state, dt, enabled, reduced, speed)
    if not finite(dt) or dt < 0 then return false end
    if not enabled or reduced then
        local ended = state.active
        state.active, state.packets, state.pending = false, {}, nil
        return ended
    end
    state.autoTime = state.autoTime + dt * clamp(speed or 1, 0.25, 1.3)
    state.clock = state.autoTime % Flow.AUTO_PERIOD
    local wasActive, target, completed = state.active, state.time + dt, {}
    if wasActive then state.elapsed = state.elapsed + dt end
    -- Resolve completions chronologically, including long frames, before reusing free slots.
    while true do
        local nextIndex, nextEnd = nil, math.huge
        for index = 1, Flow.MAX_PACKETS do
            local packet = state.packets[index]
            if packet and packet.start + Flow.DURATION < nextEnd then
                nextIndex, nextEnd = index, packet.start + Flow.DURATION
            end
        end
        if not nextIndex or nextEnd > target then break end
        completed[#completed + 1] = state.packets[nextIndex]
        state.packets[nextIndex] = nil
        fill(state, nextEnd)
    end
    state.time, state.active = target, state.pending ~= nil
    for index = 1, Flow.MAX_PACKETS do if state.packets[index] then state.active = true end end
    return wasActive and not state.active, completed
end

function Flow.progress(state, index, automatic)
    if automatic then
        if index > Flow.AUTO_PACKETS then return nil end
        local t = (state.clock / Flow.AUTO_PERIOD + (index - 1) / Flow.AUTO_PACKETS) % 1
        return 0.45 + t * 0.55 -- Ambient traffic stays inside the network.
    end
    local packet = state.packets[index]
    if not packet then return nil end
    local t = (state.time - packet.start) / Flow.DURATION
    if t < 0 or t >= 1 then return nil end
    return t
end

function Flow.route(layers, chooseInteger)
    local route = {}
    -- Full neural connectivity: decorative edge sampling must not bias destinations.
    for layer, count in ipairs(layers) do
        route[layer] = chooseInteger(1, count)
    end
    return route
end

function Flow.trip(state, index)
    return math.floor(state.autoTime / Flow.AUTO_PERIOD + (index - 1) / Flow.AUTO_PACKETS)
end

function Flow.packetRoute(owner, layers, trip, chooseInteger)
    local topology = table.concat(layers, ":")
    if not owner.route or owner.topology ~= topology or owner.trip ~= trip then
        owner.route, owner.topology, owner.trip = Flow.route(layers, chooseInteger), topology, trip
    end
    return owner.route
end

local function between(a, b, t, stage, layer)
    -- Smooth each hop without overshoot; packets stay on the displayed segment.
    local eased = t * t * (3 - 2 * t)
    return { x = a.x + (b.x - a.x) * eased, y = a.y + (b.y - a.y) * eased,
        stage = stage, layer = layer, hop = t }
end

function Flow.position(anchors, points, progress)
    local t = clamp(progress, 0, 1)
    if t < 0.16 then return between(anchors[1], anchors[2], t / 0.16, 1) end
    if t < 0.32 then return between(anchors[2], anchors[3], (t - 0.16) / 0.16, 2) end
    if t < 0.45 then return between(anchors[3], points[1], (t - 0.32) / 0.13, 3) end
    local network = (t - 0.45) / 0.55 * (#points - 1)
    local layer = math.min(#points - 1, math.floor(network) + 1)
    return between(points[layer], points[layer + 1], math.min(1, network - layer + 1), 4, layer)
end

function Flow.layout(width, height, sidebarWidth)
    local sidebar = math.min(sidebarWidth or (width >= 700 and 208 or 128), math.max(80, width - 96))
    local gap, cardHeight = 16, 104
    local cards = {}
    for index = 1, 3 do
        cards[index] = { x = 1, y = 1 + (index - 1) * (cardHeight + 12), width = sidebar - 36, height = cardHeight }
    end
    return { cards = cards, sidebarWidth = sidebar, sidebarHeight = 338, sidebarViewportHeight = height,
        rows = Flow.PREVIEW_TOKENS,
        graphX = sidebar + gap, graphY = 0, graphWidth = math.max(1, width - sidebar - gap),
        graphHeight = math.max(1, height - 58) }
end

function Flow.screenPoints(fit, route, geometry, scroll)
    local points = {}
    scroll = scroll or { x = 0, y = 0 }
    for layer, node in ipairs(route) do
        local point = fit.positions[layer][node]
        points[layer] = { x = geometry.graphX + fit.offsetX + point.x - scroll.x,
            y = geometry.graphY + fit.offsetY + point.y - scroll.y }
    end
    return points
end

function Flow.contains(point, x, y, width, height, marginX, marginY)
    return point.x >= x + marginX and point.x <= x + width - marginX
        and point.y >= y + marginY and point.y <= y + height - marginY
end

return Flow

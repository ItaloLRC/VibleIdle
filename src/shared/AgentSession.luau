--!nonstrict
-- Pure, bounded presentation of confirmed receipts. Never calculates/grants money.
local Agent = { MAX_LINES = 72, MAX_PENDING = 4, DURATION = 1.4 }
local stages = { 0.4, 0.9, 1.4 }
local files = { "src/app.tsx", "src/styles.css", "src/agent.ts", "tests/app.spec.ts" }

function Agent.new()
    return { lines = {}, pending = {}, lastReceipt = 0, revision = 0, completed = 0, coalesced = 0 }
end

function Agent.append(state, text, kind)
    state.lines[#state.lines + 1] = { text = string.sub(text, 1, 220), kind = kind or "muted" }
    if #state.lines > Agent.MAX_LINES then table.remove(state.lines, 1) end
    state.revision = state.revision + 1
end

local function begin(state, job)
    state.active, state.elapsed, state.step = job, 0, 1
    Agent.append(state, string.format("dev@vibe:~$ agent run --job %03d", job.id), "accent")
    Agent.append(state, "> " .. job.command, "text")
    Agent.append(state, "[plan] Inspecting workspace and choosing an implementation.", "muted")
end

function Agent.accept(state, receipt, baseline, prompt, balance)
    if type(receipt) ~= "table" or type(receipt.id) ~= "number" or receipt.id ~= receipt.id
        or receipt.id % 1 ~= 0 or receipt.id <= state.lastReceipt or receipt.id == math.huge then return false end
    if baseline then state.lastReceipt = receipt.id;return false end
    if type(receipt.tokens) ~= "number" or receipt.tokens % 1 ~= 0 or receipt.tokens < 1
        or receipt.tokens > balance.PROMPT_MAX_TOKENS or type(receipt.reward) ~= "number"
        or receipt.reward ~= receipt.reward or receipt.reward < 0 or receipt.reward > balance.MAX_CREDITS then return false end
    local command = prompt.text(receipt.tokens, balance, (receipt.startToken or 1) - 1)
    if not command then return false end
    state.lastReceipt = receipt.id
    -- Copy only the confirmed summary; later snapshots cannot relabel an active job.
    local job = { id = receipt.id, tokens = receipt.tokens, reward = receipt.reward,
        word = receipt.outputToken or "FIX", rarity = receipt.outputRarity or "Common",
        rank = receipt.featured and receipt.featured.rank or 1,
        command = string.sub(command, 1, 170), file = files[(receipt.id - 1) % #files + 1] }
    if not state.active then begin(state, job)
    elseif #state.pending < Agent.MAX_PENDING then state.pending[#state.pending + 1] = job
    else
        -- Collapse only unstarted previews. Every receipt was already paid by the server.
        local last = state.pending[#state.pending]
        if job.rank >= last.rank then state.pending[#state.pending] = job end
        state.coalesced = state.coalesced + 1
    end
    return true
end

function Agent.tick(state, dt, reduced, duration)
    if type(dt) ~= "number" or dt ~= dt or dt < 0 or dt == math.huge then return end
    local remaining = reduced and math.huge or dt -- At most one active + four queued jobs.
    while state.active do
        local stage=stages[state.step]*(duration or Agent.DURATION)/Agent.DURATION
        local untilStage = math.max(0,stage - state.elapsed)
        if remaining < untilStage then state.elapsed = state.elapsed + remaining;break end
        remaining, state.elapsed = remaining - untilStage, stage
        local job = state.active
        if state.step == 1 then
            Agent.append(state, "[edit] " .. job.file .. "  +" .. job.tokens .. " generated tokens", "accent")
            Agent.append(state, "+ export const build = () => ship(feature);", "success")
        elseif state.step == 2 then
            Agent.append(state, "[test] Type check passed. All checks green.", "success")
        else
            Agent.append(state, string.format("[ship #%03d] %s / %s  +$%.2f", job.id, job.word, job.rarity, job.reward), job.rarity)
            state.completed, state.lastResult = state.completed + 1, job
            state.active = nil
            if #state.pending > 0 then begin(state, table.remove(state.pending, 1)) end
        end
        if state.active == job then state.step = state.step + 1 end
    end
end

function Agent.reset(state)
    state.active, state.elapsed, state.lastResult = nil, nil, nil
    state.pending, state.lines, state.completed, state.coalesced = {}, {}, 0, 0
    state.revision = state.revision + 1 -- Receipt watermark intentionally survives reset.
end

-- Pure desktop geometry shared by placement, dragging and portable layout checks.
function Agent.clampWindow(x, y, width, height, desktopWidth, desktopHeight)
    return math.max(0, math.min(x, desktopWidth - width)),
        math.max(0, math.min(y, desktopHeight - height))
end

-- Historical multi-window geometry remains for portable fixtures. Live
-- workstationLayout below always requests only the Main CLI.
function Agent.windowLayout(width, height, count)
    count = math.max(1, math.min(8, math.floor(count or 1)))
    local windows = {}
    if width < 760 or height < 340 then
        local stack = math.min((count - 1) * 14, 84, math.max(0, height - 220))
        local inset = count > 1 and math.min(6, math.floor(width / 40)) or 0
        windows[1] = { x = inset, y = stack, width = width - inset * 2, height = height - stack }
        for index = 2, count do
            windows[index] = { x = ((index - 2) % 3) * inset, y = math.min((index - 2) * 14, stack),
                width = width - inset * 2, height = math.min(300, height - stack) }
        end
    else
        local mainWidth = math.min(1020, math.floor(width * (count == 1 and 0.84 or 0.74)))
        local mainHeight = math.min(680, math.floor(height * 0.86))
        windows[1] = { x = count == 1 and math.floor((width - mainWidth) / 2) or math.floor(width * 0.045),
            y = count == 1 and math.floor((height - mainHeight) / 2) or height - mainHeight - 8,
            width = mainWidth, height = mainHeight }
        local anchors = { {1, 0}, {0.04, 0.03}, {0.88, 0.8}, {0.18, 0.7},
            {0.72, 0.18}, {0.4, 0.02}, {0.97, 0.5} }
        local secondaryWidth, secondaryHeight = math.min(540, math.floor(width * 0.56)), math.min(330, math.floor(height * 0.72))
        for index = 2, count do
            windows[index] = { x = math.floor((width - secondaryWidth) * anchors[index - 1][1]),
                y = math.floor((height - secondaryHeight) * anchors[index - 1][2]),
                width = secondaryWidth, height = secondaryHeight }
        end
    end
    return windows
end

-- Fixed readable typography; no sidebar or permanently reserved shop column.
function Agent.layout(width, height, count)
    local narrow, short = width < 960, height < 470
    local top, footer, gap = 8, 44, 8
    local desktopWidth, desktopHeight = math.max(1, width - 16), math.max(1, height - top - footer - gap)
    return { narrow = narrow, short = short, explorer = 0, shop = 0,
        top = top, footer = footer, gap = gap, x = gap,
        width = desktopWidth, height = desktopHeight,
        windows = Agent.windowLayout(desktopWidth, desktopHeight, count) }
end

-- Fixed right shop; preserve a readable virtual CLI on physically narrow screens.
function Agent.workstationLayout(width,height,_count)
    local shopWidth=width>=960 and 288 or width>=680 and 224 or 176
    local viewportWidth=math.max(1,width-shopWidth-24)
    local canvasWidth=math.max(320,viewportWidth)
    local reserve=height<500 and 112 or 148
    local spec=Agent.layout(canvasWidth+16,height-reserve,1)
    spec.x,spec.top,spec.width,spec.height=0,0,canvasWidth,height
    spec.viewportWidth=viewportWidth
    -- Initial composition keeps space for the shop; dragging uses the full root.
    spec.dragWidth=math.max(320,width)
    spec.windows[1].width=math.min(canvasWidth,math.max(320,math.min(1040,math.floor(canvasWidth*0.88))))
    spec.windows[1].x=math.floor((canvasWidth-spec.windows[1].width)/2)
    spec.store={x=math.max(0,width-shopWidth-8),y=8,width=shopWidth,height=math.max(1,height-60)}
    return spec
end

return Agent

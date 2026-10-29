--!nonstrict
-- Fixed authored text. Raw keyboard input never leaves the client.
local Prompt = {}
local words = {
    "build", "a", "responsive", "dashboard", "with", "dark", "mode", "and", "reusable",
    "components", "then", "verify", "tests", "before", "shipping", "clean", "production", "ready",
    "code", "signal", "neuron", "network", "repository", "commit", "patch", "refactor", "deploy",
    "release", "lint", "render", "async", "promise", "request", "response", "endpoint", "server",
    "client", "browser", "layout", "button", "theme", "application", "package", "workspace", "terminal",
    "agent", "tool", "plan", "edit", "test", "debug", "fix", "review", "document",
    "buildlog", "typescript", "stylesheet", "component", "hook", "state", "props", "reducer", "action",
    "effect", "event", "handler", "interface", "import", "export", "const", "return", "await",
    "fetch", "resolve", "reject", "assert", "mock", "suite", "fixture", "coverage", "diff",
    "staging", "origin", "main", "config", "script", "command", "shell", "git", "npm",
    "vite", "eslint", "prettier", "status", "success", "task", "worker", "cpu", "context",
    "completion", "function", "module", "method", "object", "array", "index", "table", "stack",
    "queue", "loop", "step", "frame", "screen", "display", "color", "light", "memory",
    "compute", "logic", "data", "stream", "token", "input", "output", "encode", "decode",
    "vector", "matrix", "layer",
}
Prompt.VOCABULARY_SIZE = #words
local tokenIds = {}
for index, word in ipairs(words) do tokenIds[string.lower(word)] = index end

function Prompt.tokenId(word)
    return type(word) == "string" and tokenIds[string.lower(word)] or nil
end

function Prompt.limit(state, balance)
    return math.min(balance.PROMPT_MAX_TOKENS,
        balance.PROMPT_BASE_TOKENS + state.tokenLevel * balance.PROMPT_TOKENS_PER_LEVEL)
end

function Prompt.agentTypingRate(state, balance)
    return balance.TYPING_BASE_RATE + (state.typingLevel or 0) * balance.TYPING_RATE_PER_LEVEL
end

function Prompt.nextWord(tokens)
    return words[tokens % #words + 1]
end

function Prompt.text(tokens, balance, offset)
    offset = offset or 0
    if type(tokens) ~= "number" or tokens ~= tokens or tokens % 1 ~= 0
        or tokens < 0 or tokens > balance.PROMPT_MAX_TOKENS
        or type(offset) ~= "number" or offset ~= offset or offset % 1 ~= 0 or offset < 0 or offset >= #words then return nil end
    local result = {}
    for index = 1, tokens do result[index] = words[(offset + index - 1) % #words + 1] end
    return table.concat(result, " ")
end

function Prompt.validate(text, limit, balance)
    if type(text) ~= "string" or #text > balance.PROMPT_MAX_BYTES then return nil, "invalid_prompt" end
    local count = 0
    for _ in string.gmatch(text, "%S+") do
        count = count + 1
        if count > limit then return nil, "prompt_too_long" end
    end
    if count == 0 then return nil, "empty_prompt" end
    local first = string.match(text, "%S+")
    local id = Prompt.tokenId(first)
    if not id or text ~= Prompt.text(count, balance, id - 1) then return nil, "invalid_prompt" end
    return count, nil, id - 1
end

function Prompt.drawOutput(balance, chooseInteger)
    if type(chooseInteger) ~= "function" then return nil end
    local total = 0
    for _, tier in ipairs(balance.OUTPUT_TOKENS) do total = total + tier.weight end
    local roll = chooseInteger(1, total)
    if type(roll) ~= "number" or roll ~= roll or roll % 1 ~= 0 or roll < 1 or roll > total then return nil end
    local cumulative = 0
    for rank, tier in ipairs(balance.OUTPUT_TOKENS) do
        cumulative = cumulative + tier.weight
        if roll <= cumulative then
            return { word = tier.word, rarity = tier.rarity, multiplier = tier.multiplier,
                weight = tier.weight, totalWeight = total, rank = rank }
        end
    end
end

function Prompt.receiptView(receipt, includeOutputs)
    if not receipt then return nil end
    local view = {}
    for _, key in ipairs({ "id", "draftId", "tokens", "reward", "startToken", "outputToken", "outputRarity", "featured", "featuredIndex", "skillBonus" }) do
        view[key] = receipt[key]
    end
    if includeOutputs then view.outputs = receipt.outputs end
    if receipt.outputs then
        view.tokenRewards={}
        for index,output in ipairs(receipt.outputs) do view.tokenRewards[index]=output.reward end
    end
    return view
end

function Prompt.submit(state, text, now, lastManual, balance, simulation, chooseInteger)
    local count, reason, offset = Prompt.validate(text, Prompt.limit(state, balance), balance)
    if not count then return false, reason end
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge
        or now - lastManual < balance.MANUAL_MIN_INTERVAL then return false, "prompt_cooldown" end
    local outputs, featured, featuredIndex, reward, remaining = {}, nil, nil, 0, balance.MAX_CREDITS - state.credits
    local base = simulation.batchReward(state)
    for index = 1, count do
        local output = Prompt.drawOutput(balance, chooseInteger)
        if not output then return false, "invalid_reward_roll" end
        output.reward = math.min(remaining, base * output.multiplier)
        remaining, reward = remaining - output.reward, reward + output.reward
        outputs[index] = output
        if not featured or output.rank > featured.rank then featured, featuredIndex = output, index end
    end
    state.credits = state.credits + reward
    state.batches = math.min(balance.MAX_CREDITS, state.batches + 1)
    return true, { tokens = count, reward = reward, startToken = offset + 1,
        outputToken = featured.word, outputRarity = featured.rarity, featured = featured,
        featuredIndex = featuredIndex, outputs = outputs }
end

return Prompt

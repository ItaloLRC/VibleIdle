--!nonstrict
-- Server-issued token offers. A client submits only an offer ID and prefix length.
local Session = {}
local function integer(value, low, high)
    return type(value) == "number" and value == value and value % 1 == 0 and value >= low and value <= high
end

function Session.validPayload(payload, balance)
    if type(payload) ~= "table" or not integer(payload.draftId, 1, balance.MAX_CREDITS)
        or not integer(payload.tokens, 1, balance.PROMPT_MAX_TOKENS) then return false end
    local fields = 0
    for key in pairs(payload) do
        if key ~= "draftId" and key ~= "tokens" then return false end
        fields = fields + 1
    end
    return fields == 2
end

function Session.new() return { cursor = 0, sequence = 0 } end

function Session.statistics(session, now)
    local totals = session.totals or { earned = 0, prompts = 0, tokens = 0, special = 0, tiers = {0,0,0,0,0} }
    local recent, amount = session.recent or {}, 0
    for index = #recent, 1, -1 do
        if now - recent[index].time >= 10 then table.remove(recent, index)
        else amount = amount + recent[index].reward end
    end
    local tiers = {};for index, count in ipairs(totals.tiers) do tiers[index] = count end
    return { earned = totals.earned, prompts = totals.prompts, tokens = totals.tokens,
        special = totals.special, tiers = tiers, moneyPerSecond = amount / 10,
        skillBonus = totals.skillBonus or 0,streak=session.streak or 0,
        bestStreak=session.bestStreak or 0,streakMultiplier=session.streakMultiplier or 1 }
end

-- Keep tier metadata/multipliers canonical; only the server's ticket weights vary.
-- denominator in SPECIAL_TOKENS remains the baseline odds, not a live chance.
function Session.tokenWeights(profile,balance)
    local boost=balance.progression(profile).rarityBoost
    local weights,special={},0
    for rank=2,#balance.SPECIAL_TOKENS do
        weights[rank]=balance.SPECIAL_TOKENS[rank].weight*boost
        special=special+weights[rank]
    end
    weights[1]=10000-special
    return weights
end

local function token(cursor, balance, prompt, choose, weights)
    if type(choose) ~= "function" then return nil end
    local roll = choose(1, 10000)
    if not integer(roll, 1, 10000) then return nil end
    local cumulative = 0
    for rank, tier in ipairs(balance.SPECIAL_TOKENS) do
        cumulative = cumulative + weights[rank]
        if roll <= cumulative then
            return { word = prompt.nextWord(cursor), rarity = tier.rarity, rank = rank,
                multiplier = tier.multiplier, denominator = tier.denominator }
        end
    end
end

local function build(cursor, id, limit, balance, prompt, choose, profile, existing)
    local offers = {}
    local weights=Session.tokenWeights(profile,balance)
    for index = 1, limit do
        offers[index] = existing and existing[index] or token((cursor + index - 1) % prompt.VOCABULARY_SIZE, balance, prompt, choose, weights)
        if not offers[index] then return nil end
    end
    return { id = id, startToken = cursor + 1, offers = offers }
end

function Session.ensure(session, profile, balance, prompt, choose, now)
    local limit = prompt.limit(profile, balance)
    local draft = session.draft
    if draft and #draft.offers == limit then return draft end
    local id = draft and draft.id or session.sequence + 1
    local nextDraft = build(session.cursor, id, limit, balance, prompt, choose, profile, draft and draft.offers)
    if not nextDraft then return nil, "invalid_reward_roll" end
    session.sequence, session.draft = id, nextDraft
    return nextDraft
end

function Session.view(draft)
    if not draft then return nil end
    local view = { id = draft.id, startToken = draft.startToken, offers = {} }
    for index, offer in ipairs(draft.offers) do
        view.offers[index] = { word = offer.word, rarity = offer.rarity, rank = offer.rank,
            multiplier = offer.multiplier, denominator = offer.denominator }
    end
    return view
end

function Session.wire(draft)
    local wire = { id = draft.id, startToken = draft.startToken, ranks = {} }
    for index, offer in ipairs(draft.offers) do wire.ranks[index] = offer.rank end
    return wire -- Words and tier metadata are fixed shared data, not repeated 128 times.
end

function Session.baseReward(profile, balance, simulation,unixNow)
    local value=simulation.batchReward(profile)*balance.valueMultiplier(profile)*balance.progression(profile).money*balance.premiumMultiplier(profile,"money",unixNow)
    return math.min(balance.MAX_CREDITS,math.floor(value*100+0.5)/100)
end

function Session.submit(session, profile, payload, now, lastManual, balance, prompt, simulation, choose,unixNow)
    if not Session.validPayload(payload, balance) then return false, "invalid_prompt" end
    local draft = session.draft
    if not draft or payload.draftId ~= draft.id then return false, "stale_prompt" end
    local count = payload.tokens
    if count > #draft.offers or count > prompt.limit(profile, balance) then return false, "prompt_too_long" end
    if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge
        or now-lastManual < (session.skillSettings and session.skillSettings.promptCooldown or 0) then return false, "prompt_cooldown" end
    local remaining, total, outputs, best, bestIndex = balance.MAX_CREDITS - profile.credits, 0, {}, nil, 1
    local skillBonus=0
    local base = Session.baseReward(profile, balance, simulation,unixNow)
    for index = 1, count do
        local offer = draft.offers[index]
        local skill=session.skillAwards and session.skillAwards[index]
        local factor=skill and skill.multiplier or 1
        local normal=math.min(remaining,math.floor(base*offer.multiplier*100+0.5)/100)
        local amount = math.min(remaining, math.floor(base * offer.multiplier * factor * 100 + 0.5) / 100)
        skillBonus=skillBonus+amount-normal
        local output = { word = offer.word, rarity = offer.rarity, rank = offer.rank,
            multiplier = offer.multiplier, denominator = offer.denominator, reward = amount,
            skillMultiplier=factor,skillGrade=skill and skill.grade or "Normal" }
        outputs[index], remaining, total = output, remaining - amount, total + amount
        if not best or output.rank > best.rank then best, bestIndex = output, index end
    end
    local cursor = (session.cursor + count) % prompt.VOCABULARY_SIZE
    local nextDraft = build(cursor, session.sequence + 1, prompt.limit(profile, balance), balance, prompt, choose, profile)
    if not nextDraft then return false, "invalid_reward_roll" end
    -- Prepare all values before the synchronous, once-only debit-free payout/advance.
    profile.credits = math.min(balance.MAX_CREDITS, profile.credits + total)
    profile.lifetimeEarned=math.min(balance.MAX_LIFETIME_EARNED,(profile.lifetimeEarned or 0)+total)
    profile.batches = math.min(balance.MAX_CREDITS, profile.batches + 1)
    session.cursor, session.sequence, session.draft = cursor, nextDraft.id, nextDraft
    session.phaseAnchor=session.skillCheck
    session.skillCheck,session.skillAwards=nil,nil
    session.lastSkillClick=nil
    if not session.totals then
        session.totals = { earned = 0, prompts = 0, tokens = 0, special = 0, tiers = {0,0,0,0,0} }
        session.recent = {}
    end
    local totals = session.totals
    totals.earned, totals.prompts, totals.tokens = totals.earned + total, totals.prompts + 1, totals.tokens + count
    totals.skillBonus=(totals.skillBonus or 0)+skillBonus
    for _, output in ipairs(outputs) do
        totals.tiers[output.rank] = totals.tiers[output.rank] + 1
        if output.rank > 1 then totals.special = totals.special + 1 end
    end
    Session.statistics(session, now)
    session.recent[#session.recent + 1] = { time = now, reward = total }
    return true, { id = draft.id, draftId = draft.id, tokens = count, startToken = draft.startToken,
        reward = total, skillBonus=skillBonus, outputToken = best.word, outputRarity = best.rarity,
        featured = best, featuredIndex = bestIndex, outputs = outputs }
end

function Session.reset(session)
    session.nextAutoSkillAt=nil
    session.cursor, session.draft, session.agentPace = 0, nil, nil -- Sequence survives reset.
    session.totals, session.recent = nil, nil
    session.skillCheck,session.skillAwards,session.lastSkillClick=nil,nil,nil -- Skill sequence survives.
    session.avatarItems,session.lastAvatarCollect=nil,nil -- Avatar sequence survives reset.
    session.visitorNextAt,session.visitorLastPoll=nil,nil
    session.fragmentReceipts,session.fragmentReceiptOrder=nil,nil
    session.phaseAnchor=nil
    session.autoReceipt,session.autoSequence,session.autoTime=nil,nil,nil
    session.agentWordsPerClick=nil
    session.streak,session.bestStreak,session.streakMultiplier=0,0,1
    session.streakExpiresAt=nil
    session.lastStreakActivity=nil
end

return Session

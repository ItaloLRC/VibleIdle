--!nonstrict
-- Agent-only speed budget and streak reward. No automatic skill successes.
local Auto={}
local neutral={speed=1,value=1}
function Auto.advance(session,profile,now,balance,rules,skill,cards)
    if type(now)~="number" or now~=now or math.abs(now)==math.huge then return false end
    local rate=balance.TYPING_BASE_RATE+(profile.typingLevel or 0)*balance.TYPING_RATE_PER_LEVEL
    if session.skillSettings and (session.skillSettings.agentRate or 0)>0 then rate=session.skillSettings.agentRate end
    local interval=session.skillSettings and session.skillSettings.agentInterval or balance.AGENT_INTERVAL
    local words=rules and skill and skill.wordsPerClick(session.streak or 0,1+profile.clickLevel,rules.streakDivisor(profile,balance))
        or session.agentWordsPerClick or 1
    session.agentWordsPerClick=words
    local productionRate=math.min(rate,words/interval)
    local pace=session.agentPace
    if not pace then
        pace={time=now,budget=0,rate=rate,agents={}}
        session.agentPace=pace
    end
    if now<pace.time then return false end
    -- Each agent owns one second of capacity. New agents start accruing now,
    -- without consuming another agent's budget or inheriting earlier idle time.
    pace.budget=0
    pace.totalRate,pace.totalProductionRate=0,0
    local treeSpeed=balance.progression(profile).speed
    for index=1,#profile.layerSizes-2 do
        local effect=cards and cards.effect(profile,index,balance) or neutral
        local speed=effect.speed*treeSpeed
        local agentRate=math.min(balance.MAX_CARD_TYPING_RATE,rate*speed)
        local agentProductionRate=math.min(agentRate,words/interval*speed)
        local agentPeriod=agentProductionRate>0 and 1/agentProductionRate or math.huge
        local agent=pace.agents[index]
        if not agent then
            local phase=((index-1)*0.61803398875)%1
            agent={time=now,budget=0,rate=agentRate,nextAt=now+agentPeriod*(1+phase*0.75),period=agentPeriod,ordinal=0,phase=phase}
            pace.agents[index]=agent
        else
            agent.budget=math.min(balance.PROMPT_MAX_TOKENS,agent.rate,agent.budget+(now-agent.time)*agent.rate)
            if agent.period~=agentPeriod then
                local remaining=agent.period<math.huge and math.max(0,agent.nextAt-now)/agent.period or 1
                agent.nextAt=agentPeriod<math.huge and now+remaining*agentPeriod or math.huge
                agent.period=agentPeriod
            end
            agent.time,agent.rate=now,agentRate
        end
        agent.budget=math.min(agent.budget,agentRate)
        agent.productionRate,agent.cardValue=agentProductionRate,effect.value
        pace.budget=pace.budget+agent.budget
        pace.totalRate=pace.totalRate+agentRate
        pace.totalProductionRate=pace.totalProductionRate+agentProductionRate
    end
    for index=#pace.agents,#profile.layerSizes-1,-1 do pace.agents[index]=nil end
    pace.time,pace.rate,pace.productionRate=now,rate,productionRate
    return true
end
function Auto.delay(session,now,balance)
    local delay=session.skillSettings and session.skillSettings.agentInterval or balance.AGENT_INTERVAL
    for _,agent in ipairs(session.agentPace and session.agentPace.agents or {}) do
        delay=math.min(delay,math.max(0,agent.nextAt-now,(1-agent.budget)/agent.rate))
    end
    return delay
end
function Auto.grant(session,profile,payload,now,balance,rules,skill,cards)
    if type(now)~="number" or now~=now or math.abs(now)==math.huge then return false end
    if type(payload)~="table" then return false end
    local fields=0
    for key,value in pairs(payload) do
        local maximum=key=="tokenIndex" and balance.PROMPT_MAX_TOKENS or balance.MAX_CREDITS
        if (key~="requestId" and key~="draftId" and key~="tokenIndex") or type(value)~="number"
            or value~=value or value%1~=0 or value<1 or value>maximum then return false end
        fields=fields+1
    end
    if fields~=3 then return false end
    local draft=session.draft
    if not draft or payload.draftId~=draft.id or payload.tokenIndex>#draft.offers then return false end
    if payload.requestId<=(session.autoSequence or 0) then return false end
    if not Auto.advance(session,profile,now,balance,rules,skill,cards) then return false end
    local count,costs,sources,deadlines,ordinals=0,{},{},{},{}
    local jitter=session.skillSettings and session.skillSettings.agentJitter or balance.AGENT_TIMING_JITTER
    for agentIndex,agent in ipairs(session.agentPace.agents) do
        local window=math.min(balance.AGENT_COALESCE_WINDOW,math.max(balance.AGENT_POLL_INTERVAL,now-(agent.lastGrantAt or now)))
        local maximum=math.max(1,math.ceil(agent.productionRate*window))
        local fresh,start=0,count
        local nextAt,ordinal=agent.nextAt,agent.ordinal
        if now-nextAt>agent.period*maximum then nextAt=now-(agent.phase or 0)*agent.period*0.75 end
        for _=1,maximum do
            if now+0.000001<nextAt then break end
            local index=payload.tokenIndex+count
            if index>#draft.offers then break end
            if not (session.skillAwards and session.skillAwards[index]) then
                if fresh>=math.floor(agent.budget+0.000001) then break end
                fresh=fresh+1
            end
            count=count+1
            ordinal=ordinal+1
            nextAt=nextAt+agent.period*(1+((ordinal+agentIndex)%2==0 and jitter or -jitter))
        end
        costs[agentIndex]=fresh
        deadlines[agentIndex],ordinals[agentIndex]=nextAt,ordinal
        if count>start then sources[#sources+1]={agentIndex=agentIndex,wordCount=count-start} end
    end
    if count<1 then return false end
    local factor=1+(session.streak or 0)*0.1
    session.skillAwards=session.skillAwards or {}
    local cursor=payload.tokenIndex
    for _,source in ipairs(sources) do
        local cardValue=session.agentPace.agents[source.agentIndex].cardValue
        for index=cursor,cursor+source.wordCount-1 do
            if not session.skillAwards[index] then
                session.skillAwards[index]={tokenIndex=index,grade="Agent",multiplier=factor*cardValue,
                    precisionMultiplier=1,streakMultiplier=factor,streak=session.streak or 0,cardMultiplier=cardValue}
            end
        end
        cursor=cursor+source.wordCount
    end
    session.agentPace.budget=0
    for index,agent in ipairs(session.agentPace.agents) do
        agent.budget=math.max(0,agent.budget-costs[index])
        session.agentPace.budget=session.agentPace.budget+agent.budget
    end
    for _,source in ipairs(sources) do
        local agent=session.agentPace.agents[source.agentIndex]
        agent.nextAt,agent.ordinal=deadlines[source.agentIndex],ordinals[source.agentIndex]
        agent.lastGrantAt=now
    end
    session.autoTime,session.autoSequence=now,payload.requestId
    session.autoReceipt={requestId=payload.requestId,draftId=draft.id,tokenIndex=payload.tokenIndex,wordCount=count,sources=sources}
    return true
end
return Auto

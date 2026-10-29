--!nonstrict
-- Server-issued collectible actors; cosmetics never choose the reward.
local Items={CAPACITY=10,SPAWN_PERCENT=30,VISITOR_TTL=24,VISITOR_MIN=5,VISITOR_MAX=10}
Items.RARITIES={
    {name="Common",weight=6000,streak=1},
    {name="Uncommon",weight=2500,streak=2},
    {name="Rare",weight=1000,streak=3},
    {name="Epic",weight=400,streak=5},
    {name="Legendary",weight=100,streak=10},
}
function Items.clear(session) session.avatarItems={} end
local function integer(value,low,high)
    return type(value)=="number" and value==value and value%1==0 and value>=low and value<=high
end
function Items.expire(session,now)
    for index=1,Items.CAPACITY do
        local item=session.avatarItems and session.avatarItems[index]
        if item and item.expiresAt and now>=item.expiresAt then session.avatarItems[index]=nil end
    end
end
function Items.poll(session,profile,id,now,choose,balance)
    if not integer(id,1,balance.MAX_CREDITS) or type(now)~="number" or now~=now or now<0 or now>=math.huge
        or id<=(session.visitorPollSequence or 0) then return false end
    session.visitorPollSequence=id
    Items.expire(session,now)
    local last=session.visitorLastPoll
    if last and now-last<.75 then return false end
    session.visitorLastPoll=now
    if not last or now-last>2.5 or not session.visitorNextAt then
        local delay=choose(Items.VISITOR_MIN,Items.VISITOR_MAX)
        if not integer(delay,Items.VISITOR_MIN,Items.VISITOR_MAX) then return false end
        session.visitorNextAt=now+delay;return true
    end
    if now<session.visitorNextAt then return true end
    local delay=choose(Items.VISITOR_MIN,Items.VISITOR_MAX)
    if not integer(delay,Items.VISITOR_MIN,Items.VISITOR_MAX) then return false end
    session.visitorNextAt=now+delay
    session.avatarItems=session.avatarItems or {}
    local slot,count=nil,0
    for index=1,Items.CAPACITY do
        if session.avatarItems[index] then count=count+1 elseif not slot then slot=index end
    end
    if not slot or count>=(session.skillSettings and session.skillSettings.spawnCapacity or Items.CAPACITY) then return true end
    local roll,familyIndex,x,y=choose(1,10000),choose(1,#balance.AGENT_FAMILIES),choose(0,1000),choose(0,1000)
    if not integer(roll,1,10000) or not integer(familyIndex,1,#balance.AGENT_FAMILIES) or not integer(x,0,1000) or not integer(y,0,1000)
        or (session.avatarSequence or 0)>=balance.MAX_CREDITS then return false end
    local rank,total=1,0
    for index,tier in ipairs(balance.CRAFT_TIERS) do total=total+tier.weight;if roll<=total then rank=index;break end end
    local tier=balance.CRAFT_TIERS[rank];local family=balance.AGENT_FAMILIES[familyIndex]
    session.avatarSequence=(session.avatarSequence or 0)+1
    session.avatarItems[slot]={id=session.avatarSequence,rank=rank,familyId=family.id,familyName=family.name,rarity=tier.name,
        mascotId=family.id..(rank==1 and "" or "_"..tier.id),fragments=math.floor(tier.drop*balance.progression(profile).collect+.5),
        expiresAt=now+Items.VISITOR_TTL,x=x/1000,y=y/1000}
    return true
end
function Items.collectFragments(session,profile,id,now,balance)
    if not integer(id,1,balance.MAX_CREDITS) or type(now)~="number" or now~=now or now<0 or now>=math.huge then return false end
    local prior=session.fragmentReceipts and session.fragmentReceipts[id]
    if prior then session.lastAvatarCollect=prior;return true end
    Items.expire(session,now)
    local slot,item
    for index=1,Items.CAPACITY do
        local candidate=session.avatarItems and session.avatarItems[index]
        if candidate and candidate.id==id and candidate.familyId then slot=index;item=candidate;break end
    end
    if not item then return false end
    local before=profile.fragments[item.familyId]
    if not integer(before,0,balance.MAX_FRAGMENTS) then return false end
    local added=math.min(item.fragments,balance.MAX_FRAGMENTS-before)
    profile.fragments[item.familyId]=before+added;session.avatarItems[slot]=nil
    local receipt={id=id,rank=item.rank,rarity=item.rarity,familyId=item.familyId,fragments=added,total=before+added}
    session.fragmentReceipts=session.fragmentReceipts or {};session.fragmentReceiptOrder=session.fragmentReceiptOrder or {}
    session.fragmentReceipts[id]=receipt;table.insert(session.fragmentReceiptOrder,id)
    if #session.fragmentReceiptOrder>64 then session.fragmentReceipts[table.remove(session.fragmentReceiptOrder,1)]=nil end
    session.lastAvatarCollect=receipt;return true
end
-- Historical pure streak-pickup fixtures only. Live collection uses poll and
-- collectFragments above; timing grades never call issue in GameService.
function Items.issue(session,result,profile,choose,boost)
    if result.streakBroken or (session.streak or 0)==0 then Items.clear(session);return false end
    if result.reused or result.streakBroken or (result.grade~="Good" and result.grade~="Great") then return false end
    session.avatarItems=session.avatarItems or {}
    local slot
    local settings=session.skillSettings
    local capacity=settings and settings.spawnCapacity or Items.CAPACITY
    local count=0
    for index=1,Items.CAPACITY do
        if session.avatarItems[index] then count=count+1
        elseif not slot then slot=index end
    end
    if count>=capacity then return false end
    if not slot then return false end
    local spawnRoll=choose(1,100)
    if type(spawnRoll)~="number" or spawnRoll%1~=0 or spawnRoll<1 or spawnRoll>(settings and settings.spawnPercent or Items.SPAWN_PERCENT) then return false end
    local roll=choose(1,10000)
    if type(roll)~="number" or roll%1~=0 or roll<1 or roll>10000 then return false end
    local rank,total=1,0
    for index,tier in ipairs(Items.RARITIES) do total=total+tier.weight;if roll<=total then rank=index;break end end
    local source=choose(1,#profile.layerSizes-2)
    if type(source)~="number" or source%1~=0 or source<1 or source>#profile.layerSizes-2 then return false end
    session.avatarSequence=(session.avatarSequence or 0)+1
    session.avatarItems[slot]={id=session.avatarSequence,rank=rank,sourceAgent=source,streak=session.streak,
        reward=math.floor(Items.RARITIES[rank].streak*(boost or 1)+.5)}
    return true
end
function Items.collect(session,id,now,choose,skill)
    if (session.streak or 0)==0 or not session.draft or not session.skillCheck then return false end
    local slot,item
    for index=1,Items.CAPACITY do
        local candidate=session.avatarItems and session.avatarItems[index]
        if candidate and candidate.id==id then slot=index;item=candidate;break end
    end
    if not item then return false end
    local count=math.min(session.streakCap or skill.MAX_STREAK,session.streak+(item.reward or Items.RARITIES[item.rank].streak))
    local prepared={skillSequence=session.skillSequence,streak=count,phaseAnchor=session.skillCheck,skillSettings=session.skillSettings}
    local check=skill.ensure(prepared,session.draft,now,choose,0)
    if not check then return false end -- Invalid time/randomness cannot partially consume.
    local added=count-session.streak
    session.avatarItems[slot]=nil
    session.streak=count;session.bestStreak=math.max(session.bestStreak or 0,count)
    session.streakMultiplier=skill.streakFactor(count)
    skill.refreshDeadline(session,now)
    session.skillCheck,session.skillSequence=check,prepared.skillSequence
    session.lastAvatarCollect={id=id,rank=item.rank,added=added,streak=count}
    return true
end
function Items.view(session)
    local result={sequence=session.avatarSequence or 0,pollSequence=session.visitorPollSequence or 0,nextSpawnAt=session.visitorNextAt,items={}}
    for index=1,Items.CAPACITY do
        local item=session.avatarItems and session.avatarItems[index]
        if item then
            local copy={};for key,value in pairs(item) do copy[key]=value end
            result.items[#result.items+1]=copy
        end
    end
    return result
end
return Items

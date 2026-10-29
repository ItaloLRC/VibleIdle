--!nonstrict
-- Server-issued circular timing challenge. No client grade, clock or money input.
local Skill={DURATION=1.0,GOOD_WIDTH=72,GREAT_WIDTH=24,GRACE=0.12,STREAK_TIMEOUT=5}
Skill.STREAK_TIERS={{at=0,multiplier=1},{at=3,multiplier=1.25},{at=5,multiplier=1.5},
    {at=10,multiplier=2},{at=20,multiplier=3},{at=35,multiplier=4}}
Skill.MAX_STREAK=9999
local function finite(value)
    return type(value)=="number" and value==value and math.abs(value)<math.huge
end
function Skill.streakFactor(count)
    for index=#Skill.STREAK_TIERS,1,-1 do
        local tier=Skill.STREAK_TIERS[index]
        if count>=tier.at then return tier.multiplier end
    end
    return 1
end
function Skill.nextTier(count)
    for _,tier in ipairs(Skill.STREAK_TIERS) do if count<tier.at then return tier end end
    return nil
end
function Skill.difficulty(count,settings)
    local progress=math.max(0,math.min(40,count))
    local initial=settings and settings.initialRps or 1/Skill.DURATION
    local growth=settings and settings.growth or 1.045
    return math.max(settings and settings.minDuration or 0.55,1/initial/growth^progress),Skill.GOOD_WIDTH-progress*1.1,Skill.GREAT_WIDTH-progress*0.4
end
function Skill.phase(check,now)
    return ((now-check.startsAt)/check.duration*360+(check.phaseOffset or 0))%360
end
function Skill.refreshDeadline(session,now)
    local timeout=session.skillSettings and session.skillSettings.streakTimeout or Skill.STREAK_TIMEOUT
    session.lastStreakActivity=now
    session.streakExpiresAt=(session.streak or 0)>0 and timeout>0 and now+timeout or nil
end
function Skill.retime(session,now)
    local check=session.skillCheck
    if not check then return end
    local phase=Skill.phase(check,now)
    local delay=math.max(0,check.startsAt-now)
    local duration,good,great=Skill.difficulty(session.streak or 0,session.skillSettings)
    check.startsAt,check.phaseOffset=now+delay,(phase+delay/duration*360)%360
    check.duration,check.goodWidth,check.greatWidth=duration,good,great
    check.streak=session.streak or 0
    check.grace=session.skillSettings and session.skillSettings.grace or Skill.GRACE
end
function Skill.expireStreak(session,now)
    if not finite(now) or not session.streakExpiresAt or now<session.streakExpiresAt then return false end
    session.streak,session.streakMultiplier,session.streakExpiresAt=0,1,nil
    -- Random fragment visitors survive streak loss. Historical streak pickups do not.
    for index,item in pairs(session.avatarItems or {}) do if not item.familyId then session.avatarItems[index]=nil end end
    session.lastStreakActivity=nil
    Skill.retime(session,now)
    return true
end
function Skill.grade(check,now)
    if not finite(now) or now<check.startsAt then return nil end
    local delta=(Skill.phase(check,now)-check.target+180)%360-180
    local good,great=check.goodWidth or Skill.GOOD_WIDTH,check.greatWidth or Skill.GREAT_WIDTH
    local grace=math.min((check.grace or Skill.GRACE)/check.duration*360,great*0.75)
    if delta>=-great/2 and delta<=great/2+grace then return "Great",2 end
    if delta>=-good/2 and delta<=good/2+grace then return "Good",1.5 end
    return "Normal",1
end
function Skill.ensure(session,draft,now,choose,delay)
    if not finite(now) then return nil end
    if session.skillCheck and session.skillCheck.draftId==draft.id then return session.skillCheck end
    local target=choose(70,290)
    if not finite(target) or target%1~=0 or target<70 or target>290 then return nil end
    session.skillSequence=(session.skillSequence or 0)+1
    local duration,good,great=Skill.difficulty(session.streak or 0,session.skillSettings)
    local check={id=session.skillSequence,draftId=draft.id,startsAt=now+(delay or (session.skillSettings and session.skillSettings.initialDelay) or 0.25),
        duration=duration,goodWidth=good,greatWidth=great,target=target,streak=session.streak or 0,
        grace=session.skillSettings and session.skillSettings.grace or Skill.GRACE}
    local previous=session.phaseAnchor or session.skillCheck
    check.phaseOffset=previous and (Skill.phase(previous,now)+(check.startsAt-now)/duration*360)%360 or 0
    session.phaseAnchor=nil
    session.skillCheck=check
    return check
end
function Skill.wordsPerClick(streak,base,c)
    c=finite(c) and math.max(1,math.min(100,c)) or 5
    return math.max(1,math.min(4,base or 1))*(math.floor(math.max(0,math.min(Skill.MAX_STREAK,streak))/c)+1)
end
function Skill.click(session,draft,payload,now,_speed,choose)
    local check=session.skillCheck
    if not draft or payload.draftId~=draft.id or not check or payload.checkId~=check.id then return false,"stale_skill" end
    if type(payload.tokenIndex)~="number" or payload.tokenIndex%1~=0 or payload.tokenIndex<1
        or payload.tokenIndex>#draft.offers+1 then return false,"invalid_skill" end
    local full=payload.tokenIndex==#draft.offers+1
    if full then
        -- Only a completely server-awarded context can use the no-word check.
        -- Edits keep awards immutable; this never rewrites an existing word.
        for index=1,#draft.offers do
            if not (session.skillAwards and session.skillAwards[index]) then return false,"invalid_skill" end
        end
    end
    local grade,precision=Skill.grade(check,now)
    if not grade then return false,"skill_not_ready" end
    local streak=session.streak or 0
    if grade=="Normal" then streak=0
    else streak=math.min(session.streakCap or Skill.MAX_STREAK,streak+1) end
    local streakMultiplier=Skill.streakFactor(streak)
    -- Prepare the next challenge before mutating results; invalid randomness is atomic.
    local prepared={skillSequence=session.skillSequence,streak=streak,phaseAnchor=check,skillSettings=session.skillSettings}
    local nextCheck=Skill.ensure(prepared,draft,now,choose,session.skillSettings and session.skillSettings.skillCooldown or 0)
    if not nextCheck then return false,"invalid_skill" end
    -- A fresh challenge changes streak only. Agent generation owns all word
    -- awards; timing checks must never reserve or modify a token's reward.
    session.streak,session.streakMultiplier=streak,streakMultiplier
    Skill.refreshDeadline(session,now)
    session.bestStreak=math.max(session.bestStreak or 0,streak)
    session.lastSkillClick={draftId=draft.id,checkId=check.id,tokenIndex=payload.tokenIndex,
        grade=grade,multiplier=precision*streakMultiplier,streak=streak,streakMultiplier=streakMultiplier,
        reused=false,wordCount=0,
        streakBroken=grade=="Normal" and (check.streak or 0)>0}
    session.skillCheck,session.skillSequence=nextCheck,prepared.skillSequence
    return true,session.lastSkillClick
end
-- Automation is a distinct server operation, never a fabricated human grade.
-- One step per two seconds, no accumulated attempts, no tokens or collectible rolls.
function Skill.auto(session,draft,payload,now,cap,interval,choose)
    local check=session.skillCheck
    if not finite(now) or not finite(cap) or cap<1 then return false,"auto_locked" end
    if not draft or not check or payload.draftId~=draft.id or payload.checkId~=check.id then return false,"stale_skill" end
    if type(payload.tokenIndex)~="number" or payload.tokenIndex%1~=0 or payload.tokenIndex<1
        or payload.tokenIndex>#draft.offers+1 then return false,"invalid_skill" end
    if payload.tokenIndex==#draft.offers+1 then
        for index=1,#draft.offers do if not (session.skillAwards and session.skillAwards[index]) then return false,"invalid_skill" end end
    end
    if now<check.startsAt or now<(session.nextAutoSkillAt or 0) then return false,"skill_not_ready" end
    if (session.streak or 0)>cap then return false,"auto_cap" end
    local streak=math.min(cap,(session.streak or 0)+1)
    local prepared={skillSequence=session.skillSequence,streak=streak,phaseAnchor=check,skillSettings=session.skillSettings}
    local nextCheck=Skill.ensure(prepared,draft,now,choose,0)
    if not nextCheck then return false,"invalid_skill" end
    session.streak,session.streakMultiplier=streak,Skill.streakFactor(streak)
    session.bestStreak=math.max(session.bestStreak or 0,streak)
    session.nextAutoSkillAt=now+interval
    Skill.refreshDeadline(session,now)
    session.lastSkillClick={draftId=draft.id,checkId=check.id,tokenIndex=payload.tokenIndex,
        grade="Auto",automatic=true,multiplier=session.streakMultiplier,streak=streak,
        streakMultiplier=session.streakMultiplier,reused=false,wordCount=0,streakBroken=false}
    session.skillCheck,session.skillSequence=nextCheck,prepared.skillSequence
    return true,session.lastSkillClick
end
function Skill.view(session)
    local check=session.skillCheck
    if not check then return nil end
    local copy={draftId=check.draftId,id=check.id,startsAt=check.startsAt,duration=check.duration,
        phaseOffset=check.phaseOffset,initialRps=session.skillSettings and session.skillSettings.initialRps or 1/Skill.DURATION,
        growth=session.skillSettings and session.skillSettings.growth or 1.045,target=check.target,goodWidth=check.goodWidth,greatWidth=check.greatWidth,
        streak=session.streak or 0,bestStreak=session.bestStreak or 0,nextAutoSkillAt=session.nextAutoSkillAt,streakCap=session.streakCap,
        streakMultiplier=session.streakMultiplier or 1,awards={}}
    for index=1,128 do
        local award=session.skillAwards and session.skillAwards[index]
        if award then copy.awards[#copy.awards+1]={tokenIndex=index,grade=award.grade,multiplier=award.multiplier,
            precisionMultiplier=award.precisionMultiplier,streakMultiplier=award.streakMultiplier,streak=award.streak} end
    end
    if session.lastSkillClick then
        copy.lastClick={}
        for key,value in pairs(session.lastSkillClick) do copy.lastClick[key]=value end
    end
    return copy
end
return Skill

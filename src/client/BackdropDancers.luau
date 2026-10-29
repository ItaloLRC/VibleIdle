--!nonstrict
-- Streak celebration coordinator. Each pooled actor owns its visual lifecycle.
local Theme=require(script.Parent.DeskTheme)
local Avatar=require(script.Parent.StreakAvatar)
local UserInputService=game:GetService("UserInputService")
local Definitions=require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").StreakCollectibles)
local Music=require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Soundtrack)
local Dancers={};Dancers.__index=Dancers
Dancers.CAPACITY=Definitions.CAPACITY
Dancers.POPUP_SECONDS=.9
function Dancers.new(parent,terminal,desk)
    local self=setmetatable({terminal=terminal,desk=desk,pool={},cursor=0,spawnCount=0,random=Random.new()},Dancers)
    self.layer=Theme.create("Frame",parent,{Name="StreakAvatars",BackgroundTransparency=1,
        BorderSizePixel=0,Active=false,Selectable=false,ClipsDescendants=true,ZIndex=2,Size=UDim2.fromScale(1,1)})
    self.popups={};self.popupCursor=0;self.popupCount=0
    for index=1,Dancers.CAPACITY do
        local label=Theme.text(self.layer,"",18,Theme.colors.mint,UDim2.fromOffset(0,0),UDim2.fromOffset(240,32))
        label.Name="FragmentPopup"..index;label.ZIndex=8;label.Active=false;label.Selectable=false;label.Visible=false
        label.TextWrapped=false;label.TextXAlignment=Enum.TextXAlignment.Center
        local stroke=Theme.create("UIStroke",label,{Color=Color3.fromRGB(0,0,0),Thickness=2,ApplyStrokeMode=Enum.ApplyStrokeMode.Contextual})
        self.popups[index]={label=label,stroke=stroke,active=false}
    end
    for index=1,Dancers.CAPACITY do
        local avatar=Avatar.new(self.layer,index)
        avatar.onCollect=function(actor,input)
            if input and input.UserInputType~=self.pointerGestureType then self:collect(actor,input) end
        end
        self.pool[index]=avatar
    end
    self.pointerConnection=UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
        self.pointerGestureType=input.UserInputType
        if self.allowPointer and not self.allowPointer(input) then return end
        local avatar=self:avatarAt(input)
        if avatar then self:collect(avatar,input) end
    end)
    return self
end
function Dancers:showFragments(avatar,receipt)
    if not avatar.resource or avatar.collectionShown or receipt.id~=avatar.collectibleId or type(receipt.fragments)~="number"
        or receipt.fragments~=receipt.fragments or receipt.fragments%1~=0 or receipt.fragments<0 or receipt.fragments>1000000 then return end
    avatar.collectionShown=true
    self.popupCursor=self.popupCursor%Dancers.CAPACITY+1
    local slot=self.popups[self.popupCursor];local p,s=avatar.frame.AbsolutePosition,avatar.frame.AbsoluteSize
    local origin,size=self.layer.AbsolutePosition,self.layer.AbsoluteSize
    slot.x=(p.X+s.X/2-origin.X)/math.max(1,size.X);slot.y=(p.Y+s.Y/2-origin.Y)/math.max(1,size.Y)
    slot.age=0;slot.active=true;slot.id=receipt.id;slot.amount=receipt.fragments
    slot.label.Text=string.format("+%d fragments",receipt.fragments)
    self.popupCount=self.popupCount+1;self:placePopup(slot)
end
function Dancers:placePopup(slot)
    local size=self.layer.AbsoluteSize;local width=math.max(1,math.min(240,size.X-16));local height=32
    local fontSize=18
    while fontSize>12 and Theme.textWidth(slot.label.Text,fontSize)>width-8 do fontSize=fontSize-1 end
    slot.label.TextSize=fontSize
    local t=math.min(1,slot.age/Dancers.POPUP_SECONDS)
    local x=math.max(0,math.min(size.X-width,slot.x*size.X-width/2))
    local base=math.max(0,math.min(size.Y-height,slot.y*size.Y-height/2))
    local rise=self.reduced and 0 or math.min(40,base)*(1-(1-t)^2)
    slot.label.Position=UDim2.fromOffset(x,base-rise);slot.label.Size=UDim2.fromOffset(width,height)
    slot.label.TextTransparency=math.max(0,(t-.4)/.6)
    slot.stroke.Transparency=slot.label.TextTransparency
    slot.label.Visible=slot.active and self.terminal:canEdit()
end
function Dancers:choosePosition(avatar)
    avatar:setPosition(self.random:NextInteger(0,1000)/1000,self.random:NextInteger(0,1000)/1000)
end
function Dancers:loseStreak()
    for _,avatar in ipairs(self.pool) do if not avatar.resource then avatar:fadeOut() end end
end
function Dancers:confirmed(result)
    if result.streakBroken or result.streak==0 then self:loseStreak() end
end
function Dancers:avatarAt(input)
    if self.destroyed or not input or not input.Position or not self.terminal:canEdit() then return nil end
    for index=#self.pool,1,-1 do
        local avatar=self.pool[index];local p,size=avatar.frame.AbsolutePosition,avatar.frame.AbsoluteSize
        if avatar.active and avatar.frame.Visible and (avatar.alpha or 1)<0.98 and input.Position.X>=p.X and input.Position.X<p.X+size.X
            and input.Position.Y>=p.Y and input.Position.Y<p.Y+size.Y then return avatar end
    end
    return nil
end
function Dancers:blocksPointer(input) return self:avatarAt(input)~=nil end
function Dancers:collect(avatar,input)
    if self.destroyed or not input or (input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch)
        or not self.terminal:canEdit() or self.terminal.skillPending or not self.onCollect
        or not avatar.active or avatar.fading or avatar.pending or not avatar.collectibleId
        or (self.allowPointer and not self.allowPointer(input)) then return false end
    if self:avatarAt(input)~=avatar then return false end
    avatar.pending=true;avatar.pendingAge=0;avatar.syncAttempts=0;avatar.badge.Text="Checking..."
    self.onCollect({id=avatar.collectibleId});return true
end
function Dancers:update(data)
    if self.destroyed or not data.streakAvatars then return end
    self.pollSequence=math.max(self.pollSequence or 0,data.streakAvatars.pollSequence or 0)
    local checkId=data.skillCheck and data.skillCheck.id or 0
    if checkId<(self.lastCheckId or 0) then return end
    self.lastCheckId=checkId
    self.seen=self.seen or {}
    local live={}
    for _,item in ipairs(data.streakAvatars.items) do
        live[item.id]=true
        if item.id>(self.watermark or 0) and not self.seen[item.id] then
            self.seen[item.id]=true
            if item.familyId or self.terminal:canEdit() then
                local avatar
                for index,candidate in ipairs(self.pool) do
                    if not candidate.destroyed and not candidate.active then self.cursor=index;avatar=candidate;break end
                end
                if not avatar then for index,candidate in ipairs(self.pool) do
                    if candidate.fading then self.cursor=index;avatar=candidate;break end
                end end
                if avatar then
                    local source=not item.familyId and self.desk.agents[item.sourceAgent].mascot
                    avatar:activate({mascotId=item.mascotId or source.id,sourceAgent=item.sourceAgent,collectibleId=item.id,rank=item.rank,streak=item.streak,reward=item.reward,
                        familyId=item.familyId,familyName=item.familyName,rarity=item.rarity,fragments=item.fragments,
                        phaseOffset=self.random:NextInteger(0,1000)/1000*math.pi*2,width=self.random:NextInteger(12,20)*8,
                        x=item.x or self.random:NextInteger(0,1000)/1000,y=item.y or self.random:NextInteger(0,1000)/1000},self.reduced)
                    self.spawnCount=self.spawnCount+1
                end
            end
        end
    end
    -- Keep only live IDs in replay bookkeeping; monotonic watermark handles old snapshots.
    self.watermark=math.max(self.watermark or 0,data.streakAvatars.sequence)
    for id in pairs(self.seen) do if not live[id] then self.seen[id]=nil end end
    for _,avatar in ipairs(self.pool) do
        if avatar.active and avatar.collectibleId then
            if not live[avatar.collectibleId] then
                if data.lastAvatarCollect and data.lastAvatarCollect.id==avatar.collectibleId then
                    local receipt=data.lastAvatarCollect
                    if receipt.fragments then
                        self:showFragments(avatar,receipt);avatar.badge.Text=""
                    else avatar.badge.Text="+"..receipt.added.." STREAK" end
                end
                avatar.pending=false;avatar:fadeOut()
            elseif avatar.pending and (data.avatarRejected==avatar.collectibleId or data.avatarSyncId==avatar.collectibleId) then
                avatar.pending=false
                avatar.badge.Text=avatar.caption
            end
        end
    end
end
function Dancers:clear()
    for _,avatar in ipairs(self.pool) do avatar:hide() end
    for _,slot in ipairs(self.popups) do slot.active=false;slot.label.Visible=false end
end
function Dancers:setReducedMotion(value)
    self.reduced=value
    for _,avatar in ipairs(self.pool) do avatar:setReducedMotion(value) end
    for _,slot in ipairs(self.popups) do if slot.active then self:placePopup(slot) end end
end
function Dancers:tick(dt)
    if self.destroyed then return end
    local eligible=self.terminal:canEdit()
    for _,slot in ipairs(self.popups) do if slot.active then
        if eligible then slot.age=slot.age+math.max(0,math.min(.1,dt)) end
        if slot.age>=Dancers.POPUP_SECONDS then slot.active=false;slot.label.Visible=false else self:placePopup(slot) end
    end end
    if self.terminal:canEdit() and self.onPoll then
        self.pollAge=(self.pollAge or 0)+math.max(0,math.min(dt,1))
        if self.pollAge>=1 then
            self.pollAge=0;self.pollSequence=(self.pollSequence or 0)+1
            self.onPoll({requestId=self.pollSequence})
        end
    else self.pollAge=0 end
    local streak=self.desk.data and self.desk.data.stats and self.desk.data.stats.streak or self.lastStreak or 0
    if (self.lastStreak or 0)>0 and streak==0 then self:loseStreak() end
    self.lastStreak=streak
    local tuning=self.terminal.tuning or {}
    local bpm=Music.tempo(Music.tier(streak,self.terminal.streakDivisor))*(tuning.musicScale or 1)*(tuning.danceScale or 1)
    local animate=self.terminal:canEdit() and not self.reduced
    for _,avatar in ipairs(self.pool) do
        avatar.fadeInSeconds,avatar.fadeOutSeconds=tuning.avatarFadeIn,tuning.avatarFadeOut
        if avatar.pending then
            avatar.pendingAge=avatar.pendingAge+math.max(0,dt)
            if avatar.pendingAge>=(tuning.grantTimeout or 12) then
                avatar.pending=false
                avatar.badge.Text=avatar.caption
            elseif avatar.syncAttempts<3 and avatar.pendingAge>=(tuning.syncDelay or 3)*(avatar.syncAttempts+1) and self.onSync then
                avatar.syncAttempts=avatar.syncAttempts+1;self.onSync({id=avatar.collectibleId})
            end
        end
        avatar.frame.Visible=avatar.active and not self.terminal.suspended
        avatar:tick(dt,avatar.resource and 5 or streak,avatar.resource and 88 or bpm,animate,self.reduced)
        avatar.button.Active=avatar.active and (avatar.alpha or 1)<0.98 and self.terminal:canEdit()
    end
end
function Dancers:destroy()
    if self.destroyed then return end
    self.destroyed=true;self.pointerConnection:Disconnect()
    for _,avatar in ipairs(self.pool) do avatar:destroy() end
    self.layer:Destroy()
end
return Dancers

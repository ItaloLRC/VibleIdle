--!nonstrict
local Workspace=game:GetService("Workspace")
local UserInputService=game:GetService("UserInputService")
local Theme=require(script.Parent.DeskTheme)
local PixelDial=require(script.Parent.PixelSkillDial)
local Skill=require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").SkillCheck)
local c=Theme.colors
local Controller={}
Controller.__index=Controller
local function counterShadow(parent,source,name)
    local shadow=Theme.text(parent,source.Text,source.TextSize,Color3.fromRGB(8,6,15),
        UDim2.new(source.Position.X.Scale,source.Position.X.Offset+3,source.Position.Y.Scale,source.Position.Y.Offset+4),source.Size)
    shadow.Name=name;shadow.ZIndex=2;shadow.TextTransparency=0.15
    shadow.TextScaled=true;shadow.TextXAlignment=Enum.TextXAlignment.Center
    shadow.Active=false;shadow.Selectable=false
    Theme.create("UITextSizeConstraint",shadow,{MinTextSize=12,MaxTextSize=96})
    return shadow
end
function Controller.new(parent,terminal,submit,sync)
    local self=setmetatable({terminal=terminal,submit=submit,sync=sync,segments={},seen=0},Controller)
    self.layer=Theme.create("Frame",parent,{Name="SkillCheckLayer",BackgroundTransparency=1,
        BorderSizePixel=0,Active=false,ZIndex=20,Size=UDim2.new(1,0,0,148),Position=UDim2.new(0,0,1,-192)})
    self.button=Theme.create("TextButton",self.layer,{Name="SkillCircle",Text="",BorderSizePixel=0,
        BackgroundColor3=c.terminal,BackgroundTransparency=1,AutoButtonColor=false,Selectable=false,ZIndex=2,
        AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,4),Size=UDim2.fromOffset(120,120)})
    self.dial=PixelDial.new(self.button)
    self.segments,self.pivot=self.dial.segments,self.dial.pivot
    self.label=Theme.text(self.dial.capRoot,"CLICK",12,c.ink,UDim2.fromScale(0.14,0.39),UDim2.fromScale(0.72,0.22))
    self.label.BackgroundTransparency,self.label.BackgroundColor3,self.label.ZIndex=1,c.terminal,3
    self.label.TextXAlignment=Enum.TextXAlignment.Center
    self.label.Active=false;self.label.Selectable=false
    self.capLabel=Theme.text(self.layer,"MAX STREAK 5",10,c.amber,UDim2.new(.5,-144,0,128),UDim2.fromOffset(288,16))
    self.capLabel.TextXAlignment=Enum.TextXAlignment.Center;self.capLabel.Active=false;self.capLabel.Selectable=false
    self.dial.label=self.label
    self.streakLabel=Theme.text(self.layer,"0",60,c.mint,UDim2.fromOffset(0,4),UDim2.fromOffset(120,120))
    self.streakLabel.Name,self.streakLabel.ZIndex="Streak",3
    self.streakLabel.BackgroundTransparency=1
    self.streakLabel.TextScaled=true
    self.streakLabel.Active=true
    Theme.create("UITextSizeConstraint",self.streakLabel,{MinTextSize=12,MaxTextSize=96})
    self.tpcLabel=Theme.text(self.layer,"1",60,c.amber,UDim2.fromOffset(0,4),UDim2.fromOffset(120,120))
    self.tpcLabel.Name,self.tpcLabel.ZIndex="TPC",3
    self.tpcLabel.BackgroundTransparency=1;self.tpcLabel.TextScaled=true;self.tpcLabel.Active=true
    self.tpcLabel.TextXAlignment=Enum.TextXAlignment.Center
    Theme.create("UITextSizeConstraint",self.tpcLabel,{MinTextSize=12,MaxTextSize=96})
    self.streakLabel.TextXAlignment=Enum.TextXAlignment.Center
    self.streakShadow=counterShadow(self.layer,self.streakLabel,"StreakShadow")
    self.tpcShadow=counterShadow(self.layer,self.tpcLabel,"TPCShadow")
    self.pointerConnection=UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
        -- Physical press owns this gesture even if readiness rejects it. The
        -- later release must never become another attempt on a newer challenge.
        self.pointerGestureType=input.UserInputType
        if self.layer.Visible and self:containsCircle(input) then self:press(input) end
    end)
    self.button.Activated:Connect(function(input)
        -- Fallback for activations without a tracked physical pointer gesture.
        if input and input.UserInputType~=self.pointerGestureType then self:press(input) end
    end)
    self:render();return self
end
function Controller:containsCircle(input)
    if not input or not input.Position then return false end
    local p,s=self.button.AbsolutePosition,self.button.AbsoluteSize
    if s.X<=0 or s.Y<=0 then return false end
    local dx,dy=(input.Position.X-p.X)/s.X-0.5,(input.Position.Y-p.Y)/s.Y-0.5
    return dx*dx+dy*dy<=0.25
end
function Controller:eligible()
    local t=self.terminal
    return not self.destroyed and not self.suspended and (not t.tutorialActive or t.tutorialStep=="Skill") and t:canEdit() and t.composer.draft and self.check
        and not t.agentPending and not t.composer.flight and not t.sendRequested
        and t.composer.count<=t.limit
        and self.check.draftId==t.composer.draft.id
end
function Controller:press(input,freeSpace)
    if not input or (input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch) then return false end
    if not self.layer.Visible or not self.terminal:canEdit() then return false end
    if freeSpace then
        if not self.allowFreeSpace or not self.allowFreeSpace(input) then return false end
    else
        if not self:containsCircle(input) or (self.allowCircle and not self.allowCircle(input)) then return false end
    end
    if not self.reduced then self.pressAge=0;self.dial:setPress(1) end
    if not self:eligible() or self.pending or Workspace:GetServerTimeNow()<self.check.startsAt then return false end
    local t=self.terminal
    self.pending={draftId=t.composer.draft.id,checkId=self.check.id,
        tokenIndex=t.composer.count+1,age=0}
    t.skillPending=true;t:refreshControls();self:render()
    if self.onPress then self.onPress() end
    self.submit({draftId=self.pending.draftId,checkId=self.pending.checkId,tokenIndex=self.pending.tokenIndex})
    return true
end
function Controller:update(data)
    self.autoCap=data.progression and data.progression.autoSkillCap or 0
    self.streakCap=data.progression and data.progression.streakCap or 5
    self.serverAutoAt=data.skillCheck and data.skillCheck.nextAutoSkillAt or 0
    local check=data.skillCheck
    local t=self.terminal
    if not check or not t.composer.draft or check.draftId~=t.composer.draft.id then return end
    if self.check and check.id<self.check.id then return end
    self.streak,self.streakMultiplier=check.streak or 0,check.streakMultiplier or 1
    if not self.check or self.check.id~=check.id or self.check.goodWidth~=check.goodWidth
        or self.check.greatWidth~=check.greatWidth or self.check.duration~=check.duration then
        self.check=check
        for index,segment in ipairs(self.segments) do
            local delta=math.abs(((index-1)*4-check.target+180)%360-180)
            segment.BackgroundColor3=delta<=check.greatWidth/2 and c.amber or delta<=check.goodWidth/2 and c.mint or c.line
        end
    end
    for _,award in ipairs(check.awards) do
        local offer=t.composer.draft.offers[award.tokenIndex]
        if offer and offer.skillMultiplier~=award.multiplier then
            offer.skillMultiplier,offer.skillGrade=award.multiplier,award.grade
            offer.streakMultiplier,offer.streakAtHit=award.streakMultiplier,award.streak;t.tokenStamp=nil
        end
    end
    local pending=self.pending
    local result=check.lastClick
    if pending then
        if result and result.checkId==pending.checkId and result.draftId==pending.draftId
            and result.tokenIndex==pending.tokenIndex and result.checkId>self.seen then
            self.seen=result.checkId;self.pending=nil;t.skillPending=false
            -- Confirmation drives streak feedback only; agent receipts write tokens.
            if self.onConfirmed and not result.automatic then self.onConfirmed(result) end
        elseif data.skillRejected==pending.checkId or (pending.syncRequested and data.skillSyncId==pending.checkId) then
            self.pending=nil;t.skillPending=false
        elseif pending.draftId~=check.draftId then
            self.pending=nil;t.skillPending=false
        end
    end
    t:refreshInput();self:render()
    -- After a manual reconciliation, service a due agent once. Agent replies
    -- return control to input until the normal tick instead of chaining requests.
    if pending and not self.pending then t:tickAgents(0) end
end
function Controller:render()
    self.layer.Visible=not self.suspended and not self.terminal.blocked
        and self.terminal:canEdit() and self.terminal.composer.draft~=nil
    if not self.layer.Visible or self.reduced then self.pressAge=nil;self.dial:setPress(0) end
    local enabled=self:eligible() and not self.pending
    local ready=enabled and Workspace:GetServerTimeNow()>=self.check.startsAt
    -- Do not invalidate native hover/hit state on every request/acknowledgement.
    self.button.Active=true
    self.button:SetAttribute("Ready",ready==true)
    self.label.Text=self.pending and "..." or "CLICK"
    self.capLabel.Text="MAX STREAK "..tostring(self.streakCap or 5)..((self.autoCap or 0)>0 and " / AUTO" or "")
    self.streakLabel.Text=tostring(self.streak or 0).."x"
    self.tpcLabel.Text=tostring(Skill.wordsPerClick(self.streak or 0,self.terminal.baseWords or 1,self.terminal.streakDivisor))
    self.streakShadow.Text=self.streakLabel.Text
    self.tpcShadow.Text=self.tpcLabel.Text
    if self.check then self.dial:setPhase(Skill.phase(self.check,Workspace:GetServerTimeNow())) end
end
function Controller:tickAuto()
    local t=self.terminal
    local now=Workspace:GetServerTimeNow()
    if not self.autoSubmit or t.tutorialActive or (self.autoCap or 0)<1 or self.destroyed or not t:canAutomate()
        or not t.composer.draft or not self.check or self.check.draftId~=t.composer.draft.id
        or self.pending or t.agentPending or t.composer.flight or t.saleFlight or t.sendRequested or t:isCollecting()
        or now<math.max(self.nextAutoAt or 0,self.serverAutoAt or 0,self.check.startsAt)
        or (self.streak or 0)>self.autoCap then return end
    self.nextAutoAt=now+2
    self.pending={draftId=t.composer.draft.id,checkId=self.check.id,tokenIndex=t.composer.count+1,age=0,automatic=true}
    t.skillPending=true;t:refreshControls()
    self.autoSubmit({draftId=self.pending.draftId,checkId=self.pending.checkId,tokenIndex=self.pending.tokenIndex})
end
function Controller:tick(dt)
    self:tickAuto()
    if self.pressAge then
        self.pressAge=self.pressAge+math.max(0,dt)
        local duration=self.terminal.tuning and self.terminal.tuning.buttonReturn or 0.14
        local progress=math.min(1,self.pressAge/duration)
        self.dial:setPress((1-progress)^2)
        if progress==1 then self.pressAge=nil end
    end
    if self.pending then
        self.pending.age=self.pending.age+dt
        if self.pending.age>=(self.terminal.tuning and self.terminal.tuning.syncDelay or 3) and not self.pending.syncRequested then
            self.pending.syncRequested=true
            self.sync({draftId=self.pending.draftId,checkId=self.pending.checkId,tokenIndex=self.pending.tokenIndex}) -- Read only.
        end
    end
    self:render()
end
function Controller:layout(reserve,diameter)
    self.layer.Position,self.layer.Size=UDim2.new(0,0,1,-44-reserve),UDim2.new(1,0,0,reserve)
    self.button.Size=UDim2.fromOffset(diameter,diameter)
    self.capLabel.Position=UDim2.new(.5,-144,0,diameter+6)
    self.dial:layout(diameter)
    self.streakLabel.Position=UDim2.new(0.5,diameter/2+8,0,4)
    self.streakLabel.Size=UDim2.fromOffset(diameter,diameter)
    self.tpcLabel.Position=UDim2.new(0.5,-diameter*1.5-8,0,4)
    self.tpcLabel.Size=UDim2.fromOffset(diameter,diameter)
    for _,pair in ipairs({{self.streakLabel,self.streakShadow},{self.tpcLabel,self.tpcShadow}}) do
        local source,shadow=pair[1],pair[2]
        shadow.Position=UDim2.new(source.Position.X.Scale,source.Position.X.Offset+3,source.Position.Y.Scale,source.Position.Y.Offset+4)
        shadow.Size=source.Size
    end
end
function Controller:blocksPointer(input)
    if not self.layer.Visible or not input then return false end
    if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return false end
    for _,object in ipairs({self.button,self.streakLabel,self.tpcLabel}) do
        local p,s=object.AbsolutePosition,object.AbsoluteSize
        if input.Position.X>=p.X and input.Position.X<p.X+s.X
            and input.Position.Y>=p.Y and input.Position.Y<p.Y+s.Y then return true end
    end
    return false
end
function Controller:setSuspended(value) self.suspended=value;self:render() end
function Controller:setReducedMotion(value)
    self.reduced=value
    if value then self.pressAge=nil;self.dial:setPress(0) end
end
function Controller:destroy()
    if self.destroyed then return end
    self.destroyed=true;self.pointerConnection:Disconnect();self.layer:Destroy()
end
return Controller

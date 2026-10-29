--!nonstrict
-- One passive spotlight and pixel dialogue, advanced by matching real receipts.
-- Ticked by the existing terminal heartbeat; owns no reward, timer or input listener.
local Theme=require(script.Parent.DeskTheme)
local Gui=game:GetService("GuiService")
local Input=game:GetService("UserInputService")
local c=Theme.colors
local Tour={};Tour.__index=Tour
local function contains(frame,input)
    if not input or not input.Position then return true end
    local p,s=frame.AbsolutePosition,frame.AbsoluteSize
    return input.Position.X>=p.X and input.Position.X<p.X+s.X and input.Position.Y>=p.Y and input.Position.Y<p.Y+s.Y
end
local function rect(frame,origin,padding)
    local p,s=frame.AbsolutePosition,frame.AbsoluteSize
    return {x=p.X-origin.X-padding,y=p.Y-origin.Y-padding,w=s.X+padding*2,h=s.Y+padding*2}
end
local function bounds(value,w,h)
    local x,y=math.max(0,value.x),math.max(0,value.y)
    return {x=x,y=y,w=math.max(0,math.min(w,value.x+value.w)-x),h=math.max(0,math.min(h,value.y+value.h)-y)}
end
function Tour.new(parent,terminal,options)
    local self=setmetatable({terminal=terminal,options=options,mode="Start",step=nil,age=0,sequence=0},Tour)
    self.gui=Theme.create("ScreenGui",parent,{Name="VibeIdleOnboarding",ResetOnSpawn=false,
        ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,DisplayOrder=24,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    self.root=Theme.create("Frame",self.gui,{Name="OnboardingRoot",BackgroundTransparency=1,BorderSizePixel=0,
        Active=false,ClipsDescendants=true,Size=UDim2.fromScale(1,1)})
    self.masks={}
    for index=1,4 do self.masks[index]=Theme.create("TextButton",self.root,{Name="GreyMask"..index,Text="",AutoButtonColor=false,
        BackgroundColor3=Color3.fromRGB(63,63,70),BackgroundTransparency=.28,BorderSizePixel=0,Active=true,Selectable=false,ZIndex=1}) end
    self.outline={}
    for index=1,4 do self.outline[index]=Theme.create("Frame",self.root,{Name="SpotlightEdge"..index,BackgroundColor3=c.mint,
        BorderSizePixel=0,Active=false,Selectable=false,ZIndex=2}) end
    self.menu=Theme.create("Frame",self.root,{Name="StartMenu",BackgroundTransparency=1,BorderSizePixel=0,ZIndex=4})
    Theme.pixelPanel(self.menu,"MenuPanel",UDim2.fromOffset(0,0),UDim2.fromScale(1,1),c.panel)
    self.brand=Theme.text(self.menu,"VIBE IDLE",24,c.mint,UDim2.fromOffset(16,12),UDim2.new(1,-32,0,36));self.brand.ZIndex=5
    self.menuBody=Theme.create("ScrollingFrame",self.menu,{Name="WelcomeContent",BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.fromOffset(16,56),Size=UDim2.new(1,-32,1,-180),CanvasSize=UDim2.fromOffset(0,232),
        ScrollingDirection=Enum.ScrollingDirection.Y,ClipsDescendants=true,ScrollBarThickness=4,ZIndex=5})
    self.welcome=Theme.text(self.menuBody,"BUILD YOUR AGENT EMPIRE.\nHit skill checks. Sell tokens.\nCollect visitors and craft cards.",14,c.text,
        UDim2.fromOffset(4,0),UDim2.new(1,-12,0,100));self.welcome.ZIndex=5
    self.status=Theme.text(self.menuBody,"Opening your progress...",14,c.amber,UDim2.fromOffset(4,112),UDim2.new(1,-12,0,112));self.status.ZIndex=5
    self.play,self.playArt=Theme.pixelButton(self.menu,"LOADING...",UDim2.new(0,16,1,-108),UDim2.new(1,-32,0,40),function(input)
        if not self:canUse(self.play,input) then return end
        if self.ready then self:start(not self.data.tutorialDone) elseif self.age>=14 and self.options.reconnect then self.options.reconnect() end
    end)
    self.play.Name="Play";self.play.ZIndex=6;self.playArt.label.TextSize=14
    self.learn,self.learnArt=Theme.pixelButton(self.menu,"HOW TO PLAY",UDim2.new(0,16,1,-60),UDim2.new(1,-32,0,40),function(input)
        if self.ready and self:canUse(self.learn,input) then self:start(true) end
    end)
    self.learn.Name="Learn";self.learn.ZIndex=6;self.learnArt.label.TextSize=14
    self.dialog=Theme.create("Frame",self.root,{Name="TutorialDialogue",BackgroundTransparency=1,BorderSizePixel=0,ZIndex=4})
    Theme.pixelPanel(self.dialog,"DialoguePanel",UDim2.fromOffset(0,0),UDim2.fromScale(1,1),c.panel)
    self.title=Theme.text(self.dialog,"01 / SKILL CHECK",16,c.amber,UDim2.fromOffset(12,8),UDim2.new(1,-24,0,32));self.title.ZIndex=5
    self.copy=Theme.text(self.dialog,"",14,c.text,UDim2.fromOffset(12,44),UDim2.new(1,-24,1,-104));self.copy.ZIndex=5
    self.skip,self.skipArt=Theme.pixelButton(self.dialog,"SKIP TUTORIAL",UDim2.new(0,12,1,-52),UDim2.new(1,-24,0,40),function(input)
        if self:canUse(self.skip,input) then self:finish() end
    end)
    self.skip.Name="SkipTutorial";self.skip.ZIndex=6;self.skipArt.label.TextSize=14
    self:apply();self:layout()
    return self
end
function Tour:canUse(target,input)
    local t=self.terminal
    local focused=Input:GetFocusedTextBox()
    return not self.destroyed and not t.uiTransition and self.mode~="Hidden" and target.Visible~=false and t.windowFocused and not Gui.MenuIsOpen
        and not t:hasModifier() and (not focused or focused==t.input) and contains(target,input)
        and ((target==self.play or target==self.learn) and self.mode=="Start" or target==self.skip and self.mode=="Tutorial")
end
function Tour:blocks() return not self.destroyed and self.mode~="Hidden" end
function Tour:allows(kind,input)
    if self.terminal.uiTransition then return false end
    if not self:blocks() then return true end
    if self.mode~="Tutorial" or self.step~=kind or not self.ready then return false end
    if input and input.Position then
        if contains(self.dialog,input) or not self.hole then return false end
        local p=self.root.AbsolutePosition;local x,y=input.Position.X-p.X,input.Position.Y-p.Y
        local r=self.hole
        return x>=r.x and x<r.x+r.w and y>=r.y and y<r.y+r.h
    end
    return true
end
function Tour:apply()
    local t=self.terminal
    t.onboardingPaused=self.mode=="Start" or self.step=="Done"
    t.tutorialActive=self.mode=="Tutorial";t.tutorialStep=self.step
    self.options.skill:setSuspended(self.mode=="Start" or (self.mode=="Tutorial" and self.step~="Skill"))
    self.root.Visible=self.mode~="Hidden"
    self.menu.Visible=self.mode=="Start";self.dialog.Visible=self.mode=="Tutorial"
    self.root:SetAttribute("Mode",self.mode);self.root:SetAttribute("Step",self.step or "")
    if self.options.onState then self.options.onState(self:blocks()) end
    t:refreshControls()
end
function Tour:releaseVisitor()
    if self.actor then self.actor.button.Selectable=false end
    if self.actor and self.actor.active and self.actor.collectibleId==self.actorId then self.actor:setPosition(self.oldX,self.oldY) end
    self.actor,self.actorId=nil,nil
end
function Tour:start(tutorial,immediate)
    local t=self.terminal
    if not self.ready or t.composer.flight or t.agentPending or t.skillPending or t.progressionPending or t.billingBusy then return false end
    if not immediate and self.options.motion then return self.options.motion:begin(function() self:start(tutorial,true) end) end
    self:releaseVisitor();t:blur()
    self.mode=tutorial and "Tutorial" or "Hidden";self.step=tutorial and "Skill" or nil
    self.expectedVisitor=nil
    if self.options.onStart then self.options.onStart() end
    self:apply();self:layout();self:focus()
    return true
end
function Tour:finish(immediate)
    if self.mode~="Tutorial" then return end
    if not immediate and self.options.motion then return self.options.motion:begin(function() self:finish(true) end) end
    self:releaseVisitor();self.mode,self.step="Hidden",nil;self:apply()
    self.sequence=self.sequence+1
    if self.options.onComplete then self.options.onComplete({requestId=self.sequence}) end
    if self.options.onExit then self.options.onExit() end
end
function Tour:focus()
    if not Input.GamepadEnabled and not Gui.SelectedObject and not (self.options.motion and self.options.motion:busy()) then return end
    if self.options.motion and self.options.motion:busy() then
        local target=self.mode=="Start" and self.play or self.step=="Sell" and self.terminal.send or self.step=="Visitor" and self.actor and self.actor.button or self.skip
        self.options.motion.nextFocus=target;return
    end
    if self.mode=="Start" then Gui.SelectedObject=self.ready and self.play or nil
    elseif self.step=="Skill" then Gui.SelectedObject=self.skip
    elseif self.step=="Sell" then Gui.SelectedObject=self.terminal.send
    elseif self.step=="Visitor" then Gui.SelectedObject=self.actor and self.actor.button or self.skip
    elseif self.step=="Done" then Gui.SelectedObject=self.skip end
end
function Tour:advance(step,immediate)
    if not immediate and self.options.motion then return self.options.motion:begin(function() self:advance(step,true) end) end
    self.step=step;self.expectedVisitor=nil;self:apply();self:layout();self:focus()
end
function Tour:confirmedSkill(result)
    if self.mode=="Tutorial" and self.step=="Skill" and not result.automatic and (result.grade=="Good" or result.grade=="Great") then self:advance("Sell") end
end
function Tour:confirmedSale(receipt)
    if self.mode=="Tutorial" and self.step=="Sell" and receipt then self:advance("Visitor") end
end
function Tour:pressedVisitor(id)
    if self.mode=="Tutorial" and self.step=="Visitor" and self.actorId==id then self.expectedVisitor=id end
end
function Tour:update(data)
    if self.destroyed then return end
    self.data=data
    local wasReady=self.ready
    self.ready=data~=nil and not data.blocked and self.terminal.composer.draft~=nil and not self.terminal.blocked
    if self.mode=="Tutorial" and self.step=="Visitor" and self.expectedVisitor and data and data.lastAvatarCollect
        and data.lastAvatarCollect.id==self.expectedVisitor and data.lastAvatarCollect.fragments~=nil then
        self:releaseVisitor();self:advance("Done")
    end
    if self.ready and not wasReady then self:focus() end
    self:layout()
end
function Tour:target()
    if self.step=="Skill" then return self.options.skill.button end
    if self.step=="Sell" then
        local target=self.terminal.send;local desktop=self.options.desktop
        local p,s=target.AbsolutePosition,target.AbsoluteSize;local origin,size=desktop.AbsolutePosition,desktop.AbsoluteSize
        local previous=desktop.CanvasPosition
        local x=previous.X+math.max(0,p.X+s.X-origin.X-size.X+8)+math.min(0,p.X-origin.X-8)
        local y=previous.Y+math.max(0,p.Y+s.Y-origin.Y-size.Y+8)+math.min(0,p.Y-origin.Y-8)
        desktop.CanvasPosition=Vector2.new(math.max(0,x),math.max(0,y))
        return target
    end
    if self.step=="Visitor" then
        if self.actor and (not self.actor.active or self.actor.fading or self.actor.collectibleId~=self.actorId) then self:releaseVisitor() end
        if not self.actor then
            for _,actor in ipairs(self.options.dancers.pool) do
                if actor.active and actor.resource and not actor.fading then
                    self.actor,self.actorId=actor,actor.collectibleId;self.oldX,self.oldY=actor.x,actor.y
                    -- Move only this real actor's cosmetic position to clear the text.
                    actor:setPosition(.5,.96);break
                end
            end
            if self.actor then self:focus() end
        end
        if self.actor then self.actor.button.Selectable=true;return self.actor.button end
    end
end
function Tour:layout()
    if self.destroyed then return end
    local size,origin=self.root.AbsoluteSize,self.root.AbsolutePosition
    local w,h=math.max(1,size.X),math.max(1,size.Y)
    if self.options.viewport then
        w,h=self.options.viewport.AbsoluteSize.X,self.options.viewport.AbsoluteSize.Y
        self.root.Size=UDim2.fromOffset(w,h)
    end
    if self.mode=="Tutorial" and self.step=="Skill" then
        local skill=self.options.skill
        local diameter=math.min(h<500 and 84 or 120,math.floor((w-32)/3))
        skill.layer.Parent.Size=UDim2.fromOffset(w,h)
        skill:layout(diameter+20,diameter)
        skill.layer.Position=UDim2.fromOffset(0,h-diameter-16)
    end
    local target=self.mode=="Tutorial" and self.ready and self:target()
    local hole=target and bounds(rect(target,origin,8),w,h) or nil
    if hole and (hole.w<=0 or hole.h<=0) then hole=nil end
    self.hole=hole
    local r=hole or {x=0,y=0,w=0,h=0}
    local boxes=hole and {{0,0,w,r.y},{0,r.y+r.h,w,h-r.y-r.h},{0,r.y,r.x,r.h},{r.x+r.w,r.y,w-r.x-r.w,r.h}} or {{0,0,w,h},{0,0,0,0},{0,0,0,0},{0,0,0,0}}
    local edges={{r.x,r.y,r.w,3},{r.x,r.y+r.h-3,r.w,3},{r.x,r.y,3,r.h},{r.x+r.w-3,r.y,3,r.h}}
    for index,mask in ipairs(self.masks) do
        local b=boxes[index];mask.Position,mask.Size=UDim2.fromOffset(b[1],b[2]),UDim2.fromOffset(math.max(0,b[3]),math.max(0,b[4]))
        local e=edges[index];self.outline[index].Position,self.outline[index].Size=UDim2.fromOffset(e[1],e[2]),UDim2.fromOffset(math.max(0,e[3]),math.max(0,e[4]))
        self.outline[index].Visible=hole~=nil
    end
    local menuW,menuH=math.min(640,w-24),math.min(440,h-24)
    self.menu.Position,self.menu.Size=UDim2.fromOffset(math.floor((w-menuW)/2),math.floor((h-menuH)/2)),UDim2.fromOffset(menuW,menuH)
    self.playArt.label.Text=self.ready and (self.data.tutorialDone and "CONTINUE" or "START") or (self.age>=14 and "RECONNECT" or "LOADING...")
    self.play.Text=self.playArt.label.Text;self.play.Active=self.ready or self.age>=14;self.play.Selectable=self.play.Active
    self.learn.Active,self.learn.Selectable=self.ready,self.ready
    if not self.ready then self.status.Text=self.error or (self.age>=14 and "Progress is unavailable. Use RECONNECT. No purchase or sale will be replayed." or "Opening your saved progress...")
    elseif self.data.storageMode=="MEMORY" then self.status.Text="TEST SESSION\nProgress is not saved between visits. Published games use cloud saving."
    elseif self.data.persistence and self.data.persistence.status=="delayed" then self.status.Text="SAVE DELAYED\nYour session is open. Cloud saving will retry; please stay connected."
    else self.status.Text="CLOUD SAVE ON\nProgress autosaves and saves when you leave. Unsold tokens and streak are session-only." end
    local dialogW=math.min(560,w-24)
    local dialogH=math.min(224,math.max(180,h-(hole and hole.h or 0)-40))
    local x,y=math.floor((w-dialogW)/2),12
    if hole and r.y>=dialogH+24 then y=math.min(h-dialogH-12,r.y-dialogH-12)
    elseif hole and h-r.y-r.h>=dialogH+24 then y=r.y+r.h+12
    elseif hole and w-r.x-r.w>=dialogW+24 then x=r.x+r.w+12 end
    self.dialog.Position,self.dialog.Size=UDim2.fromOffset(x,y),UDim2.fromOffset(dialogW,dialogH)
    if not self.ready then self.title.Text="CONNECTION PAUSED";self.copy.Text="Waiting for your session. Skip to play and use Guide > Reconnect."
    elseif self.step=="Skill" then self.title.Text="01 / SKILL CHECK";self.copy.Text="Click the circle when red hits green or gold. A confirmed hit boosts your agents. Try it!"
    elseif self.step=="Sell" then self.title.Text="02 / SELL TOKENS";self.copy.Text="Agents write tokens. Wait for one, then press SELL or Enter to earn money. Tokens: "..tostring(self.terminal.composer.count)
    elseif self.step=="Visitor" then self.title.Text="03 / COLLECT";self.copy.Text=target and "Click this visiting agent for fragments. Craft cards in Agent Lab, then equip them in Cards." or "Watch for a random visitor (5-10 active seconds). Click it for fragments to craft agent cards."
    else self.title.Text="YOU ARE READY!";self.copy.Text="Hit. Sell. Collect. Buy upgrades, craft cards, then prestige for permanent Chips. Replay this tour in Guide." end
    self.skipArt.label.Text=self.step=="Done" and "LET'S PLAY" or "SKIP TUTORIAL";self.skip.Text=self.skipArt.label.Text
end
function Tour:tick(dt)
    if self.destroyed then return end
    self.age=self.age+math.max(0,dt)
    if self:blocks() then self:layout() end
end
function Tour:destroy()
    if self.destroyed then return end
    self:releaseVisitor();self.destroyed=true;self.mode="Hidden";self.step=nil
    self.terminal.onboardingPaused=false;self.terminal.tutorialActive=false;self.terminal.tutorialStep=nil
    if Gui.SelectedObject and Gui.SelectedObject:IsDescendantOf(self.gui) then Gui.SelectedObject=nil end
    self.gui:Destroy()
end
return Tour

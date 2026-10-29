--!nonstrict
-- Independent visual actor. Collection is delegated; this object never grants rewards.
local Mascot=require(script.Parent.AgentMascot)
local Theme=require(script.Parent.DeskTheme)
local Rarities=require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").StreakCollectibles).RARITIES
local Avatar={};Avatar.__index=Avatar
Avatar.FADE_SECONDS=0.65

function Avatar.new(parent,id)
    local self=setmetatable({id=id,parent=parent,active=false,x=0,y=0,width=128},Avatar)
    self.mascot=Mascot.new(parent)
    self.frame=self.mascot.frame
    self.frame.Name="StreakAvatar"..id
    self.frame:SetAttribute("StreakAvatarId",id)
    self.frame.Visible=false
    self.frame.ZIndex=3;self.mascot.motion.ZIndex=3;self.mascot.canvas.ZIndex=3
    self:setAppearance(self.mascot.id)
    self.button=Theme.create("TextButton",self.frame,{Name="CollectAvatar",Text="",BackgroundTransparency=1,
        BorderSizePixel=0,AutoButtonColor=false,Active=false,Selectable=false,ZIndex=4,Size=UDim2.fromScale(1,1)})
    self.badge=Theme.text(self.button,"",9,Theme.colors.text,UDim2.new(0,0,1,-16),UDim2.new(1,0,0,16))
    self.badge.Name="Rarity";self.badge.ZIndex=5;self.badge.TextScaled=true
    self.badge.TextXAlignment=Enum.TextXAlignment.Center
    self.badge.BackgroundColor3=Theme.colors.terminal;self.badge.BackgroundTransparency=0.3
    self.button.Activated:Connect(function(input) if self.onCollect then self.onCollect(self,input) end end)
    return self
end

function Avatar:setAppearance(mascotId)
    if self.destroyed or not self.mascot:setMascot(mascotId) then return false end
    -- Newly added artwork parts inherit this actor's opacity and foreground layer.
    for _,part in ipairs(self.mascot.parts) do
        part.BackgroundTransparency=self.alpha or 1;part.ZIndex=3
        if self.rank and not self.resource then part.BackgroundColor3=Theme.rarity[Rarities[self.rank].name] end
    end
    return true
end

function Avatar:setOpacity(alpha)
    if self.destroyed then return end
    alpha=math.max(0,math.min(1,alpha))
    if self.alpha and math.abs(self.alpha-alpha)<0.005 then return end
    self.alpha=alpha
    for _,part in ipairs(self.mascot.parts) do part.BackgroundTransparency=alpha end
    if self.badge then self.badge.TextTransparency=alpha;self.badge.BackgroundTransparency=math.min(1,alpha+0.25) end
end

function Avatar:place()
    if self.destroyed then return end
    local size=self.parent.AbsoluteSize
    local width=math.min(self.width,math.max(1,size.X));local height=width/1.6
    if height>math.max(1,size.Y) then height=math.max(1,size.Y);width=height*1.6 end
    self.frame.Size=UDim2.fromOffset(width,height)
    self.frame.Position=UDim2.fromOffset(self.x*math.max(0,size.X-width),self.y*math.max(0,size.Y-height))
end

-- Normalized coordinates span the whole viewport and survive resizes.
function Avatar:setPosition(x,y)
    if self.destroyed then return end
    self.x,self.y=math.max(0,math.min(1,x)),math.max(0,math.min(1,y))
    self:place()
end

function Avatar:activate(options,reduced)
    self.resource=options.familyId~=nil
    if self.destroyed or not self:setAppearance(options.mascotId) then return false end
    self.sourceAgent=options.sourceAgent
    self.collectibleId=options.collectibleId;self.rank=options.rank or 1
    self.pending=false;self.pendingAge=0;self.syncAttempts=0
    local tier=Rarities[self.rank]
    self.reward=options.fragments or options.reward or tier.streak
    self.rarity=options.rarity or tier.name
    self.familyId=options.familyId
    self.caption=self.resource and (options.familyName.."\n"..self.rarity) or (tier.name.." +"..self.reward)
    self.collectionShown=false
    self.badge.Text=self.caption
    self.badge.Size=UDim2.new(1,0,0,self.resource and 30 or 16)
    self.badge.Position=UDim2.new(0,0,1,self.resource and -24 or -16)
    self.badge.TextColor3=Theme.rarity[self.rarity]
    self.frame:SetAttribute("CollectibleId",self.collectibleId)
    self.frame:SetAttribute("Rarity",self.rarity);self.frame:SetAttribute("StreakBonus",not self.resource and self.reward or nil)
    self.frame:SetAttribute("FragmentBonus",nil);self.frame:SetAttribute("FamilyId",self.familyId)
    if not self.resource then for _,part in ipairs(self.mascot.parts) do part.BackgroundColor3=Theme.rarity[tier.name] end end
    self.frame:SetAttribute("SourceAgent",self.sourceAgent)
    self.width=options.width or 128
    self:setPosition(options.x or 0,options.y or 0)
    self.mascot:setStreak(math.max(1,options.streak or 1))
    self.mascot.phase=0;self.mascot:rest()
    self.mascot.phaseOffset=options.phaseOffset or 0
    self.age=0;self.active=true;self.fading=false;self.alpha=nil
    self.frame.Visible=true
    self.button.Active=false -- A fully transparent spawn must not intercept clicks.
    self:setOpacity(reduced and 0.45 or 1)
    return true
end

function Avatar:fadeOut()
    if self.destroyed or not self.active or self.fading then return end
    self.fading=true;self.fadeAge=0;self.fadeStart=self.alpha or 0.28
end

function Avatar:hide()
    if self.destroyed then return end
    self.active=false;self.fading=false;self.frame.Visible=false;self.button.Active=false;self.mascot:rest()
end

function Avatar:setReducedMotion(value)
    if self.destroyed or not value then return end
    self.mascot:rest()
    if self.active and not self.fading then self:setOpacity(0.45) end
end

function Avatar:tick(dt,streak,bpm,animate,reduced)
    if self.destroyed or not self.active then return end
    dt=math.max(0,dt)
    self:place()
    if self.fading then
        self.fadeAge=self.fadeAge+dt
        local duration=self.fadeOutSeconds or Avatar.FADE_SECONDS
        self:setOpacity(self.fadeStart+(1-self.fadeStart)*math.min(1,self.fadeAge/duration))
        if self.fadeAge>=duration then self:hide();return end
    else
        local duration=self.fadeInSeconds or 0.12
        self.age=math.min(duration,self.age+dt)
        self.mascot:setStreak(math.max(1,streak))
        self:setOpacity(reduced and 0.45 or 1-math.min(1,self.age/duration)*0.72)
    end
    self.mascot.danceParameters.rate=bpm/120
    self.mascot:tickDance(dt,animate and not reduced)
end

function Avatar:destroy()
    if self.destroyed then return end
    self:hide();self.destroyed=true;self.mascot:destroy()
end
return Avatar

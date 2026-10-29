--!nonstrict
local Theme=require(script.Parent.DeskTheme)
local Motion=require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").PrestigeMotion)
local Transition={};Transition.__index=Transition
function Transition.new(playerGui,targets)
    local self=setmetatable({targets={},specks={},core={},lastId=0,active=false},Transition)
    for _,target in ipairs(targets) do
        self.targets[#self.targets+1]={object=target,scale=Theme.create("UIScale",target,{Name="PrestigeScale",Scale=1})}
    end
    self.gui=Theme.create("ScreenGui",playerGui,{Name="VibeIdlePrestigeTransition",ResetOnSpawn=false,
        ScreenInsets=Enum.ScreenInsets.None,DisplayOrder=30,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    self.blocker=Theme.create("TextButton",self.gui,{Name="PrestigeVortex",Visible=false,Text="",BackgroundTransparency=1,
        BorderSizePixel=0,Active=true,Selectable=false,AutoButtonColor=false,ClipsDescendants=true,Size=UDim2.fromScale(1,1)})
    self.veil=Theme.create("Frame",self.blocker,{Name="Veil",Active=false,Selectable=false,BorderSizePixel=0,
        BackgroundColor3=Color3.fromRGB(9,5,17),BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=1})
    local colors={Color3.fromRGB(133,73,167),Color3.fromRGB(205,127,97),Color3.fromRGB(78,40,112)}
    self.spiral=Theme.create("Frame",self.blocker,{Name="Spiral",BackgroundTransparency=1,Active=false,Selectable=false,
        AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(1,1),ZIndex=2})
    self.spiralScale=Theme.create("UIScale",self.spiral,{Scale=1})
    self.coreGroup=Theme.create("Frame",self.blocker,{Name="Core",BackgroundTransparency=1,Active=false,Selectable=false,
        AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(1,1),ZIndex=3})
    self.coreScale=Theme.create("UIScale",self.coreGroup,{Scale=1})
    for index=1,Motion.SPECKS do
        self.specks[index]=Theme.create("Frame",self.spiral,{Name="SpiralStrip",Active=false,Selectable=false,
            AnchorPoint=Vector2.new(.5,.5),BorderSizePixel=0,BackgroundColor3=colors[math.floor((index-1)/48)+1],ZIndex=2,Visible=false})
    end
    for index=1,24 do
        self.core[index]=Theme.create("Frame",self.coreGroup,{Name="VortexCore",Active=false,Selectable=false,
            BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(9,5,17),ZIndex=3,Visible=false})
    end
    return self
end
function Transition:buildGeometry()
    local width,height=self.viewport.X,self.viewport.Y
    self.spiral.Size=UDim2.fromOffset(width,height);self.coreGroup.Size=self.spiral.Size
    for index,part in ipairs(self.specks) do
        local p=Motion.speck(index,0,width,height)
        part.Position=UDim2.fromOffset(p.x,p.y);part.Size=UDim2.fromOffset(p.length,p.size)
        part.Rotation=p.angle;part.BackgroundTransparency=p.alpha
    end
    local radius=math.sqrt(width*width+height*height)*.6
    for index,part in ipairs(self.core) do
        local row=index-12.5;local half=math.sqrt(144-row*row)*radius/12
        part.Position=UDim2.fromOffset(width/2-half,height/2+(index-13)*radius/12)
        part.Size=UDim2.fromOffset(half*2,radius/12+1)
    end
end
function Transition:restore()
    for _,slot in ipairs(self.targets) do
        if slot.home then
            local target,home=slot.object,slot.home
            slot.scale.Scale=1
            target.Rotation=home.rotation;target.AnchorPoint=home.anchor
            target.Position=home.position;target.Size=home.size
        end
    end
end
function Transition:cover()
    if self.covered then return end
    self.covered=true;self:restore()
    if self.onCovered then self.onCovered() end
end
function Transition:start(id,reduced)
    if self.destroyed or self.active or type(id)~="number" or id~=id or id%1~=0 or id==math.huge or id<=self.lastId then return false end
    self.lastId=id;self.active=true;self.covered=false;self.reduced=reduced==true;self.age=0
    self.viewport=self.blocker.AbsoluteSize;self.blocker.Visible=true
    self:buildGeometry();self.lastSpiralVisible=nil;self.lastCoreVisible=nil
    self.blocker:SetAttribute("ActiveTransition",true)
    for _,slot in ipairs(self.targets) do
        local target=slot.object;local parent=target.Parent.AbsoluteSize;local size=target.AbsoluteSize
        local anchor=target.AnchorPoint or Vector2.new(0,0)
        slot.home={anchor=anchor,position=target.Position,size=target.Size,rotation=target.Rotation or 0,
            x=target.Position.X.Scale*parent.X+target.Position.X.Offset+(.5-anchor.X)*size.X,
            y=target.Position.Y.Scale*parent.Y+target.Position.Y.Offset+(.5-anchor.Y)*size.Y}
        slot.activeSize=UDim2.fromOffset(size.X,size.Y)
        target.AnchorPoint=Vector2.new(.5,.5);target.Size=slot.activeSize
    end
    self:draw();if self.onStarted then self.onStarted(id,self.reduced) end;return true
end
function Transition:draw()
    if not self.active then return end
    local pose=Motion.pose(self.age,self.reduced)
    self.blocker:SetAttribute("Phase",pose.phase)
    self.veil.BackgroundTransparency=1-pose.veil
    if pose.covered then self:cover() end
    if not self.covered then
        for _,slot in ipairs(self.targets) do
            local parent=slot.object.Parent.AbsoluteSize
            local angle=pose.angle*math.pi/180
            local dx,dy=slot.home.x-parent.X/2,slot.home.y-parent.Y/2
            slot.object.Position=UDim2.fromOffset(parent.X/2+(dx*math.cos(angle)-dy*math.sin(angle))*pose.scale,
                parent.Y/2+(dx*math.sin(angle)+dy*math.cos(angle))*pose.scale)
            slot.object.Rotation=slot.home.rotation+pose.angle;slot.scale.Scale=pose.scale
        end
    end
    local spiral=Motion.spiral(self.age)
    self.spiralScale.Scale=spiral.scale;self.spiral.Rotation=spiral.angle
    if self.lastSpiralVisible~=pose.spiral then
        self.lastSpiralVisible=pose.spiral
        for _,part in ipairs(self.specks) do part.Visible=pose.spiral end
    end
    self.coreScale.Scale=math.max(.001,pose.hole/.6)
    local coreVisible=pose.hole>0
    if self.lastCoreVisible~=coreVisible then
        self.lastCoreVisible=coreVisible
        for _,part in ipairs(self.core) do part.Visible=coreVisible end
    end
end
function Transition:setReduced(value)
    if not value or not self.active or self.reduced then return end
    self.reduced=true;self.age=Motion.REDUCED_CLOSE;self.veil.BackgroundTransparency=0
    self:cover();self:draw()
end
function Transition:finish()
    if not self.active then return end
    self:cover();self:restore();self.active=false;self.blocker.Visible=false
    self.blocker:SetAttribute("ActiveTransition",false)
    if self.onFinished then self.onFinished() end
end
function Transition:tick(dt,paused)
    if not self.active or self.destroyed then return end
    local size=self.blocker.AbsoluteSize
    if size.X~=self.viewport.X or size.Y~=self.viewport.Y then self:finish();return end
    for _,slot in ipairs(self.targets) do
        local expected=self.covered and slot.home.size or slot.activeSize
        if slot.object.Size~=expected then slot.home.size=slot.object.Size;self:finish();return end
    end
    if paused then return end
    self.age=self.age+math.max(0,math.min(.1,dt));self:draw()
    if Motion.pose(self.age,self.reduced).done then self:finish() end
end
function Transition:destroy()
    if self.destroyed then return end
    self.destroyed=true;self:restore();self.active=false;self.blocker.Visible=false
    if self.onStopped then self.onStopped() end
    self.blocker:SetAttribute("ActiveTransition",false)
    for _,slot in ipairs(self.targets) do slot.scale:Destroy() end
    self.gui:Destroy()
end
return Transition

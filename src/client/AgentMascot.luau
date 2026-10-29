--!nonstrict
-- Decorative object; motion is driven by the desk's existing loop, never rewards.
local Theme=require(script.Parent.DeskTheme)
local Catalog=require(script.Parent.MascotCatalog)
local Dance=require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").MascotDance)
local Mascot={}
Mascot.__index=Mascot

function Mascot.new(parent,id)
    local self=setmetatable({parts={},streak=0,phase=0,blend=0,phaseOffset=0,
        danceParameters=Dance.parameters(0)},Mascot)
    self.frame=Theme.create("Frame",parent,{Name="AgentMascot",BackgroundTransparency=1,
        BorderSizePixel=0,Active=false,Selectable=false,ClipsDescendants=true,Size=UDim2.fromOffset(64,40)})
    self.aspect=Theme.create("UIAspectRatioConstraint",self.frame,{AspectRatio=1.6,
        DominantAxis=Enum.DominantAxis.Width})
    -- Fixed CLI slot; a different mascot fits inside it instead of pushing text.
    self.motion=Theme.create("Frame",self.frame,{Name="Dance",BackgroundTransparency=1,
        BorderSizePixel=0,Active=false,Selectable=false,AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(1,1),Rotation=0})
    self.canvas=Theme.create("Frame",self.motion,{Name="Artwork",BackgroundTransparency=1,
        BorderSizePixel=0,Active=false,Selectable=false,AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromScale(1,1)})
    if not self:setMascot(id or Catalog.DEFAULT) then self:setMascot(Catalog.DEFAULT) end
    return self
end

function Mascot:rest()
    self.blend=0
    self.motion.Position=UDim2.fromScale(0.5,0.5)
    self.motion.Size=UDim2.fromScale(1,1);self.motion.Rotation=0
end
function Mascot:setStreak(count)
    if self.destroyed then return end
    count=type(count)=="number" and count==count and math.max(0,math.min(9999,math.floor(count))) or 0
    if self.streak==count then return end
    self.streak=count;self.danceParameters=Dance.parameters(count)
    if count==0 then self.phase=0;self:rest() end
end
function Mascot:tickDance(dt,enabled)
    if self.destroyed then return end
    if not enabled or self.streak==0 then
        if self.blend~=0 then self:rest() end
        return
    end
    self.phase=Dance.advance(self.phase,dt,self.danceParameters.rate)
    self.blend=math.min(1,self.blend+math.max(0,math.min(dt,0.1))*6)
    local x,y,angle,sx,sy=Dance.pose(self.danceParameters,self.phase+self.phaseOffset,self.blend)
    self.motion.Position=UDim2.fromScale(0.5+x,0.5+y)
    self.motion.Size=UDim2.fromScale(sx,sy);self.motion.Rotation=angle
end

function Mascot:setMascot(id)
    local definition=Catalog[id]
    if self.destroyed or type(definition)~="table" or not definition.parts then return false end
    if self.id==id then return true end
    for index,rect in ipairs(definition.parts) do
        local part=self.parts[index]
        if not part then
            part=Theme.create("Frame",self.canvas,{Name="PixelPart"..index,BorderSizePixel=0,
                Active=false,Selectable=false})
            self.parts[index]=part
        end
        local color=rect[5] or definition.color
        part.Visible=true;part.BackgroundColor3=Color3.fromRGB(color[1],color[2],color[3])
        part.Position=UDim2.fromScale(rect[1]/definition.width,rect[2]/definition.height)
        part.Size=UDim2.fromScale(rect[3]/definition.width,rect[4]/definition.height)
    end
    for index=#definition.parts+1,#self.parts do self.parts[index].Visible=false end
    local ratio=definition.width/definition.height
    self.canvas.Size=UDim2.fromScale(math.min(1,ratio/1.6),math.min(1,1.6/ratio))
    self.id=id
    self.frame:SetAttribute("MascotId",id)
    self.frame:SetAttribute("DisplayName",definition.name)
    return true
end

function Mascot:destroy()
    if self.destroyed then return end
    self.destroyed=true;self.parts={};self.frame:Destroy()
end
return Mascot

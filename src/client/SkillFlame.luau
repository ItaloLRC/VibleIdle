--!nonstrict
-- User-supplied pixel animation, compiled offline into a bounded passive pool.
local Theme=require(script.Parent.DeskTheme)
local Catalog=require(script.Parent.SkillFireCatalog)
local Flame={};Flame.__index=Flame
Flame.CAPACITY=Catalog.CAPACITY
function Flame.new(parent)
    local self=setmetatable({streak=0,phase=0,tier=1,parts={},diameter=120,colors={}},Flame)
    self.layer=Theme.create("Frame",parent,{Name="StreakFire",BackgroundTransparency=1,
        BorderSizePixel=0,Active=false,Selectable=false,ZIndex=1,Visible=false,
        ClipsDescendants=false,AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,0,0,4),Size=UDim2.fromOffset(120,120)})
    for index,rgb in ipairs(Catalog.colors) do self.colors[index]=Color3.fromRGB(rgb[1],rgb[2],rgb[3]) end
    for index=1,Flame.CAPACITY do
        self.parts[index]=Theme.create("Frame",self.layer,{Name="FirePixel"..index,
            BorderSizePixel=0,Active=false,Selectable=false,ZIndex=1,Visible=false})
    end
    return self
end
function Flame:setStreak(streak,divisor)
    if self.destroyed then return end
    streak=math.max(0,math.min(9999,math.floor(streak or 0)))
    divisor=math.max(2,math.min(5,math.floor(divisor or 5)))
    local tier=streak>=divisor*2 and 3 or streak>=divisor and 2 or 1
    local redraw=self.streak<=0 or self.tier~=tier
    self.streak=streak;self.tier=tier;self.layer.Visible=streak>0
    if streak==0 then
        self.phase=0;self.frameIndex=nil
    elseif redraw then
        self:draw(true) -- Keep frame phase across hits and intensity changes.
    end
end
function Flame:layout(diameter)
    if self.destroyed or self.diameter==diameter then return end
    self.diameter=diameter;self.layer.Size=UDim2.fromOffset(diameter,diameter)
    self:draw(true)
end
function Flame:draw(force)
    if self.destroyed or self.streak<=0 then return end
    local frameIndex=math.floor(self.phase*Catalog.FPS+0.000001)%Catalog.FRAME_COUNT+1
    if not force and self.frameIndex==frameIndex then return end
    self.frameIndex=frameIndex
    local tier=Catalog.tiers[self.tier]
    local rects=tier.frames[frameIndex]
    local scale=self.diameter/Catalog.CIRCLE_DIAMETER
    local minY=tier.centerY
    for index,part in ipairs(self.parts) do
        local rect=rects[index]
        part.Visible=rect~=nil
        if rect then
            -- SVG black circle is replaced by the real button. Same center/diameter
            -- on all three tiers, so no black overlay can hide its arc/dot/label.
            part.Position=UDim2.fromOffset(self.diameter/2+(rect[1]-tier.centerX)*scale,
                self.diameter/2+(rect[2]-tier.centerY)*scale)
            part.Size=UDim2.fromOffset(rect[3]*scale,rect[4]*scale)
            part.BackgroundColor3=self.colors[rect[5]]
            minY=math.min(minY,rect[2])
        end
    end
    self.height=(tier.centerY-minY)*scale-self.diameter/2
    self.layer:SetAttribute("FireIntensity",self.tier)
    self.layer:SetAttribute("AnimationFrame",frameIndex)
end
function Flame:tick(dt,enabled)
    if self.destroyed or self.streak<=0 or not enabled or self.reduced then return end
    -- Native source animation: 12 frames at 100ms. No per-pixel task or tween.
    self.phase=(self.phase+math.max(0,math.min(0.1,dt)))%(Catalog.FRAME_COUNT/Catalog.FPS)
    self:draw(false)
end
function Flame:setReducedMotion(value)
    if self.destroyed or self.reduced==value then return end
    self.reduced=value
    if value then self.phase=0 end
    self:draw(true)
end
function Flame:destroy()
    if self.destroyed then return end
    self.destroyed=true;self.layer:Destroy();self.parts={}
end
return Flame

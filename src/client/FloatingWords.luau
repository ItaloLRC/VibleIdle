--!nonstrict
-- Immediate cosmetic feedback, emitted only by accepted local skill input.
local Theme=require(script.Parent.DeskTheme)
local Words={};Words.__index=Words
Words.CAPACITY=12;Words.DURATION=1.4
Words.PHRASES={"Wow","Vibing","__skillcheck","Flow","Nice!","Locked in","Keep going"}
function Words.new(parent,terminal,skillLayer)
    local self=setmetatable({terminal=terminal,skillLayer=skillLayer,pool={},cursor=0,emitted=0,random=Random.new()},Words)
    self.layer=Theme.create("Frame",parent,{Name="FloatingWords",BackgroundTransparency=1,BorderSizePixel=0,
        Active=false,Selectable=false,ClipsDescendants=true,ZIndex=15,Size=UDim2.fromScale(1,1)})
    for index=1,Words.CAPACITY do
        local label=Theme.text(self.layer,"",20,Theme.colors.mint,UDim2.fromOffset(0,0),UDim2.fromOffset(220,36),Theme.mono)
        label.Name="SkillWord"..index;label.Visible=false;label.Active=false;label.Selectable=false
        label.TextWrapped=false;label.TextXAlignment=Enum.TextXAlignment.Center
        self.pool[index]={label=label,active=false}
    end
    return self
end
function Words:place(slot)
    local size=self.layer.AbsoluteSize
    local width=math.max(1,math.min(size.X-24,slot.width))
    local height=36
    local bottom=math.min(size.Y-44,self.skillLayer.AbsolutePosition.Y-self.layer.AbsolutePosition.Y-8)
    local top=math.max(0,math.min(16,bottom-height))
    local low=math.max(top,bottom-height)
    local rise=math.min(56,math.max(0,low-top))
    local y=top+rise+slot.y*math.max(0,low-top-rise)
    local t=math.min(1,slot.age/(self.terminal.tuning and self.terminal.tuning.floatingDuration or Words.DURATION))
    local offset=self.reduced and 0 or rise*(1-(1-t)^2)
    slot.label.Position=UDim2.fromOffset(12+slot.x*math.max(0,size.X-width-24),y-offset)
    slot.label.Size=UDim2.fromOffset(width,height)
    slot.label.TextTransparency=self.reduced and 0 or math.max(0,(t-0.25)/0.75)
end
function Words:emit()
    if self.destroyed or not self.terminal:canEdit() then return end
    self.cursor=self.cursor%Words.CAPACITY+1
    local slot=self.pool[self.cursor]
    local phrase=Words.PHRASES[self.random:NextInteger(1,#Words.PHRASES)]
    local size=self.random:NextInteger(16,22)
    local colors={Theme.colors.mint,Theme.colors.amber,Theme.colors.ink,Theme.colors.accent}
    slot.label.Text=phrase;slot.label.TextSize=size
    slot.label.TextColor3=colors[self.random:NextInteger(1,#colors)]
    slot.width=Theme.textWidth(phrase,size)+16
    slot.x,slot.y=self.random:NextInteger(0,1000)/1000,self.random:NextInteger(0,1000)/1000
    slot.age=0;slot.active=true;slot.label.Visible=true
    self:place(slot);self.emitted=self.emitted+1
end
function Words:clear()
    for _,slot in ipairs(self.pool) do slot.active=false;slot.label.Visible=false end
end
function Words:setReducedMotion(value)
    self.reduced=value
    for _,slot in ipairs(self.pool) do if slot.active then self:place(slot) end end
end
function Words:tick(dt)
    if self.destroyed then return end
    if not self.terminal:canEdit() then self:clear();return end
    for _,slot in ipairs(self.pool) do
        if slot.active then
            slot.age=slot.age+math.max(0,dt)
            if slot.age>=(self.terminal.tuning and self.terminal.tuning.floatingDuration or Words.DURATION) then slot.active=false;slot.label.Visible=false
            else self:place(slot) end
        end
    end
end
function Words:destroy()
    self.destroyed=true;self:clear();self.layer:Destroy()
end
return Words

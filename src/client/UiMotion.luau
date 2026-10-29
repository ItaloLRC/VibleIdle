--!nonstrict
-- One bounded cosmetic owner, driven by the terminal's existing tick.
local Theme=require(script.Parent.DeskTheme)
local Gui=game:GetService("GuiService")
local Input=game:GetService("UserInputService")
local Motion={};Motion.__index=Motion
local function ease(t) t=math.max(0,math.min(1,t));return t*t*(3-2*t) end
local function visible(object)
    while object and object.ClassName~="ScreenGui" do
        if object.Visible==false then return false end
        object=object.Parent
    end
    return object~=nil
end
local function inside(object,point)
    local p,s=object.AbsolutePosition,object.AbsoluteSize
    return point.X>=p.X and point.X<p.X+s.X and point.Y>=p.Y and point.Y<p.Y+s.Y
end
function Motion.new(parent,terminal,viewport,content)
    local self=setmetatable({terminal=terminal,viewport=viewport,content=content,texts={},buttons={},connections={}},Motion)
    self.gui=Theme.create("ScreenGui",parent,{Name="VibeIdleUiMotion",ResetOnSpawn=false,DisplayOrder=26,
        ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
    self.cover=Theme.create("TextButton",self.gui,{Name="PageFade",Text="",AutoButtonColor=false,BorderSizePixel=0,
        BackgroundColor3=Color3.fromRGB(9,8,12),BackgroundTransparency=1,Active=true,Selectable=false,Visible=false,Size=UDim2.fromScale(1,1)})
    return self
end
function Motion:busy() return self.transition~=nil end
function Motion:resetText(entry)
    entry.age=nil;entry.label.TextTransparency=entry.alpha;entry.label.TextStrokeTransparency=entry.stroke
end
function Motion:watchText(label)
    if not label or #self.texts>=64 then return end
    for _,entry in ipairs(self.texts) do if entry.label==label then return end end
    local entry={label=label,alpha=label.TextTransparency or 0,stroke=label.TextStrokeTransparency or 1,last=label.Text}
    self.texts[#self.texts+1]=entry
    self.connections[#self.connections+1]=label:GetPropertyChangedSignal("Text"):Connect(function()
        if label.Text==entry.last then return end;entry.last=label.Text
        if self.destroyed or self.disabled or self.terminal.reduced or not visible(label) then self:resetText(entry);return end
        entry.age=0;label.TextTransparency=entry.alpha+(1-entry.alpha)*.6
        label.TextStrokeTransparency=entry.stroke+(1-entry.stroke)*.6
    end)
end
function Motion:watchButton(button)
    if not button or #self.buttons>=48 then return end
    for _,entry in ipairs(self.buttons) do if entry.button==button then return end end
    local glow=Theme.create("Frame",button,{Name="HoverGleam",BorderSizePixel=0,Active=false,Selectable=false,
        Position=UDim2.fromOffset(8,3),Size=UDim2.new(1,-16,0,2),ZIndex=8,BackgroundColor3=Theme.colors.white,BackgroundTransparency=1})
    local entry={button=button,glow=glow,alpha=1};self.buttons[#self.buttons+1]=entry
    self.connections[#self.connections+1]=button.MouseMoved:Connect(function(x,y) entry.pointer=Vector2.new(x,y) end)
    self.connections[#self.connections+1]=button.MouseLeave:Connect(function() entry.pointer=nil end)
    self.connections[#self.connections+1]=button.Activated:Connect(function()
        if not self:busy() and button.Active~=false and visible(button) then entry.tap=0 end
    end)
end
function Motion:begin(commit)
    if self.destroyed or self:busy() then return false end
    if self.disabled or self.terminal.reduced then commit();return true end
    self.transition={phase="cover",age=0,commit=commit,hadSelection=Gui.SelectedObject~=nil}
    self.terminal.uiTransition=true;self.terminal:blur();self.terminal:refreshControls()
    Gui.SelectedObject=nil;self.nextFocus=nil
    self.cover.Visible=true;self.cover.BackgroundTransparency=1
    return true
end
function Motion:commit()
    local t=self.transition;if not t or t.committed then return end
    t.committed=true
    local ok,reason=pcall(t.commit)
    if not ok then warn("[VibeIdle] UI transition failed: "..tostring(reason));self:cancel();return end
    if self.transition~=t then return end
    t.phase,t.age="reveal",0
end
function Motion:finish()
    local t=self.transition
    self.transition=nil;self.cover.Visible=false;self.cover.BackgroundTransparency=1
    self.content.Position=UDim2.fromOffset(0,0);self.terminal.uiTransition=false
    self.terminal:refreshInput();self.terminal:refreshControls()
    if self.nextFocus and t and (Input.GamepadEnabled or t.hadSelection) then
        if self.terminal.windowFocused and not Gui.MenuIsOpen then Gui.SelectedObject=self.nextFocus
        else self.delayedFocus=self.nextFocus end
    end
    self.nextFocus=nil
    if self.onSettled then self.onSettled() end
end
function Motion:cancel()
    self.nextFocus=nil;self.delayedFocus=nil;self:finish()
    for _,entry in ipairs(self.texts) do self:resetText(entry) end
    for _,entry in ipairs(self.buttons) do entry.pointer=nil;entry.tap=nil;entry.alpha=1;entry.glow.BackgroundTransparency=1 end
end
function Motion:setReduced(value)
    if not value then return end
    if self:busy() then self:commit();if self:busy() then self:finish() end end
    for _,entry in ipairs(self.texts) do self:resetText(entry) end
    for _,entry in ipairs(self.buttons) do entry.alpha=1;entry.glow.BackgroundTransparency=1;entry.tap=nil end
end
function Motion:tick(dt,paused)
    if self.destroyed then return end
    self.cover.Size=UDim2.fromOffset(self.viewport.AbsoluteSize.X,self.viewport.AbsoluteSize.Y)
    if self.delayedFocus and not paused and not self:busy() then
        if visible(self.delayedFocus) then Gui.SelectedObject=self.delayedFocus end
        self.delayedFocus=nil
    end
    if self.terminal.reduced or self.disabled then
        if not self.static then self:setReduced(true);self.static=true end
        return
    end
    self.static=false
    if paused then
        for _,entry in ipairs(self.buttons) do entry.pointer=nil;entry.alpha=1;entry.glow.BackgroundTransparency=1 end
        return
    end
    dt=math.max(0,math.min(.05,dt))
    local t=self.transition
    if t then
        t.age=t.age+dt
        if t.phase=="cover" then
            self.cover.BackgroundTransparency=1-ease(t.age/.1)
            if t.age>=.1 then self:commit() end
        else
            local p=ease(t.age/.22);self.cover.BackgroundTransparency=p
            self.content.Position=UDim2.fromOffset(0,math.floor(8*(1-p)+.5))
            if t.age>=.22 then self:finish() end
        end
    end
    for _,entry in ipairs(self.texts) do
        if entry.age then
            if not visible(entry.label) then self:resetText(entry)
            else
                entry.age=entry.age+dt;local p=1-ease(entry.age/.18)
                entry.label.TextTransparency=entry.alpha+(1-entry.alpha)*.6*p
                entry.label.TextStrokeTransparency=entry.stroke+(1-entry.stroke)*.6*p
                if entry.age>=.18 then self:resetText(entry) end
            end
        end
    end
    for _,entry in ipairs(self.buttons) do
        local button=entry.button
        local eligible=not self:busy() and button.Active~=false and visible(button)
        local hovered=eligible and entry.pointer and inside(button,entry.pointer)
        local parent=button.Parent
        while hovered and parent and parent.ClassName~="ScreenGui" do
            if parent.ClipsDescendants and not inside(parent,entry.pointer) then hovered=false end
            parent=parent.Parent
        end
        local focused=eligible and Gui.SelectedObject==button
        local target=(hovered or focused) and .55 or 1
        if entry.tap then entry.tap=entry.tap+dt;if entry.tap<.16 and eligible then target=.22 else entry.tap=nil end end
        entry.alpha=entry.alpha+(target-entry.alpha)*(1-math.exp(-dt*22))
        if math.abs(entry.alpha-target)<.005 then entry.alpha=target end
        entry.glow.BackgroundTransparency=entry.alpha
        entry.glow.BackgroundColor3=focused and Theme.colors.mint or Theme.colors.white
        if not eligible then entry.pointer=nil end
    end
end
function Motion:destroy()
    if self.destroyed then return end
    self.onSettled=nil;self:cancel();self.destroyed=true
    for _,entry in ipairs(self.texts) do self:resetText(entry) end
    for _,connection in ipairs(self.connections) do connection:Disconnect() end
    for _,entry in ipairs(self.buttons) do entry.glow:Destroy() end
    self.gui:Destroy()
end
return Motion

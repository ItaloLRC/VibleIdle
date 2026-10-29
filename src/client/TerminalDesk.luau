--!nonstrict
-- One draggable Main CLI with a passive, snapshot-driven agent avatar roster.
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Agent = require(Shared.AgentSession)
local Theme = require(script.Parent.DeskTheme)
local Mascot = require(script.Parent.AgentMascot)
local c = Theme.colors
local Desk = {}
Desk.__index = Desk

function Desk.new(parent, terminal, balance)
    local self = setmetatable({ parent = parent, terminal = terminal, balance = balance,
        count = 1, front = 1,
        order = {1}, windows = {}, agents={}, positions = {}, connections = {} }, Desk)
    local function connect(signal, callback) self.connections[#self.connections + 1] = signal:Connect(callback) end
    terminal.onLayoutChanged=function() self:resizeCanvas() end
    self.windows[1] = { frame = terminal.frame, bar = terminal.bar, border = terminal.border, mascot = terminal.mascot }
    self.roster=Theme.create("Frame",terminal.frame,{Name="AgentRoster",BorderSizePixel=0,
        BackgroundTransparency=1,Active=false,Selectable=false,Position=UDim2.fromOffset(12,44),Size=UDim2.new(1,-24,0,58)})
    for index=1,balance.MAX_HIDDEN_LAYERS do
        local slot=Theme.create("Frame",self.roster,{Name="Agent"..index,BackgroundTransparency=1,
            BorderSizePixel=0,Active=false,Selectable=false,Visible=index==1,Size=UDim2.fromOffset(64,50)})
        local mascot=index==1 and terminal.mascot or Mascot.new(slot)
        mascot.frame.Parent=slot
        mascot.phaseOffset=(index-1)*0.7
        mascot.frame.Position,mascot.frame.Size=UDim2.fromOffset(8,0),UDim2.fromOffset(48,30)
        local label=Theme.text(slot,string.format("%02d",index),11,c.muted,UDim2.fromOffset(0,32),UDim2.fromOffset(64,18),Theme.mono)
        label.Active,label.Selectable,label.TextXAlignment=false,false,Enum.TextXAlignment.Center
        self.agents[index]={frame=slot,mascot=mascot,label=label}
    end
    terminal.onFitRoster=function(width) return self:layoutRoster(width) end
    for index, window in ipairs(self.windows) do
        local slot = index
        connect(window.frame.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                self:activate(slot, input)
            end
        end)
        connect(window.bar.Activated, function(input)
            self:activate(slot, input)
        end)
        connect(window.bar.InputBegan, function(input)
            if GuiService.MenuIsOpen or self.drag then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if not self:activate(slot, input) then return end
            self.drag = { input = input, index = slot, start = input.Position,
                x = window.frame.Position.X.Offset, y = window.frame.Position.Y.Offset }
        end)
    end
    -- One shared drag pair; no per-window Heartbeat or document-wide input capture.
    connect(UserInputService.InputChanged, function(input)
        local drag = self.drag
        if not drag or self.suspended then return end
        if input ~= drag.input and not (drag.input.UserInputType == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement) then return end
        local window = self.windows[drag.index].frame
        local x, y = Agent.clampWindow(drag.x + input.Position.X - drag.start.X,
            drag.y + input.Position.Y - drag.start.Y, window.AbsoluteSize.X, window.AbsoluteSize.Y,
            self.canvasWidth or parent.AbsoluteSize.X, parent.AbsoluteSize.Y)
        window.Position = UDim2.fromOffset(x, y)
        self:resizeCanvas()
        self.positions[drag.index] = { x / math.max(1, (self.canvasWidth or parent.AbsoluteSize.X) - window.AbsoluteSize.X),
            y / math.max(1, parent.AbsoluteSize.Y - window.AbsoluteSize.Y) }
    end)
    connect(UserInputService.InputEnded, function(input)
        if self.drag and input == self.drag.input then self.drag = nil end
    end)
    connect(UserInputService.WindowFocusReleased, function() self.drag = nil end)
    return self
end

function Desk:resizeCanvas()
    local height=self.parent.AbsoluteSize.Y
    local width=math.max(self.parent.AbsoluteSize.X,self.canvasWidth or 0)
    local bottom=height
    local main=self.terminal.frame
    if main.Position.Y.Offset+main.AbsoluteSize.Y>height-(self.terminal.bottomClearance or 44) then
        bottom=math.max(bottom,main.Position.Y.Offset+main.AbsoluteSize.Y+(self.terminal.bottomClearance or 44))
    end
    self.parent.CanvasSize=UDim2.fromOffset(width,bottom)
    self.parent.ScrollingEnabled=bottom>height or width>self.parent.AbsoluteSize.X
    self.parent.Active=self.parent.ScrollingEnabled
    local previous=self.parent.CanvasPosition or Vector2.new(0,0)
    self.parent.CanvasPosition=Vector2.new(math.max(0,math.min(previous.X,width-self.parent.AbsoluteSize.X)),math.max(0,math.min(previous.Y,bottom-height)))
end

local function contains(frame, position)
    local origin, size = frame.AbsolutePosition, frame.AbsoluteSize
    return position.X >= origin.X and position.Y >= origin.Y
        and position.X < origin.X + size.X and position.Y < origin.Y + size.Y
end

-- GuiObject.InputBegan can reach covered Frames. Reject occluded mouse/touch
-- callbacks before they alter focus, start a drag, or request overlay ownership.
function Desk:valid(index) return index==1 end
-- Local appearance selection survives snapshots/purchases/layout. No economic command.
function Desk:setAgentMascot(index,id)
    local agent=self.agents[index]
    if not agent or index>self.count or agent.equippedCard then return false end
    if not agent.mascot:setMascot(id) then return false end
    agent.cosmeticId=id;return true
end
function Desk:ownsPointer(index, input)
    if not self:valid(index) then return false end
    if not input or (input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch) then return true end
    local target = self.windows[index].frame
    if not target.Visible or not contains(self.parent, input.Position) or not contains(target, input.Position) then return false end
    for _,id in ipairs(self.order) do
        local other = self.windows[id].frame
        if other.Visible and other.ZIndex > target.ZIndex and contains(other, input.Position) then return false end
    end
    return true
end

function Desk:activate(index, input, sourceIndex)
    if not self:valid(index) or GuiService.MenuIsOpen then return false end
    if not self:ownsPointer(sourceIndex or index, input) then return false end
    if self.onActivate and self.onActivate(input) == false then return false end
    if self.suspended then return false end
    self:focus(index)
    return true
end

function Desk:focus(index)
    if not self:valid(index) then return end
    for offset, id in ipairs(self.order) do
        if id == index then table.remove(self.order, offset);break end
    end
    self.order[#self.order + 1], self.front = index, index
    for offset, id in ipairs(self.order) do
        local window = self.windows[id]
        window.frame.ZIndex = offset + 1
        window.border.Color=c.black;window.border.Thickness=id==index and 2 or 1
    end
    if self.onFocus then self.onFocus(index) end
end

function Desk:update(data)
    self.data = data
    local count = #data.layerSizes - 2
    local changed=count~=self.count
    self.count=count
    for index,agent in ipairs(self.agents) do
        local card=data.cardDeck and data.cardDeck[index] or false
        if card then
            if not agent.equippedCard then agent.cosmeticId=agent.mascot.id end
            agent.mascot:setMascot(card)
        elseif agent.equippedCard then agent.mascot:setMascot(agent.cosmeticId or "ember") end
        agent.equippedCard=card
        agent.frame.Visible=index<=count
        agent.mascot:setStreak(index<=count and (data.stats and data.stats.streak or 0) or 0)
        if index>count then agent.mascot:tickDance(0,false) end
    end
    self.terminal.welcomeDetail.Text = string.format("%d agent%s connected\n%d words per prompt\nClick, then Enter.", count, count == 1 and "" or "s", data.tokenLimit)
    if changed then self.terminal:refreshInput() end
end

function Desk:layoutRoster(width)
    local columns=math.max(1,math.min(self.balance.MAX_HIDDEN_LAYERS,math.floor((width-24+8)/72)))
    local rows=math.ceil(self.count/columns)
    local height=rows*50+(rows-1)*8+8
    self.roster.Size=UDim2.new(1,-24,0,height)
    for index,agent in ipairs(self.agents) do
        agent.frame.Position=UDim2.fromOffset(((index-1)%columns)*72,4+math.floor((index-1)/columns)*58)
    end
    return height
end

function Desk:layout(spec)
    self.drag = nil
    local dragWidth=spec.dragWidth or spec.width
    self.canvasWidth=dragWidth;self.terminal.canvasWidth=dragWidth
    local geometry,saved=spec.windows[1],self.positions[1]
    local x,y=geometry.x,geometry.y
    if saved then x,y=saved[1]*(dragWidth-geometry.width),saved[2]*(spec.height-geometry.height) end
    x,y=Agent.clampWindow(x,y,geometry.width,geometry.height,dragWidth,spec.height)
    self.terminal:layout(UDim2.fromOffset(x,y),UDim2.fromOffset(geometry.width,geometry.height),spec.short)
    if not saved then
        self.terminal.frame.Position=UDim2.fromOffset(x,math.max(y,spec.headerHeight or 0))
    end
    if self.data then self:update(self.data) end
    self:resizeCanvas()
end

function Desk:setSuspended(value)
    self.suspended = value
    if value then self.drag = nil;self:tickMascots(0,false) end
end

function Desk:tickMascots(dt,active)
    local enabled=active and not self.suspended and not self.reduced
    for index,agent in ipairs(self.agents) do
        agent.mascot:tickDance(dt,enabled and index<=self.count and agent.frame.Visible)
    end
end
function Desk:setReducedMotion(value)
    self.reduced=value
    if value then self:tickMascots(0,false) end
end

function Desk:destroy()
    self.drag = nil
    self.terminal.onLayoutChanged=nil
    self.terminal.onFitRoster=nil
    for _, connection in ipairs(self.connections) do connection:Disconnect() end
    for index = 2, #self.agents do
        self.agents[index].mascot:destroy()
        self.agents[index].frame:Destroy()
    end
end

return Desk

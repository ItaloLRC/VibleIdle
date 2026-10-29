--!nonstrict
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Prompt, Composer, Agent = require(Shared.PromptRules), require(Shared.PromptComposer), require(Shared.AgentSession)
local Cash = require(Shared.CashFeedback)
local Collection = require(Shared.TokenCollection)
local Skill = require(Shared.SkillCheck)
local Cards = require(Shared.AgentCards)
local Theme = require(script.Parent.DeskTheme)
local Mascot = require(script.Parent.AgentMascot)
local c = Theme.colors
local tokenStyle=Composer.TOKEN_STYLE
local Terminal = {}
Terminal.__index = Terminal

function Terminal.new(parent, balance, onSubmit, payoutParent)
    local self = setmetatable({ balance=balance, submit=onSubmit, composer=Composer.new(),
        session=Agent.new(), cash=Cash.new(), connections={}, rows={}, cashLabels={}, tokens={},
        tokenWords={},tokenBadges={},tokenBorders={},soldTokens={},soldLookup={},collection=Collection.new(),reveals={}, blocked=true,
        limit=balance.PROMPT_BASE_TOKENS, base=1, speed=balance.TYPING_BASE_RATE,
        nextAgent=os.clock()+balance.AGENT_INTERVAL,agentSequence=0,agentRevealTimes={}, keysDown={}, windowFocused=true, alive=true, follow=true }, Terminal)
    local function connect(signal, callback) self.connections[#self.connections+1]=signal:Connect(callback) end
    self.frame = Theme.create("Frame", parent, { Name="MainCLI", BorderSizePixel=0,
        BackgroundColor3=c.terminal, ClipsDescendants=true, Active=true })
    self.border = Theme.window(self.frame)
    self.bar = Theme.create("TextButton", self.frame, { Name="WindowTitle", Text="", BackgroundColor3=c.title,
        AutoButtonColor=false, BorderSizePixel=0, Size=UDim2.new(1,0,0,40) })
    self.mascot=Mascot.new(self.bar)
    self.mascot.frame.Position,self.mascot.frame.Size=UDim2.fromOffset(16,10),UDim2.fromOffset(32,20)
    Theme.text(self.bar,"Vibe CLI / main",13,c.ink,UDim2.fromOffset(16,0),UDim2.fromOffset(202,40),Theme.mono)
    self.stateLabel = Theme.text(self.bar,"CONNECTING",11,c.dim,UDim2.fromOffset(222,0),UDim2.new(1,-234,1,0))
    self.stateLabel.TextXAlignment=Enum.TextXAlignment.Right
    self.welcome=Theme.create("Frame",self.frame,{Name="Welcome",BorderSizePixel=0,BackgroundTransparency=1,
        Position=UDim2.fromOffset(14,54),Size=UDim2.new(1,-28,0,112)})
    Theme.round(self.welcome,4);Theme.outline(self.welcome).Color=c.accent
    self.welcomeHeading=Theme.text(self.welcome,"VIBE CLI",18,c.ink,UDim2.fromOffset(16,12),UDim2.new(0.55,-32,0,28),Theme.mono)
    self.welcomeCopy=Theme.text(self.welcome,"Build your tokens.\nEnter or SELL to cash out.",13,c.accent,UDim2.fromOffset(16,48),UDim2.new(0.55,-32,0,52),Theme.mono)
    self.welcomeDetail=Theme.text(self.welcome,"Agents write. Skill checks build streak.",13,c.dim,UDim2.new(0.55,0,0,12),UDim2.new(0.45,-16,1,-24),Theme.mono)
    self.progress=Theme.create("Frame",self.frame,{Name="JobProgress",BorderSizePixel=0,
        BackgroundColor3=c.accent,Position=UDim2.fromOffset(0,40),Size=UDim2.fromOffset(0,2)})
    self.log=Theme.create("ScrollingFrame",self.frame,{Name="Scrollback",BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.fromOffset(16,54),Size=UDim2.new(1,-32,1,-240),CanvasSize=UDim2.fromOffset(0,0),
        ScrollBarThickness=0,ScrollBarImageColor3=c.line,ScrollingDirection=Enum.ScrollingDirection.Y})
    local list=Theme.create("UIListLayout",self.log,{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
    for index=1,Agent.MAX_LINES do
        local row=Theme.text(self.log,"",15,c.ink,UDim2.fromOffset(0,0),UDim2.new(1,-10,0,22),Theme.mono)
        row.Name,row.LayoutOrder,row.Visible="Line"..index,index,false
        row.AutomaticSize,row.TextYAlignment=Enum.AutomaticSize.Y,Enum.TextYAlignment.Top
        self.rows[index]=row
    end
    self.latest=Theme.button(self.frame,"Latest",UDim2.new(1,-78,1,-220),UDim2.fromOffset(66,40),function()
        self.follow=true;self:scrollBottom()
    end)
    self.latest.Visible=false
    self.panel=Theme.create("Frame",self.frame,{Name="PromptComposer",BackgroundTransparency=1,BorderSizePixel=0})
    Theme.rule(self.panel,UDim2.fromOffset(8,0),UDim2.new(1,-16,0,1),c.line)
    Theme.text(self.panel,">",19,c.accent,UDim2.fromOffset(12,10),UDim2.fromOffset(20,28),Theme.mono)
    self.preview=Theme.create("Frame",self.panel,{Name="PromptTokens",BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.fromOffset(38,10),Size=UDim2.new(1,-50,1,-66)})
    self.placeholder=Theme.text(self.preview,"Agents are preparing tokens.",tokenStyle.wordSize,c.dim,UDim2.fromOffset(0,0),UDim2.new(1,-8,0,tokenStyle.rowHeight),Theme.mono)
    for index=1,balance.PROMPT_MAX_TOKENS do
        local piece=Theme.create("Frame",self.preview,{Name="Token"..index,Visible=false,BorderSizePixel=0,
            BackgroundColor3=c.paper,Size=UDim2.fromOffset(57,tokenStyle.height)})
        Theme.round(piece,5)
        self.tokenBorders[index]=Theme.outline(piece)
        local word=Theme.text(piece,"",tokenStyle.wordSize,c.ink,UDim2.fromOffset(tokenStyle.padding,0),UDim2.new(1,-tokenStyle.padding*2,1,0),Theme.mono)
        word.Name,word.TextWrapped="Word",false
        word.TextTruncate=Enum.TextTruncate.AtEnd
        local badge=Theme.text(piece,"",tokenStyle.badgeSize,c.ink,UDim2.new(1,-38,0,0),UDim2.fromOffset(32,tokenStyle.height),Theme.mono)
        badge.Name,badge.TextWrapped,badge.Visible="Multiplier",false,false
        badge.TextXAlignment=Enum.TextXAlignment.Right
        self.tokens[index],self.tokenWords[index],self.tokenBadges[index]=piece,word,badge
    end
    self.caret=Theme.create("Frame",self.preview,{Name="Caret",BorderSizePixel=0,BackgroundColor3=c.ink,Size=UDim2.fromOffset(9,24)})
    -- Read-only composer: agent receipts supply authored words, never arbitrary text.
    -- Keep native Return callbacks for an already-focused input/accessibility.
    self.input=Theme.create("TextBox",self.preview,{Name="CLIInput",BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,-8,0,tokenStyle.rowHeight),FontFace=Theme.mono,TextSize=tokenStyle.wordSize,
        Text="",TextTransparency=1,ClearTextOnFocus=false,MultiLine=false,TextWrapped=true,
        TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,ZIndex=4})
    self.hint=Theme.text(self.frame,"Opening prompt session...",11,c.dim,UDim2.new(0,12,1,-28),UDim2.new(1,-24,0,28))
    self.countLabel=Theme.text(self.panel,"",11,c.dim,UDim2.new(0,38,1,-46),UDim2.new(1,-158,0,40),Theme.mono)
    self.send,self.sellArt=Theme.pixelButton(self.panel,"SELL",UDim2.new(1,-108,1,-46),UDim2.fromOffset(96,40),function(input)
        if self.onActivate and self.onActivate(input)==false then return end
        self:sendPrompt("button")
    end)
    self.send.Name="SendPrompt"
    self.sellPose={}
    for _,part in ipairs(self.sellArt.parts) do self.sellPose[#self.sellPose+1]={part=part,home=part.Position} end
    self.sellPose[#self.sellPose+1]={part=self.sellArt.label,home=self.sellArt.label.Position}
    connect(self.input.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            self.focusPointer=input
            if self.onActivate and self.onActivate(input)==false then self.input:ReleaseFocus();return end
            self.inputPaused=false
        end
    end)
    connect(self.input.Focused,function()
        if not self:canEdit() or (self.onActivate and self.onActivate(self.focusPointer)==false) then self.input:ReleaseFocus();return end
        self.focusPointer=nil;self.inputPaused=false;self.caret.Visible=true
    end)
    connect(self.input:GetPropertyChangedSignal("Text"),function()
        if self.changingText then return end
        local value=self.input.Text
        if value=="" then return end
        self.changingText=true;self.input.Text="";self.changingText=false
    end)
    connect(self.input.FocusLost,function(enterPressed)
        self.caret.Visible=false
        if enterPressed then self:sendPrompt() end
    end)
    connect(self.input.ReturnPressedFromOnScreenKeyboard,function() self:sendPrompt() end)
    self.cashLayer=Theme.create("Frame",payoutParent or parent,{Name="MoneyFeedback",BackgroundTransparency=1,
        BorderSizePixel=0,Size=UDim2.fromScale(1,1),ZIndex=30})
    for index=1,Cash.MAX_LABELS do
        local label=Theme.text(self.cashLayer,"",24,c.mint,UDim2.fromScale(0.5,0.55),UDim2.fromOffset(240,44),Theme.mono)
        label.Name,label.AnchorPoint,label.Visible="Money"..index,Vector2.new(0.5,0.5),false
        label.TextXAlignment=Enum.TextXAlignment.Center;self.cashLabels[index]=label
    end
    connect(UserInputService.InputBegan,function(input,processed)
        if input.UserInputType~=Enum.UserInputType.Keyboard then return end
        local focused=UserInputService:GetFocusedTextBox()
        if focused and focused~=self.input then return end
        if self:hasModifier() then return end
        local name=input.KeyCode.Name
        if self.keysDown[name] then return end
        self.keysDown[name]=true
        if focused==self.input then
            if name=="Backspace" then self:removeWord() end
            if name=="Return" or name=="KeypadEnter" then self:sendPrompt() end
            return -- Native Return callbacks share the same once-only dispatch.
        end
        if processed then return end
        if name=="Return" or name=="KeypadEnter" then self:sendPrompt()
        elseif name=="Backspace" then self:removeWord()
        end
    end)
    connect(UserInputService.InputEnded,function(input)
        if input.KeyCode then self.keysDown[input.KeyCode.Name]=nil end
    end)
    connect(UserInputService.WindowFocusReleased,function() self.keysDown={};self.windowFocused=false;self:blur() end)
    connect(UserInputService.WindowFocused,function() self.windowFocused=true end)
    connect(GuiService:GetPropertyChangedSignal("MenuIsOpen"),function() if GuiService.MenuIsOpen then self:blur() end end)
    connect(self.log:GetPropertyChangedSignal("CanvasPosition"),function()
        if self.resizing then return end
        self.follow=self.log.CanvasPosition.Y>=self.log.AbsoluteCanvasSize.Y-self.log.AbsoluteWindowSize.Y-24
        self.latest.Visible=not self.follow
    end)
    connect(list:GetPropertyChangedSignal("AbsoluteContentSize"),function()
        self.resizing=true;self.log.CanvasSize=UDim2.fromOffset(0,list.AbsoluteContentSize.Y+12)
        if self.follow then self:scrollBottom() end
        self.resizing=false
    end)
    connect(self.preview:GetPropertyChangedSignal("AbsoluteSize"),function() self:refreshInput() end)
    connect(RunService.Heartbeat,function(dt)
        -- During prestige, only advance the presentation/audio owner. Avoid
        -- rewriting hidden terminal controls, chips and logs while roots scale.
        if self.presentationPaused then
            if self.onTick then self.onTick(dt) end
            return
        end
        if (not self.suspended or self.autoSell) and self:canAutomate() then self:tickReveals(dt) end
        self:tickDispatch()
        if self.onBeforeAgents then self.onBeforeAgents() end
        self:tickAgents(dt)
        self:tickCollection(dt)
        self:tickSellPress(dt)
        if self.onTick then self.onTick(dt) end
        if not self.blocked then
            local revision=self.session.revision;Agent.tick(self.session,dt,self.reduced,self.tuning and self.tuning.jobDuration)
            if revision~=self.session.revision then self:renderLog() end
        end
        Cash.tick(self.cash,dt,self.tuning and self.tuning.cashDuration,not self:canEdit());self:renderCash();self:refreshState();self:refreshControls()
        if Composer.timeout(self.composer,os.clock(),balance) then
            self.autoSellBlockedDraft=self.saleFlight and self.saleFlight.draftId
            self.sendRequested=false;self.hint.Text="Response delayed. Syncing; your prompt was not resent."
            if self.onSync then self.onSync() end
            self:refreshInput()
        end
    end)
    self:boot();return self
end

function Terminal:boot()
    Agent.append(self.session,"VibeIdle / CLI v"..self.balance.BUILD_VERSION,"accent")
    Agent.append(self.session,"Agents write tokens. Click the circle to build streak. Press Enter or SELL to cash out.","text")
    Agent.append(self.session,"Colored words are special. Open Guide for chances.","muted")
    self:renderLog()
end
function Terminal:scrollBottom()
    self.log.CanvasPosition=Vector2.new(0,math.max(0,self.log.CanvasSize.Y.Offset-self.log.AbsoluteWindowSize.Y));self.latest.Visible=false
end
function Terminal:renderLog()
    local colors={text=c.ink,muted=c.dim,accent=c.syntax,success=c.mint}
    for index,row in ipairs(self.rows) do
        local line=self.session.lines[index];row.Visible=line~=nil
        if line then row.Text,row.TextColor3=line.text,colors[line.kind] or Theme.rarity[line.kind] or c.ink end
    end
end
function Terminal:renderCash()
    for index,label in ipairs(self.cashLabels) do
        local item=self.cash.items[index];label.Visible=item~=nil and (not item.tokenIndex or self:canEdit())
        if item then
            local y,alpha=Cash.pose(item,self.reduced,self.tuning and self.tuning.cashDuration)
            label.Text="+"..Theme.money(item.amount)
            label.TextSize=item.tokenIndex and 15 or 24
            local width=item.tokenIndex and math.min(240,self.frame.Parent.AbsoluteSize.X) or 240
            label.Size=UDim2.fromOffset(width,44)
            local x=item.tokenIndex and math.max(width/2,math.min(self.frame.Parent.AbsoluteSize.X-width/2,item.x)) or 0
            local top=item.tokenIndex and math.max(62,math.min(self.cashLayer.AbsoluteSize.Y-22,item.y)) or 0
            label.Position=item.tokenIndex and UDim2.fromOffset(x,top+y)
                or UDim2.new(0.5,((item.id%5)-2)*28,0.55,y-(index-1)*14)
            label.TextTransparency=alpha
        end
    end
end
function Terminal:tickCollection(dt)
    local events=Collection.tick(self.collection,dt,self:canEdit() or (self.autoSell and self:canAutomate()))
    if #events==0 then return end
    local origin,size=self.cashLayer.AbsolutePosition,self.cashLayer.AbsoluteSize
    for _,event in ipairs(events) do
        local piece=self.soldLookup[event.receiptId] and self.soldLookup[event.receiptId][event.tokenIndex]
        if piece and not self.suspended then
            local p,s=piece.AbsolutePosition,piece.AbsoluteSize
            local visibleWidth=math.min(size.X,self.frame.Parent.AbsoluteSize.X)
            local half=math.min(120,visibleWidth/2)
            local x=math.max(half,math.min(visibleWidth-half,p.X+s.X/2-origin.X))
            local y=math.max(62,math.min(size.Y-22,p.Y+s.Y/2-origin.Y))
            Cash.token(self.cash,event,x,y)
        end
        if self.onTokenCollected then self.onTokenCollected(event) end
    end
    self:refreshInput();self:renderCash()
end
function Terminal:displayOffers()
    local offers={}
    for _,batch in ipairs(self.collection.batches) do
        for _,offer in ipairs(batch.offers) do offers[#offers+1]=offer end
    end
    local sold=#offers
    local draft=self.composer.draft
    for index=1,self.composer.count do offers[#offers+1]=draft.offers[index] end
    return offers,sold
end
function Terminal:soldPiece(index)
    if self.soldTokens[index] then return self.soldTokens[index] end
    local piece=Theme.create("Frame",self.preview,{Name="SoldToken"..index,Visible=false,BorderSizePixel=0,
        Active=false,Selectable=false,BackgroundColor3=c.paper,Size=UDim2.fromOffset(57,tokenStyle.height)})
    Theme.round(piece,5)
    local border=Theme.outline(piece)
    local word=Theme.text(piece,"",tokenStyle.wordSize,c.ink,UDim2.fromOffset(tokenStyle.padding,0),UDim2.new(1,-tokenStyle.padding*2,1,0),Theme.mono)
    word.Name,word.TextWrapped="Word",false
    word.TextTruncate=Enum.TextTruncate.AtEnd
    word.Active,word.Selectable=false,false
    local badge=Theme.text(piece,"",tokenStyle.badgeSize,c.ink,UDim2.new(1,-38,0,0),UDim2.fromOffset(32,tokenStyle.height),Theme.mono)
    badge.Name,badge.TextWrapped,badge.TextXAlignment="Multiplier",false,Enum.TextXAlignment.Right
    badge.Active,badge.Selectable=false,false
    self.soldTokens[index]={frame=piece,word=word,badge=badge,border=border}
    return self.soldTokens[index]
end
function Terminal:styleToken(piece,word,badge,border,geometry,offer)
    local skill=offer.skillMultiplier or 1
    local hasBadge=offer.rank>1 or skill>1
    local color=Theme.rarity[offer.rarity] or c.ink
    piece.Position,piece.Size=UDim2.fromOffset(geometry.x,geometry.y),UDim2.fromOffset(geometry.width,tokenStyle.height)
    piece.BackgroundColor3=offer.rank>1 and color or c.paper
    piece.BackgroundTransparency=offer.rank>1 and 0.85 or 0.3
    border.Color=offer.rank>1 and color or c.black
    word.Text,word.TextColor3=offer.word,color
    word.Size=UDim2.new(1,-(tokenStyle.padding*2+(hasBadge and geometry.badgeWidth+tokenStyle.badgeGap or 0)),1,0)
    badge.Size=UDim2.fromOffset(geometry.badgeWidth,tokenStyle.height)
    badge.Position=UDim2.new(1,-tokenStyle.padding-geometry.badgeWidth,0,0)
    badge.Visible,badge.Text,badge.TextColor3=hasBadge,"x"..string.format("%g",offer.multiplier*skill),skill>1 and c.mint or color
    piece:SetAttribute("SkillGrade",offer.skillGrade or "Normal")
    piece:SetAttribute("SkillMultiplier",skill)
    piece:SetAttribute("StreakMultiplier",offer.streakMultiplier or 1)
    piece:SetAttribute("StreakAtHit",offer.streakAtHit or 0)
    if piece:GetAttribute("Word")~=offer.word or piece:GetAttribute("Rarity")~=offer.rarity then
        piece:SetAttribute("Word",offer.word);piece:SetAttribute("Rarity",offer.rarity)
        piece:SetAttribute("Multiplier",offer.multiplier)
    end
end
function Terminal:canEdit()
    local focused=UserInputService:GetFocusedTextBox()
    return self.windowFocused and not self.uiTransition and not self.onboardingPaused and not self.billingBusy and not self.presentationPaused and not self.progressionPending and not self.blocked and not self.suspended and not GuiService.MenuIsOpen
        and (not focused or focused==self.input) and not self:hasModifier()
end
function Terminal:canAutomate()
    local focused=UserInputService:GetFocusedTextBox()
    return self.windowFocused and not self.uiTransition and not self.onboardingPaused and not self.billingBusy and not self.presentationPaused and not self.progressionPending and not self.blocked and not GuiService.MenuIsOpen
        and (not focused or focused==self.input) and not self:hasModifier()
end
function Terminal:isCollecting()
    return #self.collection.batches>0
end
function Terminal:tickSellPress(dt)
    if self.sellPressAge==nil then return end
    self.sellPressAge=self.sellPressAge+math.max(0,math.min(0.1,dt))
    local age=self.sellPressAge
    local offset=age<0.05 and 3 or age<0.09 and -2 or age<0.12 and 1 or 0
    if self.reduced or not self:canEdit() or age>=0.16 then offset=0;self.sellPressAge=nil end
    for _,pose in ipairs(self.sellPose) do
        local p=pose.home
        pose.part.Position=UDim2.new(p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset+offset)
    end
end
function Terminal:tickAgents(dt)
    if self.agentPending then
        self.agentPending.age=self.agentPending.age+dt
        local attempts=self.agentPending.syncAttempts or 0
        if self.agentPending.age>=(self.tuning and self.tuning.grantTimeout or 12) then
            -- Only word grants are uncertain; no payment happened here. Resume
            -- with a new nonce and the same fixed prefix, never resend a prompt.
            self.agentPending=nil;self.nextAgent=os.clock()+self.balance.AGENT_POLL_INTERVAL
            self:refreshControls()
        elseif attempts<3 and self.agentPending.age>=(self.tuning and self.tuning.syncDelay or 3)*(attempts+1) then
            self.agentPending.syncAttempts=attempts+1
            if self.onAgentSync then self.onAgentSync(self.agentPending.payload) end
        end
        return
    end
    if not self.onAgent or not self:canAutomate() or not self.composer.draft or self.composer.flight or self.saleFlight
        or self.skillPending or self.sendRequested or self:isCollecting() or self.composer.count>=self.limit then return end
    local deadline=self.nextAgent
    if os.clock()+0.000001<math.max(deadline,self.nextAgentPacket or 0) then return end
    self.nextAgentPacket=os.clock()+self.balance.AGENT_POLL_INTERVAL
    self.nextAgent=self.nextAgentPacket
    self.agentSequence=self.agentSequence+1
    local payload={requestId=self.agentSequence,draftId=self.composer.draft.id,tokenIndex=self.composer.count+1}
    self.agentPending={payload=payload,age=0}
    self:refreshControls();self.onAgent(payload)
end
function Terminal:hasModifier()
    for _,key in ipairs({Enum.KeyCode.LeftControl,Enum.KeyCode.RightControl,Enum.KeyCode.LeftAlt,Enum.KeyCode.RightAlt,Enum.KeyCode.LeftMeta,Enum.KeyCode.RightMeta}) do
        if UserInputService:IsKeyDown(key) then return true end
    end
    return false
end
function Terminal:instantTokens()
    return (self.wordsPerClick or 1)>=self.balance.INSTANT_TOKEN_TPC
        or (self.totalAgentWordsPerSecond or 0)>=self.balance.INSTANT_TOKEN_RATE
end
function Terminal:beginReveal(index,delay,agentIndex,instant)
    local word=self.composer.draft.offers[index].word
    if self.reduced or self:instantTokens() or instant then
        self.reveals[index]=nil;self.tokenWords[index].MaxVisibleGraphemes=-1;return
    end
    self.tokenWords[index].MaxVisibleGraphemes=0
    self.reveals[index]={word=word,length=#word,age=0,lastTime=os.clock(),delay=delay or 0,
        speed=agentIndex and (self.agentTypingCaps and self.agentTypingCaps[agentIndex] or self.speed) or 4,agentIndex=agentIndex}
end
function Terminal:finishReveals()
    for index in pairs(self.reveals) do self.tokenWords[index].MaxVisibleGraphemes=-1 end
    self.reveals={}
    if self.restCaret then self.caret.Position=UDim2.fromOffset(self.restCaret.X,self.restCaret.Y) end
end
function Terminal:tickReveals(dt)
    local now=os.clock()
    for index,reveal in pairs(self.reveals) do
        if index>self.composer.count then
            self.tokenWords[index].MaxVisibleGraphemes=-1;self.reveals[index]=nil
        else
            -- Do not count time before creation or paused page/menu time.
            reveal.age=reveal.age+math.min(math.max(0,dt),math.max(0,now-reveal.lastTime))
            reveal.lastTime=now
            local visible,done=Composer.revealCount(reveal.length,math.max(0,reveal.age-reveal.delay)*(self.tuning and self.tuning.revealScale or 1),reveal.speed,self.reduced)
            self.tokenWords[index].MaxVisibleGraphemes=done and -1 or visible
            if index==self.composer.count then
                if done and self.restCaret then
                    self.caret.Position=UDim2.fromOffset(self.restCaret.X,self.restCaret.Y)
                else
                    local p=self.tokens[index].Position
                    self.caret.Position=UDim2.fromOffset(p.X.Offset+7+Theme.textWidth(string.sub(reveal.word,1,visible),15),p.Y.Offset+3)
                end
            end
            if done then self.reveals[index]=nil end
        end
    end
end
function Terminal:blur()
    self.inputPaused=true
    if not self.sendAutomatic then self.sendRequested=false end
    self.input:ReleaseFocus()
end
function Terminal:focusInput()
    if self:canEdit() then self.inputPaused=false end -- Touch uses the circle, no keyboard popup.
end
function Terminal:appendWords(count)
    if not self:canEdit() or self.agentPending or self.composer.flight or self.saleFlight or self.sendRequested or self:isCollecting() or not self.composer.draft then return false end
    local available=self.limit-self.composer.count
    if available<=0 then self.hint.Text="Context full. Press Enter or SELL.";return false end
    self.inputPaused=false
    if self.onInput then self.onInput() end
    self:appendManualWords(math.min(count,available));return true
end
function Terminal:tickDispatch()
    if self.composer.flight then return end
    if self.sendRequested then self:dispatch() end
end
function Terminal:appendManualWords(count)
    for _=1,math.min(count,self.limit-self.composer.count) do
        if not Composer.push(self.composer,self.limit) then break end
        self:beginReveal(self.composer.count,nil,nil,count>=self.balance.INSTANT_TOKEN_TPC)
    end
    self:refreshInput()
end
function Terminal:appendAgentWords(result)
    local before=self.composer.count
    for _,source in ipairs(result.sources or {{agentIndex=1,wordCount=result.wordCount}}) do
        for _=1,source.wordCount do
            if not Composer.push(self.composer,self.limit) then break end
            self:beginReveal(self.composer.count,0,source.agentIndex)
        end
    end
    if self.autoSell and not self.tutorialActive and before<self.limit and self.composer.count==self.limit and not self.composer.flight and not self.sendRequested
        and self.autoSellBlockedDraft~=self.composer.draft.id then
        self.sendRequested=self.composer.draft.id;self.sendAutomatic=true
    end
    self:refreshInput()
end
function Terminal:refreshControls()
    self.input.TextEditable=false
    local available=self:canEdit() and self.composer.draft~=nil
    self.send.Active,self.send.Selectable=available,available
    self.send.Text="SELL"
    -- Busy/empty/queued states retain the normal pixel artwork. Activation is
    -- guarded separately and repeated presses never create another sale.
    for _,part in ipairs(self.sellArt.parts) do part.BackgroundColor3=c.accent end
    self.sellArt.label.TextColor3=c.terminal
    self.send:SetAttribute("Queued",self.sendRequested and true or false)
    self.caret.Visible=not self.suspended and not self.blocked and not self.composer.flight and not self.inputPaused
end
function Terminal:refreshState()
    local state="READY"
    if self.blocked then state=self.initialized and "PAUSED" or "OFFLINE"
    elseif not self.composer.draft then state="SYNCING"
    elseif self.composer.flight or self.saleFlight then state="SELLING"
    elseif self:isCollecting() then state="COLLECTING"
    elseif self.sendRequested then state="SELL QUEUED"
    elseif self.composer.count>=self.limit then state="FULL / SELL"
    elseif self.session.active then state=({"PLANNING","EDITING","TESTING"})[self.session.step] end
    if self.stateLabel.Text~=state then self.stateLabel.Text=state end
    self.progress.Size=UDim2.new(self.session.active and not self.reduced and not self.blocked and math.min(1,self.session.elapsed/(self.tuning and self.tuning.jobDuration or Agent.DURATION)) or 0,0,0,2)
end
function Terminal:refreshInput()
    if self.fitting or self.presentationPaused then return end
    self:fitPrompt()
    local draft=self.composer.draft
    local viewport=self.preview.AbsoluteSize
    local stamp=string.format("%s:%d:%g:%g:%g:%d:%d",draft and draft.id or 0,self.composer.count,
        viewport.X,viewport.Y,self.totalSpeed or self.speed,self.limit,self.collection.revision)
    if stamp==self.tokenStamp then self:refreshControls();return end
    self.tokenStamp=stamp
    local offers,sold=self:displayOffers()
    local positions,x,y,height=Composer.tokenLayout(offers,#offers,math.max(24,self.preview.AbsoluteSize.X-10),Theme.textWidth)
    for index,piece in ipairs(self.tokens) do
        local geometry=index<=self.composer.count and positions[sold+index] or nil;piece.Visible=geometry~=nil
        if geometry then
            local offer=draft.offers[index]
            local word,badge=self.tokenWords[index],self.tokenBadges[index]
            self:styleToken(piece,word,badge,self.tokenBorders[index],geometry,offer)
        end
    end
    self.soldLookup={}
    local slot=0
    for _,batch in ipairs(self.collection.batches) do
        self.soldLookup[batch.id]={}
        for index,offer in ipairs(batch.offers) do
            slot=slot+1
            local view=self:soldPiece(slot)
            view.frame.Visible=index>batch.cursor
            view.word.MaxVisibleGraphemes=-1
            self:styleToken(view.frame,view.word,view.badge,view.border,positions[slot],offer)
            self.soldLookup[batch.id][index]=view.frame
        end
    end
    for index=slot+1,#self.soldTokens do self.soldTokens[index].frame.Visible=false end
    self.placeholder.Visible=self.composer.count==0 and sold==0
    self.caret.Position=UDim2.fromOffset(x,y+5)
    self.restCaret=Vector2.new(x,y+5)
    self.input.Size=UDim2.new(1,-8,0,math.max(height,self.preview.AbsoluteSize.Y))
    self.countLabel.Text=string.format("%d/%d | Agents cap %g/s",self.composer.count,self.limit,self.totalSpeed or self.speed)
    self:refreshControls()
end
function Terminal:removeWord()
    if self.tutorialActive then return end
    if self.skillPending or self.agentPending then return end
    self.sendRequested=false
    if not self:canEdit() or self.composer.flight then return end
    Composer.pop(self.composer)
    for index in pairs(self.reveals) do
        if index>self.composer.count then self.tokenWords[index].MaxVisibleGraphemes=-1;self.reveals[index]=nil end
    end
    self:refreshInput()
end
function Terminal:sendPrompt(source)
    if self.tutorialActive and self.tutorialStep~="Sell" then return end
    if not self:canEdit() or not self.composer.draft then return end
    if self.onSellAttempt and (source=="button" or not self.lastReportedEnter or os.clock()-self.lastReportedEnter>=.1) then
        if source~="button" then self.lastReportedEnter=os.clock() end
        self.onSellAttempt(source=="button" and "button" or "enter")
    end
    self.sellPressAge=0;self:tickSellPress(0)
    if self.composer.flight or self.saleFlight or self.sendRequested or self:isCollecting() then return end
    if self.composer.count==0 and not self.skillPending and not self.agentPending then
        self.hint.Text="Wait for your agents to write tokens first.";return
    end
    -- One explicit sale intent, scoped to this draft. Stop new generators while
    -- the current grant and its cosmetic writing settle; never queue words.
    self.inputPaused=false;self.sendRequested=self.composer.draft.id;self.sendAutomatic=false
    if self.onSellPress then self.onSellPress() end
    self.hint.Text="Sell queued. Waiting for token writing..."
    self:refreshControls();self:refreshState()
    self:tickDispatch()
end
function Terminal:dispatch()
    if self.tutorialActive and (self.tutorialStep~="Sell" or self.sendAutomatic) then return end
    local ready=self.sendAutomatic and self:canAutomate() or (self:canEdit() and not self.inputPaused)
    if not self.sendRequested or not ready or self.skillPending or self.agentPending then return end
    if not self.composer.draft or self.sendRequested~=self.composer.draft.id then self.sendRequested=false;return end
    if next(self.reveals) then return end
    if self.composer.count==0 then
        self.sendRequested=false;self.hint.Text="Nothing to sell. Wait for your agents to write tokens first."
        self:refreshControls();self:refreshState();return
    end
    if self.promptReadyAt and Workspace:GetServerTimeNow()<self.promptReadyAt then return end
    local request=Composer.send(self.composer,os.clock(),self.limit,self.balance)
    if not request then return end
    self.saleFlight=Collection.capture(self.composer.draft,request.tokens)
    self.sendRequested=false;self.sendAutomatic=false
    if self.onInput then self.onInput() end
    self.hint.Text="Sale submitted. Waiting for confirmation..."
    self:refreshControls();self.submit(request)
end
function Terminal:update(data)
    self.autoSell=data.progression and data.progression.autoSell==true
    local first=not self.initialized
    local deckStamp=Cards.key(data.cardDeck,self.balance)
    local deckChanged=deckStamp~=self.cardDeckStamp
    self.cardDeckStamp=deckStamp
    local oldInterval=self.tuning and self.tuning.agentInterval
    local oldProduction=self.agentWordsPerSecond
    self.tuning=RunService:IsStudio() and data.studioTuning or nil
    self.composer.responseTimeout=self.tuning and self.tuning.responseTimeout
    self.promptReadyAt=data.promptReadyAt
    local producerDelay=data.nextAgentAt and math.max(0,data.nextAgentAt-Workspace:GetServerTimeNow())
        or data.nextAgentDelay or self.balance.AGENT_INTERVAL
    local producerDeadline=os.clock()+producerDelay
    local resetRun=(self.prestigeCount~=nil and self.prestigeCount~=data.prestigeCount) or (self.batches and self.batches>0 and data.batches==0)
    if resetRun then
        self.composer.count,self.composer.flight=0,nil
        self.agentRevealTimes={};self.sendRequested=false
        self.agentPending=nil;self.nextAgent=os.clock()+self.balance.AGENT_INTERVAL
        Agent.reset(self.session);Cash.reset(self.cash);Collection.reset(self.collection);self.saleFlight=nil;self.follow=true;self:boot();self:renderCash()
    end
    self.prestigeCount=data.prestigeCount
    self.blocked,self.limit,self.batches,self.base=data.blocked,data.tokenLimit,data.batches,data.moneyPerToken or 1
    self.streakDivisor=data.streakDivisor or self.balance.STREAK_BASE_DIVISOR
    self.baseWords=1+data.clickLevel
    self.wordsPerClick=Skill.wordsPerClick(data.stats and data.stats.streak or 0,self.baseWords,self.streakDivisor)
    self.agentWordsPerSecond=data.agentWordsPerSecond
    self.totalAgentWordsPerSecond=data.totalAgentWordsPerSecond or (data.agentWordsPerSecond or 0)*(#data.layerSizes-2)
    if self:instantTokens() then self:finishReveals();self.agentRevealTimes={} end
    self.speed=data.agentTypingSpeed or Prompt.agentTypingRate(data,self.balance)
    self.agentTypingCaps=data.agentTypingCaps
    self.totalSpeed=data.totalAgentTypingSpeed or self.speed*(#data.layerSizes-2)
    if self.blocked then self:blur() end
    local confirmed=Composer.confirm(self.composer,data.lastPrompt,first,os.clock(),self.balance)
    if data.draft and Composer.update(self.composer,data.draft,self.balance,Prompt) then
        self.sendRequested=false
        self:finishReveals()
    end
    -- A read-only full draft after timeout proves that this nonce is still
    -- unpaid. Release the visual lock, but require an explicit sale for it.
    if self.saleFlight and not self.composer.flight and data.draft and data.draft.id==self.saleFlight.draftId then
        self.autoSellBlockedDraft=data.draft.id;self.saleFlight=nil
        self.hint.Text="Sale not confirmed. Press Enter or SELL to try explicitly."
    end
    if data.lastAgent then self.agentSequence=math.max(self.agentSequence,data.lastAgent.requestId) end
    local pending=self.agentPending
    if pending then
        local request=pending.payload;local result=data.lastAgent
        if result and result.requestId==request.requestId and result.draftId==request.draftId
            and result.tokenIndex==request.tokenIndex then
            self.agentPending=nil
            self.nextAgent=producerDeadline
            if self.composer.draft and self.composer.draft.id==request.draftId
                and self.composer.count==request.tokenIndex-1 then
                self:appendAgentWords(result)
            end
        elseif data.agentRejected==request.requestId or data.agentSyncId==request.requestId then
            self.agentPending=nil
            self.nextAgent=producerDeadline
        end
    end
    if first then
        Agent.accept(self.session,data.lastPrompt,true,Prompt,self.balance);Cash.accept(self.cash,data.lastPrompt,true,self.balance)
        Collection.accept(self.collection,data.lastPrompt,nil,true,self.balance)
    end
    if first or resetRun or deckChanged or (self.tuning and self.tuning.agentInterval~=oldInterval) or oldProduction~=self.agentWordsPerSecond then self.nextAgent=producerDeadline end
    self.initialized=true
    if confirmed then
        if self.onSaleConfirmed then self.onSaleConfirmed(data.lastPrompt) end
        Agent.accept(self.session,data.lastPrompt,false,Prompt,self.balance)
        local collected=Collection.accept(self.collection,data.lastPrompt,self.saleFlight,false,self.balance)
        Cash.accept(self.cash,data.lastPrompt,collected,self.balance)
        if self.saleFlight and self.saleFlight.draftId==(data.lastPrompt.draftId or data.lastPrompt.id) then self.saleFlight=nil end
        if self.reduced then Agent.tick(self.session,0,true) end
        self:renderLog();self:renderCash()
        self.hint.Text=string.format("Sale #%03d confirmed / %d tokens / +%s",data.lastPrompt.id,data.lastPrompt.tokens,Theme.money(data.lastPrompt.reward))
    elseif data.promptRejected then
        self.composer.flight=nil;self.sendRequested=false;self.saleFlight=nil;self.hint.Text=data.message or "Sale rejected. Use Enter or SELL to try again."
    elseif data.blocked then self.hint.Text=data.message or "Session paused. Please rejoin."
    elseif not self.composer.draft then self.hint.Text="Opening your prompt..."
    elseif first then self.hint.Text="Build your tokens, then press Enter or SELL to cash out." end
    self:refreshInput();self:tickCollection(0);self:refreshState();return confirmed
end
function Terminal:setSuspended(value)
    self.suspended=value;if value then self:blur();self:tickSellPress(0) end;self:refreshControls()
end
function Terminal:setReducedMotion(value)
    self.reduced=value
    self:tickSellPress(0)
    if value then self:finishReveals() end
    if value and not self.blocked then Agent.tick(self.session,0,true);self:renderLog() end
    self:renderCash();self:refreshState()
end
function Terminal:fitPrompt()
    self.fitting=true
    local viewport=self.frame.Parent.AbsoluteSize
    local maxWidth=math.max(viewport.X,self.canvasWidth or 0)
    local rosterHeight=self.onFitRoster and self.onFitRoster(math.min(maxWidth,self.stableWidth or self.frame.Size.X.Offset)) or 0
    local draft=self.composer.draft
    local stable=Composer.windowLayout(draft and draft.offers or {},self.composer.count,
        math.max(1,self.stableWidth or self.frame.Size.X.Offset),math.max(1,self.stableHeight or self.frame.Size.Y.Offset),
        maxWidth,math.max(1,viewport.Y-(self.bottomClearance or 44)),self.short,Theme.textWidth,rosterHeight)
    self.stableWidth,self.stableHeight=stable.width,stable.height
    local offers=self:displayOffers()
    local geometry=Composer.windowLayout(offers,#offers,stable.width,stable.height,
        maxWidth,math.max(1,viewport.Y-(self.bottomClearance or 44)),self.short,Theme.textWidth,rosterHeight)
    local size=UDim2.fromOffset(geometry.width,geometry.height)
    local changed=self.frame.Size.X.Offset~=geometry.width or self.frame.Size.Y.Offset~=geometry.height
    self.frame.Size=size
    if changed then
        -- Content grows downward; keep the chosen origin and let the outer
        -- desktop expose the extra height instead of jumping behind the header.
        local x=math.max(0,math.min(self.frame.Position.X.Offset,maxWidth-geometry.width))
        local y=math.max(0,self.frame.Position.Y.Offset)
        self.frame.Position=UDim2.fromOffset(x,y)
    end
    local short=self.short
    local welcome=not short and (self.batches or 0)==0 and size.Y.Offset>=460
        and size.Y.Offset-geometry.panelHeight-28>=220+rosterHeight
    self.welcome.Position=UDim2.fromOffset(14,54+rosterHeight)
    self.welcome.Visible=welcome;self.welcomeDetail.Visible=size.X.Offset>=620
    self.welcomeHeading.Size=UDim2.new(size.X.Offset>=620 and 0.55 or 1,-32,0,28)
    self.welcomeCopy.Size=UDim2.new(size.X.Offset>=620 and 0.55 or 1,-32,0,52)
    local logTop=(welcome and 182 or 54)+rosterHeight
    local panelHeight=geometry.panelHeight
    self.panel.Position,self.panel.Size=UDim2.new(0,0,1,-panelHeight-28),UDim2.new(1,0,0,panelHeight)
    self.log.Position,self.log.Size=UDim2.fromOffset(16,logTop),UDim2.new(1,-32,0,math.max(0,size.Y.Offset-logTop-panelHeight-38))
    self.log.Visible=self.log.Size.Y.Offset>=28
    self.latest.Position=UDim2.new(1,-78,1,-panelHeight-72)
    if not self.log.Visible then self.latest.Visible=false end
    self.fitting=false
    if self.onLayoutChanged then self.onLayoutChanged() end
end
function Terminal:layout(position,size,short)
    self.stableWidth,self.stableHeight=size.X.Offset,size.Y.Offset
    self.short=short;self.frame.Position,self.frame.Size=position,size
    self:refreshInput()
end
function Terminal:destroy()
    self.alive=false
    self.onBeforeAgents=nil;self.onSellAttempt=nil
    Collection.reset(self.collection);self.onTokenCollected=nil;self.onSellPress=nil;self.saleFlight=nil
    self.reveals={}
    for _,connection in ipairs(self.connections) do connection:Disconnect() end
    self.mascot:destroy()
    self.cashLayer:Destroy();self.frame:Destroy()
end
return Terminal

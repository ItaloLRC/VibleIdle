--!nonstrict
local Theme=require(script.Parent.DeskTheme)
local UserInputService=game:GetService("UserInputService")
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Rules=require(Shared.PrestigeRules)
local TreeLayout=require(Shared.SkillTreeLayout)
local c=Theme.colors
local Page={};Page.__index=Page
local palettes={
    core={edge=c.accent,face=Color3.fromRGB(55,35,43)},tokens={edge=c.amber,face=Color3.fromRGB(53,42,30)},
    agents={edge=c.mint,face=Color3.fromRGB(27,48,43)},focus={edge=Color3.fromRGB(133,198,255),face=Color3.fromRGB(26,39,57)},
    luck={edge=Color3.fromRGB(215,172,255),face=Color3.fromRGB(46,31,59)},
    memory={edge=Color3.fromRGB(249,204,111),face=Color3.fromRGB(53,45,31)},swarm={edge=c.accent,face=Color3.fromRGB(54,34,30)},
}
-- Authored 8x8 native pixel icons; no uploaded images or runtime assets.
local icons={
    boot={"...aa...","..abba..",".abbbba.","abbbbbba","..acca..","..acca..",".acccca.","aa....aa"},
    tokens={"..aaaa..",".abbbba.","abbccbba","abcbbcba","abcbbcba","abbccbba",".abbbba.","..aaaa.."},
    agents={"..aaaa..",".abbbba.","abbccbba","abbbbbba",".abbbba.","..aaaa..",".acccca.","aa....aa"},
    focus={"...aa...","...aa...","..abba..","aabccbaa","aabccbaa","..abba..","...aa...","...aa..."},
    cache={"........",".aaaaaa.","abbbbbba","abccccba","aaaaaaaa","abbccbba","abbbbbba",".aaaaaa."},
    swarm={"aa....aa","abbaabba",".aa..aa.","...aa...","..abba..","...aa...","aa....aa","abbaabba"},
    context={"aaaaaaaa","abbbbbba","abcccbba","abbbbbba","abcccbba","abbbbbba","abcccbba","aaaaaaaa"},
    core={"...aa...","..abba..",".abccba.","abccccba","abccccba",".abccba.","..abba..","...aa..."},
}
local function pixelRect(parent,name,x,y,width,height,color,z)
    return Theme.create("Frame",parent,{Name=name,BorderSizePixel=0,Active=false,Selectable=false,
        BackgroundColor3=color,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(width,height),ZIndex=z or 1})
end
local function hexPanel(parent)
    local borders,faces={},{}
    for _,r in ipairs(TreeLayout.hex()) do borders[#borders+1]=pixelRect(parent,"HexEdge",r.x,r.y,r.width,r.height,c.line,2) end
    for _,r in ipairs(TreeLayout.hex(4)) do faces[#faces+1]=pixelRect(parent,"HexFace",r.x,r.y,r.width,r.height,c.paper,2) end
    return borders,faces
end
local function pixelIcon(parent,id,color)
    local root=Theme.create("Frame",parent,{Name="SkillIcon",BackgroundTransparency=1,BorderSizePixel=0,
        Active=false,Selectable=false,Position=UDim2.fromOffset(88,8),Size=UDim2.fromOffset(64,64),ZIndex=3})
    local palette={a=color,b=c.terminal,c=c.ink}
    local parts={}
    for y,row in ipairs(icons[id]) do
        for x=1,8 do
            local tint=palette[row:sub(x,x)]
            if tint then parts[#parts+1]=pixelRect(root,"Pixel",(x-1)*8,(y-1)*8,8,8,tint,3) end
        end
    end
    return root,parts
end
local function pointer(input)
    return input and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch)
end
local function contains(object,input)
    if not input or not input.Position then return false end
    local p,s=object.AbsolutePosition,object.AbsoluteSize
    return input.Position.X>=p.X and input.Position.X<p.X+s.X and input.Position.Y>=p.Y and input.Position.Y<p.Y+s.Y
end
function Page.new(parent,balance,submit)
    local self=setmetatable({balance=balance,submit=submit,sequence=0,nodes={},links={},connections={},positions={},mode="Prestige"},Page)
    self.treeBounds=TreeLayout.bounds(balance.PRESTIGE_NODES)
    self.frame=Theme.create("Frame",parent,{Name="ProgressionPage",Visible=false,Active=true,
        BackgroundColor3=Theme.pixelColors.base,BorderSizePixel=0})
    Theme.pixelPanel(self.frame,"PixelPage",UDim2.fromOffset(0,0),UDim2.fromScale(1,1))
    self.title=Theme.text(self.frame,"PRESTIGE",18,c.amber,UDim2.fromOffset(12,8),UDim2.new(1,-24,0,30))
    self.wallet=Theme.text(self.frame,"0 Chips",13,c.mint,UDim2.fromOffset(12,40),UDim2.new(1,-24,0,42))
    self.centerButton,self.centerArt=Theme.pixelButton(self.frame,"CORE",UDim2.new(1,-100,0,8),UDim2.fromOffset(88,32),function(input)
        if self.mode~="Tree" or not self:allowed(input,self.centerButton) then return end
        self:centerTree()
        if self.onAction then self.onAction("center_tree") end
    end)
    self.centerButton.TextSize=14;self.centerArt.label.TextSize=14
    self.body=Theme.create("ScrollingFrame",self.frame,{Name="ProgressionContent",BackgroundTransparency=1,
        BorderSizePixel=0,Active=true,ZIndex=2,Position=UDim2.fromOffset(8,64),Size=UDim2.new(1,-16,1,-92),
        CanvasSize=UDim2.fromOffset(648,570),CanvasPosition=Vector2.new(0,0),ScrollingDirection=Enum.ScrollingDirection.XY,ClipsDescendants=true,
        ScrollBarThickness=5,ScrollBarImageColor3=c.line})
    self.preview=Theme.text(self.body,"",13,c.text,UDim2.fromOffset(8,8),UDim2.fromOffset(400,284))
    self.preview.Name,self.preview.TextYAlignment="PrestigePreview",Enum.TextYAlignment.Top
    self.ascend,self.ascendArt=Theme.pixelButton(self.body,"PRESTIGE",UDim2.fromOffset(8,306),UDim2.fromOffset(260,48),function(input) self:ascendPress(input) end)
    self.ascend.Name="Ascend"
    self.prestigeBackdrop=Theme.create("Frame",self.frame,{Name="PrestigeBackdrop",BackgroundColor3=Color3.fromRGB(25,22,30),
        BorderSizePixel=0,Active=false,Selectable=false,ClipsDescendants=true,Size=UDim2.fromScale(1,1)})
    self.stripes={}
    for _=1,256 do
        local stripe=pixelRect(self.prestigeBackdrop,"StripePixel",0,0,1,1,Color3.fromRGB(32,26,37))
        stripe.BackgroundTransparency=0.35;self.stripes[#self.stripes+1]=stripe
    end
    self.titleBadge=Theme.pixelPanel(self.frame,"PrestigeTab",UDim2.new(1,-180,0,8),UDim2.fromOffset(168,32),c.accent)
    self.titleBadge.ZIndex=3;self.title.ZIndex=5
    self.figureShadows={}
    self.dashboard=Theme.create("Frame",self.body,{Name="PrestigeDashboard",BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.fromOffset(600,576)})
    local function panel(parent,name,position,size)
        local group=Theme.create("Frame",parent,{Name=name,BackgroundTransparency=1,BorderSizePixel=0,
            Active=false,Selectable=false,Position=position,Size=size})
        Theme.create("Frame",group,{Name="PixelDropShadow",BackgroundColor3=Color3.fromRGB(12,9,17),BorderSizePixel=0,
            Active=false,Selectable=false,Position=UDim2.fromOffset(4,6),Size=UDim2.new(1,0,1,-2)})
        local face,edges=Theme.pixelPanel(group,"PanelFace",UDim2.fromOffset(0,0),UDim2.fromScale(1,1),Color3.fromRGB(42,31,56))
        for _,edge in ipairs(edges) do edge.BackgroundColor3=c.black end
        pixelRect(face,"CornerLight",8,5,20,3,Color3.fromRGB(151,115,176))
        return group
    end
    local function label(parent,value,size,color,position,dimensions)
        local shadow=Theme.text(parent,value,size,Color3.fromRGB(12,9,17),position,dimensions)
        shadow.Name="PixelTextShadow";shadow.TextXAlignment=Enum.TextXAlignment.Center
        shadow.Active=false;shadow.Selectable=false;shadow.ZIndex=2
        local item=Theme.text(parent,value,size,color,position,dimensions)
        item.TextXAlignment=Enum.TextXAlignment.Center;item.Active=false;item.Selectable=false;item.ZIndex=3
        self.figureShadows[#self.figureShadows+1]={source=item,shadow=shadow}
        return item
    end
    self.intro=label(self.dashboard,"CHIPS = MORE CASH FOREVER.\nYOUR RUN STARTS OVER.",14,c.ink,UDim2.fromOffset(0,0),UDim2.new(1,0,0,64))
    self.chipBox=panel(self.dashboard,"WalletPanel",UDim2.fromOffset(0,56),UDim2.new(0.5,-8,0,144))
    self.chipHeading=label(self.chipBox,"YOU HAVE",14,c.ink,UDim2.fromOffset(8,12),UDim2.new(1,-16,0,28))
    self.walletChip=Theme.pixelChip(self.chipBox,UDim2.fromOffset(20,52),50)
    self.walletChip.ZIndex=2
    self.chipAmount=label(self.chipBox,"0",34,Color3.fromRGB(249,173,70),UDim2.fromOffset(80,44),UDim2.new(1,-96,0,60))
    self.chipCaption=label(self.chipBox,"CHIPS",14,c.muted,UDim2.fromOffset(8,136),UDim2.new(1,-16,0,32))
    self.perkBox=panel(self.dashboard,"BonusPanel",UDim2.new(0.5,8,0,56),UDim2.new(0.5,-8,0,144))
    self.perkHeading=label(self.perkBox,"EACH EARNED CHIP",14,c.ink,UDim2.fromOffset(8,12),UDim2.new(1,-16,0,40))
    self.perChip=label(self.perkBox,"+1%",38,Color3.fromRGB(137,235,142),UDim2.fromOffset(8,44),UDim2.new(1,-16,0,60))
    self.perkCaption=label(self.perkBox,"MORE TOKEN VALUE",14,c.muted,UDim2.fromOffset(8,136),UDim2.new(1,-16,0,32))
    self.rebirthBox=panel(self.dashboard,"RebirthPanel",UDim2.fromOffset(0,216),UDim2.new(1,0,0,360))
    self.heroHeading=label(self.rebirthBox,"A PRESTIGE NOW GIVES...",14,c.ink,UDim2.fromOffset(8,16),UDim2.new(1,-16,0,28))
    self.heroRow=Theme.create("Frame",self.rebirthBox,{Name="CenteredGain",BackgroundTransparency=1,BorderSizePixel=0,
        Active=false,Selectable=false,Position=UDim2.new(0.5,-96,0,56),Size=UDim2.fromOffset(192,96),ZIndex=2})
    self.heroChip=Theme.pixelChip(self.heroRow,UDim2.fromOffset(0,8),80)
    self.gain=label(self.heroRow,"+0",48,c.ink,UDim2.fromOffset(96,0),UDim2.fromOffset(96,96));self.gain.TextXAlignment=Enum.TextXAlignment.Left
    self.progressBar=Theme.pixelPanel(self.rebirthBox,"NextChipProgress",UDim2.fromOffset(20,168),UDim2.new(1,-40,0,40))
    self.progressFill=Theme.create("Frame",self.progressBar,{Name="ProgressFill",BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(63,91,78),
        Active=false,Selectable=false,Position=UDim2.fromOffset(4,4),Size=UDim2.new(0,0,1,-8)})
    self.progressText=label(self.progressBar,"0%",14,c.ink,UDim2.fromOffset(4,0),UDim2.new(1,-8,1,0))
    self.remaining=label(self.rebirthBox,"",12,Color3.fromRGB(235,139,120),UDim2.fromOffset(8,220),UDim2.new(1,-16,0,28))
    self.bonusDivider=Theme.rule(self.rebirthBox,UDim2.fromOffset(24,256),UDim2.new(1,-48,0,2),Color3.fromRGB(27,21,36))
    self.nowHeading=label(self.rebirthBox,"CASH BONUS NOW",14,c.text,UDim2.fromOffset(8,344),UDim2.new(0.5,-16,0,42))
    self.afterHeading=label(self.rebirthBox,"AFTER PRESTIGE",11,c.text,UDim2.new(0.5,8,0,272),UDim2.new(0.5,-16,0,22))
    self.bonusNow=label(self.rebirthBox,"+0%",30,c.ink,UDim2.fromOffset(8,300),UDim2.new(0.5,-24,0,44))
    self.bonusAfter=label(self.rebirthBox,"+0%",30,c.ink,UDim2.new(0.5,16,0,300),UDim2.new(0.5,-24,0,44))
    self.bonusArrow=label(self.rebirthBox,">",24,c.accent,UDim2.new(0.5,-12,0,300),UDim2.fromOffset(24,44))
    self.actionBar=Theme.create("Frame",self.frame,{Name="PrestigeActionBar",BackgroundColor3=Theme.pixelColors.base,BorderSizePixel=0,
        Active=false,Selectable=false,Position=UDim2.new(0,8,1,-144),Size=UDim2.new(1,-16,0,64),ZIndex=4})
    Theme.rule(self.actionBar,UDim2.fromOffset(0,0),UDim2.new(1,0,0,2),c.line)
    self.ascend.Parent=self.actionBar;self.ascend.Position=UDim2.new(0.5,-160,0,8);self.ascend.Size=UDim2.fromOffset(320,48)
    self.preview.Parent=self.dashboard;self.preview.TextSize=14;self.preview.TextXAlignment=Enum.TextXAlignment.Center
    self.message=Theme.text(self.frame,"",14,c.muted,UDim2.new(0,12,1,-72),UDim2.new(1,-24,0,64))
    self.message.Name="ProgressionMessage"
    self.message.ZIndex=5
    self.treeLayer=Theme.create("Frame",self.body,{Name="PixelTree",BackgroundTransparency=1,BorderSizePixel=0,
        Active=false,Selectable=false,Size=UDim2.fromOffset(self.treeBounds.width,self.treeBounds.height)})
    self.grid={}
    for y=0,math.floor(self.treeBounds.height/96) do for x=0,math.floor(self.treeBounds.width/96) do
        self.grid[#self.grid+1]=pixelRect(self.treeLayer,"GridPixel",x*96,y*96,2,2,c.line,1)
    end end
    for index,node in ipairs(balance.PRESTIGE_NODES) do
        local p=TreeLayout.position(node.id)
        local frame=Theme.create("Frame",self.treeLayer,{Name=node.id,BackgroundTransparency=1,BorderSizePixel=0,
            Position=UDim2.fromOffset(p.x,p.y),Size=UDim2.fromOffset(p.width,p.height),ZIndex=2})
        local borders,faces=hexPanel(frame)
        local palette=palettes[TreeLayout.family(node)]
        local color=palette.edge
        local icon,parts=pixelIcon(frame,node.icon or node.id,color)
        local title=Theme.text(frame,node.name,14,c.text,UDim2.fromOffset(12,74),UDim2.fromOffset(216,38))
        title.ZIndex=3;title.Active=false;title.Selectable=false;title.TextXAlignment=Enum.TextXAlignment.Center
        local mock=Theme.text(frame,node.description,14,c.muted,UDim2.fromOffset(16,112),UDim2.fromOffset(208,42))
        mock.ZIndex=3;mock.Active=false;mock.Selectable=false;mock.TextXAlignment=Enum.TextXAlignment.Center
        local buy
        local art
        buy,art=Theme.pixelButton(frame,"",UDim2.fromOffset(40,160),UDim2.fromOffset(160,32),function(input)
            if self.mode~="Tree" or not self:allowed(input,buy) then return end
            local cost=Rules.quote(self.data,node.id,balance)
            if cost and self.data.chips>=cost then self:request("buy_skill",{nodeId=node.id}) end
        end)
        buy.Name="Unlock";buy.TextSize=14;buy.ZIndex=4;art.label.TextSize=14;art.label.ZIndex=5
        for _,part in ipairs(art.parts) do part.ZIndex=4 end
        self.nodes[node.id]={frame=frame,buy=buy,borders=borders,faces=faces,palette=palette,art=art,icon=icon,pixels=parts}
    end
    for _,node in ipairs(balance.PRESTIGE_NODES) do
        for _,id in ipairs(node.parents) do
            local r=TreeLayout.link(id,node.id)
            local shadow=pixelRect(self.treeLayer,"BranchShadow",r.x,r.y,r.length,8,Color3.fromRGB(15,12,20),1)
            local line=pixelRect(self.treeLayer,"Branch",r.x,r.y,r.length,4,c.line,1)
            for _,part in ipairs({shadow,line}) do part.AnchorPoint=Vector2.new(.5,.5);part.Rotation=r.angle end
            self.links[#self.links+1]={frame=line,shadow=shadow,parent=id,child=node.id}
        end
    end
    local function connect(signal,callback) self.connections[#self.connections+1]=signal:Connect(callback) end
    connect(UserInputService.InputBegan,function(input)
        if not pointer(input) then return end
        if self.drag then return end
        self:cancelPan();self.suppressClick=false
        if not self:canPan(input) or not contains(self.body,input) then return end
        self.drag={input=input,start=input.Position,origin=self.body.CanvasPosition,moved=false}
    end)
    connect(UserInputService.InputChanged,function(input)
        local drag=self.drag
        if not drag then return end
        if input~=drag.input and not (drag.input.UserInputType==Enum.UserInputType.MouseButton1
            and input.UserInputType==Enum.UserInputType.MouseMovement) then return end
        if not self:canPan() then self:cancelPan();return end
        local dx,dy=input.Position.X-drag.start.X,input.Position.Y-drag.start.Y
        if not drag.moved and dx*dx+dy*dy<36 then return end
        drag.moved=true;self.suppressClick=true
        self:panTo(drag.origin.X-dx,drag.origin.Y-dy)
    end)
    connect(UserInputService.InputEnded,function(input)
        if self.drag and (input==self.drag.input or (input.UserInputType==Enum.UserInputType.MouseButton1
            and self.drag.input.UserInputType==Enum.UserInputType.MouseButton1)) then self:cancelPan() end
    end)
    connect(UserInputService.WindowFocusReleased,function() self:cancelPan() end)
    connect(self.frame:GetPropertyChangedSignal("Visible"),function() if not self.frame.Visible then self:cancelPan() end end)
    return self
end
function Page:canPan(input)
    return not self.destroyed and self.mode=="Tree" and self.frame.Visible and self.data and not self.data.blocked
        and (not self.allowPointer or self.allowPointer(input))
end
function Page:cancelPan()
    if self.drag and self.drag.moved then self.suppressClick=true end
    self.drag=nil
end
function Page:panTo(x,y)
    local canvas,viewport=self.body.CanvasSize,self.body.AbsoluteWindowSize
    self.body.CanvasPosition=Vector2.new(math.max(0,math.min(x,math.max(0,canvas.X.Offset-viewport.X))),
        math.max(0,math.min(y,math.max(0,canvas.Y.Offset-viewport.Y))))
end
function Page:centerTree()
    self:cancelPan()
    local root=self.nodes.boot.frame
    self:panTo(self.treeLayer.Position.X.Offset+root.Position.X.Offset+root.Size.X.Offset/2-self.body.AbsoluteWindowSize.X/2,
        math.max(0,root.Position.Y.Offset+root.Size.Y.Offset/2-self.body.AbsoluteWindowSize.Y/2))
end
function Page:allowed(input,target)
    if self.mode=="Tree" and ((self.suppressClick and (not input or pointer(input))) or (self.drag and self.drag.moved)) then return false end
    if input and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
        local container=target==self.ascend and self.actionBar or target==self.centerButton and self.frame or self.body
        for _,object in ipairs({container,target or self.body}) do
            local p,s=object.AbsolutePosition,object.AbsoluteSize
            if input.Position.X<p.X or input.Position.X>=p.X+s.X or input.Position.Y<p.Y or input.Position.Y>=p.Y+s.Y then return false end
        end
    end
    return not self.destroyed and self.frame.Visible and self.data and not self.data.blocked and not self.pending
        and (not self.allowPointer or self.allowPointer(input))
end
function Page:request(action,payload)
    if self.pending or not self.data then return end
    self.sequence=self.sequence+1;payload.requestId=self.sequence
    self.pending={id=self.sequence,action=action,beforeCount=self.data.prestigeCount,draftId=payload.draftId,age=0,syncs=0}
    if self.onAction then self.onAction(action) end
    self.armed=nil;self.message.Text="Waiting for server confirmation..."
    if self.onPending then self.onPending(true) end
    self:render();self.submit(action,payload)
end
function Page:ascendPress(input)
    if self.mode~="Prestige" or not self:allowed(input,self.ascend) or not self.data.prestige or self.data.prestige.available<1 then return end
    if not self.draftId or (self.canReset and not self.canReset()) then
        self.message.Text="Wait for the current token or sale to finish.";return
    end
    if self.armed~=self.draftId then
        self.armed=self.draftId;self.message.Text="Confirm: money, normal upgrades and unsold tokens will reset."
        if self.onAction then self.onAction("review_prestige") end
        self:render();return
    end
    self:request("prestige",{draftId=self.draftId})
end
function Page:setMode(mode)
    self:cancelPan()
    local changed=self.mode~=mode
    if changed then self.positions[self.mode]=self.body.CanvasPosition end
    self.mode=mode;self.armed=nil
    if not self.pending then self.message.Text="" end
    self:render()
    if mode=="Tree" and not self.treeVisited then
        self.treeVisited=true
        self:centerTree()
    elseif changed then
        local position=self.positions[mode] or Vector2.new(0,0)
        self:panTo(position.X,position.Y)
    end
end
function Page:update(data,draftId)
    local confirmed,pending
    self.data=data;self.sequence=math.max(self.sequence,data.progressionSequence or 0)
    if self.draftId~=draftId then self.armed=nil end
    self.draftId=draftId
    if self.pending then
        local reply=data.progressionReply
        if reply and reply.requestId==self.pending.id then
            if reply.ok==true and reply.action==self.pending.action then confirmed,pending=reply,self.pending end
            self.pending=nil;self.message.Text=reply.message
            if self.onPending then self.onPending(false) end
        elseif data.progressionSyncId==self.pending.id then
            self.pending=nil;self.message.Text="No change confirmed. Review before trying again."
            if self.onPending then self.onPending(false) end
        end
    end
    self:render()
    if confirmed and self.onConfirmed then self.onConfirmed(confirmed,data,pending) end
end
function Page:render()
    local tree=self.mode=="Tree"
    self.centerButton.Visible=tree
    self.treeLayer.Visible=tree
    self.prestigeBackdrop.Visible,self.titleBadge.Visible,self.actionBar.Visible=not tree,not tree,not tree
    self.body.ScrollBarThickness=tree and 0 or 5
    self.body.ScrollingEnabled=not tree
    self.title.Text=tree and "SKILL TREE" or "PRESTIGE"
    self.dashboard.Visible=not tree
    self.preview.Visible,self.ascend.Visible=not tree,not tree
    local unlocked=0
    for _ in pairs(self.data and self.data.prestigeSkills or {}) do unlocked=unlocked+1 end
    self.wallet.Text=self.data and (Theme.number(self.data.chips).." Chips / "..unlocked.." of "..#self.balance.PRESTIGE_NODES) or "Opening session..."
    for id,node in pairs(self.nodes) do
        node.frame.Visible=tree
        local owned=self.data and self.data.prestigeSkills[id]
        local cost=self.data and Rules.quote(self.data,id,self.balance)
        local canBuy=cost and self.data.chips>=cost and not self.data.blocked and not self.pending
        for _,border in ipairs(node.borders) do border.BackgroundColor3=c.black end
        for _,face in ipairs(node.faces) do face.BackgroundColor3=(owned or cost) and node.palette.face or c.paper end
        node.buy.Text=owned and "UNLOCKED" or (cost and (Theme.number(cost).." Chips") or "LOCKED")
        node.buy.Active,node.buy.Selectable=canBuy==true,canBuy==true
        node.buy.BackgroundColor3=canBuy and c.accent or c.paper
        node.buy.TextColor3=owned and c.mint or canBuy and c.terminal or c.muted
        node.art.label.Text,node.art.label.TextColor3=node.buy.Text,node.buy.TextColor3
        for _,face in ipairs(node.art.parts) do face.BackgroundColor3=canBuy and c.accent or c.paper end
        for _,part in ipairs(node.pixels) do part.BackgroundTransparency=(owned or cost) and 0 or 0.45 end
    end
    for _,link in ipairs(self.links) do
        link.frame.Visible=tree
        link.shadow.Visible=tree
        local owned=self.data and self.data.prestigeSkills[link.child]
        local available=self.data and Rules.quote(self.data,link.child,self.balance)
        link.frame.BackgroundColor3=owned and c.amber or available and self.nodes[link.child].palette.edge or c.line
    end
    local view=self.data and self.data.prestige
    if view then
        self.preview.Text="Resets money, agents, upgrades, streak and unsold tokens.\nKeeps Chips, skills, cards and fragments. Only deck slot 1 stays equipped."
        self.chipAmount.Text=Theme.number(self.data.chips)
        self.perChip.Text=string.format("+%g%%",(view.perChip or self.balance.PRESTIGE_BONUS)*100)
        self.gain.Text="+"..Theme.number(view.available)
        self.bonusNow.Text=string.format("+%g%%",((view.bonus or 1)-1)*100)
        self.bonusAfter.Text=string.format("+%g%%",((view.afterBonus or view.bonus or 1)-1)*100)
        local lower=self.balance.PRESTIGE_BASE*(view.baseLevel or (self.data.prestigeClaimed+view.available))^3
        local progress=view.nextAt and math.max(0,math.min(1,(self.data.lifetimeEarned-lower)/(view.nextAt-lower))) or 1
        self.progressFill.Size=UDim2.new(progress,-8*progress,1,-8)
        self.progressText.Text=string.format("%d%%",math.floor(progress*100))
        self.remaining.Text=view.nextAt and ("EARN "..Theme.money(math.max(0,view.nextAt-self.data.lifetimeEarned)).." MORE FOR NEXT CHIP") or "MAX CHIPS REACHED"
    end
    self.ascend.Text=self.pending and "WAITING..." or (self.armed and "CONFIRM RESET" or "PRESTIGE")
    self.ascend.Active,self.ascend.Selectable=view~=nil and view.available>0 and not self.pending and not self.data.blocked,
        view~=nil and view.available>0 and not self.pending and not self.data.blocked
    self.ascend.BackgroundColor3=self.ascend.Active and c.accent or c.paper
    self.ascend.TextColor3=self.ascend.Active and c.terminal or c.muted
    self.ascendArt.label.Text,self.ascendArt.label.TextColor3=self.ascend.Text,self.ascend.TextColor3
    for _,face in ipairs(self.ascendArt.parts) do face.BackgroundColor3=self.ascend.Active and c.accent or c.paper end
    if tree and not self.pending and self.message.Text=="" then self.message.Text="Hold + drag" end
    self:layoutBody()
end
function Page:layoutBody()
    if self.presentationPaused then return end
    local compact=self.frame.AbsoluteSize.Y<144
    self.wallet.Visible=self.mode=="Tree" and not compact
    if self.mode=="Tree" then
        self.title.Position,self.title.Size=UDim2.fromOffset(12,8),UDim2.new(1,-120,0,34)
        self.title.TextSize=self.frame.AbsoluteSize.X<400 and 16 or 22;self.title.TextXAlignment=Enum.TextXAlignment.Left;self.title.TextColor3=c.amber
        self.wallet.Position,self.wallet.Size=UDim2.fromOffset(12,44),UDim2.new(1,-24,0,44)
        self.wallet.TextSize=14;self.wallet.TextWrapped=true
        self.body.Position,self.body.Size=UDim2.fromOffset(8,compact and 40 or 100),UDim2.new(1,-16,1,compact and -120 or -180)
    else
        local top=self.frame.AbsoluteSize.X>=1000 and 8 or 52
        self.body.Position,self.body.Size=UDim2.fromOffset(8,top),UDim2.new(1,-16,1,-top-152)
        self.title.Position,self.title.Size=UDim2.new(1,-180,0,8),UDim2.fromOffset(168,32)
        self.title.TextSize=14;self.title.TextXAlignment=Enum.TextXAlignment.Center;self.title.TextColor3=c.terminal
    end
    if self.mode=="Tree" then
        self.body.CanvasSize=UDim2.fromOffset(math.max(self.treeBounds.width,self.body.AbsoluteSize.X),self.treeBounds.height)
        self.treeLayer.Position=UDim2.fromOffset(math.max(0,math.floor((self.body.AbsoluteSize.X-self.treeBounds.width)/8)*4),0)
        local position=self.body.CanvasPosition
        self:panTo(position.X,position.Y)
    else
        local width=math.max(240,math.min(720,self.body.AbsoluteSize.X-16))
        local narrow=width<520
        local summaryY,summaryHeight=80,176
        local mainY=summaryY+summaryHeight+(narrow and summaryHeight+16 or 0)+20
        local mainHeight=narrow and 540 or 452
        self.dashboard.Position=UDim2.fromOffset(math.max(0,math.floor((self.body.AbsoluteSize.X-width)/2)),0)
        local noteHeight=narrow and 192 or 112
        self.dashboard.Size=UDim2.fromOffset(width,mainY+mainHeight+noteHeight+32)
        self.chipBox.Position,self.chipBox.Size=UDim2.fromOffset(0,summaryY),UDim2.new(narrow and 1 or .5,narrow and 0 or -8,0,summaryHeight)
        self.perkBox.Position=narrow and UDim2.fromOffset(0,summaryY+summaryHeight+16) or UDim2.new(.5,8,0,summaryY)
        self.perkBox.Size=self.chipBox.Size
        self.chipCaption.Position,self.chipCaption.Size=UDim2.fromOffset(8,136),UDim2.new(1,-16,0,32)
        self.perkCaption.Position,self.perkCaption.Size=UDim2.fromOffset(8,136),UDim2.new(1,-16,0,32)
        self.walletChip.Position,self.walletChip.Size=UDim2.fromOffset(20,60),UDim2.fromOffset(64,64)
        self.chipAmount.Position,self.chipAmount.Size=UDim2.fromOffset(100,56),UDim2.new(1,-116,0,64)
        self.intro.TextSize,self.perkHeading.TextSize=14,14
        self.perChip.TextSize=38;self.perChip.Position=UDim2.fromOffset(8,64)
        self.rebirthBox.Position,self.rebirthBox.Size=UDim2.fromOffset(0,mainY),UDim2.new(1,0,0,mainHeight)
        self.heroHeading.TextSize=14;self.heroHeading.Position,self.heroHeading.Size=UDim2.fromOffset(8,12),UDim2.new(1,-16,0,44)
        local iconSize=narrow and 80 or 96
        local gap=12
        local gainSize=48
        local available=width-32-iconSize-gap
        while gainSize>18 and Theme.textWidth(self.gain.Text,gainSize)>available do gainSize=gainSize-1 end
        local textWidth=math.min(available,Theme.textWidth(self.gain.Text,gainSize))
        local pairWidth=iconSize+gap+textWidth;local pairHeight=112
        self.heroRow.Position,self.heroRow.Size=UDim2.new(.5,-math.floor(pairWidth/2),0,72),UDim2.fromOffset(pairWidth,pairHeight)
        self.heroChip.Position,self.heroChip.Size=UDim2.fromOffset(0,math.floor((pairHeight-iconSize)/2)),UDim2.fromOffset(iconSize,iconSize)
        self.gain.Position,self.gain.Size=UDim2.fromOffset(iconSize+gap,0),UDim2.fromOffset(textWidth,pairHeight)
        self.gain.TextSize=gainSize;self.gain.TextWrapped=false
        self.progressBar.Position,self.progressBar.Size=UDim2.fromOffset(20,200),UDim2.new(1,-40,0,40)
        self.remaining.Position,self.remaining.Size=UDim2.fromOffset(8,252),UDim2.new(1,-16,0,64);self.remaining.TextSize=14
        self.bonusDivider.Position=UDim2.fromOffset(24,324)
        self.nowHeading.Position,self.nowHeading.Size=UDim2.fromOffset(8,340),UDim2.new(narrow and 1 or .5,-16,0,narrow and 32 or 48)
        self.afterHeading.Position=narrow and UDim2.fromOffset(8,436) or UDim2.new(.5,8,0,340)
        self.afterHeading.Size=self.nowHeading.Size
        self.nowHeading.TextSize,self.afterHeading.TextSize=14,14
        self.bonusNow.Position=UDim2.fromOffset(8,narrow and 380 or 396)
        self.bonusAfter.Position=narrow and UDim2.fromOffset(8,476) or UDim2.new(.5,16,0,396)
        self.bonusNow.Size=UDim2.new(narrow and 1 or .5,narrow and -16 or -24,0,44);self.bonusAfter.Size=self.bonusNow.Size
        self.bonusArrow.Position=UDim2.new(.5,-12,0,396);self.bonusArrow.Visible=not narrow
        local actionWidth=math.min(320,width)
        self.ascend.Position,self.ascend.Size=UDim2.new(.5,-math.floor(actionWidth/2),0,8),UDim2.fromOffset(actionWidth,48)
        self.preview.Position,self.preview.Size=UDim2.fromOffset(8,mainY+mainHeight+16),UDim2.new(1,-16,0,noteHeight)
        self.preview.TextSize=14;self.preview.TextWrapped=true
        if self.data and self.data.prestige then
            self.preview.Text="Resets money, agents, upgrades, streak and unsold tokens.\nKeeps Chips, skills, cards and fragments. Only deck slot 1 stays equipped."
        end
        self.body.CanvasSize=UDim2.fromOffset(width,mainY+mainHeight+noteHeight+40)
        for _,item in ipairs({self.chipAmount,self.bonusNow,self.bonusAfter}) do
            local size=item==self.chipAmount and 34 or 30
            while size>18 and Theme.textWidth(item.Text,size)>item.AbsoluteSize.X do size=size-1 end
            item.TextSize=size;item.TextWrapped=false
        end
        for _,pair in ipairs(self.figureShadows) do
            local source,shadow=pair.source,pair.shadow
            local offset=source==self.gain and 3 or 2
            shadow.Text,shadow.TextSize,shadow.TextWrapped=source.Text,source.TextSize,source.TextWrapped
            shadow.Visible=source.Visible
            shadow.TextXAlignment=source.TextXAlignment
            shadow.Position=UDim2.new(source.Position.X.Scale,source.Position.X.Offset+offset,source.Position.Y.Scale,source.Position.Y.Offset+offset)
            shadow.Size=source.Size
        end
        self:layoutBackdrop()
    end
end
function Page:layoutBackdrop()
    local w,h=self.frame.AbsoluteSize.X,self.frame.AbsoluteSize.Y
    local stamp=w..":"..h
    if self.backdropStamp==stamp then return end
    self.backdropStamp=stamp
    local unit=math.max(8,math.ceil(math.max(h/32,w/32)/4)*4)
    for index,part in ipairs(self.stripes) do
        local row,column=math.floor((index-1)/8),(index-1)%8
        part.Position=UDim2.fromOffset((column*unit*4+row*unit)%(unit*32)-unit,row*unit)
        part.Size=UDim2.fromOffset(unit,unit)
    end
end
function Page:layout(width,height,header)
    self:cancelPan()
    self.frame.Position=UDim2.fromOffset(8,header+8)
    self.frame.Size=UDim2.fromOffset(math.max(1,width-16),math.max(96,height-header-16))
    self.title.TextSize=width<260 and 12 or 18
    local compact=self.frame.AbsoluteSize.Y<144
    self.title.Position=UDim2.fromOffset(12,compact and 4 or 8)
    if self.mode=="Tree" then
        self.title.Size=UDim2.new(1,-24,0,30);self.title.TextColor3=c.amber;self.title.TextXAlignment=Enum.TextXAlignment.Left
    end
    self.wallet.Position,self.wallet.Size=UDim2.fromOffset(12,34),UDim2.new(1,-24,0,26)
    self:layoutBody()
end
function Page:sync()
    if self.pending then self.submit("prestige_sync",{requestId=self.pending.id}) end
end
function Page:tick(dt)
    if self.drag and not self:canPan() then self:cancelPan() end
    if not self.pending then return end
    local pending=self.pending;pending.age=pending.age+math.max(0,dt)
    if pending.syncs<3 and pending.age>=3*(pending.syncs+1) then
        pending.syncs=pending.syncs+1;self:sync()
    elseif pending.age>=12 then self.message.Text="Unconfirmed. Use Reconnect to check; no action was resent." end
end
function Page:destroy()
    if self.destroyed then return end
    self.destroyed=true;self.onAction=nil;self:cancelPan();self.pending=nil
    for _,connection in ipairs(self.connections) do connection:Disconnect() end
    self.frame:Destroy()
end
return Page

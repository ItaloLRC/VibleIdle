--!nonstrict
local Theme=require(script.Parent.DeskTheme)
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Craft=require(Shared.AgentCrafting)
local Visual=require(script.Parent.CollectionStyle)
local Lab={};Lab.__index=Lab
local c=Theme.colors
local function contains(frame,point)
    local p,s=frame.AbsolutePosition,frame.AbsoluteSize
    return point.X>=p.X and point.X<p.X+s.X and point.Y>=p.Y and point.Y<p.Y+s.Y
end
function Lab.new(parent,balance,onCraft)
    local self=setmetatable({balance=balance,onCraft=onCraft,target=1,cards={},recipes={},seenReply=0},Lab)
    self.frame=Theme.create("Frame",parent,{Name="AgentLabPage",BackgroundColor3=Theme.pixelColors.base,
        BorderSizePixel=0,Active=true,Visible=false})
    Theme.pixelPanel(self.frame,"LabPanel",UDim2.fromOffset(0,0),UDim2.fromScale(1,1))
    self.backdrop=Theme.create("Frame",self.frame,{Name="LabBackdrop",BackgroundColor3=Color3.fromRGB(25,22,30),
        BorderSizePixel=0,Active=false,Selectable=false,ClipsDescendants=true,Size=UDim2.fromScale(1,1)})
    self.stripes={}
    for _=1,256 do
        local part=Visual.rect(self.backdrop,"StripePixel",0,0,1,1,Color3.fromRGB(32,26,37));part.BackgroundTransparency=.35
        self.stripes[#self.stripes+1]=part
    end
    self.titleBadge=Theme.pixelPanel(self.frame,"LabTab",UDim2.new(1,-180,0,8),UDim2.fromOffset(168,32),c.accent)
    self.titleBadge.ZIndex=3
    self.title,self.titleShadow=Visual.caption(self.frame,"AGENT LAB",14,c.terminal,UDim2.new(1,-180,0,8),UDim2.fromOffset(168,32))
    self.openCards,self.openCardsArt=Theme.pixelButton(self.frame,"CARDS >",UDim2.fromOffset(12,8),UDim2.fromOffset(140,40),function(input)
        if self:canInteract(input,self.openCards) and self.onOpenCards then self.onOpenCards() end
    end)
    self.wallet=Theme.text(self.frame,"Connecting...",14,c.mint,UDim2.fromOffset(12,48),UDim2.new(1,-24,0,56))
    self.wallet.ZIndex=3;self.wallet.TextXAlignment=Enum.TextXAlignment.Center
    self.list=Theme.create("ScrollingFrame",self.frame,{Name="CraftingList",BackgroundTransparency=1,BorderSizePixel=0,
        ClipsDescendants=true,Position=UDim2.fromOffset(12,112),Size=UDim2.new(1,-24,1,-200),
        CanvasSize=UDim2.fromOffset(0,0),ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=5,ScrollBarImageColor3=Theme.pixelColors.edge,ZIndex=2})
    self.intro=Visual.caption(self.list,"COLLECT VISITORS.\nCRAFT YOUR NEXT AGENT CARD.",14,c.ink,UDim2.fromOffset(0,0),UDim2.new(1,-8,0,64))
    self.familyPanel=Visual.panel(self.list,"FamilyPanel",UDim2.fromOffset(0,76),UDim2.new(1,-8,0,368))
    self.familyHeading=Visual.caption(self.familyPanel,"AGENT FAMILIES",14,c.ink,UDim2.fromOffset(8,10),UDim2.new(1,-16,0,28))
    self.familyList=Theme.create("ScrollingFrame",self.list,{Name="Families",BackgroundTransparency=1,BorderSizePixel=0,
        ClipsDescendants=true,Position=UDim2.fromOffset(12,116),Size=UDim2.new(1,-32,0,320),
        CanvasSize=UDim2.fromOffset(9*208+8,0),ScrollingDirection=Enum.ScrollingDirection.X,ScrollBarThickness=5,
        ScrollBarImageColor3=c.accent,ZIndex=2})
    for index,family in ipairs(balance.AGENT_FAMILIES) do
        local entry=Visual.cardView(self.familyList,family.id,family.id);local card=entry.frame
        card.Position=UDim2.fromOffset(8+(index-1)*208,4)
        entry.id=family.id;entry.name.Text=family.name
        card.Activated:Connect(function(input)
            if not self:canInteract(input,card) then return end
            self.target=index;self:render();if self.onMove then self.onMove() end
        end)
        self.cards[index]=entry
    end
    self.recipePanel=Visual.panel(self.list,"RecipePanel",UDim2.fromOffset(0,464),UDim2.new(1,-8,0,656))
    self.familyTitle,self.familyTitleShadow=Visual.caption(self.list,"EMBER / RECIPES",16,c.ink,UDim2.fromOffset(8,476),UDim2.new(1,-24,0,44))
    for rank,tier in ipairs(balance.CRAFT_TIERS) do
        local entry=Visual.cardView(self.list,tier.id,"ember"..(rank==1 and "" or "_"..tier.id));local frame=entry.frame
        frame.Active=false;frame.Selectable=false;frame.Size=UDim2.fromOffset(288,560)
        entry.name.Position=UDim2.fromOffset(8,12);entry.name.Size=UDim2.new(1,-16,0,28);entry.name.TextSize=16
        entry.nameShadow.Position=UDim2.fromOffset(10,14);entry.nameShadow.Size=entry.name.Size;entry.nameShadow.TextSize=16
        entry.aura.frame.Position=UDim2.new(.5,-96,0,44);entry.aura.frame.Size=UDim2.fromOffset(192,192)
        for _,parts in ipairs({entry.aura.rim,entry.aura.fill,entry.aura.glints}) do for _,part in ipairs(parts) do
            local p,s=part.Position,part.Size
            part.Position=UDim2.fromOffset(p.X.Offset*4/3,p.Y.Offset*4/3);part.Size=UDim2.fromOffset(s.X.Offset*4/3,s.Y.Offset*4/3)
        end end
        entry.preview.frame.Position=UDim2.new(.5,-80,0,88);entry.preview.frame.Size=UDim2.fromOffset(160,100)
        entry.rarity.Position=UDim2.fromOffset(8,244);entry.rarity.Size=UDim2.new(1,-16,0,28);entry.rarity.TextSize=14
        local plaque=frame.BuffPlaque;plaque.Position=UDim2.fromOffset(12,280);plaque.Size=UDim2.new(1,-24,0,56)
        for _,label in ipairs({entry.buff,entry.buffShadow,entry.speed,entry.speedShadow}) do label.Size=UDim2.new(1,-12,0,20) end
        entry.buff.TextSize,entry.buffShadow.TextSize=16,16
        entry.speed.Position=UDim2.fromOffset(6,30);entry.speedShadow.Position=UDim2.fromOffset(8,32)
        entry.status.Position=UDim2.fromOffset(8,344);entry.status.Size=UDim2.new(1,-16,0,40)
        entry.statusShadow.Position=UDim2.fromOffset(10,346);entry.statusShadow.Size=entry.status.Size
        local cost,costShadow=Visual.caption(frame,"",16,c.text,UDim2.fromOffset(12,392),UDim2.new(1,-24,0,88))
        entry.cost,entry.costShadow=cost,costShadow
        local buy,art=Theme.pixelButton(frame,"CRAFT",UDim2.new(0.5,-92,1,-50),UDim2.fromOffset(184,40),function(input)
            if not self:canInteract(input,self.recipes[rank].buy) or not self.data then return end
            local id=self:cardId(rank)
            if Craft.affordable(self.data,Craft.quote(self.data,id,self.balance)) and self.onCraft then self.onCraft(id) end
        end)
        entry.buy,entry.art=buy,art;buy.ZIndex=4
        self.recipes[rank]=entry
    end
    self.message=Theme.text(self.frame,"Collect fragments in Main CLI. Equip crafted cards in Cards.",14,c.muted,UDim2.new(0,12,1,-80),UDim2.new(1,-24,0,72));self.message.ZIndex=4
    self:render();return self
end
function Lab:cardId(rank)
    local tier=self.balance.CRAFT_TIERS[rank]
    return self.balance.AGENT_FAMILIES[self.target].id..(rank==1 and "" or "_"..tier.id)
end
function Lab:canInteract(input,control)
    if self.destroyed or not self.frame.Visible or self.pending or not self.data or self.data.blocked
        or (self.allowPointer and not self.allowPointer(input)) then return false end
    if input and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
        if not contains(control,input.Position) or not contains(self.frame,input.Position) then return false end
        if control:IsDescendantOf(self.list) and not contains(self.list,input.Position) then return false end
        if control:IsDescendantOf(self.familyList) and not contains(self.familyList,input.Position) then return false end
    end
    return true
end
function Lab:update(data,pending,message)
    if self.destroyed then return end
    if data then self.data=data end
    self.pending=pending or false
    local reply=self.data and self.data.progressionReply
    if reply and reply.action=="craft_card" and reply.requestId>self.seenReply then
        self.seenReply=reply.requestId;self.message.Text=reply.message
    end
    if self.pending then self.message.Text=message or "Waiting for server confirmation..."
    elseif self.data and self.data.progressionSyncId and self.data.progressionSyncId>self.seenReply then
        self.seenReply=self.data.progressionSyncId;self.message.Text="Change checked. Choose a recipe."
    end
    self:render()
end
function Lab:setPending(value,message)
    local pendingText=value and message or nil
    if self.pending==value and self.pendingText==pendingText then return end
    self.pendingText=pendingText;self:update(nil,value,message)
end
function Lab:render()
    local family=self.balance.AGENT_FAMILIES[self.target]
    self.wallet.Text=self.data and (Theme.money(self.data.credits).." / "..Theme.number(self.data.chips).." Chips") or "Connecting..."
    self.familyTitle.Text=string.upper(family.name).." / RECIPES"
    self.familyTitleShadow.Text=self.familyTitle.Text
    for index,entry in ipairs(self.cards) do
        local amount=self.data and self.data.fragments[entry.id] or 0
        entry.status.Text=index==self.target and "SELECTED" or "SELECT"
        Visual.styleCard(entry,Craft.definition(entry.id,self.balance),true)
        entry.buff.Text=Theme.number(amount);entry.buffShadow.Text=entry.buff.Text
        entry.speed.Text="FRAGMENTS";entry.speedShadow.Text=entry.speed.Text;entry.rarity.Text="FAMILY"
        for _,edge in ipairs(entry.edges) do edge.BackgroundColor3=index==self.target and c.mint or Color3.fromRGB(189,104,138) end
        entry.frame.Active,entry.frame.Selectable=not self.pending,not self.pending
    end
    for rank,entry in ipairs(self.recipes) do
        local id=self:cardId(rank);local card=Craft.definition(id,self.balance);local tier=self.balance.CRAFT_TIERS[rank]
        entry.preview:setMascot(id);entry.name.Text=card.name
        entry.cost.Text=string.format("%d fragments\n%s\n%d Chips",tier.fragments,Theme.money(tier.money),tier.chips)
        entry.costShadow.Text=entry.cost.Text
        local owned=self.data and self.data.cardOwned[id]
        local ready=self.data and not self.pending and Craft.affordable(self.data,Craft.quote(self.data,id,self.balance))
        entry.status.Text=owned and "IN COLLECTION" or ready and "READY TO CRAFT" or "RECIPE"
        Visual.styleCard(entry,card,true)
        entry.buy.Text=owned and "OWNED" or self.pending and "WAIT..." or "CRAFT";entry.art.label.Text=entry.buy.Text
        entry.art.label.TextColor3=owned and c.mint or ready and c.accent or c.muted
        entry.buy.Active,entry.buy.Selectable=ready and true or false,ready and true or false
        entry.frame:SetAttribute("CardId",id);entry.frame:SetAttribute("Owned",owned or false)
    end
end
function Lab:layout()
    self.title.TextSize=14;self.titleShadow.TextSize=14
    local available=math.max(224,self.list.AbsoluteSize.X-24);local gap=16
    local columns=math.max(1,math.min(4,math.floor((available+gap)/304)))
    local width=math.min(352,math.floor((available-gap*(columns-1))/columns))
    for rank,entry in ipairs(self.recipes) do
        local row=math.floor((rank-1)/columns);local inRow=math.min(columns,4-row*columns)
        local left=12+math.max(0,math.floor((available-(inRow*width+(inRow-1)*gap))/2))
        entry.frame.Position=UDim2.fromOffset(left+((rank-1)%columns)*(width+gap),532+row*576)
        entry.frame.Size=UDim2.fromOffset(width,560)
    end
    local rows=math.ceil(4/columns);self.recipePanel.Size=UDim2.new(1,-8,0,80+rows*576)
    self.list.CanvasSize=UDim2.fromOffset(0,556+rows*576)
    local w,h=self.frame.AbsoluteSize.X,self.frame.AbsoluteSize.Y
    local unit=math.max(8,math.ceil(math.max(h/32,w/32)/4)*4)
    for index,part in ipairs(self.stripes) do
        local row,column=math.floor((index-1)/8),(index-1)%8
        part.Position=UDim2.fromOffset((column*unit*4+row*unit)%(unit*32)-unit,row*unit);part.Size=UDim2.fromOffset(unit,unit)
    end
end
function Lab:destroy()
    if self.destroyed then return end
    self.destroyed=true;self.onMove=nil;self.onCraft=nil;self.onOpenCards=nil
    for _,entry in ipairs(self.cards) do entry.preview:destroy() end
    for _,entry in ipairs(self.recipes) do entry.preview:destroy() end
    self.frame:Destroy()
end
return Lab

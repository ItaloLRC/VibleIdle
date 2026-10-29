--!nonstrict
local Theme=require(script.Parent.DeskTheme)
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Cards=require(Shared.AgentCards)
local c=Theme.colors
local Page={};Page.__index=Page
local CARD_W,CARD_H,STEP,ROW_H,DECK_Y,GRID_Y=192,304,208,320,128,588
local DECK_WIDTH=8*STEP
local function contains(object,point)
    local p,s=object.AbsolutePosition,object.AbsoluteSize
    return point.X>=p.X and point.X<p.X+s.X and point.Y>=p.Y and point.Y<p.Y+s.Y
end
local function lock(parent)
    local group=Theme.create("Frame",parent,{Name="PixelLock",BackgroundTransparency=1,BorderSizePixel=0,
        Active=false,Selectable=false,Position=UDim2.fromOffset(80,94),Size=UDim2.fromOffset(32,40)})
    for y,row in ipairs({"..####..",".##..##.",".#....#.",".#....#.","########","########","###..###","###..###","########",".######."}) do
        local x=1
        while x<=#row do
            if row:sub(x,x)=="#" then
                local start=x
                repeat x=x+1 until x>#row or row:sub(x,x)~="#"
                Theme.create("Frame",group,{BorderSizePixel=0,BackgroundColor3=c.muted,Active=false,Selectable=false,
                    Position=UDim2.fromOffset((start-1)*4,(y-1)*4),Size=UDim2.fromOffset((x-start)*4,4)})
            else x=x+1 end
        end
    end
    return group
end
local Visual=require(script.Parent.CollectionStyle)
local rect,panel,caption,cardView,styleCard=Visual.rect,Visual.panel,Visual.caption,Visual.cardView,Visual.styleCard
function Page.new(parent,balance,onChange)
    local self=setmetatable({balance=balance,onChange=onChange,slots={},inventory={},seenReply=0},Page)
    self.frame=Theme.create("Frame",parent,{Name="CardsPage",BackgroundColor3=Theme.pixelColors.base,BorderSizePixel=0,Active=true,Visible=false})
    Theme.pixelPanel(self.frame,"PixelPage",UDim2.fromOffset(0,0),UDim2.fromScale(1,1))
    self.backdrop=Theme.create("Frame",self.frame,{Name="CardsBackdrop",BackgroundColor3=Color3.fromRGB(25,22,30),
        BorderSizePixel=0,Active=false,Selectable=false,ClipsDescendants=true,Size=UDim2.fromScale(1,1)})
    self.stripes={}
    for _=1,256 do
        local stripe=rect(self.backdrop,"StripePixel",0,0,1,1,Color3.fromRGB(32,26,37))
        stripe.BackgroundTransparency=0.35;self.stripes[#self.stripes+1]=stripe
    end
    self.titleBadge=Theme.pixelPanel(self.frame,"CardsTab",UDim2.new(1,-180,0,8),UDim2.fromOffset(168,32),c.accent)
    self.titleBadge.ZIndex=3
    self.title=Theme.text(self.frame,"AGENT CARDS",14,c.terminal,UDim2.new(1,-180,0,8),UDim2.fromOffset(168,32))
    self.title.TextXAlignment=Enum.TextXAlignment.Center;self.title.ZIndex=4
    self.body=Theme.create("ScrollingFrame",self.frame,{Name="CardsContent",BackgroundTransparency=1,BorderSizePixel=0,ZIndex=2,
        ClipsDescendants=true,Position=UDim2.fromOffset(8,48),Size=UDim2.new(1,-16,1,-128),
        CanvasSize=UDim2.fromOffset(0,600),ScrollingDirection=Enum.ScrollingDirection.Y,
        ScrollBarThickness=5,ScrollBarImageColor3=Theme.pixelColors.edge})
    self.deckPanel=panel(self.body,"DeckPanel",UDim2.fromOffset(0,76),UDim2.new(1,-8,0,440))
    self.inventoryPanel=panel(self.body,"InventoryPanel",UDim2.fromOffset(0,536),UDim2.new(1,-8,0,400))
    self.intro=caption(self.body,"SELECT A CARD.\nCHOOSE A FREE DECK SLOT.",14,c.ink,UDim2.fromOffset(8,0),UDim2.new(1,-16,0,64))
    self.deckTitle,self.deckTitleShadow=caption(self.body,"DECK / 1 OF 8",16,c.ink,UDim2.fromOffset(8,88),UDim2.new(1,-16,0,32))
    self.deck=Theme.create("ScrollingFrame",self.body,{Name="Deck",BackgroundTransparency=1,BorderSizePixel=0,ZIndex=2,
        ClipsDescendants=true,Position=UDim2.fromOffset(12,DECK_Y),Size=UDim2.new(1,-24,0,320),
        CanvasSize=UDim2.fromOffset(DECK_WIDTH,0),ScrollingDirection=Enum.ScrollingDirection.X,
        ScrollBarThickness=5,ScrollBarImageColor3=c.accent})
    for index=1,balance.MAX_HIDDEN_LAYERS do
        local entry=cardView(self.deck,"Slot"..index)
        local button=entry.frame
        button.Position=UDim2.fromOffset(8+(index-1)*STEP,4)
        entry.name.Position=UDim2.fromOffset(40,8);entry.name.Size=UDim2.fromOffset(144,24);entry.name.TextSize=14
        entry.nameShadow.Position=UDim2.fromOffset(42,10);entry.nameShadow.Size=UDim2.fromOffset(144,24);entry.nameShadow.TextSize=14
        local plus=Theme.create("Frame",button,{Name="FreePosition",BackgroundTransparency=1,BorderSizePixel=0,
            Active=false,Selectable=false,Position=UDim2.fromOffset(80,100),Size=UDim2.fromOffset(32,32),ZIndex=4})
        for _,r in ipairs({{12,0,8,32},{0,12,32,8}}) do rect(plus,"PlusPixel",r[1],r[2],r[3],r[4],c.mint) end
        local number=Theme.text(button,string.format("%02d",index),14,c.muted,UDim2.fromOffset(8,8),UDim2.fromOffset(28,24))
        number.TextXAlignment=Enum.TextXAlignment.Center;number.ZIndex=4;number.Active=false;number.Selectable=false
        entry.lock,entry.plus=lock(button),plus;entry.lock.ZIndex=4
        self.slots[index]=entry
        button.Activated:Connect(function(input) self:slotPress(index,input) end)
    end
    self.remove,self.removeArt=Theme.pixelButton(self.body,"REMOVE",UDim2.fromOffset(16,464),UDim2.fromOffset(160,40),function(input)
        if not self.selectedSlot or not self:allowed(input,self.remove) then return end
        self.onChange("unequip_card",{slotIndex=self.selectedSlot})
    end)
    self.remove.Name="RemoveCard";self.remove.TextSize=14;self.remove.ZIndex=2;self.removeArt.label.TextSize=14
    self.inventoryTitle,self.inventoryTitleShadow=caption(self.body,"INVENTORY",16,c.ink,UDim2.fromOffset(8,548),UDim2.new(1,-16,0,32))
    for _,card in ipairs(balance.AGENT_CARDS) do
        local entry=cardView(self.body,card.id,card.id)
        local button=entry.frame
        entry.name.Text=card.name;entry.nameShadow.Text=card.name
        self.inventory[card.id]=entry
        button.Activated:Connect(function(input)
            if not self:allowed(input,button) or not self.data.cardOwned[card.id] or Cards.location(self.data,card.id,balance) then return end
            self.selectedCard,self.selectedSlot=card.id,nil;self.message.Text="Choose a free slot."
            if self.onSelect then self.onSelect() end
            self:render()
            for index=1,#self.data.layerSizes-2 do
                if not self.data.cardDeck[index] then
                    self.body.CanvasPosition=Vector2.new(0,math.max(0,math.min(DECK_Y,self.body.CanvasSize.Y.Offset-self.body.AbsoluteWindowSize.Y)))
                    self.deck.CanvasPosition=Vector2.new(math.max(0,math.min((index-1)*STEP,self.deck.CanvasSize.X.Offset-self.deck.AbsoluteWindowSize.X)),0)
                    if self.onFocusSlot then self.onFocusSlot(self.slots[index].frame) end
                    break
                end
            end
        end)
    end
    self.message=Theme.text(self.frame,"Select a card.",14,c.muted,UDim2.new(0,12,1,-72),UDim2.new(1,-24,0,64))
    self.message.Name="CardsMessage";self.message.ZIndex=4
    self.sizeConnection=self.body:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() self:layoutContent() end)
    self:render()
    return self
end
function Page:allowed(input,target,deck)
    if self.destroyed or not self.frame.Visible or not self.data or self.data.blocked or self.pending
        or (self.allowPointer and not self.allowPointer(input)) then return false end
    if input and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
        if not target.Visible or not contains(target,input.Position) or not contains(self.body,input.Position)
            or (deck and not contains(self.deck,input.Position)) then return false end
    end
    return true
end
function Page:slotPress(index,input)
    local entry=self.slots[index]
    if not self:allowed(input,entry.frame,true) then return end
    if index>#self.data.layerSizes-2 then self.message.Text="Buy Agent count.";return end
    local id=self.data.cardDeck[index]
    if id then
        self.selectedCard,self.selectedSlot=nil,index;self.message.Text="REMOVE returns card."
    elseif self.selectedCard then self.onChange("equip_card",{slotIndex=index,cardId=self.selectedCard});return
    else self.message.Text="Select a card first." end
    if self.onSelect then self.onSelect() end
    self:render()
end
function Page:setOpen(value)
    self.frame.Visible=value;self.selectedCard,self.selectedSlot=nil,nil
    if value then self.message.Text="Select a card.";self:render() end
end
function Page:setPending(value,message)
    local text=value and (message and message:find("Reconnect",1,true) and "Use Reconnect to check." or "Waiting for server...") or nil
    if self.pending==value and self.pendingText==text then return end
    self.pending,self.pendingText=value,text
    if text then self.message.Text=text end
    if self.frame.Visible then self:render() end
end
function Page:update(data,pending)
    self.data=data;self.pending=pending
    if self.selectedCard and Cards.location(data,self.selectedCard,self.balance) then self.selectedCard=nil end
    if self.selectedSlot and not data.cardDeck[self.selectedSlot] then self.selectedSlot=nil end
    local reply=data.progressionReply
    if reply and reply.requestId>self.seenReply and (reply.action=="equip_card" or reply.action=="unequip_card") then
        self.seenReply=reply.requestId;self.message.Text=reply.message
        if reply.ok then self.selectedCard,self.selectedSlot=nil,nil end
    elseif data.progressionSyncId and data.progressionSyncId>self.seenReply and not pending then
        self.seenReply=data.progressionSyncId;self.message.Text="No change confirmed."
    end
    if self.frame.Visible then self:render() end
end
function Page:render()
    if not self.data then
        self.deckTitle.Text="DECK / --";self.inventoryTitle.Text="INVENTORY / --"
        for _,entry in ipairs(self.slots) do
            entry.frame.Active,entry.frame.Selectable=false,false
            entry.preview.frame.Visible,entry.plus.Visible,entry.lock.Visible=false,false,true
            entry.status.Text="LOCKED"
            styleCard(entry,nil,false)
        end
        for _,entry in pairs(self.inventory) do entry.frame.Visible=false;entry.frame.Active=false;entry.frame.Selectable=false end
        self.remove.Active,self.remove.Selectable=false,false
        self.deckTitleShadow.Text,self.inventoryTitleShadow.Text=self.deckTitle.Text,self.inventoryTitle.Text
        self.message.Text="Reconnect to load.";self:layoutContent();return
    end
    local count=#self.data.layerSizes-2
    self.deckTitle.Text=string.format("DECK / %d OF 8",count)
    for index,entry in ipairs(self.slots) do
        local unlocked=index<=count
        local id=self.data.cardDeck[index]
        local card=id and Cards.definition(id,self.balance)
        entry.lock.Visible=not unlocked;entry.preview.frame.Visible=card and true or false
        entry.plus.Visible=unlocked and not card
        if card then entry.preview:setMascot(card.id) end
        entry.name.Text=card and card.name or ""

        entry.status.Text=not unlocked and "LOCKED" or (card and "EQUIPPED" or (self.selectedCard and "PLACE" or "EMPTY"))
        entry.border.Color=self.selectedSlot==index and c.mint or (unlocked and self.selectedCard and not card and c.accent or c.line)
        for _,edge in ipairs(entry.edges) do edge.BackgroundColor3=entry.border.Color==c.line and Color3.fromRGB(189,104,138) or entry.border.Color end
        entry.frame.Active,entry.frame.Selectable=not self.pending and not self.data.blocked,unlocked and not self.pending and not self.data.blocked
        entry.frame:SetAttribute("Locked",not unlocked);entry.frame:SetAttribute("CardId",id or "")
        entry.status.TextColor3=not unlocked and c.muted or (card and c.mint or self.selectedCard and c.mint or c.accent)
        styleCard(entry,card,unlocked)
    end
    local available=0
    for _,card in ipairs(self.balance.AGENT_CARDS) do
        local entry=self.inventory[card.id]
        local free=self.data.cardOwned[card.id] and not Cards.location(self.data,card.id,self.balance)
        entry.frame.Visible=free==true
        entry.frame.Active,entry.frame.Selectable=free==true and not self.pending and not self.data.blocked,free==true and not self.pending and not self.data.blocked
        entry.border.Color=self.selectedCard==card.id and c.mint or c.line
        for _,edge in ipairs(entry.edges) do edge.BackgroundColor3=self.selectedCard==card.id and c.mint or Color3.fromRGB(189,104,138) end
        entry.status.Text=self.selectedCard==card.id and "SELECTED" or "SELECT"
        entry.status.TextColor3=self.selectedCard==card.id and c.mint or Theme.pixelColors.gold
        styleCard(entry,card,true)
        if free then available=available+1 end
    end
    self.inventoryTitle.Text=string.format("INVENTORY / %d",available)
    self.remove.Active,self.remove.Selectable=self.selectedSlot~=nil and not self.pending and not self.data.blocked,self.selectedSlot~=nil and not self.pending and not self.data.blocked
    self.remove.BackgroundColor3=self.remove.Active and c.accent or c.paper
    self.removeArt.label.TextColor3=self.remove.Active and c.terminal or c.muted
    self.removeArt.label.Text=self.remove.Text
    for _,face in ipairs(self.removeArt.parts) do face.BackgroundColor3=self.remove.Active and c.accent or c.paper end
    self.deckTitleShadow.Text=self.deckTitle.Text;self.inventoryTitleShadow.Text=self.inventoryTitle.Text
    self:layoutContent()
end
function Page:layoutContent()
    if self.presentationPaused then return end
    local width=math.max(1,self.body.AbsoluteSize.X-16)
    self.remove.Size=UDim2.fromOffset(math.min(160,width-16),40)
    local columns=math.min(#self.balance.AGENT_CARDS,math.max(1,math.floor((width+16)/STEP)))
    local free={}
    for _,card in ipairs(self.balance.AGENT_CARDS) do if self.inventory[card.id].frame.Visible then free[#free+1]=self.inventory[card.id] end end
    for index,entry in ipairs(free) do
        local row,column=math.floor((index-1)/columns),(index-1)%columns
        local inRow=math.min(columns,#free-row*columns)
        local left=8+math.max(0,math.floor((width-(inRow*STEP-16))/8)*4)
        entry.frame.Position=UDim2.fromOffset(left+column*STEP,GRID_Y+row*ROW_H)
    end
    local rows=math.ceil(#free/columns)
    self.inventoryPanel.Size=UDim2.new(1,-8,0,64+rows*ROW_H)
    self.body.CanvasSize=UDim2.fromOffset(0,616+rows*ROW_H)
    self.deck.CanvasSize=UDim2.fromOffset(math.max(DECK_WIDTH,self.deck.AbsoluteWindowSize.X),0)
    local left=8+math.max(0,math.floor((self.deck.AbsoluteWindowSize.X-DECK_WIDTH)/8)*4)
    for index,entry in ipairs(self.slots) do entry.frame.Position=UDim2.fromOffset(left+(index-1)*STEP,4) end
    local deckPosition=self.deck.CanvasPosition or Vector2.new(0,0)
    self.deck.CanvasPosition=Vector2.new(math.max(0,math.min(deckPosition.X,self.deck.CanvasSize.X.Offset-self.deck.AbsoluteWindowSize.X)),0)
    local bodyPosition=self.body.CanvasPosition or Vector2.new(0,0)
    self.body.CanvasPosition=Vector2.new(0,math.max(0,math.min(bodyPosition.Y,self.body.CanvasSize.Y.Offset-self.body.AbsoluteWindowSize.Y)))
    local w,h=self.frame.AbsoluteSize.X,self.frame.AbsoluteSize.Y
    local stamp=w..":"..h
    if stamp~=self.backdropStamp then
        self.backdropStamp=stamp
        local unit=math.max(8,math.ceil(math.max(h/32,w/32)/4)*4)
        for index,part in ipairs(self.stripes) do
            local row,column=math.floor((index-1)/8),(index-1)%8
            part.Position=UDim2.fromOffset((column*unit*4+row*unit)%(unit*32)-unit,row*unit)
            part.Size=UDim2.fromOffset(unit,unit)
        end
    end
end
function Page:layout(width,height,header)
    self.frame.Position=UDim2.fromOffset(8,header+8)
    self.frame.Size=UDim2.fromOffset(math.max(1,width-16),math.max(96,height-header-16))
    self.title.TextSize=14
    self:layoutContent()
end
function Page:destroy()
    self.destroyed=true;self.onSelect=nil;self.sizeConnection:Disconnect()
    for _,entry in pairs(self.inventory) do entry.preview:destroy() end
    for _,entry in ipairs(self.slots) do entry.preview:destroy() end
    self.frame:Destroy()
end
return Page

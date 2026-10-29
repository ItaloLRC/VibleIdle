--!nonstrict
local Theme=require(script.Parent.DeskTheme)
local Visual=require(script.Parent.CollectionStyle)
local Icon=require(script.Parent.StoreIcon)
local Features=require(script.Parent.FeatureIconCatalog)
local StoreIcons=require(script.Parent.StoreIconCatalog)
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local Premium=require(Shared.PremiumRules)
local Market=game:GetService("MarketplaceService")
local c=Theme.colors
local Shop={};Shop.__index=Shop
local function contains(frame,point)
    local p,s=frame.AbsolutePosition,frame.AbsoluteSize
    return point.X>=p.X and point.X<p.X+s.X and point.Y>=p.Y and point.Y<p.Y+s.Y
end
function Shop.new(parent,onCommand)
    local self=setmetatable({onCommand=onCommand,entries={},sequence=0,elapsed=0},Shop)
    self.frame=Theme.create("Frame",parent,{Name="RobuxShopPage",BackgroundColor3=Theme.pixelColors.base,BorderSizePixel=0,Active=true,Visible=false})
    Theme.pixelPanel(self.frame,"ShopPage",UDim2.fromOffset(0,0),UDim2.fromScale(1,1))
    self.backdrop=Theme.create("Frame",self.frame,{Name="ShopBackdrop",BackgroundColor3=Color3.fromRGB(25,22,30),
        BorderSizePixel=0,Active=false,Selectable=false,ClipsDescendants=true,Size=UDim2.fromScale(1,1)})
    self.stripes={};for _=1,256 do local part=Visual.rect(self.backdrop,"StripePixel",0,0,1,1,Color3.fromRGB(32,26,37));part.BackgroundTransparency=.35;self.stripes[#self.stripes+1]=part end
    self.titleBadge=Theme.pixelPanel(self.frame,"ShopTab",UDim2.new(1,-180,0,8),UDim2.fromOffset(168,32),c.accent);self.titleBadge.ZIndex=3
    self.title=Visual.caption(self.frame,"ROBUX SHOP",14,c.terminal,UDim2.new(1,-180,0,8),UDim2.fromOffset(168,32))
    self.check,self.checkArt=Theme.pixelButton(self.frame,"CHECK",UDim2.fromOffset(12,8),UDim2.fromOffset(104,40),function(input)
        if not self:allowed(input,self.check) then return end
        self:loadPrices(true);self:request("premium_check",{})
    end)
    self.check.Name="CheckPurchase"
    self.check.Active,self.check.Selectable=true,true
    self.body=Theme.create("ScrollingFrame",self.frame,{Name="Offers",BackgroundTransparency=1,BorderSizePixel=0,ZIndex=2,
        ClipsDescendants=true,Position=UDim2.fromOffset(12,56),Size=UDim2.new(1,-24,1,-152),CanvasSize=UDim2.fromOffset(0,1000),
        ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=5,ScrollBarImageColor3=Theme.pixelColors.edge})
    self.intro=Visual.caption(self.body,"A LITTLE BOOST. MORE PROGRESS.",14,c.ink,UDim2.fromOffset(8,4),UDim2.new(1,-24,0,64))
    for _,offer in ipairs(Premium.OFFERS) do
        local frame=Theme.create("Frame",self.body,{Name=offer.id,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromOffset(320,456)})
        local edges=Theme.cardTrim(frame)
        if offer.featured then for _,edge in ipairs(edges) do edge.BackgroundColor3=Theme.pixelColors.gold end end
        local tag=Visual.caption(frame,offer.featured and "PERMANENT UPGRADE" or offer.id=="agent" and "THIS RUN" or "1 HOUR BOOST",14,
            offer.featured and Theme.pixelColors.gold or c.muted,UDim2.fromOffset(10,12),UDim2.new(1,-20,0,36))
        local name=Visual.caption(frame,offer.name,offer.featured and 20 or 16,c.ink,UDim2.fromOffset(10,52),UDim2.new(1,-20,0,32))
        local iconId=offer.id=="money_hour" and "upgrade_compute" or offer.id=="agent" and "add_layer" or "prestige"
        local catalog=(offer.id=="money_hour" or offer.id=="agent") and StoreIcons or Features
        local icon=Icon.create(frame,iconId,catalog);icon.Position=UDim2.new(.5,0,0,144);Icon.resize(icon,96,catalog)
        local description=Visual.caption(frame,offer.description,14,c.text,UDim2.fromOffset(12,212),UDim2.new(1,-24,0,88))
        local status=Theme.text(frame,"",14,c.mint,UDim2.fromOffset(12,306),UDim2.new(1,-24,0,40));status.TextXAlignment=Enum.TextXAlignment.Center;status.ZIndex=4
        local price=Theme.text(frame,string.format("%d Robux / target",offer.price),16,Theme.pixelColors.gold,UDim2.fromOffset(12,350),UDim2.new(1,-24,0,40))
        price.TextXAlignment=Enum.TextXAlignment.Center;price.ZIndex=4
        local buy,art=Theme.pixelButton(frame,"UNAVAILABLE",UDim2.new(.5,-104,1,-54),UDim2.fromOffset(208,40),function(input)
            local entry=self.entries[offer.id]
            if not self:allowed(input,entry.buy) or not entry.buy.Active then return end
            if offer.id=="agent" and self.data.premium.agentCredits>0 then self:request("premium_redeem",{})
            else self:request("premium_buy",{sku=offer.id}) end
        end)
        buy.ZIndex=4;buy.Name="BuyRobux";art.label.TextSize=14
        self.entries[offer.id]={offer=offer,frame=frame,icon=icon,name=name,description=description,status=status,price=price,buy=buy,art=art}
    end
    self.note=Theme.text(self.body,"1 hour uses real time, including offline time. Buying again extends time.\nTemporary and Forever bonuses stay at 2x. Agents reset at prestige; unused credits stay.\nRoblox shows the final price and asks you to confirm.",14,c.muted,UDim2.fromOffset(12,0),UDim2.new(1,-32,0,220));self.note.ZIndex=3
    self.message=Theme.text(self.frame,"Purchases are not configured for this experience.",14,c.muted,UDim2.new(0,12,1,-88),UDim2.new(1,-24,0,80));self.message.ZIndex=4
    self:render();return self
end
function Shop:allowed(input,target)
    if self.destroyed or not self.frame.Visible or not self.data or self.data.blocked or self.progressionPending or self.waiting
        or self.data.commerce and self.data.commerce.busy or (self.allowPointer and not self.allowPointer(input)) then return false end
    if input and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
        if not contains(target,input.Position) or not contains(self.frame,input.Position) then return false end
        if target:IsDescendantOf(self.body) and not contains(self.body,input.Position) then return false end
    end
    return true
end
function Shop:request(action,payload)
    self.sequence=self.sequence+1;payload.requestId=self.sequence
    self.waiting=true;self.waitAge=0;self.waitId=self.sequence;self.message.Text="Waiting for Roblox...";self:render()
    if self.onAction then self.onAction() end
    self.onCommand(action,payload)
end
function Shop:loadPrices(force)
    if not self.data or not self.data.commerce then return end
    for id,entry in pairs(self.entries) do
        local wire=self.data.commerce.offers[id]
        if wire and wire.assetId>0 and (force or entry.quotedId~=wire.assetId) and not entry.loading then
            entry.quotedId=wire.assetId;entry.loading=true;entry.quote=nil
            task.spawn(function()
                local ok,info=pcall(function() return Market:GetProductInfoAsync(wire.assetId,entry.offer.kind=="pass" and Enum.InfoType.GamePass or Enum.InfoType.Product) end)
                if self.destroyed then return end
                entry.loading=false
                if ok and type(info)=="table" and info.IsForSale==true and type(info.PriceInRobux)=="number"
                    and info.PriceInRobux>=0 and info.PriceInRobux<1000000 and info.PriceInRobux%1==0 then entry.quote=info.PriceInRobux end
                self:render()
            end)
        end
    end
end
function Shop:setOpen(value)
    local changed=self.frame.Visible~=value;self.frame.Visible=value
    if value and changed then self:loadPrices(true);self:render() end
end
function Shop:update(data,pending)
    self.data=data;self.progressionPending=pending
    local wire=data.commerce
    if wire then self.sequence=math.max(self.sequence,wire.sequence or 0) end
    if wire and ((wire.sequence or 0)>=(self.waitId or math.huge) or wire.checkedId==self.waitId) then
        self.waiting=false;self.uncertain=false;self.waitId=nil
    end
    self.elapsed=0
    self:loadPrices(false);self:render()
end
local function remaining(untilTime,now)
    local seconds=math.max(0,math.ceil(untilTime-now));return string.format("%02d:%02d:%02d",math.floor(seconds/3600),math.floor(seconds/60)%60,seconds%60)
end
function Shop:render()
    local data=self.data;local wire=data and data.commerce;local p=data and data.premium
    local now=(wire and wire.serverTime or 0)+(self.elapsed or 0)
    for id,entry in pairs(self.entries) do
        local offer=entry.offer;local configured=wire and wire.offers[id]
        local owned=p and p.forever and id=="forever"
        local included=p and p.forever and (id=="money_hour" or id=="chips_hour")
        local redeem=id=="agent" and p and p.agentCredits>0
        local cap=data and #data.layerSizes-2>=8
        local pending=self.waiting or self.uncertain or wire and (wire.pending or wire.busy)
        local ready=data and not data.blocked and not self.progressionPending and not pending and not owned and not included
            and ((redeem and not cap) or configured and configured.ready and entry.quote~=nil and not (id=="agent" and cap))
        entry.price.Text=entry.quote and (entry.quote.." Robux") or string.format("%d Robux / target",offer.price)
        local stateText=owned and "OWNED" or included and "INCLUDED" or pending and "WAIT..." or redeem and (cap and "CREDIT SAVED" or "USE CREDIT") or ready and "BUY" or "UNAVAILABLE"
        entry.buy.Text=stateText;entry.art.label.Text=stateText;entry.art.label.TextColor3=ready and c.accent or owned and c.mint or c.muted
        entry.buy.Active,entry.buy.Selectable=ready and true or false,ready and true or false
        if id=="forever" then entry.status.Text=owned and "Both bonuses active" or "2x MONEY + 2x CHIPS"
        elseif id=="agent" then entry.status.Text=p and string.format("%d/8 agents / %d saved credits",#data.layerSizes-2,p.agentCredits) or "1 extra writer"
        else
            local expires=p and (id=="money_hour" and p.moneyUntil or p.chipsUntil) or 0
            entry.status.Text=included and "Forever active" or expires>now and ("ACTIVE / "..remaining(expires,now)) or "60 real-time minutes"
        end
    end
    if wire then
        self.message.Text=wire.message or (wire.offers.forever and wire.offers.forever.ready and "Choose an offer. Confirm the final price in Roblox." or "Purchases are not configured for this experience.")
        if wire.pending then self.message.Text=wire.message or "Waiting for Roblox receipt. Use CHECK or rejoin if delayed." end
    end
    if self.waiting then self.message.Text="Waiting for Roblox..."
    elseif self.uncertain then self.message.Text="No reply. Use CHECK; purchase was not repeated." end
end
function Shop:tick(dt)
    if self.destroyed then return end
    self.elapsed=self.elapsed+math.max(0,math.min(1,dt))
    if self.waiting then self.waitAge=self.waitAge+math.max(0,dt);if self.waitAge>=8 then self.waiting=false;self.uncertain=true end end
    if self.frame.Visible then self:render() end
end
function Shop:layout(width,height,header)
    self.frame.Position=UDim2.fromOffset(8,header+8);self.frame.Size=UDim2.fromOffset(math.max(1,width-16),math.max(120,height-header-16))
    local available=math.max(224,self.body.AbsoluteSize.X-24)
    local hero=self.entries.forever;hero.frame.Position=UDim2.fromOffset(8,80);hero.frame.Size=UDim2.fromOffset(available,456)
    local columns=math.max(1,math.min(3,math.floor((available+16)/336)))
    local cardWidth=math.min(400,math.floor((available-16*(columns-1))/columns))
    for index,id in ipairs({"money_hour","chips_hour","agent"}) do
        local row=math.floor((index-1)/columns);local inRow=math.min(columns,3-row*columns)
        local left=8+math.floor((available-inRow*cardWidth-(inRow-1)*16)/2)
        self.entries[id].frame.Position=UDim2.fromOffset(left+((index-1)%columns)*(cardWidth+16),560+row*480)
        self.entries[id].frame.Size=UDim2.fromOffset(cardWidth,456)
    end
    local noteY=576+math.ceil(3/columns)*480;self.note.Position=UDim2.fromOffset(12,noteY)
    self.body.CanvasSize=UDim2.fromOffset(0,noteY+240)
    local unit=math.max(8,math.ceil(math.max(height/32,width/32)/4)*4)
    for index,part in ipairs(self.stripes) do local row,column=math.floor((index-1)/8),(index-1)%8;part.Position=UDim2.fromOffset((column*unit*4+row*unit)%(unit*32)-unit,row*unit);part.Size=UDim2.fromOffset(unit,unit) end
end
function Shop:destroy() self.destroyed=true;self.onCommand=nil;self.onAction=nil;self.frame:Destroy() end
return Shop

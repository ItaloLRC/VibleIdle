--!nonstrict
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local RunService=game:GetService("RunService")
local GuiService=game:GetService("GuiService")
local UserInputService=game:GetService("UserInputService")
local Theme=require(script.Parent.DeskTheme)
local Terminal=require(script.Parent.TerminalController)
local TerminalDesk=require(script.Parent.TerminalDesk)
local PixelWallpaper=require(script.Parent.PixelWallpaper)
local SkillCheckController=require(script.Parent.SkillCheckController)
local AudioController=require(script.Parent.AudioController)
local BackdropDancers=require(script.Parent.BackdropDancers)
local FloatingWords=require(script.Parent.FloatingWords)
local StoreIcon=require(script.Parent.StoreIcon)
local FeatureIcons=require(script.Parent.FeatureIconCatalog)
local AgentLab=require(script.Parent.AgentLab)
local PrestigePage=require(script.Parent.PrestigePage)
local PrestigeTransition=require(script.Parent.PrestigeTransition)
local CardsPage=require(script.Parent.CardsPage)
local RobuxShop=require(script.Parent.RobuxShop)
local Onboarding=require(script.Parent.Onboarding)
local UiMotion=require(script.Parent.UiMotion)
local Shared=ReplicatedStorage:WaitForChild("Shared")
local Balance,Rules,Agent=require(Shared.Balance),require(Shared.UpgradeRules),require(Shared.AgentSession)
local State=require(Shared.State)
local PromptSession=require(Shared.PromptSession)
local Simulation=require(Shared.Simulation)
local Collectibles=require(Shared.StreakCollectibles)
local Tuning=require(Shared.StudioTuning)
local remotes=ReplicatedStorage:WaitForChild("Remotes")
local command,stateUpdate=remotes:WaitForChild("Command"),remotes:WaitForChild("StateUpdate")
local create,text,button=Theme.create,Theme.text,Theme.button
local c=Theme.colors
local connections={}
local function connect(signal,callback) connections[#connections+1]=signal:Connect(callback) end
local playerGui=Players.LocalPlayer:WaitForChild("PlayerGui")
GuiService.TouchControlsEnabled=false
local backdrop=create("ScreenGui",playerGui,{Name="VibeIdleBackdrop",ResetOnSpawn=false,
    ScreenInsets=Enum.ScreenInsets.None,ClipToDeviceSafeArea=false,DisplayOrder=19})
create("Frame",backdrop,{Name="PrestigeVoid",BackgroundColor3=Color3.fromRGB(9,5,17),BorderSizePixel=0,
    Active=false,Selectable=false,ZIndex=0,Size=UDim2.fromScale(1,1)})
local wallpaper=PixelWallpaper.create(backdrop)
local function lockCamera()
    if Workspace.CurrentCamera then
        Workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable
        Workspace.CurrentCamera.CFrame=CFrame.new(Vector3.new(28,21,35),Vector3.new(0,3,0))
    end
end
connect(Workspace:GetPropertyChangedSignal("CurrentCamera"),lockCamera);lockCamera()
local gui=create("ScreenGui",playerGui,{Name="VibeIdleGui",ResetOnSpawn=false,
    ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,DisplayOrder=20,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
local root=create("Frame",gui,{Name="Workstation",BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,Size=UDim2.fromScale(1,1)})
local backgroundClick=create("TextButton",root,{Name="FreeSpaceClick",Text="",BackgroundTransparency=1,
    BorderSizePixel=0,Active=true,AutoButtonColor=false,Selectable=false,ZIndex=0,Size=UDim2.fromScale(1,1)})
local content=create("Frame",root,{Name="Pages",BackgroundTransparency=1,BorderSizePixel=0})
local desktop=create("ScrollingFrame",content,{Name="TerminalDesktop",BackgroundTransparency=1,BorderSizePixel=0,
    ClipsDescendants=true,Size=UDim2.fromScale(1,1),CanvasSize=UDim2.fromScale(1,1),
    ScrollingDirection=Enum.ScrollingDirection.XY,ScrollingEnabled=false,Active=false,
    ScrollBarThickness=0,ScrollBarImageColor3=c.line})
local current,page,layout=nil,"CLI",nil
local lastSnapshotSequence=0
local setPage
local store
local featureDock
local moneyHUD
local featureButtons={}
local iconHovers={}
local skillTestControls={}
local reconnect,connectionError
local handshakeTime,attempt=0,1
local retryAt={0,2,4,8,12}
local terminal=Terminal.new(desktop,Balance,function(request)
    if current and not current.blocked then command:FireServer("submit_prompt",request) end
end,root)
terminal.onSync=function() command:FireServer("sync") end
terminal.onAgent=function(payload) command:FireServer("agent_type",payload) end
terminal.onAgentSync=function(payload) command:FireServer("agent_sync",payload) end
local audio=AudioController.new(terminal)
terminal.onTokenCollected=function(event) audio:coin(event) end
terminal.onSellPress=function() audio:click("sell") end
local desk=TerminalDesk.new(desktop,terminal,Balance)
local progression
local agentLab=AgentLab.new(content,Balance,function(id) progression:request("craft_card",{cardId=id}) end)
local robuxShop=RobuxShop.new(content,function(action,payload) command:FireServer(action,payload) end)
robuxShop.onAction=function() audio:click("shop") end
local cardPage
progression=PrestigePage.new(content,Balance,function(action,payload) command:FireServer(action,payload) end)
progression.onPending=function(value)
    terminal.progressionPending=value;terminal:refreshControls()
    local waiting="Change pending. Reconnect if delayed."
    if value then terminal.hint.Text=waiting
    elseif terminal.hint.Text==waiting then terminal.hint.Text="Change checked. Continue playing." end
    if cardPage then cardPage:setPending(value,progression.message.Text) end
    agentLab:update(nil,value,progression.message.Text)
end
cardPage=CardsPage.new(content,Balance,function(action,payload) progression:request(action,payload) end)
cardPage.onSelect=function() audio:click("select") end
progression.onAction=function(action)
    audio:click(action=="buy_skill" and "shop" or action=="prestige" and "confirm" or action=="review_prestige" and "navigate" or "select")
end
progression.canReset=function() return not terminal.composer.flight and not terminal.skillPending and not terminal.agentPending end
-- Separate passive surface stays above every workstation window/page/skill control.
local streakGui=create("ScreenGui",playerGui,{Name="VibeIdleStreakAvatars",ResetOnSpawn=false,
    ScreenInsets=Enum.ScreenInsets.None,ClipToDeviceSafeArea=false,DisplayOrder=21,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
local dancers=BackdropDancers.new(streakGui,terminal,desk)
dancers.onCollect=function(payload) audio:click("collect");command:FireServer("collect_avatar",payload) end
dancers.onSync=function(payload) command:FireServer("avatar_sync",payload) end
dancers.onPoll=function(payload) command:FireServer("avatar_poll",payload) end
local skillGui=create("ScreenGui",playerGui,{Name="VibeIdleSkillPriority",ResetOnSpawn=false,
    ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets,DisplayOrder=22,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
local skillRoot=create("Frame",skillGui,{Name="SkillPriorityRoot",BackgroundTransparency=1,
    BorderSizePixel=0,Active=false,Selectable=false,Size=UDim2.fromScale(1,1)})
local skillCheck=SkillCheckController.new(skillRoot,terminal,function(payload)
    command:FireServer("skill_click",payload)
end,function(payload) command:FireServer("skill_sync",payload) end)
skillCheck.autoSubmit=function(payload) command:FireServer("auto_skill",payload) end
terminal.onBeforeAgents=function() skillCheck:tickAuto() end
local floatingWords=FloatingWords.new(root,terminal,skillCheck.layer)
local prestigeTransition=PrestigeTransition.new(playerGui,{root,wallpaper,skillRoot,dancers.layer})
local uiMotion=UiMotion.new(playerGui,terminal,root,content)
local onboarding=Onboarding.new(playerGui,terminal,{motion=uiMotion,viewport=root,skill=skillCheck,dancers=dancers,desktop=desktop,
    onState=function(blocking) if store then store.Visible=page=="CLI" and not blocking end;if layout then layout() end end,
    onStart=function() if setPage then setPage("CLI",false,true) end;desk.drag=nil;desk:focus(1) end,
    onExit=function() terminal:focusInput() end,
    onComplete=function(payload) command:FireServer("tutorial_complete",payload) end,
    reconnect=function() if reconnect then reconnect() end end})
terminal.onSaleConfirmed=function(receipt) onboarding:confirmedSale(receipt) end
local analyticsSequence,analyticsAt,analyticsButton,analyticsEnter=0,-math.huge,0,0
terminal.onSellAttempt=function(source)
    if source=="button" then analyticsButton=math.min(1000000000,analyticsButton+1)
    else analyticsEnter=math.min(1000000000,analyticsEnter+1) end
end
skillCheck.allowCircle=function(input) return not desk.drag and onboarding:allows("Skill",input) end
dancers.allowPointer=function(input) return not desk.drag and onboarding:allows("Visitor",input) and not skillCheck:blocksPointer(input) end
local collectVisitor=dancers.onCollect
dancers.onCollect=function(payload) onboarding:pressedVisitor(payload.id);collectVisitor(payload) end
skillCheck.onPress=function() audio:click("skill");floatingWords:emit() end
skillCheck.onConfirmed=function(result) audio:confirmed(result);dancers:confirmed(result);onboarding:confirmedSkill(result) end
local function containsPointer(object,input)
    local p,s=object.AbsolutePosition,object.AbsoluteSize
    return input.Position.X>=p.X and input.Position.X<p.X+s.X
        and input.Position.Y>=p.Y and input.Position.Y<p.Y+s.Y
end
local function finishPageEntrance()
    if not uiMotion:busy() then content.Position=UDim2.fromOffset(0,0) end
end
local function refreshIconHover(entry)
    local pointer=entry.pointer
    local hovered=pointer~=nil and page=="CLI" and terminal.windowFocused and not GuiService.MenuIsOpen
        and not prestigeTransition.active
        and not desk.drag and entry.target.Active and entry.target.Visible
    if hovered then
        for _,clip in ipairs(entry.clips) do
            if not clip.Visible or not containsPointer(clip,pointer) then hovered=false;break end
        end
        hovered=hovered and containsPointer(entry.target,pointer)
            and not skillCheck:blocksPointer(pointer) and not dancers:blocksPointer(pointer)
    end
    StoreIcon.setHovered(entry.icon,hovered and true or false)
end
local function hoverIcon(icon,target,clips)
    local entry={icon=icon,target=target,clips=clips or {}}
    iconHovers[#iconHovers+1]=entry
    local function moved(x,y)
        entry.pointer={Position=Vector2.new(x,y),UserInputType=Enum.UserInputType.MouseButton1}
        refreshIconHover(entry)
    end
    connect(target.MouseEnter,moved)
    connect(target.MouseMoved,moved)
    connect(target.MouseLeave,function() entry.pointer=nil;StoreIcon.setHovered(icon,false) end)
    connect(target:GetPropertyChangedSignal("Active"),function() refreshIconHover(entry) end)
end
local function featureBlocksPointer(input)
    if uiMotion:busy() then return true end
    if onboarding:blocks() then return true end
    if prestigeTransition.active then return true end
    if page~="CLI" then return false end
    if not input or not input.Position then return false end
    if moneyHUD and containsPointer(moneyHUD,input) then return true end
    return featureDock and featureDock.Visible and containsPointer(featureDock,input) or false
end
local function storeBlocksPointer(input)
    return page=="CLI" and store and store.Visible and input and input.Position and containsPointer(store,input)
end
skillCheck.allowFreeSpace=function(input)
    if uiMotion:busy() then return false end
    if onboarding:blocks() then return false end
    if prestigeTransition.active then return false end
    if page~="CLI" or desk.drag or dancers:blocksPointer(input) or not containsPointer(root,input) or skillCheck:blocksPointer(input) then return false end
    -- The dock occupies the bottom strip even between buttons.
    if input.Position.Y>=root.AbsolutePosition.Y+root.AbsoluteSize.Y-44 then return false end
    if store and store.Visible and containsPointer(store,input) then return false end
    if featureBlocksPointer(input) then return false end
    for _,window in ipairs(desk.windows) do
        if window.frame.Visible and containsPointer(window.frame,input) then return false end
    end
    return true
end
local backgroundPointer
connect(backgroundClick.InputBegan,function(input)
    backgroundPointer=nil
    if (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch)
        and skillCheck.allowFreeSpace(input) then backgroundPointer=input end
end)
connect(backgroundClick.Activated,function(input)
    local started=backgroundPointer;backgroundPointer=nil
    if input and input==started then skillCheck:press(input,true) end
end)
terminal.onInput=function() desk:focus(1) end
terminal.onActivate=function(input) return desk:activate(1,input) end
desk.onActivate=function(input)
    if uiMotion:busy() then return false end
    if onboarding:blocks() then return onboarding:allows("Sell",input) and (not input or containsPointer(terminal.send,input)) end
    return not prestigeTransition.active and page=="CLI" and not storeBlocksPointer(input) and not skillCheck:blocksPointer(input) and not dancers:blocksPointer(input) and not featureBlocksPointer(input)
end
desk:focus(1)
agentLab.allowPointer=function(input)
    if uiMotion:busy() then return false end
    local focused=UserInputService:GetFocusedTextBox()
    if prestigeTransition.active or not current or terminal.blocked or page~="Lab" or desk.drag or GuiService.MenuIsOpen or not terminal.windowFocused
        or (focused and focused~=terminal.input) or terminal:hasModifier() then return false end
    return not input or (not skillCheck:blocksPointer(input) and not dancers:blocksPointer(input) and not featureBlocksPointer(input))
end
progression.allowPointer=function(input)
    if uiMotion:busy() then return false end
    local focused=UserInputService:GetFocusedTextBox()
    return not prestigeTransition.active and current and not terminal.blocked and (page=="Prestige" or page=="Tree") and not desk.drag and not GuiService.MenuIsOpen and terminal.windowFocused
        and (not focused or focused==terminal.input) and not terminal:hasModifier()
        and (not input or (not dancers:blocksPointer(input) and not featureBlocksPointer(input)))
end
cardPage.allowPointer=function(input)
    if uiMotion:busy() then return false end
    local focused=UserInputService:GetFocusedTextBox()
    return not prestigeTransition.active and current and not terminal.blocked and page=="Cards" and not desk.drag and not GuiService.MenuIsOpen and terminal.windowFocused
        and (not focused or focused==terminal.input) and not terminal:hasModifier()
        and (not input or (not dancers:blocksPointer(input) and not featureBlocksPointer(input)))
end
robuxShop.allowPointer=function(input)
    if uiMotion:busy() then return false end
    local focused=UserInputService:GetFocusedTextBox()
    return not prestigeTransition.active and current and not terminal.blocked and page=="Robux" and not desk.drag
        and not GuiService.MenuIsOpen and terminal.windowFocused and (not focused or focused==terminal.input) and not terminal:hasModifier()
        and (not input or (not dancers:blocksPointer(input) and not featureBlocksPointer(input)))
end
cardPage.onFocusSlot=function(target)
    if UserInputService.GamepadEnabled or GuiService.SelectedObject then GuiService.SelectedObject=target end
end
agentLab.onMove=function() audio:click("select") end
agentLab.onOpenCards=function() audio:click("navigate");setPage("Cards",true) end
moneyHUD=create("Frame",root,{Name="MoneyHUD",BackgroundTransparency=1,BorderSizePixel=0,
    Active=false,Selectable=false,ZIndex=14,Position=UDim2.fromOffset(12,10),Size=UDim2.fromOffset(480,120)})
local hudBlack=Color3.fromRGB(0,0,0)
local moneyShadow=text(moneyHUD,"$0.00",54,hudBlack,UDim2.fromOffset(5,2),UDim2.new(1,-6,0,66),Theme.mono)
moneyShadow.Name,moneyShadow.Active,moneyShadow.Selectable="Shadow",false,false
local moneyValue=text(moneyHUD,"$0.00",54,c.mint,UDim2.fromOffset(3,0),UDim2.new(1,-6,0,66),Theme.mono)
moneyValue.Name,moneyValue.Active,moneyValue.Selectable="Balance",false,false
local chipsValue=text(moneyHUD,"0 Chips",38,c.amber,UDim2.fromOffset(3,74),UDim2.new(1,-6,0,46),Theme.mono)
chipsValue.Name,chipsValue.Active,chipsValue.Selectable="Chips",false,false
for _,label in ipairs({moneyValue,chipsValue}) do
    label.TextWrapped=false
    create("UIStroke",label,{Name="TextOutline",Color=hudBlack,Thickness=3,Transparency=0,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Contextual})
end
moneyShadow.TextWrapped=false
local function fitMoney()
    if prestigeTransition.active and not prestigeTransition.covered then return end
    local size=54
    while size>12 and Theme.textWidth(moneyValue.Text,size)>moneyHUD.AbsoluteSize.X-6 do size=size-2 end
    moneyValue.TextSize,moneyShadow.TextSize=size,size
    local chipSize=38
    while chipSize>12 and Theme.textWidth(chipsValue.Text,chipSize)>moneyHUD.AbsoluteSize.X-6 do chipSize=chipSize-1 end
    chipsValue.TextSize=chipSize
end
featureDock=create("ScrollingFrame",root,{Name="FeatureDock",BackgroundTransparency=1,BorderSizePixel=0,
    Active=true,Selectable=false,ClipsDescendants=true,ScrollingDirection=Enum.ScrollingDirection.X,
    ScrollBarThickness=5,ScrollBarImageColor3=c.accent,CanvasSize=UDim2.fromOffset(292,0),
    ZIndex=14,Position=UDim2.fromOffset(8,8),Size=UDim2.fromOffset(292,70)})
local featureDefinitions={{"laboratory","Laboratory"},{"cards","Cards"},{"skill_tree","SkillTree","Skill tree"},{"prestige","Prestige"},{"robux_shop","RobuxShop","Robux shop"}}
local function activateFeature(id,input)
    if uiMotion:busy() then return end
    if onboarding:blocks() then return end
    if prestigeTransition.active then return end
    if page~="CLI" or not featureDock.Visible then return end
    if desk.drag or GuiService.MenuIsOpen or not terminal.windowFocused then return end
    if input and (skillCheck:blocksPointer(input) or dancers:blocksPointer(input)) then return end
    if input and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch)
        and (not containsPointer(featureDock,input) or not containsPointer(featureButtons[id].button,input)) then return end
    featureDock:SetAttribute("SelectedFeature",id)
    for key,entry in pairs(featureButtons) do
        local selected=key==id
        entry.button:SetAttribute("Selected",selected)
        for _,part in ipairs(entry.art.parts) do part.BackgroundColor3=selected and c.selected or c.paper end
    end
    audio:click("navigate")
    if id=="laboratory" then setPage(page=="Lab" and "CLI" or "Lab",true)
    elseif id=="skill_tree" then setPage(page=="Tree" and "CLI" or "Tree",true)
    elseif id=="prestige" then setPage(page=="Prestige" and "CLI" or "Prestige",true)
    elseif id=="robux_shop" then setPage("Robux",true)
    else setPage(page=="Cards" and "CLI" or "Cards",true) end
end
for index,definition in ipairs(featureDefinitions) do
    local id,label=definition[1],definition[3] or definition[2]
    local control,art=Theme.pixelButton(featureDock,label,UDim2.fromOffset((index-1)*76,0),UDim2.fromOffset(64,64),function(input)
        activateFeature(id,input)
    end)
    control.Name,control.Active,control.Selectable=definition[2],true,true
    control:SetAttribute("FeatureId",id);control:SetAttribute("Selected",false)
    art.label.Visible=false
    local icon=StoreIcon.create(control,id,FeatureIcons)
    icon.Name,icon.Position="FeatureIcon",UDim2.fromOffset(32,31)
    StoreIcon.resize(icon,48,FeatureIcons)
    hoverIcon(icon,control,{featureDock})
    featureButtons[id]={button=control,art=art}
end
store=create("Frame",root,{Name="StorePanel",BackgroundTransparency=1,BorderSizePixel=0,
    Active=true,Visible=true,ZIndex=12,Size=UDim2.fromOffset(288,600)})

local storeTitle=text(store,"SHOP",16,c.text,UDim2.fromOffset(12,8),UDim2.fromOffset(80,40))
local quantityIndex=1
local purchaseSequence,purchasePending=0,nil
local refreshShopQuotes
local quantity,quantityArt
quantity,quantityArt=Theme.pixelButton(store,"1X",UDim2.new(1,-72,0,0),UDim2.fromOffset(64,44),function(input)
    if uiMotion:busy() then return end
    if onboarding:blocks() then return end
    if prestigeTransition.active then return end
    if page~="CLI" or not store.Visible or not terminal.windowFocused or GuiService.MenuIsOpen or desk.drag then return end
    local pointer=input and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch)
    if pointer and (not containsPointer(quantity,input) or skillCheck:blocksPointer(input) or dancers:blocksPointer(input)) then return end
    quantityIndex=quantityIndex%#Rules.SHOP_QUANTITIES+1
    local value=Rules.SHOP_QUANTITIES[quantityIndex]
    quantity.Text=value=="max" and "MAX" or value.."X";quantityArt.label.Text=quantity.Text
    quantity:SetAttribute("Quantity",value)
    audio:click("select");refreshShopQuotes()
end)
quantity.Name="PurchaseQuantity";quantityArt.label.TextSize=14
quantity:SetAttribute("Quantity",1)
local purchaseStatus=text(store,"",11,c.muted,UDim2.fromOffset(8,44),UDim2.new(1,-16,0,18))
purchaseStatus.Name="PurchaseStatus"
local storeCaption=text(store,"Three upgrades: token value, agent count and context.",14,c.muted,
    UDim2.fromOffset(16,52),UDim2.new(1,-32,0,48))
local shop=create("ScrollingFrame",store,{Name="UpgradeList",BackgroundTransparency=1,BorderSizePixel=0,
    Position=UDim2.fromOffset(12,108),Size=UDim2.new(1,-24,1,-120),CanvasSize=UDim2.fromOffset(0,0),
    ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=5,ScrollBarImageColor3=c.shadow})
local cards={}
local shopPalette={
    Unavailable={fill=Color3.fromRGB(83,83,89),edge=c.black,
        top=Color3.fromRGB(151,151,157),bottom=Color3.fromRGB(61,61,67),
        ink=Color3.fromRGB(255,106,106),shadow=Color3.fromRGB(57,26,31)},
    Affordable={fill=Color3.fromRGB(223,133,66),edge=c.black,
        top=Color3.fromRGB(255,205,121),bottom=Color3.fromRGB(169,88,38),
        ink=Color3.fromRGB(65,36,26),shadow=Color3.fromRGB(247,171,100)},
    Maxed={fill=Color3.fromRGB(222,177,65),edge=c.black,
        top=Color3.fromRGB(255,236,158),bottom=Color3.fromRGB(153,111,32),
        ink=Color3.fromRGB(65,43,18),shadow=Color3.fromRGB(244,211,119)},
}
local function paintShopCard(card,state)
    if card.frame:GetAttribute("PurchaseState")==state then return end
    card.frame:SetAttribute("PurchaseState",state)
    local palette=shopPalette[state]
    for _,fill in ipairs(card.fills) do fill.BackgroundColor3=palette.fill end
    for _,edge in ipairs(card.edges) do edge.BackgroundColor3=palette.edge end
    card.highlight.BackgroundColor3,card.inset.BackgroundColor3=palette.top,palette.bottom
    for _,pair in ipairs(card.shadows) do
        pair[1].TextColor3,pair[2].TextColor3=palette.ink,palette.shadow
    end
end
local function tickShopPress(dt)
    for _,card in pairs(cards) do
        if card.pressAge then
            card.pressAge=card.pressAge+math.max(0,math.min(0.1,dt))
            local age=card.pressAge
            local offset=age<0.08 and 3 or age<0.14 and -1 or 0
            if terminal.reduced or page~="CLI" or not terminal.windowFocused or GuiService.MenuIsOpen or age>=0.22 then
                offset=0;card.pressAge=nil
            end
            card.face.Position=UDim2.fromOffset(0,offset)
            card.frame:SetAttribute("PressOffset",offset)
        end
    end
end
local studioTools,studioPage,studioScroll
local studioRelayout
local layoutShop
local layingShop=false
local shopLayoutStamp
local upgradeCount=0
local function upgrade(action,heading,description,order)
    upgradeCount=upgradeCount+1
    local card=create("Frame",shop,{Name=action,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.fromOffset(264,102),LayoutOrder=order})
    card:SetAttribute("Description",description)
    local palette=shopPalette.Unavailable
    local ink=palette.ink
    create("Frame",card,{Name="StripShadow",BorderSizePixel=0,Active=false,Selectable=false,
        BackgroundColor3=Color3.fromRGB(58,38,60),Position=UDim2.fromOffset(4,6),Size=UDim2.new(1,0,1,-2)})
    local face,edges,fills=Theme.pixelPanel(card,"StripFace",UDim2.fromOffset(0,0),UDim2.fromScale(1,1),palette.fill)
    for _,edge in ipairs(edges) do edge.BackgroundColor3=palette.edge end
    local highlight=create("Frame",face,{Name="TopHighlight",BorderSizePixel=0,Active=false,Selectable=false,
        BackgroundColor3=palette.top,
        Position=UDim2.fromOffset(8,4),Size=UDim2.new(1,-16,0,3)})
    local inset=create("Frame",face,{Name="BottomInset",BorderSizePixel=0,Active=false,Selectable=false,
        BackgroundColor3=palette.bottom,
        Position=UDim2.new(0,8,1,-10),Size=UDim2.new(1,-16,0,3)})
    local function label(value,size,color)
        local shadow=text(card,value,size,palette.shadow,UDim2.fromOffset(0,0),UDim2.fromOffset(100,24))
        shadow.Name="PixelTextShadow";shadow.Active=false;shadow.Selectable=false;shadow.ZIndex=2
        local item=text(card,value,size,color,UDim2.fromOffset(0,0),UDim2.fromOffset(100,24))
        item.Active=false;item.Selectable=false;item.ZIndex=3
        return item,shadow
    end
    local title,titleShadow=label(string.upper(heading),16,ink)
    title.Name="UpgradeName"
    local status,statusShadow=label("",18,ink)
    status.Name="UpgradeStatus"
    local price,priceShadow=label("...",16,ink)
    price.Name="UpgradePrice";price.TextXAlignment=Enum.TextXAlignment.Right;priceShadow.TextXAlignment=Enum.TextXAlignment.Right
    local buy=create("TextButton",card,{Name="BuyUpgrade",Text="Opening session...",TextTransparency=1,BackgroundTransparency=1,
        BorderSizePixel=0,AutoButtonColor=false,Position=UDim2.fromOffset(0,0),Size=UDim2.fromScale(1,1),ZIndex=4})
    local entry
    buy.Activated:Connect(function(input)
        if uiMotion:busy() then return end
        if onboarding:blocks() then return end
        if prestigeTransition.active then return end
        if page~="CLI" or not store.Visible or not buy.Active or not terminal.windowFocused or GuiService.MenuIsOpen then return end
        local pointer=input and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch)
        if pointer and (not containsPointer(buy,input) or not containsPointer(store,input) or not containsPointer(shop,input)) then return end
        if pointer and (skillCheck:blocksPointer(input) or dancers:blocksPointer(input)) then return end
        if current and not current.blocked and not desk.drag then
            entry.pressAge=0;tickShopPress(0)
            audio:click("shop")
            purchaseSequence=purchaseSequence+1
            local value=Rules.SHOP_QUANTITIES[quantityIndex]
            purchasePending={requestId=purchaseSequence,action=action,quantity=value,age=0,syncs=0}
            refreshShopQuotes()
            command:FireServer(action,{requestId=purchaseSequence,quantity=value})
        end
    end)
    buy.Active,buy.Selectable=false,false
    entry={frame=card,title=title,status=status,price=price,buy=buy,order=order,
        face=face,edges=edges,fills=fills,highlight=highlight,inset=inset,
        shadows={{title,titleShadow},{status,statusShadow},{price,priceShadow}}}
    cards[action]=entry;paintShopCard(entry,"Unavailable")
end
upgrade("upgrade_compute","Token value","No level cap. +35% base per level; +25% milestone factor every 10 levels.",1)
upgrade("add_layer","Agent count","+1 automatic agent and an avatar in Main CLI, up to 8 agents.",2)
upgrade("upgrade_tokens","Context","+8 tokens per prompt, up to 64. Unlock Auto sell in the skill tree.",3)
local function stripValues()
    if current then
        local value,nextValue=current.moneyPerToken,current.moneyPerToken
        local quote=cards.upgrade_compute.quote
        if quote and quote.count>0 then
            local projected=State.copy(current)
            projected.layerSizes=quote.after.layerSizes;projected.computeLevel=quote.after.computeLevel
            nextValue=PromptSession.baseReward(projected,Balance,Simulation)
        end
        local status=cards.upgrade_compute.status
        local values=Theme.money(value).." > "..Theme.money(nextValue)
        if Theme.textWidth(values,status.TextSize)>status.AbsoluteSize.X then
            values=Theme.money(value).."\n> "..Theme.money(nextValue)
        end
        status.Text=(quote and quote.count>0 and values or Theme.money(value)).."\nBASE / TOKEN"
        local count=#current.layerSizes-2
        local agentQuote=cards.add_layer.quote
        cards.add_layer.status.Text=(agentQuote and agentQuote.count>0 and (count.." > "..(#agentQuote.after.layerSizes-2)) or tostring(count)).."\nAGENTS"
        local limit=current.tokenLimit
        local contextQuote=cards.upgrade_tokens.quote
        local nextLimit=contextQuote and math.min(Balance.PROMPT_MAX_TOKENS,Balance.PROMPT_BASE_TOKENS+contextQuote.after.tokenLevel*Balance.PROMPT_TOKENS_PER_LEVEL) or limit
        cards.upgrade_tokens.status.Text=(contextQuote and contextQuote.count>0 and (limit.." > "..nextLimit) or tostring(limit)).."\nTOKENS"
    end
    for _,card in pairs(cards) do
        for _,pair in ipairs(card.shadows) do
            local source,shadow=pair[1],pair[2]
            shadow.Text,shadow.TextSize,shadow.Size=source.Text,source.TextSize,source.Size
            shadow.Position=UDim2.new(source.Position.X.Scale,source.Position.X.Offset+1,source.Position.Y.Scale,source.Position.Y.Offset+2)
        end
    end
end
refreshShopQuotes=function()
    for action,card in pairs(cards) do
        local quote=current and Rules.quoteMany(current,action,Rules.SHOP_QUANTITIES[quantityIndex],Balance) or nil
        card.quote=quote
        local cost=quote and (quote.count>0 and quote.cost or quote.nextCost)
        local affordable=quote and quote.count>0 and current.credits>=quote.cost and not current.blocked
        local enabled=affordable and not purchasePending and not prestigeTransition.active
        card.buy.Active,card.buy.Selectable=enabled and true or false,enabled and true or false
        card.buy.Text=not current and "Reconnect to buy" or cost and Theme.money(cost) or "MAX"
        card.price.Text=not current and "OFFLINE" or cost and Theme.money(cost) or "MAXED"
        card.frame:SetAttribute("BatchCount",quote and quote.count or 0)
        card.frame:SetAttribute("PurchasePending",purchasePending~=nil)
        paintShopCard(card,(not current or current.blocked) and "Unavailable" or not quote and "Maxed" or affordable and "Affordable" or "Unavailable")
    end
    local stage=current and Balance.progression(current)
    local progress=stage and (stage.stageName..(stage.nextStageAt and (" > "..Theme.money(stage.nextStageAt)) or " / COMPLETE")) or ""
    purchaseStatus.Text=purchasePending and (purchasePending.age>=12 and "OPEN GUIDE" or purchasePending.syncs>0 and "CHECKING..." or "BUYING...") or progress
    stripValues()
end
local function tickShopPurchase(dt)
    if not purchasePending then return end
    local pending=purchasePending;pending.age=pending.age+math.max(0,dt)
    if pending.syncs<3 and pending.age>=3*(pending.syncs+1) then
        pending.syncs=pending.syncs+1
        command:FireServer("upgrade_sync",{requestId=pending.requestId})
    end
    if purchasePending then
        purchaseStatus.Text=pending.age>=12 and "OPEN GUIDE" or pending.syncs>0 and "CHECKING..." or "BUYING..."
    end
end
local nextGoal=text(shop,"Agents write tokens. Use Enter or SELL to earn money.",13,c.muted,UDim2.fromOffset(0,0),UDim2.new(1,0,0,60))
nextGoal.LayoutOrder=8
layoutShop=function()
    if prestigeTransition.destroyed or (prestigeTransition.active and not prestigeTransition.covered) then return end
    if layingShop then return end
    local stamp=string.format("%g:%g:%s",store.AbsoluteSize.X,store.AbsoluteSize.Y,
        tostring(current==nil or current.blocked==true))
    if stamp==shopLayoutStamp then return end
    shopLayoutStamp=stamp
    layingShop=true
    local narrow=store.AbsoluteSize.X<200
    storeTitle.Position,storeTitle.Size=UDim2.fromOffset(8,4),UDim2.new(1,-88,0,32)
    storeTitle.TextSize=narrow and 18 or 22
    storeCaption.Visible=current==nil or current.blocked==true
    local top=64
    storeCaption.Position,storeCaption.Size=UDim2.fromOffset(8,top),UDim2.new(1,-16,0,96)
    if storeCaption.Visible then top=top+104 end
    shop.Position,shop.Size=UDim2.fromOffset(8,top),UDim2.new(1,-16,1,-top-8)
    local gap=12
    local available=math.max(1,shop.AbsoluteSize.X-8)
    local cardHeight=narrow and 184 or store.AbsoluteSize.X<240 and 168 or 152
    for _,card in pairs(cards) do
        local index=card.order-1
        card.frame.Position,card.frame.Size=UDim2.fromOffset(0,12+index*(cardHeight+gap)),UDim2.fromOffset(available,cardHeight)
        card.title.Position,card.title.Size=UDim2.fromOffset(12,10),UDim2.new(1,-24,0,narrow and 40 or 28)
        card.title.TextSize=narrow and 14 or 16
        card.price.Position=UDim2.fromOffset(12,narrow and 52 or 40)
        card.price.Size=UDim2.new(1,-24,0,26)
        card.price.TextSize=narrow and 14 or 16
        card.status.Position=UDim2.fromOffset(12,narrow and 86 or 76)
        card.status.Size=UDim2.new(1,-24,0,narrow and 78 or store.AbsoluteSize.X<240 and 76 or 64)
        card.status.TextSize=narrow and 14 or store.AbsoluteSize.X<240 and 16 or 18
        card.buy.Position,card.buy.Size=UDim2.fromOffset(0,0),UDim2.fromScale(1,1)
    end
    local bottom=24+upgradeCount*cardHeight+(upgradeCount-1)*gap
    stripValues()
    nextGoal.Visible=false
    shop.CanvasSize=UDim2.fromOffset(0,bottom)
    layingShop=false
end
local guide=create("Frame",content,{Name="GuidePage",BackgroundColor3=c.panel,BorderSizePixel=0,
    Active=true,Visible=false,Size=UDim2.fromScale(1,1)})
Theme.window(guide)
text(guide,"GUIDE",20,c.text,UDim2.fromOffset(16,8),UDim2.new(1,-32,0,44))
local help=create("ScrollingFrame",guide,{Name="Instructions",BackgroundTransparency=1,BorderSizePixel=0,
    Position=UDim2.fromOffset(16,60),Size=UDim2.new(1,-32,1,-120),CanvasSize=UDim2.fromOffset(0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=5,ScrollBarImageColor3=c.shadow})
create("UIListLayout",help,{Padding=UDim.new(0,14),SortOrder=Enum.SortOrder.LayoutOrder})
local instructions=text(help,"01  SKILL CHECK\nClick the fixed circle at the bottom or any empty background area. Main CLI, buttons, the dock and counters keep their own input. Its red dot rotates clockwise. Green gives GOOD and the smaller gold zone gives GREAT. Both build streak; a normal click resets it. The server confirms each result. Skill checks do not write tokens, reserve word rewards or directly pay money. They work with empty, partial or full context.\n\n02  STREAK\nConsecutive GOOD/GREAT checks build streak. The red dot gets faster and both zones shrink within difficulty limits. Streak raises future agent output using base * (floor(streak / C) + 1), capped by each agent's typing speed. Base starts at 1 and C at 5; existing profile bonuses remain. Rock intensifies at C, 2C, 3C and 4C. Old tokens keep their original rewards. Only skill checks refresh the streak timer; expiry or a normal check resets streak. Random visitors are independent of skill checks and survive streak loss.\n\n03  ENTER OR SELL\nAgents write the tokens. Enter or SELL queues one sale while a check, agent grant or letter reveal finishes, then submits once. Repeated presses do not add more sales. Backspace or leaving the CLI cancels a waiting sale. Confirmed tokens are collected one by one with a coin sound and their money value rising above them. Agents wait until the last sold token disappears; repeated SELL presses during collection never queue another sale. Rare tokens play brighter coin harmonies. Full context waits for your sale until Auto sell is unlocked. Auto sell queues once after a new agent grant fills the context, including on feature pages. It never sells a loaded full snapshot or retries a paid request. Pages, chat, menus and app blur pause skill input. Skill presses wait for pending checks, agent grants and sales; busy presses are not stored or replayed.\n\n04  AGENT TYPING\nAgents add tokens at their current output rate, capped independently by typing speed. Owned agents appear together in Main CLI and keep their own clocks, including while shopping. Each new profile starts with a 4 words/s cap per agent; earlier speed bonuses remain. Skill checks never reset those timers. Fast output shows complete words immediately. Each automatic token locks rarity * (1 + streak * 0.1) and its agent card's value buff when generated. Later checks cannot change that token's reward. Menus, chat and app blur pause automation.\n\n05  MONEY AND SHOP\nYour confirmed balance stays in the top-left corner. Only submitted prompts pay money. Store has three global upgrades: Token value has no gameplay level cap: +35% base per level and a stacking x10 value milestone every 10 levels; Agent count adds an automatic writer and an avatar in Main CLI (up to 8); Context adds 8 tokens per prompt (up to 64). Use the shop quantity button to cycle 1X, 5X, 10X, 25X and MAX. Fixed batches require their full price and stop at the upgrade cap. MAX buys as many levels as your money allows. Token value starts at $10 and prices grow x1.4 per level; new agents start at $2,000 and grow x6; context starts at $100 and grows x4. Milestones create large jumps in earnings while later purchases cost more. Confirmed lifetime earnings unlock BOOT through ORBIT stages; each stage adds +5% cash. Stage progress survives prestige. Prices and limits are confirmed by the server. Open Guide and use Reconnect to check a delayed purchase without repeating it.\n\n06  PRESTIGE AND CHIPS\nOpen the ascending-chip icon to preview prestige. Lifetime money earned from confirmed sales determines total Chips: floor(cube root(lifetime earnings / 1000)). The first thresholds are $1K, $8K and $27K. You receive only new Chips; spent Chips never become claimable again. Review and confirm the reset: money, normal upgrades, agents, streak and unsold words reset. Chips, tree unlocks, fragments and your card collection stay. Only the first deck position stays equipped; the other cards return to inventory. Each earned Chip permanently adds +5% cash, including spent Chips. Chip memory skills increase this percentage. Spend Chips on connected permanent skills: cash multipliers, agent speed, Auto sell, fragment collection bonuses and automatic checks. Auto checks add one streak every 2 seconds, up to 5; later nodes raise the global streak cap from 5 to 10, 15, 20, 25, 30, 35, 40, 50, 60, 70, 80 and 100. Manual checks respect the same cap. They never write tokens, roll collectible agents or claim a human timing grade. The current maximum is shown below the skill circle. Auto pauses for chat, menus and app blur. The radial tree has 54 skills across cash, speed, luck, Chip memory, collection and streak branches. Drag to explore and use CORE to return to the center. All parent skills must be unlocked. Purchases and prestige are confirmed by the server; delayed replies are checked without retrying paid actions.\n\n07  AGENT CARDS\nOpen Cards. The eight deck positions unlock from left to right as Agent count grows. Select a card in the inventory below, then an empty unlocked deck position to equip it. Select an equipped position and REMOVE to return the card. New profiles start with Common Ember; existing collections are preserved as Common cards. Each version has one unique copy; the same card cannot occupy two positions. VALUE modifies that agent's future automatic token rewards; SPD changes its output cadence and typing cap, bounded at 55 words/s. Negative values are tradeoffs. Old words keep their fixed bonuses and manual skill clicks stay unchanged. The equipped card also supplies that agent's avatar in Main CLI. Use Cards to equip your crafted skins. Laboratory offers nine families, each with Common, Rare, Epic and Legendary recipes. Rare versions increase value and speed while retaining the family tradeoffs. Select a family to see its fragment balance and all three costs. Crafting consumes family fragments, money and Chips together, with no random outcome or automatic equip. Fragment balances and crafted cards survive prestige. Equipping is free and confirmed by the server. Delayed changes are checked without automatically repeating them.\n\nAgent output is simulated. Progress lasts for this MEMORY session only.",
    14,c.text,UDim2.fromOffset(0,0),UDim2.new(1,-12,0,20))
instructions.AutomaticSize,instructions.LayoutOrder=Enum.AutomaticSize.Y,1
instructions.Text=instructions.Text:gsub("Progress lasts for this MEMORY session only%.","Cloud progress saves in published games. Local tests are session-only; unsold tokens and streak are never restored.")
local tutorialSettings=create("Frame",help,{Name="TutorialSettings",BackgroundTransparency=1,Size=UDim2.new(1,-12,0,48),LayoutOrder=-2})
local replayTutorial=Theme.pixelButton(tutorialSettings,"REPLAY TUTORIAL",UDim2.fromOffset(4,4),UDim2.new(1,-8,0,40),function(input)
    if onboarding:blocks() or prestigeTransition.active or page~="Guide" or not terminal:canAutomate() or desk.drag then return end
    if input and (not containsPointer(help,input) or not containsPointer(tutorialSettings,input)) then return end
    audio:click("navigate");onboarding:start(true)
end)
replayTutorial.Name="ReplayTutorial"
local saveNote=text(help,"",14,c.mint,UDim2.fromOffset(0,0),UDim2.new(1,-12,0,96))
saveNote.Name="SaveStatus";saveNote.LayoutOrder=29
local streakTimeout=text(help,"STREAK TIMEOUT / Click the circle or empty background at least once every 5 seconds. Skill checks refresh the timer; visitors, sending, typing and menu activity do not. Inactivity resets streak, preserving visitors, your best and old word rewards.",13,c.amber,UDim2.fromOffset(0,0),UDim2.new(1,-12,0,20),Theme.mono)
streakTimeout.AutomaticSize,streakTimeout.LayoutOrder=Enum.AutomaticSize.Y,0
local spawnChance=text(help,"RANDOM VISITORS / Appear every 5-10 seconds of active Main CLI play, independently of skill checks. Click within 24 seconds for family fragments. Common 75% (+1), Rare 20% (+2), Epic 4.5% (+4), Legendary 0.5% (+8), before collection skills. Nine families have equal odds. No money, Chips or streak are granted. Pages/chat/menu/blur pause new arrivals; no offline catch-up.",13,c.mint,UDim2.fromOffset(0,0),UDim2.new(1,-12,0,20),Theme.mono)
spawnChance.AutomaticSize,spawnChance.LayoutOrder=Enum.AutomaticSize.Y,-1
local rarityRows={}
local rarityNote=text(help,"LUCKY TOKENS / Permanent skills raise special-token chances for new drafts and added context slots. Current offers keep their original rarity. Eight levels raise total special odds up to x10, not multiplied together. Token multipliers and collectible-agent odds stay the same.",13,c.amber,UDim2.fromOffset(0,0),UDim2.new(1,-12,0,20),Theme.mono)
rarityNote.Name="RarityNote";rarityNote.AutomaticSize,rarityNote.LayoutOrder=Enum.AutomaticSize.Y,2
for index,tier in ipairs(Balance.SPECIAL_TOKENS) do
    local chance=tier.denominator and ("1/"..tier.denominator) or string.format("%g%%",tier.weight/100)
    local row=text(help,string.format("%s / %s per token / x%g",tier.rarity,chance,tier.multiplier),13,
        Theme.rarity[tier.rarity],UDim2.fromOffset(0,0),UDim2.new(1,-12,0,20),Theme.mono)
    row.Name="TokenChance"..tier.rarity
    row.AutomaticSize,row.LayoutOrder=Enum.AutomaticSize.Y,index+2
    rarityRows[index]=row
end
local audioSettings=create("Frame",help,{Name="AudioSettings",BackgroundTransparency=1,
    Size=UDim2.new(1,-12,0,176),LayoutOrder=30})
text(audioSettings,"AUDIO / lounge + rock I-IV",12,c.mint,UDim2.fromOffset(0,0),UDim2.new(1,0,0,32))
local connectionSettings=create("Frame",help,{Name="ConnectionSettings",BackgroundTransparency=1,
    Size=UDim2.new(1,-12,0,48),LayoutOrder=31})
local reconnectButton,reconnectArt=Theme.pixelButton(connectionSettings,"Reconnect",UDim2.fromOffset(4,4),UDim2.new(1,-8,0,40),function(input)
    if prestigeTransition.active then return end
    if page~="Guide" or not guide.Visible or not terminal.windowFocused or GuiService.MenuIsOpen or desk.drag then return end
    local pointer=input and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch)
    if pointer and (not containsPointer(help,input) or not containsPointer(connectionSettings,input)) then return end
    if reconnect then audio:click("navigate");reconnect() end
end)
reconnectButton.Name="Reconnect";reconnectButton.Active=true;reconnectButton.Selectable=true;reconnectArt.label.TextSize=13
local levels={0,0.25,0.5,0.75,1}
for index,channel in ipairs({"music","effects"}) do
    local selected,control=3,nil
    local function caption() return (channel=="music" and "Music" or "Effects").." / "..math.floor(levels[selected]*100).."%" end
    control=button(audioSettings,caption(),UDim2.fromOffset(0,32+(index-1)*48),UDim2.new(1,0,0,40),function()
        if prestigeTransition.active then return end
        selected=selected%#levels+1;audio:setVolume(channel,levels[selected]);audio:click("select");control.Text=caption()
    end)
    control.Name=channel=="music" and "MusicVolume" or "EffectsVolume"
end
local muteButton
muteButton=button(audioSettings,"Sound / ON",UDim2.fromOffset(0,128),UDim2.new(1,0,0,40),function()
    if prestigeTransition.active then return end
    audio:setMuted(not audio.muted);audio:click("select");muteButton.Text=audio.muted and "Sound / MUTED" or "Sound / ON"
end)
muteButton.Name="MuteAudio"
local reduced=GuiService.ReducedMotionEnabled
local motionButton
local function applyMotion()
    motionButton.Text=reduced and "[x] Reduced motion" or "[ ] Reduced motion"
    terminal:setReducedMotion(reduced)
    uiMotion:setReduced(reduced)
    prestigeTransition:setReduced(reduced)
    if reduced then finishPageEntrance() end
    tickShopPress(0)
    desk:setReducedMotion(reduced)
    dancers:setReducedMotion(reduced)
    skillCheck:setReducedMotion(reduced)
    floatingWords:setReducedMotion(reduced)
end
motionButton=button(guide,"",UDim2.new(0,16,1,-52),UDim2.new(1,-32,0,40),function()
    if prestigeTransition.active then return end
    reduced=not reduced;applyMotion();audio:click("select")
end)
applyMotion()
connect(GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"),function()
    reduced=GuiService.ReducedMotionEnabled;applyMotion()
end)
local footer=create("Frame",root,{Name="DesktopDock",BackgroundColor3=c.panel,BorderSizePixel=0,
    Position=UDim2.new(0,0,1,-44),Size=UDim2.new(1,0,0,44),ZIndex=8})
local storage=text(footer,"CONNECTING",12,c.dim,UDim2.fromOffset(516,0),UDim2.new(1,-528,1,0))
storage.TextXAlignment=Enum.TextXAlignment.Right
local mainButton,toolsButton,guideButton
local returnButton
local function focus(item)
    if uiMotion:busy() then uiMotion.nextFocus=item;return end
    if UserInputService.GamepadEnabled or GuiService.SelectedObject then GuiService.SelectedObject=item end
end
setPage=function(nextPage,animate,internal)
    if onboarding:blocks() and not internal then return end
    if uiMotion:busy() and not internal then return end
    if prestigeTransition.active and not internal then return end
    if nextPage=="Tools" and not RunService:IsStudio() then return end
    if not internal and nextPage~=page and animate~=false then
        return uiMotion:begin(function() setPage(nextPage,false,true) end)
    end
    local previous=page
    finishPageEntrance()
    page=nextPage
    tickShopPress(0)
    for _,entry in ipairs(iconHovers) do entry.pointer=nil;StoreIcon.setHovered(entry.icon,false) end
    if page~="CLI" then floatingWords:clear() end
    local main=page=="CLI"
    desktop.Visible,store.Visible,guide.Visible=main,main,page=="Guide"
    featureDock.Visible,moneyHUD.Visible,footer.Visible=main,main,main
    dancers.layer.Visible=main
    content.BackgroundTransparency=main and 1 or 0
    content.BackgroundColor3=Theme.pixelColors.base
    if returnButton then returnButton.Visible=not main end
    if studioPage then studioPage.Visible=page=="Tools" end
    agentLab.frame.Visible=page=="Lab";agentLab:update(current,progression.pending~=nil,progression.message.Text)
    cardPage:setOpen(page=="Cards")
    robuxShop:setOpen(page=="Robux")
    progression.frame.Visible=page=="Prestige" or page=="Tree"
    if progression.frame.Visible then progression:setMode(page) end
    terminal:setSuspended(page~="CLI");desk:setSuspended(page~="CLI")
    skillCheck:setSuspended(page~="CLI")
    if layout then layout() end
    for _,control in ipairs({mainButton,toolsButton,guideButton}) do
        local selected=(control==mainButton and page=="CLI") or (control==guideButton and page=="Guide")
            or (control==toolsButton and page=="Tools")
        control.TextColor3=control==mainButton and c.terminal or (selected and c.accent or c.text)
        control.PanelBorder.Color=c.black
    end
    local target=page=="Guide" and motionButton or page=="Lab" and agentLab.cards[1].frame or terminal.input
    if page=="Tools" then target=studioTools and (studioTools:GetAttribute("Expanded") and studioTools.grant or studioTools.Disclosure) or toolsButton
    elseif page=="Cards" then
        target=returnButton or mainButton
        for _,card in ipairs(Balance.AGENT_CARDS) do if cardPage.inventory[card.id].frame.Selectable then target=cardPage.inventory[card.id].frame;break end end
    elseif page=="Robux" then target=robuxShop.entries.forever.buy.Selectable and robuxShop.entries.forever.buy or robuxShop.check
    elseif page=="Prestige" then target=progression.ascend.Selectable and progression.ascend or returnButton
    elseif page=="Tree" then
        target=returnButton or mainButton
        for _,node in ipairs(Balance.PRESTIGE_NODES) do
            if progression.nodes[node.id].buy.Selectable then target=progression.nodes[node.id].buy;break end
        end
    end
    focus(target)
end
uiMotion.onSettled=function()
    terminal:refreshControls()
    if page=="CLI" and not onboarding:blocks() and not terminal.blocked then terminal:focusInput() end
end
mainButton=button(footer,"Main CLI",UDim2.fromOffset(4,2),UDim2.fromOffset(128,40),function()
    if prestigeTransition.active then return end
    if not footer.Visible then return end
    audio:click("back")
    setPage("CLI");desk:focus(1);terminal:focusInput()
end)
mainButton.Name="MainCLIShortcut"
mainButton.BackgroundColor3=c.mint
mainButton.TextColor3=c.terminal
toolsButton=button(footer,"Studio tools",UDim2.fromOffset(140,2),UDim2.fromOffset(156,40),function(input)
    if not footer.Visible or not RunService:IsStudio() or not terminal:canAutomate() or desk.drag then return end
    if input and not containsPointer(footer,input) then return end
    audio:click("navigate")
    setPage(page=="Tools" and "CLI" or "Tools")
end)
toolsButton.Name="StudioToolsShortcut"
toolsButton.Visible=RunService:IsStudio()
toolsButton.Active,toolsButton.Selectable=RunService:IsStudio(),RunService:IsStudio()
guideButton=button(footer,"Guide",UDim2.fromOffset(190,2),UDim2.fromOffset(70,40),function()
    if prestigeTransition.active then return end
    if footer.Visible then audio:click("navigate");setPage("Guide") end
end)
returnButton=Theme.pixelButton(root,"< MAIN CLI",UDim2.fromOffset(12,8),UDim2.fromOffset(160,40),function(input)
    if prestigeTransition.active then return end
    if not returnButton.Visible or GuiService.MenuIsOpen or not terminal.windowFocused or desk.drag then return end
    if input and not containsPointer(returnButton,input) then return end
    audio:click("back")
    setPage("CLI");desk:focus(1);terminal:focusInput()
end)
returnButton.Name="ReturnCLI";returnButton.ZIndex=16;returnButton.Visible=false
setPage("CLI",false,true)
prestigeTransition.onCovered=function()
    progression.presentationPaused=false
    cardPage.presentationPaused=false
    setPage("CLI",false,true)
    desk:focus(1)
end
prestigeTransition.onStarted=function(id,reduced) audio:startVortex(id,reduced) end
prestigeTransition.onStopped=function() audio:stopVortex() end
prestigeTransition.onFinished=function()
    audio:stopVortex()
    progression.presentationPaused=false
    cardPage.presentationPaused=false
    terminal.presentationPaused=false
    desk:setSuspended(page~="CLI");skillCheck:setSuspended(page~="CLI")
    if layout then layout() end
    terminal:refreshInput();terminal:refreshControls()
    refreshShopQuotes()
    if not terminal.blocked then terminal:focusInput() end
    focus(terminal.input)
end
progression.onConfirmed=function(reply,data,pending)
    if reply.action~="prestige" or data.prestigeCount~=pending.beforeCount+1 or data.blocked then return end
    uiMotion:cancel()
    finishPageEntrance();backgroundPointer=nil;terminal.presentationPaused=true;terminal:blur()
    progression.presentationPaused=true
    cardPage.presentationPaused=true
    GuiService.SelectedObject=nil;desk:setSuspended(true)
    if not prestigeTransition:start(pending.id,terminal.reduced) then
        terminal.presentationPaused=false;progression.presentationPaused=false;cardPage.presentationPaused=false;desk:setSuspended(page~="CLI")
    end
end
local function disconnected(message)
    uiMotion:cancel()
    connectionError=message;current=nil;terminal.blocked=true;terminal:blur()
    onboarding.error=message;onboarding:update(nil)
    prestigeTransition:finish()
    terminal.hint.Text=message;storeCaption.Text=message
    reconnectButton.Visible=true;storage.Text="OFFLINE / UI v"..Balance.BUILD_VERSION
    for _,card in pairs(cards) do card.status.Text="" end
    refreshShopQuotes()
    layoutShop()
end
local function refresh(data)
    if type(data)~="table" then disconnected("Session data unavailable. Reconnect.");return end
    if data.buildVersion~=Balance.BUILD_VERSION or data.schemaVersion~=Balance.SCHEMA_VERSION then
        disconnected(RunService:IsStudio() and "Game updated. Stop and restart Play." or "Game updated. Rejoin to reconnect.")
        return
    end
    local profile,reason=State.fromSnapshot(data,Balance)
    if not profile then
        warn("[VibeIdle] Rejected incomplete snapshot: "..tostring(reason))
        disconnected("Session data unavailable. Reconnect.");return
    end
    if type(data.snapshotSequence)~="number" or data.snapshotSequence%1~=0 or data.snapshotSequence<1 or data.snapshotSequence>Balance.MAX_CREDITS then
        disconnected("Session data unavailable. Reconnect.");return
    end
    if data.snapshotSequence<=lastSnapshotSequence then return end
    lastSnapshotSequence=data.snapshotSequence
    current=data
    terminal.billingBusy=data.commerce and data.commerce.busy or false
    local tokenWeights=PromptSession.tokenWeights(profile,Balance)
    for index,tier in ipairs(Balance.SPECIAL_TOKENS) do
        rarityRows[index].Text=string.format("%s / %g%% per token / x%g",tier.rarity,tokenWeights[index]/100,tier.multiplier)
    end
    local sequence=data.upgradeSequence
    if type(sequence)=="number" and sequence%1==0 and sequence>=0 and sequence<=Balance.MAX_CREDITS then
        purchaseSequence=math.max(purchaseSequence,sequence)
    end
    if purchasePending then
        local reply=data.upgradeReply
        if (type(reply)=="table" and reply.requestId==purchasePending.requestId and reply.action==purchasePending.action
            and reply.quantity==purchasePending.quantity) or data.upgradeSyncId==purchasePending.requestId then purchasePending=nil end
    end
    moneyValue.Text=Theme.money(data.credits);moneyShadow.Text=moneyValue.Text;chipsValue.Text=Theme.number(data.chips).." Chips";fitMoney()
    if data.skillCheck then
        if skillTestControls["skill_initial"] then skillTestControls.skill_initial.Text=string.format("Initial spin / %.2f rev/s",data.skillCheck.initialRps) end
        if skillTestControls["skill_acceleration"] then skillTestControls.skill_acceleration.Text=string.format("Per hit / x%.3f",data.skillCheck.growth) end
    end
    if RunService:IsStudio() and data.studioTuning then
        for _,control in ipairs(Tuning.controls) do
            local item=skillTestControls[control.action]
            if item then item.Text=string.format("%s / %g %s +",control.label,data.studioTuning[control.key],control.unit) end
        end
        streakTimeout.Text=string.format("STREAK TIMEOUT / %g seconds (0 disables expiry). Only accepted skill checks refresh it. Sending and automatic typing do not.",data.studioTuning.streakTimeout)
        spawnChance.Text=string.format("RANDOM VISITORS / 5-10 active seconds; 24-second lifetime; maximum %g. Independent of skill checks. Legacy spawn-chance tool is retired.",data.studioTuning.spawnCapacity)
    end
    connectionError=nil
    refreshShopQuotes()
    desk:update(data)
    nextGoal.Text=data.message or "Global upgrades increase your next prompt payout."
    local saveStatus=data.persistence and data.persistence.status
    storage.Text=(data.storageMode=="MEMORY" and "SESSION ONLY" or saveStatus=="delayed" and "SAVE DELAYED" or "CLOUD ON").." / v"..data.buildVersion
    saveNote.Text=data.storageMode=="MEMORY" and "LOCAL TEST / Session-only progress. Published games use cloud saving."
        or saveStatus=="delayed" and "SAVE DELAYED / Keep this session open while cloud saving retries. If the data lease expires, progression pauses."
        or "CLOUD SAVE ON / Autosaves every 60 seconds and on exit. Money, upgrades, cards, fragments, Chips and tutorial preference persist. Unsold tokens and streak are session-only."
    terminal:update(data)
    skillCheck:update(data)
    progression:update(data,terminal.composer.draft and terminal.composer.draft.id)
    agentLab:update(data,progression.pending~=nil,progression.message.Text)
    cardPage:update(data,progression.pending~=nil)
    robuxShop:update(data,progression.pending~=nil)
    if page=="Cards" and UserInputService.GamepadEnabled then
        local selected=GuiService.SelectedObject
        if not selected or (selected:IsDescendantOf(cardPage.frame) and (not selected.Selectable or not selected.Visible)) then
            focus(cardPage.slots[1].frame.Selectable and cardPage.slots[1].frame or returnButton)
        end
    end
    if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(progression.frame)
        and not GuiService.SelectedObject.Selectable then focus(returnButton) end
    dancers:update(data)
    onboarding.error=nil;onboarding:update(data)
    reconnectButton.Visible=true
    storeCaption.Text=data.blocked and (data.message or "Session paused. Rejoin to reconnect.")
        or "Three upgrades: token value, agent count and context."
    layoutShop()
end
layout=function()
    if prestigeTransition.destroyed or (prestigeTransition.active and not prestigeTransition.covered) then return end
    finishPageEntrance()
    local spec=Agent.workstationLayout(root.AbsoluteSize.X,root.AbsoluteSize.Y,desk.count)
    local naturalWidth=#featureDefinitions*76-12
    local width=math.min(naturalWidth,math.max(1,spec.viewportWidth))
    moneyHUD.Size=UDim2.fromOffset(math.min(480,math.max(1,root.AbsoluteSize.X-24)),120);fitMoney()
    local separateRow=moneyHUD.AbsoluteSize.X+width+40>spec.viewportWidth
    local shortcutY=root.AbsoluteSize.Y<500 and 134 or 146
    featureDock.Position=UDim2.fromOffset(separateRow and math.max(0,math.floor((spec.viewportWidth-width)/2))
        or math.max(moneyHUD.AbsoluteSize.X+28,math.floor((spec.viewportWidth-width)/2)),separateRow and shortcutY or 8)
    featureDock.Size=UDim2.fromOffset(width,width<naturalWidth and 70 or 64)
    featureDock.CanvasSize=UDim2.fromOffset(naturalWidth,0)
    featureDock.ScrollingEnabled=width<naturalWidth;featureDock.ScrollBarThickness=width<naturalWidth and 5 or 0
    local previous=featureDock.CanvasPosition or Vector2.new(0,0)
    featureDock.CanvasPosition=Vector2.new(math.max(0,math.min(previous.X,naturalWidth-width)),0)
    for index,definition in ipairs(featureDefinitions) do
        featureButtons[definition[1]].button.Position=UDim2.fromOffset((index-1)*76,0)
    end
    skillRoot.Size=UDim2.fromOffset(spec.viewportWidth,root.AbsoluteSize.Y)
    local compactHeight=root.AbsoluteSize.Y<500
    local reserve=page=="CLI" and (compactHeight and 112 or 148) or 0
    terminal.bottomClearance=reserve+44
    skillCheck:layout(reserve,math.min(compactHeight and 84 or 120,math.max(1,math.floor((spec.viewportWidth-32)/3))))
    content.Position,content.Size=UDim2.fromOffset(0,0),UDim2.fromOffset(root.AbsoluteSize.X,root.AbsoluteSize.Y)
    spec.headerHeight=math.max(moneyHUD.Position.Y.Offset+moneyHUD.Size.Y.Offset,
        featureDock.Position.Y.Offset+featureDock.Size.Y.Offset)+8
    local geometry=spec.windows[1]
    geometry.height=math.max(compactHeight and 220 or 300,math.min(720,root.AbsoluteSize.Y-spec.headerHeight-(compactHeight and 112 or 148)-52))
    geometry.x,geometry.y=math.floor((spec.width-geometry.width)/2),spec.headerHeight
    desk:layout(spec)
    local fullWidth=root.AbsoluteSize.X
    agentLab.frame.Position,agentLab.frame.Size=UDim2.fromOffset(8,52),UDim2.new(1,-16,1,-60)
    agentLab:layout()
    cardPage:layout(fullWidth,root.AbsoluteSize.Y,52)
    robuxShop:layout(fullWidth,root.AbsoluteSize.Y,52)
    progression:layout(fullWidth,root.AbsoluteSize.Y,52)
    guide.Position,guide.Size=UDim2.fromOffset(8,52),UDim2.new(1,-16,1,-60)
    if studioPage then
        studioPage.Position=UDim2.fromOffset(8,52)
        studioPage.Size=UDim2.fromOffset(fullWidth-16,math.max(1,root.AbsoluteSize.Y-60))
        if studioRelayout then studioRelayout() end
    end
    local shopHeight=math.min(spec.store.height,64+24+3*(spec.store.width<200 and 184 or spec.store.width<240 and 168 or 152)+24+8)
    local shopTop=math.max(8,math.floor((root.AbsoluteSize.Y-44-shopHeight)/2))
    if spec.store.x<moneyHUD.Position.X.Offset+moneyHUD.AbsoluteSize.X+8 then
        shopTop=math.max(shopTop,moneyHUD.Position.Y.Offset+moneyHUD.AbsoluteSize.Y+8)
    end
    shopHeight=math.min(shopHeight,math.max(1,root.AbsoluteSize.Y-44-shopTop-8))
    store.Position,store.Size=UDim2.fromOffset(spec.store.x,shopTop),UDim2.fromOffset(spec.store.width,shopHeight)
    layoutShop()
    local compact=root.AbsoluteSize.X<680
    storage.Visible=not compact
    local offset=0
    local fractions=RunService:IsStudio() and {0.30,0.47,0.23} or {0.5,0,0.5}
    local desktopX=4
    for index,control in ipairs({mainButton,toolsButton,guideButton}) do
        if control.Visible then
            local controlWidth=({128,156,70})[index]
            control.Position=compact and UDim2.new(offset,4,0,2) or UDim2.fromOffset(desktopX,2)
            control.Size=compact and UDim2.new(fractions[index],-8,0,40) or UDim2.fromOffset(controlWidth,40)
            control.TextSize=control==toolsButton and 11 or (compact and 11 or control==mainButton and 12 or 14)
            offset=offset+fractions[index];desktopX=desktopX+controlWidth+8
        end
    end
end
connect(shop:GetPropertyChangedSignal("AbsoluteSize"),layoutShop)
connect(root:GetPropertyChangedSignal("AbsoluteSize"),layout)
connect(UserInputService.LastInputTypeChanged,function(inputType)
    if inputType==Enum.UserInputType.Gamepad1 and not GuiService.SelectedObject then setPage(page) end
end)
layout()
if RunService:IsStudio() then
    studioPage=create("Frame",content,{Name="StudioToolsPage",BackgroundColor3=c.panel,BorderSizePixel=0,Visible=false})
    Theme.outline(studioPage).Color=c.line
    text(studioPage,"STUDIO TOOLS",16,c.accent,UDim2.fromOffset(12,4),UDim2.new(1,-24,0,44))
    studioScroll=create("ScrollingFrame",studioPage,{Name="ToolList",BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.fromOffset(12,52),Size=UDim2.new(1,-24,1,-64),CanvasSize=UDim2.fromOffset(0,0),
        ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarThickness=5,ScrollBarImageColor3=c.line})
    local tools=create("Frame",studioScroll,{Name="StudioTools",BackgroundTransparency=1,Size=UDim2.new(1,-8,0,44)})
    studioTools=tools
    local expanded,controls,disclosure=true,{},nil
    local toolRows={}
    local function canUseTools(input)
        return page=="Tools" and studioPage.Visible and terminal:canAutomate() and not desk.drag
            and (not input or containsPointer(studioScroll,input))
    end
    disclosure=button(tools,"- Studio tools",UDim2.fromOffset(0,0),UDim2.new(1,0,0,44),function(input)
        if not canUseTools(input) then return end
        audio:click("select")
        expanded=not expanded
        tools:SetAttribute("Expanded",expanded)
        studioRelayout()
        disclosure.Text=expanded and "- Studio tools" or "+ Studio tools"
        for _,control in ipairs(controls) do control.Visible=expanded end
        if not expanded then focus(disclosure) end
    end)
    disclosure.Name="Disclosure"
    local devRemote=remotes:FindFirstChild("StudioCommand")
    local specs={{"grant","+$1 billion"},{"reset","Reset session"},{"tuning_reset","Restore tuning defaults"}}
    for _,control in ipairs(Tuning.controls) do specs[#specs+1]={control.action,string.format("%s / %g %s +",control.label,control.values[1],control.unit),control} end
    for index,spec in ipairs(specs) do
        local action=spec[1]
        local item=button(tools,spec[2],UDim2.fromOffset(0,index*48),UDim2.new(1,spec[3] and -48 or 0,0,44),function(input)
            if not expanded or not canUseTools(input) then return end
            devRemote=devRemote or remotes:FindFirstChild("StudioCommand")
            if devRemote then audio:click("select");devRemote:FireServer(action) end
        end)
        item.Name=action;item.TextSize=11;item.TextWrapped=true;item.Visible=true
        toolRows[index]={item=item}
        controls[#controls+1]=item;skillTestControls[action]=item
        if spec[3] then
            local previous=button(tools,"-",UDim2.new(1,-44,0,index*48),UDim2.fromOffset(44,44),function(input)
                if not expanded or not canUseTools(input) then return end
                devRemote=devRemote or remotes:FindFirstChild("StudioCommand")
                if devRemote then audio:click("select");devRemote:FireServer(action,-1) end
            end)
            previous.Name=action.."_Previous";previous.Visible=true;controls[#controls+1]=previous
            toolRows[index].previous=previous
        end
    end
    studioRelayout=function()
        local rowHeight=studioScroll.AbsoluteSize.X<280 and 120 or 72
        tools.Size=UDim2.new(1,-8,0,expanded and (44+#toolRows*rowHeight) or 44)
        for index,row in ipairs(toolRows) do
            local y=44+(index-1)*rowHeight
            row.item.Position=UDim2.fromOffset(0,y)
            row.item.Size=UDim2.new(1,row.previous and -48 or 0,0,rowHeight-4)
            if row.previous then row.previous.Position=UDim2.new(1,-44,0,y+math.floor((rowHeight-44)/2)) end
        end
        studioScroll.CanvasSize=UDim2.fromOffset(0,tools.Size.Y.Offset+12)
    end
    tools:SetAttribute("Expanded",true)
    layout()
end
connect(stateUpdate.OnClientEvent,function(data)
    local ok,reason=pcall(refresh,data)
    if not ok then
        warn("[VibeIdle] Snapshot could not be rendered: "..tostring(reason))
        disconnected("Could not open session. Reconnect.")
    end
end)
for _,label in ipairs({terminal.hint,terminal.stateLabel,agentLab.message,agentLab.familyTitle,agentLab.familyTitleShadow,
    cardPage.message,cardPage.deckTitle,cardPage.deckTitleShadow,cardPage.inventoryTitle,cardPage.inventoryTitleShadow,
    progression.message,robuxShop.message,onboarding.title,onboarding.copy,onboarding.status}) do uiMotion:watchText(label) end
for _,entry in ipairs(agentLab.recipes) do uiMotion:watchText(entry.status);uiMotion:watchText(entry.statusShadow) end
for _,entry in pairs(robuxShop.entries) do uiMotion:watchText(entry.status);uiMotion:watchText(entry.price) end
for _,control in ipairs({terminal.send,mainButton,toolsButton,guideButton,returnButton,quantity,reconnectButton,replayTutorial,
    motionButton,muteButton,agentLab.openCards,cardPage.remove,progression.ascend,progression.centerButton,robuxShop.check,
    onboarding.play,onboarding.learn,onboarding.skip}) do uiMotion:watchButton(control) end
for _,definition in ipairs(featureDefinitions) do uiMotion:watchButton(featureButtons[definition[1]].button) end
for _,entry in ipairs(agentLab.recipes) do uiMotion:watchButton(entry.buy) end
for _,entry in pairs(robuxShop.entries) do uiMotion:watchButton(entry.buy) end
for _,entry in ipairs(agentLab.cards) do uiMotion:watchButton(entry.frame) end
for _,entry in ipairs(cardPage.slots) do uiMotion:watchButton(entry.frame) end
-- Retry only the initial handshake, never a possibly paid prompt.
reconnect=function()
    handshakeTime,attempt,connectionError=0,1,nil
    storeCaption.Text="Opening session..."
    command:FireServer("sync")
    progression:sync()
    if purchasePending then command:FireServer("upgrade_sync",{requestId=purchasePending.requestId}) end
end
reconnect()
terminal.onTick=function(dt)
    if current and terminal.composer.draft and os.clock()-analyticsAt>=15 then
        analyticsAt=os.clock();analyticsSequence=analyticsSequence+1
        command:FireServer("analytics_pulse",{requestId=analyticsSequence,button=analyticsButton,enter=analyticsEnter,
            focused=terminal:canAutomate(),page=onboarding:blocks() and (onboarding.mode=="Start" and "Start" or "Tutorial") or page})
    end
    local focused=UserInputService:GetFocusedTextBox()
    local presenting=prestigeTransition.active
    local presentationPaused=not terminal.windowFocused or GuiService.MenuIsOpen
        or (focused and focused~=terminal.input) or terminal:hasModifier()
    uiMotion:tick(dt,presentationPaused or presenting)
    onboarding:tick(dt)
    prestigeTransition:tick(dt,presentationPaused)
    audio:vortexFrame(prestigeTransition.age or 0,prestigeTransition.reduced,prestigeTransition.active,presentationPaused)
    if presenting then
        audio:tick(dt,current and current.stats and current.stats.streak or 0,current and current.streakDivisor or Balance.STREAK_BASE_DIVISOR)
        return
    end
    tickShopPurchase(dt)
    tickShopPress(dt)
    for _,entry in ipairs(iconHovers) do refreshIconHover(entry) end
    skillCheck:tick(dt)
    progression:tick(dt)
    cardPage:setPending(progression.pending~=nil,progression.message.Text)
    robuxShop.progressionPending=progression.pending~=nil;robuxShop:tick(dt)
    agentLab:setPending(progression.pending~=nil,progression.message.Text)
    desk:tickMascots(dt*(terminal.tuning and terminal.tuning.danceScale or 1),terminal:canEdit())
    dancers:tick(dt)
    floatingWords:tick(dt)
    audio:tick(dt,current and current.stats and current.stats.streak or 0,current and current.streakDivisor or Balance.STREAK_BASE_DIVISOR)
    if current and terminal.composer.draft then return end
    handshakeTime=handshakeTime+dt
    if attempt<#retryAt and handshakeTime>=retryAt[attempt+1] then
        attempt=attempt+1;command:FireServer("sync")
    end
    if handshakeTime>=14 then
        terminal.hint.Text=connectionError or "Prompt session unavailable. Open Guide to reconnect."
        if not current then
            storeCaption.Text=connectionError or "Server unavailable. Open Guide to reconnect."
            storage.Text="OFFLINE"
            reconnectButton.Visible=true
            for _,card in pairs(cards) do card.buy.Text="Reconnect to buy" end
        end
    end
end
gui.Destroying:Connect(function()
    uiMotion:destroy()
    onboarding:destroy();terminal.onSaleConfirmed=nil
    prestigeTransition:destroy();terminal.presentationPaused=false
    progression.presentationPaused=false
    finishPageEntrance()
    if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(gui) then GuiService.SelectedObject=nil end
    robuxShop:destroy();cardPage:destroy();progression:destroy();agentLab:destroy();floatingWords:destroy();dancers:destroy();audio:destroy();skillCheck:destroy();desk:destroy();terminal:destroy()
    for _,connection in ipairs(connections) do connection:Disconnect() end
    skillGui:Destroy();streakGui:Destroy();backdrop:Destroy()
end)

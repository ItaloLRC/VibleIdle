--!nonstrict
-- Shared native collection artwork; passive builders own no input or tick.
local Theme=require(script.Parent.DeskTheme)
local Mascot=require(script.Parent.AgentMascot)
local Cards=require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").AgentCards)
local c=Theme.colors
local CARD_W,CARD_H=192,304
local auraColors={
    ember={{237,164,94},{84,42,51},{255,212,144}},sprout={{146,214,153},{34,69,54},{211,241,162}},
    volt={{128,208,228},{39,57,90},{185,246,227}},frost={{171,207,248},{42,47,88},{220,238,255}},
    nebula={{183,141,239},{60,36,94},{221,198,255}},forge={{231,184,108},{80,47,42},{255,223,143}},
    glitch={{219,144,212},{67,35,83},{151,243,208}},coral={{237,154,145},{77,39,59},{255,218,181}},
    sage={{170,193,179},{43,54,77},{231,233,173}},
}
local function rect(parent,name,x,y,w,h,color,z)
    return Theme.create("Frame",parent,{Name=name,BorderSizePixel=0,Active=false,Selectable=false,
        Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),BackgroundColor3=color,ZIndex=z or 1})
end
local function panel(parent,name,position,size)
    local root=Theme.create("Frame",parent,{Name=name,BackgroundTransparency=1,BorderSizePixel=0,
        Active=false,Selectable=false,Position=position,Size=size})
    Theme.create("Frame",root,{Name="PanelShadow",BorderSizePixel=0,Active=false,Selectable=false,
        BackgroundColor3=Color3.fromRGB(12,9,17),Position=UDim2.fromOffset(4,6),Size=UDim2.new(1,0,1,-2)})
    local face,edges=Theme.pixelPanel(root,"PanelFace",UDim2.fromOffset(0,0),UDim2.fromScale(1,1),Color3.fromRGB(42,31,56))
    for _,edge in ipairs(edges) do edge.BackgroundColor3=c.black end
    rect(face,"CornerLight",8,5,20,3,Color3.fromRGB(151,115,176))
    return root
end
local function caption(parent,value,size,color,position,dimensions)
    local shadow=Theme.text(parent,value,size,Color3.fromRGB(12,9,17),
        UDim2.new(position.X.Scale,position.X.Offset+2,position.Y.Scale,position.Y.Offset+2),dimensions)
    shadow.TextXAlignment=Enum.TextXAlignment.Center;shadow.Active=false;shadow.Selectable=false;shadow.ZIndex=3
    local label=Theme.text(parent,value,size,color,position,dimensions)
    label.TextXAlignment=Enum.TextXAlignment.Center;label.Active=false;label.Selectable=false;label.ZIndex=4
    return label,shadow
end
local function cardView(parent,name,id)
    local button=Theme.create("TextButton",parent,{Name=name,Text="",AutoButtonColor=false,
        BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromOffset(CARD_W,CARD_H),ZIndex=2})
    local edges=Theme.cardTrim(button)
    local border=Theme.outline(button);border.Thickness=0
    local aura=Theme.create("Frame",button,{Name="PixelMedallion",BackgroundTransparency=1,BorderSizePixel=0,
        Active=false,Selectable=false,Position=UDim2.fromOffset(24,40),Size=UDim2.fromOffset(144,144),ZIndex=2})
    local rim,fill,glints={},{},{}
    for y,count in ipairs({4,8,10,10,12,12,12,12,10,10,8,4}) do
        rim[#rim+1]=rect(aura,"RimPixel",(12-count)*4,(y-1)*8,count*8,8,c.line)
        if count>4 then fill[#fill+1]=rect(aura,"CorePixel",(14-count)*4,(y-1)*8,(count-2)*8,8,c.paper,2) end
    end
    for _,r in ipairs({{24,8,24,8},{16,16,8,8},{72,32,8,8},{8,56,8,8},{64,80,8,8}}) do
        glints[#glints+1]=rect(aura,"GlintPixel",r[1],r[2],r[3],r[4],c.mint,3)
    end
    for _,parts in ipairs({rim,fill,glints}) do for _,part in ipairs(parts) do
        local p,s=part.Position,part.Size;part.Position=UDim2.fromOffset(p.X.Offset*1.5,p.Y.Offset*1.5);part.Size=UDim2.fromOffset(s.X.Offset*1.5,s.Y.Offset*1.5)
    end end
    local preview=Mascot.new(button,id);preview.frame.Position,preview.frame.Size=UDim2.fromOffset(48,80),UDim2.fromOffset(96,60)
    preview.frame.ZIndex=3
    local nameLabel,nameShadow=caption(button,"",14,c.ink,UDim2.fromOffset(8,8),UDim2.fromOffset(176,24))
    local rarity=Theme.text(button,"",14,c.muted,UDim2.fromOffset(8,188),UDim2.fromOffset(176,22))
    rarity.ZIndex=4;rarity.TextXAlignment=Enum.TextXAlignment.Center
    local plaque=Theme.pixelPanel(button,"BuffPlaque",UDim2.fromOffset(8,216),UDim2.fromOffset(176,52),Color3.fromRGB(22,16,31))
    plaque.ZIndex=3
    local buff,buffShadow=caption(plaque,"",14,Theme.pixelColors.gold,UDim2.fromOffset(6,6),UDim2.fromOffset(164,18))
    local speed,speedShadow=caption(plaque,"",14,c.muted,UDim2.fromOffset(6,28),UDim2.fromOffset(164,18))
    local status,statusShadow=caption(button,"SELECT",14,c.accent,UDim2.fromOffset(8,274),UDim2.fromOffset(176,22))
    return {frame=button,border=border,edges=edges,preview=preview,name=nameLabel,nameShadow=nameShadow,rarity=rarity,
        buff=buff,buffShadow=buffShadow,speed=speed,speedShadow=speedShadow,status=status,statusShadow=statusShadow,
        aura={frame=aura,rim=rim,fill=fill,glints=glints}}
end
local function styleCard(entry,card,unlocked)
    local key=(card and card.id or "empty")..tostring(unlocked)
    if entry.aura.key~=key then
        entry.aura.key=key
        local colors=card and auraColors[card.familyId or card.id] or (unlocked and {{115,141,135},{36,45,51},{145,182,161}} or {{88,77,102},{35,29,45},{110,96,124}})
        for _,part in ipairs(entry.aura.rim) do part.BackgroundColor3=Color3.fromRGB(colors[1][1],colors[1][2],colors[1][3]) end
        for _,part in ipairs(entry.aura.fill) do part.BackgroundColor3=Color3.fromRGB(colors[2][1],colors[2][2],colors[2][3]) end
        for _,part in ipairs(entry.aura.glints) do part.BackgroundColor3=Color3.fromRGB(colors[3][1],colors[3][2],colors[3][3]) end
    end
    entry.buff.Text=card and string.format("$ %+g%%",(card.value-1)*100) or ""
    entry.rarity.Text=card and string.upper(card.rarity) or ""
    entry.rarity.TextColor3=card and Theme.rarity[card.rarity] or c.muted
    entry.speed.Text=card and string.format("SPD %+g%%",(card.speed-1)*100) or ""
    entry.buff.TextColor3=card and card.value<1 and c.accent or Theme.pixelColors.gold
    entry.speed.TextColor3=card and card.speed>1 and c.mint or card and card.speed<1 and c.accent or c.muted
    entry.frame:SetAttribute("Buffs",card and Cards.buffText(card) or "")
    for _,pair in ipairs({{entry.name,entry.nameShadow},{entry.buff,entry.buffShadow},{entry.speed,entry.speedShadow},{entry.status,entry.statusShadow}}) do
        pair[2].Text=pair[1].Text
    end
end
return {rect=rect,panel=panel,caption=caption,cardView=cardView,styleCard=styleCard}

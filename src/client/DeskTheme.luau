--!nonstrict
-- Floating CLI desktop with the Roblox built-in pixel font.
local TextService = game:GetService("TextService")
local Theme = {}
Theme.colors = {
    black = Color3.fromRGB(8,7,10),
    desktop = Color3.fromRGB(25, 21, 64), blue = Color3.fromRGB(205, 127, 97),
    title = Color3.fromRGB(35, 36, 43), panel = Color3.fromRGB(33, 33, 38),
    paper = Color3.fromRGB(47, 45, 48), text = Color3.fromRGB(231, 228, 224),
    muted = Color3.fromRGB(170, 166, 164), terminal = Color3.fromRGB(31, 31, 35),
    terminalBar = Color3.fromRGB(34, 34, 40), ink = Color3.fromRGB(238, 235, 231),
    dim = Color3.fromRGB(170, 166, 164), mint = Color3.fromRGB(151, 196, 165),
    amber = Color3.fromRGB(221, 181, 132), line = Color3.fromRGB(80, 70, 68),
    white = Color3.fromRGB(255, 255, 255), shadow = Color3.fromRGB(112, 112, 119),
    selected = Color3.fromRGB(80, 53, 45), green = Color3.fromRGB(151, 196, 165),
    syntax = Color3.fromRGB(205, 127, 97), accent = Color3.fromRGB(205, 127, 97),
}
Theme.rarity = { Common = Theme.colors.dim, Uncommon = Theme.colors.mint,
    Rare = Color3.fromRGB(133, 198, 255), Epic = Color3.fromRGB(215, 172, 255),
    Legendary = Theme.colors.amber, Mythic = Color3.fromRGB(255, 167, 205) }
Theme.font = Font.fromName("PressStart2P")
Theme.mono = Theme.font
Theme.pixelColors={base=Color3.fromRGB(27,23,34),panel=Color3.fromRGB(42,32,52),
    edge=Color3.fromRGB(137,106,159),portrait=Color3.fromRGB(49,36,67),gold=Color3.fromRGB(240,185,83)}
-- Responsive native pixel frames shared by collection and prestige pages.
function Theme.pixelPanel(parent,name,position,size,fillColor)
    local p=Theme.pixelColors
    local frame=Theme.create("Frame",parent,{Name=name,BackgroundTransparency=1,BorderSizePixel=0,
        Active=false,Selectable=false,Position=position,Size=size})
    local edges={}
    for _,rect in ipairs({{4,0,-8,0},{0,4,0,-8}}) do
        edges[#edges+1]=Theme.create("Frame",frame,{Name="PixelEdge",BorderSizePixel=0,Active=false,Selectable=false,
            BackgroundColor3=Theme.colors.black,Position=UDim2.fromOffset(rect[1],rect[2]),Size=UDim2.new(1,rect[3],1,rect[4])})
    end
    local fills={}
    for _,rect in ipairs({{8,4,-16,-8},{4,8,-8,-16}}) do
        fills[#fills+1]=Theme.create("Frame",frame,{Name="PixelFill",BorderSizePixel=0,Active=false,Selectable=false,
            BackgroundColor3=fillColor or p.panel,Position=UDim2.fromOffset(rect[1],rect[2]),Size=UDim2.new(1,rect[3],1,rect[4])})
    end
    return frame,edges,fills
end
function Theme.pixelChip(parent,position,size)
    local root=Theme.create("Frame",parent,{Name="PixelChip",BackgroundTransparency=1,BorderSizePixel=0,
        Active=false,Selectable=false,Position=position,Size=UDim2.fromOffset(size,size)})
    for _,r in ipairs({{0.3,0.2,0.6,0.9},{0.2,0.3,0.8,0.7},{0.1,0.4,1,0.5}}) do
        Theme.create("Frame",root,{Name="ChipShadow",BorderSizePixel=0,Active=false,Selectable=false,
            BackgroundColor3=Color3.fromRGB(14,10,15),BackgroundTransparency=0.1,
            Position=UDim2.fromScale(r[1],r[2]),Size=UDim2.fromScale(r[3],r[4])})
    end
    local rows={"...aaaa...","..abbbba..",".abccccba.","abccddccba","abcddddcba","abccddccba","abccddccba",".abccccba.","..abbbba..","...aaaa..."}
    local palette={a=Color3.fromRGB(131,77,36),b=Theme.pixelColors.gold,c=Color3.fromRGB(255,211,104),d=Color3.fromRGB(255,239,166)}
    for y,row in ipairs(rows) do for x=1,10 do
        local color=palette[row:sub(x,x)]
        if color then Theme.create("Frame",root,{Name="ChipPixel",ZIndex=2,BorderSizePixel=0,Active=false,Selectable=false,BackgroundColor3=color,
            Position=UDim2.fromScale((x-1)/10,(y-1)/10),Size=UDim2.fromScale(0.1,0.1)}) end
    end end
    return root
end
function Theme.cardTrim(parent)
    Theme.create("Frame",parent,{Name="CardShadow",BorderSizePixel=0,Active=false,Selectable=false,
        BackgroundColor3=Theme.colors.black,Position=UDim2.fromOffset(4,6),Size=UDim2.new(1,0,1,-2)})
    local panel=Theme.pixelPanel(parent,"CardFrame",UDim2.fromOffset(0,0),UDim2.fromScale(1,1),Color3.fromRGB(19,15,29))
    local _,edges=Theme.pixelPanel(panel,"AccentFrame",UDim2.fromOffset(4,4),UDim2.new(1,-8,1,-8),Color3.fromRGB(19,15,29))
    for _,edge in ipairs(edges) do edge.BackgroundColor3=Color3.fromRGB(189,104,138) end
    for _,y in ipairs({4,-7}) do
        Theme.create("Frame",panel,{Name="TerracottaRail",BorderSizePixel=0,Active=false,Selectable=false,
            BackgroundColor3=y>0 and Color3.fromRGB(241,152,161) or Color3.fromRGB(117,58,87),
            Position=UDim2.new(0,8,y>0 and 0 or 1,y),Size=UDim2.new(1,-16,0,3)})
    end
    for _,x in ipairs({0,1}) do for _,y in ipairs({0,1}) do
        local corner=Theme.create("Frame",panel,{Name="GoldCorner",BorderSizePixel=0,Active=false,Selectable=false,
            BackgroundColor3=Theme.pixelColors.gold,Position=UDim2.new(x,x==0 and 4 or -12,y,y==0 and 4 or -12),Size=UDim2.fromOffset(8,8)})
        Theme.create("Frame",corner,{Name="CornerGlint",BorderSizePixel=0,Active=false,Selectable=false,
            BackgroundColor3=Color3.fromRGB(255,237,167),Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(8,3)})
    end end
    for _,y in ipairs({0,1}) do
        Theme.create("Frame",panel,{Name="IvoryClasp",BorderSizePixel=0,Active=false,Selectable=false,
            BackgroundColor3=Theme.colors.ink,Position=UDim2.new(0.5,-3,y,y==0 and 0 or -4),Size=UDim2.fromOffset(6,4)})
    end
    return edges
end
local widths = {}
function Theme.textWidth(value, size)
    local key = size .. ":" .. value
    if not widths[key] then
        widths[key] = math.ceil(TextService:GetTextSize(value,size,Enum.Font.Arcade,Vector2.new(10000,10000)).X)
    end
    return widths[key]
end

function Theme.create(className, parent, properties)
    local item = Instance.new(className)
    for key, value in pairs(properties) do item[key] = value end
    item.Parent = parent
    return item
end

function Theme.text(parent, value, size, color, position, dimensions, font)
    return Theme.create("TextLabel", parent, { BackgroundTransparency = 1, BorderSizePixel = 0,
        Text = value, TextSize = size or 14, TextColor3 = color or Theme.colors.text,
        TextStrokeColor3=Theme.colors.black,TextStrokeTransparency=.8,
        FontFace = font or Theme.font, TextWrapped = true, RichText = false,
        TextXAlignment = Enum.TextXAlignment.Left, Position = position, Size = dimensions })
end

function Theme.outline(item)
    return Theme.create("UIStroke", item, { Name = "PanelBorder", Color = Theme.colors.black,
        Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end

function Theme.rule(parent, position, size, color)
    return Theme.create("Frame", parent, { Name = "Divider", BorderSizePixel = 0,
        Position = position, Size = size, BackgroundColor3 = color or Theme.colors.line })
end

function Theme.round(item, radius)
    return Theme.create("UICorner", item, { CornerRadius = UDim.new(0, radius or 10) })
end

function Theme.window(item)
    Theme.round(item, 10)
    local border = Theme.outline(item)
    border.Color = Theme.colors.black
    return border
end

function Theme.windowDots(parent)
    for index, color in ipairs({ Color3.fromRGB(216, 104, 100), Color3.fromRGB(222, 183, 103), Theme.colors.mint }) do
        local dot = Theme.create("Frame", parent, { Name = "StatusDot" .. index, BorderSizePixel = 0,
            BackgroundColor3 = color, Position = UDim2.fromOffset(14 + (index - 1) * 17, 15), Size = UDim2.fromOffset(10, 10) })
        Theme.round(dot, 5)
    end
end

function Theme.button(parent, value, position, size, callback)
    local item = Theme.create("TextButton", parent, { Text = value, FontFace = Theme.font, TextSize = 14,
        TextColor3 = Theme.colors.text, BackgroundColor3 = Theme.colors.paper,
        AutoButtonColor = false, BorderSizePixel = 0, Position = position, Size = size, TextWrapped = true })
    Theme.outline(item)
    Theme.round(item, 4)
    item.Activated:Connect(callback) -- Instance-owned; destroying the button disconnects it.
    return item
end

-- Native stepped pixels, with a passive face/shadow and one unchanged hit area.
function Theme.pixelButton(parent,value,position,size,callback)
    local item=Theme.create("TextButton",parent,{Text=value,TextTransparency=1,TextSize=14,
        FontFace=Theme.font,BackgroundTransparency=1,BorderSizePixel=0,AutoButtonColor=false,
        Position=position,Size=size})
    local parts={}
    local width,height=size.X.Offset,size.Y.Offset
    for _,rect in ipairs({{6,4,width-12,height-4},{3,7,width-6,height-10},{0,10,width,height-16}}) do
        Theme.create("Frame",item,{Name="PixelShadow",BorderSizePixel=0,Active=false,Selectable=false,
            BackgroundColor3=Theme.colors.black,Position=UDim2.fromOffset(rect[1],rect[2]),Size=UDim2.new(1,rect[3]-width,1,rect[4]-height)})
    end
    for _,rect in ipairs({{6,0,width-12,height-6},{3,3,width-6,height-12},{0,6,width,height-18}}) do
        Theme.create("Frame",item,{Name="PixelRim",BorderSizePixel=0,Active=false,Selectable=false,
            BackgroundColor3=Theme.colors.black,Position=UDim2.fromOffset(rect[1],rect[2]),Size=UDim2.new(1,rect[3]-width,1,rect[4]-height)})
    end
    for _,rect in ipairs({{8,2,width-16,height-10},{5,5,width-10,height-16},{2,8,width-4,height-22}}) do
        parts[#parts+1]=Theme.create("Frame",item,{Name="PixelFace",BorderSizePixel=0,Active=false,Selectable=false,
            BackgroundColor3=Theme.colors.paper,Position=UDim2.fromOffset(rect[1],rect[2]),Size=UDim2.new(1,rect[3]-width,1,rect[4]-height)})
    end
    local label=Theme.text(item,value,14,Theme.colors.muted,UDim2.fromOffset(6,0),UDim2.new(1,-12,1,-6))
    label.Name,label.TextXAlignment,label.ZIndex="PixelLabel",Enum.TextXAlignment.Center,2
    label.Active,label.Selectable=false,false
    item.Activated:Connect(callback)
    return item,{parts=parts,label=label}
end

function Theme.number(value)
    if value >= 1000000000000 then return string.format("%.1fT", value / 1000000000000) end
    if value >= 1000000000 then return string.format("%.1fB", value / 1000000000) end
    if value >= 1000000 then return string.format("%.1fM", value / 1000000) end
    if value >= 1000 then return string.format("%.1fK", value / 1000) end
    return tostring(math.floor(value))
end

function Theme.money(value)
    if value >= 1000 then return "$" .. Theme.number(value) end
    return string.format("$%.2f", value)
end

return Theme

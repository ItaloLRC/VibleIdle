--!nonstrict
-- Same authored pixel rectangles as the repository SVGs; no uploaded assets.
local Theme=require(script.Parent.DeskTheme)
local Catalog=require(script.Parent.StoreIconCatalog)
local Icon={}
function Icon.setHovered(canvas,hovered)
    if canvas:GetAttribute("Hovered")==hovered then return end
    canvas:SetAttribute("Hovered",hovered)
    local color=hovered and Theme.pixelColors.gold or Color3.fromRGB(0,0,0)
    for index=1,canvas:GetAttribute("OutlineCount") do
        canvas:FindFirstChild("Outline"..index).BackgroundColor3=color
    end
end
function Icon.resize(canvas,size,catalog)
    local definition=(catalog or Catalog)[canvas:GetAttribute("IconId")]
    local scale=math.max(1,math.floor(size/definition.width))
    local edge=math.max(2,scale*2)
    canvas.Size=UDim2.fromOffset(definition.width*scale,definition.height*scale)
    canvas:SetAttribute("OutlinePixels",edge)
    for index,part in ipairs(definition.parts) do
        local outline=canvas:FindFirstChild("Outline"..index)
        outline.Position=UDim2.fromOffset(part[1]*scale-edge,part[2]*scale-edge)
        outline.Size=UDim2.fromOffset(part[3]*scale+edge*2,part[4]*scale+edge*2)
        local pixel=canvas:FindFirstChild("Pixel"..index)
        pixel.Position=UDim2.fromOffset(part[1]*scale,part[2]*scale)
        pixel.Size=UDim2.fromOffset(part[3]*scale,part[4]*scale)
    end
end
function Icon.create(parent,id,catalog)
    local definition=assert((catalog or Catalog)[id],"Missing pixel icon")
    local canvas=Theme.create("Frame",parent,{Name="UpgradeIcon",BackgroundTransparency=1,BorderSizePixel=0,
        Active=false,Selectable=false,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.43),Size=UDim2.fromOffset(80,80)})
    canvas:SetAttribute("IconId",id)
    canvas:SetAttribute("OutlineCount",#definition.parts)
    canvas:SetAttribute("Hovered",false)
    for index,part in ipairs(definition.parts) do
        -- All black silhouettes sit behind all colored parts, avoiding seams
        -- between authored rectangles. Decoration never expands the hit target.
        Theme.create("Frame",canvas,{Name="Outline"..index,BackgroundColor3=Color3.fromRGB(0,0,0),
            BorderSizePixel=0,Active=false,Selectable=false,ZIndex=1})
        local color=part[5] or definition.color
        Theme.create("Frame",canvas,{Name="Pixel"..index,BackgroundColor3=Color3.fromRGB(color[1],color[2],color[3]),BorderSizePixel=0,Active=false,Selectable=false,
            ZIndex=2,
            Position=UDim2.fromScale(part[1]/definition.width,part[2]/definition.height),Size=UDim2.fromScale(part[3]/definition.width,part[4]/definition.height)})
    end
    Icon.resize(canvas,64,catalog)
    return canvas
end
return Icon

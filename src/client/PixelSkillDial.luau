--!nonstrict
-- Passive pixel artwork; the controller retains input, timing and target colors.
local Theme=require(script.Parent.DeskTheme)
local Dial={};Dial.__index=Dial
local function rounded(value) return math.floor(value+0.5) end
local function rectangle(parent,name,color)
    return Theme.create("Frame",parent,{Name=name,BorderSizePixel=0,
        BackgroundColor3=color,Active=false,Selectable=false})
end
local function circleRows(parent,name,radius,color)
    local rows={}
    local previous
    for rowIndex=0,23 do
        local left,right
        for column=0,23 do
            if (column+0.5-12)^2+(rowIndex+0.5-12)^2<=radius^2 then left=left or column;right=column+1 end
        end
        if left then
            if previous and previous.x==left and previous.w==right-left then previous.h=previous.h+1
            else
                local row={x=left,y=rowIndex,w=right-left,h=1,frame=rectangle(parent,name,color)}
                rows[#rows+1]=row;previous=row
            end
        else previous=nil end
    end
    return rows
end
function Dial.new(button)
    local self=setmetatable({body={},segments={},arcCells={},markerParts={},pressDepth=0},Dial)
    -- Twenty-four logical rows give the circle a deliberately stepped outline.
    -- Merge identical spans vertically; all artwork stays reusable on resize.
    for layer=1,2 do
        local previous
        local radius=layer==1 and 12 or 11
        for y=0,23 do
            local left,right
            for x=0,23 do
                if (x+0.5-12)^2+(y+0.5-12)^2<=radius^2 then
                    left=left or x;right=x+1
                end
            end
            if left then
                local color=layer==2 and Theme.colors.terminal or y<12 and Theme.colors.line or Color3.fromRGB(52,45,49)
                local band=y<12 and 1 or 2
                if previous and previous.x==left and previous.w==right-left and previous.band==band then
                    previous.h=previous.h+1
                else
                    local row={x=left,y=y,w=right-left,h=1,band=band}
                    row.frame=rectangle(button,layer==1 and "PixelRim" or "PixelFace",color)
                    self.body[#self.body+1]=row;previous=row
                end
            else previous=nil end
        end
    end
    self.shadowRows=circleRows(button,"ButtonShadow",12,Color3.fromRGB(8,6,15))
    for _,row in ipairs(self.shadowRows) do row.frame.ZIndex=0;row.frame.BackgroundTransparency=0.15 end
    self.capRoot=Theme.create("Frame",button,{Name="ButtonCap",BackgroundTransparency=1,
        BorderSizePixel=0,Size=UDim2.fromScale(1,1),Active=false,Selectable=false,ZIndex=1})
    self.baseRows=circleRows(self.capRoot,"ButtonBase",8.5,Color3.fromRGB(124,68,51))
    self.capRows=circleRows(self.capRoot,"ButtonFace",8.5,Theme.colors.accent)
    for _,row in ipairs(self.capRows) do row.frame.ZIndex=2 end
    -- Same ninety target samples as before, snapped to distinct40-grid cells.
    for index=1,90 do
        local angle=math.rad((index-1)*4)
        self.arcCells[index]={x=rounded((0.5+math.sin(angle)*0.43)*40),
            y=rounded((0.5-math.cos(angle)*0.43)*40)}
        self.segments[index]=rectangle(button,"Arc"..index,Theme.colors.line)
    end
    self.pivot=Theme.create("Frame",button,{Name="NeedlePivot",BackgroundTransparency=1,
        BorderSizePixel=0,Size=UDim2.fromScale(1,1),ZIndex=2,Active=false,Selectable=false})
    self.dot=Theme.create("Frame",self.pivot,{Name="OrbitDot",BorderSizePixel=0,
        BackgroundColor3=Color3.fromRGB(255,70,70),BackgroundTransparency=1,
        AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.07),
        Active=false,Selectable=false})
    local rows={{1,0,3,1},{0,1,5,3},{1,4,3,1}}
    for _,rect in ipairs(rows) do
        self.markerParts[#self.markerParts+1]={frame=rectangle(self.dot,"RedPixel",Color3.fromRGB(255,70,70)),rect=rect}
    end
    self:layout(120)
    return self
end
function Dial:layout(diameter)
    if self.diameter==diameter then return end
    self.diameter=diameter
    local function place(frame,x,y,w,h,grid,extent)
        local x0,y0=rounded(x/grid*extent),rounded(y/grid*extent)
        frame.Position=UDim2.fromOffset(x0,y0)
        frame.Size=UDim2.fromOffset(rounded((x+w)/grid*extent)-x0,rounded((y+h)/grid*extent)-y0)
    end
    for _,row in ipairs(self.body) do place(row.frame,row.x,row.y,row.w,row.h,24,diameter) end
    for _,row in ipairs(self.shadowRows) do place(row.frame,row.x+3/diameter*24,row.y+6/diameter*24,row.w,row.h,24,diameter) end
    for _,row in ipairs(self.baseRows) do place(row.frame,row.x,row.y+0.96,row.w,row.h,24,diameter) end
    for index,cell in ipairs(self.arcCells) do place(self.segments[index],cell.x-1,cell.y-1,2,2,40,diameter) end
    local markerSize=math.max(5,rounded(diameter*0.09))
    self.dot.Size=UDim2.fromOffset(markerSize,markerSize)
    for _,part in ipairs(self.markerParts) do
        local r=part.rect;place(part.frame,r[1],r[2],r[3],r[4],5,markerSize)
    end
    self:setPress(self.pressDepth,true)
end
function Dial:setPress(depth,force)
    depth=math.max(0,math.min(1,depth))
    if not force and self.pressDepth==depth then return end
    self.pressDepth=depth
    local diameter=self.diameter
    local scaleX,scaleY=1+depth*0.02,1-depth*0.18
    local shift=diameter*0.035*depth
    for _,row in ipairs(self.capRows) do
        local left=rounded((12+(row.x-12)*scaleX)/24*diameter)
        local top=rounded((12+(row.y-12)*scaleY)/24*diameter+shift)
        row.frame.Position=UDim2.fromOffset(left,top)
        row.frame.Size=UDim2.fromOffset(rounded((12+(row.x+row.w-12)*scaleX)/24*diameter)-left,
            rounded((12+(row.y+row.h-12)*scaleY)/24*diameter+shift)-top)
    end
    if self.label then
        self.label.Position=UDim2.fromOffset(rounded(diameter*0.14),rounded(diameter*0.39+shift))
        self.label.Size=UDim2.fromOffset(rounded(diameter*0.72),rounded(diameter*0.22*scaleY))
    end
end
function Dial:setPhase(angle)
    self.pivot.Rotation=angle
    -- Orbit remains smooth while each red pixel keeps its screen orientation.
    self.dot.Rotation=-angle
end
return Dial

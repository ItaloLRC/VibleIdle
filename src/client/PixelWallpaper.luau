--!nonstrict
-- Original procedural pixel interpretation of the supplied purple/orange orb.
local Theme = require(script.Parent.DeskTheme)
local Wallpaper = {}
function Wallpaper.create(parent)
    local frame = Theme.create("Frame", parent, { Name="PixelWallpaper", BackgroundColor3=Color3.fromRGB(8,3,23),
        BorderSizePixel=0, Size=UDim2.fromScale(1,1) })
    -- Large, deliberately coarse blocks keep the pixel silhouette visible.
    local columns, rows = 32, 18
    local function mix(a,b,t) return a+(b-a)*math.max(0,math.min(1,t)) end
    for row=0,rows-1 do
        for column=0,columns-1 do
            local x,y=(column+0.5)/columns,(row+0.5)/rows
            local dx,dy=(x-0.5)*1.7778,y-0.37
            local radius=math.sqrt(dx*dx+dy*dy)
            local lower=math.max(0,math.min(1,(dy+0.05)/0.6))
            local glow=math.exp(-((radius-0.60)/0.15)^2)*lower
            local rim=math.exp(-((radius-0.60)/0.024)^2)*lower^2
            local inside=math.max(0,math.min(1,(0.61-radius)*18))
            local purple=inside*math.exp(-((dx+0.08)^2/0.20+(dy-0.27)^2/0.16))
            local red=math.exp(-((dx-0.56)^2/0.20+(dy-0.38)^2/0.24))
            local r=8+112*purple+60*glow+60*red
            local g=3+4*purple+8*glow
            local b=24+134*purple+84*glow
            r,g,b=mix(r,255,rim),mix(g,222,rim),mix(b,154,rim)
            -- Quantized flat blocks; no gradients, textures, images or animation.
            local function channel(v) return math.max(0,math.min(255,math.floor(v/16+0.5)*16)) end
            Theme.create("Frame",frame,{Name="Pixel",BorderSizePixel=0,
                BackgroundColor3=Color3.fromRGB(channel(r),channel(g),channel(b)),
                Position=UDim2.fromScale(column/columns,row/rows),Size=UDim2.new(1/columns,1,1/rows,1)})
        end
    end
    return frame
end
return Wallpaper

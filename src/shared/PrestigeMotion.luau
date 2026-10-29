--!nonstrict
-- Presentation-only phases; no clock, services, transport or rewards.
local Motion={CLOSE=2.1,HOLD=.12,OPEN=.8,REDUCED_CLOSE=.18,REDUCED_OPEN=.18,SPECKS=144}
local function clamp(value) return math.max(0,math.min(1,value)) end
local function ease(value) return value*value*(3-2*value) end
function Motion.pose(age,reduced)
    age=math.max(0,age)
    local close=reduced and Motion.REDUCED_CLOSE or Motion.CLOSE
    local hold=reduced and 0 or Motion.HOLD
    local open=reduced and Motion.REDUCED_OPEN or Motion.OPEN
    local p=clamp(age/close)
    local eased=ease(p)
    local reveal=clamp((age-close-hold)/open)
    local covered=age>=close
    return {scale=(reduced or covered) and 1 or .015+.985*(1-eased)^1.4,
        angle=(reduced or covered) and 0 or 540*eased,
        veil=covered and 1-ease(reveal) or (reduced and p or eased^3),
        hole=(not reduced and not covered) and .60*eased*eased or 0,
        progress=p,covered=covered,done=age>=close+hold+open,
        spiral=not reduced and not covered,phase=not covered and "collapse" or reveal==0 and "covered" or "reveal"}
end
function Motion.spiral(age)
    local p=clamp(age/Motion.CLOSE)
    return {scale=math.max(.001,(1-ease(p))^.65),angle=360*ease(p)}
end
function Motion.speck(index,age,width,height)
    local transform=Motion.spiral(age)
    local arm=math.floor((index-1)/48)
    local u=((index-1)%48+1)/48
    local diagonal=math.sqrt(width*width+height*height)
    local radius=(.02+u)*diagonal*.58*transform.scale
    local angle=arm*math.pi*2/3+(1-u)*4.5+transform.angle*math.pi/180
    local nextRadius=(.02+u+1/48)*diagonal*.58*transform.scale
    local dx=math.cos(angle-4.5/48)*nextRadius-math.cos(angle)*radius
    local dy=math.sin(angle-4.5/48)*nextRadius-math.sin(angle)*radius
    local rotation=math.atan2 and math.atan2(dy,dx) or math.atan(dy,dx)
    return {x=width/2+math.cos(angle)*radius,y=height/2+math.sin(angle)*radius,
        size=(3+u*12)*transform.scale,
        length=math.sqrt(dx*dx+dy*dy)*.92,angle=rotation*180/math.pi,alpha=.7}
end
return Motion

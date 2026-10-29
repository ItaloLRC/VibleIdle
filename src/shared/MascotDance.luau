--!nonstrict
-- Cosmetic motion only. The outer mascot slot always remains stationary.
local Dance={TAU=math.pi*2}
function Dance.parameters(streak)
    local progress=math.max(0,math.min(40,streak))/40
    if progress==0 then return {rate=0,sway=0,lift=0,tilt=0,squash=0} end
    return {rate=1+3.5*progress,sway=0.012+0.028*progress,lift=0.018+0.062*progress,
        tilt=3+13*progress,squash=0.015+0.045*progress}
end
function Dance.advance(phase,dt,rate)
    if type(dt)~="number" or dt~=dt or dt<0 then return phase end
    return (phase+math.min(dt,0.1)*rate*Dance.TAU)%Dance.TAU
end
function Dance.pose(parameters,phase,blend)
    if parameters.rate==0 or blend<=0 then return 0,0,0,1,1 end
    blend=math.min(1,blend)
    local beat=math.sin(phase*2)
    local x=math.sin(phase)*parameters.sway*blend
    local y=-math.abs(beat)*parameters.lift*blend
    local angle=math.sin(phase)*parameters.tilt*blend
    local squash=beat*parameters.squash*blend
    local sx,sy=1+squash,1-squash
    -- The16:10 slot's rotated bounds must fit even at maximum frenzy. Artwork
    -- of any aspect already fits inside this inner slot through the renderer.
    local cosine,sine=math.abs(math.cos(math.rad(angle))),math.abs(math.sin(math.rad(angle)))
    local width,height=cosine*sx+sine*sy/1.6,cosine*sy+sine*sx*1.6
    local fit=math.min(1,(1-2*math.abs(x))/width,(1-2*math.abs(y))/height)
    return x,y,angle,sx*fit,sy*fit
end
return Dance

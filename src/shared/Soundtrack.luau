--!nonstrict
-- Original mellow lounge loop and connected A-minor pentatonic click phrase.
local Music={TONE="rbxasset://sounds/volume_slider.ogg",TAP="rbxasset://sounds/action_jump_land.mp3",
    VORTEX="rbxasset://sounds/action_falling.ogg"}
local phrase={69,72,74,76,79,76,74,72}
function Music.pitch(note) return 2^((note-69)/12) end
Music.BPM=88
local chords={{60,64,67,71},{57,60,64,67},{62,65,69,72},{55,59,62,65}}
local melody={{76,79,83,79},{76,72,69,72},{77,81,84,81},{74,77,79,74}}
function Music.transport() return {step=-1,elapsed=0} end
function Music.tier(streak,c)
    c=type(c)=="number" and c==c and math.max(1,math.min(100,c)) or 5
    return math.max(0,math.min(4,math.floor((streak or 0)/c)))
end
function Music.tempo(tier) return ({88,112,132,152,176})[math.max(0,math.min(4,tier or 0))+1] end
function Music.advance(clock,dt,tier,scale)
    if dt~=dt or dt<0 then return {} end
    if clock.step<0 then clock.step=0;return {0} end
    clock.elapsed=clock.elapsed+math.min(0.1,dt)
    local steps={};local interval=60/Music.tempo(tier)/4/(scale or 1)
    while clock.elapsed>=interval and #steps<2 do
        clock.elapsed=clock.elapsed-interval;clock.step=(clock.step+1)%128
        steps[#steps+1]=clock.step
    end
    if clock.elapsed>=interval then clock.elapsed=clock.elapsed%interval end
    return steps
end
function Music.rockEvents(step,tier)
    local roots={45,48,50,43};local root=roots[math.floor(step/16)%4+1]
    local beat=step%16;local notes={}
    local function tone(key,gain,duration)
        notes[#notes+1]={asset=Music.TONE,pitch=Music.pitch(key),gain=gain,duration=duration,attack=0.008}
    end
    local stride=tier==1 and 4 or tier<4 and 2 or 1
    if beat%stride==0 then
        tone(root,0.055,0.28-tier*0.035);tone(root+7,0.04,0.28-tier*0.035)
        if tier<4 then tone(root+12,0.025,0.24) end
    end
    if beat%4==0 then tone(root-12,0.065,0.25) end
    if beat%4==2 or (tier>=3 and beat%2==1) then
        local riff={0,0,7,10,0,12,10,7}
        tone(root+24+riff[math.floor(beat/2)%8+1],0.04,0.18)
    end
    local snare=beat==4 or beat==12
    if snare or beat%4==0 or (tier>=2 and beat%2==1) then
        notes[#notes+1]={asset=Music.TAP,pitch=snare and 1.5 or beat%4==0 and 0.65 or 3,
            gain=snare and 0.06 or beat%4==0 and 0.045 or 0.018,duration=0.07,attack=0.003}
    end
    return notes
end
function Music.events(step,tier)
    if tier and tier>0 then return Music.rockEvents(step,tier) end
    local bar=math.floor(step/16);local beat=step%16
    local index=math.floor(bar/2)%4+1
    local chord=chords[index];local notes={}
    local function tone(key,gain,duration,attack)
        notes[#notes+1]={asset=Music.TONE,pitch=Music.pitch(key),gain=gain,duration=duration,attack=attack}
    end
    if beat==0 then for _,key in ipairs(chord) do tone(key,0.035,1.6,0.04) end end
    if beat==0 or beat==8 then tone(chord[1]-12,0.07,0.6,0.015) end
    if beat%4==2 then
        local position=math.floor(beat/4)+1
        if bar%2==1 then position=5-position end
        tone(melody[index][position],0.045,0.42,0.012)
    end
    if beat==4 or beat==12 then
        notes[#notes+1]={asset=Music.TAP,pitch=2.8,gain=0.012,duration=0.045,attack=0.005}
    end
    return notes
end
function Music.envelope(age,duration,attack)
    if age<0 or age>=duration then return 0 end
    local release=math.min(0.22,duration*0.55)
    return math.min(1,age/math.max(0.003,attack),(duration-age)/release)
end
local uiSounds={
    skill={asset=Music.TAP,pitches={1.15,1.4,1.7,1.3},gain=0.07,duration=0.065},
    shop={asset=Music.TAP,pitches={0.8,0.95,1.1,0.9},gain=0.065,duration=0.08},
    navigate={asset=Music.TONE,keys={72,76,79,74},gain=0.045,duration=0.095},
    back={asset=Music.TONE,keys={69,67,64,62},gain=0.04,duration=0.09},
    select={asset=Music.TAP,pitches={2.1,2.35,2.6,2.25},gain=0.045,duration=0.045},
    sell={asset=Music.TAP,pitches={0.65,0.8,0.75,0.7},gain=0.07,duration=0.09},
    collect={asset=Music.TONE,keys={81,84,88,86},gain=0.055,duration=0.12},
    confirm={asset=Music.TONE,keys={76,79,81,84},gain=0.06,duration=0.14},
}
-- Four deterministic variations per gesture; never consume the game's RNG.
function Music.uiCue(kind,variation)
    local voice=uiSounds[kind] or uiSounds.navigate
    local index=(variation-1)%4+1
    local pitch=voice.pitches and voice.pitches[index] or Music.pitch(voice.keys[index])
    local notes={{asset=voice.asset,pitch=pitch,gain=voice.gain,duration=voice.duration,attack=0.003}}
    if kind=="shop" then
        local key=({72,76,79,74})[index]
        notes[2]={asset=Music.TONE,pitch=Music.pitch(key),risePitch=Music.pitch(key+12),riseAt=0.035,
            gain=0.04,duration=0.135,attack=0.005}
    elseif kind=="confirm" then
        notes[2]={asset=Music.TONE,pitch=pitch*1.5,gain=0.025,duration=0.18,attack=0.008}
    end
    return notes
end
function Music.cue(grade,streak)
    if grade~="Good" and grade~="Great" then return {} end
    local index=(math.max(1,math.floor(streak or 1))-1)%#phrase+1
    local pitch=Music.pitch(phrase[index])
    local notes={{asset=Music.TONE,pitch=pitch,gain=0.12,duration=0.65,attack=0.012}}
    if grade=="Great" then
        notes[2]={asset=Music.TONE,pitch=pitch*2,gain=0.045,duration=0.7,attack=0.018}
    end
    return notes
end
-- Short rising coin chimes in the click phrase's A-minor palette. Higher
-- rarities have a brighter interval and a quiet harmony, never extra rewards.
function Music.coinCue(rank)
    rank=type(rank)=="number" and rank==rank and math.max(1,math.min(5,math.floor(rank))) or 1
    local low=({81,84,88,91,93})[rank]
    local high=({88,93,96,100,105})[rank]
    local notes={{asset=Music.TONE,pitch=Music.pitch(low),risePitch=Music.pitch(high),
        riseAt=0.025,gain=0.05,duration=0.09+rank*0.018,attack=0.003}}
    if rank>1 then
        notes[2]={asset=Music.TONE,pitch=Music.pitch(low-12),risePitch=Music.pitch(high-12),
            riseAt=0.04,gain=0.018,duration=0.12+rank*0.02,attack=0.008}
    end
    return notes
end
-- Original suction wash from the same built-in sources; no downloaded track.
-- Three voices fit inside the existing six-voice effects pool.
function Music.vortexCue(reduced)
    local gain=(reduced and .3 or 1)*2.25
    return {
        {asset=Music.VORTEX,pitch=.55,gain=.095*gain,attack=.08,sustain=true,vortex=1},
        {asset=Music.TONE,pitch=.42,gain=.055*gain,attack=.1,sustain=true,vortex=2},
        {asset=Music.TONE,pitch=.63,gain=.025*gain,attack=.12,sustain=true,vortex=3},
    }
end
function Music.vortexMix(age,close,hold,open,channel)
    local total=close+hold+open
    local p=math.max(0,math.min(1,age/close))
    local reveal=math.max(0,math.min(1,(age-close-hold)/open))
    local attack=math.min(1,math.max(0,age)/math.min(.24,close/2))
    local tail=age>=total and 0 or age>close+hold and (1-reveal)^2 or 1
    local swirl=.82+.18*math.sin(age*9+(channel or 1)*2.1)
    local base=({.85,.62,.92})[channel or 1]
    return attack*tail*swirl*(.55+.45*p),base*(1-.72*p)+reveal*.9
end
return Music

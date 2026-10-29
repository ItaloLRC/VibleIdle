--!nonstrict
local SoundService=game:GetService("SoundService")
local GuiService=game:GetService("GuiService")
local ContentProvider=game:GetService("ContentProvider")
local Music=require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Soundtrack)
local Motion=require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").PrestigeMotion)
local Audio={}
Audio.__index=Audio
local function create(kind,parent,properties)
    local item=Instance.new(kind)
    for key,value in pairs(properties) do item[key]=value end
    item.Parent=parent;return item
end
function Audio.new(terminal)
    local self=setmetatable({terminal=terminal,musicVolume=0.5,effectsVolume=0.5,muted=false,
        musicVoices={},effectVoices={},clock=Music.transport(),musicTier=0,},Audio)
    self.folder=create("Folder",SoundService,{Name="VibeIdleAudio"})
    local ok,reason=pcall(function()
        self.musicGroup=create("SoundGroup",self.folder,{Name="Music",Volume=self.musicVolume})
        self.effectsGroup=create("SoundGroup",self.folder,{Name="Effects",Volume=self.effectsVolume})
        create("EqualizerSoundEffect",self.musicGroup,{LowGain=0,MidGain=-3,HighGain=-9})
        self.distortion=create("DistortionSoundEffect",self.musicGroup,{Level=0})
        create("ReverbSoundEffect",self.musicGroup,{DecayTime=1.4,Density=0.7,Diffusion=0.85,DryLevel=-3,WetLevel=-20})
        for index=1,16 do
            self.musicVoices[index]={sound=create("Sound",self.folder,{Name="MusicVoice"..index,
                SoundId=Music.TONE,Volume=0,Looped=false,SoundGroup=self.musicGroup})}
        end
        create("ReverbSoundEffect",self.effectsGroup,{DecayTime=1.1,Density=0.8,Diffusion=0.9,DryLevel=0,WetLevel=-20})
        for index=1,6 do
            self.effectVoices[index]={sound=create("Sound",self.folder,{Name="EffectVoice"..index,
                SoundId=Music.TAP,Volume=0,Looped=false,SoundGroup=self.effectsGroup})}
        end
    end)
    if not ok then self:fail(reason);return self end
    task.spawn(function()
        pcall(function() ContentProvider:PreloadAsync({Music.TONE,Music.TAP,Music.VORTEX}) end)
    end)
    return self
end
function Audio:fail(reason)
    if self.disabled then return end
    self.disabled=true
    self.folder:Destroy()
    warn("[VibeIdle] Local audio unavailable; gameplay continues: "..tostring(reason))
end
function Audio:active()
    return not self.destroyed and not self.disabled and not self.muted and not self.terminal.blocked
        and self.terminal.windowFocused and not GuiService.MenuIsOpen
end
function Audio:stopVoices(pool)
    for _,voice in ipairs(pool) do
        if voice.note then voice.sound:Stop();voice.sound.Volume=0;voice.note=nil end
    end
end
function Audio:play(pool,note)
    if not self:active() then return end
    local voice=pool[1]
    for _,candidate in ipairs(pool) do
        if not candidate.note then voice=candidate;break end
        if (candidate.age or 0)>(voice.age or 0) then voice=candidate end
    end
    local ok,reason=pcall(function()
        voice.sound:Stop()
        voice.sound.SoundId=note.asset;voice.sound.PlaybackSpeed=note.pitch;voice.sound.TimePosition=0
        voice.sound.Looped=note.sustain==true
        voice.sound.Volume=0.001
        voice.sound:Play()
    end)
    if not ok then self:fail(reason);return end
    voice.note,voice.age=note,0
end
function Audio:click(kind)
    if not self:active() or self.effectsVolume==0 then return end
    self.clickSequence=(self.clickSequence or 0)%4+1
    for _,note in ipairs(Music.uiCue(kind,self.clickSequence)) do self:play(self.effectVoices,note) end
end
function Audio:confirmed(result)
    -- Called only by the existing matching-result watermark. Never by sync alone.
    if not self:active() or self.effectsVolume==0 or self.terminal.suspended or result.reused then return end
    for _,note in ipairs(Music.cue(result.grade,result.streak)) do self:play(self.effectVoices,note) end
end
function Audio:coin(event)
    if event.receiptId<(self.coinReceipt or 0) or (event.receiptId==(self.coinReceipt or 0)
        and event.tokenIndex<=(self.coinIndex or 0)) then return end
    self.coinReceipt,self.coinIndex=event.receiptId,event.tokenIndex
    if not self:active() or self.effectsVolume==0 or self.terminal.suspended then return end
    for _,note in ipairs(Music.coinCue(event.rank)) do self:play(self.effectVoices,note) end
end
function Audio:startVortex(id,reduced)
    if id<=(self.lastVortexId or 0) then return false end
    self.lastVortexId=id
    if not self:active() or self.effectsVolume==0 then return false end
    self.vortexActive=true;self.vortexAge=0;self.vortexReduced=reduced
    for _,note in ipairs(Music.vortexCue(reduced)) do self:play(self.effectVoices,note) end
    return not self.disabled
end
function Audio:stopVortex()
    self.vortexActive=false
    if self.disabled or self.destroyed then return end
    for _,voice in ipairs(self.effectVoices) do if voice.note and voice.note.vortex then
        voice.sound:Stop();voice.sound.Volume=0;voice.note=nil
    end end
end
function Audio:vortexFrame(age,reduced,active,paused)
    if not active or paused then self:stopVortex();return end
    self.vortexAge,self.vortexReduced=age,reduced
end
function Audio:setVolume(channel,value)
    value=math.max(0,math.min(1,value))
    if channel=="music" then self.musicVolume=value
    elseif channel=="effects" then self.effectsVolume=value else return end
    if not self.disabled and not self.destroyed then
        self.musicGroup.Volume=self.muted and 0 or self.musicVolume
        self.effectsGroup.Volume=self.muted and 0 or self.effectsVolume
        if value==0 then
            self:stopVoices(channel=="music" and self.musicVoices or self.effectVoices)
            if channel=="music" then self.clock=Music.transport() end
        end
    end
end
function Audio:setMuted(value)
    self.muted=value
    if self.disabled or self.destroyed then return end
    self.musicGroup.Volume=value and 0 or self.musicVolume
    self.effectsGroup.Volume=value and 0 or self.effectsVolume
    if value then self:stopVoices(self.musicVoices);self:stopVoices(self.effectVoices);self.clock=Music.transport() end
end
function Audio:tick(dt,streak,c)
    if self.disabled or self.destroyed then return end
    if not self:active() then
        self:stopVoices(self.musicVoices);self:stopVoices(self.effectVoices)
        self.clock=Music.transport();return
    end
    dt=math.max(0,math.min(0.1,dt))
    self.musicTier=Music.tier(streak or 0,c)
    self.distortion.Level=self.distortion.Level+(self.musicTier*0.09-self.distortion.Level)*math.min(1,dt*4)
    for _,pool in ipairs({self.musicVoices,self.effectVoices}) do
        for _,voice in ipairs(pool) do
            if voice.note then
                if voice.note.vortex then
                    local close=self.vortexReduced and Motion.REDUCED_CLOSE or Motion.CLOSE
                    local hold=self.vortexReduced and 0 or Motion.HOLD
                    local open=self.vortexReduced and Motion.REDUCED_OPEN or Motion.OPEN
                    local gain,pitch=Music.vortexMix(self.vortexAge or 0,close,hold,open,voice.note.vortex)
                    voice.sound.Volume=voice.note.gain*gain;voice.sound.PlaybackSpeed=pitch
                else
                    voice.age=math.min(voice.age+dt,voice.note.sustain and voice.note.attack or math.huge)
                    local envelope=voice.note.sustain and math.min(1,voice.age/voice.note.attack)
                        or Music.envelope(voice.age,voice.note.duration,voice.note.attack)
                    voice.sound.Volume=voice.note.gain*envelope
                    if voice.note.risePitch then
                        voice.sound.PlaybackSpeed=voice.age>=voice.note.riseAt and voice.note.risePitch or voice.note.pitch
                    end
                    if not voice.note.sustain and voice.age>=voice.note.duration then voice.sound:Stop();voice.note=nil end
                end
            end
        end
    end
    if self.musicVolume>0 then
        for _,step in ipairs(Music.advance(self.clock,dt,self.musicTier,self.terminal.tuning and self.terminal.tuning.musicScale)) do
            for _,note in ipairs(Music.events(step,self.musicTier)) do
                self:play(self.musicVoices,note)
                if self.disabled then return end
            end
        end
    end
end
function Audio:destroy()
    if self.destroyed then return end
    self.destroyed=true;self.folder:Destroy();self.musicVoices={};self.effectVoices={}
end
return Audio

--!nonstrict
local Tuning={}
Tuning.controls={
    {key="initialRps",action="skill_initial",label="Initial spin",unit="rev/s",values={1,0.75,0.4,1/1.8,1.5,2}},
    {key="growth",action="skill_acceleration",label="Per hit",unit="x",values={1.045,1.065,1.09,1.025,1}},
    {key="minDuration",label="Fastest revolution",unit="s",values={0.55,0.75,1,0.4,0.25}},
    {key="skillCooldown",label="Click cooldown",unit="s",values={0,0.1,0.25,0.5,1}},
    {key="buttonReturn",label="Button rebound",unit="s",values={0.14,0.2,0.3,0.08,0.1}},
    {key="initialDelay",label="First check delay",unit="s",values={0.25,0,0.5,1,2}},
    {key="grace",label="Timing grace",unit="s",values={0.12,0,0.04,0.08}},
    {key="streakTimeout",label="Streak timeout",unit="s / 0 off",values={5,10,15,30,0,1,2,3}},
    {key="promptCooldown",label="Send cooldown",unit="s",values={0,0.1,0.25,0.5,1,2}},
    {key="agentInterval",label="Agent pacing window",unit="s / TPC",values={1,2,3,5,0.1,0.25,0.5}},
    {key="agentJitter",label="Agent timing variation",unit="x",values={0.06,0.1,0,0.03}},
    {key="agentRate",label="Agent words/s",unit="/ 0 upgrade",values={0,4,8,16,32,44}},
    {key="spawnPercent",label="Legacy spawn (inactive)",unit="%",values={30,50,75,100,0,5,10,20}},
    {key="spawnCapacity",label="Spawn limit",unit="agents",values={10,1,3,5}},
    {key="avatarFadeIn",label="Agent fade in",unit="s",values={0.12,0.25,0.5,1,0.05}},
    {key="avatarFadeOut",label="Agent fade out",unit="s",values={0.65,1,2,0.1,0.3}},
    {key="floatingDuration",label="Floating words",unit="s",values={1.4,2,3,0.5,1}},
    {key="cashDuration",label="Money feedback",unit="s",values={1.8,3,5,0.5,1}},
    {key="jobDuration",label="CLI job duration",unit="s",values={1.4,2,4,0.35,0.7}},
    {key="revealScale",label="Letter speed",unit="x",values={1,2,4,0.25,0.5}},
    {key="danceScale",label="Dance speed",unit="x",values={1,1.5,2,0,0.25,0.5}},
    {key="musicScale",label="Music tempo",unit="x",values={1,1.25,1.5,2,0.5,0.75}},
    {key="responseTimeout",label="Prompt response",unit="s",values={5,8,12,3}},
    {key="syncDelay",label="Word sync delay",unit="s",values={3,4,5,1,2}},
    {key="grantTimeout",label="Word request limit",unit="s",values={12,18,24,30}},
    {key="snapshotInterval",label="State update gap",unit="s",values={0.5,1,2,0.1,0.25}},
}
Tuning.byAction={}
for _,control in ipairs(Tuning.controls) do
    control.action=control.action or "tune_"..control.key
    Tuning.byAction[control.action]=control
end
function Tuning.view(settings)
    local result={}
    for _,control in ipairs(Tuning.controls) do
        result[control.key]=settings and settings[control.key] or control.values[1]
    end
    return result
end
function Tuning.cycle(settings,action,direction)
    local control=Tuning.byAction[action]
    if not control or (direction~=1 and direction~=-1) then return false end
    local selected=1
    for index,value in ipairs(control.values) do
        if settings[control.key] and math.abs(settings[control.key]-value)<0.000001 then selected=index end
    end
    settings[control.key]=control.values[(selected-1+direction)%#control.values+1]
    return true
end
return Tuning

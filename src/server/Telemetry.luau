--!nonstrict
-- Durable profile counters; bounded best-effort native analytics, never rewards.
local T={};T.__index=T
local function finite(n) return type(n)=="number" and n==n and n>=0 and n<math.huge end
local function cap(n,limit) return math.min(limit,math.max(0,n)) end
function T.new(deps) return setmetatable(deps,T) end
function T.milestone(_player,state,name,_config) state.milestones[name]=true end
function T:begin(player,record,id)
    local now=self.clock()
    record.telemetry={player=player,id=id,start=now,last=now,fraction=0,lastFlush=now,
        queue={},order={},queued=0,tokens=4,tokenAt=now,lastLog=now,baseline=self.state.copyAnalytics(record.state.analytics),pulseId=0,button=0,enter=0}
    self:add(record,"sessions",1)
end
function T:queue(record,name,value,kind,stage)
    local s=record.telemetry;if not s or not finite(value) or value==0 then return end
    local key=name..":"..kind..":"..stage;local e=s.queue[key]
    if not e then
        if s.queued>=64 then s.dropped=(s.dropped or 0)+1;return end
        e={name=name,value=0,kind=kind,stage=stage};s.queue[key]=e;s.order[#s.order+1]=key;s.queued=s.queued+1
    end
    e.value=cap(e.value+value,self.state.METRIC_CAP)
end
function T:add(record,key,amount)
    local a=record.state.analytics
    if not a or not finite(amount) or type(a[key])~="number" then return end
    a[key]=cap(a[key]+amount,self.state.METRIC_CAP)
end
function T:map(record,key,id,amount)
    local map=record.state.analytics[key]
    if type(map)~="table" or not finite(amount) then return end
    map[id]=cap((map[id] or 0)+amount,self.state.METRIC_CAP)
end
function T:stage(record) return self.balance.progression(record.state).stageName end
function T:action(record,key,amount)
    self:add(record,key,amount or 1);self:queue(record,"CoreAction",amount or 1,key,self:stage(record))
end
function T:settle(record)
    local s=record.telemetry;if not s or s.finished then return end
    local now=self.clock();local elapsed=math.max(0,now-s.last);s.last=math.max(s.last,now)
    s.fraction=s.fraction+elapsed;local whole=math.floor(s.fraction);s.fraction=s.fraction-whole
    self:add(record,"onlineSeconds",whole);self:queue(record,"OnlineSeconds",whole,"connected",self:stage(record))
end
function T:event(record,name,kind,amount)
    if not record.telemetry then return end
    self:settle(record)
    local p,a=record.state,record.state.analytics
    local entry={event=name,kind=kind,at=math.floor(self.unix()),sessionSeconds=math.floor(math.max(0,self.clock()-record.telemetry.start)),
        onlineSeconds=a.onlineSeconds,sessionNumber=a.sessions,stage=self:stage(record),agents=#p.layerSizes-2,
        computeLevel=p.computeLevel,context=math.min(self.balance.PROMPT_MAX_TOKENS,self.balance.PROMPT_BASE_TOKENS+p.tokenLevel*self.balance.PROMPT_TOKENS_PER_LEVEL),
        prestiges=p.prestigeCount,money=p.credits,chips=p.chips,amount=amount or 1}
    for key,value in pairs(entry) do if type(value)=="number" then entry[key]=cap(value,self.state.METRIC_CAP) end end
    a.recent[#a.recent+1]=entry;if #a.recent>24 then table.remove(a.recent,1) end
    if (name=="robux_delivered" or name=="pass_owned") and not a.firstRobux then
        a.firstRobux={};for key,value in pairs(entry) do a.firstRobux[key]=value end
    end
    return entry
end
function T:upgrade(record,action,count,_cost)
    self:map(record,"upgradePurchases",action,1);self:map(record,"upgradeLevels",action,count)
    self:event(record,"upgrade",action,count);self:queue(record,"CoreAction",1,action,self:stage(record))
    self:queue(record,"UpgradeLevels",count,action,self:stage(record))
end
function T:commerce(record,phase,sku)
    local key=({prompt="robuxPrompts",delivered="robuxDelivered",canceled="robuxCanceled",unavailable="robuxUnavailable",pass_owned="robuxDelivered"})[phase]
    if not key then return end
    self:map(record,key,sku,1)
    local name=({prompt="robux_prompt",delivered="robux_delivered",canceled="robux_cancel",unavailable="robux_unavailable",pass_owned="pass_owned"})[phase]
    local entry=self:event(record,name,sku,1)
    self:queue(record,"CoreAction",1,name.."_"..sku,self:stage(record))
    if entry and (phase=="prompt" or phase=="delivered" or phase=="pass_owned") then
        self:queue(record,"RobuxSessionSeconds",entry.sessionSeconds,phase.."_"..sku,entry.stage)
    end
end
function T:pulse(record,payload)
    local s=record.telemetry;if not s or payload.requestId<=s.pulseId then return false end
    local now=self.clock();if s.pulseAt and now-s.pulseAt<10 then return false end
    s.pulseId=payload.requestId
    local button=math.min(120,math.max(0,payload.button-s.button));local enter=math.min(120,math.max(0,payload.enter-s.enter))
    s.button,s.enter=math.max(s.button,payload.button),math.max(s.enter,payload.enter)
    self:add(record,"sellButtonReported",button);self:add(record,"sellEnterReported",enter)
    self:queue(record,"SellInputReported",button,"button",self:stage(record));self:queue(record,"SellInputReported",enter,"enter",self:stage(record))
    if s.pulseAt and now-s.pulseAt<=25 and s.focused and payload.focused then
        local seconds=math.floor(math.max(0,now-s.pulseAt));self:add(record,"focusedSecondsReported",seconds)
        self:queue(record,"FocusedSecondsReported",seconds,payload.page,self:stage(record))
    end
    if s.page~=payload.page then self:queue(record,"PageSeenReported",1,payload.page,self:stage(record)) end
    s.pulseAt,s.focused,s.page=now,payload.focused,payload.page;return true
end
function T:report(record)
    self:settle(record)
    local s=record.telemetry;local total=self.state.copyAnalytics(record.state.analytics);local delta={}
    for _,key in ipairs(self.state.METRIC_COUNTERS) do delta[key]=math.max(0,total[key]-s.baseline[key]) end
    for _,key in ipairs(self.state.METRIC_MAPS) do
        delta[key]={};for id,value in pairs(total[key]) do delta[key][id]=math.max(0,value-(s.baseline[key][id] or 0)) end
    end
    return {userId=s.player.UserId,sessionId=s.id,build=self.balance.BUILD_VERSION,
        sessionSeconds=math.floor(math.max(0,self.clock()-s.start)),totals=total,session=delta,droppedEvents=s.dropped or 0}
end
function T:flush(record,reason)
    local s=record.telemetry;if not s or s.busy then return end
    local now=self.clock();s.lastFlush=now
    s.tokens=math.min(4,s.tokens+math.max(0,now-s.tokenAt)*8/60);s.tokenAt=now
    local batch={}
    if self.config.SEND_ANALYTICS and self.published and not self.studio then
        while #s.order>0 and s.tokens>=1 and #batch<4 do
            local key=table.remove(s.order,1);local entry=s.queue[key]
            s.tokens=s.tokens-1;s.queue[key]=nil;s.queued=s.queued-1;batch[#batch+1]={key=key,entry=entry}
        end
    else s.queue={};s.order={};s.queued=0 end
    local shouldLog=self.config.ANALYTICS_LOGS and (reason=="leave" or now-s.lastLog>=60)
    local report=shouldLog and self:report(record) or nil;if shouldLog then s.lastLog=now end;s.busy=true
    self.spawn(function()
        if report and self.log then pcall(self.log,report,reason) end
        for _,item in ipairs(batch) do
            local e=item.entry
            local ok=pcall(function()
                self.analytics:LogCustomEvent(s.player,e.name,e.value,{CustomField01=e.kind,CustomField02=e.stage,CustomField03=self.balance.BUILD_VERSION})
            end)
            if not ok then
                if not e.retried and s.queued<64 then
                    local newer=s.queue[item.key]
                    if newer then newer.value=cap(newer.value+e.value,self.state.METRIC_CAP);newer.retried=true
                    else e.retried=true;s.queue[item.key]=e;s.order[#s.order+1]=item.key;s.queued=s.queued+1 end
                else s.dropped=(s.dropped or 0)+1 end
            end
        end
        s.busy=false
    end)
end
function T:tick(record)
    self:settle(record)
    if self.clock()-record.telemetry.lastFlush>=15 and not record.receiptBusy and not record.saving then self:flush(record,"interval") end
end
function T:finish(record)
    if not record.telemetry or record.telemetry.finished then return end
    self:settle(record);record.telemetry.finished=true;self:event(record,"session_end","leave",1);self:flush(record,"leave")
end
return T

--!nonstrict
-- The same specifications run in Studio, the Luau CLI, and the portable Lua runner.
local Specs = {}

function Specs.run(modules)
    local B, State, Sim, Rules = modules.Balance, modules.State, modules.Simulation, modules.Rules
    local Limiter, Protocol, Repository = modules.RateLimiter, modules.Protocol, modules.ProfileRepository
    local Layout = modules.Layout
    local Prompt, Draft = modules.Prompt, modules.Draft
    local Flow = modules.Flow
    -- Existing non-random economic invariants inject the common-tier boundary explicitly.
    local function submit(state, text, now, lastManual, config, simulation, choose)
        return Prompt.submit(state, text, now, lastManual, config, simulation, choose or function(low) return low end)
    end
    local passed,failures = 0,{}
    local function test(name, callback)
        local ok, reason = pcall(callback)
        if not ok then local failure="FAIL " .. name .. ": " .. tostring(reason);failures[#failures+1]=failure;print(failure);return end
        passed = passed + 1
        print("PASS " .. name)
    end
    local function near(actual, expected)
        assert(math.abs(actual - expected) < 0.00001, tostring(actual) .. " ~= " .. tostring(expected))
    end
    local function active()
        local state = State.new(B)
        state.batches = 1
        return state
    end
    local function funded()
        local state = active()
        state.credits = 100000000
        return state
    end
    local function legacy(version)
        local state = funded()
        state.schemaVersion, state.embDim, state.blockCount = version, nil, nil
        state.layerSizes = { 2, 2, 1 }
        if version == 1 then state.tokenLevel = nil end
        if version == 3 or version == 4 then state.attentionHeads = 1 end
        if version == 4 then state.layerSizes = nil;state.blockCount = 1;state.embDim = 2 end
        return state
    end
    local function storeFixture()
        local store = { values = {}, fail = false }
        function store:UpdateAsync(key, transform)
            if self.fail then error("simulated_network_failure") end
            local nextValue = transform(self.values[key])
            if nextValue == nil then return nil end
            self.values[key] = nextValue
            return nextValue
        end
        local time = { now = 1000 }
        local repository = Repository.new(store, State, B, function() return time.now end, 180)
        return repository, store, time
    end

    test("tutorial flag migrates schema16 strictly validates and survives copy prestige and save",function()
        local current=State.new(B);assert(current.tutorialDone==false)
        current.tutorialDone=true;current.credits=123;current.lifetimeEarned=1000
        assert(State.copy(current).tutorialDone and State.fromStored(current,B))
        local old=State.copy(current);old.schemaVersion=16;old.tutorialDone="ignored"
        local migrated=assert(State.fromStored(old,B));assert(not migrated.tutorialDone and migrated.credits==123 and old.tutorialDone=="ignored")
        for _,bad in ipairs({"yes",1,0/0,{}}) do
            local copy=State.copy(current);copy.tutorialDone=bad;assert(not State.fromStored(copy,B))
        end
        local copy=State.copy(current);copy.tutorialDone=nil;assert(not State.fromStored(copy,B))
        assert(modules.Prestige.ascend(current,B,State) and current.tutorialDone)
        local repo=storeFixture();local handle=assert(repo:acquire("User_1","a"))
        handle.state.tutorialDone=true;assert(repo:save(handle,true))
        assert(repo:acquire("User_1","b").state.tutorialDone)
    end)
    test("tutorial command accepts only bounded identity and never a client reward or status",function()
        assert(Protocol.validate("tutorial_complete",{requestId=1},B))
        for _,payload in ipairs({{requestId=0},{requestId=math.huge},{requestId=1,completed=true},{requestId=1,money=1},{requestId=1,step=3}}) do
            assert(not Protocol.validate("tutorial_complete",payload,B))
        end
    end)
    test("lease checks use the actual UpdateAsync transform time after storage delay",function()
        local repo,store,time=storeFixture();local handle=assert(repo:acquire("User_1","a"))
        local original=store.UpdateAsync
        function store:UpdateAsync(key,transform) time.now=1181;return original(self,key,transform) end
        local ok,reason=repo:save(handle,false);assert(not ok and reason=="lease_lost" and store.values.User_1.lock.expiresAt==1180)
        function store:UpdateAsync(key,transform) time.now=1400;return original(self,key,transform) end
        local nextHandle=assert(repo:acquire("User_1","b"));assert(nextHandle.expiresAt==1580)
    end)
    local function metricsFixture(studio)
        local f={now=100,events={},logs={},spawned=0,player={UserId=101},record={state=State.new(B)}}
        f.service=modules.Telemetry.new({state=State,balance=B,config={SEND_ANALYTICS=true,ANALYTICS_LOGS=true},published=true,studio=studio==true,
            clock=function() return f.now end,unix=function() return 1700000000+math.floor(f.now) end,
            spawn=function(callback) f.spawned=f.spawned+1;callback() end,
            log=function(report,reason) if f.logFailure then error("log unavailable") end;f.logs[#f.logs+1]={report=report,reason=reason} end,
            analytics={LogCustomEvent=function(_,player,name,value,fields)
                if f.nativeFailure then error("analytics unavailable") end
                assert(player==f.player);f.events[#f.events+1]={name=name,value=value,fields=fields}
            end}})
        f.service:begin(f.player,f.record,"test-session");return f
    end
    test("schema18 metrics migrate without invented history and strictly reject malformed counters maps and events",function()
        local profile=State.new(B);profile.analytics.sales=3;profile.analytics.upgradeLevels.upgrade_compute=5
        assert(State.fromStored(profile,B));local copy=State.copy(profile);copy.analytics.sales=9;assert(profile.analytics.sales==3)
        local wire=State.copy(profile,true);assert(wire.analytics==nil and not State.fromStored(wire,B) and State.fromSnapshot(wire,B))
        wire.credits=-1;assert(not State.fromSnapshot(wire,B))
        local old=State.copy(profile);old.schemaVersion=17;old.analytics="old-ignored";old.credits=123
        local parsed=assert(State.fromStored(old,B));assert(parsed.analytics.sales==0 and parsed.credits==123)
        for _,mutate in ipairs({function(s) s.analytics=nil end,function(s) s.analytics.sales=-1 end,
            function(s) s.analytics.onlineSeconds=1.5 end,function(s) s.analytics.moneyEarned=0/0 end,
            function(s) s.analytics.extra=1 end,function(s) s.analytics.upgradeLevels.price=1 end,
            function(s) s.analytics.robuxDelivered.unknown=1 end,function(s) s.analytics.recent={{event="shell"}} end,
            function(s) s.analytics.firstRobux={} end}) do
            local bad=State.copy(profile);mutate(bad);assert(not State.fromStored(bad,B))
        end
    end)
    test("analytics connected time uses server intervals once and sessions survive prestige and leased reload",function()
        local f=metricsFixture();local t,r=f.service,f.record
        f.now=100.7;t:settle(r);assert(r.state.analytics.onlineSeconds==0)
        f.now=102.3;t:settle(r);t:settle(r);assert(r.state.analytics.onlineSeconds==2)
        r.state.lifetimeEarned=1000;assert(modules.Prestige.ascend(r.state,B,State))
        assert(r.state.analytics.onlineSeconds==2 and r.state.analytics.sessions==1)
        t:finish(r);f.now=200;t:settle(r);assert(r.state.analytics.onlineSeconds==2)
        local repo=storeFixture();local handle=assert(repo:acquire("User_1","a"));handle.state=State.copy(r.state)
        assert(repo:save(handle,true));local nextHandle=assert(repo:acquire("User_1","b"))
        assert(nextHandle.state.analytics.onlineSeconds==2 and nextHandle.state.analytics.sessions==1)
    end)
    test("client analytics pulses are identity bounded estimates cannot pay or replay focus and clicks",function()
        local f=metricsFixture();local t,r=f.service,f.record;local before=State.copy(r.state)
        local p={requestId=1,button=4,enter=1,focused=true,page="CLI"}
        assert(Protocol.validate("analytics_pulse",p,B) and t:pulse(r,p))
        assert(not t:pulse(r,p));f.now=115;p.requestId=2;p.button=8;assert(t:pulse(r,p))
        assert(r.state.analytics.sellButtonReported==8 and r.state.analytics.sellEnterReported==1 and r.state.analytics.focusedSecondsReported==15)
        f.now=116;p.requestId=3;assert(not t:pulse(r,p))
        f.now=130;p.button=9999;assert(t:pulse(r,p) and r.state.analytics.sellButtonReported==128)
        f.now=200;p.requestId=4;assert(t:pulse(r,p) and r.state.analytics.focusedSecondsReported==30)
        assert(r.state.credits==before.credits and r.state.lifetimeEarned==before.lifetimeEarned and r.state.chips==before.chips)
        for _,key in ipairs({"money","userId","grade","time","amount"}) do
            p[key]=1;assert(not Protocol.validate("analytics_pulse",p,B));p[key]=nil
        end
        p.page="anything";assert(not Protocol.validate("analytics_pulse",p,B));p.page="CLI";p.button=math.huge;assert(not Protocol.validate("analytics_pulse",p,B))
    end)
    test("native analytics aggregate hot actions with fair bounded queues rate budget and contained failure",function()
        local f=metricsFixture();local t,r=f.service,f.record
        for _=1,1000 do t:action(r,"skillGood",1) end
        assert(f.spawned==0 and r.state.analytics.skillGood==1000 and r.telemetry.queued==1)
        for index=1,100 do t:queue(r,"CoreAction",1,"test"..index,"start") end
        assert(r.telemetry.queued==64 and r.telemetry.dropped==37)
        for second=1,60 do f.now=100+second;t:tick(r) end
        assert(#f.events<=12 and #f.events>0 and #f.logs==1)
        assert(f.events[1].name=="CoreAction" and f.events[1].value==1000 and f.events[1].fields.CustomField01=="skillGood")
        f.nativeFailure=true;f.logFailure=true
        for second=61,180 do f.now=100+second;t:tick(r) end
        assert(r.state.analytics.skillGood==1000 and not r.telemetry.busy and State.fromStored(r.state,B))
        local studio=metricsFixture(true);studio.service:action(studio.record,"sales",1);studio.now=161;studio.service:tick(studio.record)
        assert(#studio.events==0 and #studio.logs==1)
    end)
    test("analytics keep bounded premium timing context and deep copy first purchase across prestige",function()
        local f=metricsFixture();f.now=145
        f.service:commerce(f.record,"delivered","money_hour")
        local first=f.record.state.analytics.firstRobux
        assert(first.kind=="money_hour" and first.sessionSeconds==45 and first.onlineSeconds==45 and first.agents==1)
        for _=1,30 do f.service:event(f.record,"upgrade","upgrade_compute",1) end
        assert(#f.record.state.analytics.recent==24 and State.fromStored(f.record.state,B))
        local copy=State.copy(f.record.state);copy.analytics.firstRobux.kind="agent";assert(first.kind=="money_hour")
        f.record.state.lifetimeEarned=1000;assert(modules.Prestige.ascend(f.record.state,B,State))
        assert(f.record.state.analytics.firstRobux.sessionSeconds==45 and f.record.state.analytics.robuxDelivered.money_hour==1)
    end)
    test("fresh profiles do not share mutable layers or milestones", function()
        local a, b = State.new(B), State.new(B)
        a.layerSizes[2], a.milestones.joined = 8, true
        assert(b.layerSizes[2] == 2 and not b.milestones.joined)
    end)
    test("production begins after the first batch", function()
        assert(Sim.rate(State.new(B), B) == 0)
        assert(Sim.rate(active(), B) > 0)
    end)
    test("time integration is invariant under subdivision", function()
        local a, b = active(), active()
        Sim.advance(a, 100, B)
        for _ = 1, 100 do Sim.advance(b, 1, B) end
        near(a.credits, b.credits)
    end)
    test("invalid time never changes balances", function()
        local state = active()
        for _, seconds in ipairs({ -1, math.huge, 0 / 0, B.MAX_SIMULATION_STEP + 1 }) do
            assert(not Sim.advance(state, seconds, B))
            assert(state.credits == 0)
        end
    end)
    test("production saturates at the balance ceiling", function()
        local state = active(); state.credits = B.MAX_CREDITS - 0.1
        Sim.advance(state, 10, B)
        assert(state.credits == B.MAX_CREDITS)
    end)
    test("unaffordable purchase is atomic", function()
        local state = State.new(B)
        local ok, reason = Rules.purchase(state, "upgrade_workers", nil, B)
        assert(not ok and reason == "insufficient_credits")
        assert(state.credits == 0 and state.layerSizes[2] == 2)
    end)
    test("exact-price purchase grants once and debits exactly", function()
        local state = active(); state.credits = Rules.quote(state, "upgrade_workers", nil, B)
        assert(Rules.purchase(state, "upgrade_workers", nil, B))
        assert(state.credits == 0 and state.layerSizes[2] == 3)
        assert(not Rules.purchase(state, "upgrade_workers", nil, B))
    end)
    test("global worker purchases reject every client supplied target without charging", function()
        local state = funded(); local before = state.credits
        for _, layer in ipairs({ 1, 2, 3, 9, 1.5, 0 / 0, math.huge, { neurons = 16 } }) do
            assert(not Rules.purchase(state, "upgrade_workers", layer, B))
        end
        assert(state.credits == before)
    end)
    test("layer insertion preserves the input output and existing width", function()
        local state = funded(); local rate = Sim.rate(state, B)
        assert(Rules.purchase(state, "add_layer", nil, B))
        assert(#state.layerSizes == 4 and state.layerSizes[1] == B.EMBEDDING_DIM and state.layerSizes[2] == 2
            and state.layerSizes[3] == 2 and state.layerSizes[4] == 1)
        assert(Sim.rate(state, B) > rate)
    end)
    test("every successful upgrade increases production", function()
        for _, action in ipairs({ "upgrade_workers", "add_layer", "upgrade_compute" }) do
            local state = funded(); local before = Sim.rate(state, B)
            assert(Rules.purchase(state, action, nil, B))
            assert(Sim.rate(state, B) > before)
        end
    end)
    test("per-layer neuron limit rejects without charging", function()
        local state = funded(); state.layerSizes[2] = B.MAX_NEURONS_PER_LAYER
        local before = state.credits
        assert(not Rules.purchase(state, "upgrade_workers", nil, B))
        assert(state.credits == before)
    end)
    test("agent limit stays enforced while token value continues past the old level20 cap", function()
        local state = funded()
        state.credits=B.MAX_CREDITS
        while #state.layerSizes - 2 < B.MAX_HIDDEN_LAYERS do assert(Rules.purchase(state, "add_layer", nil, B)) end
        assert(not Rules.purchase(state, "add_layer", nil, B))
        state.computeLevel = B.LEGACY_MAX_COMPUTE_LEVEL
        assert(Rules.purchase(state, "upgrade_compute", nil, B) and state.computeLevel==21)
    end)
    test("unknown commands never mutate state", function()
        local state = funded(); local before = state.credits
        assert(not Rules.purchase(state, "give_money", nil, B))
        assert(state.credits == before)
    end)
    test("remote protocol rejects malformed and excessive payloads", function()
        assert(not Protocol.validate("upgrade_workers", nil, B))
        assert(Protocol.validate("sync", nil, B))
        assert(not Protocol.validate({}, 2, B))
        assert(not Protocol.validate(string.rep("x", 1000), nil, B))
        assert(not Protocol.validate("upgrade_workers", {}, B))
        assert(not Protocol.validate("upgrade_workers", 0 / 0, B))
        assert(not Protocol.validate("add_layer", { credits = 100000 }, B))
    end)
    test("token bucket limits bursts and refills", function()
        local bucket = Limiter.new(2, 3, 0)
        assert(Limiter.allow(bucket, 0));assert(Limiter.allow(bucket, 0));assert(Limiter.allow(bucket, 0))
        assert(not Limiter.allow(bucket, 0))
        assert(Limiter.allow(bucket, 0.5))
        assert(not Limiter.allow(bucket, 0.5))
        assert(not Limiter.allow(bucket, 0.4))
    end)
    test("persisted profiles reject NaN negative and newer schema", function()
        for _, credits in ipairs({ -1, math.huge, 0 / 0 }) do
            local state = State.new(B); state.credits = credits
            assert(not State.fromStored(state, B))
        end
        local state = State.new(B); state.schemaVersion = 999
        assert(not State.fromStored(state, B))
    end)
    test("persisted data is copied and unrecognized fields are removed", function()
        local state = active();state.admin = true;state.milestones.arbitrary = true
        local parsed = assert(State.fromStored(state, B))
        assert(parsed.admin == nil and parsed.milestones.arbitrary == nil)
        parsed.layerSizes[2], parsed.milestones.joined = 5, true
        assert(state.layerSizes[2] == 2 and not state.milestones.joined)
    end)
    test("profile lease blocks a second concurrent owner", function()
        local repo = storeFixture()
        assert(repo:acquire("User_1", "server_a"))
        local handle, reason = repo:acquire("User_1", "server_b")
        assert(handle == nil and reason == "profile_busy")
    end)
    test("released profiles preserve credits on reacquire", function()
        local repo = storeFixture()
        local handle = assert(repo:acquire("User_1", "server_a"));handle.state.credits = 321
        assert(repo:save(handle, true))
        local nextHandle = assert(repo:acquire("User_1", "server_b"))
        assert(nextHandle.state.credits == 321)
    end)
    test("expired owner cannot overwrite the new session", function()
        local repo, _, time = storeFixture()
        local old = assert(repo:acquire("User_1", "server_a"))
        time.now = time.now + 181
        local current = assert(repo:acquire("User_1", "server_b"));current.state.credits = 456
        assert(repo:save(current, false))
        old.state.credits = 999
        local ok, reason = repo:save(old, false)
        assert(not ok and reason == "lease_lost")
        assert(repo.store.values.User_1.data.credits == 456)
    end)
    test("lease refresh extends ownership", function()
        local repo, _, time = storeFixture()
        local handle = assert(repo:acquire("User_1", "a"));local expiry = handle.expiresAt
        time.now = time.now + 60
        assert(repo:save(handle, false))
        assert(handle.expiresAt == expiry + 60)
    end)
    test("network failure never creates a replacement profile", function()
        local repo, store = storeFixture()
        local handle = assert(repo:acquire("User_1", "a"));handle.state.credits = 123
        assert(repo:save(handle, true))
        store.fail = true
        local result, reason = repo:acquire("User_1", "b")
        assert(result == nil and reason == "storage_error")
        assert(store.values.User_1.data.credits == 123)
    end)
    test("corrupted persisted record is not silently reset", function()
        local repo, store = storeFixture()
        store.values.User_1 = { schemaVersion = 1, data = { credits = -50 } }
        assert(not repo:acquire("User_1", "a"))
        assert(store.values.User_1.data.credits == -50)
    end)
    test("long deterministic purchase sequence preserves invariants", function()
        local state = active()
        for step = 1, 2000 do
            Sim.advance(state, 0.5, B)
            local actions = { "upgrade_workers", "upgrade_compute", "add_layer" }
            Rules.purchase(state, actions[step % 3 + 1], nil, B)
            assert(State.fromStored(state, B))
            assert(state.credits >= 0 and state.credits <= B.MAX_CREDITS)
        end
    end)
    test("every hidden layer can reach neuron and layer limits with exact debits", function()
        local state = funded()
        assert(B.MAX_HIDDEN_LAYERS == 8 and B.MAX_NEURONS_PER_LAYER == 16)
        assert(Rules.quote(state, "upgrade_workers", nil, B) == 1)
        while #state.layerSizes - 2 < B.MAX_HIDDEN_LAYERS do
            state.credits = B.MAX_CREDITS
            assert(Rules.purchase(state, "add_layer", nil, B))
        end
        while Rules.workersPerAgent(state) < B.MAX_NEURONS_PER_LAYER do
            local workers = Rules.workersPerAgent(state)
            local cost = Rules.quote(state, "upgrade_workers", nil, B)
            assert(State.isFinite(cost) and cost <= B.MAX_CREDITS)
            state.credits = cost
            assert(Rules.purchase(state, "upgrade_workers", nil, B))
            assert(state.credits == 0 and State.fromStored(state, B))
            for layer = 2, #state.layerSizes - 1 do assert(state.layerSizes[layer] == workers + 1) end
        end
        state.credits = 123
        assert(not Rules.purchase(state, "upgrade_workers", nil, B) and state.credits == 123)
        assert(#state.layerSizes == 10 and state.layerSizes[9] == 16)
        assert(not Rules.purchase(state, "add_layer", nil, B) and state.credits == 123)
    end)
    test("expanded profiles round-trip and still refuse out-of-range topology", function()
        local state = active()
        state.layerSizes = { B.EMBEDDING_DIM, 16, 16, 16, 16, 16, 16, 16, 16, 1 }
        local parsed = assert(State.fromStored(state, B))
        assert(#parsed.layerSizes == 10 and parsed.layerSizes[9] == 16)
        state.layerSizes[9] = 17
        assert(not State.fromStored(state, B) and parsed.layerSizes[9] == 16)
        state.layerSizes = { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1 }
        assert(not State.fromStored(state, B))
    end)
    test("global worker protocol is payload free and removes targeted purchases", function()
        assert(not Protocol.validate("upgrade_workers", nil, B))
        assert(not Protocol.validate("add_neuron", nil, B) and not Protocol.validate("add_neuron", 2, B))
        for _, value in ipairs({ 1, 2, 9, 10, 9.5, -1, math.huge, "2", { neurons = 16 } }) do
            assert(not Protocol.validate("upgrade_workers", value, B))
        end
        local state = funded(); local credits = state.credits
        assert(not Rules.purchase(state, "upgrade_workers", 2, B) and state.credits == credits)
        assert(not Rules.purchase(state, "add_neuron", 2, B) and state.credits == credits)
    end)
    test("fixed graph canvas contains every neuron without shrinking at any capacity", function()
        for _, viewport in ipairs({ { 344, 244 }, { 768, 394 }, { 624, 90 }, { 1600, 900 } }) do
            local layers = { 2, 16, 16, 16, 16, 16, 16, 16, 16, 1 }
            local fit, initial = Layout.fit(layers, viewport[1], viewport[2]), Layout.fit({ 2, 2, 1 }, viewport[1], viewport[2])
            assert(fit.scale == 1 and initial.scale == 1)
            assert(fit.canvasWidth >= viewport[1] and fit.canvasHeight >= viewport[2])
            for _, points in ipairs(fit.positions) do
                for index, point in ipairs(points) do
                    local x, y = fit.offsetX + point.x, fit.offsetY + point.y
                    assert(x >= 9 and x <= fit.canvasWidth - 9 and y >= 9 and y <= fit.canvasHeight - 9)
                    if index > 1 then near(point.y - points[index - 1].y, 40) end
                end
            end
        end
    end)
    test("sampled connections are deterministic unique bounded and cover every endpoint", function()
        local layers = { 2, 16, 16, 16, 16, 16, 16, 16, 16, 1 }
        local a, b, seen, covered = Layout.edges(layers), Layout.edges(layers), {}, {}
        assert(#a <= Layout.MAX_EDGES and #a == #b)
        for index, edge in ipairs(a) do
            local key = edge.layer .. ":" .. edge.from .. ":" .. edge.to
            assert(not seen[key]);seen[key] = true
            assert(edge.layer == b[index].layer and edge.from == b[index].from and edge.to == b[index].to)
            covered[edge.layer .. ":from:" .. edge.from], covered[edge.layer .. ":to:" .. edge.to] = true, true
        end
        for layer = 1, #layers - 1 do
            for node = 1, layers[layer] do assert(covered[layer .. ":from:" .. node]) end
            for node = 1, layers[layer + 1] do assert(covered[layer .. ":to:" .. node]) end
        end
        assert(#Layout.edges({ 2, 2, 1 }) == 6)
    end)
    test("full expanded production is finite and still saturates at the credit ceiling", function()
        local state = active()
        state.layerSizes = { B.EMBEDDING_DIM, 16, 16, 16, 16, 16, 16, 16, 16, 1 }
        state.computeLevel = B.LEGACY_MAX_COMPUTE_LEVEL
        assert(Sim.capacity(state) == 128 and State.isFinite(Sim.rate(state, B)))
        state.credits = B.MAX_CREDITS - 1
        assert(Sim.advance(state, 1, B) and state.credits == B.MAX_CREDITS)
        assert(State.fromStored(state, B))
    end)
    test("prompt words are deterministic bounded and counted as game tokens", function()
        assert(Prompt.text(5, B) == "build a responsive dashboard with")
        assert(Prompt.text(0, B) == "" and not Prompt.text(-1, B))
        assert(not Prompt.text(0 / 0, B) and not Prompt.text(129, B))
        local text = Prompt.text(B.PROMPT_MAX_TOKENS, B)
        assert(#text <= B.PROMPT_MAX_BYTES and text == Prompt.text(64, B))
        assert(Prompt.validate(text, 64, B) == 64)
    end)
    test("manual prompt protocol accepts only a bounded server draft ID and token count", function()
        assert(Protocol.validate("submit_prompt", {draftId=1,tokens=8}, B))
        assert(Protocol.validate("upgrade_tokens", nil, B))
        for _, value in ipairs({ {}, 8, string.rep("x", B.PROMPT_MAX_BYTES + 1), "" }) do
            assert(not Protocol.validate("submit_prompt", value, B))
        end
        assert(not Protocol.validate("process_batch", nil, B))
        assert(not Protocol.validate("upgrade_tokens", { credits = 10, tokenLimit = 128 }, B))
    end)
    test("accepted prompt grants confirmed tokens once and activates production", function()
        local state = State.new(B)
        local ok, receipt = submit(state, Prompt.text(8, B), 10, -math.huge, B, Sim)
        assert(ok and receipt.tokens == 8 and receipt.reward == 8)
        assert(state.credits == 8 and state.batches == 1 and Sim.rate(state, B) > 0)
        state.credits = B.MAX_CREDITS - 0.5
        ok, receipt = submit(state, Prompt.text(8, B), 11, 10, B, Sim)
        assert(ok and receipt.reward == 0.5 and state.credits == B.MAX_CREDITS)
    end)
    test("invalid or over-cap prompts never grant credits or start production", function()
        for _, text in ipairs({ "", "   ", "untrusted player input", "build  a", Prompt.text(9, B),
            string.rep("x", B.PROMPT_MAX_BYTES + 1) }) do
            local state = State.new(B)
            assert(not submit(state, text, 10, -math.huge, B, Sim))
            assert(state.credits == 0 and state.batches == 0)
        end
    end)
    test("prompt cooldown rejects rapid repeated and backwards-time requests", function()
        local state = State.new(B)
        local text = Prompt.text(1, B)
        assert(submit(state, text, 10, -math.huge, B, Sim))
        for _, now in ipairs({ 10, 10.01, 9, 0 / 0, math.huge }) do
            assert(not submit(state, text, now, 10, B, Sim))
            assert(state.credits == 1 and state.batches == 1)
        end
        assert(submit(state, text, 11, 10, B, Sim))
        assert(state.credits == 2 and state.batches == 2)
    end)
    test("token upgrades debit atomically extend prompts and enforce the 64-token cap", function()
        local state = State.new(B)
        assert(Prompt.limit(state, B) == 8)
        assert(not Rules.purchase(state, "upgrade_tokens", nil, B) and state.tokenLevel == 0)
        for level = 1, B.MAX_TOKEN_LEVEL do
            state.credits = Rules.quote(state, "upgrade_tokens", nil, B)
            assert(Rules.purchase(state, "upgrade_tokens", nil, B))
            assert(state.credits == 0 and state.tokenLevel == level)
            assert(Prompt.limit(state, B) == 8 + level * 8)
        end
        state.credits = 123
        assert(not Rules.purchase(state, "upgrade_tokens", nil, B) and state.credits == 123)
        assert(submit(state, Prompt.text(64, B), 10, -math.huge, B, Sim))
        assert(State.fromStored(state, B))
    end)
    test("test-scaled prices stay positive and old baseline remains capped", function()
        local state, baseline = active(), {}
        for key, value in pairs(B) do baseline[key] = value end
        baseline.UPGRADE_COST_MULTIPLIER, baseline.UPGRADE_GROWTH_MULTIPLIER = 1, 1
        local expected = { upgrade_workers = 1, add_layer = 2000, upgrade_compute = 10, upgrade_tokens = 100 }
        for action, price in pairs(expected) do
            assert(Rules.quote(state, action, nil, B) == price)
            assert(price <= Rules.quote(state, action, nil, baseline))
        end
        state.layerSizes = { 2, 16, 16, 16, 16, 16, 16, 16, 15, 1 }
        local cost = Rules.quote(state, "upgrade_workers", nil, B)
        assert(cost >= 1 and cost < 1000000000 and cost % 1 == 0)
        baseline.NEURON_BASE_COST = B.MAX_CREDITS
        assert(Rules.quote(state, "upgrade_workers", nil, baseline) == B.MAX_CREDITS)
    end)
    test("schema-1 migration preserves validated progression and adds token level zero", function()
        local old = legacy(1)
        old.credits, old.computeLevel, old.batches, old.milestones.first_neuron = 123, 3, 45, true
        local parsed = assert(State.fromStored(old, B))
        assert(parsed.schemaVersion == B.SCHEMA_VERSION and parsed.tokenLevel == 0 and parsed.attentionHeads == nil)
        assert(parsed.credits == 123 and parsed.computeLevel == 3 and parsed.batches == 45)
        assert(parsed.milestones.first_neuron and old.schemaVersion == 1 and old.tokenLevel == nil)
        old.credits = -1
        assert(not State.fromStored(old, B))
    end)
    test("legacy repository migration respects leases and saves token upgrades", function()
        local repo, store, time = storeFixture()
        local old = legacy(1);old.credits = 456
        store.values.User_1 = { schemaVersion = 1, data = old, lock = { owner = "other", expiresAt = time.now + 5 } }
        local handle, reason = repo:acquire("User_1", "new")
        assert(not handle and reason == "profile_busy" and store.values.User_1.schemaVersion == 1)
        time.now = time.now + 6
        handle = assert(repo:acquire("User_1", "new"))
        assert(handle.state.credits == 456 and handle.state.tokenLevel == 0
            and store.values.User_1.schemaVersion == B.SCHEMA_VERSION)
        handle.state.tokenLevel = 5
        assert(repo:save(handle, true))
        assert(repo:acquire("User_1", "third").state.tokenLevel == 5)
    end)
    test("token corruption future and mismatched records fail safely", function()
        local state = active()
        for _, level in ipairs({ -1, 0 / 0, 1.5, B.MAX_TOKEN_LEVEL + 1 }) do
            state.tokenLevel = level
            assert(not State.fromStored(state, B))
        end
        state.tokenLevel = nil
        assert(not State.fromStored(state, B))
        local repo, store = storeFixture()
        store.values.User_1 = { schemaVersion = B.SCHEMA_VERSION + 1, data = State.new(B) }
        assert(not repo:acquire("User_1", "owner") and store.values.User_1.schemaVersion == B.SCHEMA_VERSION + 1)
        store.values.User_1 = { schemaVersion = 2, data = { schemaVersion = 1 } }
        assert(not repo:acquire("User_1", "owner") and store.values.User_1.data.schemaVersion == 1)
    end)
    test("prompt receipts deduplicate and do not erase a newer draft", function()
        local restored = Draft.new()
        assert(not Draft.confirm(restored, { id = 7 }, true))
        assert(not Draft.confirm(restored, { id = 7 }))
        local draft = Draft.new()
        Draft.setCount(draft, 3, 8);Draft.submitted(draft)
        Draft.setCount(draft, 4, 8)
        assert(Draft.confirm(draft, { id = 1 }) and draft.tokens == 4)
        assert(not Draft.confirm(draft, { id = 1 }) and draft.tokens == 4)
        Draft.submitted(draft)
        assert(Draft.confirm(draft, { id = 2 }) and draft.tokens == 0)
        assert(not Draft.confirm(draft, { id = 1 }) and not Draft.confirm(draft, nil))
    end)
    test("snapshot cap changes preserve drafts and profiles never retain prompt content", function()
        local draft = Draft.new()
        Draft.setCount(draft, 8, 8)
        Draft.setCount(draft, draft.tokens, 16)
        assert(draft.tokens == 8)
        Draft.setCount(draft, 16, 16)
        Draft.setCount(draft, draft.tokens, 8)
        assert(draft.tokens == 8)
        local state = active();state.tokenLevel = 4;state.promptText = "private";state.lastPrompt = { id = 1 }
        local copied, parsed = State.copy(state), assert(State.fromStored(state, B))
        assert(copied.tokenLevel == 4 and parsed.tokenLevel == 4)
        assert(copied.promptText == nil and copied.lastPrompt == nil and parsed.promptText == nil and parsed.lastPrompt == nil)
    end)
    test("fresh neural profile has the original topology income and no Transformer state", function()
        local state = active()
        assert(#state.layerSizes == 3 and state.layerSizes[1] == B.EMBEDDING_DIM and state.layerSizes[2] == 2 and state.layerSizes[3] == 1)
        near(Sim.rate(state, B), 2 * B.CREDITS_PER_NEURON_SECOND)
        assert(Sim.batchReward(state) == 1 and state.attentionHeads == nil and state.embDim == nil and state.blockCount == nil)
    end)
    test("removed Transformer commands reject every payload and never mutate neural state", function()
        local state = funded();local credits = state.credits
        for _, action in ipairs({ "add_head", "upgrade_emb_dim" }) do
            assert(not Protocol.validate(action, nil, B))
            assert(not Rules.purchase(state, action, nil, B))
            for _, value in ipairs({ 2, "2", true, { heads = 8, embDim = 16 }, 0 / 0 }) do
                assert(not Protocol.validate(action, value, B))
            end
        end
        assert(state.credits == credits and state.layerSizes[2] == 2)
    end)
    test("schema-2 migration keeps uneven widths tokens and milestones without mutating its source", function()
        local old = legacy(2)
        old.layerSizes = { 2, 16, 5, 1 }
        old.credits, old.computeLevel, old.tokenLevel, old.batches = 987, 4, 7, 32
        old.milestones.first_layer = true
        local parsed = assert(State.fromStored(old, B))
        assert(parsed.schemaVersion == B.SCHEMA_VERSION and parsed.tokenLevel == 7)
        assert(parsed.credits == 987 and parsed.computeLevel == 4 and parsed.batches == 32)
        assert(parsed.layerSizes[2] == 16 and parsed.layerSizes[3] == 5 and parsed.milestones.first_layer)
        parsed.layerSizes[2] = 3
        assert(old.layerSizes[2] == 16 and old.schemaVersion == 2)
        old.tokenLevel = nil
        assert(not State.fromStored(old, B))
    end)
    test("schema-2 lease prevents conversion until available and neuron upgrades round-trip", function()
        local repo, store, time = storeFixture()
        local old = legacy(2);old.tokenLevel = 6
        store.values.User_1 = { schemaVersion = 2, data = old, lock = { owner = "old", expiresAt = time.now + 5 } }
        local handle, reason = repo:acquire("User_1", "new")
        assert(not handle and reason == "profile_busy" and store.values.User_1.schemaVersion == 2)
        time.now = time.now + 6
        handle = assert(repo:acquire("User_1", "new"))
        assert(handle.state.tokenLevel == 6 and handle.state.attentionHeads == nil)
        assert(Rules.purchase(handle.state, "upgrade_workers", nil, B) and repo:save(handle, true))
        local restored = assert(repo:acquire("User_1", "third"))
        assert(restored.state.layerSizes[2] == 3 and restored.state.tokenLevel == 6)
        assert(store.values.User_1.schemaVersion == B.SCHEMA_VERSION)
    end)
    test("legacy corrupt or missing heads refuse conversion instead of granting a refund", function()
        for version = 3, 4 do
            local repo, store = storeFixture()
            for _, heads in ipairs({ 0, -1, 1.5, 9, math.huge, 0 / 0, "2", false }) do
                local state = legacy(version);state.attentionHeads = heads
                local parsed, reason = State.fromStored(state, B)
                assert(not parsed and reason == "invalid_attention_heads")
                store.values.User_1 = { schemaVersion = version, data = state }
                assert(not repo:acquire("User_1", "owner") and store.values.User_1.data == state)
            end
            local state = legacy(version);state.attentionHeads = nil
            assert(not State.fromStored(state, B))
        end
    end)
    test("accepted prompts retain output reward metadata including token and credit caps", function()
        local state = active();state.tokenLevel = B.MAX_TOKEN_LEVEL
        for _, count in ipairs({ 1, 8, 18, 19, 20, 64 }) do
            local ok, receipt = submit(state, Prompt.text(count, B), count, -math.huge, B, Sim)
            assert(ok and receipt.tokens == count and receipt.outputToken == B.OUTPUT_TOKENS[1].word and #receipt.outputs == count)
        end
        assert(Prompt.nextWord(1) == "a" and Prompt.nextWord(Prompt.VOCABULARY_SIZE) == "build")
        assert(Prompt.nextWord(Prompt.VOCABULARY_SIZE + 1) == "a" and Prompt.nextWord(19) == "signal")
        local before = State.copy(state)
        assert(not submit(state, "arbitrary prompt", 1000, -math.huge, B, Sim))
        assert(state.credits == before.credits and state.batches == before.batches)
        assert(State.copy(state).outputToken == nil and State.copy(state).lastPrompt == nil)
    end)
    test("legacy head refunds use frozen prices once and saturate at the existing ceiling", function()
        local refunds = { 0, 4, 8, 13, 18, 24, 31, 39 }
        for version = 3, 4 do
            for heads = 1, 8 do
                local old = legacy(version);old.credits = 100;old.attentionHeads = heads
                local parsed = assert(State.fromStored(old, B))
                assert(parsed.credits == 100 + refunds[heads] and old.credits == 100)
                assert(parsed.attentionHeads == nil)
                local again = assert(State.fromStored(parsed, B))
                assert(again.credits == parsed.credits)
                local changed = {};for key, value in pairs(B) do changed[key] = value end
                changed.UPGRADE_COST_MULTIPLIER, changed.UPGRADE_GROWTH_MULTIPLIER = 1, 1
                assert(State.fromStored(old, changed).credits == parsed.credits)
            end
            local old = legacy(version);old.credits = B.MAX_CREDITS - 0.5;old.attentionHeads = 8
            assert(State.fromStored(old, B).credits == B.MAX_CREDITS)
        end
    end)
    test("full neural topology keeps prompt rewards finite and actual credited amounts capped", function()
        local state = funded()
        state.layerSizes = { B.EMBEDDING_DIM, 16, 16, 16, 16, 16, 16, 16, 16, 1 }
        state.computeLevel = B.LEGACY_MAX_COMPUTE_LEVEL
        assert(State.isFinite(Sim.rate(state, B)) and State.isFinite(Sim.batchReward(state)))
        assert(State.fromStored(state, B) and #State.copy(state).layerSizes == 10)
        state.credits = B.MAX_CREDITS - 0.5
        local ok, receipt = submit(state, Prompt.text(8, B), 10, -math.huge, B, Sim)
        assert(ok and receipt.reward == 0.5 and state.credits == B.MAX_CREDITS)
    end)
    test("global workers upgrade every agent and new agents inherit the worker level", function()
        local state = funded();state.layerSizes[2] = 8
        assert(Rules.purchase(state, "add_layer", nil, B))
        assert(state.layerSizes[2] == 8 and state.layerSizes[3] == 8)
        assert(Rules.purchase(state, "upgrade_workers", nil, B))
        assert(state.layerSizes[2] == 9 and state.layerSizes[3] == 9)
        assert(Rules.purchase(state, "upgrade_workers", nil, B))
        assert(state.layerSizes[2] == 10 and state.layerSizes[3] == 10)
    end)
    test("global worker upgrades charge once atomically for every agent and do not scale price with team size", function()
        local single, team = funded(), funded()
        team.credits=B.MAX_CREDITS
        for _=2,B.MAX_HIDDEN_LAYERS do assert(Rules.purchase(team,"add_layer",nil,B)) end
        local cost = Rules.quote(team,"upgrade_workers",nil,B)
        assert(cost == Rules.quote(single,"upgrade_workers",nil,B))
        team.credits = cost - 0.01
        assert(not Rules.purchase(team,"upgrade_workers",nil,B))
        for index=2,#team.layerSizes-1 do assert(team.layerSizes[index]==2) end
        near(team.credits,cost-0.01)
        team.credits = cost
        assert(Rules.purchase(team,"upgrade_workers",nil,B) and team.credits==0)
        for index=2,#team.layerSizes-1 do assert(team.layerSizes[index]==3) end
        assert(team.layerSizes[1]==B.EMBEDDING_DIM and team.layerSizes[#team.layerSizes]==1)
        assert(not Rules.purchase(team,"upgrade_workers",nil,B))
    end)
    test("global upgrades converge historical uneven workers without downgrades overflow or profile resets", function()
        local state = funded()
        state.layerSizes={B.EMBEDDING_DIM,2,9,16,1}
        local parsed=assert(State.fromStored(state,B))
        assert(Rules.workersPerAgent(parsed)==2 and parsed.layerSizes[4]==16)
        assert(Rules.purchase(parsed,"upgrade_workers",nil,B))
        assert(parsed.layerSizes[2]==3 and parsed.layerSizes[3]==10 and parsed.layerSizes[4]==16)
        assert(state.layerSizes[2]==2 and state.layerSizes[3]==9)
        assert(Rules.purchase(parsed,"add_layer",nil,B))
        assert(parsed.layerSizes[#parsed.layerSizes-1]==3)
        while Rules.workersPerAgent(parsed)<16 do assert(Rules.purchase(parsed,"upgrade_workers",nil,B)) end
        local credits=parsed.credits
        assert(not Rules.purchase(parsed,"upgrade_workers",nil,B) and parsed.credits==credits)
        for index=2,#parsed.layerSizes-1 do assert(parsed.layerSizes[index]==16) end
        assert(State.fromStored(State.copy(parsed),B))
    end)
    test("schema-3 conversion preserves uneven widths progression and refunds removed heads", function()
        local old = legacy(3)
        old.layerSizes, old.attentionHeads, old.tokenLevel = { 2, 3, 16, 5, 1 }, 7, 11
        local parsed = assert(State.fromStored(old, B))
        assert(parsed.schemaVersion == B.SCHEMA_VERSION and #parsed.layerSizes == 5)
        assert(parsed.layerSizes[2] == 3 and parsed.layerSizes[3] == 16 and parsed.layerSizes[4] == 5)
        assert(parsed.tokenLevel == 7 and parsed.credits == old.credits + 48 and Sim.capacity(parsed) == 24)
        assert(parsed.attentionHeads == nil and old.attentionHeads == 7)
    end)
    test("all layered schemas validate dense arrays endpoints and every width before loading", function()
        for _, version in ipairs({ 1, 2, 3, 5 }) do
            for _, layers in ipairs({ { 3, 2, 1 }, { 2, 2, 2 }, { 2, 17, 1 }, { 2, 0, 1 },
                { 2, 2.5, 1 }, { 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1 } }) do
                local old = legacy(version);old.layerSizes = layers
                assert(not State.fromStored(old, B))
            end
            local old = legacy(version);old.layerSizes.extra = 2
            assert(not State.fromStored(old, B))
            old.layerSizes = { [1] = 2, [3] = 1 }
            assert(not State.fromStored(old, B))
        end
    end)
    test("schema-4 conversion validates global fields and expands all purchased blocks", function()
        for _, field in ipairs({ "embDim", "blockCount" }) do
            local high = field == "embDim" and 16 or 8
            for _, value in ipairs({ 0, -1, 1.5, high + 1, math.huge, 0 / 0, "2", false }) do
                local state = legacy(4);state[field] = value
                assert(not State.fromStored(state, B))
            end
            local state = legacy(4);state[field] = nil
            assert(not State.fromStored(state, B))
        end
        local old = legacy(4);old.embDim = 1
        assert(not State.fromStored(old, B))
        old.embDim, old.blockCount, old.attentionHeads = 16, 8, 8
        local parsed = assert(State.fromStored(old, B))
        assert(#parsed.layerSizes == 10 and parsed.layerSizes[1] == B.EMBEDDING_DIM and parsed.layerSizes[10] == 1)
        for index = 2, 9 do assert(parsed.layerSizes[index] == 16) end
        assert(old.layerSizes == nil and parsed.blockCount == nil and parsed.embDim == nil)
    end)
    test("current schema strips obsolete fields and cannot claim a legacy refund or missing topology", function()
        local state = active();state.credits = 123
        state.attentionHeads, state.embDim, state.blockCount = 8, 16, 8
        local parsed = assert(State.fromStored(state, B))
        assert(parsed.credits == 123 and parsed.attentionHeads == nil and parsed.embDim == nil and parsed.blockCount == nil)
        local copied = State.copy(state)
        assert(copied.credits == 123 and copied.attentionHeads == nil and copied.embDim == nil and copied.blockCount == nil)
        state.layerSizes = nil
        assert(not State.fromStored(state, B))
    end)
    test("Transformer leases remain untouched until available and refunds survive save exactly once", function()
        for version = 3, 4 do
            local repo, store, time = storeFixture()
            local old = legacy(version);old.attentionHeads = 5;old.credits = 123
            if version == 3 then old.layerSizes = { 2, 9, 3, 1 }
            else old.blockCount, old.embDim = 2, 9 end
            store.values.User_1 = { schemaVersion = version, data = old, lock = { owner = "other", expiresAt = time.now + 5 } }
            local handle, reason = repo:acquire("User_1", "new")
            assert(not handle and reason == "profile_busy" and store.values.User_1.data == old and old.credits == 123)
            time.now = time.now + 6
            handle = assert(repo:acquire("User_1", "new"))
            assert(handle.state.credits == 141 and handle.state.layerSizes[2] == 9)
            assert(handle.state.layerSizes[3] == (version == 3 and 3 or 9))
            local cost = Rules.quote(handle.state, "upgrade_workers", nil, B)
            assert(Rules.purchase(handle.state, "upgrade_workers", nil, B) and repo:save(handle, true))
            local restored = assert(repo:acquire("User_1", "third"))
            assert(restored.state.credits == 141 - cost and restored.state.attentionHeads == nil)
            assert(restored.state.layerSizes[3] == (version == 3 and 4 or 10))
        end
    end)
    test("visual token IDs are stable distinct for the fixed vocabulary and vectors are bounded", function()
        local ids = {}
        for index = 1, Prompt.VOCABULARY_SIZE do
            local word = Prompt.nextWord(index - 1)
            local a, b = Flow.token(word, Prompt, B.EMBEDDING_DIM), Flow.token(string.lower(word), Prompt, B.EMBEDDING_DIM)
            assert(a.word == word and a.id == b.id and a.id == index and not ids[a.id])
            ids[a.id] = true
            assert(#a.vector == B.EMBEDDING_DIM)
            for dim, value in ipairs(a.vector) do
                assert(value >= -1 and value <= 1 and value == b.vector[dim])
            end
        end
        assert(Flow.token(Prompt.nextWord(0), Prompt, B.EMBEDDING_DIM).id == Flow.token(Prompt.nextWord(Prompt.VOCABULARY_SIZE), Prompt, B.EMBEDDING_DIM).id)
        assert(not Flow.token("not a vocabulary token", Prompt, B.EMBEDDING_DIM) and not Prompt.tokenId({}))
    end)
    test("flow preview is canonical and bounded regardless of the accepted token count", function()
        for count = 0, B.PROMPT_MAX_TOKENS do
            local preview = assert(Flow.preview(count, Prompt, B))
            assert(preview.count == count and #preview.tokens == math.min(count, Flow.MAX_PACKETS))
            assert(#preview.text <= #Prompt.text(6, B) + 4)
            for index, token in ipairs(preview.tokens) do assert(token.word == Prompt.nextWord(index - 1)) end
        end
        assert(Flow.preview(0, Prompt, B).text == "")
        for _, value in ipairs({ -1, 129, 1.5, math.huge, 0 / 0, "8", {} }) do
            assert(not Flow.preview(value, Prompt, B))
        end
    end)
    test("flow baseline and repeated receipts never replay and bursts preserve traveling packets", function()
        local state = Flow.new()
        local receipt = { id = 4, tokens = 8, reward = 8 }
        assert(not Flow.accept(state, receipt, true) and not state.active)
        assert(not Flow.accept(state, receipt, false))
        assert(Flow.accept(state, { id = 5, tokens = 3 }, false) and state.active)
        Flow.tick(state, 0.5, true, false)
        assert(not Flow.accept(state, { id = 5, tokens = 3 }, false) and state.elapsed == 0.5)
        assert(not Flow.accept(state, { id = 3, tokens = 3 }, false) and state.elapsed == 0.5)
        for id = 6, 1000 do
            assert(Flow.accept(state, { id = id, tokens = 128 }, false) and state.elapsed == 0.5)
        end
        assert(state.lastReceipt == 1000 and state.tokens == 128 and state.queue == nil and receipt.id == 4)
        for _, bad in ipairs({ {}, { id = 1001, tokens = 129 }, { id = 1001.5, tokens = 3 },
            { id = 1001, tokens = 0 / 0 }, { id = math.huge, tokens = 2 } }) do
            assert(not Flow.accept(state, bad, false) and state.lastReceipt == 1000)
        end
    end)
    test("manual packet timing is staggered bounded and invariant under time subdivision", function()
        local a, b = Flow.new(), Flow.new()
        assert(Flow.accept(a, { id = 1, tokens = 128 }, false))
        assert(Flow.accept(b, { id = 1, tokens = 128 }, false))
        assert(Flow.progress(a, 1, false) == 0 and not Flow.progress(a, 2, false))
        assert(not Flow.progress(a, Flow.MAX_PACKETS + 1, false))
        Flow.tick(a, 1, true, false)
        for _ = 1, 10 do Flow.tick(b, 0.1, true, false) end
        near(a.elapsed, b.elapsed)
        near(Flow.progress(a, 4, false), Flow.progress(b, 4, false))
        near(Flow.span(a), Flow.DURATION + (Flow.MAX_PACKETS - 1) * Flow.STAGGER)
        assert(Flow.tick(a, Flow.span(a), true, false) and not a.active)
        assert(not Flow.progress(a, 1, false))
        local elapsed = b.elapsed
        for _, dt in ipairs({ -1, 0 / 0, math.huge }) do assert(not Flow.tick(b, dt, true, false) and b.elapsed == elapsed) end
    end)
    test("reduced motion paused production and resets end travel while retaining receipt watermark", function()
        local state = Flow.new()
        assert(Flow.accept(state, { id = 7, tokens = 8 }, false))
        assert(Flow.tick(state, 0, true, true) and not state.active)
        assert(not Flow.tick(state, 1, true, true) and state.clock == 0)
        assert(Flow.accept(state, { id = 8, tokens = 3 }, false))
        assert(Flow.tick(state, 1, false, false) and not state.active and state.clock == 0)
        Flow.reset(state)
        assert(state.lastReceipt == 8 and state.tokens == 0 and not state.active)
        assert(not Flow.accept(state, { id = 8, tokens = 3 }, false))
        assert(Flow.accept(state, { id = 9, tokens = 1 }, false))
    end)
    test("uniform routes select the full neuron range in every layer independently", function()
        local layers = { 4, 16, 7, 1 }
        for pick = 1, 16 do
            local calls = 0
            local route = Flow.route(layers, function(low, high)
                calls = calls + 1
                assert(low == 1 and high == layers[calls])
                return (pick - 1) % high + 1
            end)
            assert(calls == #layers)
            for layer, node in ipairs(route) do assert(node == (pick - 1) % layers[layer] + 1) end
        end
    end)
    test("packet interpolation explains all preprocessing stages continuously and stays on its segments", function()
        local anchors = { { x = 10, y = 10 }, { x = 50, y = 10 }, { x = 90, y = 10 } }
        local points = { { x = 10, y = 80 }, { x = 80, y = 120 }, { x = 150, y = 80 } }
        local boundaries = { { 0, anchors[1] }, { 0.16, anchors[2] }, { 0.32, anchors[3] }, { 0.45, points[1] }, { 1, points[3] } }
        for _, boundary in ipairs(boundaries) do
            local p = Flow.position(anchors, points, boundary[1])
            near(p.x, boundary[2].x);near(p.y, boundary[2].y)
            if boundary[1] > 0 then
                local before = Flow.position(anchors, points, boundary[1] - 0.000001)
                assert(math.abs(before.x - p.x) < 0.01 and math.abs(before.y - p.y) < 0.01)
            end
        end
        for step = 0, 1000 do
            local p = Flow.position(anchors, points, step / 1000)
            assert(p.x >= 10 and p.x <= 150 and p.y >= 10 and p.y <= 120)
            assert(p.stage >= 1 and p.stage <= 4 and p.hop >= 0 and p.hop <= 1)
            if p.layer then
                local a, b = points[p.layer], points[p.layer + 1]
                near((p.x - a.x) * (b.y - a.y), (p.y - a.y) * (b.x - a.x))
            end
        end
    end)
    test("left preprocessing never takes vertical space or shrinks its cards on short screens", function()
        local layers = { 2, 16, 16, 16, 16, 16, 16, 16, 16, 1 }
        local edges = Layout.edges(layers)
        for _, viewport in ipairs({ { 344, 268 }, { 768, 348 }, { 624, 90 }, { 900, 600 } }) do
            local w, h = viewport[1], viewport[2]
            local geometry = Flow.layout(w, h)
            assert(geometry.graphY == 0 and geometry.graphHeight == h - 58)
            assert(geometry.graphX > geometry.sidebarWidth and geometry.graphX + geometry.graphWidth == w)
            local bottom = 0
            for _, card in ipairs(geometry.cards) do
                assert(card.y >= bottom and card.width >= 90 and card.x + card.width < geometry.sidebarWidth)
                assert(card.height == 104)
                bottom = card.y + card.height
            end
            assert(geometry.rows == Flow.PREVIEW_TOKENS and geometry.sidebarHeight >= bottom)
            local fit = Layout.fit(layers, geometry.graphWidth, geometry.graphHeight)
            local route = Flow.route(layers, function(low) return low end)
            local points = Flow.screenPoints(fit, route, geometry)
            for index, point in ipairs(points) do
                near(point.x, geometry.graphX + fit.offsetX + fit.positions[index][route[index]].x)
                near(point.y, fit.offsetY + fit.positions[index][route[index]].y)
                assert(index == 1 or point.x > points[index - 1].x)
            end
        end
    end)
    test("neuron spacing remains fixed for every per-layer expansion and viewport", function()
        for count = B.STARTING_LAYERS[2], B.MAX_NEURONS_PER_LAYER do
            for _, viewport in ipairs({ { 200, 80 }, { 768, 348 }, { 1600, 900 } }) do
                local fit = Layout.fit({ 2, count, 1 }, viewport[1], viewport[2])
                assert(fit.scale == 1)
                for index = 2, count do near(fit.positions[2][index].y - fit.positions[2][index - 1].y, 40) end
                near(fit.positions[2][1].x, 160)
            end
        end
    end)
    test("scroll preserves valid offsets clamps resets and reveals selected offscreen layers", function()
        local fit = Layout.fit({ 2, 16, 16, 16, 16, 16, 16, 16, 16, 1 }, 200, 244)
        local preserved = Layout.scroll(fit, { x = 100, y = 200 }, 9, false)
        assert(preserved.x == 100 and preserved.y == 200)
        local right = Layout.scroll(fit, preserved, 9, true)
        local target = fit.offsetX + fit.positions[9][1].x
        assert(target - right.x >= 32 and target - right.x <= 168 and right.y == preserved.y)
        local left = Layout.scroll(fit, right, 2, true)
        target = fit.offsetX + fit.positions[2][1].x
        assert(target - left.x >= 32 and target - left.x <= 168)
        local reset = Layout.scroll(Layout.fit({ 2, 2, 1 }, 768, 348), right, 2, true)
        assert(reset.x == 0 and reset.y == 0)
        local bounded = Layout.scroll(fit, { x = math.huge, y = -100 }, 2, false)
        assert(bounded.x == fit.canvasWidth - 200 and bounded.y == 0)
    end)
    test("scrolled packets remain on their displayed routes and offscreen labels are hidden", function()
        local layers = { 2, 16, 16, 16, 16, 16, 16, 16, 16, 1 }
        local geometry = Flow.layout(344, 268)
        local fit = Layout.fit(layers, geometry.graphWidth, geometry.graphHeight)
        local route = Flow.route(layers, function(low) return low end)
        local before = Flow.screenPoints(fit, route, geometry)
        local after = Flow.screenPoints(fit, route, geometry, { x = 350, y = 120 })
        for index, point in ipairs(after) do
            near(point.x, before[index].x - 350);near(point.y, before[index].y - 120)
        end
        local anchors = { { x = 10, y = 10 }, { x = 10, y = 100 }, { x = 10, y = 200 } }
        for step = 45, 99 do
            local a, b = Flow.position(anchors, before, step / 100), Flow.position(anchors, after, step / 100)
            near(b.x, a.x - 350);near(b.y, a.y - 120)
            if Flow.contains(b, geometry.graphX, 0, geometry.graphWidth - 6, geometry.graphHeight - 6, 14, 8) then
                assert(b.x - 14 >= geometry.graphX and b.x + 14 <= 338 and b.y - 8 >= 0 and b.y + 8 <= geometry.graphHeight - 6)
            end
        end
        assert(not Flow.contains(after[1], geometry.graphX, 0, geometry.graphWidth, geometry.graphHeight, 14, 8))
    end)
    test("small graph centers at native scale and every expanded neuron is reachable by scrolling", function()
        local initial = Layout.fit({ 2, 2, 1 }, 768, 348)
        near(initial.offsetX + initial.width / 2, 384);near(initial.offsetY + initial.height / 2, 174)
        local fit = Layout.fit({ 2, 16, 16, 16, 16, 16, 16, 16, 16, 1 }, 200, 80)
        for _, points in ipairs(fit.positions) do
            for _, p in ipairs(points) do
                local scroll = Layout.scroll(fit, { x = p.x - 100, y = p.y - 40 }, nil, false)
                assert(Flow.contains({ x = p.x - scroll.x, y = p.y - scroll.y }, 0, 0, 200, 80, 9, 9))
            end
        end
    end)
    test("growing layers preserve the viewed vertical center instead of losing input and output", function()
        local small = Layout.fit({ 2, 2, 1 }, 768, 328)
        local large = Layout.fit({ 2, 16, 1 }, 768, 328)
        local scroll = Layout.scroll(large, { x = 0, y = 0, maxY = small.canvasHeight - small.viewportHeight }, 2, false)
        near(large.offsetY + large.positions[3][1].y - scroll.y, 164)
        local shifted = Layout.scroll(large, { x = 0, y = 30, maxY = large.canvasHeight - 328 }, 2, false)
        assert(shifted.y == 30)
        local reset = Layout.scroll(small, { x = 0, y = 50, maxY = large.canvasHeight - 328 }, 2, false)
        assert(reset.y == 0)
    end)
    test("ambient traffic is network-only capped and never emits a receipt or manual success", function()
        local state = Flow.new()
        assert(not state.active and state.lastReceipt == 0)
        for _ = 1, 1000 do
            Flow.tick(state, 0.016, true, false, 1.3)
            assert(state.clock >= 0 and state.clock < Flow.AUTO_PERIOD)
            for index = 1, Flow.AUTO_PACKETS do
                local progress = Flow.progress(state, index, true)
                assert(progress >= 0.45 and progress < 1)
            end
        end
        assert(not Flow.progress(state, Flow.AUTO_PACKETS + 1, true))
        assert(state.lastReceipt == 0 and not state.active and state.tokens == 0 and state.credits == nil)
    end)
    test("packet budget and duration do not grow with prompt capacity or network expansion", function()
        for count = 1, B.PROMPT_MAX_TOKENS do
            local state = Flow.new();assert(Flow.accept(state, { id = 1, tokens = count }, false))
            assert(Flow.span(state) <= Flow.DURATION + (Flow.MAX_PACKETS - 1) * Flow.STAGGER)
            local maximum = 0
            for step = 0, 60 do
                if step > 0 then Flow.tick(state, 0.1, true, false) end
                local visible = 0
                for index = 1, 20 do if Flow.progress(state, index, false) then visible = visible + 1 end end
                maximum = math.max(maximum, visible)
            end
            assert(maximum <= Flow.MAX_PACKETS)
        end
    end)
    test("new prompts cannot restart remove or relabel packets already inside the network", function()
        local state = Flow.new()
        Flow.accept(state, { id = 1, tokens = 8 }, false)
        Flow.tick(state, 2, true, false)
        local old, progress, ambient = {}, {}, {}
        for index = 1, Flow.MAX_PACKETS do old[index] = state.packets[index];progress[index] = Flow.progress(state, index, false) end
        for index = 1, Flow.AUTO_PACKETS do ambient[index] = Flow.progress(state, index, true) end
        assert(progress[1] > 0.45)
        Flow.accept(state, { id = 2, tokens = 1 }, false)
        for index = 1, Flow.MAX_PACKETS do
            assert(state.packets[index] == old[index] and old[index].receiptId == 1 and old[index].ordinal == index)
            near(Flow.progress(state, index, false), progress[index])
        end
        for index = 1, Flow.AUTO_PACKETS do near(Flow.progress(state, index, true), ambient[index]) end
        Flow.tick(state, 1.39, true, false)
        assert(state.packets[1] == old[1] and Flow.progress(state, 1, false) > 0.99)
        Flow.tick(state, 0.02, true, false)
        assert(state.packets[1].receiptId == 2 and state.packets[1].ordinal == 1)
        assert(state.packets[2] == old[2])
    end)
    test("new prompt uses only free slots with its own token ordinals", function()
        local state = Flow.new()
        Flow.accept(state, { id = 1, tokens = 2 }, false);Flow.tick(state, 1, true, false)
        local first, second = state.packets[1], state.packets[2]
        Flow.accept(state, { id = 2, tokens = 1 }, false)
        assert(state.packets[1] == first and state.packets[2] == second)
        assert(state.packets[3].receiptId == 2 and state.packets[3].ordinal == 1)
        near(Flow.progress(state, 3, false), 0)
        assert(not state.pending)
    end)
    test("burst coalesces only pending previews stays bounded and eventually drains", function()
        local state = Flow.new()
        Flow.accept(state, { id = 1, tokens = 128 }, false);Flow.tick(state, 2, true, false)
        local first = state.packets[1]
        for id = 2, 10000 do
            Flow.accept(state, { id = id, tokens = 128 }, false)
            local count = 0;for _ in pairs(state.packets) do count = count + 1 end
            assert(count == Flow.MAX_PACKETS and state.packets[1] == first and state.pending.id == id)
        end
        Flow.tick(state, 1.41, true, false)
        assert(state.packets[1].receiptId == 10000)
        Flow.tick(state, 20, true, false)
        assert(not state.active and not state.pending and next(state.packets) == nil)
        assert(state.lastReceipt == 10000 and Flow.progress(state, 1, true))
    end)
    test("overlapping packet completion and pending admission are invariant under time subdivision", function()
        local a, b = Flow.new(), Flow.new()
        for _, state in ipairs({ a, b }) do
            Flow.accept(state, { id = 1, tokens = 128 }, false);Flow.tick(state, 2, true, false)
            Flow.accept(state, { id = 2, tokens = 128 }, false)
        end
        Flow.tick(a, 3, true, false)
        for _ = 1, 30 do Flow.tick(b, 0.1, true, false) end
        for index = 1, Flow.MAX_PACKETS do
            assert(a.packets[index].receiptId == b.packets[index].receiptId)
            near(a.packets[index].start, b.packets[index].start)
            near(Flow.progress(a, index, false), Flow.progress(b, index, false))
        end
        for _, state in ipairs({ a, b }) do
            Flow.tick(state, 0, false, false)
            assert(not state.active and not state.pending and next(state.packets) == nil and state.lastReceipt == 2)
        end
    end)
    test("input width and every embedding vector share the balance dimension", function()
        for _, dimensions in ipairs({ 4, 8, 16 }) do
            local config = {};for key, value in pairs(B) do config[key] = value end
            config.EMBEDDING_DIM = dimensions
            local state = State.new(config)
            assert(state.layerSizes[1] == dimensions and state.layerSizes[2] == 2)
            local preview = Flow.preview(6, Prompt, config)
            for _, token in ipairs(preview.tokens) do assert(#token.vector == state.layerSizes[1]) end
            assert(State.fromStored(state, config))
            near(Sim.rate(state, config), 0)
            state.batches = 1;near(Sim.rate(state, config), 0.7)
        end
    end)
    test("schema-5 converts only validated input width and respects leases without refunds", function()
        local repo, store, time = storeFixture()
        local old = legacy(5)
        old.layerSizes, old.credits, old.tokenLevel = { 2, 7, 12, 1 }, 123, 8
        old.attentionHeads = 8
        local parsed = assert(State.fromStored(old, B))
        assert(parsed.schemaVersion == B.SCHEMA_VERSION and parsed.layerSizes[1] == B.EMBEDDING_DIM)
        assert(parsed.layerSizes[2] == 7 and parsed.layerSizes[3] == 12 and parsed.credits == 127 and parsed.tokenLevel == 7)
        assert(old.layerSizes[1] == 2 and old.schemaVersion == 5)
        near(Sim.rate(parsed, B), Sim.rate(old, B))
        store.values.User_1 = { schemaVersion = 5, data = old, lock = { owner = "old", expiresAt = time.now + 5 } }
        local handle, reason = repo:acquire("User_1", "new")
        assert(not handle and reason == "profile_busy" and store.values.User_1.data == old)
        time.now = time.now + 6;handle = assert(repo:acquire("User_1", "new"))
        assert(repo:save(handle, true))
        local again = assert(repo:acquire("User_1", "next"))
        assert(again.state.credits == 127 and again.state.layerSizes[1] == B.EMBEDDING_DIM)
        old.layerSizes[1] = B.EMBEDDING_DIM;assert(not State.fromStored(old, B))
        parsed.layerSizes[1] = 2;assert(not State.fromStored(parsed, B))
    end)
    test("uniform integer choices reach every complete neural route with equal multiplicity", function()
        local layers, seen, inputs, middle = { 4, 3, 2, 1 }, {}, {}, {}
        for input = 1, 4 do
            for hidden = 1, 3 do
                for last = 1, 2 do
                    local picks, call = { input, hidden, last, 1 }, 0
                    local route = Flow.route(layers, function(low, high)
                        call = call + 1;assert(low == 1 and high == layers[call]);return picks[call]
                    end)
                    local key = table.concat(route, ":");assert(not seen[key]);seen[key] = true
                    inputs[route[1]] = (inputs[route[1]] or 0) + 1
                    middle[route[2]] = (middle[route[2]] or 0) + 1
                end
            end
        end
        for _, count in pairs(inputs) do assert(count == 6) end
        for _, count in pairs(middle) do assert(count == 8) end
    end)
    test("packet route persists across prompts and geometry but rerolls for new trips or topology", function()
        local state, owner, calls, pick = Flow.new(), {}, 0, 1
        local layers = { 4, 16, 1 }
        local function choose(low, high) calls = calls + 1;return math.min(pick, high) end
        local route = Flow.packetRoute(owner, layers, 0, choose)
        pick = 16
        Flow.accept(state, { id = 1, tokens = 2 }, false)
        assert(Flow.packetRoute(owner, layers, 0, choose) == route and calls == 3)
        local nextRoute = Flow.packetRoute(owner, layers, 1, choose)
        assert(nextRoute ~= route and nextRoute[1] == 4 and nextRoute[2] == 16 and calls == 6)
        assert(Flow.packetRoute(owner, { 4, 2, 1 }, 1, choose)[2] == 2 and calls == 9)
        assert(Flow.trip(state, 1) == 0)
        Flow.tick(state, Flow.AUTO_PERIOD + 0.01, true, false, 1)
        assert(Flow.trip(state, 1) == 1)
        local fresh = {};assert(Flow.packetRoute(fresh, layers, 0, choose) ~= nextRoute)
    end)
    test("expanded vocabulary has stable unique IDs and every offset wraps within byte and token caps", function()
        assert(Prompt.VOCABULARY_SIZE == 129 and Prompt.tokenId("code") == 19 and Prompt.tokenId("signal") == 20)
        local seen = {}
        for offset = 0, Prompt.VOCABULARY_SIZE - 1 do
            local word = Prompt.nextWord(offset)
            assert(not seen[string.lower(word)]);seen[string.lower(word)] = true
            assert(Prompt.tokenId(word) == offset + 1)
            for _, count in ipairs({ 1, 8, 64 }) do
                local text = Prompt.text(count, B, offset)
                assert(#text <= B.PROMPT_MAX_BYTES and not Protocol.validate("submit_prompt", text, B))
                assert(Protocol.validate("submit_prompt", {draftId=1,tokens=count}, B))
                local parsed, reason, start = Prompt.validate(text, count, B)
                assert(parsed == count and not reason and start == offset)
            end
        end
        assert(Prompt.nextWord(129) == "build" and Prompt.nextWord(130) == "a")
    end)
    test("offset prompts reject noncanonical order casing whitespace and invalid offsets", function()
        for _, text in ipairs({ "BUILD", "signal  neuron", "neuron signal", "signal network", " signal", "signal ", "unknown" }) do
            assert(not Prompt.validate(text, 128, B))
            local state = State.new(B);assert(not submit(state, text, 10, -math.huge, B, Sim))
            assert(state.credits == 0 and state.batches == 0)
        end
        for _, offset in ipairs({ -1, 0.5, 129, math.huge, 0 / 0, "0" }) do
            assert(not Prompt.text(3, B, offset) and not Flow.preview(3, Prompt, B, offset))
        end
    end)
    test("offset receipts report accepted start and sampled output with common-tier base rewards", function()
        local state = active();state.tokenLevel = B.MAX_TOKEN_LEVEL
        for _, offset in ipairs({ 0, 19, 64, 128 }) do
            local credits = state.credits
            local ok, receipt = submit(state, Prompt.text(8, B, offset), offset + 10, -math.huge, B, Sim)
            assert(ok and receipt.startToken == offset + 1 and receipt.tokens == 8)
            assert(receipt.outputToken == B.OUTPUT_TOKENS[1].word and receipt.outputRarity == "Common")
            near(state.credits - credits, 8 * Sim.batchReward(state))
            assert(State.copy(state).startToken == nil and State.copy(state).promptText == nil)
        end
    end)
    test("live input sends automatically once and preserves later words through matching receipts", function()
        local state = Draft.liveNew()
        assert(not Draft.liveNext(state, 0, 8, B, Prompt.VOCABULARY_SIZE))
        assert(Draft.livePush(state, Prompt.VOCABULARY_SIZE, 128) == 0)
        local first = assert(Draft.liveNext(state, 0, 8, B, Prompt.VOCABULARY_SIZE))
        assert(first.tokens == 1 and first.startToken == 1)
        for index = 1, 3 do assert(Draft.livePush(state, 129, 128) == index) end
        assert(not Draft.liveNext(state, 0.2, 8, B, 129))
        local receipt = { id = 1, tokens = 1, startToken = 1 }
        assert(Draft.liveConfirm(state, receipt, false) and state.queued == 3 and not state.flight)
        assert(not Draft.liveNext(state, B.LIVE_SEND_INTERVAL - 0.001, 8, B, 129))
        local second = assert(Draft.liveNext(state, B.LIVE_SEND_INTERVAL, 8, B, 129))
        assert(second.tokens == 3 and second.startToken == 2 and state.queued == 0)
        assert(not Draft.liveConfirm(state, receipt, false) and state.flight == second)
    end)
    test("live queue is bounded and batches respect capacity cooldown and one-flight pacing", function()
        local state, server = Draft.liveNew(), State.new(B)
        local lastManual, accepted, total = -math.huge, 0, 0
        for _ = 1, 10000 do Draft.livePush(state, 129, B.PROMPT_MAX_TOKENS) end
        assert(state.queued == 64 and state.cursor == 64)
        for tick = 0, 100 do
            local now = tick * 0.1
            local flight = Draft.liveNext(state, now, 8, B, 129)
            if flight then
                assert(flight.tokens <= 8 and not Draft.liveNext(state, now, 8, B, 129))
                local text = Prompt.text(flight.tokens, B, flight.startToken - 1)
                local ok, receipt = submit(server, text, now, lastManual, B, Sim)
                assert(ok);lastManual = now;accepted = accepted + 1;total = total + receipt.tokens
                receipt.id = accepted
                assert(Draft.liveConfirm(state, receipt, false))
            end
            assert(state.queued >= 0 and state.queued <= 128)
        end
        assert(total == 64 and accepted == 8 and server.credits == 64 and state.queued == 0 and not state.flight)
    end)
    test("live timeout never resends possibly credited words and late receipts cannot erase new input", function()
        local state = Draft.liveNew()
        Draft.livePush(state, 129, 128)
        local old = Draft.liveNext(state, 0, 8, B, 129)
        local flight, reason = Draft.liveNext(state, B.LIVE_RECEIPT_TIMEOUT, 8, B, 129)
        assert(not flight and reason == "timeout" and not state.flight)
        assert(not Draft.liveNext(state, 10, 8, B, 129))
        Draft.livePush(state, 129, 128)
        local newer = assert(Draft.liveNext(state, 10, 8, B, 129))
        assert(newer.startToken == 2)
        assert(Draft.liveConfirm(state, { id = 1, tokens = old.tokens, startToken = old.startToken }, false))
        assert(state.flight == newer)
        Draft.liveReset(state)
        assert(state.lastReceipt == 1 and state.queued == 0 and not state.flight and state.cursor == 0)
        assert(not Draft.liveConfirm(state, { id = 1, tokens = 1 }, false))
        assert(not Draft.liveConfirm(state, { id = 2, tokens = 1 }, true))
    end)
    test("packet offsets preserve earlier word identities across later live receipts", function()
        local state = Flow.new()
        assert(Flow.accept(state, { id = 1, tokens = 2, startToken = 20 }, false, 129))
        Flow.tick(state, 2, true, false)
        local old, progress = state.packets[1], Flow.progress(state, 1, false)
        assert(old.offset == 19 and Prompt.nextWord(old.offset + old.ordinal - 1) == "signal")
        assert(Flow.accept(state, { id = 2, tokens = 1, startToken = 129 }, false, 129))
        assert(state.packets[1] == old and old.offset == 19)
        near(Flow.progress(state, 1, false), progress)
        local preview = Flow.preview(2, Prompt, B, 128)
        assert(preview.tokens[1].id == 129 and preview.tokens[2].id == 1)
        assert(state.packets[3].offset == 128)
        for _, bad in ipairs({ 0, -1, 0.5, 130, math.huge, 0 / 0, "1" }) do
            assert(not Flow.accept(state, { id = 3, tokens = 1, startToken = bad }, false, 129))
        end
    end)
    test("delayed live acknowledgement leaves a cooldown gap before the next automatic batch", function()
        local state = Draft.liveNew()
        Draft.livePush(state, 129, 128)
        assert(Draft.liveNext(state, 0, 8, B, 129))
        Draft.livePush(state, 129, 128)
        assert(Draft.liveConfirm(state, { id = 1, tokens = 1, startToken = 1 }, false, 2, B))
        assert(not Draft.liveNext(state, 2 + B.LIVE_SEND_INTERVAL - 0.001, 8, B, 129))
        local nextBatch = assert(Draft.liveNext(state, 2 + B.LIVE_SEND_INTERVAL, 8, B, 129))
        assert(nextBatch.startToken == 2 and nextBatch.tokens == 1)
    end)
    test("output distribution has exact weighted counts and decreasing rarity with increasing rewards", function()
        local counts, total, expected = {}, 0, 0
        for rank, tier in ipairs(B.OUTPUT_TOKENS) do
            assert(tier.weight > 0 and tier.weight % 1 == 0 and tier.multiplier >= 1)
            if rank > 1 then
                assert(tier.weight < B.OUTPUT_TOKENS[rank - 1].weight)
                assert(tier.multiplier > B.OUTPUT_TOKENS[rank - 1].multiplier)
            end
            total = total + tier.weight;expected = expected + tier.weight * tier.multiplier
        end
        assert(total == 10000);near(expected / total, 2.075)
        for roll = 1, total do
            local output = assert(Prompt.drawOutput(B, function(low, high)
                assert(low == 1 and high == total);return roll
            end))
            counts[output.rank] = (counts[output.rank] or 0) + 1
            assert(output.word == B.OUTPUT_TOKENS[output.rank].word and output.totalWeight == total)
        end
        for rank, tier in ipairs(B.OUTPUT_TOKENS) do assert(counts[rank] == tier.weight) end
    end)
    test("weighted output boundaries and malformed rolls cannot fall into another reward", function()
        local previous = 0
        for rank, tier in ipairs(B.OUTPUT_TOKENS) do
            for _, roll in ipairs({ previous + 1, previous + tier.weight }) do
                assert(Prompt.drawOutput(B, function() return roll end).rank == rank)
            end
            previous = previous + tier.weight
        end
        for _, roll in ipairs({ 0, -1, 10001, 1.5, math.huge, 0 / 0, "1", false }) do
            assert(not Prompt.drawOutput(B, function() return roll end))
        end
        assert(not Prompt.drawOutput(B, nil))
        local state = State.new(B)
        assert(not Prompt.submit(state, Prompt.text(1, B), 10, -math.huge, B, Sim))
        assert(state.credits == 0 and state.batches == 0)
    end)
    test("each accepted word draws its own reward and the batch aggregate grants exactly once", function()
        local state, calls = State.new(B), 0
        local rolls = { 1, 7001, 9001, 9801, 9951, 9996 }
        local ok, receipt = submit(state, Prompt.text(6, B, 19), 10, -math.huge, B, Sim, function()
            calls = calls + 1;return rolls[calls]
        end)
        assert(ok and calls == 6 and #receipt.outputs == 6 and receipt.startToken == 20)
        assert(state.credits == 323 and receipt.reward == 323 and state.batches == 1)
        assert(receipt.outputToken == "NEXT_BIG_THING" and receipt.outputRarity == "Mythic" and receipt.featured.rank == 6)
        local sum = 0
        for rank, output in ipairs(receipt.outputs) do
            assert(output.rank == rank and output.reward == B.OUTPUT_TOKENS[rank].multiplier)
            sum = sum + output.reward
        end
        assert(sum == receipt.reward and B.OUTPUT_TOKENS[1].reward == nil)
        local copy = State.copy(state)
        assert(copy.outputs == nil and copy.featured == nil and copy.lastPrompt == nil)
    end)
    test("rare reward scales with neural base and caps each actual amount at remaining balance", function()
        local state = active();state.layerSizes[2] = 6
        local ok, receipt = submit(state, Prompt.text(1, B), 10, -math.huge, B, Sim, function() return 9001 end)
        assert(ok and receipt.outputs[1].reward == 5 * Sim.batchReward(state))
        state.tokenLevel = B.MAX_TOKEN_LEVEL;state.credits = B.MAX_CREDITS - 0.5
        local calls = 0
        ok, receipt = submit(state, Prompt.text(64, B), 11, 10, B, Sim, function()
            calls = calls + 1;return 10000
        end)
        assert(ok and calls == 64 and receipt.reward == 0.5 and state.credits == B.MAX_CREDITS)
        assert(receipt.outputs[1].reward == 0.5)
        for index = 2, 64 do assert(receipt.outputs[index].reward == 0) end
        local rate = Sim.rate(state, B)
        assert(Sim.advance(state, 1, B) and state.credits == B.MAX_CREDITS and rate > 0)
    end)
    test("invalid capped and cooldown input never consumes a reward draw or changes progression", function()
        local state, calls = State.new(B), 0
        local function roll() calls = calls + 1;return 10000 end
        for _, text in ipairs({ "unknown text", "", Prompt.text(9, B) }) do
            assert(not submit(state, text, 10, -math.huge, B, Sim, roll))
            assert(calls == 0 and state.credits == 0 and state.batches == 0)
        end
        assert(submit(state, Prompt.text(1, B), 10, -math.huge, B, Sim, roll))
        assert(calls == 1 and state.credits == 250)
        assert(not submit(state, Prompt.text(1, B), 10.01, 10, B, Sim, roll))
        assert(calls == 1 and state.credits == 250 and state.batches == 1)
    end)
    test("invalid later reward draw cannot grant a partial batch", function()
        local state, calls = State.new(B), 0
        local ok, reason = submit(state, Prompt.text(3, B), 10, -math.huge, B, Sim, function()
            calls = calls + 1;return calls == 2 and 0 / 0 or 10000
        end)
        assert(not ok and reason == "invalid_reward_roll" and calls == 2)
        assert(state.credits == 0 and state.batches == 0)
    end)
    test("packet completion retains the original reward receipt through overlapping input and emits once", function()
        local state = Flow.new()
        local common = Prompt.drawOutput(B, function() return 1 end);common.reward = 1
        local rare = Prompt.drawOutput(B, function() return 9001 end);rare.reward = 5
        local mythic = Prompt.drawOutput(B, function() return 10000 end);mythic.reward = 250
        local first = { id = 1, tokens = 2, outputs = { common, rare }, featured = rare, reward = 6 }
        local second = { id = 2, tokens = 1, outputs = { mythic }, featured = mythic, reward = 250 }
        assert(Flow.accept(state, first, false))
        Flow.tick(state, 2, true, false)
        local packet = state.packets[1]
        assert(Flow.accept(state, second, false) and state.packets[1] == packet and packet.output == common)
        local _, completed = Flow.tick(state, 1.41, true, false)
        assert(#completed == 1 and completed[1].receipt == first and completed[1].output.reward == 1)
        local _, rest = Flow.tick(state, 10, true, false)
        assert(#rest == 2 and rest[1].output == rare and rest[2].receipt == second and rest[2].output == mythic)
        local _, empty = Flow.tick(state, 10, true, false)
        assert(#empty == 0 and state.credits == nil)
    end)
    test("baseline repeats reset and reduced motion cannot replay reward arrivals", function()
        local state = Flow.new()
        local receipt = { id = 1, tokens = 1, outputs = { { word = "FIX", reward = 1 } } }
        assert(not Flow.accept(state, receipt, true))
        local ended, completed = Flow.tick(state, 10, true, false)
        assert(not ended and #completed == 0)
        assert(not Flow.accept(state, receipt, false))
        receipt.id = 2;assert(Flow.accept(state, receipt, false))
        ended, completed = Flow.tick(state, 0, true, true)
        assert(ended and completed == nil)
        Flow.reset(state)
        assert(not Flow.accept(state, receipt, false))
        ended, completed = Flow.tick(state, 10, true, false)
        assert(not ended and #completed == 0)
    end)
    test("rare pending output survives common bursts and best hidden token enters the bounded preview", function()
        local state, server = Flow.new(), State.new(B)
        server.tokenLevel = B.MAX_TOKEN_LEVEL
        assert(Flow.accept(state, { id = 1, tokens = 128 }, false))
        Flow.tick(state, 2, true, false)
        local calls = 0
        local ok, receipt = submit(server, Prompt.text(64, B), 10, -math.huge, B, Sim, function()
            calls = calls + 1;return calls == 64 and 10000 or 1
        end)
        assert(ok and receipt.featuredIndex == 64 and receipt.reward == 313)
        receipt.id = 2;assert(Flow.accept(state, receipt, false))
        local pending = state.pending
        for id = 3, 1000 do
            assert(Flow.accept(state, { id = id, tokens = 1, featured = { rank = 1 } }, false))
            assert(state.pending == pending)
        end
        local _, completed = Flow.tick(state, 10, true, false)
        local found = false
        for _, packet in ipairs(completed) do
            if packet.receiptId == 2 and packet.lastSample then
                assert(packet.ordinal == 64 and packet.output.word == "NEXT_BIG_THING" and packet.output.reward == 250)
                found = true
            end
        end
        assert(found and not state.active and #completed <= 12)
    end)
    test("routine receipt summaries omit per-word arrays without replaying or mutating active output", function()
        local server = State.new(B)
        local _, receipt = submit(server, Prompt.text(8, B), 10, -math.huge, B, Sim, function() return 10000 end)
        receipt.id = 1
        local full, light = Prompt.receiptView(receipt, true), Prompt.receiptView(receipt, false)
        assert(#full.outputs == 8 and light.outputs == nil and light.id == 1 and light.reward == receipt.reward)
        assert(light.featured.word == "NEXT_BIG_THING" and light.featuredIndex == 1)
        local state = Flow.new();assert(Flow.accept(state, full, false))
        local packet = state.packets[1]
        assert(not Flow.accept(state, light, false) and state.packets[1] == packet)
        assert(packet.output.word == "NEXT_BIG_THING" and packet.receipt.outputs == full.outputs)
        assert(Prompt.receiptView(nil, true) == nil and receipt.outputs ~= nil)
    end)
    local Agent = modules.Agent
    local function receipt(id, count, roll)
        local server = State.new(B)
        server.tokenLevel = B.MAX_TOKEN_LEVEL
        local ok, result = submit(server, Prompt.text(count or 1, B), 10, -math.huge, B, Sim,
            function() return roll or 1 end)
        assert(ok);result.id = id
        return result
    end
    test("CLI baseline repeated and older receipts do not replay jobs", function()
        local state = Agent.new()
        assert(not Agent.accept(state, receipt(12), true, Prompt, B))
        assert(not Agent.accept(state, receipt(12), false, Prompt, B))
        assert(not Agent.accept(state, receipt(11), false, Prompt, B))
        assert(not state.active and #state.lines == 0)
        assert(Agent.accept(state, receipt(13), false, Prompt, B) and state.active.id == 13)
    end)
    test("CLI appending input preserves active job time and confirmed reward ownership", function()
        local state, first = Agent.new(), receipt(1, 8, 10000)
        Agent.accept(state, first, false, Prompt, B);Agent.tick(state, 0.5, false)
        local owner, elapsed = state.active, state.elapsed
        first.reward, first.outputToken = 999, "MUTATED"
        Agent.accept(state, receipt(2), false, Prompt, B)
        assert(state.active == owner and state.elapsed == elapsed and #state.pending == 1)
        assert(owner.word == "NEXT_BIG_THING" and owner.reward == 2000)
        Agent.tick(state, 0.91, false)
        assert(state.lastResult == owner and state.active.id == 2 and state.completed == 1)
    end)
    test("CLI presentation queue remains bounded and keeps rarer unstarted outcomes", function()
        local state = Agent.new()
        for id = 1, 5 do Agent.accept(state, receipt(id), false, Prompt, B) end
        local activeJob = state.active
        Agent.accept(state, receipt(6, 1, 10000), false, Prompt, B)
        for id = 7, 1006 do Agent.accept(state, receipt(id), false, Prompt, B) end
        assert(#state.pending == Agent.MAX_PENDING and state.active == activeJob)
        assert(state.pending[4].id == 6 and state.coalesced == 1001)
        Agent.tick(state, 100, false)
        assert(not state.active and #state.pending == 0 and state.completed == 5 and state.lastResult.id == 6)
    end)
    test("CLI stages are invariant under frame subdivision and emit each outcome once", function()
        local a, b = Agent.new(), Agent.new()
        for id = 1, 5 do Agent.accept(a, receipt(id), false, Prompt, B);Agent.accept(b, receipt(id), false, Prompt, B) end
        Agent.tick(a, 8, false)
        for _ = 1, 800 do Agent.tick(b, 0.01, false) end
        assert(a.completed == 5 and b.completed == 5 and #a.lines == #b.lines)
        for index, line in ipairs(a.lines) do assert(line.text == b.lines[index].text) end
        local revision = a.revision;Agent.tick(a, 100, false)
        assert(a.revision == revision and a.completed == 5)
    end)
    test("CLI reduced mode drains all bounded jobs without delaying credits", function()
        local state = Agent.new()
        for id = 1, 5 do Agent.accept(state, receipt(id), false, Prompt, B) end
        Agent.tick(state, 0, true)
        assert(not state.active and #state.pending == 0 and state.completed == 5)
        assert(state.lastResult.id == 5 and state.lastResult.reward == 1)
    end)
    test("CLI scrollback and long lines stay bounded through prolonged typing", function()
        local state = Agent.new()
        for id = 1, 1000 do
            Agent.accept(state, receipt(id, 64), false, Prompt, B);Agent.tick(state, 0, true)
        end
        assert(#state.lines == Agent.MAX_LINES and state.completed == 1000 and state.lastReceipt == 1000)
        for _, line in ipairs(state.lines) do assert(#line.text <= 220) end
    end)
    test("CLI reset clears presentation but retains receipt dedup watermark", function()
        local state = Agent.new()
        Agent.accept(state, receipt(10), false, Prompt, B);Agent.reset(state)
        assert(#state.lines == 0 and #state.pending == 0 and not state.active and state.completed == 0)
        assert(state.lastReceipt == 10 and not Agent.accept(state, receipt(10), false, Prompt, B))
        assert(Agent.accept(state, receipt(11), false, Prompt, B))
    end)
    test("CLI rejects malformed presentation inputs without occupying a slot", function()
        local state = Agent.new()
        for _, bad in ipairs({ {}, { id = math.huge }, { id = 1, tokens = 129, reward = 2 },
            { id = 1, tokens = 1, reward = -1 }, { id = 1, tokens = 1, reward = 0/0 },
            { id = 1, tokens = 1, reward = 1, startToken = 130 } }) do
            assert(not Agent.accept(state, bad, false, Prompt, B))
        end
        assert(state.lastReceipt == 0 and not state.active)
        Agent.accept(state, receipt(1), false, Prompt, B)
        for _, bad in ipairs({ -1, 0/0, math.huge, "1" }) do Agent.tick(state, bad, false) end
        assert(state.elapsed == 0 and state.step == 1)
    end)
    test("fixed shop partitions every workstation with a readable minimum virtual CLI", function()
        for _,size in ipairs({{320,360},{360,640},{640,360},{900,640},{1280,720},{1920,1080}}) do
            for count=1,8 do
                local spec=Agent.workstationLayout(size[1],size[2],count)
                assert(spec.store.x+spec.store.width==size[1]-8 and spec.store.y==8)
                assert(spec.store.y+spec.store.height<=size[2]-44)
                assert(spec.viewportWidth+16==spec.store.x and spec.width>=320)
                assert(spec.width>=spec.viewportWidth and #spec.windows==1)
                for _,window in ipairs(spec.windows) do
                    assert(window.width>=300 and window.x>=0 and window.y>=0)
                    assert(window.x+window.width<=spec.width and window.y+window.height<=spec.height)
                end
            end
        end
    end)
    test("floating desktop keeps one to eight terminals inside every target viewport without a sidebar", function()
        for _, size in ipairs({ {360,640}, {1280,720}, {640,360}, {1920,1080}, {960,470} }) do
            for count = 1, 8 do
                local layout = Agent.layout(size[1], size[2], count)
                assert(layout.x >= 8 and layout.width >= 300 and layout.height >= 220)
                assert(layout.x + layout.width <= size[1] - 8)
                assert(layout.top + layout.height <= size[2] - 44)
                assert(layout.shop == 0 and layout.explorer == 0 and #layout.windows == count)
                assert(layout.windows[1].width >= 300 and layout.windows[1].height >= 220)
                for _, window in ipairs(layout.windows) do
                    assert(window.x >= 0 and window.y >= 0 and window.width > 0 and window.height >= 200)
                    assert(window.x + window.width <= layout.width and window.y + window.height <= layout.height)
                end
                local again = Agent.layout(size[1], size[2], count)
                for index, window in ipairs(layout.windows) do
                    for key, value in pairs(window) do assert(again.windows[index][key] == value) end
                end
            end
        end
    end)
    test("terminal dragging and normalized resize positions never lose a window outside the desktop", function()
        for count = 1, 8 do
            local desktop = Agent.layout(1920, 1080, count)
            for _, window in ipairs(desktop.windows) do
                for _, drag in ipairs({ {-10000,-10000}, {10000,10000}, {0,0}, {201,79} }) do
                    local x, y = Agent.clampWindow(drag[1], drag[2], window.width, window.height, desktop.width, desktop.height)
                    assert(x >= 0 and y >= 0 and x + window.width <= desktop.width and y + window.height <= desktop.height)
                    local nx, ny = x / math.max(1, desktop.width - window.width), y / math.max(1, desktop.height - window.height)
                    local small = Agent.layout(360,640,count)
                    local resized = small.windows[1]
                    local rx, ry = Agent.clampWindow(nx * (small.width - resized.width), ny * (small.height - resized.height),
                        resized.width, resized.height, small.width, small.height)
                    assert(rx >= 0 and ry >= 0 and rx + resized.width <= small.width and ry + resized.height <= small.height)
                end
            end
        end
    end)
    test("only confirmed agent purchases add terminal windows while workers preserve the window count", function()
        local server = State.new(B)
        server.credits = B.MAX_CREDITS
        assert(#Agent.layout(1280,720,#server.layerSizes-2).windows == 1)
        assert(Rules.purchase(server,"upgrade_workers",nil,B))
        assert(#Agent.layout(1280,720,#server.layerSizes-2).windows == 1)
        for count = 2, B.MAX_HIDDEN_LAYERS do
            assert(Rules.purchase(server,"add_layer",nil,B))
            assert(#Agent.layout(1280,720,#server.layerSizes-2).windows == count)
        end
        assert(not Rules.purchase(server,"add_layer",nil,B))
        assert(#Agent.layout(1280,720,#server.layerSizes-2).windows == B.MAX_HIDDEN_LAYERS)
        assert(#Agent.layout(1280,720,#State.new(B).layerSizes-2).windows == 1)
    end)
    test("typing to CLI receipts and buying a worker completes the MVP economic cycle", function()
        local server, draft, ui = State.new(B), Draft.liveNew(), Agent.new()
        for _ = 1, 8 do Draft.livePush(draft, Prompt.VOCABULARY_SIZE, B.PROMPT_MAX_TOKENS) end
        local flight = assert(Draft.liveNext(draft, 1, 8, B, Prompt.VOCABULARY_SIZE))
        local ok, result = submit(server, Prompt.text(flight.tokens, B, flight.startToken - 1), 1, -math.huge, B, Sim)
        assert(ok and server.credits == 8 and Sim.rate(server, B) > 0);result.id = 1
        assert(Draft.liveConfirm(draft, result, false, 1, B) and Agent.accept(ui, result, false, Prompt, B))
        local originalCredits = server.credits
        Agent.tick(ui, 100, false);Agent.tick(ui, 100, true)
        assert(server.credits == originalCredits and ui.completed == 1)
        local cost = Rules.quote(server, "upgrade_workers", nil, B)
        assert(Rules.purchase(server, "upgrade_workers", nil, B))
        assert(server.layerSizes[2] == 3 and server.credits == 8-cost and Sim.rate(server, B) > 0.7)
    end)
    assert(#failures==0,table.concat(failures,"\n"))
    print("[VibeIdle] " .. passed .. " specifications passed")
    return passed
end

return Specs

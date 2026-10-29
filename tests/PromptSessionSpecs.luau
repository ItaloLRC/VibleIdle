-- Pure tests for the live manual-prompt path; old portable helpers remain regressed separately.
local Specs = {}
function Specs.run(m)
    local B,State,Rules,Prompt,Sim=m.Balance,m.State,m.Rules,m.Prompt,m.Simulation
    local Session,Composer,Cash=m.Session,m.Composer,m.Cash
    local passed,failures=0,{}
    local function test(name,run)
        local ok,reason=pcall(run)
        if not ok then
            failures[#failures+1]="FAIL manual prompt: "..name..": "..tostring(reason)
            print(failures[#failures])
        else passed=passed+1;print("PASS manual prompt: "..name) end
    end
    local function near(a,b) assert(math.abs(a-b)<0.0001,tostring(a).." ~= "..tostring(b)) end
    local function commonState() local state=State.new(B);for _,card in ipairs(B.AGENT_CARDS) do if card.rank==1 then state.cardOwned[card.id]=true end end;return state end
    local function setup(choose)
        local profile,session=commonState(),Session.new()
        assert(Session.ensure(session,profile,B,Prompt,choose or function() return 1 end))
        m.Auto.advance(session,profile,0,B)
        return profile,session
    end
    local function send(profile,session,count,now,last,choose)
        return Session.submit(session,profile,{draftId=session.draft.id,tokens=count},now or 10,last or -math.huge,B,Prompt,Sim,choose or function() return 1 end)
    end
    test("Studio tuning catalog cycles both directions copies defaults and rejects unsupported commands",function()
        local settings={};local defaults=m.Tuning.view()
        for _,control in ipairs(m.Tuning.controls) do
            assert(defaults[control.key]==control.values[1])
            assert(m.Tuning.cycle(settings,control.action,1) and settings[control.key]==control.values[2])
            assert(m.Tuning.cycle(settings,control.action,-1) and settings[control.key]==control.values[1])
            for _=1,#control.values do assert(m.Tuning.cycle(settings,control.action,1)) end
            assert(settings[control.key]==control.values[1])
        end
        assert(not m.Tuning.cycle(settings,"missing",1) and not m.Tuning.cycle(settings,"skill_initial",99))
        local view=m.Tuning.view(settings);view.spawnPercent=100
        assert(settings.spawnPercent==30 and m.Tuning.view().spawnPercent==30)
    end)
    test("lowering Studio spawn capacity preserves live items and blocks additions until below the new limit",function()
        local profile,session=setup();session.streak=1
        local function choose(low) return low end
        for _=1,3 do assert(m.Collectibles.issue(session,{grade="Great"},profile,choose)) end
        session.skillSettings={spawnCapacity=1}
        session.avatarItems[1]=nil
        assert(not m.Collectibles.issue(session,{grade="Great"},profile,function() error("over cap rerolled") end))
        assert(#m.Collectibles.view(session).items==2)
        session.avatarItems[2],session.avatarItems[3]=nil,nil
        assert(m.Collectibles.issue(session,{grade="Good"},profile,choose))
        assert(#m.Collectibles.view(session).items==1 and session.avatarSequence==4)
    end)
    test("special-token tickets have exact 1-in-50 1-in-100 1-in-1000 and 1-in-10000 odds",function()
        local counts={0,0,0,0,0}
        for roll=1,10000 do
            local _,session=setup(function() return roll end)
            local rank=session.draft.offers[1].rank;counts[rank]=counts[rank]+1
        end
        for index,tier in ipairs(B.SPECIAL_TOKENS) do
            assert(counts[index]==tier.weight)
            if tier.denominator then assert(tier.weight*tier.denominator==10000) end
        end
    end)
    test("payload fields reject forged words money rolls multipliers IDs and counts",function()
        local bad={{},{draftId=1,tokens=0},{draftId=1,tokens=129},{draftId=0,tokens=1},
            {draftId=0/0,tokens=1},{draftId=math.huge,tokens=1},{draftId=1,tokens=1.5},
            {draftId=1,tokens=1,word="rare"},{draftId=1,tokens=1,reward=999},
            {draftId=1,tokens=1,multiplier=250},{draftId=1,tokens=1,roll=10000},
            {draftId=1,tokens=1,[1]=1}}
        for _,payload in ipairs(bad) do
            assert(not Session.validPayload(payload,B) and not m.Protocol.validate("submit_prompt",payload,B))
        end
        assert(Session.validPayload({draftId=1,tokens=64},B))
        assert(not m.Protocol.validate("submit_prompt","build",B))
    end)
    test("syncs and repeated draft views cannot reroll or share mutable token offers",function()
        local calls=0
        local choose=function() calls=calls+1;return 9890 end
        local profile,session=setup(choose)
        local original=session.draft
        for _=1,10 do assert(Session.ensure(session,profile,B,Prompt,choose)==original) end
        assert(calls==8 and original.offers[1].rank==3)
        local view=Session.view(original);view.offers[1].multiplier=999
        assert(original.offers[1].multiplier==10)
    end)
    test("context upgrades append offers without changing the ID or rerolling old tokens",function()
        local calls=0
        local choose=function() calls=calls+1;return 9690 end
        local profile,session=setup(choose)
        local old=session.draft
        profile.credits=100;assert(Rules.purchase(profile,"upgrade_tokens",nil,B))
        local nextDraft=assert(Session.ensure(session,profile,B,Prompt,choose))
        assert(nextDraft.id==old.id and #nextDraft.offers==16 and #old.offers==8 and calls==16)
        for index=1,8 do assert(nextDraft.offers[index]==old.offers[index]) end
    end)
    test("payout equals submitted token count and each preissued token multiplier with CPU scaling",function()
        local tickets={1,9690,9890,9990,10000,1,1,1};local calls=0
        local profile,session=setup(function() calls=calls+1;return tickets[calls] end)
        profile.computeLevel=1
        local ok,receipt=send(profile,session,3)
        assert(ok and receipt.tokens==3 and #receipt.outputs==3 and receipt.id==1 and receipt.draftId==1)
        near(receipt.reward,1.35*(1+3+10));near(profile.credits,receipt.reward)
        assert(receipt.outputs[1].word=="build" and receipt.outputs[2].word=="a" and receipt.outputToken=="responsive")
        assert(receipt.featured.rank==3 and session.draft.id==2 and session.draft.startToken==4)
    end)
    test("unsent special tokens never contribute to the prompt payout",function()
        local calls=0
        local profile,session=setup(function() calls=calls+1;return calls==1 and 1 or 10000 end)
        local ok,receipt=send(profile,session,1)
        assert(ok and receipt.reward==1 and profile.credits==1 and receipt.featured.rank==1)
    end)
    test("duplicate and stale submissions pay once without consuming randomness",function()
        local profile,session=setup();local payload={draftId=1,tokens=8}
        assert(Session.submit(session,profile,payload,10,-math.huge,B,Prompt,Sim,function() return 1 end))
        local before,active=profile.credits,session.draft
        for _=1,100 do
            local ok,reason=Session.submit(session,profile,payload,20,10,B,Prompt,Sim,function() error("stale reroll") end)
            assert(not ok and reason=="stale_prompt")
        end
        assert(profile.credits==before and profile.batches==1 and session.draft==active)
    end)
    test("server context and invalid time rejects leave drafts balances and RNG untouched",function()
        local profile,session=setup();local original=session.draft
        local ok,reason=send(profile,session,9,nil,nil,function() error("over-cap reroll") end)
        assert(not ok and reason=="prompt_too_long")
        ok,reason=send(profile,session,8,9.99,10,function() error("backward time reroll") end)
        assert(not ok and reason=="prompt_cooldown")
        for _,now in ipairs({0/0,math.huge,-math.huge}) do assert(not send(profile,session,1,now,0)) end
        assert(session.draft==original and profile.credits==0 and profile.batches==0)
    end)
    test("capped money is the actual receipt amount and never overflows",function()
        local profile,session=setup(function() return 10000 end)
        profile.credits=B.MAX_CREDITS-0.5
        local ok,receipt=send(profile,session,8)
        assert(ok and receipt.reward==0.5 and profile.credits==B.MAX_CREDITS)
        assert(receipt.outputs[1].reward==0.5 and receipt.outputs[2].reward==0)
    end)
    test("invalid next-offer randomness cannot partly pay or consume a prompt",function()
        local profile,session=setup();local original=session.draft;local calls=0
        local ok,reason=send(profile,session,8,nil,nil,function() calls=calls+1;return calls==3 and 0/0 or 1 end)
        assert(not ok and reason=="invalid_reward_roll" and profile.credits==0 and profile.batches==0)
        assert(session.draft==original and session.sequence==1 and session.cursor==0)
        local empty=Session.new()
        assert(not Session.ensure(empty,profile,B,Prompt,function() return 10001 end) and empty.sequence==0)
    end)
    test("global agents workers and CPU improve prompt money while context only increases length",function()
        local profile=State.new(B);profile.credits=10000
        local initial=Session.baseReward(profile,B,Sim)
        assert(Rules.purchase(profile,"upgrade_workers",nil,B))
        local workers=Session.baseReward(profile,B,Sim);assert(workers>initial)
        assert(Rules.purchase(profile,"add_layer",nil,B))
        local agents=Session.baseReward(profile,B,Sim);assert(agents>workers)
        assert(Rules.purchase(profile,"upgrade_compute",nil,B))
        local cpu=Session.baseReward(profile,B,Sim);assert(cpu>agents)
        assert(Rules.purchase(profile,"upgrade_tokens",nil,B))
        assert(Session.baseReward(profile,B,Sim)==cpu and Prompt.limit(profile,B)==16)
    end)
    test("manual composition stops at context and only an explicit send creates a request",function()
        local _,session=setup();local state=Composer.new();Composer.update(state,Session.view(session.draft))
        for _=1,8 do assert(Composer.push(state,8)) end
        for _=1,100 do assert(not Composer.push(state,8)) end
        assert(state.count==8 and not state.flight)
        local request=assert(Composer.send(state,10,8,B))
        assert(request.draftId==1 and request.tokens==8 and state.flight)
        assert(not Composer.send(state,11,8,B) and not Composer.push(state,8) and not Composer.pop(state) and not Composer.clear(state))
    end)
    test("undo and clear preserve the same special offers instead of rerolling",function()
        local _,session=setup(function() return 10000 end)
        local state=Composer.new();Composer.update(state,Session.view(session.draft))
        local original=state.draft
        Composer.push(state,8);Composer.push(state,8);assert(Composer.pop(state) and state.count==1)
        assert(Composer.clear(state) and Composer.push(state,8))
        assert(state.draft==original and state.draft.offers[1].multiplier==250 and state.count==1)
    end)
    test("late receipts and draft updates cannot erase a newer manual prompt",function()
        local profile,session=setup();local state=Composer.new()
        Composer.update(state,Session.view(session.draft));Composer.push(state,8);Composer.send(state,10,8,B)
        local _,receipt=send(profile,session,1)
        assert(Composer.confirm(state,receipt,false,10,B))
        local old=state.draft;Composer.update(state,Session.view(session.draft));Composer.push(state,8)
        assert(not Composer.confirm(state,receipt,false,11,B) and state.count==1)
        assert(not Composer.update(state,old) and state.count==1 and state.draft.id==2)
    end)
    test("timeouts unlock only for explicit retry and never submit or reroll themselves",function()
        local _,session=setup();local state=Composer.new();Composer.update(state,Session.view(session.draft));Composer.push(state,8)
        Composer.send(state,10,8,B)
        assert(not Composer.timeout(state,10+B.LIVE_RECEIPT_TIMEOUT-0.1,B))
        assert(Composer.timeout(state,10+B.LIVE_RECEIPT_TIMEOUT,B) and not state.flight and state.count==1)
        assert(not Composer.timeout(state,100,B) and state.draft.id==1)
    end)
    test("reset advances offer IDs and baseline receipts never replay money",function()
        local profile,session=setup();Session.reset(session);assert(Session.ensure(session,profile,B,Prompt,function() return 1 end).id==2)
        assert(not Session.submit(session,profile,{draftId=1,tokens=1},10,-math.huge,B,Prompt,Sim,function() error("stale reset reroll") end))
        local cash=Cash.new();local receipt={id=7,reward=10}
        assert(not Cash.accept(cash,receipt,true,B) and not Cash.accept(cash,receipt,false,B) and #cash.items==0)
        assert(Cash.accept(cash,{id=8,reward=5},false,B));Cash.reset(cash)
        assert(not Cash.accept(cash,{id=8,reward=5},false,B) and #cash.items==0)
    end)
    test("cash feedback is bounded rises solid first fades and expires without changing money",function()
        local cash=Cash.new()
        for id=1,1000 do assert(Cash.accept(cash,{id=id,reward=id},false,B)) end
        assert(#cash.items==Cash.MAX_LABELS and cash.items[1].id==1001-Cash.MAX_LABELS)
        Cash.tick(cash,0.8)
        local y,alpha=Cash.pose(cash.items[1],false);assert(y<0 and alpha==0)
        local ry,ra=Cash.pose(cash.items[1],true);assert(ry==0 and ra==0)
        Cash.tick(cash,0.7);y,alpha=Cash.pose(cash.items[1],false);assert(y<0 and alpha>0 and alpha<1)
        Cash.tick(cash,1);assert(#cash.items==0)
    end)
    test("malformed feedback and composer snapshots cannot poison receipt watermarks",function()
        local cash,state=Cash.new(),Composer.new()
        for _,id in ipairs({0/0,math.huge,-1,1.5}) do
            assert(not Cash.accept(cash,{id=id,reward=1},false,B))
            assert(not Composer.confirm(state,{id=id},false,1,B))
        end
        assert(cash.lastReceipt==0 and state.lastReceipt==0)
        assert(not Composer.update(state,{id=1,offers={{word="<bad>",rank=1,multiplier=1}}}) and not state.draft)
        assert(not Cash.accept(cash,{id=1,reward=0/0},false,B))
    end)
    test("compact wire offers reconstruct identical highlighted words without shipping repeated tier data",function()
        local profile,session=setup(function() return 9890 end)
        profile.tokenLevel=B.MAX_TOKEN_LEVEL
        assert(Session.ensure(session,profile,B,Prompt,function() return 9690 end))
        local wire=Session.wire(session.draft)
        assert(#wire.ranks==64 and wire.offers==nil)
        local state=Composer.new();assert(Composer.update(state,wire,B,Prompt))
        for index,offer in ipairs(session.draft.offers) do
            local restored=state.draft.offers[index]
            assert(restored.word==offer.word and restored.multiplier==offer.multiplier and restored.denominator==offer.denominator)
        end
        wire.ranks[1]=999
        assert(not Composer.update(state,wire,B,Prompt) and state.draft.offers[1].rank==3)
    end)
    test("UI estimates cannot forge the server token tiers or payout",function()
        local profile,session=setup()
        local state=Composer.new();Composer.update(state,Session.wire(session.draft),B,Prompt)
        state.draft.offers[1].multiplier=250
        Composer.push(state,8)
        local request=assert(Composer.send(state,10,8,B))
        local ok,receipt=Session.submit(session,profile,request,10,-math.huge,B,Prompt,Sim,function() return 1 end)
        assert(ok and receipt.reward==1 and receipt.outputs[1].multiplier==1 and profile.credits==1)
    end)
    test("collection receipt exposes exact capped per-token rewards without client amount authority",function()
        local profile,session=setup(function() return 10000 end)
        profile.credits=B.MAX_CREDITS-0.5
        local ok,receipt=send(profile,session,3)
        assert(ok and profile.credits==B.MAX_CREDITS)
        local view=Prompt.receiptView(receipt,false)
        assert(not view.outputs and #view.tokenRewards==3 and view.tokenRewards[1]==0.5 and view.tokenRewards[2]==0 and view.tokenRewards[3]==0)
        view.tokenRewards[1]=999;assert(receipt.outputs[1].reward==0.5)
        assert(not m.Protocol.validate("submit_prompt",{draftId=2,tokens=3,tokenRewards={999}},B))
    end)
    test("confirmed collection consumes one token at a time in order and cannot replay",function()
        local profile,session=setup(function() return 9690 end)
        local visual=m.Collection.capture(session.draft,4)
        local ok,receipt=send(profile,session,4);assert(ok)
        local state=m.Collection.new();local view=Prompt.receiptView(receipt,false)
        assert(m.Collection.accept(state,view,visual,false,B))
        local events=m.Collection.tick(state,0,true)
        assert(#events==1 and events[1].tokenIndex==1 and events[1].amount==3)
        assert(#m.Collection.tick(state,0.1,false)==0 and state.collected==1)
        for _=1,4 do
            for _,event in ipairs(m.Collection.tick(state,0.11,true)) do events[#events+1]=event end
        end
        assert(#events==4 and state.amount==receipt.reward and #state.batches==0)
        for index,event in ipairs(events) do assert(event.tokenIndex==index and event.receiptId==receipt.id) end
        assert(not m.Collection.accept(state,view,visual,false,B) and #m.Collection.tick(state,10,true)==0)
        assert(profile.credits==receipt.reward)
    end)
    test("collection baseline malformed receipt pause and reset never replay or poison valid amounts",function()
        local profile,session=setup();local visual=m.Collection.capture(session.draft,2)
        local _,receipt=send(profile,session,2);local view=Prompt.receiptView(receipt,false)
        local state=m.Collection.new();local invalid=Prompt.receiptView(receipt,false)
        invalid.tokenRewards[1]=0/0;assert(not m.Collection.accept(state,invalid,visual,false,B) and state.lastReceipt==0)
        invalid.tokenRewards[1]=100;assert(not m.Collection.accept(state,invalid,visual,false,B) and state.lastReceipt==0)
        assert(not m.Collection.accept(state,view,visual,true,B) and state.lastReceipt==receipt.id)
        assert(not m.Collection.accept(state,view,visual,false,B))
        local live=m.Collection.new();assert(m.Collection.accept(live,view,visual,false,B))
        assert(#m.Collection.tick(live,100,false)==0 and live.collected==0)
        m.Collection.reset(live);assert(#live.batches==0 and not m.Collection.accept(live,view,visual,false,B))
    end)
    test("collection queues and token popup pools stay bounded through rapid sales and stalled frames",function()
        local state=m.Collection.new();local cash=Cash.new()
        for id=1,20 do
            local offers,rewards={},{}
            for index=1,128 do offers[index]={word="token",rank=1,multiplier=1};rewards[index]=1 end
            assert(m.Collection.accept(state,{id=id,draftId=id,tokens=128,reward=128,tokenRewards=rewards},{draftId=id,offers=offers},false,B))
        end
        assert(#state.batches==m.Collection.MAX_BATCHES and state.batches[1].id==17)
        local events=m.Collection.tick(state,100,true);assert(#events<=m.Collection.MAX_EVENTS)
        for index=1,100 do Cash.token(cash,{receiptId=20,tokenIndex=index,amount=1},120,100) end
        assert(#cash.items==Cash.MAX_LABELS)
        Cash.tick(cash,0.2,nil,true);assert(cash.items[1].age==0)
        Cash.tick(cash,0.2);local y,alpha=Cash.pose(cash.items[1],false);assert(y<0 and alpha==0)
        local ry,ra=Cash.pose(cash.items[1],true);assert(ry==0 and ra==0)
        Cash.tick(cash,0.4);assert(#cash.items==0)
    end)
    test("typing upgrade charges once globally changes speed and stops at the cap",function()
        local profile=State.new(B);local layers=table.concat(profile.layerSizes,",")
        assert(Prompt.agentTypingRate(profile,B)==4 and Rules.quote(profile,"upgrade_typing",nil,B)==4)
        assert(not Rules.purchase(profile,"upgrade_typing",nil,B) and profile.typingLevel==0)
        for level=1,B.MAX_TYPING_LEVEL do
            local cost=Rules.quote(profile,"upgrade_typing",nil,B)
            profile.credits=cost;assert(Rules.purchase(profile,"upgrade_typing",nil,B))
            assert(profile.credits==0 and profile.typingLevel==level and Prompt.agentTypingRate(profile,B)==4+2*level)
        end
        profile.credits=99
        assert(not Rules.purchase(profile,"upgrade_typing",nil,B) and profile.credits==99)
        assert(table.concat(profile.layerSizes,",")==layers and profile.computeLevel==0 and profile.tokenLevel==0)
    end)
    test("typing upgrade rejects client levels rates prices and per-agent targets",function()
        assert(not m.Protocol.validate("upgrade_typing",nil,B))
        for _,payload in ipairs({0,1,"20",{typingLevel=20},{rate=999},{cost=0}}) do
            local profile=State.new(B);profile.credits=100
            assert(not m.Protocol.validate("upgrade_typing",payload,B))
            assert(not Rules.purchase(profile,"upgrade_typing",payload,B))
            assert(profile.typingLevel==0 and profile.credits==100)
        end
    end)
    test("schemas one through six gain base typing without losing historical progression",function()
        for version=1,6 do
            local old=State.new(B);old.schemaVersion=version
            old.credits,old.computeLevel,old.tokenLevel,old.batches=123,2,3,7
            old.layerSizes={version>=6 and B.EMBEDDING_DIM or 2,3,5,1}
            old.typingLevel=999 -- No legacy schema could have purchased speed.
            if version==1 then old.tokenLevel=nil end
            if version==3 or version==4 then old.attentionHeads=1 end
            if version==4 then old.embDim,old.blockCount=3,2;old.layerSizes=nil end
            local parsed=assert(State.fromStored(old,B))
            assert(parsed.schemaVersion==B.SCHEMA_VERSION and parsed.typingLevel==0 and parsed.credits==123)
            assert(parsed.computeLevel==2 and parsed.batches==7 and parsed.layerSizes[1]==B.EMBEDDING_DIM)
            assert(parsed.tokenLevel==(version==1 and 0 or 3) and old.typingLevel==999)
            if version~=4 then assert(parsed.layerSizes[2]==3 and parsed.layerSizes[3]==5) end
        end
    end)
    test("schema seven refuses corrupt or missing typing levels and round trips valid speed",function()
        for _,value in ipairs({-1,0.5,21,math.huge,0/0,"1",false}) do
            local profile=State.new(B);profile.typingLevel=value
            local parsed,reason=State.fromStored(profile,B)
            assert(not parsed and reason=="invalid_typing_level")
        end
        local profile=State.new(B);profile.typingLevel=nil;assert(not State.fromStored(profile,B))
        profile.typingLevel=13
        assert(State.fromStored(State.copy(profile),B).typingLevel==13)
    end)
    test("typing speed migration respects repository leases and saves purchased speed",function()
        local old=State.new(B);old.schemaVersion=6;old.typingLevel=nil;old.credits=100
        local store={value={schemaVersion=6,data=old,lock={owner="other",expiresAt=10}}}
        function store:UpdateAsync(_,callback)
            local nextValue=callback(self.value)
            if nextValue then self.value=nextValue end
            return nextValue
        end
        local now=0;local repo=m.ProfileRepository.new(store,State,B,function() return now end,30)
        local handle,reason=repo:acquire("test","new")
        assert(not handle and reason=="profile_busy" and store.value.schemaVersion==6)
        now=11;handle=assert(repo:acquire("test","new"))
        assert(handle.state.typingLevel==0 and store.value.schemaVersion==B.SCHEMA_VERSION)
        assert(Rules.purchase(handle.state,"upgrade_typing",nil,B) and repo:save(handle,true))
        assert(repo:acquire("test","next").state.typingLevel==1)
    end)
    test("full manual prompts send consecutively without a typing budget or cooldown",function()
        local profile,session=setup()
        assert(send(profile,session,8,0) and profile.credits==8)
        assert(send(profile,session,8,0,0) and profile.credits==16)
        assert(send(profile,session,8,0.001,0) and profile.credits==24)
        assert(session.agentPace.budget==0 and not session.typing)
    end)
    test("composer sends immediately after a delayed receipt while preserving one flight",function()
        local profile,session=setup();local state=Composer.new()
        Composer.update(state,Session.view(session.draft));Composer.push(state,8)
        assert(Composer.send(state,0,8,B))
        assert(not Composer.send(state,0,8,B))
        local ok,receipt=send(profile,session,1,0)
        assert(ok and Composer.confirm(state,receipt,false,10,B))
        Composer.update(state,Session.view(session.draft));Composer.push(state,8)
        assert(Composer.send(state,10,8,B))
        assert(not Composer.send(state,10,8,B))
        assert(not Composer.confirm(state,receipt,false,10,B) and state.flight)
    end)
    test("Studio prompt cooldown is optional server owned and rejects without consuming awards or RNG",function()
        local profile,session=setup();session.skillSettings={promptCooldown=1}
        assert(send(profile,session,1,0))
        local draft=session.draft
        assert(not send(profile,session,1,0.999,0,function() error("cooldown reroll") end))
        assert(session.draft==draft and profile.credits==1)
        assert(send(profile,session,1,1,0) and profile.credits==2)
        session.skillSettings.promptCooldown=0
        assert(send(profile,session,1,1,1) and profile.credits==3)
    end)
    test("Studio cosmetic durations keep bounded jobs cash and music transport independent of rewards",function()
        local cash=Cash.new();assert(Cash.accept(cash,{id=1,reward=1},false,B))
        Cash.tick(cash,0.6,1);assert(#cash.items==1)
        local _,alpha=Cash.pose(cash.items[1],false,1);assert(alpha>0)
        Cash.tick(cash,0.4,1);assert(#cash.items==0)
        local slow,fast=m.Music.transport(),m.Music.transport()
        m.Music.advance(slow,0,0,0.5);m.Music.advance(fast,0,0,2)
        for _=1,10 do m.Music.advance(slow,0.05,0,0.5);m.Music.advance(fast,0.05,0,2) end
        assert(fast.step>slow.step and fast.step<=20)
        for _=1,1000 do
            assert(#m.Music.advance(fast,0.1,4,2)<=2)
            assert(fast.elapsed<60/m.Music.tempo(4)/4/2)
        end
    end)
    test("agent speed upgrade settles old rate and sync cannot mint agent budget",function()
        local profile,session=setup();profile.credits=100
        assert(m.Auto.advance(session,profile,1,B));near(session.agentPace.budget,4)
        assert(Rules.purchase(profile,"upgrade_typing",nil,B))
        assert(m.Auto.advance(session,profile,1,B));assert(session.agentPace.rate==6)
        for _=1,20 do Session.ensure(session,profile,B,Prompt,function() error("sync reroll") end,1) end
        near(session.agentPace.budget,4)
        assert(m.Auto.advance(session,profile,1.5,B));near(session.agentPace.budget,6)
        assert(not m.Auto.advance(session,profile,1,B) and session.agentPace.time==1.5)
    end)
    test("agent budget caps one second gives no idle money and resets cleanly",function()
        local profile,session=setup()
        assert(m.Auto.advance(session,profile,10000,B))
        assert(session.agentPace.budget==4 and profile.credits==0 and profile.batches==0)
        for _,now in ipairs({0/0,math.huge,-math.huge}) do assert(not m.Auto.advance(session,profile,now,B)) end
        Session.reset(session);assert(not session.agentPace)
        Session.ensure(session,profile,B,Prompt,function() return 1 end,10000)
        assert(m.Auto.advance(session,profile,10000,B))
        assert(session.agentPace.budget==0 and session.draft.id==2)
    end)
    test("STATS counts only accepted words and actual rewards and expires the ten-second rate",function()
        local profile,session=setup(function() return 9890 end)
        local ok,receipt=send(profile,session,3)
        assert(ok and receipt.reward==30)
        local stat=Session.statistics(session,10)
        assert(stat.earned==30 and stat.tokens==3 and stat.special==3 and stat.prompts==1)
        assert(stat.tiers[3]==3 and stat.moneyPerSecond==3)
        stat.tiers[3]=999;assert(Session.statistics(session,10).tiers[3]==3)
        assert(not Session.submit(session,profile,{draftId=1,tokens=3},11,10,B,Prompt,Sim,function() error("duplicate") end))
        stat=Session.statistics(session,20);assert(stat.moneyPerSecond==0 and stat.earned==30 and profile.credits==30)
        Session.reset(session);stat=Session.statistics(session,21)
        assert(stat.earned==0 and stat.tokens==0 and stat.special==0 and stat.moneyPerSecond==0)
    end)
    test("STATS rolling receipt history stays bounded across long prompt sessions",function()
        local profile,session=setup()
        for index=1,1000 do
            assert(send(profile,session,1,index*0.31,(index-1)*0.31))
            assert(#session.recent<=34)
        end
        local stat=Session.statistics(session,310)
        assert(stat.tokens==1000 and stat.prompts==1000 and stat.earned==profile.lifetimeEarned and stat.special==0)
        assert(stat.moneyPerSecond<=4.6)
    end)
    test("independent token object layout wraps full context at readable native scale",function()
        local profile,session=setup(function() return 10000 end)
        profile.tokenLevel=B.MAX_TOKEN_LEVEL
        Session.ensure(session,profile,B,Prompt,function() return 10000 end)
        for _,width in ipairs({120,240,640,1000}) do
            local positions,x,y,height=Composer.tokenLayout(session.draft.offers,64,width)
            assert(#positions==64 and x>=0 and x+Composer.TOKEN_STYLE.gap<=width and y+Composer.TOKEN_STYLE.rowHeight==height)
            for index,geometry in ipairs(positions) do
                assert(geometry.x>=0 and geometry.x+geometry.width<=width and geometry.y%Composer.TOKEN_STYLE.rowHeight==0)
                assert(string.find(geometry.text,"x250",1,true))
                if index>1 then assert(geometry.y>=positions[index-1].y) end
            end
        end
    end)
    test("complete prompt grows only vertically at the same width even beyond the viewport",function()
        local profile,session=setup(function() return 10000 end)
        profile.tokenLevel=B.MAX_TOKEN_LEVEL
        assert(Session.ensure(session,profile,B,Prompt,function() return 10000 end))
        for _,offer in ipairs(session.draft.offers) do offer.skillMultiplier=1000.9 end
        for _,viewport in ipairs({{1280,720},{1920,1080},{360,640},{640,360}}) do
            local maxWidth,maxHeight=viewport[1],viewport[2]-192
            local geometry=Composer.windowLayout(session.draft.offers,64,math.min(900,maxWidth),300,maxWidth,maxHeight,false)
            local positions,_,_,height=Composer.tokenLayout(session.draft.offers,64,geometry.width-60)
            assert(#positions==64 and geometry.tokenHeight==height)
            assert(geometry.panelHeight-66>=height and geometry.height>=geometry.panelHeight+82)
            assert(geometry.width==math.min(900,maxWidth))
            for _,position in ipairs(positions) do
                assert(position.x>=0 and position.x+position.width<=geometry.width-60)
                assert(position.y+Composer.TOKEN_STYLE.rowHeight<=geometry.panelHeight-66)
            end
        end
    end)
    test("prompt window retains grown dimensions across undo empty drafts and repeated full sends",function()
        local profile,session=setup();profile.tokenLevel=B.MAX_TOKEN_LEVEL
        assert(Session.ensure(session,profile,B,Prompt,function() return 1 end))
        local width,height=800,320
        for count=0,64 do
            local geometry=Composer.windowLayout(session.draft.offers,count,width,height,1280,528,false)
            assert(geometry.width==width and geometry.height>=height)
            width,height=geometry.width,geometry.height
        end
        for _,count in ipairs({63,1,0,64,0}) do
            local geometry=Composer.windowLayout(session.draft.offers,count,width,height,1280,528,false)
            assert(geometry.width==width and geometry.height==height)
        end
    end)
    test("fast letter reveal is monotonic bounded reduced and completes within typing interval",function()
        for _,speed in ipairs({4,6,20,44}) do
            for length=1,20 do
                local previous=0
                for step=0,100 do
                    local visible,done=Composer.revealCount(length,step/1000,speed,false)
                    assert(visible>=previous and visible<=length and done==(visible==length));previous=visible
                end
                local visible,done=Composer.revealCount(length,0.85/speed,speed,false)
                assert(visible==length and done)
                visible,done=Composer.revealCount(length,0,speed,true);assert(visible==length and done)
            end
        end
        local visible,done=Composer.revealCount(10,0.03,4,false)
        assert(visible==3 and not done)
    end)
    local function seedAwards(session,count,factor)
        session.skillAwards={}
        for index=1,count do session.skillAwards[index]={tokenIndex=index,grade="Agent",multiplier=factor or 1,streakMultiplier=factor or 1} end
    end
    local function chooseTarget(low) return low end
    local function skillHit(profile,session,index,grade)
        local check=m.Skill.ensure(session,session.draft,1,chooseTarget)
        local angle=grade=="Great" and check.target or grade=="Good" and check.target-25 or (check.target+130)%360
        local now=check.startsAt+((angle-(check.phaseOffset or 0))%360)/360*check.duration
        return m.Skill.click(session,session.draft,{draftId=session.draft.id,checkId=check.id,tokenIndex=index},now,4,chooseTarget)
    end
    test("skill phase wraps clockwise and pre-start clicks cannot be graded",function()
        local check={startsAt=10,duration=2.4,target=100}
        near(m.Skill.phase(check,10),0);near(m.Skill.phase(check,10.6),90)
        near(m.Skill.phase(check,12.4),0)
        assert(not m.Skill.grade(check,9) and not m.Skill.grade(check,0/0))
    end)
    test("skill zones distinguish normal good great and bounded trailing latency grace",function()
        local check={startsAt=0,duration=2.4,target=100}
        local function grade(angle) return m.Skill.grade(check,angle/360*2.4) end
        assert(grade(100)=="Great" and grade(75)=="Good" and grade(0)=="Normal")
        assert(grade(129)=="Great" and grade(131)=="Good" and grade(156)=="Normal")
    end)
    test("skill protocol refuses client grade time phase amount and forged IDs",function()
        local good={draftId=1,checkId=1,tokenIndex=1}
        assert(m.Protocol.validate("skill_click",good,B))
        for _,field in ipairs({"grade","time","phase","multiplier","amount","streak","streakMultiplier"}) do
            local value={draftId=1,checkId=1,tokenIndex=1};value[field]=2
            assert(not m.Protocol.validate("skill_click",value,B))
        end
        for _,value in ipairs({0,-1,1.2,math.huge}) do
            assert(not m.Protocol.validate("skill_click",{draftId=value,checkId=1,tokenIndex=1},B))
        end
    end)
    test("a skill challenge consumes once and its wire view cannot mutate server awards",function()
        local profile,session=setup();local check=m.Skill.ensure(session,session.draft,1,chooseTarget)
        assert(skillHit(profile,session,1,"Great"))
        assert(not m.Skill.click(session,session.draft,{draftId=session.draft.id,checkId=check.id,tokenIndex=1},10,4,chooseTarget))
        local view=m.Skill.view(session);assert(#view.awards==0);view.lastClick.multiplier=999
        assert(not session.skillAwards and session.lastSkillClick.multiplier==2 and profile.credits==0)
    end)
    test("editing sync and fresh timing checks cannot rewrite an existing agent award",function()
        local profile,session=setup();seedAwards(session,1,1.7)
        local old=session.skillAwards[1]
        assert(skillHit(profile,session,1,"Normal"))
        assert(skillHit(profile,session,1,"Great"))
        Session.ensure(session,profile,B,Prompt,chooseTarget)
        assert(session.skillAwards[1]==old and old.multiplier==1.7 and session.streak==1)
        assert(session.lastSkillClick.wordCount==0)
    end)
    test("agent bonuses multiply rarity and skill checks leave the locked sale unchanged",function()
        local profile,session=setup(function() return 9890 end)
        seedAwards(session,3,1.5);assert(skillHit(profile,session,1,"Great"));assert(skillHit(profile,session,2,"Good"))
        assert(skillHit(profile,session,3,"Normal"));assert(profile.credits==0)
        local ok,receipt=send(profile,session,3,10)
        assert(ok and profile.credits==45 and receipt.reward==45 and receipt.skillBonus==15)
        assert(receipt.outputs[1].skillMultiplier==1.5 and receipt.outputs[2].skillMultiplier==1.5)
        assert(Session.statistics(session,10).skillBonus==15 and not session.skillAwards)
        assert(Prompt.receiptView(receipt,false).skillBonus==15)
    end)
    test("agent payout caps money and duplicate submissions cannot repeat the bonus",function()
        local profile,session=setup();seedAwards(session,1,2);assert(skillHit(profile,session,1,"Great"))
        profile.credits=B.MAX_CREDITS-1.5
        local id=session.draft.id;local ok,receipt=send(profile,session,1,10)
        assert(ok and profile.credits==B.MAX_CREDITS and receipt.reward==1.5 and receipt.skillBonus==0.5)
        assert(not Session.submit(session,profile,{draftId=id,tokens=1},11,-math.huge,B,Prompt,Sim,function() return 1 end))
        assert(Session.statistics(session,11).prompts==1)
    end)
    test("invalid next randomness and out-of-context skill clicks leave awards and check intact",function()
        local profile,session=setup();local check=m.Skill.ensure(session,session.draft,1,chooseTarget)
        local payload={draftId=session.draft.id,checkId=check.id,tokenIndex=1}
        local now=check.startsAt+((check.target-(check.phaseOffset or 0))%360)/360*check.duration
        assert(not m.Skill.click(session,session.draft,payload,now,4,function() return 0 end))
        payload.tokenIndex=129;assert(not m.Skill.click(session,session.draft,payload,now,4,chooseTarget))
        assert(session.skillCheck==check and not session.skillAwards and profile.credits==0)
    end)
    test("reset preserves skill nonce sequence but clears awards and stale input",function()
        local profile,session=setup();assert(skillHit(profile,session,1,"Great"))
        local previous=session.skillSequence
        Session.reset(session);Session.ensure(session,profile,B,Prompt,function() return 1 end,10)
        local check=m.Skill.ensure(session,session.draft,10,chooseTarget)
        assert(check.id>previous and not session.skillAwards and not session.lastSkillClick)
    end)
    test("combined rarity and precision multiplier badges wrap with decimal width",function()
        local offers={{word="build",rank=1,multiplier=1,skillMultiplier=1.5},
            {word="test",rank=3,multiplier=10,skillMultiplier=2}}
        local positions=Composer.tokenLayout(offers,2,150)
        assert(string.find(positions[1].text,"x1.5",1,true) and string.find(positions[2].text,"x20",1,true))
        assert(positions[1].badgeWidth==4*Composer.TOKEN_STYLE.badgeSize and positions[2].y>positions[1].y)
    end)
    test("streak milestone factors and capped count use the post-hit tier",function()
        for _,item in ipairs({{0,1},{2,1},{3,1.25},{4,1.25},{5,1.5},{9,1.5},{10,2},{19,2},{20,3},{34,3},{35,4},{9999,4}}) do
            near(m.Skill.streakFactor(item[1]),item[2])
        end
        assert(m.Skill.nextTier(0).at==3 and m.Skill.nextTier(3).at==5 and not m.Skill.nextTier(35))
        local profile,session=setup();session.streak=m.Skill.MAX_STREAK
        assert(skillHit(profile,session,1,"Great"))
        assert(session.streak==9999 and session.bestStreak==9999 and session.lastSkillClick.multiplier==8 and not session.skillAwards)
    end)
    test("streak expires at five seconds preserving best awards nonce and continuous phase",function()
        local profile,session=setup()
        seedAwards(session,3,2.5)
        for index=1,3 do assert(skillHit(profile,session,index,"Great")) end
        assert(m.Collectibles.issue(session,session.lastSkillClick,profile,chooseTarget))
        local check,deadline=session.skillCheck,session.streakExpiresAt
        local award=session.skillAwards[3]
        assert(not m.Skill.expireStreak(session,deadline-0.001) and session.streak==3)
        local phase=m.Skill.phase(check,deadline)
        assert(m.Skill.expireStreak(session,deadline))
        assert(session.streak==0 and session.streakMultiplier==1 and session.bestStreak==3)
        assert(not session.streakExpiresAt and #m.Collectibles.view(session).items==0)
        assert(session.skillAwards[3]==award and award.multiplier==2.5 and session.skillCheck==check)
        near(m.Skill.phase(check,deadline),phase);near(check.duration,m.Skill.DURATION)
        assert(not m.Skill.expireStreak(session,deadline+100))
        local now=deadline+((check.target-phase)%360)/360*check.duration
        assert(m.Skill.click(session,session.draft,{draftId=session.draft.id,checkId=check.id,tokenIndex=4},now,0,chooseTarget))
        assert(session.streak==1 and session.bestStreak==3 and session.skillAwards[3]==award)
    end)
    test("accepted skill and avatar clicks refresh expiry while duplicates sync sends and reset do not",function()
        local profile,session=setup();assert(skillHit(profile,session,1,"Great"))
        local deadline=session.streakExpiresAt
        assert(m.Collectibles.issue(session,session.lastSkillClick,profile,chooseTarget))
        local id=session.avatarItems[1].id
        assert(m.Collectibles.collect(session,id,deadline-0.1,chooseTarget,m.Skill))
        near(session.streakExpiresAt,deadline+4.9)
        local extended=session.streakExpiresAt
        assert(not m.Collectibles.collect(session,id,extended-0.1,chooseTarget,m.Skill))
        Session.ensure(session,profile,B,Prompt,chooseTarget)
        assert(send(profile,session,1,2) and session.streakExpiresAt==extended)
        assert(not m.Skill.expireStreak(session,extended-0.001))
        assert(m.Skill.expireStreak(session,extended) and session.streak==0)
        Session.reset(session);assert(not session.streakExpiresAt and session.bestStreak==0)
    end)
    test("streak difficulty is monotonic and safely caps speed and both zone widths",function()
        local previousDuration,previousGood,previousGreat=3,73,25
        for count=0,70 do
            local duration,good,great=m.Skill.difficulty(count)
            assert(duration<=previousDuration and good<=previousGood and great<=previousGreat)
            assert(duration>=0.55 and good>=28 and great>=8 and great<good)
            previousDuration,previousGood,previousGreat=duration,good,great
        end
        near(previousDuration,0.55);near(previousGood,28);near(previousGreat,8)
        local check={startsAt=0,duration=1.2,target=100,goodWidth=28,greatWidth=8}
        assert(m.Skill.grade(check,111/360*1.2)=="Good") -- Grace cannot fill the hard great zone.
    end)
    test("third timing hit updates its feedback tier without rewriting agent payout",function()
        local profile,session=setup();seedAwards(session,3,1.1)
        for index=1,3 do assert(skillHit(profile,session,index,"Great")) end
        assert(session.streak==3 and session.lastSkillClick.multiplier==2.5)
        for index=1,3 do near(session.skillAwards[index].multiplier,1.1) end
        local ok,receipt=send(profile,session,3,10)
        assert(ok);near(receipt.reward,3.3)
    end)
    test("normal attempt breaks current streak and restores easy difficulty without touching old rewards",function()
        local profile,session=setup();seedAwards(session,4,1.3)
        for index=1,3 do assert(skillHit(profile,session,index,"Great")) end
        assert(skillHit(profile,session,4,"Normal"))
        assert(session.streak==0 and session.bestStreak==3 and session.lastSkillClick.streakBroken)
        near(session.skillCheck.duration,m.Skill.DURATION);near(session.skillCheck.goodWidth,72)
        near(session.skillAwards[3].multiplier,1.3);near(session.skillAwards[4].multiplier,1.3)
        local ok,receipt=send(profile,session,4,10)
        assert(ok);near(receipt.reward,5.2)
    end)
    test("streak survives prompt send sync and context expansion instead of resetting",function()
        local profile,session=setup()
        for index=1,3 do assert(skillHit(profile,session,index,"Great")) end
        assert(send(profile,session,3,10))
        profile.tokenLevel=1;Session.ensure(session,profile,B,Prompt,function() return 1 end,11)
        local check=m.Skill.ensure(session,session.draft,11,chooseTarget)
        near(check.duration,m.Skill.difficulty(3))
        assert(skillHit(profile,session,1,"Great") and session.streak==4)
        assert(not session.skillAwards and session.lastSkillClick.wordCount==0)
    end)
    test("fresh timing nonces build streak at the same token index without editing its award",function()
        local profile,session=setup();seedAwards(session,1,1.2)
        local old=session.skillAwards[1]
        for _=1,21 do assert(skillHit(profile,session,1,"Great")) end
        assert(session.streak==21 and not session.lastSkillClick.reused)
        assert(skillHit(profile,session,1,"Normal") and session.streak==0)
        assert(session.skillAwards[1]==old and old.multiplier==1.2)
        assert(skillHit(profile,session,1,"Great") and session.streak==1)
    end)
    test("invalid randomness and duplicate checks cannot partially advance a streak",function()
        local profile,session=setup();assert(skillHit(profile,session,1,"Great"))
        local check=session.skillCheck
        local payload={draftId=session.draft.id,checkId=check.id,tokenIndex=2}
        local now=check.startsAt+((check.target-(check.phaseOffset or 0))%360)/360*check.duration
        assert(not m.Skill.click(session,session.draft,payload,now,4,function() return 0 end))
        assert(session.streak==1 and session.bestStreak==1 and not session.skillAwards and session.skillCheck==check)
        assert(m.Skill.click(session,session.draft,payload,now,4,chooseTarget) and session.streak==2)
        assert(not m.Skill.click(session,session.draft,payload,now+1,4,chooseTarget) and session.streak==2)
    end)
    test("streak snapshot copies and explicit session reset preserve authority and nonce monotonicity",function()
        local profile,session=setup()
        for index=1,3 do assert(skillHit(profile,session,index,"Great")) end
        local sequence=session.skillSequence;local view=m.Skill.view(session)
        view.streak=999;view.streakMultiplier=999;view.lastClick.streakMultiplier=999
        assert(session.streak==3 and session.lastSkillClick.streakMultiplier==1.25 and not session.skillAwards)
        Session.reset(session);Session.ensure(session,profile,B,Prompt,function() return 1 end,10)
        local check=m.Skill.ensure(session,session.draft,10,chooseTarget)
        assert(check.id>sequence and session.streak==0 and session.bestStreak==0 and session.streakMultiplier==1)
    end)
    test("mascot dance speed and movement grow with confirmed streak and cap at forty",function()
        local previous=m.Dance.parameters(0)
        assert(previous.rate==0 and previous.tilt==0)
        for streak=1,40 do
            local parameters=m.Dance.parameters(streak)
            for _,key in ipairs({"rate","sway","lift","tilt","squash"}) do assert(parameters[key]>previous[key]) end
            previous=parameters
        end
        near(previous.rate,4.5);near(previous.tilt,16)
        local capped=m.Dance.parameters(9999)
        for key,value in pairs(previous) do near(capped[key],value) end
    end)
    test("every blended dance pose keeps all rotated corners inside the fixed mascot slot",function()
        for _,streak in ipairs({1,3,10,20,35,40,9999}) do
            local parameters=m.Dance.parameters(streak)
            for step=0,128 do
                for _,blend in ipairs({0,0.25,0.5,1}) do
                    local x,y,angle,sx,sy=m.Dance.pose(parameters,step/128*m.Dance.TAU,blend)
                    assert(sx>0 and sy>0)
                    local cosine,sine=math.cos(math.rad(angle)),math.sin(math.rad(angle))
                    for _,cx in ipairs({-32*sx,32*sx}) do
                        for _,cy in ipairs({-20*sy,20*sy}) do
                            local px=(0.5+x)*64+cx*cosine-cy*sine
                            local py=(0.5+y)*40+cx*sine+cy*cosine
                            assert(px>=-0.00001 and px<=64.00001 and py>=-0.00001 and py<=40.00001)
                        end
                    end
                end
            end
        end
    end)
    test("cosmetic dance clock is bounded and rest is neutral without catching up long frames",function()
        local phase=0
        for _=1,10000 do phase=m.Dance.advance(phase,1/60,4.5);assert(phase>=0 and phase<m.Dance.TAU) end
        near(m.Dance.advance(0,20,4.5),m.Dance.advance(0,0.1,4.5))
        near(m.Dance.advance(phase,-1,4.5),phase);near(m.Dance.advance(phase,0/0,4.5),phase)
        local x,y,angle,sx,sy=m.Dance.pose(m.Dance.parameters(0),3,1)
        assert(x==0 and y==0 and angle==0 and sx==1 and sy==1)
    end)
    test("elevator score repeats at fixed tempo with bounded harmony bass melody and transport",function()
        local M=m.Music;assert(M.BPM==88)
        local count,pitches,live=0,{},{}
        for step=0,255 do
            local now=step*60/M.BPM/4;local active=0
            for _,expiry in ipairs(live) do if expiry>now then active=active+1 end end
            local notes=M.events(step%128)
            assert(#notes<=5)
            for _,note in ipairs(notes) do
                count=count+1;pitches[note.pitch]=true
                assert(not note.sustain and note.duration>0 and note.gain<=0.07 and note.pitch>0 and note.pitch<4)
                assert(note.asset==M.TONE or note.asset==M.TAP)
                live[#live+1]=now+note.duration;active=active+1
            end
            assert(active<=16)
        end
        assert(count>100)
        local distinct=0;for _ in pairs(pitches) do distinct=distinct+1 end;assert(distinct>8)
        local clock=M.transport();assert(M.advance(clock,0)[1]==0)
        local short,long=M.transport(),M.transport();M.advance(short,0);M.advance(long,0)
        M.advance(short,0.1);M.advance(long,30);assert(short.step==long.step and short.elapsed==long.elapsed)
        for _=1,10000 do assert(#M.advance(clock,1/60)<=2 and clock.step>=0 and clock.step<128) end
        assert(#M.advance(clock,0/0)==0 and #M.advance(clock,-1)==0)
    end)
    test("streak melody follows a repeating connected phrase with identical good great lead",function()
        local M=m.Music;local expected={69,72,74,76,79,76,74,72}
        for streak=1,64 do
            local good,great=M.cue("Good",streak),M.cue("Great",streak)
            near(good[1].pitch,M.pitch(expected[(streak-1)%8+1]))
            near(great[1].pitch,good[1].pitch);near(great[2].pitch,good[1].pitch*2)
            assert(good[1].duration>=0.6 and good[1].attack>0)
            local nextNote=M.cue("Good",streak+1)[1]
            assert(math.abs(12*math.log(nextNote.pitch/good[1].pitch)/math.log(2))<=5.00001)
        end
        near(M.cue("Good",1)[1].pitch,M.cue("Good",9)[1].pitch)
    end)
    test("soft envelopes and harmonic success cues distinguish normal good and great",function()
        local M=m.Music
        assert(#M.cue("Normal")==0 and #M.cue("Good")==1 and #M.cue("Great")==2)
        near(M.pitch(81)/M.pitch(69),2)
        for _,duration in ipairs({0.055,0.09,0.27,0.5,2.8}) do
            assert(M.envelope(0,duration,0.005)==0 and M.envelope(duration,duration,0.005)==0)
            for step=0,100 do
                local gain=M.envelope(duration*step/100,duration,0.005)
                assert(gain>=0 and gain<=1)
            end
        end
    end)
    test("skill angle remains continuous across speed changes cooldown and new drafts",function()
        local profile,session=setup()
        local check=session.skillCheck or m.Skill.ensure(session,session.draft,10,chooseTarget)
        local now=check.startsAt+0.7
        local phase=m.Skill.phase(check,now)
        assert(m.Skill.click(session,session.draft,{draftId=session.draft.id,checkId=check.id,tokenIndex=1},now,4,chooseTarget))
        near((m.Skill.phase(session.skillCheck,now)-phase+180)%360-180,0)
        local nextCheck=session.skillCheck
        assert(m.Skill.grade(nextCheck,now))
        assert(m.Skill.phase(nextCheck,now+0.1)~=m.Skill.phase(nextCheck,now))
        session.draft.id=session.draft.id+1
        local fresh=m.Skill.ensure(session,session.draft,now+0.1,chooseTarget)
        near((m.Skill.phase(fresh,now+0.1)-m.Skill.phase(nextCheck,now+0.1)+180)%360-180,0)
        local duration=m.Skill.difficulty(5,{initialRps=0.75,growth=1.065})
        near(duration,1/0.75/1.065^5)
    end)
    test("schema eight migrates seven click base without accepting corrupt current levels",function()
        local old=State.new(B);old.schemaVersion=7;old.clickLevel=nil;old.typingLevel=9
        local parsed=assert(State.fromStored(old,B))
        assert(parsed.clickLevel==0 and parsed.typingLevel==9 and parsed.schemaVersion==B.SCHEMA_VERSION and old.clickLevel==nil)
        for _,value in ipairs({-1,4,1.5,0/0,math.huge,"3"}) do
            local profile=State.new(B);profile.clickLevel=value;assert(not State.fromStored(profile,B))
        end
        local profile=State.new(B);profile.clickLevel=nil;assert(not State.fromStored(profile,B))
        profile.clickLevel=3;assert(State.fromStored(State.copy(profile),B).clickLevel==3)
    end)
    test("global words per click purchase debits atomically caps at four and refuses payloads",function()
        local profile=State.new(B)
        assert(not Rules.purchase(profile,"upgrade_click",nil,B) and profile.clickLevel==0)
        for level=1,3 do
            local cost=Rules.quote(profile,"upgrade_click",nil,B);profile.credits=cost
            assert(Rules.purchase(profile,"upgrade_click",nil,B) and profile.clickLevel==level and profile.credits==0)
        end
        assert(not Rules.purchase(profile,"upgrade_click",nil,B) and profile.clickLevel==3)
        assert(not m.Protocol.validate("upgrade_click",nil,B))
        for _,payload in ipairs({1,4,{words=4},{price=0}}) do
            assert(not m.Protocol.validate("upgrade_click",payload,B))
            assert(not Rules.purchase(profile,"upgrade_click",payload,B))
        end
    end)
    test("streak words formula uses post-hit counts and multiplies purchased base",function()
        for _,entry in ipairs({{0,1},{4,1},{5,2},{9,2},{10,3},{15,4},{20,5},{9999,2000}}) do
            for base=1,4 do assert(m.Skill.wordsPerClick(entry[1],base)==entry[2]*base) end
        end
        near(m.Skill.difficulty(0),1)
    end)
    test("high base timing checks never grant words or spend agent budget",function()
        local profile,session=setup();session.streak=4
        local check=m.Skill.ensure(session,session.draft,1,chooseTarget)
        local now=check.startsAt+check.target/360*check.duration
        local payload={draftId=session.draft.id,checkId=check.id,tokenIndex=3}
        local ok,result=m.Skill.click(session,session.draft,payload,now,4,chooseTarget,4)
        assert(ok and result.wordCount==0 and session.streak==5)
        assert(not session.skillAwards)
        local budget=session.agentPace.budget
        assert(not m.Skill.click(session,session.draft,payload,now,4,chooseTarget,4))
        assert(session.agentPace.budget==budget and session.streak==5)
        assert(skillHit(profile,session,3,"Great") and session.lastSkillClick.wordCount==0 and session.streak==6)
        assert(session.agentPace.budget==budget)
    end)
    test("schema nine migrates eight under leases and validates divisor levels",function()
        local old=State.new(B);old.schemaVersion=8;old.divisorLevel=nil;old.clickLevel=3;old.credits=100
        local parsed=assert(State.fromStored(old,B));assert(parsed.divisorLevel==0 and parsed.clickLevel==3)
        for _,value in ipairs({-1,4,0.5,0/0,math.huge,"1"}) do
            local profile=State.new(B);profile.divisorLevel=value;assert(not State.fromStored(profile,B))
        end
        local profile=State.new(B);profile.divisorLevel=nil;assert(not State.fromStored(profile,B))
        local store={value={schemaVersion=8,data=old,lock={owner="other",expiresAt=10}}}
        function store:UpdateAsync(_,callback) local nextValue=callback(self.value);if nextValue then self.value=nextValue end;return nextValue end
        local now=0;local repo=m.ProfileRepository.new(store,State,B,function() return now end,30)
        assert(not repo:acquire("test","new") and store.value.schemaVersion==8)
        now=11;local handle=assert(repo:acquire("test","new"))
        assert(handle.state.divisorLevel==0 and Rules.purchase(handle.state,"upgrade_divisor",nil,B))
        assert(repo:save(handle,true) and repo:acquire("test","next").state.divisorLevel==1)
    end)
    test("C upgrade and authored modifiers share one bounded divisor and reject client tuning",function()
        local profile=State.new(B);assert(Rules.streakDivisor(profile,B)==5)
        assert(not Rules.purchase(profile,"upgrade_divisor",nil,B))
        for level=1,3 do
            profile.credits=Rules.quote(profile,"upgrade_divisor",nil,B)
            assert(Rules.purchase(profile,"upgrade_divisor",nil,B) and profile.credits==0)
            assert(Rules.streakDivisor(profile,B)==5-level)
        end
        assert(not Rules.purchase(profile,"upgrade_divisor",nil,B))
        assert(Rules.streakDivisor(profile,B,{{add=-10}})==1)
        assert(Rules.streakDivisor(profile,B,{{add=2,multiply=2}})==8)
        for _,payload in ipairs({0,1,{c=1},{price=0}}) do
            assert(not m.Protocol.validate("upgrade_divisor",payload,B))
            assert(not Rules.purchase(profile,"upgrade_divisor",payload,B))
        end
        for c=1,8 do
            assert(m.Skill.wordsPerClick(c-1,4,c)==4)
            assert(m.Skill.wordsPerClick(c,4,c)==8 and m.Skill.wordsPerClick(2*c,4,c)==12)
        end
    end)
    test("four rock tiers use C multiples and capped increasing tempos",function()
        local M=m.Music
        for _,c in ipairs({1,2,3,5,8}) do
            assert(M.tier(c-0.01,c)==0)
            for tier=1,4 do
                assert(M.tier(tier*c,c)==tier and M.tier(tier*c-0.01,c)==tier-1)
                assert(M.tempo(tier)>M.tempo(tier-1))
            end
            assert(M.tier(9999,c)==4)
        end
        assert(M.tempo(0)==88 and M.tempo(4)==176)
    end)
    test("all rock arrangements fit music pools and transport survives mode changes without backlog",function()
        local M=m.Music;local densities={}
        for tier=1,4 do
            local live,total={},0
            for step=0,255 do
                local now=step*60/M.tempo(tier)/4;local active=0
                for _,expiry in ipairs(live) do if expiry>now then active=active+1 end end
                for _,note in ipairs(M.events(step%128,tier)) do
                    assert(note.pitch>0 and note.pitch<4 and note.duration>0 and note.gain<=0.07)
                    live[#live+1]=now+note.duration;active=active+1;total=total+1
                end
                assert(active<=16)
            end
            densities[tier]=total
        end
        assert(densities[2]>densities[1] and densities[3]>densities[2] and densities[4]>densities[3])
        local clock=M.transport();M.advance(clock,0,0)
        for i=1,10000 do assert(#M.advance(clock,i%100==0 and 30 or 1/60,i%5)<=2 and clock.step<128) end
    end)
    test("eight words per second are generated one at each eighth second without idle catchup",function()
        local profile,session=setup();profile.typingLevel=2;profile.clickLevel=3;profile.tokenLevel=15
        session.streak=5;session.skillSettings={agentJitter=0}
        Session.ensure(session,profile,B,Prompt,function() return 1 end,0)
        m.Auto.advance(session,profile,0,B,Rules,m.Skill)
        near(session.agentPace.productionRate,8)
        assert(not m.Auto.grant(session,profile,{requestId=1,draftId=1,tokenIndex=1},0.124,B,Rules,m.Skill))
        for index=1,8 do
            assert(m.Auto.grant(session,profile,{requestId=index,draftId=1,tokenIndex=index},index/8,B,Rules,m.Skill))
            assert(session.autoReceipt.wordCount==1 and session.autoReceipt.sources[1].wordCount==1)
            near(session.agentPace.agents[1].nextAt,(index+1)/8)
        end
        assert(profile.credits==0 and session.streak==5)
        assert(m.Auto.grant(session,profile,{requestId=9,draftId=1,tokenIndex=9},1000,B,Rules,m.Skill))
        assert(session.autoReceipt.wordCount==1)
        near(session.agentPace.agents[1].nextAt,1000.125)
    end)
    test("independent agent phases and bounded timing variation spread words without consuming reward randomness",function()
        local profile,session=setup();profile.typingLevel=2;profile.clickLevel=3;profile.tokenLevel=15
        profile.layerSizes={B.EMBEDDING_DIM,2,2,1};session.streak=5
        Session.ensure(session,profile,B,Prompt,function() return 1 end,0)
        m.Auto.advance(session,profile,0,B,Rules,m.Skill)
        local first,second=session.agentPace.agents[1],session.agentPace.agents[2]
        assert(first.nextAt~=second.nextAt)
        local events={{},{}};local count,request=0,0
        for step=1,420 do
            request=request+1
            local now=step*0.005
            if m.Auto.grant(session,profile,{requestId=request,draftId=1,tokenIndex=count+1},now,B,Rules,m.Skill) then
                count=count+session.autoReceipt.wordCount
                for _,source in ipairs(session.autoReceipt.sources) do
                    assert(source.wordCount==1);events[source.agentIndex][#events[source.agentIndex]+1]=now
                end
            end
        end
        assert(#events[1]>=16 and #events[2]>=15 and events[1][1]~=events[2][1])
        local shortest,longest=1,0
        for index=2,#events[1] do
            local gap=events[1][index]-events[1][index-1]
            shortest=math.min(shortest,gap);longest=math.max(longest,gap)
            assert(gap>=0.11 and gap<=0.145)
        end
        assert(longest>shortest+0.005 and profile.credits==0 and session.streak==5)
    end)
    test("agent grants use owned TPC agent count context and never modify streak or money",function()
        local profile,session=setup();profile.layerSizes={B.EMBEDDING_DIM,2,2,1};profile.clickLevel=1;profile.tokenLevel=1
        Session.ensure(session,profile,B,Prompt,function() return 1 end,0)
        m.Auto.advance(session,profile,0,B)
        session.streak=10;session.bestStreak=10;session.skillAwards={[2]={tokenIndex=2,grade="Great",multiplier=3}}
        local request={requestId=1,draftId=session.draft.id,tokenIndex=1}
        assert(m.Auto.grant(session,profile,request,1,B,Rules,m.Skill))
        assert(session.autoReceipt.wordCount==1 and session.streak==10 and session.bestStreak==10 and profile.credits==0)
        assert(m.Auto.grant(session,profile,{requestId=2,draftId=1,tokenIndex=2},1.12,B,Rules,m.Skill))
        assert(session.skillAwards[1].grade=="Agent" and session.skillAwards[1].multiplier==2 and session.skillAwards[2].multiplier==3)
        assert(session.agentPace.budget>0)
        local ok,receipt=send(profile,session,2,10)
        assert(ok and receipt.reward==5*Session.baseReward(profile,B,Sim) and session.streak==10)
    end)
    test("agent cadence duplicates stale drafts and forged computed values cannot grant words",function()
        local profile,session=setup();local request={requestId=1,draftId=session.draft.id,tokenIndex=1}
        assert(not m.Auto.grant(session,profile,request,0.5,B,Rules,m.Skill))
        for _,bad in ipairs({{}, {requestId=1,draftId=1,tokenIndex=0},{requestId=1,draftId=1,tokenIndex=1,tpc=100},
            {requestId=1,draftId=1,tokenIndex=1,streak=100},{requestId=1,draftId=1,tokenIndex=1,agents=8}}) do
            assert(not m.Protocol.validate("agent_type",bad,B) and not m.Auto.grant(session,profile,bad,1,B,Rules,m.Skill))
        end
        assert(m.Auto.grant(session,profile,request,1,B,Rules,m.Skill));local budget=session.agentPace.budget
        assert(not m.Auto.grant(session,profile,request,10,B,Rules,m.Skill) and session.agentPace.budget==budget)
        assert(not m.Auto.grant(session,profile,{requestId=2,draftId=1,tokenIndex=2},1.5,B,Rules,m.Skill))
        assert(m.Auto.grant(session,profile,{requestId=2,draftId=1,tokenIndex=2},2.1,B,Rules,m.Skill))
    end)
    test("agent grants clamp to context restore fixed awards without extra budget and reset cleanly",function()
        local profile,session=setup();profile.clickLevel=3;session.streak=40
        assert(m.Auto.grant(session,profile,{requestId=1,draftId=1,tokenIndex=7},1,B,Rules,m.Skill))
        assert(session.autoReceipt.wordCount==1 and session.skillAwards[7].multiplier==5)
        assert(m.Auto.grant(session,profile,{requestId=2,draftId=1,tokenIndex=8},1.3,B,Rules,m.Skill))
        assert(session.skillAwards[8].multiplier==5)
        local budget=session.agentPace.budget
        assert(m.Auto.grant(session,profile,{requestId=3,draftId=1,tokenIndex=7},2,B,Rules,m.Skill))
        assert(session.agentPace.budget==4 and session.streak==40)
        Session.reset(session);assert(not session.autoReceipt and not session.autoSequence and not session.autoTime)
    end)
    test("agent speed cap increases with its upgrade while manual grants never spend it",function()
        local profile,session=setup();profile.layerSizes={B.EMBEDDING_DIM,2,2,1};profile.clickLevel=3;profile.tokenLevel=15;session.streak=10
        Session.ensure(session,profile,B,Prompt,function() return 1 end,0)
        m.Auto.advance(session,profile,0,B)
        assert(m.Auto.grant(session,profile,{requestId=1,draftId=1,tokenIndex=1},1,B,Rules,m.Skill))
        assert(session.autoReceipt.wordCount==1 and session.agentPace.budget==7)
        profile.credits=100;assert(Rules.purchase(profile,"upgrade_typing",nil,B))
        assert(m.Auto.advance(session,profile,1,B))
        assert(m.Auto.grant(session,profile,{requestId=2,draftId=1,tokenIndex=9},2,B,Rules,m.Skill))
        assert(session.autoReceipt.wordCount==2 and session.agentPace.budget>0)
        local budget=session.agentPace.budget
        assert(skillHit(profile,session,21,"Great") and session.agentPace.budget==budget)
        assert(send(profile,session,24,2))
    end)
    test("purchased agents get independent speed budgets without inheriting idle capacity",function()
        local profile,session=setup();profile.clickLevel=3;profile.tokenLevel=1
        Session.ensure(session,profile,B,Prompt,function() return 1 end,0)
        m.Auto.advance(session,profile,10,B)
        local first=session.agentPace.agents[1];assert(first.budget==4)
        profile.credits=Rules.quote(profile,"add_layer",nil,B);assert(Rules.purchase(profile,"add_layer",nil,B))
        m.Auto.advance(session,profile,10,B)
        local second=session.agentPace.agents[2]
        assert(first~=second and first.budget==4 and second.budget==0 and second.time==10)
        assert(m.Auto.grant(session,profile,{requestId=1,draftId=1,tokenIndex=1},10,B,Rules,m.Skill))
        assert(session.autoReceipt.wordCount==1 and first.budget==3 and second.budget==0)
        assert(m.Auto.grant(session,profile,{requestId=2,draftId=1,tokenIndex=5},11,B,Rules,m.Skill))
        assert(session.autoReceipt.wordCount==2 and first.budget==3 and second.budget==3)
        m.Auto.advance(session,profile,11,B);assert(first.budget==3 and second.budget==3)
    end)
    test("each producer keeps its own deadline across other agents and manual skill clicks",function()
        local profile,session=setup();profile.clickLevel=3;profile.tokenLevel=3
        Session.ensure(session,profile,B,Prompt,function() return 1 end,0)
        profile.credits=Rules.quote(profile,"add_layer",nil,B);assert(Rules.purchase(profile,"add_layer",nil,B))
        m.Auto.advance(session,profile,0.4,B)
        local first,second=session.agentPace.agents[1],session.agentPace.agents[2]
        near(first.nextAt,1);assert(second.nextAt>1.4)
        assert(m.Auto.grant(session,profile,{requestId=1,draftId=1,tokenIndex=1},1,B,Rules,m.Skill))
        assert(session.autoReceipt.wordCount==1 and #session.autoReceipt.sources==1)
        assert(session.autoReceipt.sources[1].agentIndex==1)
        local firstDue,secondDue=first.nextAt,second.nextAt
        assert(skillHit(profile,session,5,"Great"))
        near(first.nextAt,firstDue);near(second.nextAt,secondDue)
        assert(m.Auto.grant(session,profile,{requestId=2,draftId=1,tokenIndex=9},secondDue,B,Rules,m.Skill))
        assert(session.autoReceipt.wordCount==1 and session.autoReceipt.sources[1].agentIndex==2)
        near(first.nextAt,firstDue)
        assert(m.Auto.grant(session,profile,{requestId=3,draftId=1,tokenIndex=13},firstDue,B,Rules,m.Skill))
        assert(session.autoReceipt.sources[1].agentIndex==1)
    end)
    test("agent streak buff locks rarity reward across loss restore sync and prompt payout",function()
        local profile,session=setup(function() return 9890 end)
        session.streak=10
        local request={requestId=1,draftId=session.draft.id,tokenIndex=1}
        assert(m.Auto.grant(session,profile,request,1,B,Rules,m.Skill))
        assert(session.skillAwards[1].multiplier==2 and session.skillAwards[1].streak==10)
        session.streak=0
        assert(m.Auto.grant(session,profile,{requestId=2,draftId=1,tokenIndex=1},2,B,Rules,m.Skill))
        assert(session.skillAwards[1].multiplier==2 and session.streak==0)
        assert(m.Auto.grant(session,profile,{requestId=3,draftId=1,tokenIndex=4},3.1,B,Rules,m.Skill))
        assert(session.skillAwards[4].multiplier==1)
        local ok,receipt=send(profile,session,4,3)
        assert(ok and receipt.reward==50 and receipt.outputs[1].skillGrade=="Agent")
        assert(receipt.outputs[1].skillMultiplier==2 and receipt.outputs[4].skillMultiplier==1)
    end)
    test("avatar rarity tickets match exact weights and views cannot mutate issued rewards",function()
        local counts={0,0,0,0,0};local profile=State.new(B)
        for roll=1,10000 do
            local session={streak=1}
            assert(m.Collectibles.issue(session,{grade="Great"},profile,function(_,high) return high==10000 and roll or 1 end))
            local view=m.Collectibles.view(session);local rank=view.items[1].rank
            counts[rank]=counts[rank]+1;view.items[1].rank=99
            assert(session.avatarItems[1].rank==rank)
        end
        for rank,tier in ipairs(m.Collectibles.RARITIES) do assert(counts[rank]==tier.weight) end
    end)
    test("avatar spawn tickets give exactly thirty percent independently of rarity and preserve skipped state",function()
        local profile=State.new(B);local spawned=0
        for ticket=1,100 do
            local session={streak=3,streakExpiresAt=10}
            local draws=0
            local ok=m.Collectibles.issue(session,{grade="Good"},profile,function(low,high)
                draws=draws+1
                if high==100 then return ticket end
                return high==10000 and 9901 or low
            end)
            if ticket<=m.Collectibles.SPAWN_PERCENT then
                assert(ok and draws==3 and session.avatarItems[1].rank==5 and session.avatarSequence==1)
                spawned=spawned+1
            else
                assert(not ok and draws==1 and not session.avatarSequence and #m.Collectibles.view(session).items==0)
            end
            assert(session.streak==3 and session.streakExpiresAt==10 and profile.credits==0)
        end
        assert(spawned==30)
        for _,invalid in ipairs({0,101,-1,1.5,0/0,math.huge,"1",false}) do
            local session={streak=1}
            assert(not m.Collectibles.issue(session,{grade="Great"},profile,function() return invalid end))
            assert(not session.avatarSequence and #m.Collectibles.view(session).items==0)
        end
    end)
    test("avatar issuance is bounded fresh-only and loss reset invalidates old IDs",function()
        local profile,session=setup();session.streak=1
        local function choose(low) return low end
        for index=1,10 do assert(m.Collectibles.issue(session,{grade="Great"},profile,choose)) end
        assert(not m.Collectibles.issue(session,{grade="Great"},profile,function() error("full pool rerolled") end))
        assert(#m.Collectibles.view(session).items==10 and session.avatarSequence==10)
        assert(not m.Collectibles.issue(session,{grade="Great",reused=true},profile,function() error("reused rerolled") end))
        session.streak=0;assert(not m.Collectibles.issue(session,{grade="Normal",streakBroken=true},profile,choose))
        assert(#m.Collectibles.view(session).items==0)
        Session.reset(session);session.streak=1
        assert(m.Collectibles.issue(session,{grade="Good"},profile,choose))
        assert(m.Collectibles.view(session).items[1].id==11)
    end)
    test("each avatar rarity grants streak once with continuous phase no words money or retroactive awards",function()
        for rank,roll in ipairs({1,6001,8501,9501,9901}) do
            local profile,session=setup();assert(skillHit(profile,session,1,"Great"))
            local choose=function(low,high) return high==10000 and roll or low end
            assert(m.Collectibles.issue(session,{grade="Great"},profile,choose))
            local id=m.Collectibles.view(session).items[1].id;local phase=m.Skill.phase(session.skillCheck,11)
            local deadline=session.agentPace.agents[1].nextAt
            assert(m.Collectibles.collect(session,id,11,chooseTarget,m.Skill))
            local bonus=m.Collectibles.RARITIES[rank].streak
            assert(session.streak==1+bonus and session.bestStreak==1+bonus and session.lastAvatarCollect.added==bonus)
            near((m.Skill.phase(session.skillCheck,11)-phase+180)%360-180,0)
            assert(not session.skillAwards and profile.credits==0 and profile.batches==0 and session.draft.id==1)
            assert(session.agentPace.agents[1].nextAt==deadline and #m.Collectibles.view(session).items==0)
            assert(not m.Collectibles.collect(session,id,11,function() error("duplicate rerolled") end,m.Skill))
            assert(session.streak==1+bonus)
        end
    end)
    test("avatar protocol rejects forged computed fields and invalid claims cannot partly consume",function()
        assert(m.Protocol.validate("collect_avatar",{id=1},B) and m.Protocol.validate("avatar_sync",{id=1},B))
        for _,bad in ipairs({{}, {id=0},{id=-1},{id=0/0},{id=math.huge},{id=1.5},{id="1"},{id=1,streak=999},{id=1,rank=5},{id=1,reward=10}}) do
            assert(not m.Protocol.validate("collect_avatar",bad,B) and not m.Protocol.validate("avatar_sync",bad,B))
        end
        local profile,session=setup();assert(skillHit(profile,session,1,"Great"))
        assert(m.Collectibles.issue(session,{grade="Great"},profile,function(low) return low end))
        local id=session.avatarItems[1].id;local check=session.skillCheck
        assert(not m.Collectibles.collect(session,id+1,11,function() error("forged rerolled") end,m.Skill))
        assert(not m.Collectibles.collect(session,id,11,function() return 0 end,m.Skill))
        assert(session.streak==1 and session.avatarItems[1].id==id and session.skillCheck==check and not session.lastAvatarCollect)
        Session.reset(session);assert(not m.Collectibles.collect(session,id,11,chooseTarget,m.Skill))
    end)
    test("avatar bonus respects streak ceiling without multiplying old precision or recursively spawning",function()
        local profile,session=setup();assert(skillHit(profile,session,1,"Great"));session.streak=9998
        assert(m.Collectibles.issue(session,{grade="Great"},profile,function(low,high) return high==10000 and 10000 or low end))
        assert(m.Collectibles.collect(session,session.avatarItems[1].id,11,chooseTarget,m.Skill))
        assert(session.streak==9999 and session.lastAvatarCollect.added==1 and session.streakMultiplier==4)
        assert(session.avatarSequence==1 and #m.Collectibles.view(session).items==0 and not session.skillAwards)
    end)
    local function directGreat(session,index,base,c)
        local check=assert(m.Skill.ensure(session,session.draft,10,chooseTarget))
        local now=check.startsAt+((check.target-(check.phaseOffset or 0))%360)/360*check.duration
        local payload={draftId=check.draftId,checkId=check.id,tokenIndex=index}
        local ok,result=m.Skill.click(session,session.draft,payload,now,0,chooseTarget,base or 4,c or 2)
        return ok,result,payload,now
    end
    test("removed word buffer has no command API budgets or Studio controls",function()
        local profile,session=setup()
        assert(not m.Protocol.validate("skill_queue",{draftId=1,checkId=1,tokenIndex=1},B))
        assert(not m.Skill.enqueue and not m.Skill.drain and not B.SKILL_QUEUE_CAPACITY and not B.SKILL_QUEUE_RATE and not B.SKILL_QUEUE_BATCH)
        assert(not m.Tuning.byAction.tune_queueRate and not m.Tuning.byAction.tune_queueBatch)
        assert(directGreat(session,1))
        assert(session.lastSkillClick.wordCount==0 and not session.skillQueue and not session.pendingSkillWords)
        assert(profile.credits==0)
    end)
    test("high TPC timing hit leaves the remaining context empty and old awards fixed",function()
        local profile,session=setup();session.streak=34;seedAwards(session,6,1.4)
        local old=session.skillAwards[6]
        local ok,result=directGreat(session,7)
        assert(ok and result.wordCount==0 and session.streak==35)
        assert(session.skillAwards[6]==old and not session.skillAwards[7])
        assert(not session.pendingSkillWords and not session.skillQueue and profile.credits==0)
    end)
    test("out of context direct attempts reject without consuming a check or changing streak",function()
        local profile,session=setup();local check=m.Skill.ensure(session,session.draft,10,chooseTarget)
        local now=check.startsAt+check.target/360*check.duration
        local ok=m.Skill.click(session,session.draft,{draftId=check.draftId,checkId=check.id,tokenIndex=9},now,0,
            function() error("Overflow drew randomness") end,4,2)
        assert(not ok and session.skillCheck==check and not session.skillAwards and not session.streak and profile.credits==0)
        assert(directGreat(session,1))
        assert(session.lastSkillClick.wordCount==0 and not session.pendingSkillWords)
    end)
    test("timing checks do not spill words into a sold context or replay its payment",function()
        local profile,session=setup();session.streak=4
        local ok,result,payload=directGreat(session,1)
        assert(ok and result.wordCount==0 and session.streak==5 and not session.pendingSkillWords)
        local paid,receipt=send(profile,session,8,20)
        assert(paid and receipt.reward==8 and profile.credits==8)
        m.Skill.ensure(session,session.draft,21,chooseTarget)
        assert(not session.skillAwards and not session.lastSkillClick and not session.skillQueue)
        assert(not m.Skill.click(session,session.draft,payload,22,0,chooseTarget,4,2))
        assert(not Session.submit(session,profile,{draftId=payload.draftId,tokens=8},23,-math.huge,B,Prompt,Sim,function() return 1 end))
        assert(profile.credits==8)
    end)
    test("fresh timing checks at an unchanged context position have no word backlog",function()
        local _,session=setup();assert(directGreat(session,1))
        local old=session.skillAwards;local streak=session.streak
        local ok,result=directGreat(session,1)
        assert(ok and not result.reused and result.wordCount==0 and session.skillAwards==old and session.streak==streak+1)
        assert(not session.skillQueue and not session.pendingSkillWords)
        Session.reset(session)
        assert(not session.lastSkillClick and not session.skillAwards and session.streak==0)
    end)
    test("submitted challenges have no previous-draft handover for buffered clicks",function()
        local profile,session=setup();local check=m.Skill.ensure(session,session.draft,10,chooseTarget)
        local payload={draftId=check.draftId,checkId=check.id,tokenIndex=1}
        assert(send(profile,session,1,20));m.Skill.ensure(session,session.draft,21,chooseTarget)
        assert(not session.previousSkillCheck and not session.previousSkillDeadline)
        assert(not m.Skill.click(session,session.draft,payload,22,0,chooseTarget,4,2))
        assert(not session.pendingSkillWords and profile.credits==1)
        assert(directGreat(session,1))
        assert(session.lastSkillClick.draftId==session.draft.id and profile.credits==1)
    end)
    test("full-context checks build and break streak without words or changing prior payment",function()
        local profile,session=setup();seedAwards(session,8,2)
        assert(directGreat(session,1,4,5));assert(directGreat(session,5,4,5))
        local awards={};for index=1,8 do awards[index]=session.skillAwards[index] end
        local ok,result,payload,now=directGreat(session,9,4,5)
        assert(ok and result.wordCount==0 and not result.reused and session.streak==3 and session.bestStreak==3)
        assert(not session.skillAwards[9] and profile.credits==0)
        for index=1,8 do assert(session.skillAwards[index]==awards[index] and awards[index].multiplier==2) end
        assert(not m.Skill.click(session,session.draft,payload,now,0,chooseTarget,4,5))
        local check=session.skillCheck
        local phase=(check.target+130)%360
        now=check.startsAt+((phase-check.phaseOffset)%360)/360*check.duration
        assert(m.Skill.click(session,session.draft,{draftId=check.draftId,checkId=check.id,tokenIndex=9},now,0,chooseTarget,4,5))
        assert(session.streak==0 and session.lastSkillClick.wordCount==0)
        assert(send(profile,session,8,30));assert(profile.credits==16)
    end)
    test("no-word checks require every server-awarded context slot before consuming randomness",function()
        local profile,session=setup();assert(directGreat(session,1,4,5))
        local check=session.skillCheck;local streak=session.streak
        local payload={draftId=check.draftId,checkId=check.id,tokenIndex=9}
        assert(not m.Skill.click(session,session.draft,payload,11,0,function() error("Unfilled context consumed RNG") end,4,5))
        assert(session.skillCheck==check and session.streak==streak and profile.credits==0)
        payload.tokenIndex=10;assert(not m.Skill.click(session,session.draft,payload,11,0,chooseTarget,4,5))
    end)
    test("full 64-token skill and read-only sync use bounded index129 while agent and overflow packets reject",function()
        local profile,session=setup();profile.tokenLevel=7
        assert(Session.ensure(session,profile,B,Prompt,function() return 1 end))
        assert(#session.draft.offers==64)
        session.skillAwards={}
        for index=1,64 do session.skillAwards[index]={tokenIndex=index,grade="Agent",multiplier=1} end
        local check=m.Skill.ensure(session,session.draft,10,chooseTarget)
        local payload={draftId=check.draftId,checkId=check.id,tokenIndex=65}
        assert(m.Protocol.validate("skill_click",payload,B) and m.Protocol.validate("skill_sync",payload,B))
        assert(not m.Protocol.validate("agent_type",{draftId=check.draftId,requestId=1,tokenIndex=65},B))
        local ok,result=directGreat(session,65,1,5)
        assert(ok and result.wordCount==0 and session.streak==1 and not session.skillAwards[65])
        payload.tokenIndex=66;assert(not m.Protocol.validate("skill_click",payload,B))
        local paid,receipt=send(profile,session,64,30);assert(paid and receipt.reward==64 and profile.credits==64)
        assert(not m.Skill.click(session,session.draft,payload,31,0,chooseTarget,1,5))
    end)
    test("prestige cubic thresholds round exactly and cap without paying from current balance",function()
        for _,case in ipairs({{0,0},{999.99,0},{1000,1},{7999.99,1},{8000,2},{26999.99,2},{27000,3},{B.MAX_LIFETIME_EARNED,B.MAX_PRESTIGE_CHIPS}}) do
            assert(m.Prestige.level(case[1],B)==case[2])
        end
        local state=State.new(B);state.credits=1000000
        assert(m.Prestige.view(state,B).available==0 and not m.Prestige.ascend(state,B,State))
    end)
    test("only a confirmed prompt increments lifetime earnings once and purchases cannot subtract it",function()
        local state,session=setup();assert(state.lifetimeEarned==0)
        assert(send(state,session,8,10));assert(state.lifetimeEarned==8 and state.credits==8)
        state.credits=30;assert(Rules.purchase(state,"upgrade_compute",nil,B));assert(state.lifetimeEarned==8)
        assert(not Session.submit(session,state,{draftId=1,tokens=8},11,-math.huge,B,Prompt,Sim,function() return 1 end))
        assert(state.lifetimeEarned==8 and m.Prestige.view(state,B).available==0)
        state.credits=B.MAX_CREDITS
        local ok,receipt=send(state,session,1,12)
        assert(ok and receipt.reward==0 and state.lifetimeEarned==8)
    end)
    test("prestige atomically resets normal progression on the same profile while keeping permanent currency",function()
        local state=State.new(B);state.lifetimeEarned=27000;state.credits=500;state.computeLevel=10
        state.tokenLevel,state.typingLevel,state.clickLevel,state.divisorLevel=8,10,3,3
        table.insert(state.layerSizes,2,5);state.batches=50
        local identity=state
        local ok,gain=m.Prestige.ascend(state,B,State)
        assert(ok and gain==3 and state==identity and state.chips==3 and state.prestigeClaimed==3 and state.prestigeCount==1)
        assert(state.lifetimeEarned==27000 and state.credits==B.STARTING_CREDITS and #state.layerSizes==3)
        assert(state.computeLevel==0 and state.tokenLevel==0 and state.typingLevel==0 and state.clickLevel==0 and state.divisorLevel==0 and state.batches==0)
        assert(State.fromStored(state,B))
        assert(not m.Prestige.ascend(state,B,State) and state.chips==3)
    end)
    test("spent Chips and permanent skills survive later prestiges without minting spent points again",function()
        local state=State.new(B);state.lifetimeEarned=8000;assert(m.Prestige.ascend(state,B,State))
        assert(m.Prestige.buy(state,"boot",B) and state.chips==1)
        assert(not m.Prestige.ascend(state,B,State) and state.prestigeClaimed==2)
        state.lifetimeEarned=27000;assert(m.Prestige.ascend(state,B,State))
        assert(state.chips==2 and state.prestigeSkills.boot and state.prestigeClaimed==3 and state.prestigeCount==2)
        assert(State.fromStored(state,B))
    end)
    test("permanent graph purchases enforce parents balance and once-only costs",function()
        local state=State.new(B);state.lifetimeEarned=B.MAX_LIFETIME_EARNED;assert(m.Prestige.ascend(state,B,State))
        local money,compute=state.credits,state.computeLevel
        assert(not m.Prestige.buy(state,"core",B) and not m.Prestige.buy(state,"unknown",B))
        local paid=0
        for _,node in ipairs(B.PRESTIGE_NODES) do
            local before=state.chips;assert(m.Prestige.buy(state,node.id,B));paid=paid+node.cost
            assert(state.chips==before-node.cost and not m.Prestige.buy(state,node.id,B))
        end
        assert(state.chips+paid==state.prestigeClaimed and state.credits==money and state.computeLevel==compute)
        assert(State.fromStored(state,B))
        state.chips=0;state.prestigeSkills={};assert(not m.Prestige.buy(state,"boot",B))
    end)
    test("earned prestige, stage and root skill multiply confirmed token value",function()
        local state,session=setup();state.lifetimeEarned=1000;assert(m.Prestige.ascend(state,B,State))
        near(Session.baseReward(state,B,Sim),1.16)
        assert(m.Prestige.buy(state,"boot",B));near(Session.baseReward(state,B,Sim),1.27)
        assert(send(state,session,1,10));near(state.credits,1.27);near(state.lifetimeEarned,1001.27)
    end)
    test("current schema rejects forged currencies nonfinite earnings unknown skills or missing prerequisites",function()
        local valid=State.new(B);valid.lifetimeEarned=8000;assert(m.Prestige.ascend(valid,B,State))
        for _,entry in ipairs({{"chips",-1},{"chips",3},{"chips",0/0},{"prestigeClaimed",3},{"prestigeCount",0},{"lifetimeEarned",math.huge},{"lifetimeEarned",0}}) do
            local bad=State.copy(valid);bad[entry[1]]=entry[2];assert(not State.fromStored(bad,B))
        end
        local bad=State.copy(valid);bad.prestigeSkills.unknown=true;assert(not State.fromStored(bad,B))
        bad=State.copy(valid);bad.prestigeSkills.agents=true;bad.chips=0;assert(not State.fromStored(bad,B))
        assert(not valid.prestigeSkills.agents and valid.chips==2)
    end)
    test("schema9 migration preserves old progression without inventing lifetime earnings and skills copy independently",function()
        local old=State.new(B);old.schemaVersion=9;old.credits=789;old.computeLevel=4
        old.chips,old.prestigeClaimed,old.prestigeCount,old.lifetimeEarned,old.prestigeSkills=nil,nil,nil,nil,nil
        local migrated=assert(State.fromStored(old,B));assert(migrated.schemaVersion==B.SCHEMA_VERSION and migrated.credits==789 and migrated.computeLevel==4)
        assert(migrated.chips==0 and migrated.lifetimeEarned==0 and not old.chips)
        migrated.lifetimeEarned=1000;assert(m.Prestige.ascend(migrated,B,State));assert(m.Prestige.buy(migrated,"boot",B))
        local copy=State.copy(migrated);copy.prestigeSkills.boot=nil;assert(migrated.prestigeSkills.boot)
    end)
    test("schema9 repository migration respects leases and saves validated permanent progress",function()
        local old=State.new(B);old.schemaVersion=9;old.credits=19
        local store={record={schemaVersion=9,data=old,lock={owner="other",expiresAt=100}}}
        function store:UpdateAsync(_,callback) local result=callback(self.record);if result then self.record=result end;return result end
        local now=50;local repo=m.ProfileRepository.new(store,State,B,function() return now end,60)
        assert(not repo:acquire("user","me") and store.record.schemaVersion==9)
        now=101;local handle=assert(repo:acquire("user","me"));assert(handle.state.credits==19 and store.record.schemaVersion==B.SCHEMA_VERSION)
        handle.state.lifetimeEarned=1000;assert(m.Prestige.ascend(handle.state,B,State));assert(m.Prestige.buy(handle.state,"boot",B))
        assert(repo:save(handle,false) and store.record.data.prestigeSkills.boot and store.record.data.prestigeClaimed==1)
        now=200;assert(not repo:save(handle,false))
    end)
    test("progression protocol accepts only bounded IDs and rejects trusted client prices amounts and levels",function()
        assert(m.Protocol.validate("prestige",{requestId=1,draftId=1},B))
        assert(m.Protocol.validate("buy_skill",{requestId=1,nodeId="boot"},B))
        assert(m.Protocol.validate("prestige_sync",{requestId=1},B))
        for _,payload in ipairs({{requestId=1,draftId=1,chips=100},{requestId=1,draftId=1,amount=5},{requestId=0,draftId=1},{requestId=1},{requestId=math.huge,draftId=1}}) do assert(not m.Protocol.validate("prestige",payload,B)) end
        assert(not m.Protocol.validate("buy_skill",{requestId=2,nodeId="boot",cost=0},B))
        assert(not m.Protocol.validate("buy_skill",{requestId=2,nodeId=string.rep("a",33)},B))
    end)
    test("new collection has only Common Ember and eight empty deck positions with no implicit buffs",function()
        local state=State.new(B);local owned=0
        for _,card in ipairs(B.AGENT_CARDS) do
            assert(card.value>0 and card.speed>0)
            if state.cardOwned[card.id] then owned=owned+1;assert(card.id=="ember") end
        end
        assert(owned==1 and #B.AGENT_CARDS==36 and #state.cardDeck==8 and State.fromStored(state,B))
        for index=1,8 do assert(state.cardDeck[index]==false) end
        assert(m.Cards.effect(state,1,B).value==1 and m.Cards.effect(state,8,B).speed==1)
    end)
    test("deck positions unlock left to right only from confirmed agent count",function()
        local state=commonState();state.credits=B.MAX_CREDITS
        assert(m.Cards.validSlot(state,1,B) and not m.Cards.equip(state,2,"volt",B))
        for count=2,8 do
            assert(Rules.purchase(state,"add_layer",nil,B))
            assert(m.Cards.validSlot(state,count,B) and not m.Cards.validSlot(state,count+1,B))
        end
        for _,bad in ipairs({0,9,1.5,0/0,math.huge,"1"}) do assert(not m.Cards.validSlot(state,bad,B)) end
    end)
    test("equipping requires one owned unused card and an empty unlocked slot and removal returns the same copy",function()
        local state=commonState();table.insert(state.layerSizes,2,2)
        assert(m.Cards.equip(state,1,"sage",B));assert(m.Cards.location(state,"sage",B)==1)
        assert(not m.Cards.equip(state,2,"sage",B) and not m.Cards.equip(state,1,"volt",B))
        assert(m.Cards.unequip(state,1,B) and state.cardOwned.sage and not state.cardDeck[1])
        assert(not m.Cards.unequip(state,1,B));assert(m.Cards.equip(state,2,"sage",B))
        assert(state.credits==B.STARTING_CREDITS and state.chips==0 and State.fromStored(state,B))
        state.cardOwned.volt=nil;assert(not m.Cards.equip(state,1,"volt",B) and not m.Cards.equip(state,1,"forged",B))
    end)
    test("schema11 rejects unknown unowned duplicate locked and malformed deck entries without mutating input",function()
        local valid=State.new(B);table.insert(valid.layerSizes,2,2);assert(m.Cards.equip(valid,1,"ember",B))
        local variants={}
        local bad=State.copy(valid);bad.cardDeck[2]="ember";variants[#variants+1]=bad
        bad=State.copy(valid);bad.cardDeck[3]="sage";variants[#variants+1]=bad
        bad=State.copy(valid);bad.cardDeck[2]="missing";variants[#variants+1]=bad
        bad=State.copy(valid);bad.cardOwned.ember=nil;variants[#variants+1]=bad
        bad=State.copy(valid);bad.cardOwned.fake=true;variants[#variants+1]=bad
        bad=State.copy(valid);bad.cardOwned.volt=false;variants[#variants+1]=bad
        bad=State.copy(valid);bad.cardDeck[2]=nil;variants[#variants+1]=bad
        bad=State.copy(valid);bad.cardDeck[9]=false;variants[#variants+1]=bad
        bad=State.copy(valid);bad.cardDeck[2]="";variants[#variants+1]=bad
        for _,value in ipairs(variants) do assert(not State.fromStored(value,B)) end
        local copy=State.copy(valid);copy.cardOwned.ember=nil;copy.cardDeck[1]=false
        assert(valid.cardOwned.ember and valid.cardDeck[1]=="ember" and State.fromStored(valid,B))
    end)
    test("schema10 migration preserves prestige and run progression and starts cards unequipped",function()
        local old=State.new(B);old.schemaVersion=10;old.credits=77;old.tokenLevel=6;old.typingLevel=9
        old.lifetimeEarned=27000;old.prestigeClaimed=3;old.prestigeCount=1;old.chips=2;old.prestigeSkills.boot=true
        old.cardOwned,old.cardDeck=nil,nil
        local parsed=assert(State.fromStored(old,B))
        assert(parsed.schemaVersion==B.SCHEMA_VERSION and parsed.credits==77 and parsed.tokenLevel==6 and parsed.typingLevel==9)
        assert(parsed.chips==2 and parsed.prestigeSkills.boot and parsed.prestigeClaimed==3 and parsed.lifetimeEarned==27000)
        for _,card in ipairs(B.AGENT_CARDS) do assert((parsed.cardOwned[card.id]==true)==(card.rank==1)) end
        for index=1,8 do assert(not parsed.cardDeck[index]) end
        assert(old.cardDeck==nil)
    end)
    test("prestige keeps collection and first equipped card and returns newly locked positions to inventory",function()
        local state=commonState();table.insert(state.layerSizes,2,2);table.insert(state.layerSizes,2,2)
        assert(m.Cards.equip(state,1,"volt",B));assert(m.Cards.equip(state,2,"sage",B));assert(m.Cards.equip(state,3,"ember",B))
        state.lifetimeEarned=1000;assert(m.Prestige.ascend(state,B,State))
        assert(#state.layerSizes==3 and state.cardDeck[1]=="volt" and not state.cardDeck[2] and not state.cardDeck[3])
        assert(state.cardOwned.sage and state.cardOwned.ember and not m.Cards.location(state,"sage",B))
        assert(State.fromStored(state,B))
    end)
    test("card value locks per source at automatic generation and cannot reroll old rewards on removal",function()
        local state,session=setup();assert(m.Cards.equip(state,1,"sage",B))
        assert(m.Auto.advance(session,state,0,B,Rules,m.Skill,m.Cards))
        assert(m.Auto.grant(session,state,{requestId=1,draftId=session.draft.id,tokenIndex=1},1.2,B,Rules,m.Skill,m.Cards))
        local award=session.skillAwards[1];near(award.multiplier,1.25)
        assert(m.Cards.unequip(state,1,B));assert(m.Auto.advance(session,state,1.2,B,Rules,m.Skill,m.Cards))
        assert(m.Auto.grant(session,state,{requestId=2,draftId=session.draft.id,tokenIndex=2},2.3,B,Rules,m.Skill,m.Cards))
        assert(session.skillAwards[1]==award and award.cardMultiplier==1.25 and session.skillAwards[2].cardMultiplier==1)
        assert(m.Cards.equip(state,1,"ember",B));local ok,receipt=send(state,session,2,3)
        assert(ok);near(receipt.reward,2.25);near(state.credits,2.25)
    end)
    test("card buffs affect only automatic agents and never change manual skill precision",function()
        local state,session=setup();assert(m.Cards.equip(state,1,"sage",B))
        assert(skillHit(state,session,1,"Great"));assert(session.lastSkillClick.multiplier==2)
        assert(not session.skillAwards and session.lastSkillClick.wordCount==0)
        assert(send(state,session,1,20));assert(state.credits==1)
    end)
    test("card speed changes preserve phase and old budgets and leave other agent clocks unchanged",function()
        local state,session=setup();table.insert(state.layerSizes,2,2)
        assert(m.Auto.advance(session,state,0,B,Rules,m.Skill,m.Cards));assert(m.Auto.advance(session,state,0.5,B,Rules,m.Skill,m.Cards))
        local other=session.agentPace.agents[2].nextAt
        local budget=session.agentPace.agents[1].budget
        assert(m.Cards.equip(state,1,"volt",B));assert(m.Auto.advance(session,state,0.5,B,Rules,m.Skill,m.Cards))
        near(session.agentPace.agents[1].rate,4.8);near(session.agentPace.agents[1].productionRate,1.2)
        near(session.agentPace.agents[1].budget,budget);assert(session.agentPace.agents[2].nextAt==other)
        near(session.agentPace.totalRate,8.8);near(session.agentPace.totalProductionRate,2.2)
        for _=1,20 do
            assert(m.Cards.unequip(state,1,B));m.Auto.advance(session,state,0.5,B,Rules,m.Skill,m.Cards)
            assert(m.Cards.equip(state,1,"volt",B));m.Auto.advance(session,state,0.5,B,Rules,m.Skill,m.Cards)
        end
        near(session.agentPace.agents[1].budget,budget);assert(session.agentPace.agents[2].nextAt==other and state.credits==0)
    end)
    test("card typing has a bounded55 per-agent cap and never grants offline catchup or time money",function()
        local state,session=setup();state.typingLevel=20;state.clickLevel=3;state.divisorLevel=3;session.streak=99
        assert(m.Cards.equip(state,1,"glitch",B));assert(m.Auto.advance(session,state,0,B,Rules,m.Skill,m.Cards))
        near(session.agentPace.agents[1].rate,55);near(session.agentPace.totalRate,55)
        assert(m.Auto.advance(session,state,10000,B,Rules,m.Skill,m.Cards));assert(session.agentPace.budget<=55 and state.credits==0)
        assert(m.Auto.grant(session,state,{requestId=1,draftId=session.draft.id,tokenIndex=1},10000,B,Rules,m.Skill,m.Cards))
        assert(session.autoReceipt.wordCount<=8 and state.credits==0)
        assert(not m.Auto.grant(session,state,{requestId=1,draftId=session.draft.id,tokenIndex=1},10000,B,Rules,m.Skill,m.Cards))
    end)
    test("card commands accept only owned-ID and slot identity fields without trusted client stats",function()
        assert(m.Protocol.validate("equip_card",{requestId=1,slotIndex=1,cardId="ember"},B))
        assert(m.Protocol.validate("unequip_card",{requestId=2,slotIndex=1},B))
        for _,slot in ipairs({0,9,1.5,math.huge,0/0}) do assert(not m.Protocol.validate("equip_card",{requestId=1,slotIndex=slot,cardId="ember"},B)) end
        for _,key in ipairs({"amount","money","speed","value","owned","price"}) do
            local payload={requestId=1,slotIndex=1,cardId="ember"};payload[key]=100
            assert(not m.Protocol.validate("equip_card",payload,B))
        end
        assert(not m.Protocol.validate("unequip_card",{requestId=2,slotIndex=1,cardId="ember"},B))
    end)
    test("schema10 lease migration and save round-trip card ownership and deck safely",function()
        local old=State.new(B);old.schemaVersion=10;old.cardOwned,old.cardDeck=nil,nil
        local store={record={schemaVersion=10,data=old,lock={owner="other",expiresAt=100}}}
        function store:UpdateAsync(_,callback) local result=callback(self.record);if result then self.record=result end;return result end
        local now=50;local repo=m.ProfileRepository.new(store,State,B,function() return now end,60)
        assert(not repo:acquire("cards","me") and store.record.schemaVersion==10)
        now=101;local handle=assert(repo:acquire("cards","me"));assert(store.record.schemaVersion==B.SCHEMA_VERSION)
        assert(m.Cards.equip(handle.state,1,"volt",B));assert(repo:save(handle,false))
        assert(store.record.data.cardOwned.volt and store.record.data.cardDeck[1]=="volt")
        now=200;assert(not repo:save(handle,false))
    end)
    test("inflated shop prices retain low anchors and grow geometrically to existing caps",function()
        for _,entry in ipairs({{action="add_layer",base=2000,growth=6},{action="upgrade_tokens",base=100,growth=4}}) do
            local profile=State.new(B)
            for level=0,6 do
                local expected=entry.base*entry.growth^level
                assert(Rules.quote(profile,entry.action,nil,B)==expected)
                profile.credits=expected-1
                assert(not Rules.purchase(profile,entry.action,nil,B) and profile.credits==expected-1)
                profile.credits=expected
                assert(Rules.purchase(profile,entry.action,nil,B) and profile.credits==0)
            end
            local cost,reason=Rules.quote(profile,entry.action,nil,B)
            assert(not cost and reason=="limit" and State.fromStored(profile,B))
            assert(Rules.quote(profile,"upgrade_compute",nil,B)==10)
        end
        local profile=State.new(B)
        for level=0,30 do
            profile.computeLevel=level
            assert(Rules.quote(profile,"upgrade_compute",nil,B)==math.floor(10*1.4^level))
        end
    end)
    test("bulk quotes and purchases match successive prices without modifying the quoted profile",function()
        for _,action in ipairs({"upgrade_compute","add_layer","upgrade_tokens"}) do
            for _,quantity in ipairs(Rules.SHOP_QUANTITIES) do
                local profile=State.new(B);profile.credits=B.MAX_CREDITS
                for index=2,#profile.layerSizes-1 do profile.layerSizes[index]=4 end
                local manual=State.copy(profile);local quote=assert(Rules.quoteMany(profile,action,quantity,B))
                assert(profile.computeLevel==0 and profile.tokenLevel==0 and #profile.layerSizes==3 and profile.credits==B.MAX_CREDITS)
                local count,total=0,0
                for _=1,quantity=="max" and 512 or quantity do
                    local ok,cost=Rules.purchase(manual,action,nil,B)
                    if not ok then break end
                    count=count+1;total=total+cost
                end
                assert(quote.count==count and quote.cost==total)
                local ok,paid=Rules.purchaseMany(profile,action,quantity,B)
                assert(ok and paid.count==count and profile.credits==manual.credits)
                assert(profile.computeLevel==manual.computeLevel and profile.tokenLevel==manual.tokenLevel)
                assert(table.concat(profile.layerSizes,",")==table.concat(manual.layerSizes,","))
                for index=2,#profile.layerSizes-1 do assert(profile.layerSizes[index]==4) end
            end
        end
    end)
    test("fixed bulk purchases reject atomically while MAX exhausts only affordable levels",function()
        for _,action in ipairs({"upgrade_compute","add_layer","upgrade_tokens"}) do
            local poor=State.new(B);local quote=Rules.quoteMany(poor,action,5,B);poor.credits=quote.cost-1
            assert(not Rules.purchaseMany(poor,action,5,B) and poor.credits==quote.cost-1)
            assert(poor.computeLevel==0 and poor.tokenLevel==0 and #poor.layerSizes==3)
            for _,budget in ipairs({0,1,2,10,39,100,B.MAX_CREDITS}) do
                local profile=State.new(B);profile.credits=budget;local manual=State.copy(profile)
                local n,total=0,0
                for _=1,512 do
                    local ok,cost=Rules.purchase(manual,action,nil,B);if not ok then break end
                    n=n+1;total=total+cost
                end
                local estimate=assert(Rules.quoteMany(profile,action,"max",B))
                assert(estimate.count==n and estimate.cost==total)
                local ok=Rules.purchaseMany(profile,action,"max",B)
                assert(ok==(n>0) and profile.credits==manual.credits)
                local nextPrice=Rules.quote(profile,action,nil,B);assert(not nextPrice or nextPrice>profile.credits)
            end
        end
    end)
    test("bulk caps and unaffordable large totals never overflow or grant partial fixed batches",function()
        local profile=State.new(B);profile.credits=B.MAX_CREDITS;profile.computeLevel=B.LEGACY_MAX_COMPUTE_LEVEL-1
        local quote=assert(Rules.quoteMany(profile,"upgrade_compute",25,B));assert(quote.count==25)
        assert(Rules.purchaseMany(profile,"upgrade_compute",25,B) and profile.computeLevel==44)
        assert(Rules.quoteMany(profile,"upgrade_compute","max",B).count>25)
        local huge={};for key,value in pairs(B) do huge[key]=value end;huge.COMPUTE_BASE_COST=B.MAX_CREDITS
        local fresh=State.new(B);fresh.credits=B.MAX_CREDITS
        local full=Rules.quoteMany(fresh,"upgrade_compute",5,huge);assert(full.cost==5*B.MAX_CREDITS)
        assert(not Rules.purchaseMany(fresh,"upgrade_compute",5,huge) and fresh.computeLevel==0 and fresh.credits==B.MAX_CREDITS)
        assert(Rules.quoteMany(fresh,"upgrade_compute","max",huge).count==1)
    end)
    test("bulk protocol accepts only quantity choices and nonce with read-only reconciliation",function()
        for _,action in ipairs({"upgrade_compute","add_layer","upgrade_tokens"}) do
            for _,quantity in ipairs(Rules.SHOP_QUANTITIES) do assert(m.Protocol.validate(action,{requestId=1,quantity=quantity},B)) end
            for _,bad in ipairs({0,2,4,26,-1,1.5,0/0,math.huge,"5","MAX",true,{}}) do
                assert(not m.Protocol.validate(action,{requestId=1,quantity=bad},B))
            end
            for _,extra in ipairs({"price","count","level","credits","layerIndex"}) do
                local payload={requestId=1,quantity=5};payload[extra]=1;assert(not m.Protocol.validate(action,payload,B))
            end
            assert(not m.Protocol.validate(action,{quantity=5},B) and not m.Protocol.validate(action,{requestId=0,quantity=5},B))
        end
        assert(m.Protocol.validate("upgrade_sync",{requestId=9},B))
        assert(not m.Protocol.validate("upgrade_sync",{requestId=9,quantity=5},B))
        assert(not m.Protocol.validate("upgrade_typing",{requestId=1,quantity=5},B))
    end)
    test("64 sold tokens collect in order within about one second without paying from animation",function()
        local profile,session=setup();profile.tokenLevel=B.MAX_TOKEN_LEVEL
        Session.ensure(session,profile,B,Prompt,function() return 1 end)
        local visual=m.Collection.capture(session.draft,64);local ok,receipt=send(profile,session,64);assert(ok)
        local state=m.Collection.new();assert(m.Collection.accept(state,Prompt.receiptView(receipt,false),visual,false,B))
        local last,elapsed=0,0
        while #state.batches>0 and elapsed<1.2 do
            for _,event in ipairs(m.Collection.tick(state,1/60,true)) do assert(event.tokenIndex==last+1);last=event.tokenIndex end
            elapsed=elapsed+1/60
        end
        assert(last==64 and elapsed<=1.1 and state.amount==receipt.reward and profile.credits==receipt.reward)
        assert(#m.Collection.tick(state,5,true)==0)
    end)
    test("schema12 clamps old context with a frozen once-only refund and preserves permanent progression",function()
        local old=State.new(B);old.schemaVersion=11;old.tokenLevel=15;old.computeLevel=20;old.credits=123
        old.lifetimeEarned=27000;old.prestigeClaimed=3;old.prestigeCount=1;old.chips=0;old.prestigeSkills={boot=true,focus=true}
        local refund=0;for level=7,14 do refund=refund+math.floor(2*1.5^(level*.25)) end
        local migrated=assert(State.fromStored(old,B))
        assert(migrated.schemaVersion==B.SCHEMA_VERSION and migrated.tokenLevel==7 and migrated.credits==123+refund)
        assert(migrated.prestigeSkills.focus and migrated.prestigeClaimed==3 and old.tokenLevel==15 and old.credits==123)
        assert(State.fromStored(migrated,B).credits==migrated.credits)
        migrated.tokenLevel=8;assert(not State.fromStored(migrated,B))
        old.prestigeSkills.focus10=true;assert(not State.fromStored(old,B))
    end)
    test("value levels continue beyond20 and MAX exhausts affordable levels above25 safely",function()
        local profile=State.new(B);profile.computeLevel=20;profile.credits=B.MAX_CREDITS
        assert(Rules.purchaseMany(profile,"upgrade_compute",25,B) and profile.computeLevel==45)
        assert(Rules.quoteMany(profile,"upgrade_compute","max",B).count>25)
        assert(Rules.purchaseMany(profile,"upgrade_compute","max",B))
        assert(Rules.quote(profile,"upgrade_compute",nil,B)>profile.credits and State.fromStored(profile,B))
        profile.computeLevel=1000000;assert(State.fromStored(profile,B))
        assert(Rules.quote(profile,"upgrade_compute",nil,B)==B.MAX_CREDITS and State.isFinite(Session.baseReward(profile,B,Sim)))
    end)
    test("ten-level value milestones and lifetime stages reward real progression with finite multipliers",function()
        local state=State.new(B);state.computeLevel=9
        local before=Session.baseReward(state,B,Sim);state.computeLevel=10
        assert(Session.baseReward(state,B,Sim)>before*1.25)
        state.credits=B.MAX_CREDITS;assert(B.progression(state).stageName=="BOOT")
        state.lifetimeEarned=1000;local effect=B.progression(state)
        assert(effect.stageName=="STUDIO" and effect.nextStageAt==10000);near(effect.stageBonus,1.10)
        local oldStage=effect.stage;assert(m.Prestige.ascend(state,B,State));assert(B.progression(state).stage==oldStage)
    end)
    test("rarity skills have exact bounded ticket distributions for every permanent level",function()
        local profile=State.new(B)
        local ids={"luck","luck2","luck3","luck4"}
        for level=0,4 do
            if level>0 then profile.prestigeSkills[ids[level]]=true end
            local boost=level+1
            local weights=Session.tokenWeights(profile,B)
            assert(B.progression(profile).rarityBoost==boost)
            local counts={0,0,0,0,0}
            for roll=1,10000 do
                local session=Session.new()
                assert(Session.ensure(session,profile,B,Prompt,function(low,high)
                    assert(low==1 and high==10000);return roll
                end))
                local offer=session.draft.offers[1]
                counts[offer.rank]=counts[offer.rank]+1
                assert(offer.multiplier==B.SPECIAL_TOKENS[offer.rank].multiplier)
            end
            local total=0
            for rank,weight in ipairs(weights) do
                assert(weight>0 and weight%1==0 and counts[rank]==weight)
                if rank>1 then assert(weight==B.SPECIAL_TOKENS[rank].weight*boost) end
                total=total+weight
            end
            assert(total==10000)
        end
        local weights=Session.tokenWeights(profile,B)
        assert(weights[1]==8445 and weights[2]==1000 and weights[3]==500 and weights[4]==50 and weights[5]==5)
        assert(B.SPECIAL_TOKENS[1].weight==9689 and B.SPECIAL_TOKENS[5].weight==1)
    end)
    test("rarity skills enforce costs parents exact accounting persistence and prestige retention",function()
        local profile=State.new(B);profile.lifetimeEarned=B.MAX_LIFETIME_EARNED
        assert(m.Prestige.ascend(profile,B,State))
        assert(not m.Prestige.buy(profile,"luck",B))
        assert(m.Prestige.buy(profile,"boot",B))
        local spent=1
        for index,entry in ipairs({{"luck",3},{"luck2",10},{"luck3",50},{"luck4",200}}) do
            if index<4 then assert(not m.Prestige.buy(profile,({"luck2","luck3","luck4"})[index],B)) end
            assert(m.Prestige.quote(profile,entry[1],B)==entry[2])
            local poor=State.copy(profile);poor.chips=entry[2]-1
            assert(not m.Prestige.buy(poor,entry[1],B) and not poor.prestigeSkills[entry[1]])
            assert(m.Prestige.buy(profile,entry[1],B));spent=spent+entry[2]
            assert(profile.chips==B.MAX_PRESTIGE_CHIPS-spent and not m.Prestige.buy(profile,entry[1],B))
            profile=assert(State.fromStored(profile,B))
            assert(B.progression(profile).rarityBoost==index+1)
        end
        local invalid=State.copy(profile);invalid.prestigeSkills.luck2=nil;invalid.chips=invalid.chips+8
        assert(not State.fromStored(invalid,B))
        invalid=State.copy(profile);invalid.chips=invalid.chips+1;assert(not State.fromStored(invalid,B))
        invalid=State.copy(profile);invalid.prestigeSkills.fake_luck=true;assert(not State.fromStored(invalid,B))
        -- A subsequent real prestige retains luck while resetting the normal run.
        profile.lifetimeEarned=B.PRESTIGE_BASE*500^3;profile.prestigeClaimed=499
        profile.chips=499-spent;profile.computeLevel=5
        assert(m.Prestige.ascend(profile,B,State))
        assert(profile.computeLevel==0 and B.progression(profile).rarityBoost==5 and State.fromStored(profile,B))
        for _,field in ipairs({"luck","rarityBoost","weight","chance","price"}) do
            local payload={requestId=1,nodeId="luck"};payload[field]=999
            assert(not m.Protocol.validate("buy_skill",payload,B))
        end
    end)
    test("buying rarity skills preserves existing draft and awards while new offers use new odds",function()
        local profile,session=setup(function() return 9500 end)
        profile.lifetimeEarned=1000000;profile.prestigeClaimed=10;profile.prestigeCount=1;profile.chips=10
        assert(m.Prestige.buy(profile,"boot",B))
        seedAwards(session,8,1.7)
        local draft,awards=session.draft,session.skillAwards
        local value=Session.baseReward(profile,B,Sim)
        assert(m.Prestige.buy(profile,"luck",B))
        assert(Session.baseReward(profile,B,Sim)==value)
        assert(Session.ensure(session,profile,B,Prompt,function() error("existing draft rerolled") end)==draft)
        assert(session.skillAwards==awards and draft.offers[1].rank==1)
        local ok,receipt=send(profile,session,8,10,nil,function() return 9500 end)
        assert(ok and receipt.outputs[1].rank==1 and receipt.outputs[1].skillMultiplier==1.7)
        assert(session.draft.id==draft.id+1 and session.draft.offers[1].rank==2)
        local restored=assert(State.fromStored(profile,B))
        assert(Session.ensure(session,restored,B,Prompt,function() error("sync rerolled") end)==session.draft)
        local fixed=session.draft.offers[1];profile.tokenLevel=1
        assert(Session.ensure(session,profile,B,Prompt,function() return 9500 end).offers[1]==fixed)
        assert(session.draft.offers[9].rank==2)
    end)
    test("inflation milestones grow money and costs together while bounding extreme stored levels",function()
        local profile=State.new(B)
        for _,entry in ipairs({{0,1},{9,4.15},{10,45},{20,800},{30,11500},{40,150000},{50,1850000},{60,22000000}}) do
            profile.computeLevel=entry[1]
            near(Session.baseReward(profile,B,Sim),entry[2])
            assert(Rules.quote(profile,"upgrade_compute",nil,B)==math.floor(10*1.4^entry[1]))
        end
        for level=10,70,10 do
            profile.computeLevel=level-1;local before=Session.baseReward(profile,B,Sim)
            profile.computeLevel=level;local after=Session.baseReward(profile,B,Sim)
            assert(after>before*10 and after<before*12)
        end
        for _,level in ipairs({120,1000000,B.MAX_SAFE_COMPUTE_LEVEL}) do
            profile.computeLevel=level
            local amount=Session.baseReward(profile,B,Sim)
            assert(amount==B.MAX_CREDITS and State.isFinite(amount))
            local cost,reason=Rules.quote(profile,"upgrade_compute",nil,B)
            assert(cost==B.MAX_CREDITS or (level==B.MAX_SAFE_COMPUTE_LEVEL and reason=="numeric_limit"))
            assert(State.fromStored(profile,B))
        end
        local total=0
        for _,node in ipairs(B.PRESTIGE_NODES) do
            assert((not node.legacyCost or node.cost>=node.legacyCost) and node.cost%1==0);total=total+node.cost
        end
        assert(total==19973 and total<=B.MAX_PRESTIGE_CHIPS)
    end)
    test("schema13 preserves pre13 skill debits and future buys use the inflated price exactly once",function()
        local old=State.new(B);old.schemaVersion=12;old.legacyPrestigeSkills=nil
        old.lifetimeEarned=1000000000000000;old.prestigeClaimed=10000;old.prestigeCount=1
        old.computeLevel=23;old.tokenLevel=5;old.credits=12345
        local spent=0
        for _,node in ipairs(B.PRESTIGE_NODES) do
            if node.legacyCost then old.prestigeSkills[node.id]=true;spent=spent+node.legacyCost end
        end
        old.chips=old.prestigeClaimed-spent
        local migrated=assert(State.fromStored(old,B))
        assert(migrated.schemaVersion==B.SCHEMA_VERSION and migrated.chips==old.chips and migrated.prestigeClaimed==10000)
        assert(migrated.credits==12345 and migrated.computeLevel==23 and migrated.tokenLevel==5 and not old.legacyPrestigeSkills)
        for id in pairs(old.prestigeSkills) do assert(migrated.legacyPrestigeSkills[id]) end
        local again=assert(State.fromStored(migrated,B));assert(again.chips==migrated.chips and again.credits==12345)
        local copy=State.copy(again);copy.legacyPrestigeSkills.luck=nil;assert(again.legacyPrestigeSkills.luck)
        local partial=State.new(B);partial.schemaVersion=12;partial.legacyPrestigeSkills=nil
        partial.lifetimeEarned=1000000;partial.prestigeClaimed=10;partial.prestigeCount=1
        partial.prestigeSkills={boot=true,tokens=true};partial.chips=7
        partial=assert(State.fromStored(partial,B))
        assert(m.Prestige.quote(partial,"agents",B)==3 and m.Prestige.buy(partial,"agents",B))
        assert(partial.chips==4 and not partial.legacyPrestigeSkills.agents and State.fromStored(partial,B))
        assert(not m.Prestige.buy(partial,"agents",B) and partial.chips==4)
        partial.lifetimeEarned=8000000;assert(m.Prestige.ascend(partial,B,State))
        assert(partial.legacyPrestigeSkills.tokens and not partial.legacyPrestigeSkills.agents and State.fromStored(partial,B))
        for _,change in ipairs({function(p) p.legacyPrestigeSkills=nil end,
            function(p) p.legacyPrestigeSkills={fake=true} end,function(p) p.legacyPrestigeSkills.focus=true end,
            function(p) p.legacyPrestigeSkills.tokens=false end,function(p) p.chips=p.chips+1 end}) do
            local bad=State.copy(partial);change(bad);assert(not State.fromStored(bad,B))
        end
        old.chips=old.chips+1;assert(not State.fromStored(old,B))
        for _,field in ipairs({"legacyPrestigeSkills","legacyCost","paidCost","rarityBoost"}) do
            local payload={requestId=1,nodeId="luck"};payload[field]=0
            assert(not m.Protocol.validate("buy_skill",payload,B))
        end
    end)
    test("schema12 price migration respects leases and stores grandfathered ownership without a refund",function()
        local old=State.new(B);old.schemaVersion=12;old.legacyPrestigeSkills=nil
        old.lifetimeEarned=27000;old.prestigeClaimed=3;old.prestigeCount=1;old.chips=0
        old.prestigeSkills={boot=true,focus=true};old.credits=999
        local store={record={schemaVersion=12,data=old,lock={owner="other",expiresAt=100}}}
        function store:UpdateAsync(_,callback) local result=callback(self.record);if result then self.record=result end;return result end
        local now=50;local repo=m.ProfileRepository.new(store,State,B,function() return now end,60)
        local denied,reason=repo:acquire("inflation","me");assert(not denied and reason=="profile_busy" and store.record.schemaVersion==12)
        now=101;local handle=assert(repo:acquire("inflation","me"))
        assert(handle.state.credits==999 and handle.state.chips==0 and handle.state.legacyPrestigeSkills.focus)
        assert(store.record.schemaVersion==B.SCHEMA_VERSION and repo:save(handle,false))
        assert(store.record.data.legacyPrestigeSkills.focus and store.record.data.prestigeClaimed==3)
        now=200;assert(not repo:save(handle,false))
    end)
    test("expanded tree is reachable has no overlapping nodes and uses bounded passive hex geometry",function()
        local T=m.Tree;assert(#B.PRESTIGE_NODES==54)
        local bounds=T.bounds(B.PRESTIGE_NODES);assert(bounds.width==3416 and bounds.height==2704)
        local seen,placed,total={},{},0
        for _,node in ipairs(B.PRESTIGE_NODES) do
            assert(not seen[node.id]);seen[node.id]=true;total=total+node.cost
            local p=T.position(node.id)
            assert(p.x>=0 and p.y>=0 and p.x+p.width<=bounds.width and p.y+p.height<=bounds.height)
            for _,other in ipairs(placed) do
                assert(p.x+p.width<=other.x or other.x+other.width<=p.x or p.y+p.height<=other.y or other.y+other.height<=p.y)
            end
            placed[#placed+1]=p
            for _,parent in ipairs(node.parents) do
                assert(seen[parent],"Parent must precede child: "..node.id)
                local link=T.link(parent,node.id)
                assert(State.isFinite(link.angle) and link.length>0 and link.length<5000)
                assert(link.x>=0 and link.y>=0 and link.x<=bounds.width and link.y<=bounds.height)
            end
        end
        assert(total==19973 and B.MAX_PRESTIGE_CHIPS-total==827)
        for _,inset in ipairs({0,4}) do
            local rects=T.hex(inset);assert(#rects<=26)
            for _,r in ipairs(rects) do
                for _,value in pairs(r) do assert(value%1==0) end
                assert(r.x>=inset and r.y>=inset and r.width>0 and r.height>0)
                assert(r.x+r.width<=240-inset and r.y+r.height<=208-inset)
            end
            assert(rects[1].width<rects[math.ceil(#rects/2)].width)
        end
    end)
    test("expanded branches strictly improve their authored effects without rewriting rarity awards",function()
        local state=State.new(B);state.lifetimeEarned=B.MAX_LIFETIME_EARNED;assert(m.Prestige.ascend(state,B,State))
        for _,node in ipairs(B.PRESTIGE_NODES) do
            local before=B.progression(state)
            assert(m.Prestige.buy(state,node.id,B))
            local after=B.progression(state)
            if node.cash then assert(after.cash>before.cash) end
            if node.speed then assert(after.speed>before.speed) end
            if node.chip then assert(after.perChip>before.perChip) end
            if node.introducedSchema then
                assert(not state.legacyPrestigeSkills[node.id] and State.fromStored(state,B))
                if node.luck then assert(after.rarityBoost>before.rarityBoost) end
                if node.auto then assert(after.streakCap>before.streakCap) end
            end
        end
        assert(state.chips==827 and B.progression(state).rarityBoost==10 and B.progression(state).streakCap==100)
        local session=Session.new();local counts={0,0,0,0,0}
        for roll=1,10000 do
            session=Session.new()
            assert(Session.ensure(session,state,B,Prompt,function() return roll end))
            local offer=session.draft.offers[1]
            counts[offer.rank]=counts[offer.rank]+1
            assert(offer.multiplier==B.SPECIAL_TOKENS[offer.rank].multiplier)
        end
        for rank,weight in ipairs({6890,2000,1000,100,10}) do assert(counts[rank]==weight) end
        local draft=session.draft;Session.ensure(session,state,B,Prompt,function() error("reroll") end)
        assert(session.draft==draft)
        assert(m.Prestige.ascend(state,B,State)==false) -- no automatic/duplicate new Chips
    end)
    test("schema14 preserves mixed old debits and excludes new skills and higher caps from old records",function()
        local old=State.new(B);old.schemaVersion=13;old.lifetimeEarned=2744000
        old.prestigeClaimed=14;old.prestigeCount=1;old.chips=1
        old.prestigeSkills={boot=true,focus=true,focus10=true};old.legacyPrestigeSkills={boot=true,focus=true}
        local current=assert(State.fromStored(old,B))
        assert(current.schemaVersion==B.SCHEMA_VERSION and current.chips==1 and current.prestigeClaimed==14)
        assert(current.legacyPrestigeSkills.focus and not current.legacyPrestigeSkills.focus10 and not current.prestigeSkills.cash1)
        assert(old.schemaVersion==13 and old.chips==1 and State.fromStored(current,B))
        local bad=State.copy(old);bad.prestigeSkills.cash1=true;assert(not State.fromStored(bad,B))
        bad=State.copy(old);bad.prestigeClaimed=10001;bad.chips=9988;bad.lifetimeEarned=B.PRESTIGE_BASE*10001^3
        assert(not State.fromStored(bad,B));bad.schemaVersion=14;assert(State.fromStored(bad,B))
        local fresh=State.new(B);fresh.lifetimeEarned=B.MAX_LIFETIME_EARNED;assert(m.Prestige.ascend(fresh,B,State))
        assert(m.Prestige.buy(fresh,"boot",B) and m.Prestige.buy(fresh,"tokens",B) and m.Prestige.buy(fresh,"cash1",B))
        fresh.legacyPrestigeSkills.cash1=true;assert(not State.fromStored(fresh,B))
        assert(m.Prestige.level(1000000000000000,B)==10000 and m.Prestige.level(B.MAX_LIFETIME_EARNED,B)==20800)
        assert(B.MAX_LIFETIME_EARNED<9007199254740992)
    end)
    test("schema13 leased records migrate without new Chips and unknown expansion parents cannot be skipped",function()
        local old=State.new(B);old.schemaVersion=13;old.lifetimeEarned=1000;old.prestigeClaimed=1;old.prestigeCount=1;old.chips=0
        old.prestigeSkills.boot=true
        local store={record={schemaVersion=13,data=old,lock={owner="other",expiresAt=100}}}
        function store:UpdateAsync(_,callback) local result=callback(self.record);if result then self.record=result end;return result end
        local now=50;local repo=m.ProfileRepository.new(store,State,B,function() return now end,60)
        assert(not repo:acquire("expanded","me") and store.record.schemaVersion==13)
        now=101;local handle=assert(repo:acquire("expanded","me"))
        assert(handle.state.schemaVersion==B.SCHEMA_VERSION and handle.state.chips==0 and handle.state.prestigeSkills.boot)
        assert(not m.Prestige.buy(handle.state,"singularity",B) and not m.Prestige.buy(handle.state,"cash1",B))
        assert(repo:save(handle,false) and store.record.schemaVersion==B.SCHEMA_VERSION and store.record.data.chips==0)
    end)
    test("prestige vortex has bounded monotonic collapse an opaque handover and a finite neutral reveal",function()
        local M=m.PrestigeMotion
        local scale,angle,veil=1,0,0
        assert(M.CLOSE+M.HOLD+M.OPEN>2.9 and M.CLOSE+M.HOLD+M.OPEN<3.2)
        for frame=0,125 do
            local p=M.pose(frame/126*M.CLOSE,false)
            assert(p.scale<=scale and p.scale>=.015 and p.angle>=angle and p.angle<=540)
            assert(p.veil>=veil and p.veil<=1 and p.spiral and not p.covered and not p.done)
            scale,angle,veil=p.scale,p.angle,p.veil
        end
        local cover=M.pose(M.CLOSE,false)
        assert(cover.covered and cover.veil==1 and cover.scale==1 and cover.angle==0 and not cover.spiral)
        local reveal=M.pose(M.CLOSE+M.HOLD+.2,false)
        assert(reveal.phase=="reveal" and reveal.veil>0 and reveal.veil<1)
        local done=M.pose(M.CLOSE+M.HOLD+M.OPEN,false);assert(done.done and done.veil==0 and done.scale==1 and done.angle==0)
        for frame=0,40 do
            local p=M.pose(frame/100,true)
            assert(p.scale==1 and p.angle==0 and p.hole==0 and not p.spiral and p.veil>=0 and p.veil<=1)
        end
        assert(M.pose(.36,true).done)
    end)
    test("prestige spiral keeps a fixed144-piece continuous geometry budget across viewports",function()
        local M=m.PrestigeMotion;assert(M.SPECKS==144)
        for _,size in ipairs({{320,360},{1280,720},{1920,1080}}) do
            for _,age in ipairs({0,.2,.6,1,1.2}) do
                for index=1,M.SPECKS do
                    local p=M.speck(index,age,size[1],size[2])
                    assert(p.size>0 and p.size<=15)
                    assert(p.alpha>=0 and p.alpha<=1 and State.isFinite(p.x) and State.isFinite(p.y))
                    assert(p.length>0 and p.length<=math.sqrt(size[1]^2+size[2]^2)*.07)
                    assert(State.isFinite(p.angle) and p.angle>=-180 and p.angle<=180)
                    local radius=math.sqrt((p.x-size[1]/2)^2+(p.y-size[2]/2)^2)
                    assert(radius<math.sqrt(size[1]^2+size[2]^2)*.62+2)
                end
            end
        end
    end)
    test("all permanent branches compose cash speed collection and claimed-Chip bonuses",function()
        local state=State.new(B);state.lifetimeEarned=B.MAX_LIFETIME_EARNED;assert(m.Prestige.ascend(state,B,State))
        for _,node in ipairs(B.PRESTIGE_NODES) do assert(m.Prestige.buy(state,node.id,B)) end
        local e=B.progression(state);near(e.cash,266.409);near(e.speed,3.007241015625);near(e.perChip,.19)
        assert(e.collect==4.5 and e.autoSell and e.autoSkillCap==100 and e.streakCap==100 and math.abs(e.prestigeBonus-(1+B.MAX_PRESTIGE_CHIPS*.19))<.001)
        assert(State.fromStored(state,B) and m.Prestige.view(state,B).perChip==e.perChip)
        local profile,session=setup();profile.prestigeSkills={boot=true,agents=true}
        assert(m.Auto.advance(session,profile,1,B,Rules,m.Skill,m.Cards));near(session.agentPace.agents[1].rate,4.6)
    end)
    test("automatic checks are server-cadenced nonce-bound capped and never generate words or human grades",function()
        local profile,session=setup();seedAwards(session,1,1.7)
        local check=m.Skill.ensure(session,session.draft,10,chooseTarget,0)
        local old={draftId=check.draftId,checkId=check.id,tokenIndex=2}
        assert(not m.Skill.auto(session,session.draft,old,10,0,2,chooseTarget))
        local ok,result=m.Skill.auto(session,session.draft,old,10,5,2,chooseTarget)
        assert(ok and result.grade=="Auto" and result.automatic and result.wordCount==0 and session.streak==1)
        assert(not m.Collectibles.issue(session,result,profile,function() error("auto rolled a collectible") end))
        assert(not m.Skill.auto(session,session.draft,old,12,5,2,chooseTarget))
        local function request(now)
            local c=session.skillCheck
            return m.Skill.auto(session,session.draft,{draftId=c.draftId,checkId=c.id,tokenIndex=2},now,5,2,chooseTarget)
        end
        assert(not request(10.1))
        for now=12,30,2 do assert(request(now) and session.streak<=5) end
        assert(session.streak==5 and session.bestStreak==5 and session.skillAwards[1].multiplier==1.7 and not session.skillAwards[2])
        local sequence=session.skillSequence;assert(request(1000) and session.streak==5 and session.skillSequence==sequence+1)
        assert(profile.credits==0 and profile.lifetimeEarned==0)
    end)
    test("global streak cap applies to manual checks and clickable agents and evolves without rewriting awards",function()
        local profile,session=setup();session.streak=5;session.streakCap=5
        assert(m.Skill.ensure(session,session.draft,10,chooseTarget,0))
        assert(directGreat(session,1,1,5) and session.streak==5)
        assert(m.Collectibles.issue(session,{grade="Great"},profile,function(low) return low end,3))
        local item=m.Collectibles.view(session).items[1]
        assert(m.Collectibles.collect(session,item.id,12,chooseTarget,m.Skill) and session.streak==5)
        session.streakCap=10
        assert(directGreat(session,1,1,5) and session.streak==6)
        assert(m.Skill.expireStreak(session,session.streakExpiresAt) and session.streak==0)
    end)
    test("automatic identity protocol rejects forged caps grades rates clocks and full-context overflow",function()
        local payload={draftId=1,checkId=1,tokenIndex=65}
        assert(m.Protocol.validate("auto_skill",payload,B))
        for _,key in ipairs({"cap","grade","time","streak","amount","interval","wordCount"}) do
            payload[key]=10;assert(not m.Protocol.validate("auto_skill",payload,B));payload[key]=nil
        end
        payload.tokenIndex=66;assert(not m.Protocol.validate("auto_skill",payload,B))
        assert(m.Protocol.validate("buy_skill",{requestId=1,nodeId="focus10"},B))
    end)
    test("clickable-agent skill bonus is locked at spawn and collected once without paying money",function()
        local profile,session=setup();session.streak=1;m.Skill.ensure(session,session.draft,10,chooseTarget,0)
        assert(m.Collectibles.issue(session,{grade="Great"},profile,function(low) return low end,1.5))
        local item=m.Collectibles.view(session).items[1];assert(item.reward==2)
        profile.prestigeSkills={boot=true,agents=true,swarm=true,swarm2=true}
        assert(m.Collectibles.collect(session,item.id,11,chooseTarget,m.Skill) and session.streak==3)
        assert(not m.Collectibles.collect(session,item.id,12,chooseTarget,m.Skill) and profile.credits==0)
    end)
    test("craft catalog has nine complete rarity families and fits alongside the whole tree",function()
        local seen,total={},0
        for _,card in ipairs(B.AGENT_CARDS) do
            assert(not seen[card.id] and card.familyId and card.rank>=1 and card.rank<=4);seen[card.id]=true
            local common=m.Cards.definition(card.familyId,B)
            near(card.value,common.value*B.CRAFT_TIERS[card.rank].value)
            near(card.speed,common.speed*B.CRAFT_TIERS[card.rank].speed)
            if card.id~="ember" then total=total+B.CRAFT_TIERS[card.rank].chips end
        end
        assert(#B.AGENT_CARDS==36 and total==683)
        for _,node in ipairs(B.PRESTIGE_NODES) do total=total+node.cost end
        assert(total==20656 and total<=B.MAX_PRESTIGE_CHIPS)
    end)
    test("craft debits all three exact resources once and old awards and earnings remain unchanged",function()
        local state=State.new(B);state.lifetimeEarned=1000000;state.prestigeClaimed=10;state.prestigeCount=1;state.chips=10
        state.fragments.volt=20;state.credits=30000
        local quote=assert(m.Craft.quote(state,"volt_rare",B));assert(quote.fragments==12 and quote.money==25000 and quote.chips==3)
        assert(m.Craft.purchase(state,"volt_rare",B));assert(state.fragments.volt==8 and state.credits==5000 and state.chips==7)
        assert(state.cardOwned.volt_rare and state.cardCrafted.volt_rare and state.lifetimeEarned==1000000 and not state.cardDeck[1])
        assert(not m.Craft.purchase(state,"volt_rare",B) and State.fromStored(state,B))
        local copy=State.copy(state);copy.fragments.volt=0;copy.cardCrafted.volt_rare=nil
        assert(state.fragments.volt==8 and state.cardCrafted.volt_rare)
    end)
    test("insufficient fragments money or Chips leave every crafting resource untouched",function()
        for _,missing in ipairs({"fragments","credits","chips"}) do
            local state=State.new(B);state.fragments.sage=75;state.credits=25000000000;state.chips=60
            if missing=="fragments" then state.fragments.sage=74 else state[missing]=0 end
            local before=State.copy(state);assert(not m.Craft.purchase(state,"sage_legendary",B))
            assert(state.fragments.sage==before.fragments.sage and state.credits==before.credits and state.chips==before.chips)
            assert(not state.cardOwned.sage_legendary and not next(state.cardCrafted))
        end
        assert(not m.Craft.quote(State.new(B),"fake",B))
    end)
    test("schema15 validates dense fragments crafted ownership and the combined Chip ledger",function()
        local state=State.new(B);state.lifetimeEarned=1000000;state.prestigeClaimed=10;state.prestigeCount=1;state.chips=10
        state.fragments.sprout=20;state.credits=25000;assert(m.Craft.purchase(state,"sprout_rare",B))
        assert(State.fromStored(state,B))
        for _,change in ipairs({function(s) s.fragments=nil end,function(s) s.fragments.ember=nil end,
            function(s) s.fragments.fake=1 end,function(s) s.fragments.volt=0/0 end,function(s) s.fragments.volt=math.huge end,
            function(s) s.fragments.volt=-1 end,function(s) s.fragments.volt=B.MAX_FRAGMENTS+1 end,
            function(s) s.cardCrafted.sprout_rare=nil end,function(s) s.cardOwned.sprout_rare=nil end,
            function(s) s.cardCrafted.fake=true end,function(s) s.chips=s.chips+3 end}) do
            local bad=State.copy(state);change(bad);assert(not State.fromStored(bad,B))
        end
        local old=State.copy(state);old.schemaVersion=14;assert(not State.fromStored(old,B))
    end)
    test("schema14 migrations preserve common ownership deck and leases without inventing fragments",function()
        local old=commonState();old.schemaVersion=14;old.fragments=nil;old.cardCrafted=nil;old.credits=999
        old.cardDeck[1]="frost";old.lifetimeEarned=8000000000000000;old.prestigeClaimed=20000;old.chips=20000;old.prestigeCount=1
        local migrated=assert(State.fromStored(old,B));assert(migrated.credits==999 and migrated.cardDeck[1]=="frost" and migrated.chips==20000)
        for _,family in ipairs(B.AGENT_FAMILIES) do assert(migrated.fragments[family.id]==0 and migrated.cardOwned[family.id]) end
        assert(not next(migrated.cardCrafted) and migrated.schemaVersion==B.SCHEMA_VERSION and old.fragments==nil)
        local bad=State.copy(old);bad.lifetimeEarned=B.MAX_LIFETIME_EARNED;assert(not State.fromStored(bad,B))
        local store={record={schemaVersion=14,data=old,lock={owner="other",expiresAt=100}}}
        function store:UpdateAsync(_,callback) local result=callback(self.record);if result then self.record=result end;return result end
        local now=50;local repo=m.ProfileRepository.new(store,State,B,function() return now end,60)
        assert(not repo:acquire("craft","me"));now=101;local handle=assert(repo:acquire("craft","me"))
        assert(handle.state.fragments.ember==0 and repo:save(handle,false) and store.record.schemaVersion==B.SCHEMA_VERSION)
    end)
    test("prestige retains fragments crafted cards and exact spent costs while keeping only first deck slot",function()
        local state=State.new(B);state.lifetimeEarned=1000000;assert(m.Prestige.ascend(state,B,State))
        state.fragments.sage=50;state.credits=25000;assert(m.Craft.purchase(state,"sage_rare",B))
        table.insert(state.layerSizes,2,2);assert(m.Cards.equip(state,1,"sage_rare",B));assert(m.Cards.equip(state,2,"ember",B))
        state.lifetimeEarned=8000000;assert(m.Prestige.ascend(state,B,State))
        assert(state.chips==17 and state.prestigeClaimed==20 and state.fragments.sage==38 and state.cardCrafted.sage_rare)
        assert(state.cardDeck[1]=="sage_rare" and not state.cardDeck[2] and State.fromStored(state,B))
    end)
    test("craft and visitor protocol accepts identity only and rejects forged rewards and costs",function()
        assert(m.Protocol.validate("craft_card",{requestId=1,cardId="ember_legendary"},B))
        assert(m.Protocol.validate("avatar_poll",{requestId=1},B))
        for _,key in ipairs({"price","chips","money","fragments","rank","amount","time","familyId"}) do
            local craft={requestId=1,cardId="ember_rare"};craft[key]=0;assert(not m.Protocol.validate("craft_card",craft,B))
            local poll={requestId=1};poll[key]=1;assert(not m.Protocol.validate("avatar_poll",poll,B))
        end
        assert(not m.Protocol.validate("craft_card",{requestId=1,cardId="EMBER"},B))
        assert(not m.Protocol.validate("avatar_poll",{requestId=math.huge},B))
    end)
    local function visitor(session,state,roll,family,start)
        start=start or 0;local sequence=session.visitorPollSequence or 0
        local function choose(low,high) if high==10000 then return roll elseif high==9 then return family else return low end end
        for t=start,start+5 do sequence=sequence+1;assert(m.Collectibles.poll(session,state,sequence,t,choose,B)) end
        return m.Collectibles.view(session).items[1]
    end
    test("active visitor deadlines spawn at zero streak with all four rarity rewards and nine families",function()
        for rank,roll in ipairs({1,7501,9501,9951}) do for family=1,9 do
            local state,session=State.new(B),Session.new();local item=assert(visitor(session,state,roll,family))
            assert(item.rank==rank and item.familyId==B.AGENT_FAMILIES[family].id and item.fragments==B.CRAFT_TIERS[rank].drop)
            assert(item.expiresAt==29 and (session.streak or 0)==0 and state.credits==0)
            local fragments=state.fragments[item.familyId]
            assert(m.Collectibles.collectFragments(session,state,item.id,5,B))
            assert(state.fragments[item.familyId]==fragments+item.fragments and (session.streak or 0)==0 and state.chips==0)
            assert(m.Collectibles.collectFragments(session,state,item.id,6,B) and state.fragments[item.familyId]==item.fragments)
        end end
    end)
    test("visitor nonces rate guards inactive gaps and TTL cannot create catchup or recollect expired actors",function()
        local state,session=State.new(B),Session.new();visitor(session,state,1,1)
        local before=session.avatarSequence;local choose=function(low) return low end
        assert(not m.Collectibles.poll(session,state,6,6,choose,B))
        assert(not m.Collectibles.poll(session,state,7,5.1,choose,B))
        assert(m.Collectibles.poll(session,state,8,1000,choose,B) and session.avatarSequence==before)
        assert(#m.Collectibles.view(session).items==0 and not m.Collectibles.collectFragments(session,state,1,1000,B))
        for t=1001,1004 do assert(m.Collectibles.poll(session,state,t,t,choose,B)) end
        assert(session.avatarSequence==before)
        assert(m.Collectibles.poll(session,state,1005,1005,choose,B) and session.avatarSequence==before+1)
        local item=m.Collectibles.view(session).items[1];assert(not m.Collectibles.collectFragments(session,state,item.id,item.expiresAt,B))
        assert(not m.Collectibles.poll(session,state,1006,0/0,choose,B))
    end)
    test("fragment boost locks at spawn caps safely and collection never renews or rewrites streak awards",function()
        local state,session=State.new(B),Session.new();state.prestigeSkills={boot=true,agents=true,swarm=true}
        local item=visitor(session,state,7501,1);assert(item.fragments==3)
        state.prestigeSkills={};state.fragments.ember=B.MAX_FRAGMENTS-1
        session.streak=4;session.streakExpiresAt=7
        assert(m.Collectibles.collectFragments(session,state,item.id,6,B) and state.fragments.ember==B.MAX_FRAGMENTS)
        assert(session.streak==4 and session.streakExpiresAt==7 and session.lastAvatarCollect.fragments==1)
        assert(m.Collectibles.collectFragments(session,state,item.id,8,B) and state.fragments.ember==B.MAX_FRAGMENTS)
        assert(State.fromStored(state,B))
    end)
    test("legendary equipped bonuses lock only fresh agent awards and keep the55 speed ceiling",function()
        local state,session=setup();state.cardOwned.glitch_legendary=true;state.cardCrafted.glitch_legendary=true
        assert(m.Cards.equip(state,1,"glitch_legendary",B));state.typingLevel=20
        m.Auto.advance(session,state,0,B,Rules,m.Skill,m.Cards);near(session.agentPace.agents[1].rate,55)
        assert(m.Auto.grant(session,state,{requestId=1,draftId=session.draft.id,tokenIndex=1},2,B,Rules,m.Skill,m.Cards))
        local award=session.skillAwards[1];near(award.cardMultiplier,.95*2.7)
        assert(m.Cards.unequip(state,1,B));m.Auto.advance(session,state,2,B,Rules,m.Skill,m.Cards)
        assert(session.skillAwards[1]==award and award.cardMultiplier==.95*2.7)
    end)
    test("visitor slots and collection receipt history stay bounded without replacing live actors",function()
        local state,session=State.new(B),Session.new()
        session.avatarItems={};for index=1,10 do session.avatarItems[index]={id=index,familyId="ember",fragments=1,expiresAt=1000} end
        session.avatarSequence=10;session.visitorLastPoll=0;session.visitorNextAt=1
        local calls=0;local choose=function(low) calls=calls+1;return low end
        assert(m.Collectibles.poll(session,state,1,1,choose,B));assert(calls==1 and session.avatarSequence==10)
        assert(#m.Collectibles.view(session).items==10 and session.avatarItems[1].id==1)
        for id=1,70 do
            session.avatarItems[1]={id=id+100,familyId="ember",rank=1,rarity="Common",fragments=1,expiresAt=1000}
            assert(m.Collectibles.collectFragments(session,state,id+100,2,B))
        end
        assert(#session.fragmentReceiptOrder==64 and state.fragments.ember==70)
        assert(not m.Collectibles.collectFragments(session,state,101,2,B))
        assert(m.Collectibles.collectFragments(session,state,170,2,B) and state.fragments.ember==70)
        session.avatarItems={};session.avatarItems[1]={id=999,familyId="ember",rank=1,fragments=8,expiresAt=1000}
        state.fragments.ember=B.MAX_FRAGMENTS
        assert(m.Collectibles.collectFragments(session,state,999,2,B) and session.lastAvatarCollect.fragments==0)
        assert(#m.Collectibles.view(session).items==0 and state.fragments.ember==B.MAX_FRAGMENTS)
    end)
    test("vortex sound has three bounded built-in voices and a continuous finite suction and release envelope",function()
        local M=m.PrestigeMotion;local duration=M.CLOSE+M.HOLD+M.OPEN
        for _,reduced in ipairs({false,true}) do
            local notes=m.Music.vortexCue(reduced);assert(#notes==3)
            local close=reduced and M.REDUCED_CLOSE or M.CLOSE;local hold=reduced and 0 or M.HOLD
            local open=reduced and M.REDUCED_OPEN or M.OPEN
            for channel,note in ipairs(notes) do
                assert((note.asset==m.Music.VORTEX or note.asset==m.Music.TONE) and note.vortex==channel and note.sustain)
                assert(note.gain>0 and note.gain<=.24)
                local lastPitch
                for frame=0,360 do
                    local age=frame/120;local gain,pitch=m.Music.vortexMix(age,close,hold,open,channel)
                    assert(gain>=0 and gain<=1 and pitch>0 and pitch<2)
                    if lastPitch and age<close then assert(pitch<=lastPitch) end
                    lastPitch=pitch
                end
                local gain=m.Music.vortexMix(close+hold+open,close,hold,open,channel);assert(gain==0)
            end
        end
        local scale,angle=1,0
        for frame=0,math.floor(M.CLOSE*120)-1 do
            local p=M.spiral(frame/120);assert(p.scale<=scale and p.angle>=angle)
            scale,angle=p.scale,p.angle
        end
        assert(duration>3 and M.pose(duration,false).done)
    end)
    assert(#failures==0,table.concat(failures,"\n"))
    print("[VibeIdle] "..passed.." manual prompt specifications passed")
    return passed
end
return Specs

-- Money/receipt regressions use deterministic stores; no real purchase is made.
local Specs={}
function Specs.run(m)
    local B,S,P,C=m.Balance,m.State,m.Premium,m.Commerce
    local passed,failures=0,{}
    local function test(name,callback)
        local ok,why=pcall(callback)
        if ok then passed=passed+1;print("PASS commerce: "..name) else failures[#failures+1]=name..": "..tostring(why);print("FAIL commerce: "..failures[#failures]) end
    end
    local function event()
        local result={callbacks={}}
        function result:Connect(callback) self.callbacks[#self.callbacks+1]=callback;return {Disconnect=function() end} end
        function result:Fire(...) for _,callback in ipairs(self.callbacks) do callback(...) end end
        return result
    end
    local function fixture()
        local f={now=1000,saveCount=0,publishes=0,values={},promptCount=0,owned=false}
        f.player={UserId=101};f.record={state=S.new(B),handle={},blocked=false,closing=false}
        f.config={COMMERCE_ENABLED=true,STORAGE_MODE="DATASTORE",COMMERCE_IDS={money_hour=11,chips_hour=12,agent=13,forever=14}}
        f.market={PromptProductPurchaseFinished=event(),PromptGamePassPurchaseFinished=event()}
        function f.market:PromptProductPurchase(_,assetId) f.promptCount=f.promptCount+1;f.lastPrompt=assetId end
        function f.market:PromptGamePassPurchase(_,assetId) f.promptCount=f.promptCount+1;f.lastPrompt=assetId end
        function f.market:UserOwnsGamePassAsync() if f.failPass then error("ownership unavailable") end;return f.owned end
        f.archive={}
        function f.archive:UpdateAsync(key,callback)
            if f.failRead then error("archive read failure") end
            local old=f.values[key];local value=callback(old)
            value=callback(old) -- Roblox may repeat callbacks; no benefit belongs here.
            if value and not old and f.failArchive then error("archive write failure") end
            if value~=nil then f.values[key]=value end
            return value or old
        end
        f.billing=C.new({config=f.config,market=f.market,players={GetPlayerByUserId=function(_,id) return id==101 and f.player or nil end},archive=f.archive,
            balance=B,premium=P,decisions={PurchaseGranted="granted",NotProcessedYet="deferred"},unix=function() return f.now end,
            published=true,studio=false,getRecord=function(player) return player==f.player and not f.absent and f.record or nil end,
            publish=function() f.publishes=f.publishes+1 end,
            save=function(record)
                assert(record.receiptBusy);f.saveCount=f.saveCount+1
                if f.onSave then f.onSave() end
                if f.failSave then return false end
                f.saved=assert(S.fromStored(record.state,B));return true
            end})
        f.billing:bind()
        function f:receipt(product,purchase) return self.market.ProcessReceipt({PlayerId=101,ProductId=product or 11,PurchaseId=purchase or "receipt-a"}) end
        return f
    end
    local function instrument(f)
        local telemetry=m.Telemetry.new({state=S,balance=B,config={},clock=function() return f.now end,unix=function() return f.now end,
            spawn=function(callback) callback() end,published=false,studio=true})
        telemetry:begin(f.player,f.record,"purchase-session")
        f.billing.onEvent=function(record,phase,sku) telemetry:commerce(record,phase,sku) end
        return telemetry
    end
    test("premium telemetry records timing and durable benefit once across save archive and receipt retries",function()
        local f=fixture();instrument(f)
        f.now=1060;f.billing:buy(f.player,f.record,"money_hour",1);f.billing:buy(f.player,f.record,"money_hour",1)
        assert(f.record.state.analytics.robuxPrompts.money_hour==1)
        f.failArchive=true;assert(f:receipt()=="deferred")
        assert(f.record.state.analytics.robuxDelivered.money_hour==1 and f.saved.analytics.robuxDelivered.money_hour==1)
        assert(f.saved.analytics.firstRobux.sessionSeconds==60 and f.saved.analytics.firstRobux.kind=="money_hour")
        assert(f:receipt()=="deferred" and f.record.state.analytics.robuxDelivered.money_hour==1)
        f.failArchive=false;assert(f:receipt()=="granted" and f:receipt()=="granted")
        assert(f.record.state.analytics.robuxDelivered.money_hour==1)
        assert(f:receipt(12,"second")=="granted" and f.record.state.analytics.robuxDelivered.chips_hour==1)
    end)
    test("premium telemetry separates cancellation and pass discovery and failures cannot block benefits",function()
        local f=fixture();instrument(f)
        f.billing:buy(f.player,f.record,"agent",1)
        f.market.PromptProductPurchaseFinished:Fire(101,13,false)
        f.market.PromptProductPurchaseFinished:Fire(101,13,false)
        assert(f.record.state.analytics.robuxCanceled.agent==1 and not f.record.state.analytics.robuxDelivered.agent)
        f.owned=true;f.billing:checkPass(f.player,f.record);f.billing:checkPass(f.player,f.record)
        assert(f.record.state.analytics.robuxDelivered.forever==1 and f.record.state.analytics.firstRobux.event=="pass_owned")
        f.market.PromptProductPurchase=function() error("prompt unavailable") end
        f.billing:buy(f.player,f.record,"agent",2)
        assert(f.record.state.analytics.robuxUnavailable.agent==1 and not f.record.state.analytics.robuxDelivered.agent)
        f.billing.onEvent=function() error("telemetry failure") end
        assert(f:receipt()=="granted" and f.record.state.premium.moneyUntil>f.now)
    end)
    test("four low-priced offers include one highlighted permanent pass and deterministic run agent",function()
        assert(#P.OFFERS==4 and P.offer("money_hour").price==10 and P.offer("chips_hour").price==15)
        assert(P.offer("agent").price==20 and P.offer("forever").price==100 and P.offer("forever").kind=="pass")
        assert(P.offer("forever").featured and P.offer("money_hour").duration==3600)
    end)
    test("temporary time extends without4x stacking and expiration uses server Unix time",function()
        local state=S.new(B)
        assert(P.grant(state,"money_hour",1000,B));assert(state.premium.moneyUntil==4600)
        assert(B.premiumMultiplier(state,"money",1000)==2 and B.premiumMultiplier(state,"money",4599)==2)
        assert(B.premiumMultiplier(state,"money",4600)==1)
        assert(P.grant(state,"money_hour",1100,B) and state.premium.moneyUntil==8200)
        state.premium.forever=true;assert(B.premiumMultiplier(state,"money",1100)==2 and B.premiumMultiplier(state,"chips",999999)==2)
        assert(state.credits==0 and state.lifetimeEarned==0 and state.chips==0)
    end)
    test("money boost pays only confirmed token amounts including credit cap and exact receipt totals",function()
        local state,session=S.new(B),m.Session.new();state.premium.moneyUntil=4600
        m.Session.ensure(session,state,B,m.Prompt,function() return 1 end)
        local ok,receipt=m.Session.submit(session,state,{draftId=session.draft.id,tokens=1},10,-math.huge,B,m.Prompt,m.Simulation,function() return 1 end,1000)
        assert(ok and receipt.reward==2 and receipt.outputs[1].reward==2 and state.credits==2 and state.lifetimeEarned==2)
        state.credits=B.MAX_CREDITS
        ok,receipt=m.Session.submit(session,state,{draftId=session.draft.id,tokens=1},11,10,B,m.Prompt,m.Simulation,function() return 1 end,1001)
        assert(ok and receipt.reward==0 and state.lifetimeEarned==2)
        assert(m.Session.baseReward(state,B,m.Simulation,4600)==1)
    end)
    test("Chip boost doubles only unclaimed base entitlement and cannot reclaim when it expires",function()
        local state=S.new(B);state.lifetimeEarned=8000;state.premium.chipsUntil=4600
        local view=m.Prestige.view(state,B,1000);assert(view.available==4 and view.baseAvailable==2 and view.baseLevel==2)
        assert(m.Prestige.ascend(state,B,S,1000));assert(state.prestigeClaimed==4 and state.premium.bonusChips==2 and state.chips==4)
        assert(S.fromStored(state,B) and not m.Prestige.ascend(state,B,S,1001))
        assert(not m.Prestige.ascend(state,B,S,5000))
        state.lifetimeEarned=27000;assert(m.Prestige.ascend(state,B,S,5000))
        assert(state.prestigeClaimed==5 and state.premium.bonusChips==2 and state.chips==5 and S.fromStored(state,B))
        state.premium.chipsUntil=10000;assert(not m.Prestige.ascend(state,B,S,5001))
    end)
    test("permanent premium allows bounded41600 total Chips without changing base lifetime ceiling",function()
        local state=S.new(B);state.premium.forever=true;state.lifetimeEarned=B.MAX_LIFETIME_EARNED
        assert(m.Prestige.ascend(state,B,S,1000));assert(state.prestigeClaimed==41600 and state.premium.bonusChips==20800 and S.fromStored(state,B))
        assert(m.Prestige.view(state,B,1001).available==0 and not m.Prestige.ascend(state,B,S,1001))
        state.premium.bonusChips=20799;assert(not S.fromStored(state,B))
    end)
    test("agent receipt inherits global workers and stores a credit at cap for explicit later redemption",function()
        local state=S.new(B);state.layerSizes[2]=7
        assert(P.grant(state,"agent",1000,B));assert(#state.layerSizes-2==2 and state.layerSizes[3]==7 and state.premium.agentCredits==0)
        while #state.layerSizes-2<8 do assert(P.grant(state,"agent",1000,B)) end
        assert(P.grant(state,"agent",1000,B) and state.premium.agentCredits==1)
        assert(not P.redeem(state,B));state.lifetimeEarned=1000;assert(m.Prestige.ascend(state,B,S,1000))
        assert(state.premium.agentCredits==1 and #state.layerSizes-2==1 and P.redeem(state,B))
        assert(#state.layerSizes-2==2 and state.premium.agentCredits==0 and S.fromStored(state,B))
    end)
    test("schema16 strictly validates premium data ledger and old schemas retain all progression without premium",function()
        local valid=S.new(B);valid.premium.moneyUntil=4600;valid.premium.receipts.a="money_hour"
        assert(S.fromStored(valid,B))
        for _,mutate in ipairs({function(s) s.premium=nil end,function(s) s.premium.moneyUntil=0/0 end,
            function(s) s.premium.chipsUntil=math.huge end,function(s) s.premium.moneyUntil=-1 end,
            function(s) s.premium.agentCredits=1.5 end,function(s) s.premium.forever="yes" end,
            function(s) s.premium.price=1 end,function(s) s.premium.receipts.a="forever" end,
            function(s) s.premium.receipts[string.rep("a",51)]="agent" end,function(s) s.premium.bonusChips=1 end}) do
            local bad=S.copy(valid);mutate(bad);assert(not S.fromStored(bad,B))
        end
        local old=S.copy(valid);old.schemaVersion=15;old.credits=123;old.premium.forever=true;old.cardDeck[1]="ember"
        local parsed=assert(S.fromStored(old,B));assert(parsed.credits==123 and parsed.cardDeck[1]=="ember" and not parsed.premium.forever and not next(parsed.premium.receipts))
        assert(parsed.premium.moneyUntil==0 and parsed.schemaVersion==B.SCHEMA_VERSION and old.premium.forever)
        local copy=S.copy(valid);copy.premium.receipts.a=nil;assert(valid.premium.receipts.a=="money_hour")
    end)
    test("identity-only premium protocol rejects client prices product IDs clocks and multipliers",function()
        assert(m.Protocol.validate("premium_buy",{sku="money_hour",requestId=1},B))
        assert(m.Protocol.validate("premium_check",{requestId=2},B) and m.Protocol.validate("premium_redeem",{requestId=3},B))
        for _,key in ipairs({"productId","price","money","chips","amount","time","duration","multiplier","receiptId"}) do
            local p={sku="money_hour",requestId=1};p[key]=100;assert(not m.Protocol.validate("premium_buy",p,B))
        end
        assert(not m.Protocol.validate("premium_buy",{sku="forged",requestId=1},B))
        assert(not m.Protocol.validate("premium_redeem",{requestId=1,amount=5},B))
    end)
    test("native prompt completion never grants a product and replayed prompt nonces open only once",function()
        local f=fixture();f.billing:buy(f.player,f.record,"money_hour",1);assert(f.promptCount==1 and f.lastPrompt==11)
        f.billing:buy(f.player,f.record,"money_hour",1);f.billing:buy(f.player,f.record,"chips_hour",2)
        assert(f.promptCount==1 and f.record.state.premium.moneyUntil==0)
        f.market.PromptProductPurchaseFinished:Fire(101,11,true)
        assert(f.record.state.premium.moneyUntil==0 and f.record.premiumPrompt)
        f.market.PromptProductPurchaseFinished:Fire(101,11,false);assert(not f.record.premiumPrompt)
    end)
    test("receipt saves benefit and proof before archiving and permanent archive blocks all duplicate grants",function()
        local f=fixture();assert(f:receipt()=="granted")
        assert(f.saved.premium.moneyUntil==4600 and f.saved.premium.receipts["receipt-a"]=="money_hour")
        assert(f.values["receipt-a"].userId==101 and not f.record.state.premium.receipts["receipt-a"])
        local saves=f.saveCount;f.now=1100;assert(f:receipt()=="granted")
        assert(f.record.state.premium.moneyUntil==4600 and f.saveCount==saves and not f.record.receiptBusy)
        assert(f.record.state.credits==0 and f.record.state.chips==0)
    end)
    test("failed profile save and archive failure retry without duration extension or duplicate run agents",function()
        local f=fixture();f.failSave=true;assert(f:receipt()=="deferred" and not f.values["receipt-a"])
        assert(f.record.state.premium.moneyUntil==4600 and f.record.state.premium.receipts["receipt-a"])
        f.now=1100;f.failSave=false;f.failArchive=true;assert(f:receipt()=="deferred" and f.saved.premium.moneyUntil==4600)
        f.record.state=S.copy(f.saved);f.failArchive=false;assert(f:receipt()=="granted" and f.record.state.premium.moneyUntil==4600)
        local g=fixture();g.failArchive=true;assert(g:receipt(13)=="deferred" and #g.record.state.layerSizes-2==2)
        g.record.state=S.copy(g.saved);g.failArchive=false;assert(g:receipt(13)=="granted" and #g.record.state.layerSizes-2==2)
    end)
    test("crash after archive and CHECK reconcile proof without replaying its already saved benefit",function()
        local f=fixture();assert(f:receipt()=="granted");f.record.state=S.copy(f.saved)
        assert(next(f.record.state.premium.receipts));f.billing:reconcile(f.player,f.record)
        assert(not next(f.record.state.premium.receipts) and f.record.state.premium.moneyUntil==4600)
        assert(f:receipt()=="granted" and f.record.state.premium.moneyUntil==4600)
        local g=fixture();g.failArchive=true;g:receipt();g.failArchive=false
        g.billing:reconcile(g.player,g.record);assert(not next(g.record.state.premium.receipts) and g.record.state.premium.moneyUntil==4600)
    end)
    test("unknown absent invalid lease busy or archive-error receipts remain unprocessed without fake grants",function()
        for _,flag in ipairs({"absent","failRead"}) do local f=fixture();f[flag]=true;assert(f:receipt()=="deferred" and f.record.state.premium.moneyUntil==0) end
        for _,flag in ipairs({"closing","blocked","receiptBusy","saving"}) do local f=fixture();f.record[flag]=true;assert(f:receipt()=="deferred" and f.record.state.premium.moneyUntil==0) end
        local f=fixture();assert(f:receipt(999)=="deferred" and f.record.state.premium.moneyUntil==0)
        assert(f:receipt(11,string.rep("a",51))=="deferred")
        f.values["receipt-a"]={userId=102,productId=11};assert(f:receipt()=="deferred" and f.record.state.premium.moneyUntil==0)
    end)
    test("concurrent receipt delivery and duplicate archived receipt cannot release another native prompt",function()
        local f=fixture();local nested
        f.onSave=function() nested=f:receipt() end
        assert(f:receipt()=="granted" and nested=="deferred" and f.record.state.premium.moneyUntil==4600)
        f.billing:buy(f.player,f.record,"chips_hour",1);assert(f.record.premiumPrompt.sku=="chips_hour")
        f.onSave=nil;assert(f:receipt()=="granted" and f.record.premiumPrompt.sku=="chips_hour")
    end)
    test("live purchases fail closed in MEMORY Studio unpublished disabled duplicate or missing-ID configurations",function()
        for _,change in ipairs({function(f) f.config.STORAGE_MODE="MEMORY" end,function(f) f.billing.studio=true end,
            function(f) f.billing.published=false end,function(f) f.config.COMMERCE_ENABLED=false end,
            function(f) f.config.COMMERCE_IDS.money_hour=0 end,function(f) f.config.COMMERCE_IDS.agent=11 end}) do
            local f=fixture();change(f);f.billing:buy(f.player,f.record,"money_hour",1)
            assert(f.promptCount==0 and f:receipt()=="deferred" and f.record.state.premium.moneyUntil==0)
        end
    end)
    test("pass ownership is server checked and cannot grant from a purchase-finished boolean alone",function()
        local f=fixture();f.market.PromptGamePassPurchaseFinished:Fire(f.player,14,true)
        assert(not f.record.state.premium.forever)
        f.owned=true;f.market.PromptGamePassPurchaseFinished:Fire(f.player,14,true);assert(f.record.state.premium.forever)
        f.failPass=true;f.owned=false;f.billing:checkPass(f.player,f.record);assert(f.record.state.premium.forever)
        f.failPass=false;f.billing:checkPass(f.player,f.record);assert(not f.record.state.premium.forever)
    end)
    test("schema15 leased profiles migrate with no invented entitlement and lost leases refuse premium saves",function()
        local old=S.new(B);old.schemaVersion=15;old.credits=321;old.cardDeck[1]="ember"
        local store={record={schemaVersion=15,data=old,lock={owner="other",expiresAt=100}}}
        function store:UpdateAsync(_,callback) local value=callback(self.record);if value then self.record=value end;return value or self.record end
        local now=50;local repo=m.ProfileRepository.new(store,S,B,function() return now end,60)
        assert(not repo:acquire("premium","me") and store.record.schemaVersion==15)
        now=101;local handle=assert(repo:acquire("premium","me"))
        assert(handle.state.credits==321 and handle.state.cardDeck[1]=="ember" and not handle.state.premium.forever and not next(handle.state.premium.receipts))
        handle.state.premium.moneyUntil=4600;handle.state.premium.receipts.a="money_hour"
        assert(repo:save(handle,false) and store.record.data.premium.moneyUntil==4600 and store.record.data.premium.receipts.a)
        store.record.lock.owner="another-server";local ok,why=repo:save(handle,false)
        assert(not ok and why=="lease_lost")
    end)
    assert(#failures==0,table.concat(failures,"\n"))
    print("[VibeIdle] "..passed.." commerce specifications passed")
    return passed
end
return Specs

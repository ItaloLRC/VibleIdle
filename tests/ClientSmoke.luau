-- Executes production Bootstrap/Terminal/Desk callbacks with fake services/remotes.
-- Deliberately does not model rendering, native hit testing, fonts or Roblox focus.
return function(factories, shared)
    local function signal()
        local event = { listeners = {} }
        function event:Connect(callback)
            local connection = { Connected = true, callback = callback }
            function connection:Disconnect() self.Connected = false end
            self.listeners[#self.listeners + 1] = connection
            return connection
        end
        function event:Fire(...)
            for _, connection in ipairs(self.listeners) do
                if connection.Connected then connection.callback(...) end
            end
        end
        return event
    end
    local function fixture(roll,options)
        options=options or {}
        local f = { now = 0, submits = {}, requests = {}, autoAck = true, roll = roll or 1, lastManual = -math.huge, deferred={}, warnings={}, dropSync=options.dropSync or 0 }
        local enum = setmetatable({}, { __index = function(types, family)
            local group = setmetatable({}, { __index = function(values, name)
                local value = { Name = name };rawset(values, name, value);return value
            end })
            rawset(types, family, group);return group
        end })
        local function dimension(xs, xo, ys, yo) return { X = {Scale=xs, Offset=xo}, Y = {Scale=ys, Offset=yo} } end
        local udim2 = { new = dimension, fromOffset = function(x,y) return dimension(0,x,0,y) end,
            fromScale = function(x,y) return dimension(x,0,y,0) end }
        local vec2 = { new = function(x,y) return {X=x,Y=y} end }
        local methods, meta = {}, {}
        local function instance(className)
            if options.audioUnavailable and className=="Sound" then error("unsupported test audio") end
            return setmetatable({ properties = { ClassName=className, Visible=true, Size=udim2.fromOffset(0,0),
                Position=udim2.fromOffset(0,0), CanvasSize=udim2.fromOffset(0,0), ZIndex=1 }, children={}, signals={} }, meta)
        end
        function methods:GetPropertyChangedSignal(name)
            self.signals[name] = self.signals[name] or signal();return self.signals[name]
        end
        function methods:FireServer(...) self.OnServerEvent:Fire(f.player,...) end
        function methods:Play()
            if f.failPlay then error("test audio playback failure") end
            self.playCount=(self.playCount or 0)+1;self.Playing=true
            f.audioEvents=f.audioEvents or {}
            f.audioEvents[#f.audioEvents+1]={group=self.SoundGroup and self.SoundGroup.Name,pitch=self.PlaybackSpeed}
        end
        function methods:Stop() self.Playing=false;self.TimePosition=0 end
        function methods:FindFirstChild(name)
            for _, child in ipairs(self.children) do if child.Name == name then return child end end
        end
        function methods:WaitForChild(name) return assert(self:FindFirstChild(name), "Missing fixture child " .. name) end
        function methods:CaptureFocus()
            f.input.textBox=self;self.Focused:Fire()
        end
        function methods:SetAttribute(name,value)
            self.attributes=self.attributes or {};self.attributes[name]=value
        end
        function methods:GetAttribute(name) return self.attributes and self.attributes[name] end
        function methods:ReleaseFocus(enter)
            if f.input and f.input.textBox==self then f.input.textBox=nil;self.FocusLost:Fire(enter==true) end
        end
        function methods:IsDescendantOf(parent)
            local node = self.Parent
            while node do if node == parent then return true end;node = node.Parent end
            return false
        end
        function methods:Destroy()
            self.Destroying:Fire()
            for _, child in ipairs(self.children) do child:Destroy() end
            for _, event in pairs(self.signals) do
                for _, connection in ipairs(event.listeners) do connection:Disconnect() end
            end
        end
        local eventNames = { Activated=true, MouseEnter=true, MouseMoved=true, MouseLeave=true, InputBegan=true, Destroying=true, OnClientEvent=true, OnServerEvent=true, Focused=true, FocusLost=true, ReturnPressedFromOnScreenKeyboard=true }
        function meta:__index(key)
            if key=="FireServer" and self.properties[key] then return self.properties[key] end
            if methods[key] then return methods[key] end
            if eventNames[key] then return self:GetPropertyChangedSignal(key) end
            if key == "AbsolutePosition" then
                local parent=self.Parent and self.Parent.AbsolutePosition or vec2.new(0,0)
                local size=self.Parent and self.Parent.AbsoluteSize or vec2.new(1280,720)
                local anchor=self.AnchorPoint or vec2.new(0,0)
                local canvas=self.Parent and self.Parent.ClassName=="ScrollingFrame" and self.Parent.CanvasPosition or vec2.new(0,0)
                return vec2.new(parent.X+size.X*self.Position.X.Scale+self.Position.X.Offset-self.AbsoluteSize.X*anchor.X-canvas.X,
                    parent.Y+size.Y*self.Position.Y.Scale+self.Position.Y.Offset-self.AbsoluteSize.Y*anchor.Y-canvas.Y)
            end
            if key == "AbsoluteSize" or key == "AbsoluteWindowSize" then
                if self.ClassName == "ScreenGui" or self.ClassName == "PlayerGui" then return vec2.new(1280,720) end
                local parent = self.Parent and self.Parent.AbsoluteSize or vec2.new(1280,720)
                return vec2.new(parent.X*self.Size.X.Scale+self.Size.X.Offset, parent.Y*self.Size.Y.Scale+self.Size.Y.Offset)
            end
            if key == "AbsoluteCanvasSize" then return vec2.new(self.CanvasSize.X.Offset,self.CanvasSize.Y.Offset) end
            if self.properties[key] ~= nil then return self.properties[key] end
            return self:FindFirstChild(key)
        end
        function meta:__newindex(key, value)
            local old=self.properties[key]
            self.properties[key] = value
            if old~=value and self.signals[key] then self.signals[key]:Fire() end
            if old~=value and key=="Size" and self.signals.AbsoluteSize then self.signals.AbsoluteSize:Fire() end
            if key == "Parent" and value then value.children[#value.children+1] = self end
        end
        local function child(parent, className, name)
            local object = instance(className);object.Name=name;object.Parent=parent;return object
        end
        local playerGui = instance("PlayerGui")
        local player = instance("Player");f.player=player;playerGui.Name="PlayerGui";playerGui.Parent=player
        if options.cloud or options.analytics then player.UserId=12345 end
        local storage = instance("ReplicatedStorage")
        local folder = child(storage,"Folder","Shared")
        local sharedNames = {PremiumRules="Premium",AgentCrafting="Craft",PrestigeMotion="PrestigeMotion",SkillTreeLayout="Tree",AgentCards="Cards",PrestigeRules="Prestige",StudioTuning="Tuning", StreakCollectibles="Collectibles", Balance="Balance", State="State", Simulation="Simulation", UpgradeRules="Rules",
            AgentSession="Agent", PromptRules="Prompt", PromptDraft="Draft", PromptSession="Session",
            PromptComposer="Composer", CashFeedback="Cash", TokenCollection="Collection", RateLimiter="RateLimiter", Protocol="Protocol",
            ProfileRepository="ProfileRepository", NetworkLayout="Layout", NetworkFlow="Flow", SkillCheck="Skill", MascotDance="Dance", AgentAutomation="Auto", Soundtrack="Music" }
        for name in pairs(sharedNames) do child(folder,"ModuleScript",name) end
        local remotes = child(storage,"Folder","Remotes")
        local command = child(remotes,"RemoteEvent","Command")
        local update = child(remotes,"RemoteEvent","StateUpdate")
        local serverStorage=instance("ServerStorage");f.serverStorage=serverStorage
        function methods:Invoke(...) return self.OnInvoke(...) end
        if options.testsFail then
            local tests=child(serverStorage,"Folder","Tests")
            child(tests,"ModuleScript","Specs");child(tests,"ModuleScript","PromptSessionSpecs")
        end
        local players=instance("Players");players.LocalPlayer=player;player.Parent=players
        players.PlayerAdded=signal();players.PlayerRemoving=signal()
        function players:GetPlayers() return {player} end
        local client = instance("Folder")
        child(client,"ModuleScript","ProfileRepository")
        for name in pairs(factories) do child(client,"ModuleScript",name) end
        local input = { InputBegan=signal(), InputChanged=signal(), InputEnded=signal(), WindowFocusReleased=signal(), WindowFocused=signal(),
            LastInputTypeChanged=signal(), held={} }
        function input:GetFocusedTextBox() return self.textBox end
        function input:IsKeyDown(key) return self.held[key] == true end
        local run = { Heartbeat=signal(), IsStudio=function() return options.studio==true end }
        local gui = instance("GuiService");gui.ReducedMotionEnabled=false;gui.MenuIsOpen=false
        local workspace = instance("Workspace")
        workspace.GetServerTimeNow=function() return f.now end
        local market={PromptProductPurchaseFinished=signal(),PromptGamePassPurchaseFinished=signal()};f.market=market
        function players:GetPlayerByUserId(userId) if userId==player.UserId then return player end end
        function market:GetProductInfoAsync(assetId) return {IsForSale=true,PriceInRobux=options.robuxPrice or 10} end
        function market:UserOwnsGamePassAsync() return options.ownsPass or false end
        function market:PromptProductPurchase(_,assetId) self.lastProduct=assetId end
        function market:PromptGamePassPurchase(_,assetId) self.lastPass=assetId end
        local dataStores={};f.cloudStores=options.cloudStores or {};f.cloudQueue={}
        local function clone(value)
            if type(value)~="table" then return value end
            local copy={};for k,v in pairs(value) do copy[k]=clone(v) end;return copy
        end
        function dataStores:GetDataStore(name)
            assert(type(name)=="string" and name:find("VibeIdle",1,true));f.storeName=name
            local store=f.cloudStores[name]
            if not store then
                store={values={}};f.cloudStores[name]=store
                function store:UpdateAsync(key,transform)
                    if self.fail then error("cloud unavailable") end
                    local value=transform(clone(self.values[key]))
                    if value then self.values[key]=clone(value) end
                    return clone(value)
                end
                function store:GetAsync(key) if self.fail then error("cloud unavailable") end;return clone(self.values[key]) end
            end
            return store
        end
        function player:Kick(message) f.kicked=message end
        f.nativeAnalytics={};f.analyticsLogs={}
        local analytics={LogCustomEvent=function(_,target,name,value,fields)
            if options.analyticsFailure then error("native analytics unavailable") end
            f.nativeAnalytics[#f.nativeAnalytics+1]={player=target,name=name,value=value,fields=fields}
        end}
        local http={GenerateGUID=function() return "fixture" end,JSONEncode=function(_,value) f.analyticsLogs[#f.analyticsLogs+1]=clone(value);return "fixture-summary" end}
        local services = { MarketplaceService=market,Players=players, ServerStorage=serverStorage, DataStoreService=dataStores, HttpService=http, AnalyticsService=analytics, ReplicatedStorage=storage, Workspace=workspace,
            TextService={GetTextSize=function(_,value,size) return vec2.new(#value*size,size) end},
            RunService=run, GuiService=gui, UserInputService=input, SoundService=instance("SoundService"),
            ContentProvider={PreloadAsync=function(_,assets) f.preloaded=assets end} }
        local game = { GetService=function(_,name) return assert(services[name],name) end, JobId=options.jobId or "test",GameId=options.published and 123 or 0, BindToClose=function(_,callback) f.shutdown=callback end }
        local balance={};for key,value in pairs(shared.Balance) do balance[key]=value end
        -- Historical high-streak physics/audio cases use an explicit server-side
        -- sandbox balance. New progression scenarios use the authored caps.
        if options.legacyStreak then
            balance.progression=function(state)
                local effect=shared.Balance.progression(state)
                effect.streakCap=9999;effect.autoSkillCap=0;return effect
            end
        end
        balance.STARTING_CREDITS=options.money or 1000000
        -- Legacy scenarios freeze automation time; agent scenarios use the production cadence.
        if not options.agents then balance.AGENT_INTERVAL=math.huge end
        local tasks={delay=function() end,spawn=function(callback,...) callback(...) end,
            defer=function(callback) f.deferred[#f.deferred+1]=callback end}
        if options.cloud then
            local function resume(co,...)
                local ok,delay=coroutine.resume(co,...);assert(ok,delay)
                if coroutine.status(co)~="dead" then f.cloudQueue[#f.cloudQueue+1]={co=co,due=f.now+(delay or 0)} end
            end
            tasks.spawn=function(callback,...) resume(coroutine.create(callback),...) end
            tasks.wait=function(seconds) return coroutine.yield(seconds or .1) end
            function f:runCloudTasks()
                local queued=self.cloudQueue;self.cloudQueue={}
                for _,item in ipairs(queued) do if self.now>=item.due then resume(item.co) else self.cloudQueue[#self.cloudQueue+1]=item end end
            end
        end
        local random={new=function() return {NextInteger=function(_,low,high)
            if options.visitors and low==5 and high==10 then return 5 end
            if options.visitors and low==1 and high==9 then return options.family or 1 end
            if high==10000 then return f.roll end
            if high==100 then return options.avatarSpawnRoll or 1 end
            f.randomStep=(f.randomStep or 0)+1
            return low+((f.roll+f.randomStep*137)%(high-low+1))
        end} end}
        local function warning(value) f.warnings[#f.warnings+1]=tostring(value) end
        local cache = {}
        local function loadModule(module)
            local name = module.Name
            if name=="Balance" then return balance end
            if name=="Specs" or name=="PromptSessionSpecs" then return {run=function() error("intentional development test failure") end} end
            if name=="State" then
                local proxy={};for key,value in pairs(shared.State) do proxy[key]=value end
                proxy.new=function(config)
                    local state=shared.State.new(config)
                    if not f.profile then
                        -- Historical card fixtures retain their nine Common starters.
                        if not options.newCollection then for _,card in ipairs(config.AGENT_CARDS) do
                            if card.rank==1 then state.cardOwned[card.id]=true end
                        end end
                        for key,value in pairs(options.profile or {}) do state[key]=value end
                        -- Existing saved-bonus fixtures retain their pre13 Chip debits.
                        -- New-price scenarios explicitly supply an empty legacy map.
                        if options.profile and options.profile.prestigeSkills and options.profile.legacyPrestigeSkills==nil then
                            for id,owned in pairs(state.prestigeSkills) do state.legacyPrestigeSkills[id]=owned end
                        end
                    end
                    f.profile=state;return state
                end
                return proxy
            end
            if sharedNames[name] then return shared[sharedNames[name]] end
            if cache[name] then return cache[name] end
            local result = factories[name](game, {Parent=client}, loadModule, enum, udim2,
                {new=function(scale,offset) return {Scale=scale,Offset=offset} end}, vec2,
                {fromRGB=function(r,g,b) return {r,g,b} end}, {fromName=function(name) return {Family=name} end}, {new=instance},
                {new=function(value) return value end}, {new=function(time,color) return {time,color} end},
                {clock=function()
                    if name=="GameService" or name=="ServerBootstrap" or name=="Telemetry" then
                        -- Wall time advances between reads; client/server retain different epochs.
                        f.now=f.now+(options.serverClockStep or 0)
                        return f.now
                    end
                    return f.now+(options.clientClockOffset or 0)
                end,time=function() return 1000+f.now end}, tasks, random, warning)
            if name == "UiMotion" or name == "Onboarding" or name == "RobuxShop" or name == "AgentLab" or name == "TerminalController" or name == "TerminalDesk" or name=="SkillCheckController" or name=="AudioController" or name=="BackdropDancers" or name=="FloatingWords" or name=="PrestigePage" or name=="CardsPage" or name=="PrestigeTransition" then
                local constructor = result.new
                result.new = function(...)
                    local value = constructor(...)
                    if name == "UiMotion" then f.motion=value;value.disabled=not options.motion elseif name == "Onboarding" then f.onboarding=value elseif name == "RobuxShop" then f.robuxShop=value elseif name == "AgentLab" then f.lab=value elseif name == "TerminalController" then f.terminal=value elseif name=="TerminalDesk" then f.desk=value
                    elseif name=="PrestigeTransition" then f.transition=value elseif name=="CardsPage" then f.cardPage=value elseif name=="PrestigePage" then f.progression=value elseif name=="AudioController" then f.audio=value elseif name=="BackdropDancers" then f.dancers=value elseif name=="FloatingWords" then f.floatingWords=value else f.skill=value end
                    return value
                end
            end
            cache[name]=result;return result
        end
        f.input=input
        f.reportVersion=options.serverVersion;f.invalidProfile=options.invalidProfile
        update.FireClient=function(_,target,data)
            assert(target==player)
            if f.reportVersion then data.buildVersion=f.reportVersion end
            if f.invalidProfile then data.typingLevel=nil end
            f.server=data
            if f.autoAck then update.OnClientEvent:Fire(data) else f.delayed=f.delayed or {};f.delayed[#f.delayed+1]=data end
        end
        command.FireServer=function(_,action,value)
            if action=="analytics_pulse" and not options.analytics then return end -- Historical fixtures opt out of batched UI reports.
            f.requests[#f.requests+1]={action=action,payload=value}
            if action=="sync" and f.dropSync>0 then f.dropSync=f.dropSync-1;return end
            if action=="collect_avatar" and (f.dropCollect or 0)>0 then f.dropCollect=f.dropCollect-1;return end
            if action=="avatar_sync" and (f.dropAvatarSync or 0)>0 then f.dropAvatarSync=f.dropAvatarSync-1;return end
            if action=="agent_sync" and (f.dropAgentSync or 0)>0 then f.dropAgentSync=f.dropAgentSync-1;return end
            if action=="agent_type" and (f.dropAgent or 0)>0 then f.dropAgent=f.dropAgent-1;return end
            if (action=="prestige" or action=="buy_skill" or action=="equip_card" or action=="unequip_card" or action=="craft_card") and (f.dropProgression or 0)>0 then f.dropProgression=f.dropProgression-1;return end
            if action=="prestige_sync" and (f.dropProgressionSync or 0)>0 then f.dropProgressionSync=f.dropProgressionSync-1;return end
            if (action=="upgrade_compute" or action=="upgrade_tokens" or action=="add_layer") and (f.dropPurchase or 0)>0 then f.dropPurchase=f.dropPurchase-1;return end
            if action=="upgrade_sync" and (f.dropUpgradeSync or 0)>0 then f.dropUpgradeSync=f.dropUpgradeSync-1;return end
            if action=="skill_click" and (f.dropSkill or 0)>0 then f.dropSkill=f.dropSkill-1;return end
            if action=="submit_prompt" then
                f.submits[#f.submits+1]=value
                if (f.dropSubmit or 0)>0 then f.dropSubmit=f.dropSubmit-1;return end
            end
            command.OnServerEvent:Fire(player,action,value)
        end
        function f:snapshot() command:FireServer("sync") end
        function f:tune(key,value)
            local dev=assert(command.Parent:FindFirstChild("StudioCommand"))
            local control
            for _,candidate in ipairs(shared.Tuning.controls) do if candidate.key==key then control=candidate end end
            assert(control,"Unknown tuning key")
            for _=1,#control.values do
                if math.abs(self.server.studioTuning[key]-value)<0.000001 then return end
                self:tick(0.15);dev:FireServer(control.action)
            end
            assert(math.abs(self.server.studioTuning[key]-value)<0.000001,"Tuning value not reached")
        end
        function f:ack()
            if self.delayed then
                local data=self.delayed;self.delayed=nil;self.autoAck=true
                for _,snapshot in ipairs(data) do update.OnClientEvent:Fire(snapshot) end
            end
        end
        function f:deliverReplies()
            local replies=self.delayed or {};self.delayed=nil
            for _,snapshot in ipairs(replies) do update.OnClientEvent:Fire(snapshot) end
        end
        if not options.offline then loadModule(client.ServerBootstrap) end
        loadModule(client.Bootstrap)
        if not options.onboarding then f.onboarding:start(false) end -- Legacy scenarios begin after the actual menu.
        if not options.visitors then f.dancers.onPoll=nil end -- Opt into live random scheduling in visitor tests.
        f.theme=loadModule(client.DeskTheme)
        f.mascotCatalog=loadModule(client.MascotCatalog)
        f.fireCatalog=loadModule(client.SkillFireCatalog)
        f.command=command;f.input=input;f.enum=enum;f.gui=gui;f.udim2=udim2;f.vec2=vec2
        f.root=playerGui.VibeIdleGui.Workstation;f.playerGui=playerGui
        function f:button(parent,value)
            for _, object in ipairs(parent.children) do if object.ClassName=="TextButton" and object.Text==value then return object end end
            error("Button not found: " .. value)
        end
        -- Historical reset scenarios settle only the cosmetic transition before
        -- starting their next explicit action. Dedicated tests use real ticks.
        function f:finishPrestige() if self.transition.active then self.transition:finish() end end
        function f:shop() if not self.root.StorePanel.Visible then self:main() end end
        function f:reconnect()
            if not options.onboarding and self.onboarding:blocks() then
                self.onboarding.options.reconnect();self.onboarding:start(false)
            end
            local destination
            if self.root.Pages.AgentLabPage.Visible then destination="Laboratory"
            elseif self.cardPage.frame.Visible then destination="Cards"
            elseif self.progression.frame.Visible then destination=self.progression.mode=="Tree" and "SkillTree" or "Prestige" end
            local guideWasOpen=self.root.Pages.GuidePage.Visible
            self:guide();self.root.Pages.GuidePage.Instructions.ConnectionSettings.Reconnect.Activated:Fire()
            if destination then self:feature(destination) elseif not guideWasOpen then self:main() end
        end
        function f:quantity(value)
            self:shop()
            for _=1,5 do
                if self.root.StorePanel.PurchaseQuantity:GetAttribute("Quantity")==value then return end
                self.root.StorePanel.PurchaseQuantity.Activated:Fire()
            end
            assert(self.root.StorePanel.PurchaseQuantity:GetAttribute("Quantity")==value)
        end
        function f:guide() if not self.root.DesktopDock.Visible then self:main() end;self:button(self.root.DesktopDock,"Guide").Activated:Fire() end
        -- Locate by type/text rather than relying on child decoration ordering.
        function f:buyUpgrade(action)
            self:shop()
            self:tick(0.31)
            local card=self.root.StorePanel.UpgradeList[action]
            for _, object in ipairs(card.children) do if object.ClassName=="TextButton" then object.Activated:Fire();return end end
            error("Missing agent purchase")
        end
        -- Seed historical progression for inherited reward/animation regressions.
        -- Live remotes reject these retired commands; this is test setup only.
        function f:restoreLegacyUpgrade(action)
            self:tick(0.31)
            assert(shared.Rules.purchase(self.profile,action,nil,balance))
            self:snapshot()
        end
        function f:buyAgent() self:buyUpgrade("add_layer") end
        function f:pointer(object,touch)
            local p=object.AbsolutePosition
            return {UserInputType=touch and enum.UserInputType.Touch or enum.UserInputType.MouseButton1,Position={X=p.X+(object.Name=="WindowTitle" and math.min(338,object.AbsoluteSize.X-12) or 20),Y=p.Y+20}}
        end
        function f:expose(index)
            self.terminal.frame.Position=udim2.fromOffset(0,math.min(80,self.desk.parent.AbsoluteSize.Y-self.terminal.frame.AbsoluteSize.Y))
            self.desk.windows[index].frame.Position=udim2.fromOffset(0,0)
        end
        function f:press(name,processed)
            local object={UserInputType=enum.UserInputType.Keyboard,KeyCode={Name=name}}
            input.InputBegan:Fire(object,processed or false)
            return object
        end
        function f:key(name,processed)
            local object=self:press(name,processed)
            input.InputEnded:Fire(object)
            self.now=self.now+1;run.Heartbeat:Fire(0.016)
        end
        function f:tick(dt) self.now=self.now+dt;run.Heartbeat:Fire(dt) end
        function f:finishUi()
            for _=1,30 do if not self.motion:busy() then return end;self:tick(1/60) end
            assert(not self.motion:busy(),"UI transition did not settle")
        end
        function f:finishSellWriting()
            for _=1,60 do
                if not self.terminal.sendRequested or self.terminal.skillPending or self.terminal.agentPending
                    or not next(self.terminal.reveals) then break end
                self:tick(0.01)
            end
        end
        function f:finishCollection()
            for _=1,130 do
                if not self.terminal:isCollecting() then return end
                self:tick(0.1)
            end
            assert(not self.terminal:isCollecting(),"Collection failed to finish")
        end
        function f:send()
            if input:GetFocusedTextBox()==self.terminal.input then self.terminal.input:ReleaseFocus(true)
            else self:key("Return") end
            self:finishSellWriting()
        end
        -- Composer/payout regressions insert directly without the QTE adapter.
        -- Skill scenarios below use real key/click callbacks.
        function f:compose(value)
            self.terminal:focusInput();self.terminal.input:CaptureFocus()
            self.terminal:appendWords(#value)
        end
        -- Fill through actual server agent receipts for full-context regressions.
        function f:fillContext()
            local previous=balance.AGENT_INTERVAL
            balance.AGENT_INTERVAL=1
            for _=1,64 do
                if self.terminal.composer.count==self.terminal.limit then break end
                self.terminal.nextAgent=self.now
                self:tick(1)
            end
            balance.AGENT_INTERVAL=previous;self:snapshot()
            assert(self.terminal.composer.count==self.terminal.limit)
        end
        function f:rawText(value)
            self.terminal.input:CaptureFocus();self.terminal.input.Text=value
        end
        function f:event()
            local check=self.skill.check
            assert(check,"Missing skill challenge")
            if self.now<check.startsAt then self:tick(check.startsAt-self.now+0.001) end
            return self.skill.button
        end
        function f:aim(grade)
            self:event()
            local check=self.skill.check
            local angle=grade=="Great" and check.target or grade=="Good" and check.target-(check.goodWidth+check.greatWidth)/4 or (check.target+130)%360
            local phase=shared.Skill.phase(check,self.now)
            self:tick(((angle-phase)%360)/360*check.duration)
        end
        function f:hit(grade,touch)
            self:aim(grade or "Normal")
            local cap=self:event();local p,s=cap.AbsolutePosition,cap.AbsoluteSize
            cap.Activated:Fire({UserInputType=touch and enum.UserInputType.Touch or enum.UserInputType.MouseButton1,
                Position={X=p.X+s.X/2,Y=p.Y+s.Y/2}})
            return cap
        end
        function f:runDeferred() for _,callback in ipairs(self.deferred) do callback() end;self.deferred={} end
        function f:main()
            self:finishPrestige()
            if self.root.ReturnCLI.Visible then self.root.ReturnCLI.Activated:Fire()
            else self:button(self.root.DesktopDock,"Main CLI").Activated:Fire() end
        end
        function f:feature(name)
            self:finishPrestige()
            if not self.root.FeatureDock.Visible then self:main() end
            self.root.FeatureDock[name].Activated:Fire()
        end
        function f:title(index)
            local bar=self.desk.windows[index].bar
            local pointer=self:pointer(bar)
            bar.InputBegan:Fire(pointer);input.InputEnded:Fire(pointer);bar.Activated:Fire(pointer)
        end
        return f
    end
    local function highStreakFixture(roll,options)
        options=options or {};options.legacyStreak=true
        return fixture(roll,options)
    end
    local passed,failures=0,{}
    local function test(name,callback)
        local ok,reason=pcall(callback)
        if ok then passed=passed+1;print("PASS production callbacks: "..name)
        else failures[#failures+1]=name..": "..tostring(reason);print("FAIL production callbacks: "..failures[#failures]) end
    end
    test("fluid page cover commits once blocks covered actions and preserves draft and page scroll",function()
        local f=fixture(1,{motion=true,money=10000});f:finishUi()
        local draft=f.terminal.composer.draft.id;local money=f.server.credits
        f:feature("Laboratory")
        assert(f.motion:busy() and f.motion.cover.Visible and f.desk.parent.Visible and not f.lab.frame.Visible and not f.terminal:canEdit())
        f:feature("Cards");f.root.StorePanel.UpgradeList.add_layer.BuyUpgrade.Activated:Fire();f.terminal.send.Activated:Fire()
        assert(f.server.credits==money and #f.submits==0)
        f:tick(.05);assert(f.motion.cover.BackgroundTransparency>0 and f.motion.cover.BackgroundTransparency<1 and not f.lab.frame.Visible)
        f:tick(.05);assert(f.lab.frame.Visible and f.motion:busy() and not f.cardPage.frame.Visible)
        f:finishUi();assert(not f.motion.cover.Visible and f.root.Pages.Position.Y.Offset==0 and f.terminal.composer.draft.id==draft)
        f.lab.list.CanvasPosition=f.vec2.new(0,80);f:main();assert(f.motion:busy());f:finishUi()
        assert(f.desk.parent.Visible and f.terminal:canEdit());f:feature("Laboratory");f:finishUi()
        assert(f.lab.list.CanvasPosition.Y==80 and f.server.credits==money)
    end)
    test("fluid motion pauses without catchup and reduced motion commits immediately with correct focus after resize",function()
        local f=fixture(1,{motion=true});f:finishUi();f.input.GamepadEnabled=true
        f:feature("Cards");f:tick(.05);local age=f.motion.transition.age
        f.gui.MenuIsOpen=true;f:tick(8);assert(f.motion.transition.age==age and not f.gui.SelectedObject)
        f.root.Size=f.udim2.fromOffset(360,640);f.gui.ReducedMotionEnabled=true
        assert(not f.motion:busy() and not f.motion.cover.Visible and f.cardPage.frame.Visible and not f.terminal.uiTransition)
        assert(not f.gui.SelectedObject);f.gui.MenuIsOpen=false;f:tick(.01)
        assert(f.gui.SelectedObject and f.gui.SelectedObject:IsDescendantOf(f.cardPage.frame))
        f:main();assert(not f.motion:busy() and f.desk.parent.Visible)
        f.gui.ReducedMotionEnabled=false;f:feature("RobuxShop");f:tick(.05);age=f.motion.transition.age
        f.input.WindowFocusReleased:Fire();f:tick(10);assert(f.motion.transition.age==age)
        f.input.WindowFocused:Fire();f:finishUi();assert(f.robuxShop.frame.Visible and #f.submits==0)
    end)
    test("fluid status text fades pause and reduced mode restores readability without delaying confirmed money",function()
        local f=fixture(1,{motion=true,money=0});f:finishUi()
        local label=f.terminal.hint;label.Text="Ready for your next sale."
        assert(label.TextTransparency>0 and label.TextTransparency<1);f:tick(.05)
        local alpha=label.TextTransparency;assert(alpha>0 and alpha<.6)
        f.input.WindowFocusReleased:Fire();f:tick(1);assert(label.TextTransparency==alpha)
        f.input.WindowFocused:Fire();f.gui.ReducedMotionEnabled=true;assert(label.TextTransparency==0)
        f.gui.ReducedMotionEnabled=false;f:compose("a");f:send()
        assert(f.server.credits==1 and f.root.MoneyHUD.Balance.Text=="$1.00" and not f.motion:busy())
        local count=#f.motion.texts;f.motion:watchText(label);assert(#f.motion.texts==count and count<=64 and #f.motion.buttons<=48)
        for _=1,15 do f:tick(1/60) end
        assert(label.TextTransparency==0 and f.server.credits==1)
    end)
    test("fluid button feedback has fixed hit bounds rejects clipped hover and cleans up mid transition",function()
        local f=fixture(1,{motion=true});f:finishUi();local button=f.root.FeatureDock.Laboratory
        local pointer=f:pointer(button);local size=button.AbsoluteSize
        button.MouseMoved:Fire(pointer.Position.X,pointer.Position.Y);f:tick(.05)
        assert(button.HoverGleam.BackgroundTransparency<1 and not button.HoverGleam.Active)
        assert(button.AbsoluteSize.X==size.X and button.AbsoluteSize.Y==size.Y)
        local alpha=button.HoverGleam.BackgroundTransparency
        button.MouseMoved:Fire(10000,10000);f:tick(.05);assert(button.HoverGleam.BackgroundTransparency>alpha)
        f.gui.MenuIsOpen=true;f:tick(.1);assert(button.HoverGleam.BackgroundTransparency==1);f.gui.MenuIsOpen=false
        f:feature("Laboratory");assert(f.motion:busy());f.root.Parent:Destroy()
        assert(f.motion.destroyed and not f.motion:busy() and not f.terminal.uiTransition)
        for _,connection in ipairs(f.motion.connections) do assert(not connection.Connected) end
        assert(not f.motion:begin(function() error("destroyed owner committed") end))
    end)
    test("fluid start tutorial and skip transitions cannot replay a confirmed skill or dismiss twice",function()
        local f=fixture(1,{motion=true,onboarding=true,money=0});local tour=f.onboarding
        tour.play.Activated:Fire();tour.play.Activated:Fire()
        assert(f.motion:busy() and tour.mode=="Start");f:finishUi();assert(tour.step=="Skill")
        f:hit("Great");assert(f.motion:busy() and tour.step=="Skill")
        tour.skip.Activated:Fire();f:finishUi();assert(tour.step=="Sell" and not f.server.tutorialDone)
        tour.skip.Activated:Fire();tour.skip.Activated:Fire();f:finishUi()
        assert(tour.mode=="Hidden" and f.server.tutorialDone and f.server.stats.streak==1 and f.server.credits==0)
        local dismissals=0;for _,request in ipairs(f.requests) do if request.action=="tutorial_complete" then dismissals=dismissals+1 end end
        assert(dismissals==1 and #f.submits==0)
    end)
    test("behavior metrics count confirmed skill sale visitor and upgrade actions once with read-only server reports",function()
        local f=fixture(1,{analytics=true,agents=true,visitors=true,money=1000000})
        f:hit("Great");f:hit("Normal");f:hit("Good")
        local a=f.profile.analytics
        assert(a.sessions==1 and a.skillGreat==1 and a.skillMiss==1 and a.skillGood==1)
        local request
        for _,item in ipairs(f.requests) do if item.action=="skill_click" then request=item end end
        f:tick(.2);f.command:FireServer("skill_click",request.payload)
        assert(a.skillGood==1 and a.skillRejected==1)
        for _=1,15 do f:tick(.1) end
        f:send();assert(a.sales==1 and a.tokensSold>0 and a.moneyEarned>0)
        local earned=a.moneyEarned;local sale=f.submits[1]
        f:tick(.2);f.command:FireServer("submit_prompt",sale);assert(a.sales==1 and a.moneyEarned==earned and a.saleRejected==1)
        f:finishCollection();f:quantity(5);f:buyUpgrade("upgrade_compute")
        assert(a.upgradePurchases.upgrade_compute==1 and a.upgradeLevels.upgrade_compute==5)
        local upgrade=f.requests[#f.requests];f:tick(.2);f.command:FireServer(upgrade.action,upgrade.payload)
        assert(a.upgradeLevels.upgrade_compute==5)
        for _=1,100 do f:tick(.1);if f.dancers.pool[1].active then break end end
        local avatar=f.dancers.pool[1];assert(avatar.active)
        local id=avatar.collectibleId;assert(f.dancers:collect(avatar,f:pointer(avatar.button)))
        local fragments=a.fragmentsCollected;f:tick(.2);f.command:FireServer("collect_avatar",{id=id})
        assert(a.visitors==1 and a.fragmentsCollected==fragments and fragments>0)
        local report=f.serverStorage.VibeIdleAnalyticsReport:Invoke(12345)
        assert(f.server.analytics==nil and shared.State.fromSnapshot(f.server,shared.Balance))
        assert(report.userId==12345 and report.totals.sales==1 and report.session.skillGreat==1 and report.sessionSeconds>0)
        report.totals.sales=999;assert(a.sales==1)
        assert(f.serverStorage.VibeIdleAnalyticsReport:Invoke(-1).error=="invalid_user_id")
    end)
    test("batched SELL button and Enter estimates preserve empty and busy press counts without creating sales",function()
        local f=fixture(1,{analytics=true,money=0});local a=f.profile.analytics
        f:tick(.01);f.terminal.send.Activated:Fire();f.terminal.send.Activated:Fire()
        f:send();assert(#f.submits==0 and a.sales==0)
        f:tick(15);assert(a.sellButtonReported==2 and a.sellEnterReported==1)
        local before=a.sellButtonReported;f:tick(.2)
        f.command:FireServer("analytics_pulse",{requestId=999,button=9999,enter=0,focused=true,page="CLI",money=100})
        assert(a.sellButtonReported==before and f.profile.credits==0)
        f:guide();f.terminal.send.Activated:Fire();f:tick(15);assert(a.sellButtonReported==before)
    end)
    test("behavior counters persist through cloud saves and server-only offline lookup never mutates saved profiles",function()
        local f=fixture(1,{cloud=true,published=true,analytics=true,agents=true,money=0});f:hit("Great")
        f:tick(1.1);f:send();f.shutdown()
        local saved=f.cloudStores[f.storeName].values.User_12345
        assert(saved.data.analytics.sales==1 and saved.data.analytics.skillGreat==1)
        local g=fixture(1,{cloud=true,published=true,analytics=true,cloudStores=f.cloudStores,jobId="metrics-next"})
        local report=g.serverStorage.VibeIdleAnalyticsReport:Invoke(12345)
        assert(report.totals.sales==1 and report.totals.sessions==2 and report.session.sales==0)
        g.shutdown();g.player.Parent.PlayerRemoving:Fire(g.player)
        local offline=g.serverStorage.VibeIdleAnalyticsReport:Invoke(12345)
        assert(offline.scope=="last_saved" and offline.totals.sales==1)
        assert(not g.cloudStores[g.storeName].values.User_12345.lock)
    end)
    test("start screen waits for validated draft pauses gameplay and cannot buy or open covered pages",function()
        local f=fixture(1,{onboarding=true,agents=true,money=20000,visitors=true})
        local t=f.onboarding;assert(t.mode=="Start" and t.ready and f.terminal.onboardingPaused and not f.terminal:canAutomate())
        local money=f.server.credits;f:tick(10)
        f:feature("Laboratory");f:buyAgent();f:send()
        assert(not f.lab.frame.Visible and f.server.credits==money and #f.server.layerSizes-2==1 and #f.submits==0 and f.terminal.composer.count==0)
        f.gui.MenuIsOpen=true;t.play.Activated:Fire();f.gui.MenuIsOpen=false;assert(t.mode=="Start")
        t.play.Activated:Fire();assert(t.mode=="Tutorial" and t.step=="Skill" and f.terminal:canEdit())
    end)
    test("tutorial advances only on a matched good skill sale receipt and clicked real visitor",function()
        local f=fixture(1,{onboarding=true,agents=true,visitors=true,money=0,newCollection=true})
        local t=f.onboarding;t.play.Activated:Fire();f:hit("Normal");assert(t.step=="Skill")
        f:hit("Great");assert(t.step=="Sell" and f.server.stats.streak==1)
        for _=1,15 do f:tick(.1) end
        assert(f.terminal.composer.count>0)
        f.autoAck=false;f:send();assert(t.step=="Sell" and #f.submits==1)
        f:ack();assert(t.step=="Visitor" and f.server.credits>0)
        for _=1,100 do f:tick(.1);if t.actor then break end end
        assert(t.actor and t.hole and not f.server.tutorialDone)
        local actor=t.actor;local total=f.server.fragments.ember
        local beforeRequests=#f.requests;f.autoAck=false
        assert(f.dancers:collect(actor,f:pointer(actor.button)))
        assert(t.step=="Visitor" and #f.requests==beforeRequests+1)
        f:ack();assert(t.step=="Done" and f.server.fragments.ember==total+1)
        local money=f.server.credits;t.skip.Activated:Fire()
        assert(t.mode=="Hidden" and f.server.tutorialDone and f.server.credits==money)
        f:snapshot();assert(t.mode=="Hidden")
    end)
    test("tutorial masks reject free clicks covered SELL visitors and page shortcuts across resize",function()
        local f=fixture(1,{onboarding=true,agents=true,visitors=true});local t=f.onboarding;t.play.Activated:Fire()
        for _,size in ipairs({{1280,720},{360,640},{320,360}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2]);t:layout()
            local r=t.hole;assert(r and r.w>0 and r.h>0 and r.x>=0 and r.y>=0 and r.x+r.w<=size[1] and r.y+r.h<=size[2])
            local p,s=t.dialog.AbsolutePosition,t.dialog.AbsoluteSize
            assert(p.Y+s.Y<=r.y or p.Y>=r.y+r.h or p.X+s.X<=r.x or p.X>=r.x+r.w,"Dialogue covers the highlighted action")
            for _,mask in ipairs(t.masks) do assert(mask.AbsoluteSize.X>=0 and mask.AbsoluteSize.Y>=0 and mask.Active and not mask.Selectable) end
            assert(not t:allows("Skill",f:pointer(t.dialog)))
            assert(not f.skill.allowFreeSpace({Position={X=1,Y=1}}))
        end
        f:feature("Cards");f:send();assert(not f.cardPage.frame.Visible and #f.submits==0)
        local money=f.server.credits;t.skip.Activated:Fire()
        assert(t.mode=="Hidden" and f.server.tutorialDone and f.server.credits==money)
        f:guide();f.root.Pages.GuidePage.Instructions.TutorialSettings.ReplayTutorial.Activated:Fire()
        assert(t.mode=="Tutorial" and t.step=="Skill" and f.desk.parent.Visible)
    end)
    test("offline start screen exposes bounded reconnect and blocks invalid or mixed-version snapshots",function()
        for _,options in ipairs({{offline=true},{serverVersion="old"},{invalidProfile=true}}) do
            options.onboarding=true;local f=fixture(1,options);local t=f.onboarding
            for _=1,150 do f:tick(.1) end
            assert(not t.ready and t.mode=="Start" and t.play.Text=="RECONNECT")
            local count=#f.requests;t.play.Activated:Fire()
            assert(#f.requests==count+1 and f.requests[#f.requests].action=="sync" and #f.submits==0)
        end
    end)
    test("owned automatic checks and auto sell cannot bypass the explicit tutorial actions",function()
        local owned={boot=true,tokens=true,focus=true,cache=true};local spent=0
        for _,node in ipairs(shared.Balance.PRESTIGE_NODES) do if owned[node.id] then spent=spent+node.cost end end
        local f=fixture(1,{onboarding=true,agents=true,money=0,profile={lifetimeEarned=shared.Balance.PRESTIGE_BASE*spent^3,
            prestigeClaimed=spent,prestigeCount=1,chips=0,prestigeSkills=owned,legacyPrestigeSkills={}}})
        assert(f.server.progression.autoSell and f.server.progression.autoSkillCap==5,"Expected owned Auto sell and Auto check")
        assert(f.onboarding.ready,f.warnings[1] or f.terminal.hint.Text)
        f.onboarding.play.Activated:Fire()
        for _=1,15 do f:tick(1) end
        assert(f.terminal.composer.count==f.terminal.limit and #f.submits==0 and f.server.stats.streak==0 and f.onboarding.step=="Skill",
            string.format("tokens=%d/%d sales=%d streak=%d step=%s",f.terminal.composer.count,f.terminal.limit,#f.submits,f.server.stats.streak,tostring(f.onboarding.step)))
        for _,request in ipairs(f.requests) do assert(request.action~="auto_skill" and request.action~="submit_prompt") end
    end)
    test("returning player continues directly and replay skip remains cosmetic under focus guards",function()
        local f=fixture(1,{onboarding=true,profile={tutorialDone=true}});local t=f.onboarding
        assert(t.play.Text=="CONTINUE");t.play.Activated:Fire();assert(t.mode=="Hidden")
        f:guide();f.root.Pages.GuidePage.Instructions.TutorialSettings.ReplayTutorial.Activated:Fire()
        local count=#f.requests;f.input.WindowFocusReleased:Fire();t.skip.Activated:Fire();assert(#f.requests==count and t.mode=="Tutorial")
        f.input.WindowFocused:Fire();f.input.held[f.enum.KeyCode.LeftControl]=true;t.skip.Activated:Fire();assert(t.mode=="Tutorial")
        f.input.held={};t.skip.Activated:Fire();assert(t.mode=="Hidden")
        f.root.Parent:Destroy();assert(t.destroyed and not f.terminal.onboardingPaused)
        t.play.Activated:Fire();assert(t.destroyed)
    end)
    test("published cloud progress autosaves exits reloads and never falls back on failed loads",function()
        local f=fixture(1,{cloud=true,published=true,agents=true,newCollection=true,money=0})
        assert(f.server.storageMode=="DATASTORE" and f.storeName=="VibeIdle_Profiles_v1")
        f.command:FireServer("tutorial_complete",{requestId=1});f:tick(1.1);f:send()
        local money=f.server.credits;assert(money>0)
        f:tick(61);f:runCloudTasks();f:snapshot()
        local saved=f.cloudStores[f.storeName].values.User_12345
        assert(saved.data.credits==money and saved.data.tutorialDone and f.server.persistence.status=="saved")
        f.shutdown();assert(not f.cloudStores[f.storeName].values.User_12345.lock)
        local g=fixture(1,{cloud=true,published=true,cloudStores=f.cloudStores,jobId="next",onboarding=true})
        assert(g.server.credits==money and g.server.tutorialDone and g.onboarding.play.Text=="CONTINUE")
        g.shutdown();g.cloudStores[g.storeName].fail=true
        local bad=fixture(1,{cloud=true,published=true,cloudStores=g.cloudStores,onboarding=true})
        assert(bad.kicked and not bad.server and not bad.onboarding.ready)
        assert(saved.data.credits==money)
    end)
    test("cloud save failure is visible preserves stored data and pauses after lease expiry",function()
        local f=fixture(1,{cloud=true,published=true,onboarding=true})
        local store=f.cloudStores[f.storeName];store.fail=true
        f:tick(61);f:runCloudTasks();f:snapshot()
        assert(f.server.persistence.status=="delayed" and f.onboarding.status.Text:find("SAVE DELAYED",1,true))
        f:tick(121);f:snapshot();assert(f.server.blocked and not f.onboarding.ready)
        assert(store.values.User_12345.data.credits==1000000)
        local studio=fixture(1,{studio=true,published=true})
        assert(studio.server.storageMode=="MEMORY" and not studio.storeName)
    end)
    test("checks leave an empty draft empty while agents remain the only production path",function()
        local f=fixture(1,{agents=true,money=0});local callback=f.terminal.onAgent;f.terminal.onAgent=nil
        local draft=f.terminal.composer.draft;local first=draft.offers[1]
        for _=1,6 do f:hit("Great") end
        assert(f.skill.streak==5 and f.terminal.composer.count==0 and #f.server.skillCheck.awards==0)
        assert(f.terminal.composer.draft==draft and draft.offers[1]==first and not next(f.terminal.reveals))
        assert(#f.submits==0 and f.server.credits==0 and f.server.skillCheck.lastClick.wordCount==0)
        f.terminal.onAgent=callback;f:tick(1);f.terminal.onAgent=nil
        assert(f.terminal.composer.count>0 and f.server.lastAgent.wordCount==f.terminal.composer.count)
        for _,award in ipairs(f.server.skillCheck.awards) do assert(award.grade=="Agent" and award.multiplier==1.5) end
        assert(f.server.credits==0 and #f.submits==0)
    end)
    test("checks preserve a written agent token and only a later agent grant receives new streak",function()
        local f=fixture(1,{agents=true,money=0});local callback=f.terminal.onAgent;f.terminal.onAgent=nil
        f:hit("Great");f.terminal.onAgent=callback;f:tick(1);f.terminal.onAgent=nil
        assert(f.terminal.composer.count==1 and f.server.skillCheck.awards[1].multiplier==1.1)
        for _=1,4 do f:hit("Great") end
        assert(f.terminal.composer.count==1 and f.skill.streak==5 and f.server.skillCheck.awards[1].multiplier==1.1)
        f.terminal.onAgent=callback;f:tick(1);f.terminal.onAgent=nil
        local count=f.terminal.composer.count;assert(count>1)
        for index=2,count do assert(f.server.skillCheck.awards[index].multiplier==1.5) end
        f:hit("Normal");assert(f.skill.streak==0 and f.terminal.composer.count==count)
        assert(f.server.skillCheck.awards[1].multiplier==1.1 and f.server.credits==0)
        f:send();assert(math.abs(f.server.credits-(1.1+(count-1)*1.5))<0.0001 and #f.submits==1)
    end)
    test("top features replace the workstation with full pages and hidden controls cannot act",function()
        local f=fixture(1,{studio=true});f:compose("abc")
        local draft=f.terminal.composer.draft.id
        local window=f.terminal.frame
        assert(math.abs(window.Position.X.Offset+window.Size.X.Offset/2-shared.Agent.workstationLayout(1280,720,1).width/2)<=1)
        assert(f.root.StorePanel.Position.Y.Offset>8 and f.root.DesktopDock.StudioToolsShortcut.Text=="Studio tools")
        for _,feature in ipairs({"Laboratory","Cards","SkillTree","Prestige"}) do
            f:feature(feature)
            local surface=feature=="Laboratory" and f.root.Pages.AgentLabPage or feature=="Cards" and f.cardPage.frame or f.progression.frame
            assert(surface.Visible and surface.AbsoluteSize.X>=f.root.AbsoluteSize.X-16)
            assert(f.root.Pages.AbsoluteSize.X==f.root.AbsoluteSize.X and f.root.ReturnCLI.Visible)
            assert(not f.root.FeatureDock.Visible and not f.root.MoneyHUD.Visible and not f.root.StorePanel.Visible)
            assert(not f.root.DesktopDock.Visible and not f.desk.parent.Visible and not f.skill.layer.Visible and not f.dancers.layer.Visible)
            local requests=#f.requests
            f.root.StorePanel.UpgradeList.upgrade_compute.BuyUpgrade.Activated:Fire()
            f.root.FeatureDock.Cards.Activated:Fire(f:pointer(f.root.FeatureDock.Cards))
            f.root.DesktopDock.StudioToolsShortcut.Activated:Fire()
            f:button(f.root.DesktopDock,"Guide").Activated:Fire()
            assert(surface.Visible and #f.requests==requests and #f.submits==0)
            f.root.ReturnCLI.Activated:Fire(f:pointer(f.root.ReturnCLI))
            assert(not surface.Visible and not f.root.ReturnCLI.Visible)
            assert(f.root.FeatureDock.Visible and f.root.MoneyHUD.Visible and f.root.StorePanel.Visible and f.root.DesktopDock.Visible)
            assert(f.terminal.composer.count==3 and f.terminal.composer.draft.id==draft)
        end
    end)
    test("prestige dashboard derives gain progress and permanent bonus from confirmed Chip snapshots",function()
        local f=fixture(1,{money=0,profile={lifetimeEarned=3375}});f:feature("Prestige")
        local p=f.progression
        assert(p.chipAmount.Text=="0" and p.gain.Text=="+1" and p.perChip.Text=="+5%")
        assert(p.bonusNow.Text=="+0%" and p.bonusAfter.Text=="+5%")
        assert(p.progressText.Text=="33%" and math.abs(p.progressFill.Size.X.Scale-2375/7000)<0.00001)
        assert(p.remaining.Text:find("$4.6K",1,true) and #f.submits==0 and f.server.chips==0)
        p.body.CanvasPosition=f.vec2.new(0,400)
        p.ascend.Activated:Fire(f:pointer(p.ascend));assert(p.armed and p.ascendArt.label.Text=="CONFIRM RESET" and f.server.chips==0)
        f.autoAck=false;p.ascend.Activated:Fire(f:pointer(p.ascend))
        assert(p.pending and p.chipAmount.Text=="0" and f.server.chips==1)
        f:ack();assert(p.chipAmount.Text=="1" and p.gain.Text=="+0" and p.bonusNow.Text=="+5%")
        f:feature("SkillTree");p.nodes.boot.buy.Activated:Fire();assert(f.server.chips==0)
        f:feature("Prestige");assert(p.chipAmount.Text=="0" and p.bonusNow.Text=="+5%" and p.bonusAfter.Text=="+5%")
        local nextChip=fixture(1,{money=0,profile={lifetimeEarned=8000,chips=0,prestigeClaimed=1,prestigeCount=1,prestigeSkills={boot=true}}})
        nextChip:feature("Prestige")
        assert(nextChip.progression.gain.Text=="+1" and nextChip.progression.bonusAfter.Text=="+10%" and nextChip.progression.progressText.Text=="0%")
        assert(#f.submits==0 and f.server.credits==0)
        for _,size in ipairs({{320,360},{360,640},{1280,720}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2])
            assert(p.ascend.AbsoluteSize.Y==48 and p.dashboard.AbsoluteSize.X<=p.body.AbsoluteSize.X)
            assert(p.ascend.AbsolutePosition.Y>=p.frame.AbsolutePosition.Y and p.ascend.AbsolutePosition.Y+48<=size[2]-24)
            assert(p.ascend.AbsolutePosition.X>=p.frame.AbsolutePosition.X and p.ascend.AbsolutePosition.X+p.ascend.AbsoluteSize.X<=p.frame.AbsolutePosition.X+p.frame.AbsoluteSize.X)
            assert(p.gain.TextSize>=12 and not p.gain.TextWrapped)
        end
    end)
    test("real sales earn the first prestige Chip and confirmed reset preserves no unsold words",function()
        local f=fixture(10000,{money=0});f:compose("abcd");f:send()
        assert(f.server.lifetimeEarned==1000 and f.server.chips==0 and f.server.prestige.available==1)
        f:compose("a");local oldDraft=f.terminal.composer.draft.id
        f:feature("Prestige")
        local p=f.progression;assert(p.frame.Visible and p.mode=="Prestige" and f.terminal.suspended)
        p.ascend.Activated:Fire();assert(p.armed and f.server.chips==0 and f.server.credits==1000)
        p.ascend.Activated:Fire()
        assert(f.server.chips==1 and f.server.prestigeClaimed==1 and f.server.prestigeCount==1)
        assert(f.server.credits==0 and f.server.batches==0 and f.server.lifetimeEarned==1000 and f.server.moneyPerToken==1.16)
        assert(f.terminal.composer.count==0 and f.terminal.composer.draft.id>oldDraft and #f.terminal.collection.batches==0)
        assert(f.root.MoneyHUD.Chips.Text=="1 Chips" and not f.terminal.progressionPending)
        f:main();f:tick(0.2);assert(#f.submits==1 and f.server.chips==1)
    end)
    test("confirmed prestige pulls the actual GUI once then reveals normal Main CLI without gameplay during the effect",function()
        local f=fixture(1,{money=0,profile={lifetimeEarned=1000}})
        local home=f.root.Size;f.input.GamepadEnabled=true
        f:feature("Prestige");local p=f.progression;local effect=f.transition
        p.ascend.Activated:Fire();assert(not effect.active)
        p.ascend.Activated:Fire()
        assert(effect.active and effect.gui.DisplayOrder==30 and effect.blocker.Active and effect.blocker.Visible)
        assert(f.terminal.presentationPaused and not f.terminal:canAutomate() and not f.terminal:canEdit())
        assert(f.server.prestigeCount==1 and f.server.chips==1 and #effect.specks==144 and #effect.core==24)
        local agentTicks=0;local originalAgentTick=f.terminal.tickAgents
        f.terminal.tickAgents=function(self,dt) agentTicks=agentTicks+1;return originalAgentTick(self,dt) end
        local frameSize=f.terminal.frame.Size
        local stripPosition,stripSize=effect.specks[1].Position,effect.specks[1].Size
        for _=1,5 do f:tick(.1) end
        assert(f.root.Rotation>0 and f.root.PrestigeScale.Scale<1)
        assert(effect.specks[1].Position==stripPosition and effect.specks[1].Size==stripSize)
        f.root:GetPropertyChangedSignal("AbsoluteSize"):Fire()
        f.root.StorePanel.UpgradeList:GetPropertyChangedSignal("AbsoluteSize"):Fire()
        f.cardPage.body:GetPropertyChangedSignal("AbsoluteSize"):Fire()
        assert(f.terminal.frame.Size==frameSize)
        local age=effect.age;f:snapshot();assert(effect.age==age and effect.lastId==p.sequence)
        while not effect.covered do f:tick(.1) end
        assert(f.desk.parent.Visible and f.root.StorePanel.Visible and not p.frame.Visible and effect.veil.BackgroundTransparency==0)
        local requests=#f.requests
        f.root.FeatureDock.Cards.Activated:Fire();f:button(f.root.DesktopDock,"Guide").Activated:Fire()
        f.root.StorePanel.PurchaseQuantity.Activated:Fire()
        local buy=f.root.StorePanel.UpgradeList.upgrade_compute.BuyUpgrade;buy.Active=true;buy.Activated:Fire()
        f.skill.button.Activated:Fire();f.terminal.send.Activated:Fire();f:press("Return")
        assert(#f.requests==requests and not f.desk:activate(1) and f.terminal.composer.count==0)
        for _=1,10 do if effect.active then f:tick(.1) end end
        assert(not effect.active and not effect.blocker.Visible and not f.terminal.presentationPaused)
        assert(agentTicks==0)
        assert(f.root.Size==home and f.root.Rotation==0 and f.root.PrestigeScale.Scale==1)
        assert(f.playerGui.VibeIdleBackdrop.PixelWallpaper.PrestigeScale.Scale==1 and f.playerGui.VibeIdleBackdrop.PrestigeVoid.ZIndex==0)
        assert(f.desk.parent.Visible and not f.root.ReturnCLI.Visible and f.terminal:canEdit() and not f.terminal.inputPaused)
        assert(f.gui.SelectedObject==f.terminal.input and f.server.chips==1 and f.server.prestigeCount==1)
        local paid=0;for _,r in ipairs(f.requests) do if r.action=="prestige" then paid=paid+1 end end;assert(paid==1)
        f:snapshot();assert(not effect.active)
    end)
    test("prestige animation waits for a matching success and read-only lost-reply recovery never repeats it",function()
        local f=fixture(1,{money=0,profile={lifetimeEarned=1000}});f:feature("Prestige")
        local p=f.progression;p.ascend.Activated:Fire();f.autoAck=false;p.ascend.Activated:Fire()
        assert(p.pending and not f.transition.active and f.server.prestigeCount==1)
        f.delayed=nil;f:tick(3.1);f:deliverReplies()
        assert(f.transition.active and not p.pending and f.transition.lastId==p.sequence)
        local age=f.transition.age;f:deliverReplies();assert(f.transition.age==age)
        f.autoAck=true;f:snapshot();assert(f.transition.age==age)
        local paid,syncs=0,0
        for _,r in ipairs(f.requests) do if r.action=="prestige" then paid=paid+1 elseif r.action=="prestige_sync" then syncs=syncs+1 end end
        assert(paid==1 and syncs==1)
        local dropped=fixture(1,{money=0,profile={lifetimeEarned=1000}});dropped:feature("Prestige")
        local page=dropped.progression;page.ascend.Activated:Fire();dropped.dropProgression=1;page.ascend.Activated:Fire();dropped:tick(3.1)
        assert(not dropped.transition.active and dropped.transition.lastId==0 and dropped.server.prestigeCount==0)
        local failed=fixture(1,{money=0,profile={lifetimeEarned=1000}});failed:feature("Prestige")
        failed.progression.ascend.Activated:Fire();failed.profile.lifetimeEarned=0;failed.progression.ascend.Activated:Fire()
        assert(not failed.transition.active and failed.server.prestigeCount==0 and not failed.server.progressionReply.ok)
        local loaded=fixture(1,{money=0,profile={lifetimeEarned=1000,prestigeCount=1,prestigeClaimed=1,chips=1}})
        assert(not loaded.transition.active);loaded:feature("SkillTree");loaded.progression.nodes.boot.buy.Activated:Fire()
        assert(not loaded.transition.active and loaded.transition.lastId==0)
    end)
    test("vortex pauses on menu focus chat and modifiers and resumes with bounded time and no agent catchup",function()
        local f=fixture(1,{money=0,agents=true,profile={lifetimeEarned=1000}});f:feature("Prestige")
        f.progression.ascend.Activated:Fire();f.progression.ascend.Activated:Fire();f:tick(.1)
        local effect=f.transition;local age,rotation,scale=effect.age,f.root.Rotation,f.root.PrestigeScale.Scale;local requests=#f.requests
        f.gui.MenuIsOpen=true;f:tick(10);f.gui.MenuIsOpen=false
        f.input.WindowFocusReleased:Fire();f:tick(10);f.input.WindowFocused:Fire()
        f.input.textBox={};f:tick(10);f.input.textBox=nil
        f.input.held[f.enum.KeyCode.LeftControl]=true;f:tick(10);f.input.held={}
        assert(effect.age==age and f.root.Rotation==rotation and f.root.PrestigeScale.Scale==scale and #f.requests==requests)
        f:tick(10);assert(math.abs(effect.age-age-.1)<.0001 and f.terminal.composer.count==0)
        while effect.active do f:tick(.1) end
        assert(f.terminal.composer.count==0 and #f.requests==requests)
        f:tick(.1);assert(f.terminal.composer.count==1 and #f.requests==requests+1)
    end)
    test("OS and Guide reduced motion use a static fade and switching preferences neutralizes an active vortex immediately",function()
        for _,source in ipairs({"OS","Guide"}) do
            local f=fixture(1,{money=0,profile={lifetimeEarned=1000}})
            if source=="OS" then f.gui.ReducedMotionEnabled=true
            else f:guide();f:button(f.root.Pages.GuidePage,"[ ] Reduced motion").Activated:Fire() end
            f:feature("Prestige");f.progression.ascend.Activated:Fire();f.progression.ascend.Activated:Fire()
            assert(f.transition.active and f.transition.reduced and f.root.Rotation==0 and f.root.PrestigeScale.Scale==1)
            for _,part in ipairs(f.transition.specks) do assert(not part.Visible) end
            for _=1,4 do f:tick(.1) end
            assert(not f.transition.active and f.desk.parent.Visible and not f.terminal.presentationPaused)
        end
        local f=fixture(1,{money=0,profile={lifetimeEarned=1000}});f:feature("Prestige")
        f.progression.ascend.Activated:Fire();f.progression.ascend.Activated:Fire();f:tick(.1)
        assert(f.root.Rotation>0);f.gui.ReducedMotionEnabled=true
        assert(f.root.Rotation==0 and f.root.PrestigeScale.Scale==1 and f.transition.covered)
        f.gui.ReducedMotionEnabled=false;assert(f.transition.reduced)
        for _=1,3 do f:tick(.1) end;assert(not f.transition.active)
    end)
    test("vortex resize disconnect and destruction always remove the overlay and restore owned transforms",function()
        for _,ticks in ipairs({3,14}) do
            local f=fixture(1,{money=0,profile={lifetimeEarned=1000}});f:feature("Prestige")
            f.progression.ascend.Activated:Fire();f.progression.ascend.Activated:Fire()
            for _=1,ticks do f:tick(.1) end
            local resized=f.udim2.fromOffset(360,640);f.root.Size=resized;f:tick(0)
            assert(not f.transition.active and not f.transition.blocker.Visible and f.root.Size==resized)
            assert(f.root.Rotation==0 and f.root.PrestigeScale.Scale==1 and f.desk.parent.Visible)
        end
        local f=fixture(1,{money=0,profile={lifetimeEarned=1000}});f:feature("Prestige")
        f.progression.ascend.Activated:Fire();f.progression.ascend.Activated:Fire();f:tick(.1)
        f.reportVersion="old-build";f:snapshot()
        assert(not f.transition.active and f.terminal.blocked and not f.terminal.presentationPaused and f.root.Rotation==0)
        local g=fixture(1,{money=0,profile={lifetimeEarned=1000}});g:feature("Prestige")
        g.progression.ascend.Activated:Fire();g.progression.ascend.Activated:Fire();g:tick(.1)
        local effect=g.transition;local requests=#g.requests;g.root.Parent:Destroy();g:tick(5)
        assert(effect.destroyed and not effect.active and not effect.blocker.Visible and #g.requests==requests)
        assert(g.root.Rotation==0 and not g.terminal.presentationPaused and not effect:start(99,false))
    end)
    test("prestige requires deliberate review and duplicate IDs or stale drafts never mint twice",function()
        local f=fixture(1,{money=0,profile={lifetimeEarned=27000,credits=200,computeLevel=3}})
        f:feature("Prestige");local p=f.progression
        p.ascend.Activated:Fire();f:main();assert(f.server.prestigeCount==0)
        f:feature("Prestige");p.ascend.Activated:Fire();assert(f.server.chips==0)
        p.ascend.Activated:Fire();assert(f.server.chips==3 and f.server.computeLevel==0 and f.server.credits==0)
        local request=f.requests[#f.requests];assert(request.action=="prestige")
        f.command:FireServer("prestige",request.payload);assert(f.server.chips==3 and f.server.prestigeCount==1)
        f.command:FireServer("prestige",{requestId=request.payload.requestId+1,draftId=request.payload.draftId})
        assert(f.server.chips==3 and not f.server.progressionReply.ok)
        f.command:FireServer("prestige",{requestId=request.payload.requestId+2,draftId=f.terminal.composer.draft.id})
        assert(f.server.chips==3 and f.server.prestigeCount==1 and not f.server.progressionReply.ok)
    end)
    test("skill tree branches cost Chips require every parent and grant permanent effects",function()
        local f=fixture(1,{money=0,profile={lifetimeEarned=shared.Balance.MAX_LIFETIME_EARNED}})
        f.input.GamepadEnabled=true
        f:feature("Prestige");local p=f.progression
        assert(f.gui.SelectedObject==p.ascend)
        p.ascend.Activated:Fire();p.ascend.Activated:Fire();assert(f.server.chips==shared.Balance.MAX_PRESTIGE_CHIPS)
        f:feature("SkillTree");assert(p.mode=="Tree")
        assert(f.gui.SelectedObject==p.nodes.boot.buy)
        local requests=#f.requests;p.nodes.core.buy.Activated:Fire();assert(#f.requests==requests)
        local spent=0;local value=f.server.moneyPerToken
        for _,node in ipairs(shared.Balance.PRESTIGE_NODES) do
            f:tick(.12)
            p.nodes[node.id].buy.Activated:Fire();spent=spent+node.cost
            assert(f.server.prestigeSkills[node.id] and f.server.chips==shared.Balance.MAX_PRESTIGE_CHIPS-spent,node.id..": "..tostring(f.server.message))
            assert(f.gui.SelectedObject~=p.nodes[node.id].buy)
            local count=#f.requests;p.nodes[node.id].buy.Activated:Fire();assert(#f.requests==count)
        end
        assert(f.server.computeLevel==0 and f.server.tokenLevel==0 and #f.server.layerSizes==3 and f.server.moneyPerToken>value)
        assert(p.nodes.core.buy.Text=="UNLOCKED" and #p.links>0 and f.server.chips==shared.Balance.MAX_PRESTIGE_CHIPS-spent)
    end)
    test("rarity branch buys update Guide chances but only new drafts get boosted server rolls",function()
        local f=fixture(9500,{profile={lifetimeEarned=shared.Balance.MAX_LIFETIME_EARNED,
            prestigeClaimed=1000,prestigeCount=1,chips=1000}})
        local p=f.progression
        local oldDraft=f.terminal.composer.draft
        assert(oldDraft.offers[1].rank==1)
        f:feature("SkillTree");f.input.GamepadEnabled=true
        local requests=#f.requests;p.nodes.luck2.buy.Activated:Fire();assert(#f.requests==requests)
        p.nodes.boot.buy.Activated:Fire()
        local before=f.server.moneyPerToken
        for index,id in ipairs({"luck","luck2","luck3","luck4"}) do
            f:tick(.12);p.nodes[id].buy.Activated:Fire()
            assert(f.server.prestigeSkills[id] and f.server.progression.rarityBoost==index+1)
            assert(f.server.moneyPerToken==before and f.terminal.composer.draft.offers[1].rank==1)
            assert(p.nodes[id].frame.Position.X.Offset+p.nodes[id].frame.Size.X.Offset<=p.body.CanvasSize.X.Offset)
            local chances=f.root.Pages.GuidePage.Instructions
            assert(chances.TokenChanceRare.Text==string.format("Rare / %g%% per token / x10",index+1))
            local paid=#f.requests;p.nodes[id].buy.Activated:Fire();assert(#f.requests==paid)
        end
        assert(f.server.chips==736)
        f:guide()
        local chances=f.root.Pages.GuidePage.Instructions
        assert(chances.TokenChanceCommon.Text=="Common / 84.45% per token / x1")
        assert(chances.TokenChanceEpic.Text=="Epic / 0.5% per token / x50")
        assert(chances.TokenChanceLegendary.Text=="Legendary / 0.05% per token / x250")
        assert(chances.RarityNote.Text:find("Current offers keep",1,true))
        f:main();f:compose("a");f:send()
        assert(f.server.lastPrompt.outputRarity=="Common")
        assert(f.terminal.composer.draft.id>oldDraft.id and f.terminal.composer.draft.offers[1].rank==3)
        f:finishCollection();f:compose("a");f:send()
        assert(f.server.lastPrompt.outputRarity=="Rare")
        assert(math.abs(f.server.lastPrompt.reward-before*10)<.001)
    end)
    test("lost rarity purchase reconciles once and duplicate nonce never spends Chips again",function()
        local f=fixture(9500,{profile={lifetimeEarned=64000,prestigeClaimed=4,
            prestigeCount=1,chips=3,prestigeSkills={boot=true}}})
        f:feature("SkillTree");f.autoAck=false
        f.progression.nodes.luck.buy.Activated:Fire()
        assert(f.progression.pending and f.profile.chips==0 and f.profile.prestigeSkills.luck)
        local request=f.requests[#f.requests]
        assert(request.action=="buy_skill" and request.payload.nodeId=="luck")
        f.delayed=nil;f:tick(3.1);f:deliverReplies()
        assert(not f.progression.pending and f.server.chips==0 and f.server.progression.rarityBoost==2)
        f.autoAck=true;f.command:FireServer("buy_skill",request.payload)
        assert(f.server.chips==0 and f.server.prestigeSkills.luck)
        assert(f.terminal.composer.draft.offers[1].rank==1)
        local payments=0
        for _,r in ipairs(f.requests) do if r.action=="buy_skill" then payments=payments+1 end end
        assert(payments==2) -- original and deliberate duplicate, no automatic paid retry
    end)
    test("radial tree has54 passive hex nodes and CORE recenters without a request or hidden input",function()
        local f=fixture(1,{profile={lifetimeEarned=1000,prestigeClaimed=1,prestigeCount=1,chips=1}})
        f.root.Size=f.udim2.fromOffset(360,640);f:feature("SkillTree")
        local p=f.progression;local count=0
        for id,node in pairs(p.nodes) do
            count=count+1;local expected=shared.Tree.position(id)
            assert(node.frame.Position.X.Offset==expected.x and node.frame.Position.Y.Offset==expected.y)
            assert(#node.borders==26 and #node.faces==25 and node.buy.Size.X.Offset==160)
            for _,part in ipairs(node.borders) do assert(not part.Active and not part.Selectable and part.Size.X.Offset>0) end
            for _,part in ipairs(node.faces) do assert(not part.Active and not part.Selectable and part.Size.Y.Offset>0) end
        end
        assert(count==54 and p.wallet.Text:find("0 of 54",1,true))
        local x,y=p.body.CanvasPosition.X,p.body.CanvasPosition.Y
        p:panTo(0,0);local requests=#f.requests
        p.centerButton.Activated:Fire(f:pointer(p.centerButton))
        assert(p.body.CanvasPosition.X==x and p.body.CanvasPosition.Y==y and #f.requests==requests)
        p:panTo(0,0);f.gui.MenuIsOpen=true;p.centerButton.Activated:Fire();f.gui.MenuIsOpen=false
        assert(p.body.CanvasPosition.X==0 and p.body.CanvasPosition.Y==0)
        f:main();p.centerButton.Activated:Fire();assert(not p.frame.Visible and #f.requests==requests)
        f.root.Parent:Destroy();p.centerButton.Activated:Fire();assert(p.destroyed and #f.requests==requests)
    end)
    test("new branch purchases debit current Chips once and increase actual money without legacy flags",function()
        local f=fixture(1,{money=0,profile={lifetimeEarned=27000000,prestigeClaimed=30,prestigeCount=1,chips=26,
            prestigeSkills={boot=true,tokens=true},legacyPrestigeSkills={}}})
        f:feature("SkillTree");local p=f.progression;local before=f.server.moneyPerToken
        assert(p.nodes.cash1.buy.Text=="5 Chips" and p.nodes.cash2.buy.Text=="LOCKED")
        p.nodes.cash1.buy.Activated:Fire();f:tick(.2);p.nodes.cash2.buy.Activated:Fire()
        assert(f.server.chips==6 and f.server.moneyPerToken>before and f.server.prestigeSkills.cash2)
        assert(not f.server.legacyPrestigeSkills.cash1 and not f.server.legacyPrestigeSkills.cash2)
        local request=f.requests[#f.requests]
        f:tick(.2);f.command:FireServer("buy_skill",request.payload)
        assert(f.server.chips==6 and shared.State.fromSnapshot(f.server,shared.Balance))
        f:reconnect();assert(f.server.chips==6 and f.server.prestigeSkills.cash2)
        local value=f.server.moneyPerToken
        f:main();f:compose("a");f:send();assert(f.server.lastPrompt.reward==value and f.server.credits==value)
    end)
    test("fully expanded server tree caps manual streak at100 with unchanged no-word skill checks",function()
        local skills={};for _,node in ipairs(shared.Balance.PRESTIGE_NODES) do skills[node.id]=true end
        local f=fixture(1,{money=0,profile={lifetimeEarned=shared.Balance.MAX_LIFETIME_EARNED,
            prestigeClaimed=20000,prestigeCount=1,chips=27,prestigeSkills=skills,legacyPrestigeSkills={}}})
        f.skill.autoSubmit=nil
        for _=1,105 do f:hit("Great") end
        assert(f.server.stats.streak==100 and f.server.progression.streakCap==100)
        assert(f.skill.capLabel.Text=="MAX STREAK 100 / AUTO")
        assert(f.terminal.composer.count==0 and #f.submits==0 and f.server.credits==0 and f.server.chips==27)
        f.root.Size=f.udim2.fromOffset(320,360);f:feature("SkillTree")
        local p=f.progression
        assert(p.wallet.Text:find("54 of 54",1,true))
        assert(p.wallet.TextWrapped and p.wallet.TextSize==14 and p.wallet.AbsoluteSize.Y==44)
        assert(p.centerButton.AbsolutePosition.X+p.centerButton.AbsoluteSize.X<=p.frame.AbsolutePosition.X+p.frame.AbsoluteSize.X)
        f:guide()
        assert(f.root.Pages.GuidePage.Instructions.TokenChanceRare.Text=="Rare / 10% per token / x10")
        assert(f.root.Pages.GuidePage.Instructions.TokenChanceLegendary.Text=="Legendary / 0.1% per token / x250")
    end)
    test("lost progression response reconciles read-only without repeating reset or Chip purchase",function()
        local f=fixture(1,{money=0,profile={lifetimeEarned=8000}})
        f:feature("Prestige");local p=f.progression
        p.ascend.Activated:Fire();f.autoAck=false;p.ascend.Activated:Fire()
        assert(p.pending and f.server.chips==2 and f.terminal.progressionPending)
        f.delayed=nil;f:tick(3.1);f:deliverReplies()
        assert(not p.pending and f.server.prestigeCount==1 and f.server.chips==2)
        f.autoAck=true;f:feature("SkillTree");f.autoAck=false
        p.nodes.boot.buy.Activated:Fire();assert(f.server.chips==1 and p.pending)
        f.delayed=nil;f:tick(3.1);f:deliverReplies()
        assert(not p.pending and f.server.chips==1 and f.server.prestigeSkills.boot)
        local paid=0;for _,request in ipairs(f.requests) do if request.action=="prestige" or request.action=="buy_skill" then paid=paid+1 end end
        assert(paid==2)
    end)
    test("dropped prestige request and bounded sync loss unlock only through a fresh explicit action",function()
        local f=fixture(1,{money=0,profile={lifetimeEarned=1000}})
        f:feature("Prestige");local p=f.progression
        f.dropProgression=1;p.ascend.Activated:Fire();p.ascend.Activated:Fire();assert(p.pending)
        f:tick(3.1);assert(not p.pending and f.server.chips==0)
        f.dropProgression=1;f.dropProgressionSync=3
        p.ascend.Activated:Fire();p.ascend.Activated:Fire()
        for _=1,5 do f:tick(3.1) end
        assert(p.pending and p.pending.syncs==3 and f.server.chips==0 and p.message.Text:find("Reconnect",1,true))
        f:reconnect();assert(not p.pending and f.server.chips==0)
        p.ascend.Activated:Fire();p.ascend.Activated:Fire();assert(f.server.chips==1)
    end)
    test("late pre-prestige snapshots cannot restore old balance upgrades draft or Chip balance",function()
        local f=fixture(1,{money=0,profile={lifetimeEarned=1000,credits=100,computeLevel=4}})
        local old=f.server
        f:feature("Prestige");local p=f.progression
        p.ascend.Activated:Fire();p.ascend.Activated:Fire()
        local draft=f.terminal.composer.draft.id
        f.command.Parent.StateUpdate.OnClientEvent:Fire(old)
        assert(f.root.MoneyHUD.Balance.Text=="$0.00" and f.root.MoneyHUD.Chips.Text=="1 Chips")
        assert(p.data.chips==1 and p.data.computeLevel==0 and f.terminal.composer.draft.id==draft)
    end)
    test("hidden clipped covered and busy progression callbacks cannot spend Chips or reset a run",function()
        local f=fixture(1,{money=0,profile={lifetimeEarned=1000}});local p=f.progression
        p.ascend.Activated:Fire();assert(not p.armed)
        f:feature("SkillTree");p.ascend.Activated:Fire();assert(not p.armed)
        f:feature("Prestige")
        local requests=#f.requests;f.terminal.agentPending={};p.ascend.Activated:Fire();assert(#f.requests==requests and not p.armed)
        f.terminal.agentPending=nil;f.gui.MenuIsOpen=true;p.ascend.Activated:Fire();f.gui.MenuIsOpen=false;assert(not p.armed)
        p.ascend.Activated:Fire();p.ascend.Activated:Fire();assert(f.server.chips==1)
        f:feature("SkillTree")
        p.body.CanvasPosition=f.vec2.new(0,500);requests=#f.requests
        p.nodes.boot.buy.Activated:Fire(f:pointer(p.nodes.boot.buy));assert(#f.requests==requests and f.server.chips==1)
        f:main();p.nodes.boot.buy.Activated:Fire();assert(f.server.chips==1)
    end)
    test("progression pages keep fixed mock tree geometry and the prestige icon reachable at small sizes",function()
        local f=fixture();local p=f.progression
        f:feature("SkillTree")
        for _,size in ipairs({{1280,720},{900,640},{360,640},{320,360}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2])
            local icon=f.root.FeatureDock.Prestige
            assert(icon.AbsoluteSize.X==64 and icon.FeatureIcon.AbsoluteSize.X==48)
            assert(icon.Position.X.Offset+64<=f.root.FeatureDock.CanvasSize.X.Offset)
            assert(p.frame.AbsolutePosition.Y>=52 and not f.root.FeatureDock.Visible)
            assert(p.frame.AbsolutePosition.Y+p.frame.AbsoluteSize.Y<=size[2]-8)
            assert(p.body.CanvasSize.X.Offset>=3000 and p.nodes.boot.frame.AbsoluteSize.X==240)
            assert(p.nodes.core.buy.AbsoluteSize.Y==32 and not p.links[1].frame.Active)
        end
        f.root.Parent:Destroy();assert(not p.pending)
    end)
    local function treePointer(f,touch)
        local body=f.progression.body;local p,s=body.AbsolutePosition,body.AbsoluteSize
        return {UserInputType=touch and f.enum.UserInputType.Touch or f.enum.UserInputType.MouseButton1,
            Position={X=p.X+math.min(80,s.X/2),Y=p.Y+math.min(80,s.Y/2)}}
    end
    local function treeMove(f,input,dx,dy)
        local position={X=input.Position.X+dx,Y=input.Position.Y+dy}
        if input.UserInputType==f.enum.UserInputType.Touch then input.Position=position;f.input.InputChanged:Fire(input)
        else f.input.InputChanged:Fire({UserInputType=f.enum.UserInputType.MouseMovement,Position=position}) end
    end
    test("skill tree mouse grab pans both axes and clamps to content without buying or writing",function()
        local f=fixture();f.root.Size=f.udim2.fromOffset(360,640);f:feature("SkillTree")
        local p=f.progression;p:panTo(0,0);local input=treePointer(f);local requests=#f.requests
        assert(p.body.ScrollBarThickness==0 and not p.body.ScrollingEnabled)
        f.input.InputBegan:Fire(input,true);assert(p.drag)
        treeMove(f,input,-90,-80)
        assert(p.body.CanvasPosition.X==90 and p.body.CanvasPosition.Y==80 and p.drag.moved)
        treeMove(f,input,-10000,-10000)
        assert(p.body.CanvasPosition.X==p.body.CanvasSize.X.Offset-p.body.AbsoluteWindowSize.X)
        assert(p.body.CanvasPosition.Y==p.body.CanvasSize.Y.Offset-p.body.AbsoluteWindowSize.Y)
        treeMove(f,input,10000,10000)
        assert(p.body.CanvasPosition.X==0 and p.body.CanvasPosition.Y==0)
        f.input.InputEnded:Fire(input,true)
        assert(not p.drag and #f.requests==requests and not p.pending and f.terminal.composer.count==0)
        for _,node in pairs(p.nodes) do
            assert(node.icon.AbsoluteSize.X==64 and #node.pixels>0 and node.buy.AbsoluteSize.Y==32)
            for _,child in ipairs(node.frame.children) do assert(child.ClassName~="UICorner" and child.ClassName~="UIStroke") end
        end
    end)
    test("dragging on an affordable skill suppresses release purchase but a new small click unlocks once",function()
        local f=fixture(1,{money=0,profile={chips=5,prestigeClaimed=5,prestigeCount=1,lifetimeEarned=125000}})
        f.root.Size=f.udim2.fromOffset(360,640);f:feature("SkillTree")
        local p=f.progression;p:centerTree()
        local buy=p.nodes.boot.buy;local input=f:pointer(buy);local requests=#f.requests
        f.input.InputBegan:Fire(input,true);assert(p.drag)
        treeMove(f,input,-30,-30);f.input.InputEnded:Fire(input,true)
        buy.Activated:Fire(f:pointer(buy))
        assert(#f.requests==requests and f.server.chips==5 and not f.server.prestigeSkills.boot)
        local click=f:pointer(buy);f.input.InputBegan:Fire(click,true)
        treeMove(f,click,2,1);f.input.InputEnded:Fire(click,true);buy.Activated:Fire(click)
        assert(f.server.chips==4 and f.server.prestigeSkills.boot and not p.pending)
        local paid=0;for _,request in ipairs(f.requests) do if request.action=="buy_skill" then paid=paid+1 end end
        assert(paid==1 and p.nodes.boot.art.label.Text=="UNLOCKED")
    end)
    test("tree grab rejects covered or paused starts and cancels on menu blur page exit and destruction",function()
        local f=fixture();f.root.Size=f.udim2.fromOffset(360,640);f:feature("SkillTree")
        local p=f.progression;p:panTo(0,0);local input=treePointer(f)
        f.input.InputBegan:Fire(f:pointer(f.root.ReturnCLI),true);assert(not p.drag)
        f.gui.MenuIsOpen=true;f.input.InputBegan:Fire(input,true);assert(not p.drag)
        f.gui.MenuIsOpen=false;f.input.textBox={};f.input.InputBegan:Fire(input,true);assert(not p.drag)
        f.input.textBox=nil;f.input.held[f.enum.KeyCode.LeftControl]=true
        f.input.InputBegan:Fire(input,true);assert(not p.drag);f.input.held={}
        f.input.InputBegan:Fire(input,true);assert(p.drag)
        f.gui.MenuIsOpen=true;treeMove(f,input,-50,-50);assert(not p.drag and p.body.CanvasPosition.X==0)
        f.gui.MenuIsOpen=false;f.input.InputBegan:Fire(input,true);assert(p.drag)
        f.input.WindowFocusReleased:Fire();assert(not p.drag)
        f.input.WindowFocused:Fire();f.input.InputBegan:Fire(input,true);assert(p.drag)
        f:main();assert(not p.drag)
        f:feature("SkillTree");f.input.InputBegan:Fire(treePointer(f),true);assert(p.drag)
        f.root.Parent:Destroy();assert(p.destroyed and not p.drag)
        for _,connection in ipairs(p.connections) do assert(not connection.Connected) end
        local requests=#f.requests;f.input.InputBegan:Fire(input,true);treeMove(f,input,-100,-100)
        assert(#f.requests==requests)
    end)
    test("touch tree grab ignores another finger and resize clamps without affecting prestige scrolling",function()
        local f=fixture();f.root.Size=f.udim2.fromOffset(360,640);f:feature("SkillTree")
        local p=f.progression
        assert(p.body.CanvasPosition.X>0) -- First opening reveals the root on a narrow viewport.
        p:panTo(0,0);local input=treePointer(f,true);local other=treePointer(f,true)
        f.input.InputBegan:Fire(input,true);f.input.InputBegan:Fire(other,true)
        treeMove(f,other,-40,-40);assert(p.drag.input==input and p.body.CanvasPosition.X==0)
        treeMove(f,input,-50,-60);assert(p.body.CanvasPosition.X==50 and p.body.CanvasPosition.Y==60)
        f.input.InputEnded:Fire(other,true);assert(p.drag)
        f.input.InputEnded:Fire(input,true);assert(not p.drag)
        f:main();f:feature("SkillTree")
        assert(p.body.CanvasPosition.X==50 and p.body.CanvasPosition.Y==60)
        p:panTo(50,80);f:feature("Prestige");f:feature("SkillTree")
        assert(p.body.CanvasPosition.X==50 and p.body.CanvasPosition.Y==80)
        f.root.Size=f.udim2.fromOffset(1920,1080)
        assert(p.body.CanvasPosition.X<=math.max(0,p.treeLayer.Size.X.Offset-p.body.AbsoluteWindowSize.X) and p.body.CanvasPosition.Y<=math.max(0,p.treeLayer.Size.Y.Offset-p.body.AbsoluteWindowSize.Y))
        f:feature("Prestige")
        assert(p.mode=="Prestige" and p.body.ScrollingEnabled and p.body.ScrollBarThickness==5 and not p.treeLayer.Visible)
        f.input.InputBegan:Fire(treePointer(f),true);assert(not p.drag)
    end)
    test("Studio money grants malformed payloads and idle frames cannot mint prestige Chips",function()
        local f=fixture(1,{money=0,studio=true})
        f.command.Parent.StudioCommand:FireServer("grant")
        assert(f.server.credits==1000000000 and f.server.lifetimeEarned==0 and f.server.prestige.available==0)
        f.command:FireServer("prestige",{requestId=1,draftId=f.terminal.composer.draft.id,chips=999})
        f.command:FireServer("buy_skill",{requestId=2,nodeId="boot",cost=0})
        f:tick(5);f:snapshot()
        assert(f.server.chips==0 and f.server.prestigeClaimed==0 and not f.server.prestigeSkills.boot and f.server.lifetimeEarned==0)
        f.command:FireServer("prestige",{requestId=3,draftId=f.terminal.composer.draft.id})
        assert(not f.server.progressionReply.ok and f.server.chips==0)
    end)
    test("prestige discards old agent grants and paid drafts and starts fresh clocks without catchup",function()
        local f=fixture(1,{money=0,agents=true,profile={lifetimeEarned=1000}})
        local old=f.terminal.composer.draft.id
        f:feature("Prestige");local p=f.progression
        p.ascend.Activated:Fire();p.ascend.Activated:Fire()
        f.command:FireServer("agent_type",{requestId=1,draftId=old,tokenIndex=1})
        f.command:FireServer("submit_prompt",{draftId=old,tokens=8})
        assert(f.server.chips==1 and f.server.credits==0 and f.server.lifetimeEarned==1000 and f.terminal.composer.count==0)
        f:main();f:tick(0.2);assert(f.terminal.composer.count==0)
        f:tick(0.9);assert(f.terminal.composer.count==1 and f.server.lastAgent.wordCount==1)
        assert(f.server.credits==0 and f.server.lifetimeEarned==1000)
        f:send();assert(f.server.credits==1.16 and f.server.chips==1 and f.server.lifetimeEarned==1001.16)
    end)
    test("Cards opens eight ordered slots with locked artwork and a nine-card starter inventory",function()
        local f=fixture(1,{money=0});f.input.GamepadEnabled=true
        f:feature("Cards");local p=f.cardPage
        assert(f.gui.SelectedObject==p.inventory.ember.frame)
        assert(p.frame.Visible and not f.desk.parent.Visible and not f.root.StorePanel.Visible and #p.slots==8)
        assert(p.inventoryTitle.Text=="INVENTORY / 9" and f.terminal.suspended)
        local requests=#f.requests
        p.slots[1].frame.Activated:Fire();p.slots[2].frame.Activated:Fire();assert(#f.requests==requests)
        for index,slot in ipairs(p.slots) do
            assert(slot.frame.Position.X.Offset==p.slots[1].frame.Position.X.Offset+(index-1)*208 and slot.frame.Position.Y.Offset==4)
            assert(slot.frame:GetAttribute("Locked")== (index>1) and slot.lock.Visible==(index>1))
            assert(slot.plus.Visible==(index==1))
            assert(not slot.preview.frame.Visible and slot.status.Text==(index==1 and "EMPTY" or "LOCKED"))
            for _,part in ipairs(slot.lock.children) do assert(not part.Active and not part.Selectable) end
        end
        for _,card in ipairs(shared.Balance.AGENT_CARDS) do
            assert(p.inventory[card.id].frame.Visible==(card.rank==1) and p.inventory[card.id].preview.id==card.id and f.mascotCatalog[card.id])
        end
        p.inventory.sage.frame.Activated:Fire();assert(p.selectedCard=="sage" and #f.requests==requests)
        assert(f.gui.SelectedObject==p.slots[1].frame)
        p.slots[1].frame.Activated:Fire()
        assert(f.server.cardDeck[1]=="sage" and f.desk.agents[1].mascot.id=="sage" and not p.inventory.sage.frame.Visible)
        assert(p.slots[1].preview.id=="sage" and p.slots[1].status.Text=="EQUIPPED" and f.server.credits==0 and f.server.chips==0)
    end)
    test("agent purchases unlock only the next deck positions and each card occupies at most one slot",function()
        local f=fixture(1,{money=1000000000});f:feature("Cards");local p=f.cardPage
        p.inventory.ember.frame.Activated:Fire();p.slots[1].frame.Activated:Fire()
        local requests=#f.requests;p.inventory.ember.frame.Activated:Fire();assert(#f.requests==requests)
        f:buyAgent();f:feature("Cards");assert(not p.slots[2].lock.Visible and p.slots[3].lock.Visible and not f.server.cardDeck[2])
        p.inventory.volt.frame.Activated:Fire();requests=#f.requests
        p.slots[8].frame.Activated:Fire();assert(#f.requests==requests and p.selectedCard=="volt")
        p.slots[2].frame.Activated:Fire()
        assert(f.server.cardDeck[1]=="ember" and f.server.cardDeck[2]=="volt" and f.desk.agents[2].mascot.id=="volt")
        f.command:FireServer("equip_card",{requestId=f.server.progressionSequence+1,slotIndex=2,cardId="ember"})
        assert(not f.server.progressionReply.ok and f.server.cardDeck[2]=="volt")
        for count=3,8 do f:buyAgent();f:feature("Cards");assert(not p.slots[count].lock.Visible) end
        assert(#f.desk.windows==1 and p.deckTitle.Text=="DECK / 8 OF 8")
    end)
    test("removing a card returns its only copy and restores a prior cosmetic without losing the mascot object",function()
        local f=fixture();assert(f.desk:setAgentMascot(1,"frost"));local mascot=f.terminal.mascot
        f:feature("Cards");local p=f.cardPage
        p.inventory.sage.frame.Activated:Fire();p.slots[1].frame.Activated:Fire();assert(mascot.id=="sage")
        f:feature("Laboratory")
        assert(not f.desk:setAgentMascot(1,"volt") and f.lab.frame.Visible)
        f:feature("Cards");p.slots[1].frame.Activated:Fire();assert(p.remove.Active)
        p.remove.Activated:Fire()
        assert(not f.server.cardDeck[1] and p.inventory.sage.frame.Visible and p.inventoryTitle.Text=="INVENTORY / 9")
        assert(f.terminal.mascot==mascot and mascot.id=="frost" and not p.remove.Active and not p.slots[1].preview.frame.Visible)
        local requests=#f.requests;p.remove.Activated:Fire();assert(#f.requests==requests)
    end)
    test("automatic card value is fixed on the word before removal and only manual SELL pays it",function()
        local f=fixture(1,{money=0,agents=true});f:feature("Cards");local p=f.cardPage
        p.inventory.sage.frame.Activated:Fire();p.slots[1].frame.Activated:Fire();f:main();f:tick(1.3)
        assert(f.terminal.composer.count==1 and f.server.skillCheck.awards[1].multiplier==1.25 and f.server.credits==0)
        f:feature("Cards");p.slots[1].frame.Activated:Fire();p.remove.Activated:Fire()
        assert(f.server.skillCheck.awards[1].multiplier==1.25 and f.server.cardDeck[1]==false)
        f:main();f:tick(1)
        assert(f.terminal.composer.count==2 and f.server.skillCheck.awards[2].multiplier==1 and f.server.credits==0)
        f:send();assert(f.server.credits==2.25 and f.server.lifetimeEarned==2.25 and f.server.chips==0)
    end)
    test("Volt changes real agent cadence and per-agent caps while leaving the skill dial alone",function()
        local f=fixture(1,{money=0,agents=true});local duration=f.skill.check.duration
        f:feature("Cards");local p=f.cardPage
        p.inventory.volt.frame.Activated:Fire();p.slots[1].frame.Activated:Fire();f:main()
        assert(math.abs(f.server.agentTypingCaps[1]-4.8)<0.00001 and math.abs(f.terminal.totalSpeed-4.8)<0.00001)
        assert(math.abs(f.server.totalAgentWordsPerSecond-1.2)<0.00001 and f.skill.check.duration==duration)
        f:tick(0.9);assert(f.terminal.composer.count==1 and f.server.credits==0)
        local plain=fixture(1,{money=0,agents=true});plain:tick(0.9);assert(plain.terminal.composer.count==0)
    end)
    test("lost equipment replies use read-only progression sync and cannot equip or remove twice",function()
        local f=fixture(1,{money=0});f.input.GamepadEnabled=true
        f:feature("Cards");local p=f.cardPage
        p.inventory.ember.frame.Activated:Fire();f.autoAck=false;p.slots[1].frame.Activated:Fire()
        assert(p.pending and f.progression.pending and f.terminal.progressionPending and f.server.cardDeck[1]=="ember")
        local requests=#f.requests;for _=1,10 do p.slots[1].frame.Activated:Fire() end;assert(#f.requests==requests)
        f.delayed=nil;f.gui.SelectedObject=p.inventory.ember.frame;f:tick(3.1);f:deliverReplies()
        assert(not p.pending and not f.progression.pending and p.slots[1].preview.id=="ember" and not p.inventory.ember.frame.Visible)
        assert(f.gui.SelectedObject==p.slots[1].frame and f.gui.SelectedObject.Selectable)
        p.slots[1].frame.Activated:Fire();p.remove.Activated:Fire();f.delayed=nil
        f:tick(3.1);f:deliverReplies();assert(f.server.cardDeck[1]==false and p.inventory.ember.frame.Visible)
        local changes=0;for _,request in ipairs(f.requests) do if request.action=="equip_card" or request.action=="unequip_card" then changes=changes+1 end end
        assert(changes==2 and f.server.credits==0 and f.server.chips==0)
    end)
    test("dropped card requests and bounded sync loss do not auto retry an equipment change",function()
        local f=fixture();f:feature("Cards");local p=f.cardPage
        p.inventory.ember.frame.Activated:Fire();f.dropProgression=1;f.dropProgressionSync=3
        p.slots[1].frame.Activated:Fire()
        for _=1,5 do f:tick(3.1) end
        assert(p.pending and not f.server.cardDeck[1] and f.progression.pending.syncs==3)
        assert(p.message.Text:find("Reconnect",1,true))
        f:reconnect();assert(not p.pending and not f.server.cardDeck[1])
        p.inventory.ember.frame.Activated:Fire()
        p.slots[1].frame.Activated:Fire();assert(f.server.cardDeck[1]=="ember")
        local changes=0;for _,request in ipairs(f.requests) do if request.action=="equip_card" then changes=changes+1 end end
        assert(changes==2)
    end)
    test("prestige keeps cards but relocks higher deck positions and returns their cards to inventory",function()
        local f=fixture(1,{money=0,agents=true,profile={lifetimeEarned=1000,layerSizes={4,2,2,2,1},cardDeck={"volt","frost","sage",false,false,false,false,false}}})
        f:feature("Prestige");f.progression.ascend.Activated:Fire();f.progression.ascend.Activated:Fire()
        assert(f.server.cardDeck[1]=="volt" and not f.server.cardDeck[2] and not f.server.cardDeck[3] and f.server.chips==1)
        f:feature("Cards");local p=f.cardPage
        assert(not p.inventory.volt.frame.Visible and p.inventory.frost.frame.Visible and p.inventory.sage.frame.Visible)
        assert(not p.slots[1].lock.Visible and p.slots[2].lock.Visible and f.desk.agents[1].mascot.id=="volt")
        f:main();f:tick(0.9);assert(f.terminal.composer.count==1 and f.server.credits==0)
    end)
    test("card mutations reject forged stats duplicate cards and old snapshots without restoring inventory copies",function()
        local f=fixture();local old=f.server;local draft=f.terminal.composer.draft.id
        f.command:FireServer("equip_card",{requestId=1,slotIndex=1,cardId="sage",value=100})
        f:snapshot();assert(not f.server.cardDeck[1] and f.server.progressionSequence==0)
        f:feature("Cards");local p=f.cardPage
        p.inventory.sage.frame.Activated:Fire();p.slots[1].frame.Activated:Fire()
        local request=f.requests[#f.requests];f.command:FireServer(request.action,request.payload)
        assert(f.server.cardDeck[1]=="sage" and f.terminal.composer.draft.id==draft)
        f.command.Parent.StateUpdate.OnClientEvent:Fire(old)
        assert(p.data.cardDeck[1]=="sage" and not p.inventory.sage.frame.Visible and f.desk.agents[1].mascot.id=="sage")
        f:buyAgent();f.command:FireServer("equip_card",{requestId=f.server.progressionSequence+1,slotIndex=2,cardId="sage"})
        assert(not f.server.progressionReply.ok and not f.server.cardDeck[2])
    end)
    test("card layout preserves all eight slots and miniature inventory with clipping and hidden-page guards",function()
        local f=fixture();local p=f.cardPage;p.inventory.volt.frame.Activated:Fire();assert(not p.selectedCard)
        f:feature("Cards");local requests=#f.requests
        for _,size in ipairs({{1280,720},{900,640},{360,640},{320,360}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2])
            assert(p.frame.AbsolutePosition.Y+p.frame.AbsoluteSize.Y<=size[2]-8 and p.deck.CanvasSize.X.Offset>=1152)
            assert(p.inventory.volt.frame.Position.Y.Offset>=588 and p.slots[8].frame.Position.X.Offset>p.slots[1].frame.Position.X.Offset)
            assert(p.slots[8].frame.AbsoluteSize.X==192 and p.inventory.volt.frame.AbsoluteSize.X==192)
        end
        p.body.CanvasPosition=f.vec2.new(0,0)
        p.inventory.volt.frame.Activated:Fire(f:pointer(p.inventory.volt.frame));assert(not p.selectedCard)
        p.deck.CanvasPosition=f.vec2.new(0,0)
        p.slots[8].frame.Activated:Fire(f:pointer(p.slots[8].frame));assert(#f.requests==requests)
        f.gui.MenuIsOpen=true;p.inventory.volt.frame.Activated:Fire();f.gui.MenuIsOpen=false;assert(not p.selectedCard)
        f.input.held[f.enum.KeyCode.LeftControl]=true;p.inventory.volt.frame.Activated:Fire();f.input.held={};assert(not p.selectedCard)
        p.inventory.volt.frame.Activated:Fire();assert(p.selectedCard=="volt" and p.body.CanvasPosition.Y==128)
        f:main();p.inventory.volt.frame.Activated:Fire();assert(not p.selectedCard)
        f.root.Parent:Destroy();assert(p.destroyed and p.inventory.volt.preview.destroyed and p.slots[1].preview.destroyed)
    end)
    test("native CLI Enter reaches real GameService pays money and has no token toolbar or resources bar",function()
        local f=fixture(1,{money=0})
        assert(not f.terminal.blocked and f.server.credits==0)
        assert(f.terminal.input.ClassName=="TextBox" and not f.root:FindFirstChild("Resources"))
        for _,name in ipairs({"AddToken","Undo","Clear"}) do assert(not f.terminal.panel:FindFirstChild(name)) end
        assert(f.terminal.panel:FindFirstChild("SendPrompt")==f.terminal.send)
        f:compose("a");assert(f.terminal.composer.count==1 and #f.submits==0)
        f:send();assert(#f.submits==1 and f.server.credits==1 and f.server.stats.prompts==1)
        assert(f.terminal.composer.count==0 and #f.terminal.cash.items==1)
        assert(f.root.MoneyHUD.Balance.Text=="$1.00")
    end)
    test("manual word queue appends immediately and Enter submits once without typing limits",function()
        local f=fixture(1,{money=0});f:compose("abcd")
        assert(f.terminal.composer.count==4 and f.terminal.pendingKeys==nil)
        f:send();assert(#f.submits==1 and not f.terminal.sendRequested)
        for _=1,16 do f:tick(0.05) end
        assert(#f.submits==1 and f.submits[1].tokens==4 and f.server.credits==4)
        f:tick(2);assert(#f.submits==1 and f.terminal.composer.count==0)
    end)
    test("processed focused Enter and mobile Return cannot double dispatch or block own TextBox",function()
        local f=fixture(1,{money=0});f:compose("a")
        f:press("Return",true);assert(f.terminal.sendRequested and #f.submits==0)
        f.terminal.input:ReleaseFocus(true)
        f.terminal.input.ReturnPressedFromOnScreenKeyboard:Fire();f:finishSellWriting()
        assert(#f.submits==1 and f.server.credits==1)
        f:tick(0.4);f:compose("b");f.terminal.input.ReturnPressedFromOnScreenKeyboard:Fire()
        f.terminal.input:ReleaseFocus(true);f:finishSellWriting()
        assert(#f.submits==2 and f.server.credits==2)
    end)
    test("rare words render as independent colored objects with matching server multipliers",function()
        local f=fixture(9890,{money=0});f:compose("abc")
        for _=1,12 do f:tick(0.05) end
        assert(f.terminal.tokens[1].Visible and f.terminal.tokens[2].Visible and f.terminal.tokens[3].Visible)
        local piece=f.terminal.tokens[1]
        assert(piece~=f.terminal.tokens[2] and piece.ClassName=="Frame" and piece.Word.Text=="build")
        assert(piece.Word.TextColor3[3]==255 and piece.Multiplier.Text=="x10" and piece.Multiplier.Visible)
        assert(piece.BackgroundTransparency==0.85 and piece.PanelBorder.Color==piece.Word.TextColor3)
        assert(piece:GetAttribute("Rarity")=="Rare" and piece:GetAttribute("Multiplier")==10)
        f:send();assert(f.server.credits==30 and f.server.stats.special==3 and f.server.stats.tiers[3]==3)
    end)
    test("three live Store upgrades preserve scroll and historical bonuses apply to future agents",function()
        local f=fixture(1,{money=1000000000});f:shop();local list=f.root.StorePanel.UpgradeList
        list.CanvasPosition=f.vec2.new(0,150)
        f:restoreLegacyUpgrade("upgrade_workers")
        for count=2,8 do
            f:buyAgent();assert(f.desk.count==count and f.root.StorePanel.Visible)
            assert(list.CanvasPosition.Y==150 and f.server.layerSizes[count+1]==3)
        end
        f:restoreLegacyUpgrade("upgrade_typing");f:buyUpgrade("upgrade_compute");f:buyUpgrade("upgrade_tokens")
        assert(f.server.typingLevel==1 and f.terminal.speed==6 and f.server.computeLevel==1 and f.terminal.limit==16)
        for _,request in ipairs(f.requests) do if request.action=="add_layer" or request.action=="upgrade_compute" or request.action=="upgrade_tokens" then assert(request.payload.quantity==1 and request.payload.requestId>=1) end end
    end)
    test("Store exposes exactly three upgrades and token value pays the confirmed base on the same draft",function()
        local f=fixture();f:compose("a");local draft=f.terminal.composer.draft
        f:shop();local list=f.root.StorePanel.UpgradeList
        local names={upgrade_compute="TOKEN VALUE",add_layer="AGENT COUNT",upgrade_tokens="CONTEXT"}
        local count=0
        for _,card in ipairs(list.children) do
            if card:FindFirstChild("BuyUpgrade") then
                count=count+1;assert(card.UpgradeName.Text==names[card.Name])
            end
        end
        assert(count==3)
        list.CanvasPosition=f.vec2.new(0,80)
        local money=f.server.credits;local price=shared.Rules.quote(f.server,"upgrade_compute",nil,shared.Balance)
        f:buyUpgrade("upgrade_compute")
        assert(f.server.credits==money-price and f.server.moneyPerToken==1.35)
        assert(f.terminal.composer.draft.id==draft.id and f.terminal.composer.count==1)
        assert(string.find(list.upgrade_compute.UpgradeStatus.Text,"$1.35",1,true) and string.find(list.upgrade_compute.UpgradeStatus.Text,"$1.70",1,true))
        f:buyUpgrade("upgrade_tokens");assert(f.server.tokenLimit==16)
        assert(f.terminal.composer.draft.id==draft.id and f.terminal.composer.count==1)
        assert(list.CanvasPosition.Y==80 and f.root.StorePanel.Visible)
        money=f.server.credits;f:main();f:send()
        assert(math.abs(f.server.credits-money-1.35)<0.000001)
        f:snapshot();assert(math.abs(f.server.credits-money-1.35)<0.000001)
    end)
    test("retired upgrade commands reject at the real server boundary without charging or granting",function()
        local f=fixture();f:shop()
        for _,action in ipairs({"upgrade_workers","upgrade_typing","upgrade_click","upgrade_divisor"}) do
            assert(not f.root.StorePanel.UpgradeList:FindFirstChild(action))
            local before=shared.State.copy(f.server);local draft=f.terminal.composer.draft.id
            for _,payload in ipairs({false,{level=3,price=0}}) do
                f:tick(0.31);f.command:FireServer(action,payload or nil)
                f:snapshot()
                assert(f.server.credits==before.credits and f.server.computeLevel==before.computeLevel)
                assert(f.server.typingLevel==before.typingLevel and f.server.clickLevel==before.clickLevel)
                assert(f.server.divisorLevel==before.divisorLevel)
                assert(table.concat(f.server.layerSizes,",")==table.concat(before.layerSizes,","))
                assert(f.terminal.composer.draft.id==draft and #f.submits==0)
            end
        end
    end)
    test("agent and context caps reject further purchases while token value continues",function()
        local f=fixture(1,{money=1000000000});f:shop()
        local limits={add_layer=shared.Balance.MAX_HIDDEN_LAYERS-1,upgrade_tokens=shared.Balance.MAX_TOKEN_LEVEL}
        for action,limit in pairs(limits) do
            for _=1,limit do f:buyUpgrade(action) end
            local card=f.root.StorePanel.UpgradeList[action]
            assert(card.BuyUpgrade.Text=="MAX" and card.UpgradePrice.Text=="MAXED" and not card.BuyUpgrade.Active)
            local money=f.server.credits
            f:tick(0.31);f.command:FireServer(action)
            assert(f.server.credits==money and f.root.StorePanel.Visible)
        end
        assert(f.desk.count==8 and f.server.tokenLimit==64 and f.server.computeLevel==0)
    end)
    test("all 64 tokens grow the main CLI vertically at fixed width without an inner scroller",function()
        for _,roll in ipairs({1,10000}) do
            local f=fixture(roll);f:shop()
            for _=1,15 do f:buyUpgrade("upgrade_tokens") end
            f:main();local first=f.terminal.tokens[1];local last=f.terminal.tokens[64]
            local initialWidth,initialHeight=f.terminal.frame.AbsoluteSize.X,f.terminal.frame.AbsoluteSize.Y
            f.autoAck=false;f:compose(string.rep("a",64));assert(#f.submits==0);f:send()
            assert(f.terminal.composer.count==64 and #f.submits==1)
            assert(f.terminal.frame.AbsoluteSize.X==initialWidth and f.terminal.frame.AbsoluteSize.Y>=initialHeight)
            for _,viewport in ipairs({{1280,720},{1920,1080},{360,640},{640,360},{1280,720}}) do
                f.root.Size=f.udim2.fromOffset(viewport[1],viewport[2])
                local terminal=f.terminal
                local spec=shared.Agent.workstationLayout(viewport[1],viewport[2],f.desk.count)
                assert(terminal.frame.AbsoluteSize.X==spec.windows[1].width)
                assert(terminal.preview.ClassName=="Frame" and terminal.preview.AbsoluteSize.Y>=28)
                assert(terminal.tokens[1]==first and terminal.tokens[64]==last)
                for index,piece in ipairs(terminal.tokens) do
                    assert(piece.Visible and terminal.tokenWords[index].TextSize==shared.Composer.TOKEN_STYLE.wordSize)
                    assert(piece.Position.X.Offset>=0 and piece.Position.X.Offset+piece.Size.X.Offset<=terminal.preview.AbsoluteSize.X)
                    assert(piece.Position.Y.Offset>=0 and piece.Position.Y.Offset+shared.Composer.TOKEN_STYLE.rowHeight<=terminal.preview.AbsoluteSize.Y)
                end
                assert(terminal.panel.AbsolutePosition.Y>=terminal.bar.AbsolutePosition.Y+40)
                assert(terminal.send.AbsolutePosition.Y+40<=terminal.frame.AbsolutePosition.Y+terminal.frame.AbsoluteSize.Y)
                if terminal.frame.AbsoluteSize.Y>viewport[2]-terminal.bottomClearance then
                    local desktop=terminal.frame.Parent
                    assert(desktop.ScrollingEnabled and desktop.CanvasSize.Y.Offset>=terminal.frame.AbsoluteSize.Y+terminal.bottomClearance)
                end
            end
            local size=f.terminal.frame.AbsoluteSize
            f:ack();assert(f.terminal.composer.count==0 and #f.submits==1)
            assert(f.terminal.frame.AbsoluteSize.X==size.X and f.terminal.frame.AbsoluteSize.Y==size.Y)
        end
    end)
    test("overflow scroll reaches the whole CLI while dock skill and covered pointer guards remain independent",function()
        local f=fixture(10000);f:guide();f:buyAgent()
        for _=1,15 do f:buyUpgrade("upgrade_tokens") end
        f:main();f.root.Size=f.udim2.fromOffset(360,640)
        f.autoAck=false;f:compose(string.rep("a",63))
        local desktop=f.terminal.frame.Parent
        assert(desktop.ScrollingEnabled and f.terminal.composer.count==63 and #f.submits==0)
        desktop.CanvasPosition=f.vec2.new(desktop.CanvasSize.X.Offset-desktop.AbsoluteSize.X,desktop.CanvasSize.Y.Offset-desktop.AbsoluteSize.Y)
        local button=f.terminal.send
        assert(button.AbsolutePosition.Y+40<=f.root.AbsoluteSize.Y-f.terminal.bottomClearance)
        assert(f.root.DesktopDock.AbsolutePosition.Y==f.root.AbsoluteSize.Y-44)
        assert(f.skill.layer.Parent.Parent.DisplayOrder==22)
        local pointer=f:pointer(button)
        assert(f.desk:ownsPointer(1,pointer))
        f:guide();assert(not desktop.Visible and f.terminal.composer.count==63)
        f:main();assert(f.terminal.composer.count==63)
        button.Activated:Fire();assert(#f.submits==1 and f.submits[1].tokens==63)
        f:ack();assert(f.terminal.composer.count==0 and f.terminal.tokens[64].Visible==false)
    end)
    test("agent upgrades never pace manual composition or change rarity and payout base",function()
        local function countAt(level)
            local f=fixture(9890);f:shop()
            for _=1,level do f:restoreLegacyUpgrade("upgrade_typing") end
            f:main();f:compose("abcdefg")
            for _=1,10 do f:tick(0.05) end
            assert(f.terminal.composer.draft.offers[1].multiplier==10 and f.terminal.base==1)
            return f.terminal.composer.count
        end
        assert(countAt(2)==7 and countAt(0)==7)
    end)
    test("full context waits for Enter and partial prompts support Backspace and SELL",function()
        local f=fixture(1,{money=0});f:compose(string.rep("a",30))
        for _=1,50 do f:tick(0.05) end
        assert(f.terminal.composer.count==8 and f.terminal.pendingKeys==nil and #f.submits==0 and f.server.credits==0)
        f:send();assert(#f.submits==1 and f.server.credits==8)
        f:finishCollection()
        f:compose("abc");f:tick(0.6);f:press("Backspace",true)
        assert(f.terminal.composer.count==2)
        f:send();assert(f.server.credits==10 and f.submits[2].tokens==2)
    end)
    test("full tokens remain unsold across ticks snapshots reconnect pages and resumed focus",function()
        local f=fixture(1,{money=0});f:compose("abcdefgh")
        local draft=f.terminal.composer.draft.id
        assert(f.terminal.composer.count==8 and f.terminal.send.Text=="SELL" and f.terminal.send.Active)
        f.terminal:dispatch();assert(#f.submits==0)
        for _=1,20 do f:tick(0.25);f:snapshot() end
        f:shop();f:reconnect()
        f:button(f.root.DesktopDock,"Guide").Activated:Fire();f:tick(2);f:main()
        f.input.WindowFocusReleased:Fire();f:tick(2);f.input.WindowFocused:Fire();f:tick(0.1)
        assert(f.server.credits==0 and #f.submits==0 and not f.terminal.sendRequested)
        assert(f.terminal.composer.count==8 and f.terminal.composer.draft.id==draft)
        assert(f.terminal.stateLabel.Text=="FULL / SELL")
        f.terminal.send.Activated:Fire();f:key("Return")
        assert(#f.submits==1 and f.server.credits==8 and f.terminal.composer.count==0)
    end)
    test("late skill acknowledgement off-page preserves existing tokens and waits for explicit sale",function()
        local f=fixture(1,{money=0})
        f:compose("abcdefg")
        f.autoAck=false;f:hit("Normal");f:send()
        assert(f.terminal.skillPending and #f.submits==0 and f.terminal.sendRequested)
        f:guide();f:ack();f:tick(2);f:snapshot()
        assert(f.terminal.composer.count==7 and f.server.credits==0 and #f.submits==0)
        f.terminal.send.Activated:Fire();assert(#f.submits==0)
        f:main();f:tick(2);assert(#f.submits==0)
        f:send();assert(#f.submits==1 and f.server.credits==7)
    end)
    test("SELL uses passive native stepped pixels and retains the same button across receipts",function()
        local f=fixture(1,{money=0});local button=f.terminal.send
        assert(button.Text=="SELL" and button.AbsoluteSize.X==96 and button.AbsoluteSize.Y==40)
        assert(button.FontFace.Family=="PressStart2P" and button.TextTransparency==1 and not button.AutoButtonColor)
        local face,shadow=0,0
        for _,part in ipairs(button.children) do
            assert(part.ClassName~="UICorner" and part.ClassName~="UIStroke")
            if part.Name=="PixelFace" then face=face+1 end
            if part.Name=="PixelShadow" then shadow=shadow+1 end
            assert(not part.Active and not part.Selectable)
        end
        assert(face==3 and shadow==3 and button.PixelLabel.Text=="SELL")
        f:compose("a");f.autoAck=false;button.Activated:Fire()
        assert(button.Active and button.Text=="SELL" and button.PixelLabel.Text=="SELL")
        f:finishSellWriting();f:ack();f:snapshot();assert(f.terminal.send==button and #f.submits==1 and f.server.credits==1)
    end)
    test("SELL press animates only its pixel face and respects reduced motion and one sale",function()
        local f=fixture(1,{money=0});local terminal=f.terminal;local button=terminal.send
        local position,size=button.Position,button.Size
        local labelY=terminal.sellArt.label.Position.Y.Offset
        button.Activated:Fire()
        assert(terminal.sellArt.label.Position.Y.Offset==labelY+3 and #f.submits==0)
        f:tick(0.06);assert(terminal.sellArt.label.Position.Y.Offset==labelY-2)
        f:tick(0.09);f:tick(0.1)
        assert(terminal.sellPressAge==nil and terminal.sellArt.label.Position.Y.Offset==labelY)
        assert(button.Position==position and button.Size==size)
        f:compose("abc");f.autoAck=false;button.Activated:Fire();f:finishSellWriting()
        for _=1,5 do button.Activated:Fire() end
        assert(#f.submits==1 and button.Active)
        f:ack();f:guide();assert(terminal.sellPressAge==nil and terminal.sellArt.label.Position.Y.Offset==labelY)
        f:main();terminal:setReducedMotion(true);button.Activated:Fire()
        assert(terminal.sellPressAge==nil and terminal.sellArt.label.Position.Y.Offset==labelY and #f.submits==1)
    end)
    test("agents wait through delayed confirmation and paused collection then resume once without a queued resale",function()
        local f=fixture(1,{agents=true,money=0});local terminal=f.terminal
        local callback=terminal.onAgent;terminal.onAgent=nil
        f:compose("abcdefgh");f.autoAck=false;f:send();terminal.onAgent=callback
        assert(terminal.saleFlight and #f.submits==1)
        local function agentRequests()
            local n=0;for _,r in ipairs(f.requests) do if r.action=="agent_type" then n=n+1 end end;return n
        end
        local before=agentRequests();f:tick(6)
        assert(not terminal.composer.flight and terminal.saleFlight and agentRequests()==before)
        f:guide();f:ack();f:tick(4);f:snapshot()
        assert(terminal:isCollecting() and terminal.composer.count==0 and agentRequests()==before)
        f:main();terminal.send.Activated:Fire();assert(not terminal.sendRequested)
        f:tick(0.1);assert(terminal:isCollecting() and agentRequests()==before)
        f.input.WindowFocusReleased:Fire();f:tick(4);f.input.WindowFocused:Fire()
        assert(terminal:isCollecting() and agentRequests()==before)
        for _=1,20 do
            if not terminal:isCollecting() then break end
            f:tick(0.1);assert(agentRequests()==before and terminal.composer.count==0)
        end
        assert(not terminal:isCollecting() and terminal.collection.collected==8)
        f:tick(0.05);assert(agentRequests()==before+1 and terminal.composer.count>0)
        assert(#f.submits==1 and f.server.credits==8 and not terminal.sendRequested)
    end)
    test("rare sold tokens play distinct short rising coin harmonies with receipt deduplication",function()
        local pitches={}
        for rank,roll in ipairs({1,9690,9890,9990,10000}) do
            local f=fixture(roll,{money=0});f:compose("a");f:send()
            assert(f.audio.coinIndex==1 and f.audio.coinReceipt==1)
            local notes={}
            for _,voice in ipairs(f.audio.effectVoices) do if voice.note and voice.note.risePitch then notes[#notes+1]=voice.note end end
            assert(#notes==(rank==1 and 1 or 2))
            local lead=notes[1];pitches[#pitches+1]=lead.pitch
            assert(lead.risePitch>lead.pitch and lead.duration<0.25 and lead.gain<=0.055)
            if rank>1 then assert(pitches[rank]>pitches[rank-1]) end
            local plays=0;for _,v in ipairs(f.audio.effectVoices) do plays=plays+(v.sound.playCount or 0) end
            f.audio:coin({receiptId=1,tokenIndex=1,rank=rank});f:snapshot()
            local after=0;for _,v in ipairs(f.audio.effectVoices) do after=after+(v.sound.playCount or 0) end
            assert(after==plays and #f.submits==1)
        end
    end)
    test("navigation icons keep black silhouettes while shop options have no icons",function()
        local f=fixture();local icons={}
        for _,control in ipairs(f.root.FeatureDock.children) do
            if control.FeatureIcon then icons[#icons+1]=control.FeatureIcon end
        end
        for _,action in ipairs({"upgrade_compute","add_layer","upgrade_tokens"}) do
            assert(not f.root.StorePanel.UpgradeList[action]:FindFirstChild("UpgradeIcon"))
        end
        assert(#icons==5)
        for _,icon in ipairs(icons) do
            local edge=icon:GetAttribute("OutlinePixels");assert(edge>=2)
            local outlines,pixels=0,0
            for _,part in ipairs(icon.children) do
                assert(not part.Active and not part.Selectable)
                if part.Name:sub(1,7)=="Outline" then
                    outlines=outlines+1
                    assert(part.ZIndex==1 and table.concat(part.BackgroundColor3,",")=="0,0,0")
                else pixels=pixels+1;assert(part.ZIndex==2) end
            end
            assert(outlines==pixels and outlines>0)
        end
    end)
    test("confirmed sale collects chips sequentially with exact token popups and deduplicated coin effects",function()
        local f=fixture(9890,{money=0});f:compose("abc");f.autoAck=false
        f.terminal.send.Activated:Fire();f:finishSellWriting()
        assert(f.server.credits==30 and f.terminal.composer.count==3 and #f.terminal.collection.batches==0)
        assert(#f.terminal.cash.items==0 and not f.audio.coinReceipt)
        f:ack()
        local terminal=f.terminal
        assert(terminal.composer.count==0 and terminal.collection.collected==1)
        assert(not terminal.soldTokens[1].frame.Visible and terminal.soldTokens[2].frame.Visible and terminal.soldTokens[3].frame.Visible)
        assert(terminal.cash.items[1].amount==10 and terminal.cash.items[1].tokenIndex==1)
        assert(f.audio.coinIndex==1 and #f.audio.effectVoices==6)
        f:snapshot();assert(terminal.collection.collected==1 and f.audio.coinIndex==1)
        f:tick(0.04);f:tick(0.01)
        assert(terminal.collection.collected==2 and not terminal.soldTokens[2].frame.Visible and terminal.soldTokens[3].frame.Visible)
        assert(terminal.cashLabels[1].Position.Y.Offset<terminal.cash.items[1].y)
        f:tick(0.04)
        assert(terminal.collection.collected==3 and terminal.collection.amount==30 and #terminal.collection.batches==0)
        assert(not terminal.soldTokens[3].frame.Visible and f.audio.coinIndex==3)
        local sounds=0;for _,voice in ipairs(f.audio.effectVoices) do sounds=sounds+(voice.sound.playCount or 0) end
        f.audio:coin({receiptId=f.server.lastPrompt.id,tokenIndex=3,amount=10});f:snapshot()
        local after=0;for _,voice in ipairs(f.audio.effectVoices) do after=after+(voice.sound.playCount or 0) end
        assert(after==sounds and f.server.credits==30 and #f.submits==1)
    end)
    test("collection shows locked rarity payouts including zero at the money ceiling",function()
        local f=fixture(9890,{money=0});f:hit("Great");f:hit("Normal");f:hit("Good");f:compose("abc");f:send()
        assert(f.server.credits==30 and f.server.lastPrompt.tokenRewards[1]==10 and f.server.lastPrompt.tokenRewards[2]==10 and f.server.lastPrompt.tokenRewards[3]==10)
        for _=1,4 do f:tick(0.11) end
        assert(f.terminal.collection.amount==30 and f.terminal.collection.collected==3)
        local capped=fixture(10000,{money=shared.Balance.MAX_CREDITS-0.5})
        capped:compose("ab");capped:send();capped:tick(0.11);capped:tick(0.02)
        assert(capped.server.credits==shared.Balance.MAX_CREDITS and capped.terminal.collection.amount==0.5)
        assert(capped.terminal.cash.items[1].amount==0.5 and capped.terminal.cash.items[2].amount==0)
        capped:snapshot();assert(capped.terminal.collection.collected==2)
    end)
    test("collection pauses with pages focus chat and menus while reduced mode stays static and mute never replays coins",function()
        local f=fixture(1,{money=0});f:compose("abcd");f:send()
        local terminal=f.terminal
        assert(terminal.collection.collected==1)
        local age=terminal.cash.items[1].age
        f:guide();f:tick(4);assert(terminal.collection.collected==1 and terminal.cash.items[1].age==age and not terminal.cashLabels[1].Visible)
        f:main();f.gui.MenuIsOpen=true;f:tick(4);f.gui.MenuIsOpen=false
        f.input.WindowFocusReleased:Fire();f:tick(4);f.input.WindowFocused:Fire()
        f.input.textBox={};f:tick(4);f.input.textBox=nil
        assert(terminal.collection.collected==1)
        f.gui.ReducedMotionEnabled=true;f:tick(0.04);f:tick(0.01)
        assert(terminal.collection.collected==2 and terminal.cashLabels[1].Position.Y.Offset==terminal.cash.items[1].y)
        assert(terminal.cashLabels[1].TextTransparency==0)
        local function plays()
            local total=0;for _,voice in ipairs(f.audio.effectVoices) do total=total+(voice.sound.playCount or 0) end;return total
        end
        f.audio:setMuted(true);local sounds=plays();f:tick(0.04)
        assert(terminal.collection.collected==3 and plays()==sounds)
        f.audio:setVolume("effects",0);f.audio:setMuted(false);f:tick(0.045)
        assert(terminal.collection.collected==4 and plays()==sounds)
        f.audio:setVolume("effects",0.5);f:snapshot();f:tick(0.1)
        assert(plays()==sounds and f.server.credits==4 and #f.submits==1)
    end)
    test("collection freezes generation and repeated sales until the last sold token disappears",function()
        local f=fixture(1,{money=0});f:compose("abcdefgh");f:send()
        local terminal=f.terminal;local first=terminal.soldTokens[2].frame
        f:compose("ab");assert(terminal.composer.count==0 and not terminal.tokens[1].Visible)
        terminal.send.Activated:Fire();f:send()
        assert(#f.submits==1 and f.server.credits==8 and #terminal.collection.batches==1)
        assert(terminal.soldTokens[2].frame==first and first.Visible)
        for _=1,22 do f:tick(0.11) end
        assert(#terminal.collection.batches==0 and terminal.collection.collected==8 and terminal.collection.amount==8)
        assert(terminal.composer.count==0 and f.server.credits==8 and #f.submits==1)
        f:compose("a");assert(terminal.composer.count==1 and terminal.tokens[1].Visible and not terminal.sendRequested)
        assert(terminal.frame.AbsoluteSize.Y==terminal.stableHeight)
        for _,piece in ipairs(terminal.soldTokens) do assert(not piece.frame.Visible and not piece.frame.Active) end
    end)
    test("off-page late sale confirmation waits to collect and teardown clears its reused pools",function()
        local f=fixture(1,{money=0});f:compose("abc");f.autoAck=false;f:send();f:guide();f:ack()
        assert(f.server.credits==3 and f.terminal.collection.collected==0 and #f.terminal.cash.items==0)
        f:tick(4);f:snapshot();assert(f.terminal.collection.collected==0 and not f.audio.coinReceipt)
        f:main();f:tick(0.02);assert(f.terminal.collection.collected==1 and f.audio.coinIndex==1)
        f.root.Parent:Destroy();assert(f.audio.destroyed and #f.terminal.collection.batches==0)
        local count=f.terminal.collection.collected;f:tick(4)
        assert(f.terminal.collection.collected==count and f.server.credits==3 and #f.submits==1)
    end)
    test("full collection stays readable and the next context waits for collection to finish",function()
        local f=fixture();f:shop();for _=1,15 do f:buyUpgrade("upgrade_tokens") end;f:main()
        f:compose(string.rep("a",64));f:send();local money=f.server.credits
        f:compose(string.rep("a",64));assert(f.terminal.composer.count==0 and #f.submits==1)
        local terminal=f.terminal
        for _,size in ipairs({{1280,720},{360,640},{640,360}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2])
            for _,piece in ipairs(terminal.soldTokens) do
                assert(piece.frame.Position.Y.Offset+shared.Composer.TOKEN_STYLE.rowHeight<=terminal.preview.AbsoluteSize.Y)
                assert(piece.word.TextSize==shared.Composer.TOKEN_STYLE.wordSize and not piece.frame.Active)
            end
            for _,piece in ipairs(terminal.tokens) do
                assert(not piece.Visible)
            end
        end
        for _=1,70 do f:tick(0.05) end
        assert(terminal.collection.collected==64 and terminal.collection.amount==64 and #terminal.collection.batches==0)
        assert(#terminal.soldTokens==64 and #terminal.cash.items<=shared.Cash.MAX_LABELS)
        assert(terminal.composer.count==0 and f.server.credits==money and #f.submits==1)
        f:compose(string.rep("a",64));assert(terminal.composer.count==64)
        for _,label in ipairs(terminal.cashLabels) do
            if label.Visible then assert(label.Position.X.Offset>=0 and label.Position.X.Offset<=f.root.AbsoluteSize.X) end
        end
    end)
    test("shop remains on the right and purchases never replace or pause the CLI",function()
        local f=fixture();local panel=f.root.StorePanel
        assert(panel.Parent==f.root and panel.Visible and not f.root.Pages:FindFirstChild("StorePage"))
        f:compose("ab");local draft=f.terminal.composer.draft.id
        local position=f.terminal.frame.Position
        f:shop()
        assert(f.desk.parent.Visible and not f.terminal.suspended and not f.skill.suspended)
        assert(f.terminal.frame.Position==position and f.terminal.composer.count==2)
        f:buyUpgrade("upgrade_tokens")
        assert(f.server.tokenLevel==1 and f.terminal.composer.draft.id==draft and f.terminal.composer.count==2)
        f:hit("Normal");assert(f.terminal.composer.count==2 and #f.submits==0)
        f:send();assert(#f.submits==1 and f.server.lastPrompt.tokens==2)
        f:guide();assert(not panel.Visible and not f.desk.parent.Visible)
        f:buyUpgrade("upgrade_compute");assert(f.server.computeLevel==1 and panel.Visible)
        f:main();assert(panel.Visible and f.desk.parent.Visible)
    end)
    test("fixed shop has larger text without icons and leaves CLI typography unscaled",function()
        local f=fixture();local panel=f.root.StorePanel;local list=panel.UpgradeList
        for _,size in ipairs({{1280,720},{900,640},{360,640},{640,360}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2])
            assert(panel.Visible and panel.AbsolutePosition.X+panel.AbsoluteSize.X==size[1]-8)
            assert(panel.AbsolutePosition.Y>=8 and panel.AbsolutePosition.Y+panel.AbsoluteSize.Y<=size[2]-44)
            assert(f.desk.parent.AbsoluteSize.X==size[1] and f.desk.canvasWidth>=size[1])
            assert(f.terminal.frame.AbsoluteSize.X>=300 and f.terminal.tokenWords[1].TextSize==shared.Composer.TOKEN_STYLE.wordSize)
            assert(f.skill.button.AbsolutePosition.X+f.skill.button.AbsoluteSize.X<panel.AbsolutePosition.X)
            for _,action in ipairs({"upgrade_compute","add_layer","upgrade_tokens"}) do
                local card=list[action]
                assert(not card:FindFirstChild("UpgradeIcon") and card.BuyUpgrade.AbsoluteSize.Y==card.AbsoluteSize.Y)
                assert(card.UpgradeName.TextSize>=14 and card.UpgradePrice.TextSize>=14 and card.UpgradeStatus.TextSize>=14)
                assert(card.UpgradeName.Position.Y.Offset+card.UpgradeName.AbsoluteSize.Y<=card.UpgradePrice.Position.Y.Offset)
                assert(card.UpgradePrice.Position.Y.Offset+card.UpgradePrice.AbsoluteSize.Y<=card.UpgradeStatus.Position.Y.Offset)
                assert(card.UpgradeStatus.Position.Y.Offset+card.UpgradeStatus.AbsoluteSize.Y<=card.AbsoluteSize.Y)
            end
        end
        f.root.Size=f.udim2.fromOffset(360,640)
        local x=panel.AbsolutePosition.X
        assert(f.desk.parent.CanvasSize.X.Offset>=360)
        f.desk.parent.CanvasPosition=f.vec2.new(f.desk.parent.CanvasSize.X.Offset-f.desk.parent.AbsoluteSize.X,0)
        assert(panel.AbsolutePosition.X==x and f.terminal.tokenWords[1].TextSize==shared.Composer.TOKEN_STYLE.wordSize)
    end)
    test("shop pointer cannot trigger free skill focus or covered CLI actions and buys remain server-priced",function()
        local f=fixture();local card=f.root.StorePanel.UpgradeList.upgrade_compute
        local pointer=f:pointer(card.BuyUpgrade);local front=f.desk.front;local requests=#f.requests
        assert(not f.skill.allowFreeSpace(pointer) and not f.desk:ownsPointer(1,pointer))
        f.root.FreeSpaceClick.InputBegan:Fire(pointer);f.root.FreeSpaceClick.Activated:Fire(pointer)
        f.terminal.bar.InputBegan:Fire(pointer);f.terminal.bar.Activated:Fire(pointer)
        assert(#f.requests==requests and f.desk.front==front and not f.desk.drag)
        local money=f.server.credits;local price=shared.Rules.quote(f.server,"upgrade_compute",nil,shared.Balance)
        card.BuyUpgrade.Activated:Fire(pointer)
        assert(f.server.credits==money-price and f.server.computeLevel==1 and #f.submits==0)
        f.desk.drag={index=1};card.BuyUpgrade.Activated:Fire(pointer);f.desk.drag=nil
        assert(f.server.computeLevel==1 and f.terminal.composer.count==0)
        f:tick(0.31)
        local p,size=card.BuyUpgrade.AbsolutePosition,card.BuyUpgrade.AbsoluteSize
        local corner={UserInputType=pointer.UserInputType,Position={X=p.X+size.X-12,Y=p.Y+size.Y-16}}
        money=f.server.credits;price=shared.Rules.quote(f.server,"upgrade_compute",nil,shared.Balance)
        requests=#f.requests;card.BuyUpgrade.Activated:Fire(corner)
        assert(f.server.computeLevel==2 and f.server.credits==money-price and #f.requests==requests+1)
        f:tick(0.31);f.gui.SelectedObject=card.BuyUpgrade
        money=f.server.credits;price=shared.Rules.quote(f.server,"upgrade_compute",nil,shared.Balance)
        card.BuyUpgrade.Activated:Fire({UserInputType=f.enum.UserInputType.Gamepad1,KeyCode=f.enum.KeyCode.ButtonA,Position={X=0,Y=0}})
        assert(f.server.computeLevel==3 and f.server.credits==money-price)
    end)
    test("Main CLI drags under the shop without covered focus drag or SELL actions",function()
        local f=fixture();local window=f.terminal.frame;local shop=f.root.StorePanel
        window.Position=f.udim2.fromOffset(0,200)
        local press={UserInputType=f.enum.UserInputType.MouseButton1,Position={X=100,Y=210}}
        f.terminal.bar.InputBegan:Fire(press);assert(f.desk.drag)
        f.input.InputChanged:Fire({UserInputType=f.enum.UserInputType.MouseMovement,Position={X=5000,Y=210}})
        f.input.InputEnded:Fire(press)
        assert(window.Position.X.Offset+window.AbsoluteSize.X==f.root.AbsoluteSize.X)
        assert(window.AbsolutePosition.X<shop.AbsolutePosition.X and window.AbsolutePosition.X+window.AbsoluteSize.X>shop.AbsolutePosition.X)
        assert(shop.ZIndex>f.root.Pages.ZIndex)
        local point={UserInputType=f.enum.UserInputType.MouseButton1,Position={X=shop.AbsolutePosition.X+20,Y=210}}
        local x,y=window.Position.X.Offset,window.Position.Y.Offset;local requests=#f.requests
        f.terminal.bar.InputBegan:Fire(point);f.terminal.bar.Activated:Fire(point)
        f.terminal.send.Activated:Fire(point)
        assert(not f.desk.drag and window.Position.X.Offset==x and window.Position.Y.Offset==y)
        assert(#f.requests==requests and #f.submits==0 and not f.skill.allowFreeSpace(point))
        local row=shop.UpgradeList.upgrade_compute
        local money=f.server.credits;local price=shared.Rules.quote(f.server,"upgrade_compute",nil,shared.Balance)
        row.BuyUpgrade.Activated:Fire(f:pointer(row.BuyUpgrade))
        assert(f.server.credits==money-price and f.server.computeLevel==1)
        f:snapshot();assert(window.Position.X.Offset==x)
    end)
    test("shop focus keeps sequential collection running and reconnect preserves real panel scroll",function()
        local f=fixture();f:compose("abcd");f:send();local panel=f.root.StorePanel
        local collected=f.terminal.collection.collected
        f:shop();f:tick(0.1);f:tick(0.02)
        assert(f.terminal.collection.collected>collected and f.desk.parent.Visible)
        f.root.Size=f.udim2.fromOffset(360,640);f:tick(0)
        for _,label in ipairs(f.terminal.cashLabels) do
            if label.Visible then assert(label.Position.X.Offset+label.AbsoluteSize.X/2<=f.desk.parent.AbsoluteSize.X) end
        end
        f.root.Size=f.udim2.fromOffset(1280,360)
        local list=panel.UpgradeList;assert(list.CanvasSize.Y.Offset>list.AbsoluteSize.Y)
        list.CanvasPosition=f.vec2.new(0,100)
        f:buyUpgrade("upgrade_tokens");f:reconnect()
        assert(list.CanvasPosition.Y==100 and panel.Visible and f.desk.parent.Visible and #f.submits==1)
        for _=1,10 do f:tick(0.1) end
        assert(f.terminal.collection.collected==4 and f.terminal.collection.amount==4 and #f.submits==1)
        for _,label in ipairs(f.terminal.cashLabels) do
            if label.Visible then assert(label.Position.X.Offset+label.AbsoluteSize.X/2<=f.desk.parent.AbsoluteSize.X) end
        end
    end)
    test("top Laboratory Cards and progression icons open their pages",function()
        local f=fixture();local dock=f.root.FeatureDock
        local lab,cards,tree=dock.Laboratory,dock.Cards,dock.SkillTree
        assert(dock.Prestige and dock.Prestige.FeatureIcon:GetAttribute("IconId")=="prestige")
        f:compose("ab");local money=f.server.credits;local requests=#f.requests
        local draft=f.terminal.composer.draft.id;local front=f.desk.front
        for _,size in ipairs({{1280,720},{360,640},{640,360},{320,360}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2])
            assert((dock.AbsolutePosition.Y==8 or dock.AbsolutePosition.Y==134 or dock.AbsolutePosition.Y==146) and dock.AbsolutePosition.X>=0)
            assert(dock.AbsolutePosition.X+dock.AbsoluteSize.X<=f.desk.parent.AbsoluteSize.X)
            assert(lab.AbsolutePosition.X+64<=cards.AbsolutePosition.X)
            assert(tree.AbsolutePosition.Y>=lab.AbsolutePosition.Y+64 or cards.AbsolutePosition.X+64<=tree.AbsolutePosition.X)
            for _,control in ipairs({lab,cards,tree}) do
                assert(control.Active and control.Selectable and control.AbsoluteSize.X==64 and control.AbsoluteSize.Y==64)
                assert(control.FeatureIcon.AbsoluteSize.X==48 and not control.FeatureIcon.Active)
                for _,part in ipairs(control.FeatureIcon.children) do
                    assert(not part.Active and not part.Selectable and part.Position.X.Offset%1==0 and part.Position.Y.Offset%1==0)
                end
            end
        end
        lab.Activated:Fire(f:pointer(lab))
        assert(dock:GetAttribute("SelectedFeature")=="laboratory" and lab:GetAttribute("Selected") and not cards:GetAttribute("Selected"))
        assert(f.root.Pages.AgentLabPage.Visible and not f.desk.parent.Visible)
        f:main();dock.CanvasPosition=f.vec2.new(76,0);cards.Activated:Fire(f:pointer(cards))
        assert(dock:GetAttribute("SelectedFeature")=="cards" and cards:GetAttribute("Selected") and not lab:GetAttribute("Selected"))
        assert(f.cardPage.frame.Visible and not f.root.Pages.AgentLabPage.Visible)
        f:main();dock.CanvasPosition=f.vec2.new(152,0);tree.Activated:Fire(f:pointer(tree))
        assert(dock:GetAttribute("SelectedFeature")=="skill_tree" and tree:GetAttribute("Selected") and not cards:GetAttribute("Selected"))
        assert(f.root.Pages.ProgressionPage.Visible and not f.root.Pages.AgentLabPage.Visible)
        assert(f.server.credits==money and #f.requests==requests and #f.submits==0 and f.desk.front==front)
        assert(f.terminal.composer.count==2 and f.terminal.composer.draft.id==draft and f.terminal.suspended)
        f:guide();f:feature("Laboratory")
        assert(not dock.Visible and not f.root.StorePanel.Visible and not f.desk.parent.Visible)
        assert(dock:GetAttribute("SelectedFeature")=="laboratory" and #f.submits==0)
    end)
    test("top feature buttons reject click-through drags overlays and stale callbacks after teardown",function()
        local f=fixture();local dock=f.root.FeatureDock;local lab,cards=dock.Laboratory,dock.Cards
        f.terminal.frame.Position=f.udim2.fromOffset(0,0)
        f.terminal.frame.Size=f.udim2.fromOffset(f.desk.canvasWidth,720)
        f.desk:focus(1);local pointer=f:pointer(lab);local requests=#f.requests
        assert(not f.skill.allowFreeSpace(pointer))
        f.terminal.bar.InputBegan:Fire(pointer);f.terminal.bar.Activated:Fire(pointer)
        f.root.FreeSpaceClick.InputBegan:Fire(pointer);f.root.FreeSpaceClick.Activated:Fire(pointer)
        assert(not f.desk.drag and f.desk.front==1 and f.terminal.composer.count==0 and #f.requests==requests)
        f.desk.drag={index=1};lab.Activated:Fire(pointer);f.desk.drag=nil
        assert(not dock:GetAttribute("SelectedFeature"))
        f.gui.MenuIsOpen=true;lab.Activated:Fire(pointer);f.gui.MenuIsOpen=false
        f.input.WindowFocusReleased:Fire();lab.Activated:Fire(pointer);f.input.WindowFocused:Fire()
        assert(not dock:GetAttribute("SelectedFeature"))
        local blocks=f.dancers.blocksPointer;f.dancers.blocksPointer=function() return true end
        lab.Activated:Fire(pointer);assert(not dock:GetAttribute("SelectedFeature"));f.dancers.blocksPointer=blocks
        cards.Activated:Fire(f:pointer(cards));assert(dock:GetAttribute("SelectedFeature")=="cards")
        f.root.Parent:Destroy();lab.Activated:Fire(pointer)
        assert(dock:GetAttribute("SelectedFeature")=="cards" and #f.requests==requests and #f.submits==0)
    end)
    local function craftingFixture()
        local fragments={};for _,family in ipairs(shared.Balance.AGENT_FAMILIES) do fragments[family.id]=100 end
        return fixture(1,{newCollection=true,money=100000000000,profile={fragments=fragments,lifetimeEarned=1000000000,prestigeClaimed=100,prestigeCount=1,chips=100}})
    end
    test("Laboratory shows nine families and four variant recipes without changing roster or spending on selection",function()
        local f=craftingFixture();f:feature("Laboratory");local lab=f.lab;local mascot=f.terminal.mascot
        assert(#lab.cards==9 and #lab.recipes==4 and #f.mascotCatalog.ORDER==36 and #f.mascotCatalog.ember.parts==11)
        local money,requests=f.server.credits,#f.requests
        for index,entry in ipairs(lab.cards) do
            entry.frame.Activated:Fire();assert(lab.target==index and lab.cards[index].buff.Text=="100" and lab.cards[index].speed.Text=="FRAGMENTS")
            for rank,recipe in ipairs(lab.recipes) do
                local id=lab:cardId(rank);assert(recipe.preview.id==id and recipe.frame:GetAttribute("CardId")==id)
                assert(recipe.cost.Text:find("Chips",1,true) and recipe.cost.Text:find("fragments",1,true))
                assert(recipe.preview.motion.Rotation==0 and f.mascotCatalog[id])
            end
        end
        assert(mascot.id=="ember" and f.server.credits==money and #f.requests==requests)
        for _,size in ipairs({{1280,720},{360,640},{640,360},{320,360}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2])
            for _,entry in ipairs(lab.recipes) do
                assert(entry.frame.Position.X.Offset>=0 and entry.frame.Position.X.Offset+entry.frame.AbsoluteSize.X<=lab.list.AbsoluteSize.X+1)
                assert(entry.preview.frame.AbsoluteSize.X==160 and entry.preview.motion.Rotation==0)
            end
        end
    end)
    test("Laboratory crafts one deterministic version and Cards equips its exact rarity skin",function()
        local f=craftingFixture();f:feature("Laboratory");local lab=f.lab
        lab.cards[2].frame.Activated:Fire();local before=f.server.credits
        lab.recipes[2].buy.Activated:Fire()
        assert(f.server.cardOwned.sprout_rare and f.server.cardCrafted.sprout_rare and not f.server.cardDeck[1])
        assert(f.server.fragments.sprout==88 and f.server.credits==before-25000 and f.server.chips==97)
        assert(lab.recipes[2].buy.Text=="OWNED" and not lab.recipes[2].buy.Active)
        local requests=#f.requests;lab.recipes[2].buy.Activated:Fire();assert(#f.requests==requests)
        lab.openCards.Activated:Fire();assert(f.cardPage.frame.Visible)
        f.cardPage.inventory.sprout_rare.frame.Activated:Fire();f.cardPage.slots[1].frame.Activated:Fire()
        assert(f.server.cardDeck[1]=="sprout_rare" and f.terminal.mascot.id=="sprout_rare")
        assert(f.cardPage.slots[1].rarity.Text=="RARE" and f.cardPage.inventoryTitle.Text=="INVENTORY / 1")
    end)
    test("Laboratory rejects hidden clipped chat modifier blur menu and pending crafts with bounded reconciliation",function()
        local f=craftingFixture();local lab=f.lab;local buy=lab.recipes[2].buy
        local requests=#f.requests;buy.Activated:Fire();assert(#f.requests==requests)
        f:feature("Laboratory");f.gui.MenuIsOpen=true;buy.Activated:Fire();f.gui.MenuIsOpen=false
        f.input.textBox={};buy.Activated:Fire();f.input.textBox=nil
        f.input.held[f.enum.KeyCode.LeftControl]=true;buy.Activated:Fire();f.input.held[f.enum.KeyCode.LeftControl]=false
        f.input.WindowFocusReleased:Fire();buy.Activated:Fire();f.input.WindowFocused:Fire()
        f.desk.drag={};buy.Activated:Fire();f.desk.drag=nil
        lab.list.CanvasPosition=f.vec2.new(0,2000);buy.Activated:Fire(f:pointer(buy));assert(#f.requests==requests)
        f.autoAck=false;buy.Activated:Fire();assert(f.progression.pending and lab.pending)
        requests=#f.requests;buy.Activated:Fire();lab.cards[2].frame.Activated:Fire();assert(#f.requests==requests and lab.target==1)
        f:tick(3.1);f:ack();assert(not f.progression.pending and f.server.cardOwned.ember_rare)
        local count=0;for _,request in ipairs(f.requests) do if request.action=="craft_card" then count=count+1 end end;assert(count==1)
        requests=#f.requests;f.root.Parent:Destroy();buy.Activated:Fire();assert(#f.requests==requests)
    end)
    test("separate pages preserve drafts and hidden input cannot send or generate words",function()
        local f=fixture();f:compose("a");local id=f.terminal.composer.draft.id
        f:guide();f:compose("bb");f:send();assert(f.terminal.composer.count==1 and #f.submits==0)
        f:buyUpgrade("upgrade_tokens");f:buyAgent()
        assert(f.root.StorePanel.Visible and f.terminal.composer.draft.id==id)
        f:button(f.root.DesktopDock,"Guide").Activated:Fire();f:key("A");assert(f.terminal.composer.count==1)
        f:main();f:send();assert(#f.submits==1 and f.submits[1].tokens==1)
    end)
    test("confirmed purchases add passive avatars to one Main CLI without creating agent windows",function()
        local f=fixture(1,{money=1000000000});local frame=f.terminal.frame;local width=frame.AbsoluteSize.X
        local draft=f.terminal.composer.draft.id
        for count=1,8 do
            if count>1 then f:buyAgent() end
            assert(f.desk.count==count and #f.desk.windows==1 and f.desk.front==1)
            assert(f.terminal.frame==frame and frame.AbsoluteSize.X==width and f.terminal.composer.draft.id==draft)
            for index,agent in ipairs(f.desk.agents) do
                assert(agent.frame.Visible==(index<=count) and agent.frame.Parent==f.desk.roster)
                assert(not agent.frame.Active and not agent.frame.Selectable and not agent.mascot.frame.Active)
                assert(not f.desk.parent:FindFirstChild("AgentCLI"..index))
            end
        end
        local last=f.desk.agents[8].mascot;f:snapshot();f:main()
        assert(f.desk.agents[8].mascot==last and not f.desk:activate(2) and #f.submits==0)
        for _,control in ipairs(f.root.DesktopDock.children) do assert(not (control.Text or ""):match("^CLI ")) end
        local denied=fixture(1,{money=0});denied:buyAgent()
        assert(denied.desk.count==1 and not denied.desk.agents[2].frame.Visible and #denied.desk.windows==1)
    end)
    test("initial lost sync packets recover without leaving the production store Connecting",function()
        local f=fixture(1,{dropSync=2})
        assert(f.terminal.blocked)
        f:tick(2);assert(not f.terminal.blocked and not f.terminal.composer.draft)
        f:tick(2);assert(not f.terminal.blocked and f.terminal.composer.draft)
        f:shop();f:restoreLegacyUpgrade("upgrade_typing")
        assert(f.server.typingLevel==1 and f.terminal.speed==6)
    end)
    test("missing server has bounded retries and an unavailable state instead of infinite Connecting",function()
        local f=fixture(1,{offline=true})
        for _=1,16 do f:tick(1) end
        assert(#f.requests==5)
        assert(string.find(f.terminal.hint.Text,"unavailable",1,true))
        for _,card in ipairs(f.root.StorePanel.UpgradeList.children) do
            if card.ClassName=="Frame" then
                for _,object in ipairs(card.children) do
                    if object.ClassName=="TextButton" then assert(object.Text=="Reconnect to buy" and not object.Active) end
                end
            end
        end
        f:tick(30);assert(#f.requests==5 and #f.submits==0)
        f:feature("Cards");f.cardPage.inventory.ember.frame.Activated:Fire()
        assert(f.cardPage.message.Text:find("Reconnect",1,true) and not f.cardPage.inventory.ember.frame.Visible and #f.requests==5)
    end)
    test("missing or failing Studio tests cannot prevent production remotes or prompt payout",function()
        for _,failure in ipairs({false,true}) do
            local f=fixture(1,{studio=true,testsFail=failure,money=0})
            assert(not f.terminal.blocked)
            f:runDeferred();assert(#f.warnings==1)
            f:compose("a");f:send();assert(f.server.credits==1 and #f.submits==1)
        end
    end)
    test("top-left pixel balance uses only confirmed snapshots and keeps money after idle",function()
        local f=fixture(9890,{money=0});f:compose("a");f.autoAck=false;f:send()
        local hud=f.root.MoneyHUD
        assert(hud.Balance.Text=="$0.00" and hud.BackgroundTransparency==1 and not hud.Active)
        f:ack();assert(hud.Balance.Text=="$10.00" and hud.Shadow.Text==hud.Balance.Text)
        assert(hud.Balance.FontFace.Family=="PressStart2P" and not hud.Balance.Active)
        assert(f.server.stats.moneyPerSecond==1 and f.server.credits==10)
        f:guide();assert(not hud.Visible);f:main();f:tick(10.1);f:snapshot()
        assert(f.server.stats.moneyPerSecond==0 and hud.Balance.Text=="$10.00" and f.server.credits==10)
        for _,item in ipairs(f.root.DesktopDock.children) do assert(item.Text~="STATS") end
    end)
    test("pixel balance and feature buttons fit separate header space and reject covered CLI gestures",function()
        local f=fixture();local hud=f.root.MoneyHUD
        for _,size in ipairs({{1280,720},{900,640},{360,640},{320,360}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2])
            local h,d=hud.AbsolutePosition,f.root.FeatureDock.AbsolutePosition
            assert(h.X==12 and h.Y==10 and h.X+hud.AbsoluteSize.X<=f.desk.parent.AbsoluteSize.X)
            assert(d.Y>=h.Y+hud.AbsoluteSize.Y or d.X>=h.X+hud.AbsoluteSize.X)
            assert(#hud.Balance.Text*hud.Balance.TextSize<=hud.AbsoluteSize.X-4)
        end
        f.root.Size=f.udim2.fromOffset(1280,720);f.terminal.frame.Position=f.udim2.fromOffset(0,0)
        local pointer=f:pointer(hud);local requests=#f.requests
        assert(not f.skill.allowFreeSpace(pointer))
        f.terminal.bar.InputBegan:Fire(pointer);f.terminal.bar.Activated:Fire(pointer)
        assert(not f.desk.drag and #f.requests==requests)
        f.root.Parent:Destroy();assert(not hud.Balance.Active)
    end)
    test("manual full context keeps timing streak and feedback without new tokens or retroactive rewards",function()
        local f=fixture(1,{money=0})
        f:fillContext()
        f:hit("Great");f:hit("Good")
        assert(f.server.stats.streak==2 and f.terminal.composer.count==8 and f.skill.streak==2)
        assert(f.server.skillCheck.lastClick.wordCount==0 and f.floatingWords.emitted==2 and #f.submits==0)
        for _,award in ipairs(f.server.skillCheck.awards) do assert(award.multiplier==1) end
        f:hit("Normal");assert(f.server.stats.streak==0 and f.terminal.composer.count==8)
        f:send();assert(f.server.credits==8 and #f.submits==1)
        f:hit("Great");assert(f.terminal.composer.count==0 and #f.submits==1 and not f.server.pendingSkillWords)
    end)
    test("queued SELL reconciles a delayed zero-word full check once before paying its original tokens",function()
        local f=fixture(1,{money=0})
        f:fillContext()
        f.autoAck=false;f:hit("Great");f.terminal.send.Activated:Fire()
        assert(f.skill.pending and f.terminal.sendRequested and #f.submits==0)
        f:tick(3.1);f:deliverReplies()
        assert(not f.skill.pending and f.terminal.composer.count==8 and f.server.stats.streak==1)
        f:tick(0.15);assert(#f.submits==1 and f.server.credits==8)
        f:deliverReplies();f:snapshot();f:deliverReplies();f:tick(0.2)
        assert(#f.submits==1 and f.terminal.composer.count==0 and not f.terminal.sendRequested)
    end)
    test("pending submissions timeout sync only and late receipt cannot replay money",function()
        local f=fixture();f.autoAck=false;f:compose("a");f:send()
        assert(f.terminal.composer.flight and #f.submits==1)
        f:tick(5.1);assert(not f.terminal.composer.flight and #f.submits==1)
        f:ack();assert(f.terminal.composer.count==0 and #f.terminal.cash.items==1)
        f:snapshot();assert(#f.terminal.cash.items==1 and #f.submits==1)
        f:compose("b");assert(f.terminal.composer.count==1)
    end)
    test("chat processed shortcuts menus and app focus exclude external input without blocking native CLI",function()
        local f=fixture();f.input.textBox={};f:key("A");f.input.textBox=nil
        f:key("A",true);f.input.held[f.enum.KeyCode.LeftControl]=true;f:key("A");f.input.held={}
        f.gui.MenuIsOpen=true;f:key("A");f.gui.MenuIsOpen=false
        f.input.WindowFocusReleased:Fire();f:key("A");f.input.WindowFocused:Fire()
        assert(f.terminal.composer.count==0 and #f.submits==0)
        f:compose("a");assert(f.terminal.composer.count==1);f:send();assert(#f.submits==1)
    end)
    test("procedural pixel wallpaper is bounded static and has no external image or gradient",function()
        local f=fixture();local wall=f.playerGui.VibeIdleBackdrop.PixelWallpaper
        assert(wall and #wall.children==32*18+1 and wall.PrestigeScale.Scale==1)
        for _,pixel in ipairs(wall.children) do
            if pixel.ClassName~="UIScale" then
                assert(pixel.ClassName=="Frame" and pixel.Name=="Pixel" and pixel.BorderSizePixel==0)
                for _,channel in ipairs(pixel.BackgroundColor3) do assert(channel>=0 and channel<=255) end
            end
        end
    end)
    test("each token rarity has its own framed object color border and multiplier badge",function()
        local colors={}
        for index,roll in ipairs({1,9690,9890,9990,10000}) do
            local f=fixture(roll);f:compose("a")
            local piece=f.terminal.tokens[1]
            assert(piece.ClassName=="Frame" and piece:GetAttribute("Rarity")==shared.Balance.SPECIAL_TOKENS[index].rarity)
            local color=piece.Word.TextColor3;local key=table.concat(color,",")
            assert(not colors[key]);colors[key]=true
            assert(piece.Word.Text=="build" and piece.Multiplier.Visible==(index>1))
            if index>1 then assert(piece.PanelBorder.Color==color and piece.Multiplier.Text=="x"..shared.Balance.SPECIAL_TOKENS[index].multiplier) end
        end
    end)
    test("manual Store reconnect recovers after exhausted syncs and preserves an existing draft",function()
        local f=fixture(9890,{dropSync=100})
        for _=1,16 do f:tick(1) end
        assert(not f.terminal.composer.draft)
        f.dropSync=0;f:reconnect()
        assert(f.terminal.composer.draft and not f.terminal.blocked)
        f:main();f:compose("a")
        local draft=f.terminal.composer.draft;local money=f.server.credits
        f:shop();f.root.StorePanel.UpgradeList.CanvasPosition=f.vec2.new(0,90)
        f:reconnect()
        assert(f.root.StorePanel.Visible and f.root.StorePanel.UpgradeList.CanvasPosition.Y==90)
        assert(f.terminal.composer.count==1 and f.terminal.composer.draft.id==draft.id)
        assert(f.terminal.composer.draft.offers[1].multiplier==10 and f.server.credits==money and #f.submits==0)
        f:buyUpgrade("upgrade_compute");assert(f.server.computeLevel==1)
    end)
    test("mixed server client versions show a restart message instead of stuck connecting",function()
        local f=fixture(1,{studio=true,serverVersion="0.6.0"})
        assert(f.terminal.blocked and string.find(f.terminal.hint.Text,"restart Play",1,true))
        local list=f.root.StorePanel.UpgradeList
        for _,object in ipairs(list.upgrade_compute.children) do
            if object.ClassName=="TextButton" then assert(object.Text=="Reconnect to buy" and not object.Active) end
        end
        f.reportVersion=nil;f:reconnect();assert(not f.terminal.blocked and f.terminal.composer.draft)
        f:buyUpgrade("upgrade_compute");assert(f.server.computeLevel==1)
    end)
    test("invalid profile cannot crash Store rendering and reconnect restores valid prices",function()
        local f=fixture(1,{invalidProfile=true})
        assert(f.terminal.blocked and #f.warnings>0)
        assert(string.find(f.terminal.hint.Text,"Session data unavailable",1,true))
        f.invalidProfile=false;f:reconnect()
        assert(not f.terminal.blocked and f.terminal.composer.draft)
        f:shop();f:buyUpgrade("upgrade_compute");assert(f.server.computeLevel==1)
    end)
    test("a server clock progressing between reads accepts normally paced native Enter",function()
        local f=fixture(1,{money=0,serverClockStep=0.001})
        f:compose("a");f:send()
        assert(f.server.credits==1 and f.server.lastPrompt and f.server.lastPrompt.tokens==1,
            f.server.message or "A valid prompt was not paid")
        assert(not f.server.promptRejected and #f.submits==1)
    end)
    test("manual full prompt ignores typing pace across different client and server clock epochs",function()
        local f=fixture(1,{money=0,serverClockStep=0.001,clientClockOffset=5000})
        f:compose("abcdefgh")
        assert(#f.submits==0 and f.server.credits==0,"Manual full prompt must wait for Enter or SELL")
        f:send()
        for _=1,40 do f:tick(0.05) end
        assert(f.server.credits==8 and not f.server.promptRejected and #f.submits==1)
    end)
    test("SELL stays visually available and shares the once-only Enter path while writing and selling",function()
        local f=fixture(1,{money=0,serverClockStep=0.001,clientClockOffset=5000})
        assert(f.terminal.send.Active)
        local color,labelColor=f.terminal.sellArt.parts[1].BackgroundColor3,f.terminal.sellArt.label.TextColor3
        f:compose("abcdefg");assert(f.terminal.send.Active)
        f.autoAck=false;f.terminal.send.Activated:Fire()
        assert(f.terminal.sendRequested and not f.terminal.composer.flight and f.terminal.send.Active)
        f.terminal.input:ReleaseFocus(true);f.terminal.send.Activated:Fire()
        f:finishSellWriting()
        assert(f.terminal.composer.flight and f.terminal.send.Active and f.terminal.send.Text=="SELL")
        for _=1,40 do f:tick(0.05) end
        assert(#f.submits==1 and f.server.credits==7 and f.terminal.composer.flight)
        assert(f.terminal.send.Text=="SELL" and f.terminal.send.Active)
        f.terminal.send.Activated:Fire();f:key("Return");assert(#f.submits==1)
        f:ack();assert(#f.terminal.cash.items==1 and f.terminal.composer.count==0)
        assert(f.terminal.send.Active and f.terminal.send.Text=="SELL")
        assert(f.terminal.sellArt.parts[1].BackgroundColor3==color and f.terminal.sellArt.label.TextColor3==labelColor)
        f.terminal.send.Activated:Fire();f:tick(0.5)
        assert(#f.submits==1 and not f.terminal.sendRequested)
    end)
    test("one queued SELL waits for a delayed skill receipt and all letters before submitting",function()
        local f=fixture(1,{money=0});f:compose("a");f:aim("Great");f.terminal:beginReveal(1);f.autoAck=false;f.skill.button.Activated:Fire({UserInputType=f.enum.UserInputType.MouseButton1,Position={X=f.skill.button.AbsolutePosition.X+60,Y=f.skill.button.AbsolutePosition.Y+60}})
        assert(f.skill.pending and f.terminal.composer.count==1 and f.terminal.send.Active)
        f.terminal.send.Activated:Fire()
        assert(f.terminal.sendRequested==f.terminal.composer.draft.id and f.terminal.send:GetAttribute("Queued"))
        for _=1,12 do f.terminal.send.Activated:Fire();f:press("Return");f.input.InputEnded:Fire({KeyCode={Name="Return"}}) end
        assert(#f.submits==0 and f.server.credits==0)
        f:deliverReplies()
        assert(not f.skill.pending and f.terminal.composer.count==1 and next(f.terminal.reveals) and #f.submits==0)
        assert(not f.skill:eligible())
        f:tick(0.001);assert(#f.submits==0)
        f:tick(0.15)
        assert(#f.submits==1 and f.submits[1].tokens==1 and f.server.credits==1)
        assert(not f.terminal.sendRequested and f.terminal.composer.flight and f.terminal.send.Active)
        f.terminal.send.Activated:Fire();f:deliverReplies();f:tick(0.3);f:snapshot();f:deliverReplies()
        assert(#f.submits==1 and f.terminal.composer.count==0 and not f.terminal.sendRequested)
    end)
    test("queued SELL takes priority over due agents after the current agent finishes writing",function()
        local f=fixture(1,{money=0,agents=true});f.autoAck=false;f:tick(1.1)
        assert(f.terminal.agentPending and f.terminal.composer.count==0)
        f.terminal.send.Activated:Fire();f.terminal.send.Activated:Fire()
        f:deliverReplies()
        assert(not f.terminal.agentPending and next(f.terminal.reveals) and #f.submits==0)
        f.terminal.nextAgent=f.now;f:tick(0.15)
        assert(#f.submits==1 and f.submits[1].tokens==1 and f.server.credits==1)
        local agents=0;for _,request in ipairs(f.requests) do if request.action=="agent_type" then agents=agents+1 end end
        assert(agents==1 and not f.terminal.agentPending and f.terminal.composer.flight)
        f:deliverReplies();f:tick(0.2);f:deliverReplies();f:tick(0.2)
        assert(#f.submits==1 and not f.terminal.sendRequested)
    end)
    test("queued SELL uses immediate complete words in reduced motion without a second sale",function()
        local f=fixture(1,{money=0});f:compose("abc");f.terminal.send.Activated:Fire()
        assert(f.terminal.sendRequested and #f.submits==0 and f.server.credits==0)
        f.terminal:setReducedMotion(true);assert(not next(f.terminal.reveals))
        f:tick(0);assert(#f.submits==1 and f.server.credits==3 and f.terminal.composer.count==0)
        f:compose("a");assert(f.terminal.composer.count==0)
        f:finishCollection()
        f:compose("a");f:tick(0.1);assert(#f.submits==1 and f.terminal.composer.count==1)
    end)
    test("failed empty grant clears queued SELL without selling a future agent token",function()
        local f=fixture(1,{money=0,agents=true});f.dropAgent=1;f:tick(1.1)
        f.terminal.send.Activated:Fire();assert(f.terminal.sendRequested)
        f:tick(3.1);assert(not f.terminal.agentPending and f.terminal.composer.count==0 and #f.submits==0)
        f:tick(0.02);assert(not f.terminal.sendRequested and f.terminal.composer.count==1)
        f:tick(0.2);assert(#f.submits==0 and f.server.credits==0)
    end)
    test("editing or leaving the CLI cancels a waiting sale without replay on return",function()
        local f=fixture(1,{money=0});f:compose("abc");f.terminal.send.Activated:Fire()
        assert(f.terminal.sendRequested and #f.submits==0)
        f:key("Backspace");f:tick(0.2)
        assert(not f.terminal.sendRequested and f.terminal.composer.count==2 and #f.submits==0)
        f:compose("a");f.terminal.send.Activated:Fire();assert(f.terminal.sendRequested)
        f:guide();f:tick(1);assert(not f.terminal.sendRequested and #f.submits==0)
        f:main();f:tick(0.2);f:snapshot()
        assert(#f.submits==0 and f.terminal.composer.count==3 and f.terminal.send.Active)
        f.terminal.send.Activated:Fire();assert(#f.submits==1 and f.server.credits==3)
    end)
    test("SELL rejects hidden pages and callbacks covered by the header or priority skill UI",function()
        local f=fixture(1,{serverClockStep=0.001});f:buyAgent()
        local money,reward=f.server.credits,f.server.moneyPerToken;f:compose("a")
        f:guide();f.terminal.send.Activated:Fire();assert(#f.submits==0)
        f:main();f.terminal.frame.Position=f.udim2.fromOffset(0,0)
        for _,object in ipairs({f.root.MoneyHUD,f.skill.streakLabel}) do
            f.terminal.send.Activated:Fire(f:pointer(object))
            assert(#f.submits==0 and not f.terminal.sendRequested and f.desk.front==1)
        end
        f.terminal.send.Activated:Fire();f:finishSellWriting()
        assert(#f.submits==1 and f.server.credits==money+reward)
    end)
    test("successive button and Enter prompts pay correctly with a progressing server clock",function()
        local f=fixture(1,{money=0,serverClockStep=0.0001,clientClockOffset=12000})
        for index=1,12 do
            f:tick(0.35);f:compose("a")
            if index%2==0 then f:send() else f.terminal.send.Activated:Fire() end
            f:finishSellWriting()
            assert(f.server.credits==index and not f.server.promptRejected and #f.submits==index)
        end
    end)
    test("consecutive partial and full sales wait for collection before the next context",function()
        local f=fixture(1,{money=0})
        f:compose("a");f.terminal.send.Activated:Fire();f:finishSellWriting()
        assert(#f.submits==1 and f.server.credits==1)
        f:compose("b");f.terminal.input:ReleaseFocus(true);f:finishSellWriting()
        assert(#f.submits==2 and f.server.credits==2)
        f:compose("abcdefgh");assert(#f.submits==2);f.terminal.send.Activated:Fire()
        assert(#f.submits==3 and f.server.credits==10 and not f.server.promptRejected)
        f:compose("abcdefgh");assert(#f.submits==3);f.terminal.input:ReleaseFocus(true)
        assert(#f.submits==3 and f.terminal.composer.count==0)
        f:finishCollection();f:compose("abcdefgh");f.terminal.input:ReleaseFocus(true);f:finishSellWriting()
        assert(#f.submits==4 and f.server.credits==18 and not f.terminal.sendRequested)
        f:tick(0.01)
        assert(#f.submits==4 and f.server.credits==18)
    end)
    test("pixel words reveal letters rapidly inside fixed token pieces without generating money",function()
        local f=fixture(9890,{money=0});f:compose("a")
        local word=f.terminal.tokenWords[1];local piece=f.terminal.tokens[1]
        local width=piece.Size.X.Offset
        assert(word.FontFace.Family=="PressStart2P" and word.Text=="build" and word.MaxVisibleGraphemes==0)
        f:tick(0.02)
        assert(word.MaxVisibleGraphemes>0 and word.MaxVisibleGraphemes<#word.Text)
        assert(piece.Size.X.Offset==width and f.server.credits==0 and #f.submits==0)
        f:tick(0.08);assert(word.MaxVisibleGraphemes==-1 and not next(f.terminal.reveals))
        assert(piece:GetAttribute("Multiplier")==10 and piece.Multiplier.Text=="x10")
    end)
    test("letter reveal pauses off-page and reduced motion immediately reveals full words",function()
        local f=fixture();f:compose("a");f:tick(0.01)
        local word=f.terminal.tokenWords[1];local visible=word.MaxVisibleGraphemes
        f:guide();f:tick(1);assert(word.MaxVisibleGraphemes==visible)
        f:main();f:tick(0.01);assert(word.MaxVisibleGraphemes>visible and word.MaxVisibleGraphemes<5)
        f.terminal:setReducedMotion(true)
        assert(word.MaxVisibleGraphemes==-1 and not next(f.terminal.reveals))
        f:tick(0.3);f:compose("a")
        assert(f.terminal.tokenWords[2].MaxVisibleGraphemes==-1 and not next(f.terminal.reveals))
    end)
    test("Backspace pooled labels and queued SELL finish letters before payout",function()
        local f=fixture(1,{money=0});f:compose("a");f:tick(0.01)
        f:press("Backspace",true)
        assert(f.terminal.composer.count==0 and not next(f.terminal.reveals))
        f:tick(0.3);f:compose("a")
        assert(f.terminal.tokenWords[1].MaxVisibleGraphemes==0)
        f.terminal.send.Activated:Fire()
        assert(f.terminal.sendRequested and f.server.credits==0 and #f.submits==0)
        f:finishSellWriting()
        assert(f.server.credits==1 and #f.submits==1 and not next(f.terminal.reveals))
        assert(f.terminal.tokenWords[1].MaxVisibleGraphemes==-1)
        f:tick(0.4);f:compose("a");assert(f.terminal.tokenWords[1].Text=="a")
        f:send();assert(f.server.credits==2 and #f.submits==2)
    end)
    test("two words per second show complete manual and agent words even below high TPC",function()
        local client=fixture(1,{agents=true});local callback=client.terminal.onAgent;client.terminal.onAgent=nil
        client:shop();client:restoreLegacyUpgrade("upgrade_click");client:main()
        assert(client.terminal.wordsPerClick==2 and client.server.totalAgentWordsPerSecond==2)
        client:compose("a")
        assert(client.terminal.tokenWords[1].MaxVisibleGraphemes==-1 and not next(client.terminal.reveals))
        local money=client.server.credits
        client.terminal.onAgent=callback;client:tick(1)
        assert(client.terminal.composer.count==2 and client.server.lastAgent.wordCount==1)
        assert(client.terminal.tokenWords[2].MaxVisibleGraphemes==-1 and not next(client.terminal.reveals))
        assert(client.server.credits==money and not next(client.terminal.agentRevealTimes))
    end)
    test("combined agent output finishes current letters off-page and only slow new words animate",function()
        local client=fixture(1,{agents=true,studio=true});client.terminal.onAgent=nil
        client:compose("a");assert(client.terminal.tokenWords[1].MaxVisibleGraphemes==0)
        client:shop();client:buyAgent()
        assert(client.server.agentWordsPerSecond==1 and client.server.totalAgentWordsPerSecond==2)
        assert(client.terminal.tokenWords[1].MaxVisibleGraphemes==-1 and not next(client.terminal.reveals))
        client:main();client:compose("a")
        assert(client.terminal.tokenWords[2].MaxVisibleGraphemes==-1)
        client:shop();client:tune("agentInterval",2);client:main();client:compose("a")
        assert(client.server.totalAgentWordsPerSecond==1 and client.terminal.tokenWords[3].MaxVisibleGraphemes==0)
        assert(client.terminal.tokenWords[1].MaxVisibleGraphemes==-1 and client.terminal.tokenWords[2].MaxVisibleGraphemes==-1)
    end)
    test("instant mode uses actual output instead of typing cap and overrides Studio letter speed",function()
        local client=fixture(1,{agents=true,studio=true});client.terminal.onAgent=nil
        client:shop();client:tune("agentRate",8);client:tune("revealScale",0.25);client:main()
        client:compose("a")
        assert(client.terminal.speed==8 and client.server.totalAgentWordsPerSecond==1)
        assert(client.terminal.tokenWords[1].MaxVisibleGraphemes==0 and next(client.terminal.reveals))
        client:shop();client:restoreLegacyUpgrade("upgrade_click");client:main();client:compose("a")
        assert(client.server.totalAgentWordsPerSecond==2 and not next(client.terminal.reveals))
        for index=1,2 do assert(client.terminal.tokenWords[index].MaxVisibleGraphemes==-1) end
    end)
    local function highTpcFixture(agents,studio,money)
        local client=fixture(1,{agents=agents,studio=studio,money=money})
        client.savedAgentCallback=client.terminal.onAgent;client.terminal.onAgent=nil
        client:shop()
        for _=1,3 do
            client:restoreLegacyUpgrade("upgrade_click");client:restoreLegacyUpgrade("upgrade_divisor");client:buyUpgrade("upgrade_tokens")
        end
        client:main()
        return client
    end
    test("high TPC changes future agent output without creating manual tokens or a sale",function()
        local client=highTpcFixture(false)
        client:hit("Great");assert(client.terminal.wordsPerClick==4 and client.terminal.composer.count==0)
        client:hit("Great");assert(client.terminal.wordsPerClick==8 and client.terminal.composer.count==0)
        assert(not next(client.terminal.reveals) and not next(client.terminal.agentRevealTimes))
        assert(#client.server.skillCheck.awards==0 and client.server.skillCheck.lastClick.wordCount==0)
        client:send();assert(#client.submits==0)
    end)
    test("high TPC agent batches bypass cosmetic letter deadlines without changing production budget",function()
        local client=highTpcFixture(true)
        client:hit("Great");client:hit("Great")
        local before=client.server.credits
        client.terminal.onAgent=client.savedAgentCallback
        client:tick(1)
        assert(client.server.lastAgent.wordCount==1 and client.terminal.composer.count==1)
        assert(not next(client.terminal.reveals) and not next(client.terminal.agentRevealTimes))
        for index=1,1 do assert(client.terminal.tokenWords[index].MaxVisibleGraphemes==-1) end
        assert(client.server.credits==before and client.server.agentTypingSpeed==4)
        client:tick(0.1);assert(client.terminal.composer.count==1)
    end)
    test("eight words per second appear individually every eighth second even with high TPC instant text",function()
        local client=highTpcFixture(true,true)
        client:tune("agentRate",8);client:tune("agentJitter",0);client:tune("streakTimeout",0)
        client:hit("Great");client:hit("Great")
        assert(client.server.agentWordsPerSecond==8 and client.terminal.wordsPerClick==8)
        local before=client.terminal.composer.count;local money=client.server.credits
        local appearances={};local previous=before
        client.terminal.onAgent=client.savedAgentCallback
        client:tick(0.005)
        before=client.terminal.composer.count;previous=before
        for _=1,200 do
            client:tick(0.005)
            local count=client.terminal.composer.count
            if count~=previous then
                assert(count==previous+1 and client.server.lastAgent.wordCount==1,"Unexpected word batch: "..tostring(count-previous))
                assert(client.terminal.tokenWords[count].MaxVisibleGraphemes==-1)
                appearances[#appearances+1]=client.now;previous=count
            end
        end
        assert(#appearances==8 and client.terminal.composer.count==before+8,"Unexpected appearances: "..tostring(#appearances))
        for index=2,#appearances do
            assert(math.abs(appearances[index]-appearances[index-1]-0.125)<0.006,"Unexpected word gap: "..tostring(appearances[index]-appearances[index-1]))
        end
        assert(client.server.credits==money and not next(client.terminal.agentRevealTimes))
        local packets=0
        for _,request in ipairs(client.requests) do if request.action=="agent_type" then packets=packets+1 end end
        assert(packets<=20)
    end)
    test("agents keep different word phases with bounded variation and no replay burst after focus pause",function()
        local client=highTpcFixture(true,true)
        client:tune("agentRate",8);client:tune("streakTimeout",0)
        client:shop();client:buyAgent();client:main();client:hit("Great");client:hit("Great")
        local events={{},{}}
        local append=client.terminal.appendAgentWords
        client.terminal.appendAgentWords=function(terminal,result)
            for _,source in ipairs(result.sources) do
                assert(source.wordCount==1)
                events[source.agentIndex][#events[source.agentIndex]+1]=client.now
            end
            return append(terminal,result)
        end
        client.terminal.onAgent=client.savedAgentCallback
        for _=1,100 do client:tick(0.005) end
        assert(#events[1]>=3 and #events[2]>=3)
        local different=false
        for index=2,math.min(#events[1],#events[2]) do if events[1][index]~=events[2][index] then different=true end end
        assert(different and client.server.totalAgentWordsPerSecond==16)
        local count=client.terminal.composer.count;local requests=#client.requests
        client.input.WindowFocusReleased:Fire();client:tick(30)
        assert(#client.requests==requests and client.terminal.composer.count==count)
        client.input.WindowFocused:Fire();client:tick(0.005)
        assert(client.terminal.composer.count<=count+2)
        client:tick(0.01);assert(client.terminal.composer.count<=count+2)
    end)
    test("dropping below high TPC animates only new words and reduced motion still completes them",function()
        local client=highTpcFixture(false)
        client:hit("Great");client:hit("Great")
        client:compose("a");assert(client.terminal.tokenWords[1].MaxVisibleGraphemes==-1)
        client:hit("Normal");client:compose("b")
        assert(client.terminal.wordsPerClick==4 and client.terminal.composer.count==2)
        assert(client.terminal.tokenWords[1].MaxVisibleGraphemes==-1 and client.terminal.tokenWords[2].MaxVisibleGraphemes==0)
        client.terminal:setReducedMotion(true)
        assert(not next(client.terminal.reveals) and client.terminal.tokenWords[2].MaxVisibleGraphemes==-1)
    end)
    local function center(f)
        local button=f.skill.button;local p,s=button.AbsolutePosition,button.AbsoluteSize
        return {UserInputType=f.enum.UserInputType.MouseButton1,Position={X=p.X+s.X/2,Y=p.Y+s.Y/2}}
    end
    test("stationary physical presses work over processed UI without duplicate release activations",function()
        local f=fixture();f:shop();f:buyUpgrade("upgrade_tokens");f:main();f:event()
        local pointer=center(f);local requests=0
        for _=1,6 do
            local before=f.skill.check.id
            f.input.InputBegan:Fire(pointer,true) -- Reuse the same pointer/position; no movement event.
            requests=requests+1
            local count=f.terminal.composer.count
            assert(f.skill.check.id>before and count==0 and not f.skill.pending and f.skill.button.Active)
            f.input.InputEnded:Fire(pointer,true)
            f.skill.button.Activated:Fire(center(f)) -- Native release may carry a different object.
            assert(f.terminal.composer.count==count)
            f:tick(0.03)
        end
        local actual=0;for _,request in ipairs(f.requests) do if request.action=="skill_click" then actual=actual+1 end end
        assert(actual==requests and f.floatingWords.emitted==6)
    end)
    test("pending acknowledgements do not disable the hit target or turn held release into another click",function()
        local f=fixture();f:aim("Great");local pointer=center(f)
        f.autoAck=false;f.input.InputBegan:Fire(pointer,true)
        assert(f.skill.pending and f.skill.button.Active and not f.skill.button:GetAttribute("Ready"))
        local requests=#f.requests;f:tick(0.05)
        assert(#f.requests==requests) -- Holding never repeats.
        f:ack();local count=f.terminal.composer.count
        f.input.InputEnded:Fire(pointer,true);f.skill.button.Activated:Fire(center(f))
        assert(f.terminal.composer.count==count)
        local id=f.skill.check.id
        f.input.InputBegan:Fire(pointer,true)
        assert(f.terminal.composer.count==count and not f.skill.pending and f.skill.check.id==id+1)
    end)
    test("priority skill surface beats overlapping windows and avatars and disconnects pointer capture",function()
        local f=fixture();f:event();local skillGui=f.skill.layer.Parent.Parent
        assert(skillGui.DisplayOrder>f.dancers.layer.Parent.DisplayOrder and skillGui.DisplayOrder>f.root.Parent.DisplayOrder)
        f.terminal.frame.Position=f.udim2.fromOffset(0,0);f.terminal.frame.Size=f.udim2.fromOffset(1280,720)
        local pointer=center(f)
        f.terminal.bar.InputBegan:Fire(pointer);assert(not f.desk.drag)
        f.input.InputBegan:Fire(pointer,true);assert(f.terminal.composer.count==0 and f.server.skillCheck.lastClick.wordCount==0 and f.floatingWords.emitted==1)
        f.root.Size=f.udim2.fromOffset(360,640)
        assert(f.skill.layer.Parent.AbsoluteSize.X==shared.Agent.workstationLayout(360,640,f.desk.count).viewportWidth and f.skill.layer.Parent.AbsoluteSize.Y==640)
        f:guide();local count=f.terminal.composer.count
        f.input.InputBegan:Fire(center(f),true);assert(f.terminal.composer.count==count)
        f:main();f.gui.MenuIsOpen=true
        f.input.InputBegan:Fire(center(f),true);assert(f.terminal.composer.count==count)
        f.gui.MenuIsOpen=false;f.desk.drag={index=1}
        f.input.InputBegan:Fire(center(f),true);assert(f.terminal.composer.count==count)
        f.desk.drag=nil;f.input.textBox={}
        f.input.InputBegan:Fire(center(f),true);assert(f.terminal.composer.count==count)
        f.input.textBox=nil;f.root.Parent:Destroy()
        local requests=#f.requests;f.input.InputBegan:Fire(center(f),true)
        assert(#f.requests==requests and f.skill.destroyed and not f.skill.pointerConnection.Connected)
    end)
    test("great mouse check builds confirmed streak without writing a word or paying money",function()
        local f=fixture(1,{money=0,serverClockStep=0.001,clientClockOffset=5000})
        f:hit("Great")
        assert(f.terminal.composer.count==0 and f.server.credits==0 and #f.submits==0)
        assert(f.server.stats.streak==1 and #f.server.skillCheck.awards==0)
        f:send();assert(#f.submits==0 and f.server.credits==0)
        f:snapshot();assert(f.skill.streak==1 and f.terminal.composer.count==0)
    end)
    test("good touch check changes streak without granting a rare token or sale",function()
        local f=fixture(9890,{money=0});f:hit("Good",true)
        assert(f.skill.streak==1 and f.server.skillCheck.lastClick.grade=="Good")
        assert(f.terminal.composer.count==0 and #f.server.skillCheck.awards==0)
        f.terminal.send.Activated:Fire();assert(f.server.credits==0 and #f.submits==0)
    end)
    test("normal check breaks streak without writing a token or paying income",function()
        local f=fixture(1,{money=0});f:hit("Great");f:hit("Normal")
        assert(f.terminal.composer.count==0 and f.skill.streak==0 and f.server.stats.bestStreak==1)
        f:tick(20);f:send();assert(f.server.credits==0 and #f.submits==0)
    end)
    test("WASD raw text and circle corners cannot generate words",function()
        local f=fixture();f:event()
        for _,key in ipairs({"W","A","S","D","Space"}) do f:key(key) end
        f:rawText("pasted WASD");f.terminal.input:ReleaseFocus()
        local p=f.skill.button.AbsolutePosition
        f.skill.button.Activated:Fire({UserInputType=f.enum.UserInputType.MouseButton1,Position={X=p.X,Y=p.Y}})
        f.skill.button.Activated:Fire({UserInputType=f.enum.UserInputType.Keyboard,Position=p})
        assert(f.terminal.composer.count==0 and not f.skill.pending and f.server.credits==1000000)
    end)
    test("early and duplicate timing nonces cannot repeat streak or create awards",function()
        local f=fixture(1,{money=0})
        f.skill.button.Activated:Fire(center(f));assert(f.terminal.composer.count==0)
        f:hit("Great");local payload
        for _,request in ipairs(f.requests) do if request.action=="skill_click" then payload=request.payload end end
        f.command:FireServer("skill_click",payload)
        assert(f.terminal.composer.count==0 and #f.server.skillCheck.awards==0 and f.server.stats.streak==1)
        f:send();assert(f.server.credits==0 and #f.submits==0)
    end)
    test("skill click eligibility excludes pages chat menus modifiers and app blur",function()
        local f=fixture();f:event();local id=f.skill.check.id
        local function blocked()
            f:tick(1);f.skill.button.Activated:Fire(center(f))
            assert(f.terminal.composer.count==0 and not f.skill.pending)
        end
        f:guide();blocked();assert(not f.skill.layer.Visible);f:main()
        f:button(f.root.DesktopDock,"Guide").Activated:Fire();blocked();f:main()
        f.input.textBox={};blocked();f.input.textBox=nil
        f.gui.MenuIsOpen=true;blocked();f.gui.MenuIsOpen=false
        f.input.held[f.enum.KeyCode.LeftControl]=true;blocked();f.input.held={}
        f.input.WindowFocusReleased:Fire();blocked();f.input.WindowFocused:Fire()
        assert(f.skill.check.id==id)
        f:hit("Great");assert(f.terminal.composer.count==0 and f.skill.streak==1)
    end)
    test("full agent context waits for SELL and subsequent checks cannot repeat payout",function()
        local f=fixture(1,{money=0});f:fillContext()
        assert(#f.submits==0 and f.server.credits==0)
        f:hit("Normal");assert(f.terminal.composer.count==8 and #f.submits==0)
        f.terminal.send.Activated:Fire();f:finishSellWriting()
        assert(#f.submits==1 and f.server.credits==8 and f.terminal.composer.count==0)
        f:hit("Great");f:send();f:snapshot()
        assert(#f.submits==1 and f.server.credits==8 and f.terminal.composer.count==0)
    end)
    test("explicit full prompt sale timeout syncs without automatic retry and late receipt pays once",function()
        local f=fixture(1,{money=0});f.autoAck=false;f:compose(string.rep("a",8));assert(#f.submits==0);f:send()
        for _=1,50 do f:tick(0.05) end
        assert(#f.submits==1 and f.terminal.composer.flight)
        f:tick(20);f:tick(20);assert(#f.submits==1)
        f:ack();f:tick(1)
        assert(#f.submits==1 and f.server.credits==8 and f.terminal.composer.count==0)
    end)
    test("pending skill confirmation queues an empty sale then clears without payout",function()
        local f=fixture(1,{money=0});f.autoAck=false;f:hit("Great")
        assert(f.skill.pending and f.terminal.skillPending and f.terminal.composer.count==0)
        f:send();f.terminal.send.Activated:Fire();assert(#f.submits==0)
        f:ack();assert(not f.skill.pending and not f.terminal.skillPending and f.terminal.composer.count==0)
        f:send();assert(f.server.credits==0 and #f.submits==0)
    end)
    test("lost acknowledgement syncs streak without replay or late token creation",function()
        local f=fixture(1,{money=0});f.autoAck=false;f:hit("Good")
        local clickRequests=0
        for _,request in ipairs(f.requests) do if request.action=="skill_click" then clickRequests=clickRequests+1 end end
        f:tick(3.1);f:ack()
        assert(f.terminal.composer.count==0 and f.skill.streak==1 and not f.skill.pending)
        local count=0
        for _,request in ipairs(f.requests) do if request.action=="skill_click" then count=count+1 end end
        assert(count==clickRequests and #f.submits==0)
        f:send();assert(f.server.credits==0 and #f.submits==0)
    end)
    test("server rejects forged grades multipliers times and indexes without any money",function()
        local f=fixture(1,{money=0});f:event();local check=f.skill.check
        for _,field in ipairs({"grade","multiplier","time","angle","amount","streak","streakMultiplier"}) do
            local payload={draftId=check.draftId,checkId=check.id,tokenIndex=1};payload[field]=999
            f.command:FireServer("skill_click",payload)
        end
        assert(f.terminal.composer.count==0 and f.server.credits==0 and #f.server.skillCheck.awards==0)
        f:hit("Great");f:send();assert(f.server.credits==0 and #f.submits==0 and f.skill.streak==1)
    end)
    test("fixed circle stays above full-screen draggable CLI content on every viewport",function()
        local f=fixture();f:event()
        for _,size in ipairs({{1280,720},{360,640},{640,360}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2]);f:tick(0)
            local p,s=f.skill.button.AbsolutePosition,f.skill.button.AbsoluteSize
            assert(math.abs(p.X+s.X/2-shared.Agent.workstationLayout(size[1],size[2],f.desk.count).viewportWidth/2)<0.001)
            assert(p.Y+s.Y<=size[2]-44 and p.Y>=0)
            local desk=f.desk.parent
            assert(desk.AbsolutePosition.X==0 and desk.AbsolutePosition.Y==0)
            assert(desk.AbsoluteSize.X==size[1] and desk.AbsoluteSize.Y==size[2])
            assert(f.skill.layer.ZIndex>f.root.Pages.ZIndex)
        end
        local pointer=center(f);local front=f.desk.front
        f.terminal.bar.InputBegan:Fire(pointer);f.terminal.bar.Activated:Fire(pointer)
        assert(f.desk.front==front and not f.desk.drag)
        f.gui.ReducedMotionEnabled=true;f:hit("Great");assert(f.terminal.composer.count==0 and f.skill.streak==1)
        f.root.Parent:Destroy();local count=f.terminal.composer.count
        f.skill.button.Activated:Fire(pointer);assert(f.terminal.composer.count==count)
    end)
    test("Main CLI and its agent roster drag to full screen edges while skill and streak reject click-through",function()
        local f=fixture();f:shop();f:buyAgent();f:main()
        for _,index in ipairs({1}) do
            local w=f.desk.windows[index]
            w.frame.Position=f.udim2.fromOffset(0,0);f.desk:focus(index)
            local pointer={UserInputType=f.enum.UserInputType.MouseButton1,Position={X=500,Y=20}}
            w.bar.InputBegan:Fire(pointer)
            assert(f.desk.drag and f.desk.drag.index==index)
            f.input.InputChanged:Fire({UserInputType=f.enum.UserInputType.MouseMovement,Position={X=5000,Y=5000}})
            assert(w.frame.Position.X.Offset+w.frame.AbsoluteSize.X==f.desk.canvasWidth)
            assert(w.frame.Position.Y.Offset+w.frame.AbsoluteSize.Y==f.root.AbsoluteSize.Y)
            f.input.InputChanged:Fire({UserInputType=f.enum.UserInputType.MouseMovement,Position={X=-5000,Y=-5000}})
            assert(w.frame.Position.X.Offset==0 and w.frame.Position.Y.Offset==0)
            f.input.InputEnded:Fire(pointer)
        end
        f.terminal.frame.Position=f.udim2.fromOffset(0,200)
        f.desk:focus(1)
        local pointer=f:pointer(f.skill.streakLabel)
        assert(f.skill:blocksPointer(pointer))
        assert(not f.desk:activate(1,pointer) and f.desk.front==1)
        f:compose("a");f.terminal.send.Activated:Fire(pointer)
        assert(#f.submits==0 and f.skill.streakLabel.Active)
        f:hit("Great");assert(f.terminal.composer.count==1)
    end)
    test("agent upgrades never add manual click cooldown or change streak difficulty",function()
        local f=fixture();f:shop();f:restoreLegacyUpgrade("upgrade_typing");f:main()
        f:hit("Great")
        assert(math.abs(f.skill.check.startsAt-f.now)<0.001 and math.abs(f.skill.check.duration-shared.Skill.difficulty(1))<0.001)
        f:shop();f:restoreLegacyUpgrade("upgrade_typing");f:main();f:hit("Great")
        assert(math.abs(f.skill.check.startsAt-f.now)<0.001 and math.abs(f.skill.check.duration-shared.Skill.difficulty(2))<0.001)
    end)
    test("lost click packet unlocks through correlated read-only sync without replaying the click",function()
        local f=fixture(1,{money=0});f.dropSkill=1;f:hit("Great")
        assert(f.skill.pending and f.terminal.composer.count==0)
        f:tick(3.1)
        assert(not f.skill.pending and not f.terminal.skillPending and f.terminal.composer.count==0)
        local clicks=0;for _,request in ipairs(f.requests) do if request.action=="skill_click" then clicks=clicks+1 end end
        assert(clicks==1 and f.server.credits==0)
        f:hit("Great");f:send();assert(f.server.credits==0 and #f.submits==0 and f.skill.streak==1)
    end)
    test("late check acknowledgement on Store restores streak without hidden words or payment",function()
        local f=fixture(1,{money=0});f.autoAck=false;f:hit("Great");f:guide();f:ack()
        assert(not f.root.StorePanel.Visible and f.terminal.pendingKeys==nil and f.terminal.composer.count==0)
        assert(not f.skill.layer.Visible and f.server.credits==0 and f.skill.streak==1)
        f:main();f:send();assert(#f.submits==0 and f.terminal.composer.count==0)
    end)
    test("an old rejected check cannot cancel a newer pending click",function()
        local f=fixture(1,{money=0});f:hit("Great");local old
        for _,request in ipairs(f.requests) do if request.action=="skill_click" then old=request.payload end end
        f.autoAck=false
        f.command:FireServer("skill_click",old)
        f:hit("Good");f:ack()
        assert(not f.skill.pending and f.terminal.composer.count==0 and f.skill.streak==2)
        f:send();assert(f.server.credits==0 and #f.submits==0)
    end)
    test("repeated ready checks advance nonces without typing cooldown or token generation",function()
        local f=fixture();f:event();local id=f.skill.check.id;local money=f.server.credits
        for _=1,10 do
            f.skill.button.Activated:Fire(center(f))
            assert(not f.skill.pending and f.terminal.composer.count==0)
        end
        assert(f.skill.check.id==id+10 and #f.server.skillCheck.awards==0)
        f:send();assert(f.server.credits==money and #f.submits==0)
    end)
    test("third hit updates circle streak and difficulty without creating a token bonus",function()
        local f=fixture(1,{money=0})
        for _=1,3 do f:hit("Great") end
        assert(f.server.skillCheck.streak==3 and f.skill.streakLabel.Text=="3x" and f.skill.tpcLabel.Text=="1")
        assert(f.terminal.composer.count==0 and #f.server.skillCheck.awards==0)
        assert(f.server.skillCheck.lastClick.multiplier==2.5 and f.server.credits==0)
        assert(math.abs(f.skill.check.duration-shared.Skill.difficulty(3))<0.001 and f.skill.check.goodWidth<72)
        assert(f.server.stats.streak==3 and f.server.stats.streakMultiplier==1.25)
        f:tick(1.1);assert(not f.skill.status and f.skill.streakShadow.Text=="3x")
        f:send();assert(f.server.credits==0 and #f.submits==0 and f.server.skillCheck.streak==3)
    end)
    test("miss resets live difficulty and keeps best streak without token rewards",function()
        local f=fixture(1,{money=0})
        for _=1,5 do f:hit("Great") end
        assert(f.server.stats.streak==5 and f.skill.streakMultiplier==1.5)
        f:hit("Normal")
        assert(f.server.stats.streak==0 and f.server.stats.bestStreak==5)
        assert(math.abs(f.skill.check.duration-shared.Skill.DURATION)<0.00001 and f.skill.check.goodWidth==72)
        assert(f.server.skillCheck.lastClick.streakBroken and f.terminal.composer.count==0)
        f:send();assert(f.server.credits==0 and #f.submits==0)
    end)
    test("streak persists across Send Store context upgrades Guide and sync within inactivity limit",function()
        local f=fixture()
        for _=1,3 do f:hit("Great") end
        f:compose("a");f:send();local id=f.skill.check.id
        f:shop();f:buyUpgrade("upgrade_tokens")
        f:button(f.root.DesktopDock,"Guide").Activated:Fire();f:tick(3);f:snapshot()
        assert(f.server.skillCheck.streak==3 and f.skill.check.id==id and f.skill.streakMultiplier==1.25)
        f:main();f:hit("Good")
        assert(f.server.skillCheck.streak==4 and f.terminal.composer.count==0 and #f.server.skillCheck.awards==0)
    end)
    test("late third-hit acknowledgement and duplicate snapshots cannot increment the streak twice",function()
        local f=fixture(1,{money=0});f:hit("Great");f:hit("Great")
        f.autoAck=false;f:hit("Great");f:tick(3.1);f:ack()
        assert(f.terminal.composer.count==0 and f.server.stats.streak==3 and f.skill.streak==3)
        for _=1,3 do f:snapshot() end
        assert(f.skill.streak==3 and f.terminal.composer.count==0)
        f:send();assert(f.server.credits==0 and #f.submits==0)
    end)
    test("long streak progressively shrinks colored arcs speeds needle and caps difficulty and payout factor",function()
        local f=highStreakFixture();f:shop()
        for _=1,15 do f:buyUpgrade("upgrade_tokens") end
        f:main();local money=f.server.credits
        local function colored()
            local count=0
            for _,segment in ipairs(f.skill.segments) do if segment.BackgroundColor3[1]~=80 then count=count+1 end end
            return count
        end
        local initial=colored();local expected=0
        for index=1,45 do
            f:hit("Great");expected=expected+f.terminal.composer.count*2*shared.Skill.streakFactor(index)
            assert(f.server.skillCheck.lastClick.multiplier==2*shared.Skill.streakFactor(index) and f.terminal.composer.count==0)
            f:send()
        end
        assert(f.skill.streak==45 and f.skill.streakMultiplier==4 and colored()<initial)
        assert(math.abs(f.skill.check.duration-0.55)<0.001 and f.skill.check.goodWidth==28 and f.skill.check.greatWidth==8)
        assert(f.server.credits==money+expected)
        f:send();assert(f.server.credits==money+expected and f.server.stats.bestStreak==45)
    end)
    test("Backspace edits tokens while timing checks independently build and break streak",function()
        local f=fixture(1,{money=0});f:compose("abc")
        for _=1,3 do f:hit("Great") end
        f:key("Backspace");assert(f.terminal.composer.count==2)
        f:hit("Great");assert(f.skill.streak==4 and f.terminal.composer.count==2)
        f:hit("Normal");assert(f.skill.streak==0 and f.server.stats.bestStreak==4)
        f:send();assert(f.server.credits==2)
    end)
    test("agent mascots are independent transparent passive objects with the same catalog artwork",function()
        local f=fixture();local main=f.terminal.mascot
        assert(main.id=="ember" and main.frame:GetAttribute("MascotId")=="ember")
        assert(main.frame.Parent==f.desk.agents[1].frame and main.frame.BackgroundTransparency==1)
        f:shop();f:buyAgent();f:main()
        local second=f.desk.agents[2].mascot
        assert(main~=second and main.parts[1]~=second.parts[1] and second.id=="ember")
        assert(#second.parts==#f.mascotCatalog.ember.parts and #second.parts==11)
        for _,part in ipairs(second.parts) do
            assert(part.ClassName=="Frame" and not part.Active and not part.Selectable)
            assert(not part.Image and part.BackgroundColor3[1]==216)
        end
        assert(not second.frame.Active and not f.desk.windows[shared.Balance.MAX_HIDDEN_LAYERS+1])
    end)
    test("mascot swap changes geometry reuses objects and survives snapshots purchases and resize",function()
        local f=fixture();f:shop();f:buyAgent()
        f.mascotCatalog.test={name="Test",width=1,height=1,color={1,2,3},parts={{0,0,1,1}}}
        local mascot=f.desk.agents[2].mascot;local first=mascot.parts[1]
        local money,requests=f.server.credits,#f.requests
        assert(f.desk:setAgentMascot(2,"test") and mascot.id=="test")
        assert(mascot.parts[1]==first and first.BackgroundColor3[1]==1)
        assert(first.Size.X.Scale==1 and mascot.canvas.Size.X.Scale==0.625 and mascot.canvas.Size.Y.Scale==1)
        for index=2,#mascot.parts do assert(not mascot.parts[index].Visible) end
        assert(not f.desk:setAgentMascot(2,"missing") and mascot.id=="test")
        assert(not f.desk:setAgentMascot(shared.Balance.MAX_HIDDEN_LAYERS+1,"ember"))
        assert(f.server.credits==money and #f.requests==requests)
        f:snapshot();f:buyAgent();f.root.Size=f.udim2.fromOffset(360,640)
        assert(mascot.id=="test" and f.desk.agents[3].mascot.id=="ember")
        assert(f.desk:setAgentMascot(1,"test") and f.terminal.mascot.id=="test")
        assert(f.desk:setAgentMascot(2,"ember") and mascot.parts[1]==first)
        assert(mascot.aspect.AspectRatio==1.6 and mascot.parts[11].Visible)
    end)
    test("all eight roster avatars wrap inside Main CLI without covering context at any target viewport",function()
        local f=fixture(1,{money=1000000000});for _=2,8 do f:buyAgent() end
        for _=1,15 do f:buyUpgrade("upgrade_tokens") end
        f:compose(string.rep("a",64));assert(f.terminal.composer.count==64 and #f.submits==0)
        for _,size in ipairs({{1280,720},{1920,1080},{360,640},{640,360},{320,360}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2])
            local roster=f.desk.roster;local bounds={}
            assert(f.terminal.frame.AbsolutePosition.Y>=f.root.FeatureDock.AbsolutePosition.Y+f.root.FeatureDock.AbsoluteSize.Y)
            assert(roster.AbsolutePosition.Y>=f.terminal.bar.AbsolutePosition.Y+40)
            assert(roster.AbsolutePosition.Y+roster.AbsoluteSize.Y<=f.terminal.panel.AbsolutePosition.Y)
            for index,agent in ipairs(f.desk.agents) do
                local slot,mascot=agent.frame,agent.mascot.frame
                local p,dimensions=slot.Position,slot.AbsoluteSize
                assert(slot.Visible and p.X.Offset>=0 and p.X.Offset+dimensions.X<=roster.AbsoluteSize.X)
                assert(p.Y.Offset>=0 and p.Y.Offset+dimensions.Y<=roster.AbsoluteSize.Y)
                assert(mascot.AbsoluteSize.X==48 and mascot.AbsoluteSize.Y==30)
                assert(mascot.Position.Y.Offset+30<=agent.label.Position.Y.Offset and not agent.label.Active)
                for _,other in ipairs(bounds) do
                    assert(p.X.Offset>=other.x+other.w or p.X.Offset+dimensions.X<=other.x
                        or p.Y.Offset>=other.y+other.h or p.Y.Offset+dimensions.Y<=other.y)
                end
                bounds[#bounds+1]={x=p.X.Offset,y=p.Y.Offset,w=dimensions.X,h=dimensions.Y}
            end
            assert(f.terminal.frame.AbsoluteSize.X==shared.Agent.workstationLayout(size[1],size[2],8).windows[1].width)
        end
        f.root.Parent:Destroy();assert(f.terminal.mascot.destroyed and f.desk.agents[2].mascot.destroyed)
    end)
    test("confirmed streak animates main and purchased mascots inside stable passive slots",function()
        local f=fixture();local main=f.terminal.mascot
        local position,size=main.frame.Position,main.frame.Size
        assert(main.streak==0 and main.motion.Rotation==0)
        f:hit("Great");f:tick(0.05)
        assert(main.streak==1 and main.phase>0 and main.blend>0 and main.motion.Rotation~=0)
        assert(main.frame.Position==position and main.frame.Size==size and not main.motion.Active)
        f:shop();f:buyAgent();f:main();f:tick(0.05)
        local second=f.desk.agents[2].mascot;local hidden=f.desk.agents[3].mascot
        assert(second.streak==1 and second.blend>0 and second.motion.Rotation~=main.motion.Rotation)
        assert(hidden.phase==0 and hidden.blend==0 and hidden.motion.Rotation==0)
        local requests,money=#f.requests,f.server.credits
        f:tick(0.05);assert(#f.requests==requests and f.server.credits==money)
    end)
    test("higher streak makes dance faster and stronger while a miss immediately restores neutral",function()
        local f=highStreakFixture();f:shop();for _=1,3 do f:buyUpgrade("upgrade_tokens") end;f:main()
        local money=f.server.credits;f:hit("Great");f:tick(0.05)
        local mascot=f.terminal.mascot
        local rate,tilt=mascot.danceParameters.rate,mascot.danceParameters.tilt
        for _=2,10 do f:hit("Great") end
        f:tick(0.05)
        assert(mascot.streak==10 and mascot.danceParameters.rate>rate and mascot.danceParameters.tilt>tilt)
        f:hit("Normal")
        assert(mascot.streak==0 and mascot.phase==0 and mascot.blend==0)
        assert(mascot.motion.Rotation==0 and mascot.motion.Position.X.Scale==0.5 and mascot.motion.Position.Y.Scale==0.5)
        assert(mascot.motion.Size.X.Scale==1 and mascot.motion.Size.Y.Scale==1 and f.server.credits==money)
    end)
    test("OS and Guide reduced motion immediately stop dance without losing the server streak",function()
        local f=fixture();f:hit("Great");f:tick(0.08)
        local mascot=f.terminal.mascot;local phase=mascot.phase
        assert(mascot.blend>0)
        f.gui.ReducedMotionEnabled=true
        assert(mascot.blend==0 and mascot.motion.Rotation==0)
        f:tick(1);assert(mascot.phase==phase and mascot.streak==1)
        f.gui.ReducedMotionEnabled=false;f:tick(0.05);assert(mascot.blend>0)
        f:button(f.root.DesktopDock,"Guide").Activated:Fire()
        f:button(f.root.Pages.GuidePage,"[ ] Reduced motion").Activated:Fire()
        f:main();f:tick(0.1)
        assert(mascot.blend==0 and mascot.motion.Rotation==0 and f.server.stats.streak==1)
    end)
    test("dance pauses across pages chat menus focus and survives mascot swap then tears down",function()
        local f=fixture();f:hit("Great");f:tick(0.05)
        local mascot=f.terminal.mascot
        local function paused()
            local phase=mascot.phase;f:tick(1)
            assert(mascot.phase==phase and mascot.blend==0 and mascot.motion.Rotation==0)
        end
        f:guide();paused();f:main();f:tick(0.05)
        f.input.textBox={};paused();f.input.textBox=nil;f:tick(0.05)
        f.gui.MenuIsOpen=true;paused();f.gui.MenuIsOpen=false;f:tick(0.05)
        f.input.WindowFocusReleased:Fire();paused();f.input.WindowFocused:Fire();f:tick(0.05)
        f.mascotCatalog.square={name="Square",width=1,height=1,color={1,2,3},parts={{0,0,1,1}}}
        local motion=mascot.motion;local phase=mascot.phase
        assert(f.desk:setAgentMascot(1,"square") and mascot.motion==motion and mascot.phase==phase)
        f.root.Size=f.udim2.fromOffset(360,640);f:tick(0.05)
        assert(mascot.id=="square" and mascot.streak==1 and mascot.blend>0 and mascot.frame.ClipsDescendants)
        f.root.Parent:Destroy();phase=mascot.phase;f:tick(0.1)
        assert(mascot.destroyed and mascot.phase==phase)
    end)
    test("continuous needle retains angle at a hit and rotates while acknowledgement is pending",function()
        local f=fixture();f:aim("Great")
        local check=f.skill.check;local before=shared.Skill.phase(check,f.now)
        f:hit("Great")
        local after=shared.Skill.phase(f.skill.check,f.now)
        assert(math.abs((after-before+180)%360-180)<0.00001)
        assert(f.skill.streakLabel.Parent==f.skill.layer)
        assert(f.skill.streakLabel.AbsolutePosition.X>=f.skill.button.AbsolutePosition.X+f.skill.button.AbsoluteSize.X)
        assert(f.skill.streakLabel.AbsoluteSize.Y==f.skill.button.AbsoluteSize.Y)
        f.autoAck=false;f:hit("Great");local angle=f.skill.pivot.Rotation
        f:tick(0.05);assert(f.skill.pending and f.skill.pivot.Rotation~=angle)
        f:ack();assert(not f.skill.pending)
    end)
    test("bottom Studio tools shortcut toggles its own scroll page and keeps shop upgrades separate",function()
        local f=fixture(1,{studio=true});f:compose("abc")
        local draft=f.terminal.composer.draft;local toolsPage=f.root.Pages.StudioToolsPage
        local shortcut=f.root.DesktopDock.StudioToolsShortcut
        assert(shortcut.Visible and shortcut.Text=="Studio tools")
        for _,child in ipairs(f.root.DesktopDock.children) do assert(child.Text~="Store") end
        assert(not f.root.StorePanel.UpgradeList:FindFirstChild("StudioTools"))
        shortcut.Activated:Fire()
        assert(toolsPage.Visible and f.terminal.suspended and not f.skill.layer.Visible and not f.root.StorePanel.Visible)
        local list=toolsPage.ToolList;local tools=list.StudioTools
        assert(tools:GetAttribute("Expanded") and tools.grant.Visible and list.CanvasSize.Y.Offset>list.AbsoluteSize.Y)
        f:tick(0.2);tools.grant.Activated:Fire();assert(f.server.credits>1000000)
        local money=f.server.credits
        list.CanvasPosition=f.vec2.new(0,160)
        f:main()
        assert(not toolsPage.Visible and not f.terminal.suspended and f.terminal.composer.draft==draft and f.terminal.composer.count==3)
        tools.grant.Activated:Fire();assert(f.server.credits==money)
        shortcut.Activated:Fire();assert(list.CanvasPosition.Y==160)
        for _,size in ipairs({{320,360},{360,640},{640,360},{1280,720}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2])
            assert(shortcut.AbsoluteSize.Y==40 and shortcut.AbsolutePosition.X>=0)
            assert(shortcut.AbsolutePosition.X+shortcut.AbsoluteSize.X<=size[1])
            assert(toolsPage.AbsolutePosition.Y+toolsPage.AbsoluteSize.Y<=size[2]-8)
        end
        local row=tools.tune_agentRate
        f.gui.MenuIsOpen=true;row.Activated:Fire();assert(f.server.credits==money)
        f.gui.MenuIsOpen=false;f.input.WindowFocusReleased:Fire();tools.grant.Activated:Fire();assert(f.server.credits==money)
    end)
    test("Studio spin controls change authoritative settings without money or streak changes",function()
        local f=fixture(1,{studio=true});f:shop()
        f:button(f.root.DesktopDock,"Studio tools").Activated:Fire()
        local tools=f.root.Pages.StudioToolsPage.ToolList.StudioTools
        local initial,growth
        for _,control in ipairs(tools.children) do
            if control.ClassName=="TextButton" and control.Text:find("Initial spin",1,true) then initial=control end
            if control.ClassName=="TextButton" and control.Text:find("Per hit",1,true) then growth=control end
        end
        assert(initial and growth and initial.Visible and growth.Visible)
        local money=f.server.credits
        f:tick(0.4);initial.Activated:Fire();assert(f.server.skillCheck.initialRps==0.75)
        f:tick(0.4);growth.Activated:Fire();assert(f.server.skillCheck.growth==1.065)
        assert(f.server.credits==money and f.server.stats.streak==0)
        f:main();f:hit("Great")
        assert(math.abs(f.skill.check.duration-1/0.75/1.065)<0.00001)
    end)
    test("Studio tools expose every tuning row both directions preserve scroll and restore defaults",function()
        local f=fixture(1,{studio=true});f.terminal.onAgent=nil;f:shop()
        f:button(f.root.DesktopDock,"Studio tools").Activated:Fire()
        local list=f.root.Pages.StudioToolsPage.ToolList;local tools=list.StudioTools
        assert(tools.Size.Y.Offset==44+(3+#shared.Tuning.controls)*72)
        list.CanvasPosition=f.vec2.new(0,450)
        for _,control in ipairs(shared.Tuning.controls) do
            local nextButton,previous=tools[control.action],tools[control.action.."_Previous"]
            assert(nextButton.Visible and previous.Visible and nextButton.Text:find(control.label,1,true))
            f:tick(0.15);nextButton.Activated:Fire()
            assert(f.server.studioTuning[control.key]==control.values[2])
            assert(f.terminal.tuning[control.key]==control.values[2])
            f:tick(0.15);previous.Activated:Fire()
            assert(f.server.studioTuning[control.key]==control.values[1])
            assert(list.CanvasPosition.Y==450 and not f.root.StorePanel.Visible)
        end
        f:tune("spawnPercent",100);f:tune("agentRate",44)
        f:tick(0.15);tools.tuning_reset.Activated:Fire()
        for _,control in ipairs(shared.Tuning.controls) do assert(f.server.studioTuning[control.key]==control.values[1]) end
        for _,size in ipairs({{360,640},{640,360},{1280,720}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2])
            for _,control in ipairs(shared.Tuning.controls) do
                local item=tools[control.action];local previous=tools[control.action.."_Previous"]
                assert(item.Position.Y.Offset+44<=tools.Size.Y.Offset)
                assert(item.AbsoluteSize.X+48==tools.AbsoluteSize.X and previous.AbsoluteSize.X==44)
            end
            assert(list.CanvasSize.Y.Offset>tools.Size.Y.Offset)
        end
    end)
    test("Studio spawn cap chance and streak expiry apply without changing old word rewards",function()
        local f=fixture(1,{studio=true,money=0});f.terminal.onAgent=nil
        f:tune("streakTimeout",0);f:tune("spawnPercent",0);f:hit("Great")
        assert(#f.server.streakAvatars.items==0 and f.server.stats.streak==1)
        f:tune("spawnPercent",100);f:tune("spawnCapacity",1);f:hit("Great");f:hit("Great")
        assert(#f.server.streakAvatars.items==0 and f.server.stats.streak==3)
        local award=#f.server.skillCheck.awards
        f:tick(10);assert(f.server.stats.streak==3)
        f:hit("Great");local clicked=f.now
        f:tune("streakTimeout",2)
        f:tick(2-(f.now-clicked));f:snapshot()
        assert(f.server.stats.streak==0 and f.server.stats.bestStreak==4)
        assert(#f.server.skillCheck.awards==award and #f.server.streakAvatars.items==0)
        f.terminal.send.Activated:Fire();assert(#f.submits==0 and f.terminal.composer.count==0)
    end)
    test("Studio click and prompt cooldowns use server timing while preserving phase and single flight",function()
        local f=fixture(1,{studio=true,money=0});f.terminal.onAgent=nil
        f:tune("skillCooldown",0.5);f:hit("Great")
        assert(math.abs(f.server.skillCheck.startsAt-f.now-0.5)<0.000001)
        local count=f.terminal.composer.count;local cap=f.skill.button
        cap.Activated:Fire(f:pointer(cap));assert(f.terminal.composer.count==count)
        local id,target=f.skill.check.id,f.skill.check.target
        f:tune("minDuration",0.4)
        assert(f.skill.check.id==id and f.skill.check.target==target)
        f:tune("promptCooldown",1)
        f:compose("a");f.terminal:setReducedMotion(true);f.terminal.send.Activated:Fire();assert(#f.submits==1)
        f:compose("a");f.terminal.send.Activated:Fire()
        assert(#f.submits==1 and f.terminal.sendRequested and not f.terminal.composer.flight)
        f:tick(0.5);assert(#f.submits==1)
        f:tick(0.5);assert(#f.submits==2 and not f.terminal.composer.flight and not f.server.promptRejected)
    end)
    test("Studio agent cadence and per-agent rate refresh capacity without catchup or direct payout",function()
        local f=fixture(1,{studio=true,agents=true});local callback=f.terminal.onAgent;f.terminal.onAgent=nil
        f:shop();f:buyAgent()
        f:tune("agentInterval",0.25);f:tune("agentRate",16)
        assert(f.server.agentTypingSpeed==16 and f.server.totalAgentTypingSpeed==32)
        assert(f.terminal.speed==16 and f.terminal.totalSpeed==32)
        local money=f.server.credits;f.terminal.onAgent=callback
        f:tick(0.3)
        assert(f.server.lastAgent.wordCount==2 and #f.server.lastAgent.sources==2)
        assert(f.server.nextAgentDelay>0 and f.server.nextAgentDelay<=0.265 and f.terminal.composer.count==2)
        assert(f.server.credits==money)
        f:tick(0.1);assert(f.terminal.composer.count>=2 and f.terminal.composer.count<=4)
    end)
    test("Studio cosmetic durations change existing pools and bounded cleanup without extra rewards",function()
        local f=fixture(1,{studio=true,money=0});f.terminal.onAgent=nil
        f:tune("streakTimeout",0);f:tune("avatarFadeOut",2);f:tune("floatingDuration",3)
        f:tune("cashDuration",0.5);f:tune("jobDuration",0.35);f:tune("revealScale",4)
        f:hit("Great");f:tick(0.2);local avatar=f.dancers.pool[1];avatar:activate({mascotId="ember",sourceAgent=1},false)
        f:hit("Normal");assert(avatar.fading)
        local emitted=f.floatingWords.pool[f.floatingWords.cursor]
        f:tick(1);assert(avatar.active and emitted.active)
        f:tick(1.1);assert(not avatar.active and emitted.active)
        f:compose("a");f.terminal:finishReveals();f.terminal.send.Activated:Fire();local money=f.server.credits
        assert(#f.terminal.cash.items==1 and f.terminal.session.active)
        f:tick(0.4);assert(not f.terminal.session.active and #f.terminal.cash.items==1)
        f:tick(0.2);assert(#f.terminal.cash.items==0 and #f.terminal.collection.batches==0 and f.server.credits==money)
        f:tick(0.5);assert(#f.terminal.cash.items==0 and f.server.credits==money)
        f:tick(0.5);assert(not emitted.active)
    end)
    test("Studio tuning rejects forged values stays isolated and is absent outside Studio",function()
        local f=fixture(1,{studio=true});f.terminal.onAgent=nil
        local dev=f.command.Parent:FindFirstChild("StudioCommand")
        local money=f.server.credits
        for _,args in ipairs({{"tune_spawnPercent",999},{"tune_spawnPercent",{value=100}},
            {"tune_spawnPercent",1,100},{"grant",1},{"tune_unknown"}}) do
            dev:FireServer(table.unpack(args))
        end
        assert(f.server.studioTuning.spawnPercent==30 and f.server.credits==money)
        f:tune("spawnPercent",100);f:tune("agentRate",44)
        local other=fixture(1,{studio=true});assert(other.server.studioTuning.spawnPercent==30 and other.server.agentTypingSpeed==4)
        local published=fixture()
        assert(not published.command.Parent:FindFirstChild("StudioCommand"))
        assert(not published.root.StorePanel.UpgradeList:FindFirstChild("StudioTools"))
        assert(not published.root.Pages:FindFirstChild("StudioToolsPage") and not published.root.DesktopDock.StudioToolsShortcut.Visible)
        assert(not published.server.studioTuning and not published.terminal.tuning)
        assert(shared.Collectibles.SPAWN_PERCENT==30 and shared.Skill.STREAK_TIMEOUT==5 and shared.Balance.AGENT_INTERVAL==1)
    end)
    local function plays(pool)
        local count=0
        for _,voice in ipairs(pool) do count=count+(voice.sound.playCount or 0) end
        return count
    end
    local function silent(pool)
        for _,voice in ipairs(pool) do assert(not voice.note and not voice.sound.Playing) end
    end
    test("lounge score runs steadily across streak hits misses and pages with fixed tempo",function()
        local f=fixture();local a=f.audio;f:tick(1/60)
        assert(#a.musicVoices==16 and #a.effectVoices==6 and #f.preloaded==3)
        assert(plays(a.musicVoices)==5 and shared.Music.BPM==88)
        for _,voice in ipairs(a.musicVoices) do assert(not voice.sound.Looped and voice.sound.SoundGroup==a.musicGroup) end
        for _=1,7 do f:hit("Great") end
        f:hit("Normal");local clock=a.clock;f:shop()
        local before=plays(a.musicVoices)
        for _=1,180 do f:tick(1/60) end
        assert(a.clock==clock and plays(a.musicVoices)>before and shared.Music.BPM==88)
        f:main();f:tick(0.1);assert(a.clock==clock)
    end)
    test("normal clicks and fresh good great hits have distinct effects without snapshot replay",function()
        local f=fixture(1,{money=0});local pool=f.audio.effectVoices
        for _,item in ipairs({{"Normal",1},{"Good",2},{"Great",3}}) do
            f:aim(item[1]);local before=plays(pool);f:hit(item[1])
            assert(plays(pool)-before==item[2])
        end
        local before=plays(pool);f:snapshot();f:snapshot();assert(plays(pool)==before)
        f:key("Backspace");f:hit("Great");assert(plays(pool)==before+3)
        f:event();before=plays(pool)
        f.skill.button.Activated:Fire({UserInputType=f.enum.UserInputType.Keyboard,Position={X=0,Y=0}})
        local p=f.skill.button.AbsolutePosition
        f.skill.button.Activated:Fire({UserInputType=f.enum.UserInputType.MouseButton1,Position={X=p.X,Y=p.Y}})
        assert(plays(pool)==before and f.server.credits==0)
    end)
    test("late skill confirmation sounds once and offpage confirmations do not queue success audio",function()
        local f=fixture();local pool=f.audio.effectVoices
        f.autoAck=false;f:hit("Great");assert(plays(pool)==1 and f.skill.pending)
        local before=plays(pool);f:tick(3.1);f:ack()
        assert(plays(pool)==before+2 and not f.skill.pending)
        before=plays(pool);f:snapshot();assert(plays(pool)==before)
        f.autoAck=false;f:hit("Good");before=plays(pool);f:guide()
        assert(plays(pool)==before+1) -- Explicit navigation has its own UI cue.
        f:ack();assert(plays(pool)==before+1) -- Hidden confirmation stays silent.
        f:main();assert(plays(pool)==before+2)
    end)
    test("Guide music effects and mute controls work independently and preserve gameplay",function()
        local f=fixture();local a=f.audio
        f:button(f.root.DesktopDock,"Guide").Activated:Fire()
        local controls=f.root.Pages.GuidePage.Instructions.AudioSettings
        assert(controls.MusicVolume.AbsoluteSize.Y==40 and controls.MuteAudio.AbsoluteSize.Y==40)
        controls.MusicVolume.Activated:Fire();assert(a.musicVolume==0.75 and a.effectsVolume==0.5)
        controls.EffectsVolume.Activated:Fire();assert(a.effectsVolume==0.75)
        controls.MuteAudio.Activated:Fire();assert(a.muted and a.musicGroup.Volume==0 and a.effectsGroup.Volume==0)
        silent(a.musicVoices);silent(a.effectVoices)
        local music,effects=plays(a.musicVoices),plays(a.effectVoices)
        f:main();f:hit("Great");f:compose("a");f:send();f:tick(0.1)
        assert(f.server.stats.prompts==1 and plays(a.musicVoices)==music and plays(a.effectVoices)==effects)
        controls.MuteAudio.Activated:Fire();assert(not a.muted and a.musicGroup.Volume==0.75 and a.effectsGroup.Volume==0.75)
        a:setVolume("music",0);f:tick(0.1);silent(a.musicVoices)
        f:hit("Good");assert(plays(a.effectVoices)>effects and plays(a.musicVoices)==music)
        a:setVolume("effects",0);silent(a.effectVoices)
    end)
    test("menu focus loss and disconnection stop audio without replaying a paused backlog",function()
        local f=fixture();local a=f.audio;f:tick(0.05)
        f.gui.MenuIsOpen=true;f:tick(5);silent(a.musicVoices);silent(a.effectVoices)
        local before=plays(a.musicVoices);f:tick(20);assert(plays(a.musicVoices)==before)
        f.gui.MenuIsOpen=false;f:tick(0.016);assert(plays(a.musicVoices)==before+5 and a.clock.step==0)
        f.input.WindowFocusReleased:Fire();f:tick(1);silent(a.musicVoices)
        f.input.WindowFocused:Fire();f:tick(0.016);assert(a.clock.step==0)
        f.reportVersion="incompatible";f:snapshot();f:tick(1)
        assert(f.terminal.blocked);silent(a.musicVoices);silent(a.effectVoices)
        local offline=fixture(1,{offline=true});offline:tick(1);assert(plays(offline.audio.musicVoices)==0)
    end)
    test("unavailable or failed audio preserves click send money and cleans up with the GUI",function()
        for _,unavailable in ipairs({true,false}) do
            local f=fixture(1,{money=0,audioUnavailable=unavailable})
            if not unavailable then f.failPlay=true;f:tick(0.016) end
            assert(f.audio.disabled and not f.terminal.blocked)
            f:hit("Great");f:compose("a");f:send();assert(f.server.credits==1 and #f.submits==1)
            f.root.Parent:Destroy();assert(f.audio.destroyed)
        end
        local f=fixture();f:tick(0.016)
        local pool=f.audio.musicVoices;local before=plays(pool)
        f.root.Parent:Destroy();f:tick(1)
        assert(f.audio.destroyed and #f.audio.musicVoices==0 and plays(pool)==before)
    end)
    test("red pixel orbit marker preserves one initial revolution per second",function()
        local f=fixture();local dot=f.skill.pivot.OrbitDot
        assert(dot and not f.skill.pivot:FindFirstChild("Needle") and dot.BackgroundColor3[1]==255)
        assert(dot.Position.Y.Scale==0.07 and dot.Size.X.Offset==dot.Size.Y.Offset and not dot.Active)
        assert(f.server.skillCheck.initialRps==1 and f.skill.check.duration==1)
        local angle=f.skill.pivot.Rotation;f:tick(0.1);assert(f.skill.pivot.Rotation~=angle)
    end)
    test("pixel button rebounds on repeated fast stationary mouse and touch presses without duplicate releases",function()
        for _,touch in ipairs({false,true}) do
            local client=fixture();client:shop()
            for _=1,7 do client:buyUpgrade("upgrade_tokens") end
            client:main();client:event()
            local skill=client.skill;local pointer=center(client)
            if touch then pointer.UserInputType=client.enum.UserInputType.Touch end
            local position,size=skill.button.Position,skill.button.Size
            for _=1,32 do
                client.input.InputBegan:Fire(pointer,true)
                assert(skill.pressAge==0 and skill.dial.pressDepth==1 and skill.button.Active)
                assert(skill.button.Position==position and skill.button.Size==size)
                client:tick(0.01)
                local depth=skill.dial.pressDepth
                assert(depth>0 and depth<1)
                client.input.InputEnded:Fire(pointer,true)
                local release=center(client);release.UserInputType=pointer.UserInputType
                skill.button.Activated:Fire(release)
                assert(skill.dial.pressDepth==depth)
                client:tick(0.015)
            end
            local requests=0
            for _,request in ipairs(client.requests) do if request.action=="skill_click" then requests=requests+1 end end
            assert(requests==32 and client.floatingWords.emitted==32)
            client:tick(0.2)
            assert(skill.dial.pressDepth==0 and not skill.pressAge)
            assert(skill.pivot.Rotation==shared.Skill.phase(skill.check,client.now))
        end
    end)
    test("own pending skill and sale flight presses only squash without storing clicks",function()
        local client=fixture();client:event();client.autoAck=false
        local skill=client.skill;local pointer=center(client)
        client.input.InputBegan:Fire(pointer,true)
        assert(skill.pending and skill.dial.pressDepth==1)
        local requests=#client.requests
        for _=1,10 do
            client:tick(0.025);assert(skill.dial.pressDepth<1)
            client.input.InputEnded:Fire(pointer,true)
            client.input.InputBegan:Fire(pointer,true)
            assert(skill.dial.pressDepth==1 and skill.pressAge==0 and #client.requests==requests)
        end
        assert(client.floatingWords.emitted==1 and client.terminal.composer.count==0)
        client:ack();assert(client.terminal.composer.count==0)
        client:tick(0.2);assert(skill.dial.pressDepth==0 and not skill.pressAge)
        client.input.InputEnded:Fire(pointer,true);skill.button.Activated:Fire(center(client))
        assert(#client.requests==requests and client.terminal.composer.count==0)
        client.input.InputBegan:Fire(pointer,true)
        assert(skill.dial.pressDepth==1 and #client.requests==requests+1)
        client:compose("a");client.autoAck=false;client.terminal.send.Activated:Fire();client:finishSellWriting()
        assert(client.terminal.composer.flight)
        local pendingRequests=#client.requests;local money=client.server.credits
        client:tick(0.025);client.input.InputBegan:Fire(pointer,true)
        assert(skill.dial.pressDepth==1 and #client.requests==pendingRequests and not skill.pending)
        assert(client.server.pendingSkillWords==nil)
        assert(client.server.credits==money and #client.submits==1)
        client:ack();client:tick(0.2);assert(skill.dial.pressDepth==0)
    end)
    test("raised pixel button and projected shadow reuse bounded passive integer geometry at every pose and size",function()
        local client=fixture();local dial=client.skill.dial
        local face,shadow=dial.capRows[1].frame,dial.shadowRows[1].frame
        assert(face.BackgroundColor3[1]==205 and face.BackgroundColor3[2]==127)
        for _,diameter in ipairs({84,98,120}) do
            dial:layout(diameter)
            for _,depth in ipairs({0,0.2,0.5,1,0.5,0}) do
                dial:setPress(depth)
                for _,rows in ipairs({dial.capRows,dial.baseRows,dial.shadowRows}) do
                    for _,row in ipairs(rows) do
                        local part=row.frame;local point,size=part.Position,part.Size
                        assert(not part.Active and not part.Selectable)
                        assert(point.X.Offset%1==0 and point.Y.Offset%1==0 and size.X.Offset%1==0 and size.Y.Offset%1==0)
                        assert(size.X.Offset>0 and size.Y.Offset>0 and point.X.Offset>=0 and point.Y.Offset>=0)
                        assert(point.X.Offset+size.X.Offset<=diameter+3 and point.Y.Offset+size.Y.Offset<=diameter+6)
                    end
                end
                assert(dial.capRows[1].frame==face and dial.shadowRows[1].frame==shadow)
                assert(shadow.ZIndex==0 and shadow.BackgroundTransparency==0.15)
            end
        end
        dial:setPress(1);local compressed=dial.capRows[1].frame.Position.Y.Offset
        dial:setPress(0);assert(dial.capRows[1].frame.Position.Y.Offset<compressed)
    end)
    test("button rebound tuning reduced motion and page focus pauses restore neutral immediately",function()
        local client=fixture(1,{studio=true});client.terminal.onAgent=nil
        client:tune("buttonReturn",0.3);client:event()
        client.input.InputBegan:Fire(center(client),true)
        client:tick(0.15);assert(math.abs(client.skill.dial.pressDepth-0.25)<0.000001)
        client.gui.ReducedMotionEnabled=true
        assert(client.skill.dial.pressDepth==0 and not client.skill.pressAge)
        client.input.InputBegan:Fire(center(client),true);assert(client.skill.dial.pressDepth==0)
        local angle=client.skill.pivot.Rotation;client:tick(0.05)
        assert(client.skill.pivot.Rotation~=angle)
        client.gui.ReducedMotionEnabled=false
        client.input.InputBegan:Fire(center(client),true);assert(client.skill.dial.pressDepth==1)
        client:guide();assert(client.skill.dial.pressDepth==0 and not client.skill.pressAge)
        client:main();assert(client.skill.dial.pressDepth==0)
        client.input.InputBegan:Fire(center(client),true);assert(client.skill.dial.pressDepth==1)
        client.input.WindowFocusReleased:Fire();client:tick(0.01)
        assert(client.skill.dial.pressDepth==0 and not client.skill.pressAge)
        client.input.WindowFocused:Fire();client:tick(0.01);assert(client.skill.dial.pressDepth==0)
    end)
    test("pixel skill artwork has stepped bounds distinct square target cells and an upright smooth orbit",function()
        local f=fixture();local dial=f.skill.dial
        assert(f.skill.button.BackgroundTransparency==1 and #dial.segments==90)
        local first=dial.body[1].frame;local firstArc=dial.segments[1]
        for _,diameter in ipairs({84,98,120}) do
            dial:layout(diameter)
            local cells={}
            for _,row in ipairs(dial.body) do
                local part=row.frame;local p,size=part.Position,part.Size
                assert(not part.Active and not part.Selectable)
                assert(p.X.Offset%1==0 and p.Y.Offset%1==0 and size.X.Offset%1==0 and size.Y.Offset%1==0)
                assert(p.X.Offset>=0 and p.Y.Offset>=0 and p.X.Offset+size.X.Offset<=diameter and p.Y.Offset+size.Y.Offset<=diameter)
                assert(row.y~=0 or row.x>0) -- Top row is stepped in from both corners.
            end
            for _,part in ipairs(dial.segments) do
                assert(not part.Active and (part.Rotation==nil or part.Rotation==0))
                local x,y=part.Position.X.Offset,part.Position.Y.Offset
                local key=x..":"..y;assert(not cells[key]);cells[key]=true
                assert(x%1==0 and y%1==0 and part.Size.X.Offset>0 and part.Size.Y.Offset>0)
            end
            assert(dial.body[1].frame==first and dial.segments[1]==firstArc)
            for _,part in ipairs(dial.markerParts) do assert(not part.frame.Active and not part.frame.Selectable) end
        end
        for _,child in ipairs(f.skill.button.children) do assert(child.ClassName~="UICorner" and child.ClassName~="UIStroke") end
        local angle=f.skill.pivot.Rotation;f:tick(0.037)
        assert(f.skill.pivot.Rotation~=angle and dial.dot.Rotation==-f.skill.pivot.Rotation)
        assert(f.skill.pivot.Rotation==shared.Skill.phase(f.skill.check,f.now))
        f:hit("Great");assert(f.terminal.composer.count==0 and f.server.stats.streak==1)
        assert(not f.skill.fire)
    end)
    test("historical base bonuses increase agent output but never timing-check words",function()
        local f=fixture();f:shop()
        for level=1,3 do f:restoreLegacyUpgrade("upgrade_click");assert(f.server.clickLevel==level) end
        assert(not f.root.StorePanel.UpgradeList:FindFirstChild("upgrade_click"))
        f:main();local money=f.server.credits
        f:hit("Normal");f:hit("Normal")
        assert(f.terminal.wordsPerClick==4 and f.terminal.composer.count==0)
        f:send();assert(#f.submits==0 and f.server.credits==money)
    end)
    test("fifth timing hit increases agent output after late acknowledgement without writing words",function()
        local f=fixture(1,{money=0})
        for _=1,4 do f:hit("Great") end
        f.autoAck=false;f:hit("Great");assert(f.terminal.composer.count==0)
        f:ack();for _=1,12 do f:tick(0.05) end
        assert(f.server.skillCheck.lastClick.wordCount==0 and f.terminal.composer.count==0 and f.skill.streak==5)
        assert(f.skill.tpcLabel.Text=="2" and #f.server.skillCheck.awards==0)
        f:snapshot();f:snapshot();assert(f.terminal.composer.count==0 and f.server.credits==0)
        f:send();assert(f.server.credits==0 and #f.submits==0)
    end)
    test("confirmed click melody continues across grades sends pages and sync without replay",function()
        local f=fixture();f:hit("Good")
        local events=f.audioEvents
        assert(math.abs(events[#events].pitch-shared.Music.pitch(69))<0.00001)
        f:hit("Great")
        assert(math.abs(events[#events-1].pitch-shared.Music.pitch(72))<0.00001)
        assert(math.abs(events[#events].pitch-shared.Music.pitch(84))<0.00001)
        f:send();f:button(f.root.DesktopDock,"Guide").Activated:Fire();f:main()
        local before=plays(f.audio.effectVoices);f:snapshot();assert(plays(f.audio.effectVoices)==before)
        f:hit("Good");assert(math.abs(events[#events].pitch-shared.Music.pitch(74))<0.00001)
        f:hit("Normal");f:hit("Good")
        assert(f.skill.streak==1 and math.abs(events[#events].pitch-shared.Music.pitch(69))<0.00001)
        f:key("Backspace");before=plays(f.audio.effectVoices);f:hit("Good")
        assert(plays(f.audio.effectVoices)==before+2) -- Fresh check: tactile click and Good phrase.
    end)
    test("historical C modifier changes agent output thresholds and music without manual words",function()
        local f=fixture();f:shop()
        for level=1,3 do f:restoreLegacyUpgrade("upgrade_divisor");assert(f.server.divisorLevel==level and f.server.streakDivisor==5-level) end
        assert(not f.root.StorePanel.UpgradeList:FindFirstChild("upgrade_divisor"))
        f:main();f:hit("Good");assert(f.terminal.composer.count==0)
        f:hit("Good");f:tick(0.05)
        assert(f.terminal.composer.count==0 and f.skill.tpcLabel.Text=="2" and f.audio.musicTier==1)
        assert(f.server.skillCheck.lastClick.wordCount==0 and f.server.skillCheck.streak==2)
        f:send();assert(#f.submits==0)
    end)
    test("music reaches four rock stages at C 2C 3C 4C then a miss returns lounge",function()
        local f=highStreakFixture();f:shop()
        for _=1,3 do f:restoreLegacyUpgrade("upgrade_divisor") end
        for _=1,3 do f:buyUpgrade("upgrade_tokens") end;f:main()
        local expected=0
        for streak=1,8 do
            f:hit("Great");f:tick(0.05)
            assert(f.audio.musicTier==math.min(4,math.floor(streak/2)))
            assert(f.audio.distortion.Level>=expected);expected=f.audio.distortion.Level
        end
        assert(f.skill.streak==8 and f.audio.musicTier==4 and f.audio.distortion.Level>0.15)
        local clock=f.audio.clock;f:shop();f:tick(0.05);f:main();assert(f.audio.clock==clock)
        f:hit("Normal");f:tick(0.1)
        assert(f.skill.streak==0 and f.audio.musicTier==0)
    end)
    test("Restored C modifier preserves previous word awards and immediately updates music threshold",function()
        local f=fixture();for _=1,4 do f:hit("Great") end
        local prior=#f.server.skillCheck.awards
        f:shop();f:restoreLegacyUpgrade("upgrade_divisor");f:tick(0.05)
        assert(f.server.streakDivisor==4 and f.audio.musicTier==1 and #f.server.skillCheck.awards==prior)
        local money=f.server.credits;f:main();f:send()
        assert(f.server.credits==money and #f.submits==0 and f.skill.streak==4)
    end)
    local function freePointer(f,touch)
        return {UserInputType=touch and f.enum.UserInputType.Touch or f.enum.UserInputType.MouseButton1,
            Position={X=10,Y=f.root.AbsoluteSize.Y-60}}
    end
    local function backgroundClick(f,pointer)
        f.root.FreeSpaceClick.InputBegan:Fire(pointer)
        f.root.FreeSpaceClick.Activated:Fire(pointer)
    end
    test("background mouse and touch use once-only streak checks without token production",function()
        local f=fixture(1,{money=0});f:aim("Great")
        local pointer=freePointer(f)
        assert(f.skill.allowFreeSpace(pointer) and f.root.FreeSpaceClick.ZIndex<f.root.Pages.ZIndex)
        backgroundClick(f,pointer)
        assert(f.terminal.composer.count==0 and f.skill.streak==1 and f.server.credits==0)
        f.root.FreeSpaceClick.Activated:Fire(pointer)
        assert(f.terminal.composer.count==0)
        f:aim("Good");backgroundClick(f,freePointer(f,true))
        assert(f.terminal.composer.count==0 and f.skill.streak==2 and f.server.skillCheck.lastClick.grade=="Good")
        f:send();assert(f.server.credits==0 and #f.submits==0)
    end)
    test("CLI bodies controls dock skill and streak never count as free background",function()
        local f=fixture();f:shop();f:buyAgent();f:main();f:aim("Great")
        local requests=#f.requests;local front=f.desk.front
        for _,object in ipairs({f.terminal.bar,f.terminal.send,f.terminal.input,
            f.desk.roster,f.desk.agents[2].frame,
            f.root.DesktopDock,f.skill.button,f.skill.streakLabel}) do
            local pointer=f:pointer(object)
            assert(not f.skill.allowFreeSpace(pointer))
            backgroundClick(f,pointer)
        end
        backgroundClick(f,{UserInputType=f.enum.UserInputType.MouseButton1,Position={X=-1,Y=1}})
        backgroundClick(f,{UserInputType=f.enum.UserInputType.Keyboard,Position={X=10,Y=660}})
        assert(#f.requests==requests and f.terminal.composer.count==0 and f.desk.front==front)
        local pointer=f:pointer(f.terminal.bar)
        f.root.FreeSpaceClick.InputBegan:Fire(pointer)
        pointer.Position=freePointer(f).Position -- A press begun on a CLI cannot activate when released on the background.
        f.root.FreeSpaceClick.Activated:Fire(pointer)
        assert(#f.requests==requests)
    end)
    test("background input respects pages pause drag pending skill and destruction",function()
        local f=fixture();f:aim("Great");local requests=#f.requests
        f:guide();requests=#f.requests;backgroundClick(f,freePointer(f));assert(#f.requests==requests)
        f:main();f.gui.MenuIsOpen=true;backgroundClick(f,freePointer(f));f.gui.MenuIsOpen=false
        f.input.WindowFocusReleased:Fire();backgroundClick(f,freePointer(f));f.input.WindowFocused:Fire()
        f.input.textBox={};backgroundClick(f,freePointer(f));f.input.textBox=nil
        f.input.held[f.enum.KeyCode.LeftControl]=true;backgroundClick(f,freePointer(f));f.input.held[f.enum.KeyCode.LeftControl]=false
        f.desk.drag={};backgroundClick(f,freePointer(f));f.desk.drag=nil
        assert(#f.requests==requests)
        f.autoAck=false;f:aim("Great");backgroundClick(f,freePointer(f))
        assert(f.skill.pending and f.terminal.composer.count==0)
        requests=#f.requests;backgroundClick(f,freePointer(f));assert(#f.requests==requests)
        f:ack();assert(f.terminal.composer.count==0 and f.skill.streak==1)
        local bg=f.root.FreeSpaceClick;requests=#f.requests;f.root.Parent:Destroy()
        bg.InputBegan:Fire(freePointer(f));bg.Activated:Fire(freePointer(f))
        assert(#f.requests==requests)
    end)
    local function visitorFixture(roll,options)
        options=options or {};options.visitors=true;options.newCollection=true;options.money=options.money or 0
        local f=fixture(roll or 1,options)
        for _=1,6 do f:tick(1) end
        assert(#f.server.streakAvatars.items==1 and f.dancers.spawnCount==1)
        f.dancers.onPoll=nil;f:tick(.03)
        return f,f.dancers.pool[1]
    end
    test("random visitors appear at zero streak without skill commands and never replay snapshots",function()
        local f,a=visitorFixture();local d=f.dancers
        assert(a.active and a.resource and a.mascot.id=="ember" and f.server.stats.streak==0 and f.server.fragments.ember==0)
        assert(#d.pool==10 and d.layer.Parent.DisplayOrder>f.root.Parent.DisplayOrder and not d.layer.Active)
        local count=d.spawnCount;f:snapshot();f:snapshot();assert(d.spawnCount==count)
        f:hit("Great");f:hit("Normal");assert(a.active and not a.fading and d.spawnCount==count)
        for _,request in ipairs(f.requests) do if request.action=="avatar_poll" then assert(request.payload.requestId>=1) end end
        assert(a.badge.Text=="Ember\nCommon" and not a.badge.Text:find("fragments",1,true) and not a.frame:GetAttribute("StreakBonus"))
    end)
    test("four visitor rarities use multicolor variant art and collect their exact fragments once",function()
        for rank,roll in ipairs({1,7501,9501,9951}) do
            local f,a=visitorFixture(roll,{family=2});a:setPosition(0,0)
            assert(a.rank==rank and a.familyId=="sprout" and a.rarity==shared.Balance.CRAFT_TIERS[rank].name)
            local colors={};for _,part in ipairs(a.mascot.parts) do colors[table.concat(part.BackgroundColor3,",")]=true end
            local n=0;for _ in pairs(colors) do n=n+1 end;assert(n>=3)
            local id=a.collectibleId;local old=f.server;a.button.Activated:Fire(f:pointer(a.frame))
            local reward=shared.Balance.CRAFT_TIERS[rank].drop
            assert(f.server.fragments.sprout==reward and f.server.stats.streak==0 and f.server.credits==0 and f.server.chips==0)
            assert(a.fading and not a.pending and f.server.lastAvatarCollect.fragments==reward)
            f.command:FireServer("collect_avatar",{id=id});f.command:FireServer("avatar_sync",{id=id})
            assert(f.server.fragments.sprout==reward and f.server.avatarSyncId==id)
            f.dancers:update(old);assert(f.dancers.spawnCount==1)
            f:tick(.7);assert(not a.active)
        end
    end)
    test("visitor scheduling pauses on pages chat menu modifiers and blur with no offline burst",function()
        local f=fixture(1,{visitors=true,money=0});for _=1,3 do f:tick(1) end
        f:guide();local n=#f.requests;for _=1,20 do f:tick(1) end;assert(#f.requests==n)
        f:main();f:tick(1);assert(#f.server.streakAvatars.items==0)
        for _=1,5 do f:tick(1) end;assert(#f.server.streakAvatars.items==1)
        local a=f.dancers.pool[1];f.dancers.onPoll=nil;local phase=a.mascot.phase
        f.input.WindowFocusReleased:Fire();f:tick(1);assert(a.mascot.phase==phase and a.active)
        local before=#f.requests;a.button.Activated:Fire(f:pointer(a.frame));assert(#f.requests==before)
        f.input.WindowFocused:Fire();f.gui.ReducedMotionEnabled=true;assert(a.mascot.motion.Rotation==0)
        f:guide();assert(not f.dancers.layer.Visible);f:main();assert(a.active and f.dancers.layer.Visible)
        f.root.Parent:Destroy();assert(a.destroyed and f.dancers.destroyed)
    end)
    test("visitor lifetime is server owned and collecting cannot renew or alter skill streak",function()
        local f,a=visitorFixture();f:hit("Great");local clicked=f.now;a:setPosition(0,0)
        f:tick(4);a.button.Activated:Fire(f:pointer(a.frame));assert(f.server.stats.streak==1)
        f:tick(1.01);assert(f.now>clicked+5 and f.server.stats.streak==0 and f.server.stats.bestStreak==1)
        local g,b=visitorFixture();local id=b.collectibleId;g:tick(24);g.command:FireServer("collect_avatar",{id=id})
        assert(g.server.avatarRejected==id and g.server.fragments.ember==0 and #g.server.streakAvatars.items==0)
        g:tick(.7);assert(not b.active)
    end)
    test("visitor pointer priority protects CLI and free background while skill circle remains above actors",function()
        local f,a=visitorFixture();a:setPosition(0,0);local pointer=f:pointer(a.frame)
        assert(f.dancers:blocksPointer(pointer) and not f.skill.allowFreeSpace(pointer))
        f.terminal.bar.InputBegan:Fire(pointer);f.terminal.send.Activated:Fire(pointer);assert(not f.desk.drag and #f.submits==0)
        f.input.InputBegan:Fire(pointer,true);f.input.InputEnded:Fire(pointer);a.button.Activated:Fire(pointer)
        assert(f.server.fragments.ember==1 and a.fading)
        local g,b=visitorFixture(9951);local p,s=g.skill.button.AbsolutePosition,g.skill.button.AbsoluteSize
        local size=b.frame.AbsoluteSize;local bounds=g.dancers.layer.AbsoluteSize
        b:setPosition((p.X+s.X/2-size.X/2)/(bounds.X-size.X),(p.Y+s.Y/2-size.Y/2)/(bounds.Y-size.Y))
        g:aim("Great");g.input.InputBegan:Fire(center(g),true)
        assert(g.server.stats.streak==1 and g.server.fragments.ember==0 and not g.server.lastAvatarCollect)
    end)
    test("lost visitor claims reconcile read only with three bounded syncs and never retry collection",function()
        local f,a=visitorFixture();a:setPosition(0,0);f.dropCollect=1;f.dropAvatarSync=3
        a.button.Activated:Fire(f:pointer(a.frame));assert(a.pending)
        for _=1,4 do f:tick(3.1) end;assert(not a.pending and a.active and f.server.fragments.ember==0)
        local collects,syncs=0,0
        for _,request in ipairs(f.requests) do if request.action=="collect_avatar" then collects=collects+1 elseif request.action=="avatar_sync" then syncs=syncs+1 end end
        assert(collects==1 and syncs==3)
        f.command:FireServer("avatar_sync",{id=a.collectibleId});assert(f.server.fragments.ember==0 and not a.pending)
    end)
    test("forged visitor fields and expired IDs never grant resources or generate another actor",function()
        local f,a=visitorFixture();local id=a.collectibleId;local sequence=f.server.streakAvatars.sequence
        for _,payload in ipairs({{id=id,fragments=999},{id=id,rank=4},{id=id,familyId="sage"},{id=id+1000}}) do
            f.command:FireServer("collect_avatar",payload);assert(f.server.fragments.ember==0)
        end
        assert(f.server.streakAvatars.sequence==sequence)
        f:hit("Great");f:hit("Normal");assert(a.active and not a.fading)
        f.command:FireServer("collect_avatar",{id=id});assert(f.server.fragments.ember==1)
    end)
    test("skill fire stays disabled across streak motion settings resizing and pages",function()
        local f=highStreakFixture();for _=1,3 do f:buyUpgrade("upgrade_tokens") end
        assert(f.skill.fire==nil and not f.skill.layer:FindFirstChild("StreakFire"))
        for _=1,12 do f:hit("Great") end
        f.gui.ReducedMotionEnabled=true;f:tick(0.2)
        f.root.Size=f.udim2.fromOffset(640,360);f:shop();f:main()
        assert(not f.skill.layer:FindFirstChild("StreakFire") and f.skill.streak==12)
    end)
    test("each accepted circle or background click emits one word before acknowledgement without sync replay",function()
        local f=fixture(1,{money=0});local words=f.floatingWords
        assert(words.emitted==0 and #words.pool==12)
        f.autoAck=false;f:hit("Normal")
        assert(words.emitted==1 and f.skill.pending and f.server.credits==0)
        local pointer=freePointer(f);backgroundClick(f,pointer);assert(words.emitted==1)
        f:ack();f:snapshot();assert(words.emitted==1)
        f:aim("Great");backgroundClick(f,pointer);assert(words.emitted==2)
        f:key("Backspace");f:hit("Great");assert(words.emitted==3)
        f:guide();backgroundClick(f,pointer);assert(words.emitted==3)
    end)
    test("floating words reuse a bounded passive pool rise fade fit resizing and expire",function()
        local f=fixture();for _=1,3 do f:buyUpgrade("upgrade_tokens") end;local words=f.floatingWords
        local first=words.pool[1].label;local phrases={}
        for _=1,30 do f:hit("Normal");phrases[words.pool[words.cursor].label.Text]=true end
        assert(words.emitted==30 and #words.pool==12 and words.pool[1].label==first)
        local distinct=0;for _ in pairs(phrases) do distinct=distinct+1 end;assert(distinct>1)
        local last=words.pool[words.cursor];local start=last.label.Position.Y.Offset
        local money,requests=f.server.credits,#f.requests;f:tick(0.5)
        assert(last.label.Position.Y.Offset<start and last.label.TextTransparency>0 and last.label.TextTransparency<1)
        assert(f.server.credits==money and #f.requests==requests)
        assert(words.layer.ZIndex<f.skill.layer.ZIndex and not words.layer.Active)
        for _,size in ipairs({{360,640},{640,360},{1280,720}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2]);words:tick(0)
            for _,slot in ipairs(words.pool) do
                if slot.active then
                    local label=slot.label
                    assert(not label.Active and not label.Selectable)
                    assert(label.Position.X.Offset>=0 and label.Position.Y.Offset>=0)
                    assert(label.Position.X.Offset+label.AbsoluteSize.X<=size[1]+0.001)
                    assert(label.Position.Y.Offset+label.AbsoluteSize.Y<=f.skill.layer.AbsolutePosition.Y+0.001)
                end
            end
        end
        assert(f.skill.allowFreeSpace(freePointer(f)))
        f:tick(2);for _,slot in ipairs(words.pool) do assert(not slot.active and not slot.label.Visible) end
    end)
    test("floating words honor reduced motion page and focus clearing with teardown",function()
        local f=fixture();local words=f.floatingWords
        f.gui.ReducedMotionEnabled=true;f:hit("Normal")
        local slot=words.pool[words.cursor];local p=slot.label.Position.Y.Offset
        f:tick(0.2);assert(slot.label.Position.Y.Offset==p and slot.label.TextTransparency==0)
        f:guide();for _,item in ipairs(words.pool) do assert(not item.active) end
        f:main();f.gui.ReducedMotionEnabled=false;f:hit("Normal")
        f.input.WindowFocusReleased:Fire();f:tick(0.05)
        for _,item in ipairs(words.pool) do assert(not item.active) end
        f.input.WindowFocused:Fire();f:hit("Normal")
        f.input.textBox={};f:tick(0.05);for _,item in ipairs(words.pool) do assert(not item.active) end
        f.input.textBox=nil;f.root.Parent:Destroy();f:tick(0.1);assert(words.destroyed)
        local count=words.emitted;words:emit();assert(words.emitted==count)
    end)
    test("Fixed shop preserves icon-free buy prices and nonoverlapping rectangular options",function()
        local f=fixture();f:shop();local list=f.root.StorePanel.UpgradeList
        local actions={"upgrade_compute","add_layer","upgrade_tokens"}
        for _,viewport in ipairs({{1280,720},{900,640},{360,640},{640,360}}) do
            f.root.Size=f.udim2.fromOffset(viewport[1],viewport[2])
            local rectangles={};local maxBottom=0
            for _,action in ipairs(actions) do
                local card=list[action];local size=card.AbsoluteSize;local p=card.Position
                assert(size.X>=120 and size.Y>=102 and size.X~=size.Y and card.UpgradeName.Text~="")
                assert(not card:FindFirstChild("UpgradeIcon"))
                assert(card.BuyUpgrade.Text:sub(1,1)=="$" and card.BuyUpgrade.AbsoluteSize.Y==size.Y)
                assert(p.X.Offset>=0 and p.X.Offset+size.X<=list.AbsoluteSize.X)
                for _,other in ipairs(rectangles) do
                    assert(p.X.Offset>=other.x+other.w or p.X.Offset+size.X<=other.x
                        or p.Y.Offset>=other.y+other.h or p.Y.Offset+size.Y<=other.y)
                end
                rectangles[#rectangles+1]={x=p.X.Offset,y=p.Y.Offset,w=size.X,h=size.Y}
                maxBottom=math.max(maxBottom,p.Y.Offset+size.Y)
            end
            assert(list.CanvasSize.Y.Offset>0)
            assert(list.CanvasSize.Y.Offset<=maxBottom+100,"Store must not reserve rows for retired cards")
            assert(list[actions[1]].Position.Y.Offset<list[actions[3]].Position.Y.Offset)
        end
        local buy=list.upgrade_compute.BuyUpgrade
        local money=f.server.credits;local price=shared.Rules.quote(f.server,"upgrade_compute",nil,shared.Balance)
        f:buyUpgrade("upgrade_compute")
        assert(list.upgrade_compute.BuyUpgrade==buy and f.server.credits==money-price)
        assert(list.upgrade_compute.UpgradeName.Text=="TOKEN VALUE" and f.root.StorePanel.Visible)
    end)
    test("streak avatars expose independent identity appearance position and lifecycle",function()
        local f=fixture();local a,b=f.dancers.pool[1],f.dancers.pool[2];a:activate({mascotId="ember",sourceAgent=1},false);b:activate({mascotId="volt",sourceAgent=1},false)
        assert(a.id~=b.id and a.frame~=b.frame and a.mascot~=b.mascot)
        assert(a.frame:GetAttribute("StreakAvatarId")==a.id and a.frame:GetAttribute("SourceAgent")==a.sourceAgent)
        assert(a.sourceAgent>=1 and a.sourceAgent<=f.desk.count)
        local bx,by=b.x,b.y
        a:setPosition(1,0);f:tick(0.05)
        assert(a.x==1 and a.y==0 and b.x==bx and b.y==by)
        f.mascotCatalog.square={name="Square",width=1,height=1,color={1,2,3},parts={{0,0,1,1}}}
        local original=b.mascot.id
        assert(a:setAppearance("square") and b.mascot.id==original)
        assert(not a:setAppearance("unknown") and a.mascot.id=="square")
        for _,part in ipairs(a.mascot.parts) do
            assert(part.ZIndex==3 and part.BackgroundTransparency==a.alpha and not part.Active and not part.Selectable)
        end
        a:fadeOut();a:fadeOut();f:tick(0.3);assert(a.active and a.fading and not b.fading)
        f:tick(0.4);assert(not a.active and b.active)
        a:destroy();a:destroy();a:setPosition(0,0);a:tick(1,2,88,true,false)
        assert(a.destroyed and not b.destroyed and b.active)
        f.root.Parent:Destroy();assert(b.destroyed)
    end)
    test("persistent dancers can occupy screen corners above CLIs and only fade on streak reset",function()
        local f=fixture();f:hit("Great");local d=f.dancers;local slot=d.pool[1];slot:activate({mascotId="ember",sourceAgent=1},false)
        local rng=d.random
        d.random={NextInteger=function(_,low,high) return high end};d:choosePosition(slot)
        local p,size=slot.mascot.frame.AbsolutePosition,slot.mascot.frame.AbsoluteSize
        assert(p.X+size.X==d.layer.AbsoluteSize.X and p.Y+size.Y==d.layer.AbsoluteSize.Y)
        d.random={NextInteger=function(_,low) return low end};d:choosePosition(slot)
        assert(slot.mascot.frame.Position.X.Offset==0 and slot.mascot.frame.Position.Y.Offset==0)
        f.terminal.frame.Position=f.udim2.fromOffset(0,0) -- Foreground actor can overlap the main CLI and HUD.
        d.random=rng
        f:shop();f:tick(1);f:main();assert(slot.active and not slot.fading)
        f.input.textBox={};f:tick(1);f.input.textBox=nil;assert(slot.active)
        f:hit("Normal");local alpha=slot.alpha;assert(slot.active and slot.fading)
        f:tick(0.2);assert(slot.alpha>alpha)
        f.gui.ReducedMotionEnabled=true;local fading=slot.alpha;f:tick(0.1)
        assert(slot.alpha>=fading and slot.active)
        f:tick(0.4);assert(not slot.active and not slot.mascot.frame.Visible)
    end)
    test("agents fill context while Store stays open but cannot sell without the player",function()
        local f=fixture(1,{money=0,agents=true});f:shop()
        local list=f.root.StorePanel.UpgradeList;list.CanvasPosition=f.vec2.new(0,60)
        for _=1,120 do f:tick(0.1) end
        assert(f.server.stats.prompts==0 and not f.server.lastPrompt and f.server.credits==0 and f.terminal.composer.count==8)
        assert(f.root.StorePanel.Visible and list.CanvasPosition.Y==60)
        assert(f.skill.streak==0 and f.floatingWords.emitted==0 and f.dancers.spawnCount==0)
        f:main();f.terminal.send.Activated:Fire()
        assert(f.server.stats.prompts==1 and f.server.credits==8 and f.server.lastPrompt.tokens==8)
    end)
    test("full agent context accepts no-word skill checks and never changes stored agent rewards",function()
        local f=highStreakFixture(1,{money=0,agents=true})
        for _=1,90 do f:tick(0.1) end
        assert(f.terminal.composer.count==8 and #f.submits==0 and f.server.credits==0)
        local callback=f.terminal.onAgent;f.terminal.onAgent=nil
        local id=f.skill.check.id
        for _=1,12 do f:hit("Great") end
        assert(not f.skill.pending and f.server.skillCheck.id>id and f.server.stats.streak==12)
        assert(f.terminal.composer.count==8 and f.server.skillCheck.lastClick.wordCount==0 and not f.server.pendingSkillWords)
        for _,award in ipairs(f.server.skillCheck.awards) do assert(award.grade=="Agent" and award.multiplier==1) end
        f:hit("Normal");assert(f.server.stats.streak==0 and f.terminal.composer.count==8 and f.server.credits==0)
        f.terminal.send.Activated:Fire();assert(#f.submits==1 and f.server.credits==8)
        f:tick(1);f:snapshot();assert(f.terminal.composer.count==0 and not f.server.pendingSkillWords)
        f:finishCollection()
        f.terminal.onAgent=callback;f:tick(0.05)
        assert(f.terminal.composer.count==1 and f.terminal.tokens[1]:GetAttribute("SkillGrade")=="Agent")
        assert(f.server.credits==8 and #f.submits==1)
    end)
    test("skill counters have passive offset shadows and a passive global cap caption at any viewport",function()
        local client=fixture();client:hit("Great");client:hit("Great")
        local skill=client.skill
        assert(not skill.tpcCaption and not skill.multiplierLabel and not skill.status)
        local labels=0
        for _,child in ipairs(skill.layer.children) do
            if child.ClassName=="TextLabel" then
                labels=labels+1
                assert(child==skill.capLabel or child==skill.streakLabel or child==skill.tpcLabel or child==skill.streakShadow or child==skill.tpcShadow)
            end
        end
        assert(labels==5 and skill.label.Text=="CLICK" and not skill.capLabel.Active)
        for _,viewport in ipairs({{360,640},{640,360},{1280,720}}) do
            client.root.Size=client.udim2.fromOffset(viewport[1],viewport[2])
            for _,pair in ipairs({{skill.streakLabel,skill.streakShadow},{skill.tpcLabel,skill.tpcShadow}}) do
                local source,shadow=pair[1],pair[2]
                assert(shadow.Text==source.Text and shadow.FontFace.Family==source.FontFace.Family)
                assert(shadow.TextScaled and shadow.TextSize==source.TextSize and shadow.ZIndex<source.ZIndex)
                assert(shadow.AbsolutePosition.X==source.AbsolutePosition.X+3 and shadow.AbsolutePosition.Y==source.AbsolutePosition.Y+4)
                assert(shadow.AbsoluteSize.X==source.AbsoluteSize.X and shadow.AbsoluteSize.Y==source.AbsoluteSize.Y)
                assert(shadow.TextTransparency==0.15 and shadow.BackgroundTransparency==1 and not shadow.Active and not shadow.Selectable)
                assert(skill:blocksPointer(client:pointer(source)))
            end
            local source=skill.streakLabel;local point=client:pointer(source)
            point.Position.X=source.AbsolutePosition.X+source.AbsoluteSize.X+1
            assert(not skill:blocksPointer(point))
        end
        skill.streak=9999;skill:render()
        assert(skill.streakLabel.Text=="9999x" and skill.streakShadow.Text=="9999x")
        client:snapshot();assert(skill.streakLabel.Text=="2x" and skill.streakShadow.Text=="2x")
    end)
    test("agent batches scale with current TPC and owned count with matching large TPC and Nx counters",function()
        local f=fixture(1,{agents=true});local callback=f.terminal.onAgent;f.terminal.onAgent=nil
        f:shop();f:buyAgent();f:restoreLegacyUpgrade("upgrade_click")
        for _=1,3 do f:buyUpgrade("upgrade_tokens") end
        f:main();for _=1,5 do f:hit("Great") end;f:send()
        assert(f.skill.tpcLabel.Text=="4" and f.skill.streakLabel.Text=="5x")
        local money=f.server.credits;f.terminal.onAgent=callback
        for _=1,20 do f:tick(0.05) end
        f.terminal.onAgent=nil
        local count=f.terminal.composer.count
        assert(count>=6 and count<=9 and f.server.credits==money and f.skill.streak==5)
        assert(f.server.lastAgent.wordCount<=2)
        for _,viewport in ipairs({{1280,720},{360,640},{640,360}}) do
            f.root.Size=f.udim2.fromOffset(viewport[1],viewport[2])
            local left,right,button=f.skill.tpcLabel,f.skill.streakLabel,f.skill.button
            assert(left.AbsoluteSize.Y==right.AbsoluteSize.Y and left.TextSize==right.TextSize and left.TextScaled==right.TextScaled)
            assert(left.AbsolutePosition.X>=0 and left.AbsolutePosition.X+left.AbsoluteSize.X<button.AbsolutePosition.X)
            assert(right.AbsolutePosition.X+right.AbsoluteSize.X<=viewport[1])
            assert(f.skill:blocksPointer(f:pointer(left)))
        end
        local base=f.server.moneyPerToken;f:send();assert(f.server.credits==money+count*base*1.5)
    end)
    test("manual click preserves complete fast agent words and independent production deadline",function()
        local f=fixture(1,{agents=true});local callback=f.terminal.onAgent;f.terminal.onAgent=nil
        f:shop();f:buyAgent()
        for _=1,3 do f:restoreLegacyUpgrade("upgrade_click");f:buyUpgrade("upgrade_tokens") end
        f:main();f.terminal.onAgent=callback;f:tick(1);f.terminal.onAgent=nil
        assert(f.server.lastAgent.wordCount==2 and f.terminal.composer.count==2 and f.terminal.pendingKeys==nil)
        local deadline=f.terminal.nextAgent
        assert(not next(f.terminal.reveals) and f.terminal.tokenWords[1].MaxVisibleGraphemes==-1)
        f.skill.button.Activated:Fire(center(f))
        local result=f.server.skillCheck.lastClick
        assert(result.tokenIndex==3 and f.terminal.pendingKeys==nil and not f.terminal.backgroundSend)
        assert(f.terminal.nextAgent==deadline and not next(f.terminal.agentRevealTimes))
        assert(not next(f.terminal.reveals))
        assert(f.terminal.composer.count==2+result.wordCount)
        for index=1,f.terminal.composer.count do assert(f.terminal.tokenWords[index].MaxVisibleGraphemes==-1) end
        for index=1,2 do assert(f.terminal.tokens[index]:GetAttribute("SkillGrade")=="Agent") end
        assert(f.terminal.tokens[3]:GetAttribute("SkillGrade")~="Agent")
    end)
    test("buying agents multiplies automatic words and summed queue speed with per-agent upgrades",function()
        local f=fixture(1,{agents=true});local callback=f.terminal.onAgent;f.terminal.onAgent=nil
        f:shop();for _=1,3 do f:restoreLegacyUpgrade("upgrade_click");f:buyUpgrade("upgrade_tokens") end
        f:main();f.terminal.onAgent=callback
        for _=1,20 do f:tick(0.05) end
        f.terminal.onAgent=nil
        assert(f.terminal.composer.count>=3 and f.terminal.composer.count<=4)
        f:send();f:shop();f:buyAgent();f:main()
        assert(f.server.totalAgentTypingSpeed==8 and f.terminal.totalSpeed==8 and f.desk.count==2)
        assert(string.find(f.terminal.countLabel.Text,"Agents cap 8/s",1,true))
        f.terminal.onAgent=callback
        for _=1,20 do f:tick(0.05) end
        f.terminal.onAgent=nil
        assert(f.terminal.composer.count>=6 and f.terminal.composer.count<=9 and f.terminal.pendingKeys==nil)
        f:send();f:shop();f:restoreLegacyUpgrade("upgrade_typing");f:main()
        assert(f.server.agentTypingSpeed==6 and f.server.totalAgentTypingSpeed==12 and f.terminal.totalSpeed==12)
        for _=1,5 do f:hit("Great") end;f:send()
        f.terminal.onAgent=callback
        for _=1,20 do f:tick(0.05) end
        f.terminal.onAgent=nil
        assert(f.terminal.composer.count>=10 and f.terminal.composer.count<=13 and f.terminal.pendingKeys==nil)
        assert(f.skill.streak==5)
    end)
    test("agent speed limits grants while streak buffs remain fixed on tokens and paid once",function()
        local f=fixture(9890,{agents=true});local callback=f.terminal.onAgent;f.terminal.onAgent=nil
        f:shop();f:restoreLegacyUpgrade("upgrade_click");f:restoreLegacyUpgrade("upgrade_typing")
        for _=1,4 do f:buyUpgrade("upgrade_tokens") end
        f:main();for _=1,5 do f:hit("Great") end;f:send()
        assert(f.server.agentTypingSpeed==6 and f.server.typingLevel==1)
        f.terminal.onAgent=callback;f:tick(1);f.terminal.onAgent=nil
        for _=1,20 do f:tick(0.05) end
        assert(f.terminal.composer.count==1 and f.skill.streak==5)
        for index=1,1 do
            assert(f.terminal.tokens[index]:GetAttribute("SkillGrade")=="Agent")
            assert(f.terminal.tokens[index]:GetAttribute("SkillMultiplier")==1.5)
            assert(f.terminal.tokens[index].Multiplier.Text=="x15")
        end
        f:hit("Normal");assert(f.skill.streak==0)
        assert(f.terminal.tokens[1]:GetAttribute("SkillMultiplier")==1.5)
        local before=f.server.credits;f:send()
        assert(math.abs(f.server.credits-before-15)<0.0001)
        f:snapshot();assert(f.server.credits==before+15)
        assert(not f.root.StorePanel.UpgradeList:FindFirstChild("upgrade_typing"))
    end)
    test("continuous delayed manual clicks cannot starve due automatic producers",function()
        local f=fixture(1,{agents=true});f:shop();f:buyAgent()
        for _=1,6 do f:buyUpgrade("upgrade_tokens") end
        f:main();local initial=f.server.lastAgent and f.server.lastAgent.requestId or 0
        local manual=0
        for _=1,40 do
            f:tick(0.11)
            if f.skill:eligible() then
                f.autoAck=false;f.skill.button.Activated:Fire(center(f))
                if f.skill.pending then manual=manual+1 end
                f:tick(0.05);f:ack()
            end
        end
        assert(manual>=20 and f.server.lastAgent.requestId>=initial+4)
        assert(not f.terminal.skillPending and not f.terminal.agentPending)
        assert(f.terminal.pendingKeys==nil and f.terminal.composer.count>0)
        local seen={}
        for _,request in ipairs(f.requests) do
            if request.action=="agent_type" then assert(not seen[request.payload.requestId]);seen[request.payload.requestId]=true end
        end
    end)
    test("a delayed manual receipt on Store cannot leave an agent-blocking word queue",function()
        local f=fixture(1,{agents=true});f:shop();for _=1,3 do f:buyUpgrade("upgrade_tokens") end;f:main()
        f.autoAck=false;f:hit("Great");f:shop();f:ack()
        assert(f.terminal.pendingKeys==nil and f.root.StorePanel.Visible)
        local count=f.terminal.composer.count
        for _=1,15 do f:tick(0.1) end
        assert(f.terminal.composer.count>count and not f.terminal.agentPending)
        assert(f.root.StorePanel.Visible and not f.skill.pending)
    end)
    test("manual snapshots and prompt sends never postpone an agent deadline",function()
        local f=fixture(1,{agents=true});f:shop();for _=1,3 do f:buyUpgrade("upgrade_tokens") end;f:main()
        f:tick(1.1);local due=f.terminal.nextAgent
        for _=1,5 do
            f.skill.button.Activated:Fire(center(f))
            assert(f.terminal.nextAgent==due)
        end
        f:press("Return");assert(f.terminal.nextAgent==due)
        f:tick(math.max(0,due-f.now)+0.001)
        assert(f.terminal.nextAgent>due and not f.terminal.agentPending)
    end)
    test("agent timeout sync recovers the fixed batch and resumes due production without replay or skill clicks",function()
        local f=fixture(1,{money=0,agents=true});f.autoAck=false
        f:tick(1.1);assert(f.terminal.agentPending and f.terminal.composer.count==0)
        f.terminal.nextAgent=math.huge
        f:tick(3.1);f:ack();assert(not f.terminal.agentPending and f.terminal.composer.count==1)
        f:tick(0.05);assert(not f.terminal.agentPending and f.terminal.composer.count==2)
        f:snapshot();f:snapshot();assert(f.terminal.composer.count==2 and f.skill.streak==0)
        local sends=0;for _,request in ipairs(f.requests) do if request.action=="agent_type" then sends=sends+1 end end
        assert(sends==2 and f.server.credits==0)
        f:send();assert(f.server.credits==2)
    end)
    test("lost agent packet unlocks by read-only sync and menu focus chat pause automation",function()
        local f=fixture(1,{money=0,agents=true});f.dropAgent=1;f:tick(1.1)
        assert(f.terminal.agentPending)
        f.terminal.nextAgent=math.huge;f:tick(3.1)
        assert(not f.terminal.agentPending and f.terminal.composer.count==0)
        f:tick(0.05);assert(f.terminal.composer.count==1)
        f.gui.MenuIsOpen=true;f.terminal.nextAgent=f.now;local requests=#f.requests;f:tick(10);assert(#f.requests==requests)
        f.gui.MenuIsOpen=false;f.input.WindowFocusReleased:Fire();f:tick(10);assert(#f.requests==requests)
        f.input.WindowFocused:Fire();f.input.textBox={};f:tick(10);assert(#f.requests==requests)
        f.input.textBox=nil;f:tick(0.05);assert(f.terminal.composer.count==2 and f.server.credits==0)
    end)
    test("eight fast agents keep direct manual clicks available between confirmations without storing busy presses",function()
        local f=highTpcFixture(true,true,1000000000)
        f:tune("agentRate",16);f:tune("streakTimeout",0);f:tune("spawnPercent",0)
        f:shop();for _=1,7 do f:buyAgent() end;f:main()
        for _=1,4 do f:hit("Great") end
        assert(f.terminal.wordsPerClick==12 and f.server.totalAgentWordsPerSecond==96)
        f.terminal.onAgent=f.savedAgentCallback;f.autoAck=false
        local clicks,sales=0,0
        for frame=1,360 do
            if frame%3==0 then f:deliverReplies() end
            if f.terminal.composer.count>=f.terminal.limit and not f.terminal.sendRequested and not f.terminal.composer.flight then
                f.terminal.send.Activated:Fire();sales=sales+1
            elseif f.skill:eligible() and not f.skill.pending and f.now>=f.skill.check.startsAt then
                assert(f.skill:press(center(f)));clicks=clicks+1
            end
            f:tick(1/60)
            if f.terminal.agentPending or f.terminal.composer.flight then
                local requests=#f.requests;assert(not f.skill:press(center(f)) and #f.requests==requests)
            end
        end
        assert(clicks>=3 and sales>=2 and #f.submits==sales,"Direct load: "..clicks.."/"..sales)
        for _=1,15 do f:deliverReplies();f:tick(0.05) end
        assert(not f.skill.pending and not f.server.pendingSkillWords and f.skill.button.Active)
        for _,request in ipairs(f.requests) do assert(request.action~="skill_queue") end
    end)
    test("presses during a paid prompt flight are discarded and never replayed after its receipt",function()
        local f=fixture(1,{money=0});f:hit("Great");f:compose("a");f:aim("Great")
        f.autoAck=false;f.terminal.send.Activated:Fire()
        local requests=#f.requests
        for _=1,12 do assert(not f.skill:press(center(f))) end
        assert(#f.requests==requests and not f.skill.pending and f.server.credits==1)
        f:ack();f:tick(1);f:snapshot()
        assert(f.terminal.composer.count==0 and not f.server.pendingSkillWords and #f.submits==1)
        f:hit("Great");assert(f.terminal.composer.count==0);f:compose("a")
        f:send();assert(f.server.credits==2 and #f.submits==2)
    end)
    test("retired buffer commands and Studio knobs cannot mutate words streak or money",function()
        local f=fixture(1,{studio=true,money=0});f:event()
        local check=f.server.skillCheck;local money=f.server.credits
        f.command:FireServer("skill_queue",{draftId=check.draftId,checkId=check.id,tokenIndex=1})
        local dev=f.command.Parent.StudioCommand
        dev:FireServer("tune_queueRate");dev:FireServer("tune_queueBatch")
        f:snapshot()
        assert(f.server.skillCheck.id==check.id and f.server.stats.streak==0 and f.server.credits==money)
        assert(not f.server.pendingSkillWords and not f.server.studioTuning.queueRate and not f.server.studioTuning.queueBatch)
        assert(f.terminal.composer.count==0 and not f.terminal.pendingKeys and not f.terminal.queueWords)
        assert(not f.terminal.stateLabel.Text:find("QUEUED",1,true))
    end)
    test("busy agent clicks are discarded while read-only reconciliation preserves the actual source grant",function()
        local f=fixture(1,{agents=true,money=0});f.autoAck=false;f:tick(1.1)
        assert(f.terminal.agentPending)
        local requests=#f.requests
        for _=1,12 do assert(not f.skill:press(center(f))) end
        assert(#f.requests==requests and not f.skill.pending)
        f:tick(3.1);f:ack();f.terminal.onAgent=nil
        assert(not f.terminal.agentPending and f.terminal.composer.count>=1 and f.server.credits==0)
        local count=f.terminal.composer.count;f:tick(1);f:snapshot()
        assert(f.terminal.composer.count==count and not f.server.pendingSkillWords)
        for index=1,count do assert(f.terminal.tokens[index]:GetAttribute("SkillGrade")=="Agent") end
    end)
    test("repeated lost agent reconciliation packets cannot lock the composer forever",function()
        local f=fixture(1,{money=0,agents=true});f.dropAgent=1;f.dropAgentSync=3
        f:tick(1.1);assert(f.terminal.agentPending)
        for _=1,3 do f:tick(3.1);assert(f.terminal.agentPending) end
        f:tick(3.1);assert(not f.terminal.agentPending and f.server.credits==0)
        f:tick(1.1);assert(f.terminal.composer.count==1 and f.server.credits==0)
        local sends=0;for _,request in ipairs(f.requests) do if request.action=="agent_type" then sends=sends+1 end end
        assert(sends==2 and #f.submits==0)
    end)
    test("shop quantity selector cycles all modes with exact aggregate quotes and no AUTO or shop Reconnect",function()
        local f=fixture();local shop=f.root.StorePanel;local list=shop.UpgradeList
        assert(not shop:FindFirstChild("Reconnect") and not list.add_layer:FindFirstChild("AutomationTag"))
        assert(f.root.Pages.GuidePage.Instructions.ConnectionSettings.Reconnect)
        local requests=#f.requests;list.CanvasPosition=f.vec2.new(0,30)
        for _,value in ipairs({1,5,10,25,"max",1}) do
            f:quantity(value)
            assert(shop.PurchaseQuantity.Text==(value=="max" and "MAX" or value.."X"))
            for _,action in ipairs({"upgrade_compute","add_layer","upgrade_tokens"}) do
                local quote=shared.Rules.quoteMany(f.server,action,value,shared.Balance)
                assert(list[action].BuyUpgrade.Text==f.theme.money(quote.cost))
                assert(list[action]:GetAttribute("BatchCount")==quote.count)
            end
        end
        assert(#f.requests==requests and list.CanvasPosition.Y==30 and f.server.computeLevel==0)
        f.gui.MenuIsOpen=true;shop.PurchaseQuantity.Activated:Fire();f.gui.MenuIsOpen=false
        assert(shop.PurchaseQuantity:GetAttribute("Quantity")==1)
        f:guide();shop.PurchaseQuantity.Activated:Fire();assert(shop.PurchaseQuantity:GetAttribute("Quantity")==1)
        local poor=fixture(1,{money=0});poor:quantity("max")
        for _,action in ipairs({"upgrade_compute","add_layer","upgrade_tokens"}) do
            local row=poor.root.StorePanel.UpgradeList[action];assert(not row.BuyUpgrade.Active and row:GetAttribute("BatchCount")==0)
            for _,name in ipairs({"UpgradeName","UpgradePrice","UpgradeStatus"}) do
                local color=row[name].TextColor3;assert(color[1]>color[2]*2 and color[1]>color[3]*2)
            end
        end
    end)
    test("bulk shop buys successive levels in one transaction and previews caps while preserving unsold tokens",function()
        local f=fixture(9890,{money=1000000000});f:compose("ab");local draft=f.terminal.composer.draft.id
        f:quantity(5);local money=f.server.credits
        local quote=shared.Rules.quoteMany(f.server,"upgrade_compute",5,shared.Balance)
        f:buyUpgrade("upgrade_compute")
        assert(f.server.computeLevel==5 and f.server.credits==money-quote.cost and f.server.upgradeReply.count==5)
        assert(f.terminal.composer.draft.id==draft and f.terminal.composer.count==2)
        f:restoreLegacyUpgrade("upgrade_workers")
        f:quantity(25);f:buyAgent();assert(f.desk.count==8 and f.server.upgradeReply.count==7)
        for index=2,#f.server.layerSizes-1 do assert(f.server.layerSizes[index]==3) end
        f:buyUpgrade("upgrade_tokens");assert(f.server.tokenLimit==64 and f.terminal.limit==64)
        assert(f.server.upgradeReply.count==7 and f.terminal.composer.draft.id==draft)
        local row=f.root.StorePanel.UpgradeList.upgrade_tokens
        assert(not row.BuyUpgrade.Active and row.UpgradePrice.Text=="MAXED" and row:GetAttribute("PurchaseState")=="Maxed")
        f:quantity("max");f:buyUpgrade("upgrade_compute");assert(f.server.computeLevel>20)
        assert(f.terminal.composer.count==2 and #f.submits==0)
    end)
    test("value milestones update shop and real sale money together and large numbers use trillions",function()
        local f=fixture(1,{money=100000,profile={computeLevel=9}})
        f:compose("ab");local draft=f.terminal.composer.draft.id
        assert(f.server.moneyPerToken==4.15)
        f:buyUpgrade("upgrade_compute")
        assert(f.server.computeLevel==10 and f.server.moneyPerToken==45)
        assert(f.terminal.composer.draft.id==draft and f.terminal.composer.count==2)
        assert(f.root.StorePanel.UpgradeList.upgrade_compute.UpgradeStatus.Text:find("$45.00",1,true))
        local before=f.server.credits;f:main();f:send()
        assert(f.server.lastPrompt.reward==90 and f.server.credits==before+90 and f.server.lifetimeEarned==90)
        assert(f.theme.money(1000000000000)=="$1.0T")
        local capped=fixture(1,{money=shared.Balance.MAX_CREDITS-.5,profile={computeLevel=1000000}})
        capped:compose("a");capped:send()
        assert(capped.server.lastPrompt.reward==.5 and capped.server.lifetimeEarned==.5)
        assert(capped.server.credits==shared.Balance.MAX_CREDITS and capped.server.moneyPerToken==shared.Balance.MAX_CREDITS)
    end)
    test("grandfathered skills retain old Chip debits and a new skill pays the inflated server price",function()
        local f=fixture(1,{money=0,profile={chips=10,prestigeClaimed=13,prestigeCount=1,lifetimeEarned=2197000,
            prestigeSkills={boot=true,focus=true}}})
        assert(f.server.legacyPrestigeSkills.focus and f.server.chips==10)
        f:feature("SkillTree");assert(f.progression.nodes.focus10.buy.Text=="10 Chips")
        f.progression.nodes.focus10.buy.Activated:Fire()
        assert(f.server.chips==0 and f.server.prestigeSkills.focus10 and not f.server.legacyPrestigeSkills.focus10)
        assert(shared.State.fromSnapshot(f.server,shared.Balance))
        f:tick(.31)
        f.command:FireServer("buy_skill",{requestId=f.server.progressionSequence+1,nodeId="focus15",legacyPrestigeSkills={focus15=true}})
        assert(f.server.chips==0 and not f.server.prestigeSkills.focus15)
        f:reconnect()
        assert(f.server.legacyPrestigeSkills.focus and not f.server.legacyPrestigeSkills.focus10 and f.server.chips==0)
    end)
    test("bulk pending receipts coalesce clicks and reconcile late results without repeating payment",function()
        local f=fixture();f:quantity(5);f.autoAck=false
        local quote=shared.Rules.quoteMany(f.server,"upgrade_compute",5,shared.Balance);local money=f.server.credits
        local row=f.root.StorePanel.UpgradeList.upgrade_compute;row.BuyUpgrade.Activated:Fire()
        local request=f.requests[#f.requests];assert(request.payload.quantity==5 and f.server.credits==money-quote.cost)
        local n=#f.requests
        for _=1,10 do row.BuyUpgrade.Activated:Fire() end
        assert(#f.requests==n and row:GetAttribute("PurchasePending") and not row.BuyUpgrade.Active)
        f:quantity(10);f.delayed=nil;f:tick(3.1);f:ack()
        assert(not row:GetAttribute("PurchasePending") and f.server.computeLevel==5 and f.server.credits==money-quote.cost)
        local paid=0;for _,r in ipairs(f.requests) do if r.action=="upgrade_compute" then paid=paid+1 end end
        assert(paid==1 and f.root.StorePanel.PurchaseQuantity:GetAttribute("Quantity")==10)
        f:snapshot();assert(f.server.credits==money-quote.cost)
    end)
    test("lost bulk packets unlock by read-only sync and exhausted reconciliation recovers through Guide",function()
        local f=fixture();f:quantity(5);f.dropPurchase=1
        local money=f.server.credits;f:buyUpgrade("upgrade_compute")
        assert(f.server.computeLevel==0 and f.root.StorePanel.UpgradeList.upgrade_compute:GetAttribute("PurchasePending"))
        f:tick(3.1);assert(f.server.computeLevel==0 and f.server.credits==money)
        assert(not f.root.StorePanel.UpgradeList.upgrade_compute:GetAttribute("PurchasePending"))
        f:buyUpgrade("upgrade_compute");assert(f.server.computeLevel==5)
        f.dropPurchase=1;f.dropUpgradeSync=3;f:buyUpgrade("upgrade_tokens")
        for _=1,5 do f:tick(3.1) end
        assert(f.root.StorePanel.PurchaseStatus.Text=="OPEN GUIDE" and f.server.tokenLevel==0)
        local changes=0;for _,r in ipairs(f.requests) do if r.action=="upgrade_tokens" then changes=changes+1 end end
        f:reconnect();assert(f.root.StorePanel.PurchaseStatus.Text:find("BOOT",1,true) and f.server.tokenLevel==0)
        local after=0;for _,r in ipairs(f.requests) do if r.action=="upgrade_tokens" then after=after+1 end end
        assert(after==changes and f.root.StorePanel.Visible)
        f:buyUpgrade("upgrade_tokens");assert(f.server.tokenLevel==5)
    end)
    test("bulk server rejects replay changed duplicate and forged costs without charging or granting again",function()
        local f=fixture();local money=f.server.credits
        f.command:FireServer("upgrade_compute",{requestId=8,quantity=5})
        assert(f.server.computeLevel==5 and f.server.upgradeSequence==8)
        local paid=money-f.server.credits;local cost=f.server.upgradeReply.cost
        f.server.upgradeReply.cost=999999
        for _,action in ipairs({"upgrade_compute","upgrade_tokens","add_layer"}) do
            f:tick(0.31);f.command:FireServer(action,{requestId=8,quantity="max"})
            assert(f.server.computeLevel==5 and f.server.tokenLevel==0 and #f.server.layerSizes==3 and f.server.credits==money-paid)
        end
        assert(f.server.upgradeReply.cost==cost)
        for _,payload in ipairs({{requestId=9,quantity=5,cost=0},{requestId=9,quantity=99999},{requestId=9,quantity=5,layerIndex=2}}) do
            f:tick(0.31);f.command:FireServer("upgrade_compute",payload)
            assert(f.server.computeLevel==5 and f.server.upgradeSequence==8 and f.server.credits==money-paid)
        end
        f:tick(0.31);f.command:FireServer("upgrade_sync",{requestId=9})
        assert(f.server.upgradeSyncId==9 and f.server.upgradeSequence==8 and f.server.credits==money-paid)
    end)
    test("faster sale collection holds generation until the final token and resumes only afterwards",function()
        local f=fixture(1,{agents=true,money=0});local t=f.terminal;local callback=t.onAgent;t.onAgent=nil
        f:compose("abcdefgh");f:tick(1.1);f:send();t.onAgent=callback;t.nextAgent=f.now
        local n=#f.requests;local elapsed=0
        while t:isCollecting() do
            f:tick(1/60);elapsed=elapsed+1/60
            assert(t.composer.count==0 and #f.requests==n)
        end
        assert(elapsed<0.4 and t.collection.collected==8 and t.collection.amount==8 and #f.submits==1)
        f:tick(0.05);assert(t.composer.count>0 and f.server.credits==8 and #f.submits==1)
    end)
    test("authored progression starts at global streak5 and tree upgrades raise all manual checks to10",function()
        local f=fixture(1,{money=0,profile={chips=10,prestigeClaimed=13,prestigeCount=1,lifetimeEarned=2197000,
            prestigeSkills={boot=true,focus=true}}})
        f.skill.autoSubmit=nil -- Isolate real manual grading from automatic requests.
        for _=1,9 do f:hit("Great") end
        assert(f.server.stats.streak==5 and f.server.progression.streakCap==5 and f.skill.capLabel.Text:find("5",1,true))
        assert(#f.server.streakAvatars.items==0)
        f:feature("SkillTree");f:tick(.31);f.progression.nodes.focus10.buy.Activated:Fire()
        assert(f.server.chips==0 and f.server.progression.streakCap==10 and f.server.progression.autoSkillCap==10)
        f:main();for _=1,9 do f:hit("Great") end
        assert(f.server.stats.streak==10 and f.terminal.composer.count==0 and #f.submits==0)
        assert(f.skill.capLabel.Text=="MAX STREAK 10 / AUTO")
        local streak=f.server.stats.streak
        f.command:FireServer("auto_skill",{draftId=f.skill.check.draftId,checkId=f.skill.check.id,tokenIndex=1,cap=9999})
        assert(f.server.stats.streak==streak)
    end)
    test("automatic skill checks build capped streak without tokens money collectible rolls or manual feedback",function()
        local f=fixture(1,{money=0,profile={chips=0,prestigeClaimed=3,prestigeCount=1,lifetimeEarned=27000,
            prestigeSkills={boot=true,focus=true}}})
        for _=1,12 do f:tick(2.1) end
        assert(f.server.stats.streak==5 and f.server.stats.bestStreak==5 and f.skill.streak==5)
        assert(f.server.skillCheck.lastClick.automatic and f.server.skillCheck.lastClick.grade=="Auto")
        assert(f.terminal.composer.count==0 and #f.server.skillCheck.awards==0 and #f.server.streakAvatars.items==0)
        assert(#f.submits==0 and f.server.credits==0 and f.server.lifetimeEarned==27000 and f.floatingWords.emitted==0)
        f:feature("Cards");f:tick(2.1);assert(f.server.stats.streak==5 and f.cardPage.frame.Visible)
        local requests=#f.requests
        f.input.WindowFocusReleased:Fire();f:tick(100)
        assert(#f.requests==requests and not f.skill.pending)
        f.input.WindowFocused:Fire();f:tick(.1)
        assert(f.server.stats.streak<=1 and f.server.skillCheck.lastClick.automatic)
    end)
    test("locked auto check cannot be invoked directly and server cooldown permits no streak burst",function()
        local f=fixture(1,{money=0});f:tick(.3)
        local check=f.skill.check;local payload={draftId=check.draftId,checkId=check.id,tokenIndex=1}
        f.command:FireServer("auto_skill",payload)
        assert(f.server.stats.streak==0 and not f.server.skillCheck.lastClick)
        local g=fixture(1,{money=0,profile={chips=0,prestigeClaimed=3,prestigeCount=1,lifetimeEarned=27000,
            prestigeSkills={boot=true,focus=true}}})
        g.skill.autoSubmit=nil;g:tick(.3);check=g.skill.check
        g.command:FireServer("auto_skill",{draftId=check.draftId,checkId=check.id,tokenIndex=1})
        assert(g.server.stats.streak==1)
        for _=1,5 do check=g.skill.check;g.command:FireServer("auto_skill",{draftId=check.draftId,checkId=check.id,tokenIndex=1}) end
        assert(g.server.stats.streak==1 and #g.submits==0)
    end)
    test("autosell unlock processes fresh full agent contexts on feature pages and holds generation through collection",function()
        local f=fixture(1,{agents=true,money=0,profile={chips=0,prestigeClaimed=7,prestigeCount=1,lifetimeEarned=343000,
            prestigeSkills={boot=true,tokens=true,cache=true}}})
        f:feature("SkillTree")
        local sawCollection=false
        for _=1,240 do
            f:tick(.1)
            if f.terminal:isCollecting() then sawCollection=true;assert(f.terminal.composer.count==0) end
            if #f.submits>=2 and not f.terminal:isCollecting() then break end
        end
        assert(#f.submits>=2 and sawCollection and f.progression.frame.Visible and f.server.batches==#f.submits)
        assert(f.server.lifetimeEarned>343000 and math.abs(f.server.credits-(f.server.lifetimeEarned-343000))<.0001)
        for _,request in ipairs(f.submits) do assert(request.tokens==8) end
    end)
    test("a loaded full context never creates a paid intent even with autosell unlocked",function()
        for _,unlocked in ipairs({false,true}) do
            local profile=unlocked and {chips=0,prestigeClaimed=7,prestigeCount=1,lifetimeEarned=343000,
                prestigeSkills={boot=true,tokens=true,cache=true}} or nil
            local f=fixture(1,{money=0,profile=profile})
            f:compose("abcdefgh");f:snapshot();f:tick(5);f:snapshot()
            assert(f.terminal.composer.count==8 and #f.submits==0 and not f.terminal.sendRequested)
            f:send();assert(#f.submits==1 and f.server.batches==1)
        end
    end)
    test("lost autosell receipt reconciles read-only and never repeats the paid prompt",function()
        local f=fixture(1,{agents=true,money=0,profile={chips=0,prestigeClaimed=7,prestigeCount=1,lifetimeEarned=343000,
            prestigeSkills={boot=true,tokens=true,cache=true}}})
        for _=1,150 do f:tick(.1);if f.terminal.sendRequested then break end end
        assert(f.terminal.sendRequested and f.terminal.sendAutomatic)
        f.autoAck=false;f:tick(.5);assert(#f.submits==1 and f.server.batches==1)
        f.terminal.onAgent=nil;local money=f.server.credits;f.delayed=nil
        f:tick(5.1);f:deliverReplies();f.autoAck=true;f:finishCollection();f:tick(1)
        assert(#f.submits==1 and f.server.batches==1 and f.server.credits==money)
        assert(not f.terminal.composer.flight and not f.terminal.saleFlight and not f.terminal.sendRequested)
    end)
    test("dropped autosell request stays unpaid and read-only sync restores explicit sale without retry",function()
        local f=fixture(1,{agents=true,money=0,profile={chips=0,prestigeClaimed=7,prestigeCount=1,lifetimeEarned=343000,
            prestigeSkills={boot=true,tokens=true,cache=true}}})
        f.dropSubmit=1
        for _=1,150 do f:tick(.1);if #f.submits==1 then break end end
        assert(#f.submits==1 and f.server.batches==0 and f.terminal.saleFlight)
        f:tick(5.1);f:tick(3)
        assert(#f.submits==1 and f.server.credits==0 and f.terminal.composer.count==8)
        assert(not f.terminal.saleFlight and not f.terminal.composer.flight and not f.terminal.sendRequested)
        f:send();assert(#f.submits==2 and f.server.batches==1 and f.server.credits>0)
    end)
    test("craft request dedup rejects later repeats and delayed snapshots cannot restore spent resources",function()
        local f=craftingFixture();f:feature("Laboratory");f.autoAck=false
        f.lab.recipes[4].buy.Activated:Fire();local request=f.requests[#f.requests]
        assert(request.action=="craft_card" and f.server.chips==40 and f.server.fragments.ember==25)
        local money=f.server.credits;f.command:FireServer("craft_card",request.payload)
        assert(f.server.chips==40 and f.server.credits==money and f.server.cardOwned.ember_legendary)
        f.command:FireServer("craft_card",{requestId=request.payload.requestId+1,cardId="ember_legendary"})
        assert(not f.server.progressionReply.ok and f.server.chips==40)
        f:ack();assert(f.lab.recipes[4].buy.Text=="OWNED" and not f.progression.pending)
        assert(f.server.lifetimeEarned==1000000000 and not f.transition.active and #f.submits==0)
    end)
    test("dropped crafting uses bounded read only recovery then Reconnect without automatic paid retry",function()
        local f=craftingFixture();f:feature("Laboratory");f.dropProgression=1;f.dropProgressionSync=3
        f.lab.recipes[2].buy.Activated:Fire();for _=1,4 do f:tick(3.1) end
        assert(f.progression.pending and f.lab.pending and f.lab.message.Text:find("Reconnect",1,true))
        local craft,sync=0,0
        for _,request in ipairs(f.requests) do if request.action=="craft_card" then craft=craft+1 elseif request.action=="prestige_sync" then sync=sync+1 end end
        assert(craft==1 and sync==3 and not f.server.cardOwned.ember_rare and f.server.chips==100)
        f.progression:sync();assert(not f.progression.pending and not f.server.cardOwned.ember_rare and f.server.fragments.ember==100)
        f.lab.recipes[2].buy.Activated:Fire();assert(f.server.cardOwned.ember_rare and f.server.chips==97)
    end)
    test("Laboratory shares Cards medallions stepped trim and panel art with clipped horizontal family selection",function()
        local f=craftingFixture();f:feature("Laboratory");local lab=f.lab
        assert(#lab.stripes==256 and lab.familyPanel.PanelFace and lab.recipePanel.PanelFace and lab.titleBadge)
        local card=lab.cards[1].frame;local inventory=f.cardPage.inventory.ember.frame
        assert(card.CardFrame.GoldCorner and inventory.CardFrame.GoldCorner and card.PixelMedallion and card.BuffPlaque)
        assert(card.AbsoluteSize.X==192 and card.AbsoluteSize.Y==304 and lab.familyList.ClipsDescendants)
        assert(lab.familyList.ScrollingDirection==f.enum.ScrollingDirection.X)
        local clipped=f:pointer(lab.cards[9].frame);clipped.Position.X=lab.cards[9].frame.AbsolutePosition.X+120
        lab.cards[9].frame.Activated:Fire(clipped);assert(lab.target==1)
        lab.familyList.CanvasPosition=f.vec2.new(9*208-lab.familyList.AbsoluteSize.X,0)
        lab.cards[9].frame.Activated:Fire(f:pointer(lab.cards[9].frame));assert(lab.target==9)
        assert(lab.recipes[1].frame.CardFrame and lab.recipes[1].aura.frame and lab.recipes[1].rarity.Text=="COMMON")
        for _,size in ipairs({{320,360},{360,640},{1280,720}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2]);lab:layout()
            for _,entry in ipairs(lab.recipes) do
                assert(entry.frame.Position.X.Offset+entry.frame.AbsoluteSize.X<=lab.list.AbsoluteSize.X)
                assert(entry.buy.AbsoluteSize.X>=160 and entry.buy.AbsoluteSize.Y==40)
            end
        end
        assert(f.server.fragments.sage==100 and f.server.chips==100 and #f.submits==0)
    end)
    test("confirmed vortex uses three pooled sweep voices once and stops at normal completion",function()
        local f=fixture(1,{money=0,profile={lifetimeEarned=1000}});f:feature("Prestige")
        f.progression.ascend.Activated:Fire();assert(not f.audio.lastVortexId)
        f.progression.ascend.Activated:Fire();assert(f.audio.lastVortexId==f.transition.lastId and #f.audio.effectVoices==6)
        local voices={};for _,voice in ipairs(f.audio.effectVoices) do if voice.note and voice.note.vortex then voices[#voices+1]=voice end end
        assert(#voices==3);f:tick(.1);local pitch=voices[1].sound.PlaybackSpeed;local played=voices[1].sound.playCount
        for _=1,12 do f:tick(1/60) end
        assert(voices[1].sound.PlaybackSpeed<pitch and voices[1].sound.Volume>0 and voices[1].sound.Looped)
        local age=f.transition.age;f:snapshot();assert(f.transition.age==age and voices[1].sound.playCount==played)
        for _=1,200 do if f.transition.active then f:tick(1/60) end end
        assert(not f.transition.active and not f.audio.vortexActive)
        for _,voice in ipairs(f.audio.effectVoices) do assert(not voice.note or not voice.note.vortex) end
        assert(#f.submits==0 and f.server.prestigeCount==1)
    end)
    test("vortex audio obeys effects volume mute and pause and never replays after resume or teardown",function()
        for _,muted in ipairs({false,true}) do
            local f=fixture(1,{money=0,profile={lifetimeEarned=1000}})
            if muted then f.audio:setMuted(true) else f.audio:setVolume("effects",0) end
            f:feature("Prestige");f.progression.ascend.Activated:Fire();f.progression.ascend.Activated:Fire()
            assert(f.transition.active and not f.audio.vortexActive)
            for _,voice in ipairs(f.audio.effectVoices) do assert(not voice.note or not voice.note.vortex) end
            f.root.Parent:Destroy();assert(f.audio.destroyed)
        end
        local f=fixture(1,{money=0,profile={lifetimeEarned=1000}});f:feature("Prestige")
        f.progression.ascend.Activated:Fire();f.progression.ascend.Activated:Fire();f:tick(.1)
        f.gui.MenuIsOpen=true;f:tick(5);local age=f.transition.age;f.gui.MenuIsOpen=false
        assert(not f.audio.vortexActive)
        f:tick(.1);assert(f.transition.age>age and not f.audio.vortexActive)
        for _,voice in ipairs(f.audio.effectVoices) do assert(not voice.note or not voice.note.vortex) end
        f.transition:finish();assert(not f.audio.vortexActive)
    end)
    test("visitors hide the offer amount and a matching receipt creates one exact rising fading fragment label",function()
        local f,a=visitorFixture(7501);local d=f.dancers;a:setPosition(.5,.5)
        assert(not a.badge.Text:find("fragments",1,true) and not a.frame:GetAttribute("FragmentBonus") and d.popupCount==0)
        local fragments=f.server.fragments.ember;f.autoAck=false
        a.button.Activated:Fire(f:pointer(a.frame));assert(a.pending and d.popupCount==0)
        f:ack();local popup=d.popups[d.popupCursor]
        assert(d.popupCount==1 and popup.amount==2 and popup.label.Text=="+2 fragments" and popup.label.Visible)
        assert(f.server.fragments.ember==fragments+2 and not popup.label.Active and not popup.label.Selectable)
        local y=popup.label.Position.Y.Offset;f:tick(.1);assert(popup.label.Position.Y.Offset<y)
        for _=1,5 do f:tick(.1) end
        assert(popup.label.TextTransparency>0 and popup.label.TextTransparency<1 and popup.stroke.Transparency==popup.label.TextTransparency)
        f:snapshot();f.command:FireServer("avatar_sync",{id=a.collectibleId});f.command:FireServer("collect_avatar",{id=a.collectibleId})
        assert(d.popupCount==1 and f.server.fragments.ember==fragments+2)
        for _=1,4 do f:tick(.1) end;assert(not popup.active and not popup.label.Visible and #d.popups==10)
        assert(f.server.credits==0 and f.server.chips==0 and #f.submits==0)
    end)
    test("fragment effects use capped receipt zero and never reveal amounts from expiry rejection or press",function()
        local f,a=visitorFixture();local d=f.dancers;a:setPosition(.5,.5)
        f.profile.fragments.ember=shared.Balance.MAX_FRAGMENTS;f:snapshot()
        a.button.Activated:Fire(f:pointer(a.frame));local popup=d.popups[d.popupCursor]
        assert(popup.label.Text=="+0 fragments" and popup.amount==0 and d.popupCount==1)
        assert(f.server.fragments.ember==shared.Balance.MAX_FRAGMENTS)
        local g,b=visitorFixture();g:tick(24);g.command:FireServer("collect_avatar",{id=b.collectibleId})
        assert(g.dancers.popupCount==0 and g.server.fragments.ember==0)
        local h,c=visitorFixture();c:setPosition(.5,.5);h.dropCollect=1;c.button.Activated:Fire(h:pointer(c.frame))
        assert(h.dancers.popupCount==0);h.command:FireServer("avatar_sync",{id=c.collectibleId})
        assert(h.dancers.popupCount==0 and c.badge.Text==c.caption and not c.caption:find("fragments",1,true))
    end)
    test("fragment popup pauses hidden and blurred remains still in reduced motion and cleans up with its owner",function()
        local f,a=visitorFixture();a:setPosition(.5,.5);f.autoAck=false;a.button.Activated:Fire(f:pointer(a.frame))
        f:guide();f:ack();local d=f.dancers;local popup=d.popups[d.popupCursor]
        assert(d.popupCount==1 and popup.active and not popup.label.Visible)
        local age=popup.age;f:tick(3);assert(popup.age==age)
        f:main();f.gui.ReducedMotionEnabled=true;f:tick(.1);local y=popup.label.Position.Y.Offset
        f:tick(.1);assert(popup.label.Position.Y.Offset==y and popup.label.Visible)
        f.input.WindowFocusReleased:Fire();age=popup.age;f:tick(5);assert(popup.age==age and not popup.label.Visible)
        f.input.WindowFocused:Fire();f.root.Parent:Destroy();assert(d.destroyed)
        local count=d.popupCount;f:tick(.1);assert(d.popupCount==count)
    end)
    test("larger shortcut art and header amounts remain readable while clipped shortcuts require scrolling",function()
        local f=fixture(1,{money=0});local dock=f.root.FeatureDock;local hud=f.root.MoneyHUD
        assert(hud.Balance.TextSize==54 and hud.Chips.TextSize==38)
        f.root.Size=f.udim2.fromOffset(320,360)
        assert(dock.ClassName=="ScrollingFrame" and dock.ClipsDescendants and dock.ScrollingEnabled)
        assert(dock.AbsolutePosition.X+dock.AbsoluteSize.X<=f.root.StorePanel.AbsolutePosition.X)
        local before=#f.requests;local prestige=dock.Prestige
        prestige.Activated:Fire(f:pointer(prestige));assert(not f.progression.frame.Visible and #f.requests==before)
        dock.CanvasPosition=f.vec2.new(dock.CanvasSize.X.Offset-dock.AbsoluteSize.X,0)
        assert(prestige.AbsoluteSize.X==64 and prestige.FeatureIcon.AbsoluteSize.X==48)
        local pointer=f:pointer(prestige);assert(not f.skill.allowFreeSpace(pointer))
        prestige.Activated:Fire(pointer);assert(f.progression.frame.Visible and f.progression.mode=="Prestige")
        f:main();assert(hud.Balance.TextSize>40 and hud.Chips.TextSize>28)
        assert(f.theme.textWidth(hud.Chips.Text,hud.Chips.TextSize)<=hud.AbsoluteSize.X-6)
        assert(hud.AbsolutePosition.Y+hud.AbsoluteSize.Y<=dock.AbsolutePosition.Y)
    end)
    test("Robux page shares collection art exposes low target prices and highlights Forever with billing unavailable by default",function()
        local f=fixture(1,{money=0});f:feature("RobuxShop");local p=f.robuxShop
        assert(p.frame.Visible and not f.cardPage.frame.Visible and not f.root.StorePanel.Visible and f.terminal.suspended)
        assert(#p.stripes==256 and p.entries.forever.frame.CardFrame.GoldCorner and p.entries.forever.offer.featured)
        for id,price in pairs({forever=100,money_hour=10,chips_hour=15,agent=20}) do
            local entry=p.entries[id];assert(entry.price.Text==price.." Robux / target" and entry.buy.Text=="UNAVAILABLE" and not entry.buy.Active)
            assert(entry.frame.CardFrame and not entry.icon.Active)
            entry.buy.Activated:Fire()
        end
        assert(not f.market.lastProduct and not f.market.lastPass and f.server.premium.moneyUntil==0 and not f.server.premium.forever)
        assert(p.entries.agent.description.Text:find("resets at prestige",1,true))
        f:main();assert(not p.frame.Visible and f.root.FeatureDock.RobuxShop.FeatureIcon.AbsoluteSize.X==48)
    end)
    local function readyShop(f)
        local data=shared.State.copy(f.server);data.commerce={sequence=0,serverTime=1000+f.now,offers={}}
        for index,offer in ipairs(shared.Premium.OFFERS) do data.commerce.offers[offer.id]={assetId=100+index,ready=true} end
        f.robuxShop:update(data,false);return data
    end
    test("Robux page queries actual localized prices and sends only SKU and nonce after explicit guarded click",function()
        local f=fixture(1,{money=0,robuxPrice=7});f:feature("RobuxShop");local p=f.robuxShop;readyShop(f)
        assert(p.entries.money_hour.price.Text=="7 Robux" and p.entries.forever.price.Text=="7 Robux")
        local sent={};p.onCommand=function(action,payload) sent[#sent+1]={action=action,payload=payload} end
        p.entries.money_hour.buy.Activated:Fire();assert(#sent==1 and sent[1].action=="premium_buy")
        assert(sent[1].payload.sku=="money_hour" and sent[1].payload.requestId==1 and not sent[1].payload.price and not sent[1].payload.productId)
        p.entries.money_hour.buy.Activated:Fire();assert(#sent==1 and p.waiting)
        assert(f.server.premium.moneyUntil==0 and f.server.credits==0)
    end)
    test("Robux purchase UI rejects hidden clipped paused and pending callbacks and keeps native cards on narrow screens",function()
        local f=fixture();local p=f.robuxShop;local requests=#f.requests
        p.entries.forever.buy.Activated:Fire();assert(#f.requests==requests)
        f:feature("RobuxShop");readyShop(f);local buy=p.entries.forever.buy
        for _,size in ipairs({{1280,720},{360,640},{320,360}}) do
            f.root.Size=f.udim2.fromOffset(size[1],size[2]);p:layout(size[1],size[2],52)
            for _,entry in pairs(p.entries) do
                assert(entry.frame.Position.X.Offset>=0 and entry.frame.Position.X.Offset+entry.frame.AbsoluteSize.X<=p.body.AbsoluteSize.X)
                assert(entry.buy.AbsoluteSize.X==208 and entry.buy.AbsoluteSize.Y==40)
            end
        end
        f.gui.MenuIsOpen=true;buy.Activated:Fire();f.gui.MenuIsOpen=false
        f.input.textBox={};buy.Activated:Fire();f.input.textBox=nil
        f.input.held[f.enum.KeyCode.LeftControl]=true;buy.Activated:Fire();f.input.held={}
        f.input.WindowFocusReleased:Fire();buy.Activated:Fire();f.input.WindowFocused:Fire()
        p.body.CanvasPosition=f.vec2.new(0,2000);buy.Activated:Fire(f:pointer(buy))
        assert(#f.requests==requests and not f.market.lastPass)
        f.root.Parent:Destroy();buy.Activated:Fire();assert(#f.requests==requests)
    end)
    test("Robux UI waits for correlated status never retries a paid prompt and CHECK only refreshes",function()
        local f=fixture();f:feature("RobuxShop");local p=f.robuxShop;local data=readyShop(f)
        local sent={};p.onCommand=function(action,payload) sent[#sent+1]={action=action,payload=payload} end
        p.entries.money_hour.buy.Activated:Fire();assert(p.waiting)
        p:update(data,false);assert(p.waiting)
        for _=1,9 do p:tick(1) end
        assert(not p.waiting and p.uncertain and #sent==1 and p.message.Text:find("CHECK",1,true))
        p.entries.money_hour.buy.Activated:Fire();assert(#sent==1)
        p.check.Activated:Fire();assert(#sent==2 and sent[2].action=="premium_check")
        data.commerce.checkedId=2;p:update(data,false);assert(not p.waiting and not p.uncertain)
        assert(f.server.premium.moneyUntil==0 and not f.server.premium.forever)
    end)
    test("owned Forever suppresses duplicate temporary purchases while saved agent credit redeems without Robux",function()
        local f=fixture();f:feature("RobuxShop");local p=f.robuxShop;local data=readyShop(f)
        data.premium.forever=true;data.premium.agentCredits=1;p:update(data,false)
        assert(p.entries.forever.buy.Text=="OWNED" and p.entries.money_hour.buy.Text=="INCLUDED" and not p.entries.chips_hour.buy.Active)
        assert(p.entries.agent.buy.Text=="USE CREDIT" and p.entries.agent.buy.Active)
        local sent;p.onCommand=function(action,payload) sent={action=action,payload=payload} end
        p.entries.agent.buy.Activated:Fire();assert(sent.action=="premium_redeem" and not sent.payload.sku)
        assert(not f.market.lastProduct and f.server.premium.agentCredits==0 and #f.server.layerSizes-2==1)
    end)
    assert(#failures==0,table.concat(failures,"\n"))
    print("[VibeIdle] "..passed.." production server/client callback scenarios passed (mock services, not Studio)")
    return passed
end

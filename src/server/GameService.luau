--!nonstrict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local ServerStorage=game:GetService("ServerStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Balance = require(Shared.Balance)
local State = require(Shared.State)
local Simulation = require(Shared.Simulation)
local Rules = require(Shared.UpgradeRules)
local RateLimiter = require(Shared.RateLimiter)
local Protocol = require(Shared.Protocol)
local Prompt = require(Shared.PromptRules)
local PromptSession = require(Shared.PromptSession)
local Skill = require(Shared.SkillCheck)
local Auto = require(Shared.AgentAutomation)
local Collectibles=require(Shared.StreakCollectibles)
local Tuning=require(Shared.StudioTuning)
local Prestige=require(Shared.PrestigeRules)
local Cards=require(Shared.AgentCards)
local Craft=require(Shared.AgentCrafting)
local Premium=require(Shared.PremiumRules)
local Commerce=require(script.Parent.CommerceService)
local MarketplaceService=game:GetService("MarketplaceService")
local Workspace = game:GetService("Workspace")
local Repository = require(script.Parent.ProfileRepository)
local Telemetry = require(script.Parent.Telemetry)

local GameService = {}
local messages = {
    insufficient_credits = "You need more money for this upgrade.",
    limit = "You have reached this upgrade's limit.",
    empty_prompt = "Add at least one token before sending.",
    invalid_prompt = "Compose a valid prompt before sending.",
    stale_prompt = "This prompt was already sent or replaced. Your current draft has been synced.",
    prompt_too_long = "Input exceeds context capacity. Upgrade context.",
    prompt_cooldown = "Please wait a moment before sending another prompt.",
}

function GameService.start(config)
    if config.STORAGE_MODE=="MEMORY" and config.PUBLISHED_STORAGE_MODE=="DATASTORE"
        and not RunService:IsStudio() and (game.GameId or 0)>0 then
        local resolved={};for key,value in pairs(config) do resolved[key]=value end
        resolved.STORAGE_MODE="DATASTORE";resolved.DATASTORE_NAME=config.LIVE_DATASTORE_NAME
        resolved.COMMERCE_RECEIPTS_NAME=config.LIVE_COMMERCE_RECEIPTS_NAME
        config=resolved
    end
    assert(config.STORAGE_MODE == "MEMORY" or config.STORAGE_MODE == "DATASTORE", "Invalid storage mode")
    local remoteFolder = ReplicatedStorage:WaitForChild("Remotes")
    local commandRemote = remoteFolder:WaitForChild("Command")
    local stateRemote = remoteFolder:WaitForChild("StateUpdate")
    local records = {}
    local avatarRandom=Random.new()
    local function chooseAvatar(low,high) return avatarRandom:NextInteger(low,high) end
    local rewardRandom = Random.new()
    local function chooseReward(low, high) return rewardRandom:NextInteger(low, high) end
    local loading = {}
    local closingCount = 0
    local stopping = false
    local repository = nil
    local profileStore
    local telemetry=Telemetry.new({config=config,state=State,balance=Balance,clock=os.clock,unix=os.time,spawn=task.spawn,
        analytics=game:GetService("AnalyticsService"),published=(game.GameId or 0)>0,studio=RunService:IsStudio(),
        log=function(report,reason) report.reason=reason;print("[VibeIdle:analytics] "..HttpService:JSONEncode(report)) end})
    local function metric(method,record,...)
        if not record.telemetry then return end
        local ok,value=pcall(telemetry[method],telemetry,record,...)
        if not ok and not record.analyticsWarning then record.analyticsWarning=true;warn("[VibeIdle] Analytics failed; gameplay continues") end
        return ok and value
    end
    local commerce
    if config.STORAGE_MODE == "DATASTORE" then
        local store = DataStoreService:GetDataStore(config.DATASTORE_NAME)
        profileStore=store
        repository = Repository.new(store, State, Balance, os.time, config.LEASE_SECONDS)
    end

    local function advance(record, now)
        now = now or os.clock()
        record.lastAdvance = now
        if record.blocked or record.closing or record.receiptBusy then return end
        if repository and record.handle.expiresAt <= os.time() then
            record.blocked = true
            warn("[VibeIdle] Profile lease expired; progression paused")
            return
        end
        Skill.expireStreak(record.prompts,Workspace:GetServerTimeNow())
        Collectibles.expire(record.prompts,Workspace:GetServerTimeNow())
        record.prompts.streakCap=Balance.progression(record.state).streakCap
        Auto.advance(record.prompts, record.state, now, Balance,Rules,Skill,Cards)
        -- Only accepted prompt submissions pay, including full-context agent prompts.
    end

    local function snapshot(player, record, message, promptRejected, forceDraft, skillRejected, skillSyncId, agentRejected, agentSyncId, avatarReply, progressionReply, progressionSyncId, upgradeSyncId)
        if player.Parent ~= Players then return end
        local agentNow,agentClock=os.clock(),Workspace:GetServerTimeNow()
        Skill.expireStreak(record.prompts,agentClock)
        if not record.receiptBusy then Auto.advance(record.prompts,record.state,agentNow,Balance,Rules,Skill,Cards) end
        local data = State.copy(record.state,true)
        record.snapshotSequence=(record.snapshotSequence or 0)+1
        data.snapshotSequence=record.snapshotSequence
        local unixNow=os.time()
        data.prestige=Prestige.view(record.state,Balance,unixNow)
        data.commerce=commerce and commerce:view(record) or nil
        data.progression=Balance.progression(record.state)
        record.prompts.streakCap=data.progression.streakCap
        data.progressionSequence=record.progressionSequence or 0
        data.progressionReply=progressionReply or record.progressionReply
        data.progressionSyncId=progressionSyncId
        data.upgradeSequence=record.upgradeSequence or 0
        data.upgradeSyncId=upgradeSyncId
        if record.upgradeReply then
            data.upgradeReply={}
            for key,value in pairs(record.upgradeReply) do data.upgradeReply[key]=value end
        end
        data.rate = 0
        data.moneyPerToken = PromptSession.baseReward(record.state, Balance, Simulation,unixNow)
        data.tokenLimit = Prompt.limit(record.state, Balance)
        data.agentTypingSpeed = record.prompts.agentPace.rate
        data.totalAgentTypingSpeed = record.prompts.agentPace.totalRate
        data.agentTypingCaps={}
        for index,agent in ipairs(record.prompts.agentPace.agents) do data.agentTypingCaps[index]=agent.rate end
        data.agentWordsPerSecond=record.prompts.agentPace.productionRate
        data.totalAgentWordsPerSecond=record.prompts.agentPace.totalProductionRate
        data.nextAgentDelay=Auto.delay(record.prompts,agentNow,Balance)
        data.nextAgentAt=agentClock+data.nextAgentDelay
        local cooldown=record.prompts.skillSettings and record.prompts.skillSettings.promptCooldown or 0
        data.promptReadyAt=agentClock+math.max(0,cooldown-(agentNow-record.lastManual))
        if RunService:IsStudio() then data.studioTuning=Tuning.view(record.prompts.skillSettings) end
        data.stats = PromptSession.statistics(record.prompts, os.clock())
        -- Compact read-only per-token amounts drive collection; accounting stays server-side.
        data.lastPrompt = Prompt.receiptView(record.lastPrompt, false)
        local draft = assert(PromptSession.ensure(record.prompts, record.state, Balance, Prompt, chooseReward, os.clock()))
        assert(Skill.ensure(record.prompts,draft,Workspace:GetServerTimeNow(),chooseReward))
        data.skillCheck=Skill.view(record.prompts)
        data.streakAvatars=Collectibles.view(record.prompts)
        data.lastAvatarCollect=record.prompts.lastAvatarCollect
        data.avatarRejected=avatarReply and avatarReply.rejected
        data.avatarSyncId=avatarReply and avatarReply.syncId
        data.streakDivisor=Rules.streakDivisor(record.state,Balance)
        data.skillRejected=skillRejected or nil
        data.skillSyncId=skillSyncId
        if record.prompts.autoReceipt then
            data.lastAgent={}
            for key,value in pairs(record.prompts.autoReceipt) do data.lastAgent[key]=value end
        end
        data.agentRejected=agentRejected;data.agentSyncId=agentSyncId
        if forceDraft or record.sentDraftId ~= draft.id or record.sentDraftSize ~= #draft.offers then
            data.draft = PromptSession.wire(draft)
            record.sentDraftId, record.sentDraftSize = draft.id, #draft.offers
        end
        data.storageMode = config.STORAGE_MODE
        data.persistence={status=repository and (record.saveStatus or "saved") or "session",
            lastSavedAt=record.lastSavedAt,mode=config.STORAGE_MODE}
        data.buildVersion = Balance.BUILD_VERSION
        data.experimentId = config.EXPERIMENT_ID
        data.blocked = record.blocked
        data.message = message
        data.promptRejected = promptRejected == true or nil
        stateRemote:FireClient(player, data)
    end

    local function save(record, release)
        metric("settle",record)
        if not repository then return true end
        if record.saving then return false, "save_busy" end
        record.saving = true
        record.saveStatus="saving"
        local ok, reason = repository:save(record.handle, release)
        record.saving = false
        record.saveStatus=ok and "saved" or "delayed"
        if ok then record.lastSavedAt=os.time() end
        if not ok then
            warn("[VibeIdle] Save failed: " .. tostring(reason))
            if reason == "lease_lost" or reason == "unsupported_schema" then record.blocked = true end
        end
        return ok
    end

    local function close(record)
        if record.closing then return end
        advance(record)
        record.closing = true
        metric("finish",record)
        closingCount = closingCount + 1
        if repository then
            local deadline = os.clock() + 8
            while (record.saving or record.receiptBusy) and os.clock() < deadline do task.wait(0.1) end
            -- Never bypass a concurrent save or invent a new profile on failure.
            if record.saving or record.receiptBusy then warn("[VibeIdle] Close timed out; lease will expire")
            else
                local ok = save(record, true)
                if not ok then warn("[VibeIdle] Final save unconfirmed; inspect DataStore logs before release") end
            end
        end
        closingCount = closingCount - 1
    end

    local archive
    if repository and config.COMMERCE_ENABLED then archive=DataStoreService:GetDataStore(config.COMMERCE_RECEIPTS_NAME) end
    commerce=Commerce.new({config=config,market=MarketplaceService,players=Players,archive=archive,balance=Balance,premium=Premium,
        decisions=Enum.ProductPurchaseDecision,unix=os.time,clock=os.clock,studio=RunService:IsStudio(),published=(game.GameId or 0)>0,
        getRecord=function(player) return records[player] end,save=save,publish=snapshot,
        onEvent=function(record,phase,sku) metric("commerce",record,phase,sku) end})
    commerce:bind()

    local function added(player)
        if stopping or records[player] or loading[player] then return end
        loading[player] = true
        local now = os.clock()
        local record = { state = State.new(Balance), lastAdvance = now, lastSnapshot=now, lastManual = -math.huge,
            limiter = RateLimiter.new(Balance.REQUESTS_PER_SECOND, Balance.REQUEST_BURST, now),
            skillLimiter=RateLimiter.new(Balance.TYPING_BASE_RATE+Balance.MAX_TYPING_LEVEL*Balance.TYPING_RATE_PER_LEVEL+4,
                Balance.REQUEST_BURST,now),
            avatarLimiter=RateLimiter.new(12,12,now),
            agentLimiter=RateLimiter.new(Balance.AGENT_REQUESTS_PER_SECOND,Balance.AGENT_REQUEST_BURST,now),
            saving = false, closing = false, blocked = false, prompts = PromptSession.new() }
        if repository then
            local handle, reason = repository:acquire("User_" .. player.UserId,
                game.JobId .. ":" .. HttpService:GenerateGUID(false))
            if not handle then
                loading[player] = nil
                warn("[VibeIdle] Profile load refused: " .. tostring(reason))
                if player.Parent == Players then
                    player:Kick("Your progress could not be loaded safely. Please try joining again shortly.")
                end
                return
            end
            record.handle, record.state = handle, handle.state
            record.saveStatus,record.lastSavedAt="saved",os.time()
        end
        record.lastAdvance = os.clock()
        record.prompts.autoTime=record.lastAdvance
        Auto.advance(record.prompts,record.state,record.lastAdvance,Balance,Rules,Skill,Cards)
        loading[player] = nil
        if player.Parent ~= Players or stopping then close(record); return end
        records[player] = record
        local analyticsOk=pcall(function() telemetry:begin(player,record,HttpService:GenerateGUID(false)) end)
        if not analyticsOk then warn("[VibeIdle] Analytics session unavailable; gameplay continues") end
        Telemetry.milestone(player, record.state, "joined", config)
        snapshot(player, record)
        task.spawn(function() commerce:reconcile(player,record);commerce:checkPass(player,record) end)
    end

    commandRemote.OnServerEvent:Connect(function(player, action, layerIndex, ...)
        local record = records[player]
        if not record or record.closing or stopping then return end
        -- Rate limit every packet before inspecting its payload.
        local now = os.clock()
        local purchaseTime=os.time()
        local limiter=(action=="auto_skill" or action=="skill_click" or action=="skill_sync") and record.skillLimiter
            or (action=="agent_type" or action=="agent_sync") and record.agentLimiter
            or (action=="collect_avatar" or action=="avatar_sync" or action=="avatar_poll") and record.avatarLimiter or record.limiter
        if not RateLimiter.allow(limiter, now) then return end
        if select("#", ...) > 0 or not Protocol.validate(action, layerIndex, Balance) then return end
        if action=="analytics_pulse" then metric("pulse",record,layerIndex);return end
        if record.receiptBusy then snapshot(player,record,"Purchase is saving. Please wait.");return end
        -- Settle and submit at the same captured time; sampling again makes submit
        -- appear to go backward and incorrectly rejects every prompt as too fast.
        advance(record, now)
        if record.blocked then snapshot(player, record, "Progress paused to protect your data. Please rejoin."); return end
        if action=="premium_buy" then commerce:buy(player,record,layerIndex.sku,layerIndex.requestId);return end
        if action=="premium_check" then
            record.premiumCheckId=layerIndex.requestId;commerce:reconcile(player,record);commerce:checkPass(player,record);snapshot(player,record);return
        end
        if action=="premium_redeem" then
            if layerIndex.requestId>(record.premiumSequence or 0) then
                record.premiumSequence=layerIndex.requestId
                local _,message=Premium.redeem(record.state,Balance);record.premiumMessage=message
            end
            snapshot(player,record);return
        end
        if action == "sync" then snapshot(player, record, nil, nil, true); return end
        if action=="tutorial_complete" then
            -- Cosmetic preference only; repeated/skipped tutorials grant nothing.
            if not record.state.tutorialDone then metric("action",record,"tutorialDismissed",1);metric("event",record,"tutorial","dismissed",1) end
            record.state.tutorialDone=true;snapshot(player,record);return
        end
        if action=="upgrade_sync" then
            snapshot(player,record,nil,nil,true,nil,nil,nil,nil,nil,nil,nil,layerIndex.requestId);return
        end
        if action=="prestige_sync" then
            snapshot(player,record,nil,nil,true,nil,nil,nil,nil,nil,nil,layerIndex.requestId);return
        end
        if action=="prestige" or action=="buy_skill" or action=="equip_card" or action=="unequip_card" or action=="craft_card" then
            local id=layerIndex.requestId
            if id<=(record.progressionSequence or 0) then
                local reply=record.progressionReply
                if not reply or reply.requestId~=id then reply={requestId=id,ok=false,message="Expired request. Refresh and try again."} end
                snapshot(player,record,nil,nil,true,nil,nil,nil,nil,nil,reply);return
            end
            record.progressionSequence=id
            local ok,message
            if action=="prestige" then
                if not record.prompts.draft or layerIndex.draftId~=record.prompts.draft.id then
                    ok,message=false,"Draft changed. Review the prestige preview again."
                else
                    ok,message=Prestige.ascend(record.state,Balance,State,purchaseTime)
                    if ok then
                        message="Prestige complete. Chips, skills and cards preserved."
                        PromptSession.reset(record.prompts);record.prompts.autoTime=now
                        record.lastPrompt=nil;record.lastManual=-math.huge
                        Auto.advance(record.prompts,record.state,now,Balance,Rules,Skill,Cards)
                    end
                end
            elseif action=="buy_skill" then ok,message=Prestige.buy(record.state,layerIndex.nodeId,Balance)
            elseif action=="craft_card" then ok,message=Craft.purchase(record.state,layerIndex.cardId,Balance)
            elseif action=="equip_card" then ok,message=Cards.equip(record.state,layerIndex.slotIndex,layerIndex.cardId,Balance)
            else ok,message=Cards.unequip(record.state,layerIndex.slotIndex,Balance) end
            record.progressionReply={requestId=id,action=action,ok=ok,message=message}
            if ok then
                if action=="prestige" then metric("action",record,"prestiges",1);metric("event",record,"prestige","ascend",1)
                elseif action=="buy_skill" then metric("map",record,"skills",layerIndex.nodeId,1);metric("event",record,"skill_buy",layerIndex.nodeId,1);metric("queue",record,"CoreAction",1,"skill_"..layerIndex.nodeId,telemetry:stage(record))
                elseif action=="craft_card" then metric("map",record,"crafts",layerIndex.cardId,1);metric("event",record,"craft",layerIndex.cardId,1);metric("queue",record,"CoreAction",1,"craft_"..layerIndex.cardId,telemetry:stage(record)) end
            end
            snapshot(player,record,nil,nil,true,nil,nil,nil,nil,nil);return
        end
        if action=="avatar_poll" then
            Collectibles.poll(record.prompts,record.state,layerIndex.requestId,Workspace:GetServerTimeNow(),chooseAvatar,Balance)
            snapshot(player,record);return
        end
        if action=="collect_avatar" or action=="avatar_sync" then
            local reply={}
            if action=="avatar_sync" then reply.syncId=layerIndex.id
            else
                local prior=record.prompts.fragmentReceipts and record.prompts.fragmentReceipts[layerIndex.id]
                local ok=Collectibles.collectFragments(record.prompts,record.state,layerIndex.id,Workspace:GetServerTimeNow(),Balance)
                if ok and not prior then metric("action",record,"visitors",1);metric("action",record,"fragmentsCollected",record.prompts.lastAvatarCollect.fragments) end
                if not ok then reply.rejected=layerIndex.id end
            end
            snapshot(player,record,nil,nil,nil,nil,nil,nil,nil,reply);return
        end
        if action=="agent_sync" then
            snapshot(player,record,nil,nil,nil,nil,nil,nil,layerIndex.requestId);return
        end
        if action=="agent_type" then
            local ok=Auto.grant(record.prompts,record.state,layerIndex,now,Balance,Rules,Skill,Cards)
            snapshot(player,record,nil,nil,nil,nil,nil,not ok and layerIndex.requestId or nil);return
        end
        if action=="skill_sync" then
            snapshot(player,record,nil,nil,nil,nil,layerIndex.checkId);return
        end
        if action=="skill_click" or action=="auto_skill" then
            local ok,result
            if action=="auto_skill" then
                ok,result=Skill.auto(record.prompts,record.prompts.draft,layerIndex,Workspace:GetServerTimeNow(),
                    Balance.progression(record.state).autoSkillCap,Balance.AUTO_SKILL_INTERVAL,chooseReward)
            else ok,result=Skill.click(record.prompts,record.prompts.draft,layerIndex,Workspace:GetServerTimeNow(),0,chooseReward) end
            if ok then metric("action",record,action=="auto_skill" and "autoChecks" or result.grade=="Great" and "skillGreat" or result.grade=="Good" and "skillGood" or "skillMiss",1)
            elseif action=="skill_click" then metric("action",record,"skillRejected",1) end
            local message
            if not ok then message="Check not ready. Click again when the marker starts." end
            snapshot(player,record,message,nil,nil,not ok and layerIndex.checkId or nil)
            return
        end
        if action == "submit_prompt" then
            local ok, receipt = PromptSession.submit(record.prompts, record.state, layerIndex, now, record.lastManual, Balance, Prompt, Simulation, chooseReward,purchaseTime)
            if not ok then metric("action",record,"saleRejected",1);snapshot(player, record, messages[receipt] or "Prompt could not be processed.", true, true); return end
            metric("action",record,"sales",1);metric("action",record,"tokensSold",receipt.tokens);metric("action",record,"moneyEarned",receipt.reward)
            record.lastManual = now
            record.lastPrompt = receipt
            Telemetry.milestone(player, record.state, "first_batch", config)
            snapshot(player, record)
            return
        end
        local ok,reason
        if layerIndex then
            local id=layerIndex.requestId
            if id<=(record.upgradeSequence or 0) then snapshot(player,record);return end
            record.upgradeSequence=id
            ok,reason=Rules.purchaseMany(record.state,action,layerIndex.quantity,Balance)
            record.upgradeReply={requestId=id,action=action,quantity=layerIndex.quantity,ok=ok,
                count=ok and reason.count or 0,cost=ok and reason.cost or 0}
        else ok,reason=Rules.purchase(record.state,action,nil,Balance) end
        if ok then
            metric("upgrade",record,action,layerIndex and reason.count or 1,layerIndex and reason.cost or reason)
            local milestone = { add_layer = "first_layer", upgrade_compute = "first_compute" }
            if milestone[action] then Telemetry.milestone(player, record.state, milestone[action], config) end
            snapshot(player, record, "Workstation upgrade applied.")
        else
            snapshot(player, record, messages[reason] or "This action is not available.")
        end
    end)

    -- Tooling endpoints are created only in Studio, never in published servers.
    if RunService:IsStudio() then
        local devRemote = Instance.new("RemoteEvent")
        devRemote.Name = "StudioCommand"
        devRemote.Parent = remoteFolder
        devRemote.OnServerEvent:Connect(function(player, action, direction, ...)
            local record = records[player]
            if not RunService:IsStudio() or not record or record.closing or record.blocked then return end
            if select("#",...)>0 or type(action)~="string" then return end
            if direction~=nil and direction~=1 and direction~=-1 then return end
            local now=os.clock()
            if not RateLimiter.allow(record.limiter, now) then return end
            if not Tuning.byAction[action] and direction~=nil then return end
            advance(record,now)
            if action == "grant" then
                record.state.credits = math.min(Balance.MAX_CREDITS, record.state.credits + 1000000000)
            elseif Tuning.byAction[action] or action=="tuning_reset" then
                local session=record.prompts
                local settings=action=="tuning_reset" and {} or session.skillSettings or {}
                if action~="tuning_reset" then Tuning.cycle(settings,action,direction or 1) end
                session.skillSettings=settings
                Auto.advance(session,record.state,now,Balance,Rules,Skill,Cards)
                local clock=Workspace:GetServerTimeNow()
                if session.lastStreakActivity then Skill.refreshDeadline(session,session.lastStreakActivity) end
                Skill.expireStreak(session,clock)
                Skill.retime(session,clock)
            elseif action == "reset" and config.STORAGE_MODE == "MEMORY" then
                record.state = State.new(Balance)
                record.lastAdvance, record.lastManual = os.clock(), -math.huge
                record.lastPrompt = nil
                PromptSession.reset(record.prompts)
                record.prompts.autoTime=os.clock()
            else return end
            snapshot(player, record, "Studio test command completed.")
        end)
    end

    Players.PlayerAdded:Connect(function(player) task.spawn(added, player) end)
    Players.PlayerRemoving:Connect(function(player)
        local record = records[player]
        records[player] = nil
        if record then close(record) end
    end)
    for _, player in ipairs(Players:GetPlayers()) do task.spawn(added, player) end

    local accumulated = 0
    RunService.Heartbeat:Connect(function(dt)
        if stopping then return end
        accumulated = accumulated + dt
        if accumulated < 0.1 then return end
        accumulated = 0
        local now=os.clock()
        for player, record in pairs(records) do
            if record.telemetry and not record.closing then metric("tick",record) end
            local interval=record.prompts.skillSettings and record.prompts.skillSettings.snapshotInterval or Balance.SNAPSHOT_INTERVAL
            if not record.closing and now-(record.lastSnapshot or 0)>=interval then
                record.lastSnapshot=now;advance(record,now);snapshot(player, record)
            end
        end
    end)

    -- ServerStorage never replicates this developer read-only report to clients.
    local report=Instance.new("BindableFunction");report.Name="VibeIdleAnalyticsReport"
    report.OnInvoke=function(userId)
        if not State.isFinite(userId) or userId%1~=0 or userId<1 or userId>=9007199254740992 then return {error="invalid_user_id"} end
        local player=Players:GetPlayerByUserId(userId);local record=player and records[player]
        if record and record.telemetry then return metric("report",record) end
        if not profileStore then return {error="not_loaded_in_memory"} end
        local ok,stored=pcall(function() return profileStore:GetAsync("User_"..userId) end)
        if not ok then return {error="storage_unavailable"} end
        local parsed=type(stored)=="table" and State.fromStored(stored.data,Balance)
        if not parsed then return {error="profile_unavailable"} end
        return {userId=userId,scope="last_saved",totals=State.copyAnalytics(parsed.analytics)}
    end
    report.Parent=ServerStorage

    if repository then
        task.spawn(function()
            while not stopping do
                task.wait(config.SAVE_INTERVAL)
                for _, record in pairs(records) do
                    if not stopping and not record.closing and not record.blocked and not record.receiptBusy then
                        task.spawn(function() save(record, false) end)
                    end
                end
            end
        end)
    end

    game:BindToClose(function()
        stopping = true
        local pending = 0
        for _, record in pairs(records) do
            if not record.closing then
                pending = pending + 1
                task.spawn(function() close(record); pending = pending - 1 end)
            end
        end
        local deadline = os.clock() + 25
        while (pending > 0 or closingCount > 0) and os.clock() < deadline do task.wait(0.1) end
    end)
    print("[VibeIdle] Started " .. Balance.BUILD_VERSION .. " storage=" .. config.STORAGE_MODE)
end

return GameService

--!nonstrict
local Players = game:GetService("Players")
-- This experience runs entirely in PlayerGui, without a controllable avatar.
Players.CharacterAutoLoads = false

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Start remotes and player records before optional development tests.
require(script.Parent.GameService).start(require(script.Parent.ServerConfig))

if RunService:IsStudio() then
    task.defer(function()
        local ok, reason = pcall(function()
            local Shared = ReplicatedStorage:WaitForChild("Shared")
            local tests = ServerStorage:FindFirstChild("Tests")
            if not tests or not tests:FindFirstChild("Specs") or not tests:FindFirstChild("PromptSessionSpecs") then
                warn("[VibeIdle] Optional Studio tests missing; gameplay is already running")
                return
            end
            local specs = require(tests.Specs)
            local modules = { Telemetry=require(script.Parent.Telemetry), Premium=require(Shared.PremiumRules), Commerce=require(script.Parent.CommerceService), Craft=require(Shared.AgentCrafting),
                Tree=require(Shared.SkillTreeLayout),
                PrestigeMotion=require(Shared.PrestigeMotion),
                Tuning = require(Shared.StudioTuning), Prestige=require(Shared.PrestigeRules), Cards=require(Shared.AgentCards), Collectibles=require(Shared.StreakCollectibles),
                Balance = require(Shared.Balance), State = require(Shared.State),
                Simulation = require(Shared.Simulation), Rules = require(Shared.UpgradeRules),
                RateLimiter = require(Shared.RateLimiter), Protocol = require(Shared.Protocol),
                ProfileRepository = require(script.Parent.ProfileRepository),
                Layout = require(Shared.NetworkLayout),
                Flow = require(Shared.NetworkFlow), Agent = require(Shared.AgentSession),
                Prompt = require(Shared.PromptRules), Draft = require(Shared.PromptDraft),
                Session = require(Shared.PromptSession), Composer = require(Shared.PromptComposer),
                Cash = require(Shared.CashFeedback),
                Collection = require(Shared.TokenCollection),
                Skill = require(Shared.SkillCheck),
                Auto = require(Shared.AgentAutomation),
                Dance = require(Shared.MascotDance),
                Music = require(Shared.Soundtrack),
            }
            specs.run(modules)
            require(tests.PromptSessionSpecs).run(modules)
            if tests:FindFirstChild("CommerceSpecs") then require(tests.CommerceSpecs).run(modules) end
        end)
        if not ok then warn("[VibeIdle] Studio regression failure (gameplay remains running): " .. tostring(reason)) end
    end)
end

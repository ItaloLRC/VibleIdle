-- CLI entry point; Studio runs Specs through the server bootstrap instead.
local specs = require("./Specs")
local modules = { Telemetry=require("../src/server/Telemetry"), Premium=require("../src/shared/PremiumRules"), Commerce=require("../src/server/CommerceService"), Craft=require("../src/shared/AgentCrafting"),
    Tree=require("../src/shared/SkillTreeLayout"),
    PrestigeMotion=require("../src/shared/PrestigeMotion"),
    Cards=require("../src/shared/AgentCards"),
    Prestige=require("../src/shared/PrestigeRules"),
    Collectibles=require("../src/shared/StreakCollectibles"),
    Tuning = require("../src/shared/StudioTuning"),
    Balance = require("../src/shared/Balance"),
    State = require("../src/shared/State"),
    Simulation = require("../src/shared/Simulation"),
    Rules = require("../src/shared/UpgradeRules"),
    RateLimiter = require("../src/shared/RateLimiter"),
    Protocol = require("../src/shared/Protocol"),
    ProfileRepository = require("../src/server/ProfileRepository"),
    Layout = require("../src/shared/NetworkLayout"),
    Flow = require("../src/shared/NetworkFlow"),
    Agent = require("../src/shared/AgentSession"),
    Prompt = require("../src/shared/PromptRules"),
    Draft = require("../src/shared/PromptDraft"),
    Session = require("../src/shared/PromptSession"),
    Composer = require("../src/shared/PromptComposer"),
    Cash = require("../src/shared/CashFeedback"),
    Collection = require("../src/shared/TokenCollection"),
    Skill = require("../src/shared/SkillCheck"),
    Auto = require("../src/shared/AgentAutomation"),
    Dance = require("../src/shared/MascotDance"),
    Music = require("../src/shared/Soundtrack"),
}
specs.run(modules)
require("./PromptSessionSpecs").run(modules)
require("./CommerceSpecs").run(modules)

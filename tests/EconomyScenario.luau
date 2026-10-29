local B = require("../src/shared/Balance")
local State = require("../src/shared/State")
local Sim = require("../src/shared/Simulation")
local Rules = require("../src/shared/UpgradeRules")
local state = State.new(B)
state.batches = 1
state.credits = Sim.batchReward(state)
print("seconds,credits,credits_per_second,neurons,hidden_layers")
for second = 1, 600 do
    Sim.advance(state, 1, B)
    -- A specific scripted policy, not a model of real player preference.
    if second % 20 == 0 then
        local action = (#state.layerSizes < 4 and second >= 120) and "add_layer" or "upgrade_workers"
        Rules.purchase(state, action, nil, B)
    end
    if second % 30 == 0 then
        print(string.format("%d,%.2f,%.2f,%d,%d", second, state.credits, Sim.rate(state, B), Sim.capacity(state), #state.layerSizes - 2))
    end
end

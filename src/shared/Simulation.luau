--!nonstrict
local Simulation = {}

function Simulation.capacity(state)
    local total = 0
    for index = 2, #state.layerSizes - 1 do total = total + state.layerSizes[index] end
    return total
end

function Simulation.rate(state, balance)
    if state.batches == 0 then return 0 end
    local neurons = Simulation.capacity(state)
    local hiddenLayers = #state.layerSizes - 2
    return neurons * balance.CREDITS_PER_NEURON_SECOND
        * (1 + (hiddenLayers - 1) * balance.DEPTH_BONUS)
        * (1 + state.computeLevel * balance.COMPUTE_BONUS)
end

function Simulation.batchReward(state)
    return 1 + math.floor(Simulation.capacity(state) / 3)
end

function Simulation.advance(state, seconds, balance)
    if type(seconds) ~= "number" or seconds ~= seconds or seconds < 0
        or seconds > balance.MAX_SIMULATION_STEP then
        return false, "invalid_time"
    end
    state.credits = math.min(balance.MAX_CREDITS, state.credits + Simulation.rate(state, balance) * seconds)
    return true
end

return Simulation

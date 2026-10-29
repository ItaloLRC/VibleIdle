--!nonstrict
-- Pure local graph geometry; never changes the authoritative topology or income.
local Layout = {}
Layout.MAX_EDGES = 256

function Layout.fit(layers, width, height)
    local maxCount = 1
    for _, count in ipairs(layers) do maxCount = math.max(maxCount, count) end
    local logicalWidth = math.max(320, (#layers - 1) * 100 + 56)
    local logicalHeight = math.max(240, (maxCount - 1) * 40 + 80)
    -- Grow the scroll canvas, never shrink neurons or the spacing between them.
    local canvasWidth, canvasHeight = math.max(width, logicalWidth), math.max(height, logicalHeight)
    local result = { width = logicalWidth, height = logicalHeight, scale = 1, positions = {},
        viewportWidth = width, viewportHeight = height, canvasWidth = canvasWidth, canvasHeight = canvasHeight,
        offsetX = (canvasWidth - logicalWidth) / 2, offsetY = (canvasHeight - logicalHeight) / 2 }
    for layer, count in ipairs(layers) do
        local x = 28 + (layer - 1) * (logicalWidth - 56) / (#layers - 1)
        result.positions[layer] = {}
        for neuron = 1, count do
            result.positions[layer][neuron] = { x = x, y = logicalHeight / 2 + (neuron - (count + 1) / 2) * 40 }
        end
    end
    return result
end

function Layout.scroll(fit, previous, selected, reveal)
    local maxX, maxY = fit.canvasWidth - fit.viewportWidth, fit.canvasHeight - fit.viewportHeight
    local x = previous and previous.x or maxX / 2
    local y = previous and previous.y or maxY / 2
    -- Keep the same distance from the vertical center when widths/viewport change.
    if previous and previous.maxY then y = y + (maxY - previous.maxY) / 2 end
    if reveal and selected and fit.positions[selected] then
        local target = fit.offsetX + fit.positions[selected][1].x
        if target < x + 32 then x = target - 32 end
        if target > x + fit.viewportWidth - 32 then x = target - fit.viewportWidth + 32 end
    end
    return { x = math.max(0, math.min(maxX, x)), y = math.max(0, math.min(maxY, y)) }
end

function Layout.edges(layers)
    local result = {}
    local perGap = math.floor(Layout.MAX_EDGES / (#layers - 1))
    for layer = 1, #layers - 1 do
        local count = math.min(layers[layer] * layers[layer + 1], perGap)
        local seen, used = {}, 0
        local function append(from, to)
            local key = from .. ":" .. to
            if used < count and not seen[key] then
                seen[key], used = true, used + 1
                result[#result + 1] = { layer = layer, from = from, to = to }
            end
        end
        -- Cover all current sources/destinations before adding more sampled links.
        for sample = 0, math.min(count, math.max(layers[layer], layers[layer + 1])) - 1 do
            append(sample % layers[layer] + 1, sample % layers[layer + 1] + 1)
        end
        for offset = 0, layers[layer + 1] - 1 do
            for from = 1, layers[layer] do
                append(from, (from - 1 + offset) % layers[layer + 1] + 1)
                if used == count then break end
            end
            if used == count then break end
        end
    end
    return result
end

return Layout

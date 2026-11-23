-- learns the real max energy, rage and focus per character, without trusting one odd reading
local _, ns = ...

local PowerMax = {}
ns.PowerMax = PowerMax

local type, pairs, floor = type, pairs, math.floor

PowerMax.SETTLE = 0.5 -- never read in the same frame as the change
PowerMax.APART = 1

-- the API and the saved table come in through Init, so the tests can fake them
local api
local store
local pending = {player = {}, pet = {}}
local lastMana = {}
local eventCount = 0

local UNITS = {player = true, pet = true}

local function defaultMax(powerType)
    local resource = ns.Resources.TYPES[powerType]
    if resource then return resource.defaultMax end
    return ns.Resources.FALLBACK_MAX
end

local function markRecheck()
    for _, byType in pairs(store) do
        if type(byType) == "table" then for _, entry in pairs(byType) do entry.recheck = true end end
    end
end

function PowerMax.Init(charStore, functions, build)
    store, api = charStore, functions
    store.player = store.player or {}
    store.pet = store.pet or {}
    if build and store.build ~= build then
        if store.build then markRecheck() end
        store.build = build
    end
    pending = {player = {}, pet = {}}
end

local function usableNumber(value)
    return not api.IsSecret(value) and type(value) == "number" and value > 0 and value == floor(value)
end

-- one reading proves nothing, two equal ones from different events or a moment apart do
local function read(unit, expected, event, tick)
    local powerType = api.UnitPowerType(unit)
    if api.IsSecret(powerType) or type(powerType) ~= "number" then return end
    if expected and powerType ~= expected then return end
    local default = defaultMax(powerType)
    if not default or not api.CanRead(unit) then return end
    local value = api.UnitPowerMax(unit, powerType)
    if not usableNumber(value) or value < default / 2 or value > default * 3 then return end
    local after = api.UnitPowerType(unit)
    if api.IsSecret(after) or after ~= powerType then return end

    local candidate = pending[unit][powerType]
    if candidate and candidate.value == value and (candidate.event ~= event or candidate.tick ~= tick) then
        store[unit][powerType] = {value = value}
        pending[unit][powerType] = nil
    else
        pending[unit][powerType] = {value = value, event = event, tick = tick}
    end
end

local function schedule(unit, expected, delay)
    eventCount = eventCount + 1
    local event = eventCount
    api.After(delay, function() read(unit, expected, event, 1) end)
    api.After(delay + PowerMax.APART, function() read(unit, expected, event, 2) end)
end

function PowerMax.OnEvent(event, unit, token)
    if not store then return end
    if event == "UNIT_MAXPOWER" then
        if not UNITS[unit] or api.IsSecret(token) then return end
        local powerType, current = api.UnitPowerType(unit)
        if api.IsSecret(current) or current ~= token then return end
        schedule(unit, powerType, 0.1)
    elseif event == "UNIT_DISPLAYPOWER" then
        if UNITS[unit] then schedule(unit, nil, PowerMax.SETTLE) end
    elseif event == "UNIT_PET" then
        if unit == "player" then schedule("pet", nil, PowerMax.SETTLE) end
    elseif event == "UPDATE_SHAPESHIFT_FORM" or event == "PLAYER_ENTERING_WORLD" then
        schedule("player", nil, PowerMax.SETTLE)
    else
        -- talents, gear, level: keep the values but check them again
        markRecheck()
        schedule("player", nil, PowerMax.SETTLE)
        schedule("pet", nil, PowerMax.SETTLE)
    end
end

-- mana depends on stats, so it's always read live
function PowerMax.Get(unit, powerType)
    local default = defaultMax(powerType)
    if not default then
        local value = api and api.UnitPowerMax(unit, powerType)
        if api and usableNumber(value) then
            lastMana[unit] = value
            return value
        end
        return lastMana[unit]
    end
    local entry = store and store[unit] and store[unit][powerType]
    return entry and entry.value or default
end

function PowerMax.NeedsCheck(unit, powerType)
    local entry = store and store[unit] and store[unit][powerType]
    return entry and entry.recheck or false
end

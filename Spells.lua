-- reading spell data from the game
local _, ns = ...

local Spells = {}
ns.Spells = Spells

local isSecret = ns.IsSecret
local type, ipairs, pairs = type, ipairs, pairs

local function number(value) if not isSecret(value) and type(value) == "number" then return value end end
local function text(value) if not isSecret(value) and type(value) == "string" then return value end end
local function flag(value) return not isSecret(value) and value == true end
Spells.Number, Spells.Text = number, text

function Spells.Description(spellID)
    local desc = C_Spell.GetSpellDescription(spellID)
    if isSecret(desc) then return nil, true end
    if type(desc) == "string" and desc ~= "" then return desc end
    return nil, false
end

function Spells.Name(spellID)
    local info = C_Spell.GetSpellInfo(spellID)
    return type(info) == "table" and text(info.name) or nil
end

function Spells.Flags(spellID)
    return flag(C_Spell.IsSpellHarmful(spellID)), flag(C_Spell.IsSpellHelpful(spellID))
end

-- the client's own "Channeled" line, works in any language
function Spells.IsChanneled(spellID)
    local channeled = text(SPELL_CAST_CHANNELED)
    if not channeled or not C_TooltipInfo then return false end
    local data = C_TooltipInfo.GetSpellByID(spellID)
    local lines = type(data) == "table" and not isSecret(data) and data.lines
    if type(lines) ~= "table" then return false end
    for _, line in ipairs(lines) do if text(line.leftText) == channeled then return true end end
    return false
end

function Spells.Timings(spellID, t)
    local info = C_Spell.GetSpellInfo(spellID)
    local cast = type(info) == "table" and number(info.castTime)
    t.cast = cast and cast / 1000 or 0
    local cooldown, gcd = GetSpellBaseCooldown(spellID)
    t.cooldown = (number(cooldown) or 0) / 1000
    t.gcd = (number(gcd) or 0) / 1000
    t.channeled = Spells.IsChanneled(spellID)
    return t
end

-- Cat and Bear Form can report odd costs for caster spells, or none
local function inForm(unit, powerType)
    local current = UnitPowerType(unit)
    return isSecret(current) or current ~= powerType
end

local entries, percents, known = {}, {}, {}

-- matched by type, never by list position or the current power
function Spells.Costs(spellID, unit, out, free, basePercent)
    wipe(entries)
    wipe(percents)
    local list = C_Spell.GetSpellPowerCost(spellID)
    if type(list) == "table" and not isSecret(list) then
        for _, entry in ipairs(list) do
            local powerType = number(entry.type)
            if powerType then
                local required = number(entry.requiredAuraID)
                local applies = not required or required == 0 or flag(entry.hasRequiredAura)
                -- Skull Bash: one entry per form, the one for the current form wins
                if applies or entries[powerType] == nil then
                    entries[powerType] = number(entry.cost) or false
                    percents[powerType] = number(entry.costPercent)
                end
            end
        end
    end
    -- a form can drop the mana entry completely
    for powerType in pairs(ns.NormalCost.Known(spellID, known)) do
        if entries[powerType] == nil then entries[powerType] = false end
    end
    wipe(known)
    for powerType, cost in pairs(entries) do
        local shown, isFree = ns.NormalCost.Get(spellID, powerType, cost or nil, inForm(unit, powerType))
        if shown then out[powerType] = shown end
        if isFree and not (percents[powerType] and percents[powerType] > 0) then free[powerType] = true end
        if percents[powerType] and percents[powerType] > 0 then basePercent[powerType] = percents[powerType] end
    end
end

-- by type, never the current power, or a druid in Cat Form gets max energy
function Spells.MaxPower(unit, powerType) return ns.PowerMax.Get(unit, powerType) end

-- the client's own names first, ours if one is missing
local fallbackNames

function Spells.ResourceNames(powerType, L)
    local resource = ns.Resources.TYPES[powerType]
    if not resource then return nil end
    fallbackNames = fallbackNames or {
        MANA = {L["Mana"], L["%s Mana"]},
        RAGE = {L["Rage"], L["%s Rage"]},
        FOCUS = {L["Focus"], L["%s Focus"]},
        ENERGY = {L["Energy"], L["%s Energy"]},
        COMBO_POINTS = {L["Combo Points"], L["%s Combo Points"]},
    }
    local fallback = fallbackNames[resource.token]
    local name = text(_G[resource.nameTag])
    local costFormat = text(_G[resource.costTag])
    if not costFormat or not costFormat:find("%s", 1, true) then costFormat = nil end
    return {name = name or fallback[1], costFormat = costFormat or fallback[2]}
end

-- Crit

local SCHOOL_INDEX = {PHYSICAL = 1, HOLY = 2, FIRE = 3, NATURE = 4, FROST = 5, SHADOW = 6, ARCANE = 7}
local lastCrit = {} -- last readable value per kind, stats turn secret in combat
local talentRanks = {}
local critTalents -- [spellID] = list of CritData talent entries

-- ranks from the active talent config. a talent the config doesn't list counts as fully known if the spell is
function Spells.ScanTalents()
    wipe(talentRanks)
    if not (C_ClassTalents and C_Traits and C_ClassTalents.GetActiveConfigID) then return end
    local ok, config = pcall(C_ClassTalents.GetActiveConfigID)
    if not ok or not number(config) then return end
    local info = C_Traits.GetConfigInfo(config)
    for _, tree in ipairs(type(info) == "table" and info.treeIDs or {}) do
        for _, node in ipairs(C_Traits.GetTreeNodes(tree) or {}) do
            local nodeInfo = C_Traits.GetNodeInfo(config, node)
            local rank = type(nodeInfo) == "table" and number(nodeInfo.currentRank)
            local entry = rank and rank > 0 and nodeInfo.activeEntry and C_Traits.GetEntryInfo(config, nodeInfo.activeEntry.entryID)
            local definition = type(entry) == "table" and number(entry.definitionID) and C_Traits.GetDefinitionInfo(entry.definitionID)
            local spellID = type(definition) == "table" and number(definition.spellID)
            if spellID then talentRanks[spellID] = rank end
        end
    end
end

function Spells.TalentRank(spellID) return talentRanks[spellID] end

local function talentValue(ranks)
    local best = 0
    for talent, values in pairs(ranks) do
        local rank = talentRanks[talent]
        -- one spell per rank (Force of Will) isn't in every config, a known one is that rank
        if not rank and (#values == 1 or next(talentRanks) == nil) and IsPlayerSpell(talent) then rank = #values end
        if rank and rank > 0 then best = math.max(best, values[math.min(rank, #values)]) end
    end
    return best
end

local function talentsFor(spellID)
    if not critTalents then
        critTalents = {}
        for _, entry in ipairs(ns.CritData.talents) do
            for _, id in ipairs(entry.spells) do
                critTalents[id] = critTalents[id] or {}
                table.insert(critTalents[id], entry)
            end
        end
    end
    return critTalents[spellID]
end

local function sheetCrit(kind, school)
    local key = kind == "spell" and "spell" .. (SCHOOL_INDEX[school] or 2) or kind
    local value
    if kind == "melee" then
        value = GetCritChance()
    elseif kind == "ranged" then
        value = GetRangedCritChance()
    else
        value = GetSpellCritChance(SCHOOL_INDEX[school] or 2)
    end
    value = number(value)
    if value then lastCrit[key] = value / 100 end
    return lastCrit[key]
end

-- "melee", "ranged" or "spell": abilities that need a ranged weapon, physical damage, and everything else
function Spells.CritKind(spellID, school, isHeal)
    if not Spells.ranged then
        Spells.ranged = {}
        for _, id in ipairs(ns.CritData.ranged) do Spells.ranged[id] = true end
    end
    if Spells.ranged[spellID] then return "ranged" end
    if not isHeal and (school == nil or school == "PHYSICAL") then return "melee" end
    return "spell"
end

-- pets copy their owner's crit: a hunter's pet takes the higher of melee and ranged, a warlock's pet the spell crit.
-- false when the pet's owner is some other class
function Spells.PetCrit(kind, school)
    local _, class = UnitClass("player")
    class = text(class)
    local chance
    if class == "HUNTER" then
        local melee, ranged = sheetCrit("melee"), sheetCrit("ranged")
        chance = melee and ranged and math.max(melee, ranged) or melee or ranged
    elseif class == "WARLOCK" then
        chance = sheetCrit("spell", school and school ~= "PHYSICAL" and school or "SHADOW")
    else
        return false
    end
    return chance, ns.Metrics.CritMultiplier(kind, 0)
end

-- chance (0 to 1, nil while never readable), multiplier and the talent parts, for one spell
function Spells.Crit(spellID, kind, school)
    local chance = sheetCrit(kind, school)
    local extraChance, bonus = 0, 0
    for _, entry in ipairs(talentsFor(spellID) or {}) do
        if entry.chance then extraChance = extraChance + talentValue(entry.chance) end
        if entry.bonus then bonus = bonus + talentValue(entry.bonus) end
    end
    if chance then chance = chance + extraChance / 100 end
    return chance, ns.Metrics.CritMultiplier(kind, bonus)
end

-- spell rules: hide a spell's lines or pin its average damage
local _, ns = ...
local L = ns.L

local Rules = {}
ns.Rules = Rules

local function rules() return ns.addon.db.profile.rules end

local function changed()
    if ns.Options then ns.Options:RefreshActiveTab() end
end

function Rules.Get(spellID) return rules()[spellID] end

function Rules.Hide(spellID)
    rules()[spellID] = {hide = true}
    changed()
end

function Rules.Pin(spellID, average)
    rules()[spellID] = {avg = average}
    changed()
end

function Rules.Remove(spellID)
    rules()[spellID] = nil
    changed()
end

function Rules.Clear()
    wipe(rules())
    changed()
end

function Rules.SpellLabel(spellID)
    local name = ns.Spells.Name(spellID)
    return name and format("%s (%d)", name, spellID) or tostring(spellID)
end

function Rules.List()
    local list = {}
    for spellID, rule in pairs(rules()) do
        if type(spellID) == "number" and type(rule) == "table" then
            list[#list + 1] = {spellID = spellID, rule = rule, label = Rules.SpellLabel(spellID)}
        end
    end
    table.sort(list, function(a, b)
        if a.label ~= b.label then return a.label < b.label end
        return a.spellID < b.spellID
    end)
    return list
end

function Rules.Describe(entry)
    if entry.rule.hide then return format(L["%s: lines hidden"], entry.label) end
    return format(L["%s: average damage %s"], entry.label, tostring(entry.rule.avg))
end

-- a new table, parsed may be the cached one
function Rules.Pinned(parsed, average)
    return {
        dmg = {direct = average, periodic = 0, perHit = 0, school = parsed and parsed.dmg.school},
        heal = parsed and parsed.heal or {direct = 0, periodic = 0, absorb = 0},
        area = parsed and parsed.area or false,
        pinned = true,
    }
end

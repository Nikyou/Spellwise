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

-- a typed average. a separator before exactly three digits groups them: "1,500" is 1500, "1,5" is 1.5.
-- nil unless it's a number above 0
function Rules.ParseAverage(text)
    text = (text or ""):gsub("%s", "")
    if not text:match("^%d[%d,.]*$") then return nil end
    local head, last = text:match("^(.-)[,.](%d*)$")
    local plain
    if head and #last ~= 3 then
        plain = head:gsub("[,.]", "") .. "." .. last
    else
        plain = text:gsub("[,.]", "")
    end
    local average = tonumber(plain)
    if average and average > 0 and average < math.huge then return average end
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

-- a new table, parsed may be cached. a spell that only ticks keeps ticking, so a channel still divides by its time
function Rules.Pinned(parsed, average)
    local dmg = parsed and parsed.dmg
    local ticks = dmg and dmg.direct == 0 and dmg.periodic > 0
    return {
        dmg = {direct = ticks and 0 or average, periodic = ticks and average or 0, duration = ticks and dmg.duration or nil,
               perHit = 0, school = dmg and dmg.school},
        heal = parsed and parsed.heal or {direct = 0, periodic = 0, absorb = 0},
        area = parsed and parsed.area or false,
        pinned = true,
    }
end

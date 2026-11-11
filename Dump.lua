-- /sp dump: the raw spell data, to copy and send when a number looks wrong
local _, ns = ...
local L = ns.L

local Dump = {}
ns.Dump = Dump

local isSecret = ns.IsSecret
local Spells = ns.Spells
local type, tostring, ipairs, pairs = type, tostring, ipairs, pairs
local concat, sort, format = table.concat, table.sort, string.format

local REFRESH_DELAY = 0.5

local HEADER_GLOBALS = {
    "SPELL_CAST_CHANNELED", "RANK", "MANA_COST", "SPELL_CAST_TIME_SEC", "SPELL_RECAST_TIME_SEC", "STRING_SCHOOL_PHYSICAL",
    "STRING_SCHOOL_HOLY", "STRING_SCHOOL_FIRE", "STRING_SCHOOL_NATURE", "STRING_SCHOOL_FROST", "STRING_SCHOOL_SHADOW",
    "STRING_SCHOOL_ARCANE", "MANA", "RAGE", "ENERGY", "FOCUS", "COMBO_POINTS", "RAGE_COST", "ENERGY_COST", "FOCUS_COST",
    "COMBO_POINTS_COST", "SHIFT_KEY", "CTRL_KEY", "ALT_KEY",
}
local COST_FIELDS = {"type", "name", "cost", "minCost", "costPercent", "costPerSec", "requiredAuraID", "hasRequiredAura"}

-- one byte that isn't UTF-8 leaves the whole edit box blank. such bytes, and control characters, become <xNN>
local function cleanBytes(s)
    if not s:find("[\128-\255%z\1-\9\11\12\14-\31]") then return s end
    local out, start, i, n = {}, 1, 1, #s
    while i <= n do
        local c = s:byte(i)
        local len = 1
        if c < 32 then
            len = (c == 10 or c == 13) and 1 or 0
        elseif c >= 0x80 then
            len = (c >= 0xC2 and c <= 0xDF and 2) or (c >= 0xE0 and c <= 0xEF and 3) or (c >= 0xF0 and c <= 0xF4 and 4) or 0
            -- no overlong forms, surrogates or code points past U+10FFFF
            local low = (c == 0xE0 and 0xA0) or (c == 0xF0 and 0x90) or 0x80
            local high = (c == 0xED and 0x9F) or (c == 0xF4 and 0x8F) or 0xBF
            for k = 1, len - 1 do
                local b = s:byte(i + k)
                if not b or b < (k == 1 and low or 0x80) or b > (k == 1 and high or 0xBF) then
                    len = 0
                    break
                end
            end
        end
        if len == 0 then
            out[#out + 1] = s:sub(start, i - 1)
            out[#out + 1] = format("<x%02X>", c)
            i = i + 1
            start = i
        else
            i = i + len
        end
    end
    out[#out + 1] = s:sub(start)
    return concat(out)
end
Dump.CleanBytes = cleanBytes

-- escape | and line breaks so the text shows exactly what the client gave
local function value(v)
    if isSecret(v) then return "<secret>" end
    if v == nil then return "nil" end
    if type(v) == "string" then return '"' .. cleanBytes(v):gsub("|", "||"):gsub("\r", "\\r"):gsub("\n", "\\n") .. '"' end
    return tostring(v)
end

-- in case something else blanks the box: a line the game draws with no width is swapped for its bytes, so the dump
-- still shows and says what was there
local probe
local function checkLines(lines)
    if not probe then
        probe = UIParent:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
        probe:Hide()
    end
    for i, line in ipairs(lines) do
        if line:find("%S") then
            probe:SetText(line)
            local width = probe:GetStringWidth()
            if not isSecret(width) and width == 0 then
                local list = {}
                for k = 1, #line do list[k] = tostring(line:byte(k)) end
                lines[i] = "  <this line doesn't show in the game> bytes " .. concat(list, ",")
            end
        end
    end
    probe:SetText("")
end

local function bytes(v)
    if isSecret(v) or type(v) ~= "string" then return value(v) end
    local list = {}
    for i = 1, #v do list[i] = tostring(v:byte(i)) end
    return value(v) .. " bytes " .. concat(list, ",")
end

-- so a dump taken in a form shows it
local function unitState(out, unit)
    local powerType, token = UnitPowerType(unit)
    out[#out + 1] = format("  %s power = type=%s token=%s", unit, value(powerType), value(token))
    local maxes = {}
    for _, pt in ipairs(ns.Resources.ORDER) do maxes[#maxes + 1] = pt .. ":" .. value(UnitPowerMax(unit, pt)) end
    out[#out + 1] = format("  %s max = %s", unit, concat(maxes, " "))
end

local function auraIDs()
    if C_Secrets and C_Secrets.ShouldAurasBeSecret and C_Secrets.ShouldAurasBeSecret() then return "<secret>" end
    local ids = {}
    for i = 1, 255 do
        local ok, aura = pcall(C_UnitAuras.GetBuffDataByIndex, "player", i)
        if not ok or not aura then break end
        if isSecret(aura) or isSecret(aura.spellId) then return "<secret>" end
        ids[#ids + 1] = tostring(aura.spellId)
    end
    return concat(ids, ", ")
end

-- which crit talents the game says you have, and at which rank
local function critTalents()
    Spells.ScanTalents()
    local list = {}
    for _, entry in ipairs(ns.CritData.talents) do
        for talent in pairs(entry.chance or entry.bonus) do
            local rank = Spells.TalentRank(talent)
            if rank or IsPlayerSpell(talent) then list[#list + 1] = talent .. ":" .. tostring(rank or "known") end
        end
    end
    sort(list)
    return #list > 0 and concat(list, " ") or "none"
end

local function header(out, sections)
    local version, build = GetBuildInfo()
    out[#out + 1] = "Spellwise dump  locale=" .. value(GetLocale()) .. "  client=" .. value(version) .. "  build=" .. value(build)
    for _, name in ipairs(HEADER_GLOBALS) do out[#out + 1] = "  " .. name .. " = " .. value(_G[name]) end
    out[#out + 1] = "  LARGE_NUMBER_SEPERATOR = " .. bytes(LARGE_NUMBER_SEPERATOR)
    out[#out + 1] = "  DECIMAL_SEPERATOR = " .. bytes(DECIMAL_SEPERATOR)
    unitState(out, "player")
    if UnitExists("pet") then unitState(out, "pet") end
    out[#out + 1] = "  player level = " .. value(UnitLevel and UnitLevel("player"))
    out[#out + 1] = "  player form = " .. value(GetShapeshiftFormID and GetShapeshiftFormID())
    out[#out + 1] = "  player auras = " .. auraIDs()
    local crits = {"melee:" .. value(GetCritChance()), "ranged:" .. value(GetRangedCritChance())}
    for school = 1, 7 do crits[#crits + 1] = "spell" .. school .. ":" .. value(GetSpellCritChance(school)) end
    out[#out + 1] = "  player crit = " .. concat(crits, " ")
    out[#out + 1] = "  crit talents = " .. critTalents()
    if sections then out[#out + 1] = "  sections = " .. concat(sections, " ") end
end

local function costLine(entry)
    local parts, done = {}, {}
    for _, key in ipairs(COST_FIELDS) do
        parts[#parts + 1] = key .. "=" .. value(entry[key])
        done[key] = true
    end
    -- fields added in a later client
    local extra = {}
    for key in pairs(entry) do if type(key) == "string" and not done[key] then extra[#extra + 1] = key end end
    sort(extra)
    for _, key in ipairs(extra) do parts[#parts + 1] = key .. "=" .. value(entry[key]) end
    return concat(parts, " ")
end

-- false while the description hasn't loaded
local function spell(out, spellID)
    local function add(key, text) out[#out + 1] = "  " .. key .. " = " .. text end
    out[#out + 1] = ""
    out[#out + 1] = "== spell " .. spellID
    local info = C_Spell.GetSpellInfo(spellID)
    if type(info) ~= "table" then
        out[#out + 1] = "  (no such spell on this client)"
        return true
    end
    add("name", value(info.name))
    add("subtext", value(C_Spell.GetSpellSubtext(spellID)))
    add("castTime (ms)", value(info.castTime))
    local cooldown, gcd = GetSpellBaseCooldown(spellID)
    add("baseCooldown (ms)", value(cooldown) .. "   gcd (ms) = " .. value(gcd))
    add("harmful", value(C_Spell.IsSpellHarmful(spellID)))
    add("helpful", value(C_Spell.IsSpellHelpful(spellID)))
    local costs = C_Spell.GetSpellPowerCost(spellID)
    if type(costs) == "table" and not isSecret(costs) then
        for i, entry in ipairs(costs) do add("cost[" .. i .. "]", costLine(entry)) end
    else
        add("cost", value(costs))
    end
    local desc = C_Spell.GetSpellDescription(spellID)
    add("description", value(desc))
    local data = C_TooltipInfo.GetSpellByID(spellID)
    local lines = type(data) == "table" and not isSecret(data) and data.lines
    if type(lines) == "table" then
        -- the name and description lines repeat what's above, and a long dump has to fit one edit box
        local name, plainDesc = value(info.name), value(desc)
        for i, line in ipairs(lines) do
            local left = value(line.leftText)
            if left ~= name and left ~= plainDesc then
                add("tooltip[" .. i .. "]", "type=" .. value(line.type) .. " left=" .. left .. " right=" .. value(line.rightText))
            end
        end
    else
        add("tooltip", "nil")
    end
    return isSecret(desc) or (type(desc) == "string" and desc ~= "")
end

local current
local waiting = {}
local events = CreateFrame("Frame")
local refreshQueued = false

local function show()
    ns.Options:ShowDialog({
        instance = "dump",
        title = L["Spellwise dump"],
        message = current.missing > 0 and format(L["Loading %d spell(s), the text updates."], current.missing)
                  or L["Copy with Ctrl+A, Ctrl+C and send it to the author."],
        input = {text = current.text, readOnly = true},
        buttons = {{label = L["Close"]}},
    })
end

local function render()
    if not current then return end
    local out, missing, printed = {}, 0, {}
    header(out, current.tokens)
    for _, section in ipairs(current.sections) do
        if section.token then
            out[#out + 1] = ""
            out[#out + 1] = "== class " .. section.token
        end
        for _, spellID in ipairs(section.ids) do
            if printed[spellID] then
                out[#out + 1] = ""
                out[#out + 1] = "== spell " .. spellID .. "  (above)"
            else
                printed[spellID] = true
                if not spell(out, spellID) then
                    missing = missing + 1
                    if not waiting[spellID] then
                        waiting[spellID] = true
                        C_Spell.RequestLoadSpellData(spellID)
                    end
                end
            end
        end
    end
    if missing > 0 then
        events:RegisterEvent("SPELL_DATA_LOAD_RESULT")
        events:RegisterEvent("SPELL_TEXT_UPDATE")
    else
        events:UnregisterAllEvents()
    end
    checkLines(out)
    current.text = concat(out, "\n")
    current.missing = missing
    show()
    return current.text, missing
end

-- loads arrive one by one, so rebuild once shortly after the first
events:SetScript("OnEvent", function(_, _, spellID)
    if isSecret(spellID) or not waiting[spellID] then return end
    waiting[spellID] = nil
    if refreshQueued then return end
    refreshQueued = true
    C_Timer.After(REFRESH_DELAY, function()
        refreshQueued = false
        ns.Guard(render)
    end)
end)

local function lists() return ns.DumpSpells end

function Dump.ClassList()
    local tokens = {}
    for _, token in ipairs(lists().order) do if token ~= "test" then tokens[#tokens + 1] = token end end
    return concat(tokens, ", ")
end

local function start(spec)
    current = spec
    wipe(waiting)
    return render()
end

function Dump.Start(arg)
    arg = strtrim(arg or "")
    local key = arg:lower()
    local data = lists()
    if key == "all" then
        local sections = {}
        for _, token in ipairs(data.order) do sections[#sections + 1] = {token = token, ids = data[token]} end
        return start({sections = sections, tokens = data.order})
    elseif data[key] and key ~= "order" then
        return start({sections = {{token = key, ids = data[key]}}})
    end
    local spellID
    if arg == "" then
        spellID = ns.Tooltip.HoveredSpellID()
        if not spellID then
            ns.Print(L["Hover a spell or name one: /sp dump <spell>"])
            return
        end
    else
        spellID = ns.ResolveSpell(arg)
        if not spellID or not C_Spell.GetSpellInfo(spellID) then
            ns.Print(format(L["\"%s\" is no spell or class. Classes: %s"], arg, Dump.ClassList()))
            return
        end
    end
    return start({sections = {{ids = {spellID}}}})
end

function Dump.CurrentText() return current and current.text end

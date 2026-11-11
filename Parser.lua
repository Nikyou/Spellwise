-- reads damage, healing and absorb amounts out of spell descriptions. no WoW API in here
local _, ns = ...

local Parser = {}
ns.Parser = Parser

local tonumber, ipairs, pairs, type = tonumber, ipairs, pairs, type
local floor = math.floor

-- Normalize writes ranges as "a~b"
local VALUE = "([%d%.]+~?[%d%.]*)"
local NUMBER = "([%d%.]+)"
local PLACEHOLDERS = {
    v = {VALUE, "value"},
    n = {NUMBER, "number"},
    s = {"([^%d%.,;:!%?|]-)", "slot"},
    w = {"[^%d%.,;:!%?|]-"}, -- words of the same clause
    x = {"[^%d|]-"}, -- anything but a number, across clauses
}
local SPACES = {"\194\160", "\226\128\175", "\226\128\137"}
local DASHES = {"-", "\226\128\147", "\226\128\148", "\226\136\146"}

local function escape(s) return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")) end

-- WoW's string.lower touches UTF-8 letters too, so only A-Z
local function lowerChar(c) return string.char(c:byte() + 32) end
local function lowerAscii(s) return (s:gsub("[A-Z]", lowerChar)) end

-- pack pattern to Lua patterns. {d} gets one variant per time unit
local function compile(source, units)
    local variants = {{pattern = "", captures = {}, units = {}}}
    local pos = 1
    while pos <= #source do
        local a, b, name = source:find("{(%a)}", pos)
        local literal = escape(source:sub(pos, (a or #source + 1) - 1))
        for _, variant in ipairs(variants) do variant.pattern = variant.pattern .. literal end
        if not a then break end
        if name == "d" then
            local grown = {}
            for _, variant in ipairs(variants) do
                for _, unit in ipairs(units) do
                    local copy = {pattern = variant.pattern .. NUMBER .. " ?" .. escape(unit[1]), captures = {}, units = {}}
                    for i, kind in ipairs(variant.captures) do copy.captures[i] = kind end
                    for i, factor in pairs(variant.units) do copy.units[i] = factor end
                    copy.captures[#copy.captures + 1] = "duration"
                    copy.units[#copy.captures] = unit[2]
                    grown[#grown + 1] = copy
                end
            end
            variants = grown
        else
            local spec = assert(PLACEHOLDERS[name], "unknown placeholder {" .. name .. "}")
            for _, variant in ipairs(variants) do
                variant.pattern = variant.pattern .. spec[1]
                if spec[2] then variant.captures[#variant.captures + 1] = spec[2] end
            end
        end
        pos = b + 1
    end
    return variants
end

local function prepare(pack)
    if pack.prepared then return end
    local units = pack.units or {}
    pack.compiledRanges = {}
    for _, range in ipairs(pack.ranges or {}) do
        pack.compiledRanges[#pack.compiledRanges + 1] = compile(range, units)[1].pattern
    end
    for _, rule in ipairs(pack.rules) do
        rule.variants = {}
        local sources = type(rule[3]) == "table" and rule[3] or {rule[3]}
        for _, source in ipairs(sources) do
            for _, variant in ipairs(compile(source, units)) do rule.variants[#rule.variants + 1] = variant end
        end
    end
    pack.compiledLasts = {}
    for _, source in ipairs(pack.lasts or {}) do
        for _, variant in ipairs(compile(source, units)) do pack.compiledLasts[#pack.compiledLasts + 1] = variant end
    end
    if pack.comboRow then
        pack.compiledComboRow = {}
        for _, row in ipairs(type(pack.comboRow) == "table" and pack.comboRow or {pack.comboRow}) do
            pack.compiledComboRow[#pack.compiledComboRow + 1] = compile(row, units)[1].pattern
        end
    end
    pack.compiledExtra = {}
    for _, source in ipairs(pack.extraPerPoint or {}) do
        for _, variant in ipairs(compile(source, units)) do pack.compiledExtra[#pack.compiledExtra + 1] = variant end
    end
    pack.prepared = true
end

-- Chinese punctuation ends a clause like the ASCII one
local WIDE_PUNCTUATION = {
    {"\239\188\140", ","}, {"\227\128\130", "."}, {"\239\188\155", ";"}, {"\239\188\154", ":"}, {"\239\188\129", "!"},
    {"\239\188\159", "?"}, {"\227\128\129", ","},
}

-- "1,508 to 1,722" becomes "1508~1722", "0,5" becomes "0.5". a separator only goes before exactly three digits.
-- a pack lists more separators in thousands, German writes "1.508"
function Parser.Normalize(text, pack)
    prepare(pack)
    text = lowerAscii(text) .. " "
    for _, list in ipairs({pack.thousands or {}, {",", " ", SPACES[1], SPACES[2], SPACES[3]}}) do
        for _, sep in ipairs(list) do
            local count
            repeat text, count = text:gsub("(%d)" .. escape(sep) .. "(%d%d%d)([^%d])", "%1%2%3") until count == 0
        end
    end
    for _, space in ipairs(SPACES) do text = text:gsub(space, " ") end
    text = text:gsub("%s+", " ")
    text = text:gsub("(%d),(%d)", "%1.%2")
    for _, pair in ipairs(WIDE_PUNCTUATION) do text = text:gsub(pair[1], pair[2]) end
    for _, dash in ipairs(DASHES) do text = text:gsub("(%d) ?" .. escape(dash) .. " ?(%d)", "%1~%2") end
    for _, compiled in ipairs(pack.compiledRanges or {}) do text = text:gsub(compiled, "%1~%2") end
    return text
end

local function valueOf(s)
    local low, high = s:match("^([%d%.]+)~([%d%.]+)$")
    if low then return (tonumber(low) + tonumber(high)) / 2 end
    return tonumber(s)
end

local function containsAny(text, words)
    for _, word in ipairs(words or {}) do if text:find(word, 1, true) then return true end end
    return false
end

local function findSchool(text, pack)
    for _, entry in ipairs(pack.schools or {}) do if text:find(entry[1], 1, true) then return entry[2] end end
end

-- "30 yards, reducing Physical damage" has a number before "damage" but no amount
local function slotOk(slot, pack)
    for _, entry in ipairs(pack.schools or {}) do slot = slot:gsub(escape(entry[1]), " ") end
    for _, word in ipairs(pack.fillers or {}) do slot = slot:gsub(escape(word), " ") end
    return slot:match("^%s*$") ~= nil
end

local function match(text, variants, pack)
    for _, variant in ipairs(variants) do
        local init = 1
        while true do
            local found = {text:find(variant.pattern, init)}
            local a, b = found[1], found[2]
            if not a then break end
            local caps, ok = {value = {}, number = {}, duration = {}}, true
            for i, kind in ipairs(variant.captures) do
                local raw = found[i + 2]
                if kind == "slot" then
                    ok = ok and slotOk(raw, pack)
                    caps.slot = raw
                elseif kind == "duration" then
                    local list = caps.duration
                    list[#list + 1] = (tonumber(raw) or 0) * variant.units[i]
                else
                    local list = caps[kind]
                    list[#list + 1] = kind == "value" and valueOf(raw) or tonumber(raw)
                end
            end
            if ok then return a, b, caps end
            init = a + 1
        end
    end
end

-- so no later rule reads the same numbers
local function cut(text, a, b) return text:sub(1, a - 1) .. " | " .. text:sub(b + 1) end

local function newResult()
    return {
        dmg = {direct = 0, periodic = 0, perHit = 0},
        heal = {direct = 0, periodic = 0, absorb = 0},
        area = false,
        weapon = false,
        found = false,
    }
end

local function sideFor(rule, harmful, helpful)
    local side = rule[1]
    if side == "auto" then return (helpful and not harmful) and "heal" or "dmg" end
    return side
end

local function allowed(rule, harmful, helpful)
    local when = rule.when
    return when == nil or (when == "helpful" and helpful) or (when == "harmful" and harmful)
             or (when == "healOnly" and helpful and not harmful) or (when == "notHarmful" and not harmful)
end

local function slotOf(side, shape)
    if side == "absorb" then return "heal", "absorb" end
    if shape == "hit" then return "dmg", "perHit" end
    if shape == "over" or shape == "tick" then return side == "drain" and "dmg" or side, "periodic" end
    return side, "direct"
end

local function lookupDuration(text, pack)
    for _, variant in ipairs(pack.compiledLasts) do
        local a, b, caps = match(text, {variant}, pack)
        if a then return caps.duration[1], cut(text, a, b) end
    end
    return nil, text
end

local function apply(r, rule, side, caps, text, pack, clause, tail)
    local shape = rule[2]
    local amount, duration
    if shape == "direct" or shape == "hit" then
        amount = caps.value[1]
    elseif shape == "charges" then
        local count, each = caps.number[1], caps.value[1]
        if count and each then
            amount = count * each
            r.dmg.charges, r.dmg.perCharge = count, each
        end
    elseif shape == "over" then
        amount, duration = caps.value[1], caps.duration[1]
    elseif shape == "tick" then
        local tick, interval = caps.value[1], rule.interval or caps.duration[1]
        duration = caps.duration[rule.interval and 1 or 2]
        if not duration then duration, text = lookupDuration(text, pack) end
        if tick and interval and interval > 0 and duration and duration >= interval then
            amount = tick * floor(duration / interval + 1e-6)
        else
            amount, duration = tick, interval
        end
    end
    -- "takes 0.5 Shadow damage for each mana drained" is a rate, not an amount
    if not amount or amount < 1 then return text, false end

    local sideName, slot = slotOf(side, shape)
    if side == "drain" then
        r.dmg.periodic, r.dmg.duration = amount, duration
        r.heal.periodic, r.heal.duration = amount, duration
    else
        local t = r[sideName]
        t[slot] = amount
        if slot == "periodic" then t.duration = duration end
    end
    if sideName == "dmg" or side == "drain" then
        r.dmg.school = r.dmg.school or findSchool(clause, pack) or findSchool(tail, pack)
    end
    return text, true
end

local function readRules(r, text, pack, harmful, helpful)
    for _, rule in ipairs(pack.rules) do
        if rule[2] == "ignore" then
            -- like "to life with 600 health"
            local a, b = match(text, rule.variants, pack)
            if a then text = cut(text, a, b) end
        elseif allowed(rule, harmful, helpful) then
            local side = sideFor(rule, harmful, helpful)
            local sideName, slot = slotOf(side, rule[2])
            local free = (r[sideName][slot] or 0) == 0 and not (side == "drain" and r.heal.periodic > 0)
            if free then
                local a, b, caps = match(text, rule.variants, pack)
                if a then
                    local clause = text:sub(a, b)
                    local tail = text:sub(b + 1):match("^[^%d%.,;:|]*")
                    local applied
                    text, applied = apply(r, rule, side, caps, cut(text, a, b), pack, clause, tail)
                    r.found = r.found or applied
                end
            end
        end
    end
end

-- finishers list one row per number of combo points ("1 point: 245-321 damage 2 points: ...").
-- the rows must count up from 1, anything else is just a number before the word
local function comboRows(text, pack)
    for _, pattern in ipairs(pack.compiledComboRow or {}) do
        local starts, init = {}, 1
        while true do
            local a, b, n = text:find(pattern, init)
            if not a then break end
            if tonumber(n) == #starts + 1 then starts[#starts + 1] = {a, b} end
            init = b + 1
        end
        if #starts >= 2 then
            local rows = {}
            for i, mark in ipairs(starts) do
                local finish = starts[i + 1] and starts[i + 1][1] - 1 or #text
                rows[i] = text:sub(mark[2] + 1, finish)
            end
            return rows, text:sub(1, starts[1][1] - 1)
        end
    end
end

-- amounts are averages. a finisher has combo = {[points] = result} and nothing in dmg / heal itself,
-- extraPerPoint is the damage per point of rage or energy spent above the cost.
-- nil without a pack or a text
function Parser.Parse(text, pack, harmful, helpful)
    if not pack or type(text) ~= "string" or text == "" then return nil end
    prepare(pack)
    text = Parser.Normalize(text, pack)
    local r = newResult()
    r.area = containsAny(text, pack.area)
    -- Execute and Ferocious Bite turn the rage or energy left over into damage. read it first, it sits outside the rows
    for _, variant in ipairs(pack.compiledExtra) do
        local a, b, caps = match(text, {variant}, pack)
        if a then
            r.extraPerPoint = caps.value[1]
            text = cut(text, a, b)
            break
        end
    end
    -- before the weapon check, finishers say "increased by Attack Power"
    local rows, head = comboRows(text, pack)
    if rows then
        r.combo = {}
        for points, rowText in ipairs(rows) do
            local row = newResult()
            row.area = r.area
            readRules(row, rowText, pack, harmful, helpful)
            row.dmg.school = row.dmg.school or findSchool(head, pack)
            r.combo[points] = row
            r.found = r.found or row.found
        end
        return r
    end
    if containsAny(text, pack.weapon) then
        r.weapon = true
        return r
    end
    readRules(r, text, pack, harmful, helpful)
    return r
end

-- some texts aren't translated in other clients, English gets a go when the client's pack finds nothing
function Parser.Read(text, pack, fallback, harmful, helpful)
    local r = Parser.Parse(text, pack, harmful, helpful)
    if r and (r.found or r.weapon) then return r end
    if fallback and fallback ~= pack then
        local other = Parser.Parse(text, fallback, harmful, helpful)
        if other and (other.found or other.weapon) then return other end
    end
    return r
end

-- the row for a number of combo points, or the closest one below it
function Parser.ComboRow(r, points)
    for n = points, 1, -1 do if r.combo[n] then return r.combo[n], n end end
end

function Parser.HasDamage(r) return r.dmg.direct > 0 or r.dmg.periodic > 0 or r.dmg.perHit > 0 end
function Parser.HasHealing(r) return r.heal.direct > 0 or r.heal.periodic > 0 or r.heal.absorb > 0 end

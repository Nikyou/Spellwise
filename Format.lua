-- number formatting and line texts. no WoW API in here, everything is passed in
local _, ns = ...

local Format = {}
ns.Format = Format

local format, floor, ipairs = string.format, math.floor, ipairs

local SPACER = "   "

-- an empty tsep means no grouping
function Format.Number(n, decimals, fmt)
    local s = format("%." .. decimals .. "f", n)
    local sign, int, frac = s:match("^(-?)(%d+)(.*)$")
    if not int then return s end
    if fmt.group and fmt.tsep ~= "" and #int > 3 then
        local head = #int % 3
        local parts = {}
        if head > 0 then parts[1] = int:sub(1, head) end
        for i = head + 1, #int, 3 do parts[#parts + 1] = int:sub(i, i + 2) end
        int = table.concat(parts, fmt.tsep)
    end
    if frac ~= "" then frac = fmt.dsep .. frac:sub(2) end
    return sign .. int .. frac
end

-- averages like 19.5 keep their decimal
function Format.Amount(n, fmt)
    if floor(n) == n then return Format.Number(n, 0, fmt) end
    return Format.Number(n, 1, fmt)
end

local function join(a, b)
    if a and b then return a .. SPACER .. b end
    return a or b
end

local function costParts(m, field, o, L, fmt, kind)
    local text
    for _, resource in ipairs(o.costs) do
        if resource[kind] then
            -- free right now (Clearcasting), nothing to divide by
            local values = m.perCost[resource.powerType]
            local value = values and values[field]
            if resource.free and (m[field] or 0) > 0 then
                text = join(text, format("%s: %s", resource.labels[kind], L["Free"]))
            elseif value then
                text = join(text, format("%s: %s", resource.labels[kind], Format.Number(value, 2, fmt)))
            end
        end
    end
    return text
end

-- o comes from lineOptions in Tooltip.lua. out gets text, kind pairs
local function sideLines(out, m, kind, o, L, fmt)
    local showRate = o.rate[kind]
    local rateLabel = kind == "heal" and L["HPS"] or L["DPS"]
    local function add(text)
        if text then
            out[#out + 1] = text
            out[#out + 1] = kind
        end
    end
    local function rate(value)
        if showRate and value then return format("%s: %s", rateLabel, Format.Number(value, o.decimals, fmt)) end
    end

    local showPeriodic = o.dot and m.periodic > 0 and m.periodicPerSec
    if m.charges and m.direct > 0 then
        -- charges go off when the caster gets hit, there's no time to divide by
        add(join(format(L["Per cast: %s"], Format.Amount(m.direct, fmt)), costParts(m, "direct", o, L, fmt, kind)))
    elseif m.direct > 0 then
        add(join(rate(m.perSec), costParts(m, "direct", o, L, fmt, kind)))
        if o.perCast and not showPeriodic then add(format(L["Per cast: %s"], Format.Amount(m.direct, fmt))) end
    end
    if showPeriodic then
        local head
        if o.dotLong or not showRate then
            local long = kind == "heal" and L["HoT: %s over %s sec"] or L["DoT: %s over %s sec"]
            head = join(format(long, Format.Amount(m.periodic, fmt), Format.Amount(m.periodicTime, fmt)), rate(m.periodicPerSec))
        else
            local short = kind == "heal" and L["HoT: %s"] or L["DoT: %s"]
            head = format(short, Format.Number(m.periodicPerSec, o.decimals, fmt))
        end
        add(join(head, costParts(m, "periodic", o, L, fmt, kind)))
        if m.total then
            add(join(format(L["Total per cast: %s"], Format.Amount(m.total, fmt)), costParts(m, "total", o, L, fmt, kind)))
        end
    end
    if m.perHit > 0 then add(format(L["Per hit: %s"], Format.Amount(m.perHit, fmt))) end
    if kind == "heal" and m.absorb > 0 then
        add(join(format(L["Absorb: %s"], Format.Amount(m.absorb, fmt)), costParts(m, "absorb", o, L, fmt, kind)))
    end
end

local function anyCost(o, kind)
    for _, resource in ipairs(o.costs) do if resource[kind] then return true end end
    return false
end

function Format.Lines(m, o, L, fmt, out)
    out = out or {}
    if o.rate.dmg or anyCost(o, "dmg") then sideLines(out, m.dmg, "dmg", o, L, fmt) end
    if o.rate.heal or anyCost(o, "heal") then sideLines(out, m.heal, "heal", o, L, fmt) end
    return out
end

local function reasonText(L, reason)
    if reason == "channel" then return L["channel time"] end
    if reason == "gcd" then return L["global cooldown"] end
    if reason == "cooldown" then return L["cooldown"] end
    return L["cast time"]
end

local function divisor(out, L, m, fmt)
    out[#out + 1] = format(L["Divided by %s sec (%s)"], Format.Number(m.time, 2, fmt), reasonText(L, m.reason))
    if m.cooldownLeftOut then
        out[#out + 1] = format(L["Cooldown of %s sec not counted"], Format.Amount(m.cooldownLeftOut, fmt))
    end
end

-- returns whether the side has anything at all, shown or not
local function breakdownSide(out, m, L, fmt, kind, show)
    local heal = kind == "heal"
    local amounts = show.amounts
    if m.charges and m.direct > 0 then
        if amounts then
            out[#out + 1] = format(L["%s charges of %s each, %s in total"], Format.Amount(m.charges, fmt),
                                   Format.Amount(m.perCharge, fmt), Format.Amount(m.direct, fmt))
        end
    elseif m.direct > 0 then
        if amounts and m.channel then
            out[#out + 1] = format(heal and L["Healing: %s over a %s sec channel"] or L["Damage: %s over a %s sec channel"],
                                   Format.Amount(m.direct, fmt), Format.Amount(m.time, fmt))
        elseif amounts then
            out[#out + 1] = format(heal and L["Healing: %s"] or L["Damage: %s"], Format.Amount(m.direct, fmt))
        end
        if show.time then divisor(out, L, m, fmt) end
    end
    if amounts and m.periodic > 0 then
        out[#out + 1] = format(heal and L["Healing over time: %s over %s sec"] or L["Damage over time: %s over %s sec"],
                               Format.Amount(m.periodic, fmt), Format.Amount(m.periodicTime or 0, fmt))
    end
    if amounts and m.perHit > 0 then
        out[#out + 1] = format(L["Per hit: %s (no attack rate in the text)"], Format.Amount(m.perHit, fmt))
    end
    if amounts and m.absorb > 0 then out[#out + 1] = format(L["Absorb: %s"], Format.Amount(m.absorb, fmt)) end
    return m.direct > 0 or m.periodic > 0 or m.perHit > 0 or m.absorb > 0
end

local EVERYTHING = {amounts = true, time = true, school = true, costs = true, notes = true}

-- the details lines. show says which parts, everything when it's nil
function Format.Breakdown(m, L, fmt, schoolName, costTexts, out, show)
    out = out or {}
    show = show or EVERYTHING
    local hasDamage = breakdownSide(out, m.dmg, L, fmt, "dmg", show)
    if show.school and m.dmg.school and (m.dmg.direct > 0 or m.dmg.periodic > 0 or m.dmg.perHit > 0) then
        out[#out + 1] = format(L["School: %s"], schoolName(m.dmg.school))
    end
    local hasHealing = breakdownSide(out, m.heal, L, fmt, "heal", show)
    if not (hasDamage or hasHealing) then return out end
    if show.costs then
        for _, text in ipairs(costTexts or {}) do out[#out + 1] = format(L["Cost: %s"], text) end
    end
    if show.notes then
        if m.area then out[#out + 1] = L["Values are per target"] end
        if m.pinned then out[#out + 1] = L["Average damage set by a spell rule"] end
        out[#out + 1] = L["Includes your bonuses, as the game shows them"]
    end
    return out
end

-- names come from the client ("%s Mana"). basePercent is for forms, the API gives no amount for them
function Format.CostLine(cost, max, mode, names, L, fmt, basePercent)
    if (not cost or cost <= 0) and basePercent and basePercent > 0 then
        return format(L["%s: %s%% of base"], names.name, Format.Number(basePercent, 0, fmt))
    end
    if not cost or cost <= 0 then return nil end
    local amountLine = format(names.costFormat, Format.Amount(cost, fmt))
    if mode == "amount" or not max or max <= 0 then return amountLine end
    local percent = Format.Number(cost / max * 100, 1, fmt)
    if mode == "both" then return format("%s (%s%%)", amountLine, percent) end
    return format("%s: %s%%", names.name, percent)
end

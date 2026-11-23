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
    -- 1650 x 1.1 isn't quite 1815 in floating point
    local rounded = floor(n * 10 + 0.5) / 10
    if floor(rounded) == rounded then return Format.Number(rounded, 0, fmt) end
    return Format.Number(rounded, 1, fmt)
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

    local showPeriodic = o.dot and m.periodic > 0 and m.periodicPerSec and not m.totem
    if m.totem then
        add(join(rate(m.periodicPerSec), costParts(m, "periodic", o, L, fmt, kind)))
    elseif m.charges and m.direct > 0 then
        -- charges go off when the caster gets hit, there's no time to divide by
        add(join(format(L["Per cast: %s"], Format.Amount(m.direct, fmt)), costParts(m, "direct", o, L, fmt, kind)))
    elseif m.direct > 0 and m.addedPerSec then
        -- Heroic Strike: what it adds to the swing it replaces, the whole swing if asked for
        local added = showRate and format("%s: %s", L["Added DPS"], Format.Number(m.addedPerSec, o.decimals, fmt))
        add(join(added, costParts(m, "direct", o, L, fmt, kind)))
        if showRate and o.swingTotal then add(format("%s: %s", L["Total DPS"], Format.Number(m.perSec, o.decimals, fmt))) end
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
    if m.perHit > 0 and m.attackEvery then
        -- per hit goes to the details
        add(join(rate(m.perSec), costParts(m, "attackTotal", o, L, fmt, kind)))
    elseif m.perHit > 0 then
        add(format(L["Per hit: %s"], Format.Amount(m.perHit, fmt)))
    end
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
    if reason == "swing" then return L["swing time"] end
    return L["cast time"]
end

local function divisor(out, L, m, fmt)
    out[#out + 1] = format(L["Divided by %s sec (%s)"], Format.Number(m.time, 2, fmt), reasonText(L, m.reason))
    if m.cooldownLeftOut then
        out[#out + 1] = format(L["Cooldown of %s sec not counted"], Format.Amount(m.cooldownLeftOut, fmt))
    end
end

-- what the text says beside the strike, from the damage as shown (crit in when it's on)
local function extraLine(out, extra, direct, L, fmt)
    local kind, percent = extra[1], extra[2]
    local more = Format.Amount(direct * (1 + percent / 100), fmt)
    local text
    if kind == "poisoned" then
        text = format(L["Against a poisoned target: %s"], more)
    elseif kind == "giants" then
        text = format(L["Against Giants, Dragonkin and mounted targets: %s"], more)
    elseif kind == "mainTarget" then
        text = format(L["Main target: %s"], more)
    elseif kind == "flametongue" then
        text = format(L["With %s on the off hand: %s"], extra[3], more)
    elseif kind == "heals" then
        text = format(L["Heals party members for %s in total"], Format.Amount(direct * percent / 100, fmt))
    end
    out[#out + 1] = text
end

-- how a weapon ability's damage comes together: each weapon's hit, then the ability's percent and bonus
local function strikeLines(out, strike, direct, L, fmt)
    if strike.swing then
        out[#out + 1] = format(L["Replaces a %s main hand swing, plus %s"], Format.Amount(strike.parts[1].hit, fmt),
                               Format.Amount(strike.bonus, fmt))
        return
    end
    for _, part in ipairs(strike.parts) do
        if part.normal then
            out[#out + 1] = format(L["%s: %s weapon damage, normalized to %s sec"], part.name, Format.Amount(part.hit, fmt),
                                   Format.Number(part.normal, 1, fmt))
        else
            out[#out + 1] = format(L["%s: %s weapon damage"], part.name, Format.Amount(part.hit, fmt))
        end
    end
    local percent, bonus = Format.Amount(strike.percent, fmt), Format.Amount(strike.bonus, fmt)
    if strike.percent ~= 100 and strike.bonus > 0 then
        out[#out + 1] = format(L["%s%% of weapon damage plus %s"], percent, bonus)
    elseif strike.percent ~= 100 then
        out[#out + 1] = format(L["%s%% of weapon damage"], percent)
    elseif strike.bonus > 0 then
        out[#out + 1] = format(L["Weapon damage plus %s"], bonus)
    end
    if strike.extra then extraLine(out, strike.extra, direct, L, fmt) end
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
        if amounts and m.strike then strikeLines(out, m.strike, m.direct, L, fmt) end
        if show.time then divisor(out, L, m, fmt) end
    end
    if amounts and m.totem then
        out[#out + 1] = format(heal and L["Healing: %s over %s sec"] or L["Damage: %s over %s sec"],
                               Format.Amount(m.periodic, fmt), Format.Amount(m.periodicTime, fmt))
    elseif amounts and m.periodic > 0 then
        out[#out + 1] = format(heal and L["Healing over time: %s over %s sec"] or L["Damage over time: %s over %s sec"],
                               Format.Amount(m.periodic, fmt), Format.Amount(m.periodicTime or 0, fmt))
    end
    if amounts and m.hands then
        for _, hand in ipairs(m.hands) do
            out[#out + 1] = format(L["%s: %s per hit, every %s sec"], hand.name, Format.Amount(hand.hit, fmt),
                                   Format.Number(hand.every, 2, fmt))
        end
    elseif amounts and m.perHit > 0 and m.attackEvery then
        out[#out + 1] = format(L["Per hit: %s, one attack every %s sec"], Format.Amount(m.perHit, fmt),
                               Format.Number(m.attackEvery, 3, fmt))
    elseif amounts and m.perHit > 0 then
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
        if m.dmg.strike and m.dmg.strike.swing then
            out[#out + 1] = L["Replaces your next swing: values if used on every swing"]
        end
        if m.dmg.fromWeapon then
            out[#out + 1] = L["From your weapon damage and attack power, before armor"]
        else
            out[#out + 1] = L["Includes your bonuses, as the game shows them"]
        end
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

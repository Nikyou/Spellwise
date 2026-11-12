-- tooltip hooks and the lines we add
local _, ns = ...
local L = ns.L
local LSM = LibStub("LibSharedMedia-3.0")

local Tooltip = {}
ns.Tooltip = Tooltip

local Parser, Metrics, Format, Spells, Resources = ns.Parser, ns.Metrics, ns.Format, ns.Spells, ns.Resources
local isSecret = ns.IsSecret
local type, ipairs, format, wipe = type, ipairs, string.format, wipe

local GRAY = {0.6, 0.6, 0.6}
local SCHOOL_COLORS = {
    HOLY = {1, 0.9, 0.5},
    FIRE = {1, 0.5, 0.15},
    NATURE = {0.55, 0.9, 0.25},
    FROST = {0.5, 0.8, 1},
    SHADOW = {0.7, 0.5, 1},
    ARCANE = {1, 0.55, 1},
}
-- written out so check_locale sees the keys
local LABELS = {
    DPM = L["DPM"], HPM = L["HPM"], DPR = L["DPR"], HPR = L["HPR"], DPE = L["DPE"], HPE = L["HPE"], DPF = L["DPF"],
    HPF = L["HPF"],
}

local function db() return ns.addon.db end

-- cached by spell and exact text, new spell power means a new text
local parsed, parsedCount = {}, 0
local MAX_PARSED = 400

local function parse(spellID, desc, harmful, helpful)
    local key = spellID .. "\0" .. desc
    local result = parsed[key]
    if result == nil then
        local pack, fallback = ns.PatternPack()
        result = pack and Parser.Read(desc, pack, fallback, harmful, helpful) or false
        if parsedCount >= MAX_PARSED then
            wipe(parsed)
            parsedCount = 0
        end
        parsed[key] = result
        parsedCount = parsedCount + 1
    end
    return result or nil
end

-- no pack for this language: costs only, and a notice once
local function noticeMissingPack()
    local locale = GetLocale()
    local notices = db().global.notices
    if ns.Patterns[locale] or notices[locale] then return end
    notices[locale] = true
    ns.Print(format(L["No damage or healing values for your game language (%s) yet, only costs. To help, send the author /sp dump all."], locale))
end

-- the game redraws the tooltip once the text loads. never rebuild it from here: Attack has no text, so that
-- loops, and a rebuild from addon code taints secret lines
local requested = {}
local RETRY_AFTER = 10

local function requestText(spellID)
    local now = GetTime()
    if requested[spellID] and now - requested[spellID] < RETRY_AFTER then return end
    requested[spellID] = now
    C_Spell.RequestLoadSpellData(spellID)
end

local options = {rate = {}, costs = {}}

local function lineOptions(forPet, free)
    local profile = db().profile
    local lines, pets = profile.lines, profile.pets
    options.rate.dmg = lines.dps and (not forPet or pets.dps)
    options.rate.heal = lines.hps and (not forPet or pets.hps)
    options.dot, options.dotLong, options.perCast = lines.dot, lines.dotLong, lines.perCast
    options.decimals = profile.look.decimals
    wipe(options.costs)
    for _, powerType in ipairs(Resources.ORDER) do
        local resource = Resources.TYPES[powerType]
        local settings = profile.resources[powerType]
        if resource.enabled and resource.labels and (not forPet or pets.perCost) then
            options.costs[#options.costs + 1] = {
                powerType = powerType,
                labels = {dmg = LABELS[resource.labels.dmg], heal = LABELS[resource.labels.heal]},
                dmg = settings.dmg,
                heal = settings.heal,
                free = free[powerType],
            }
        end
    end
    return options
end

local timings, spellCosts, spellFree, spellPercents, breakdownBuf, costTexts, rowBuf = {}, {}, {}, {}, {}, {}, {}

-- key names come from the client
local MODIFIERS = {
    SHIFT = {global = "SHIFT_KEY", fallback = "Shift"},
    CTRL = {global = "CTRL_KEY", fallback = "Ctrl"},
    ALT = {global = "ALT_KEY", fallback = "Alt"},
}

function Tooltip.ModifierName(mode)
    local modifier = MODIFIERS[mode]
    return modifier and (Spells.Text(_G[modifier.global]) or modifier.fallback) or ""
end

local function modifierDown(mode)
    if mode == "SHIFT" then return IsShiftKeyDown() end
    if mode == "CTRL" then return IsControlKeyDown() end
    if mode == "ALT" then return IsAltKeyDown() end
    return false
end

local function detailsState()
    local mode = db().profile.lines.details
    if mode == "ALWAYS" then return "show" end
    if not MODIFIERS[mode] then return nil end
    return modifierDown(mode) and "show" or "hint"
end

-- expected damage and healing with crits. crit = {dmg = {kind, chance, multiplier, factor}, heal = {...}}
local function withCrit(spellID, result, unit)
    local first = result.combo and result.combo[1] or result
    local school = first.dmg.school
    local crit = {}
    for _, side in ipairs({"dmg", "heal"}) do
        local kind = Spells.CritKind(spellID, school, side == "heal")
        local chance, multiplier
        if unit == "pet" then
            chance, multiplier = Spells.PetCrit(kind, side == "dmg" and school or nil)
        else
            chance, multiplier = Spells.Crit(spellID, kind, side == "dmg" and school or nil)
        end
        crit[side] = {kind = kind, chance = chance, multiplier = multiplier,
                      factor = chance and Metrics.CritFactor(chance, multiplier) or 1}
    end
    return Metrics.WithCrit(result, crit.dmg.factor, crit.heal.factor), crit
end

-- fills out with text, kind pairs. costs and max are the unit's, player or pet
function Tooltip.Build(spellID, unit, out)
    wipe(out)
    local rule = ns.Rules.Get(spellID)
    if rule and rule.hide then return out end

    local desc, secret = Spells.Description(spellID)
    local result
    if desc then
        local harmful, helpful = Spells.Flags(spellID)
        result = parse(spellID, desc, harmful, helpful)
        if not ns.Patterns[GetLocale()] then noticeMissingPack() end
    elseif not secret then
        requestText(spellID)
    end
    if rule and rule.avg then result = ns.Rules.Pinned(result, rule.avg) end

    wipe(spellCosts)
    wipe(spellFree)
    wipe(spellPercents)
    Spells.Costs(spellID, unit, spellCosts, spellFree, spellPercents)
    if result and result.combo and not db().profile.combo.show then result = nil end
    local crit
    if result and not result.weapon then
        Spells.Timings(spellID, timings)
        -- a pet's crit is its owner's, only hunters and warlocks have one
        if db().profile.lines.crit and Spells.CanCrit(spellID) and (unit == "player" or Spells.PetCrit("spell") ~= false) then
            result, crit = withCrit(spellID, result, unit)
        end
    else
        result = nil
    end
    return Tooltip.Lines(result, timings, spellCosts, spellFree, spellPercents, unit, detailsState(), out, crit)
end

-- Execute and Ferocious Bite with more rage or energy than they cost: steps of 10 up to your maximum,
-- steps of 5 when there's little room
local function breakPoints(out, m, perPoint, costs, free, unit, fmt, options)
    if not perPoint or m.dmg.direct <= 0 then return end
    for _, resource in ipairs(options.costs) do
        local powerType = resource.powerType
        local cost = not free[powerType] and costs[powerType]
        local max = cost and cost > 0 and Spells.MaxPower(unit, powerType)
        if max and max > cost then
            local step = max - cost > 50 and 10 or 5
            local name = Spells.ResourceNames(powerType, L).name
            for spent = (math.floor(cost / step) + 1) * step, max, step do
                local amount = m.dmg.direct + (spent - cost) * perPoint
                local text = format("%s %s: ", name, spent) .. format(L["%s damage"], Format.Amount(amount, fmt))
                if options.rate.dmg and m.dmg.time then
                    text = text .. format("   %s: %s", L["DPS"], Format.Number(amount / m.dmg.time, options.decimals, fmt))
                end
                if resource.dmg then
                    text = text .. format("   %s: %s", resource.labels.dmg, Format.Number(amount / spent, 2, fmt))
                end
                out[#out + 1] = text
                out[#out + 1] = "info"
            end
        end
    end
end

local function percent(value, fmt) return Format.Number(value * 100, 1, fmt) end

-- crit chance and size, and for melee and ranged how higher targets lower it
local function critLines(out, m, crit, fmt, show)
    local function add(text)
        out[#out + 1] = text
        out[#out + 1] = "info"
    end
    local decimals = db().profile.look.decimals
    for _, side in ipairs({"dmg", "heal"}) do
        local c, part = crit[side], m[side]
        local rate = part.perSec or part.periodicPerSec
        if (part.direct > 0 or part.periodic > 0 or (part.perHit or 0) > 0) then
            if not c.chance then
                if show.crit then add(L["Crit can't be read right now, it's left out"]) end
            else
                if show.crit then
                    local text = side == "heal" and L["Heal crit %s%% ×%s: +%s%% on average"]
                                   or L["Crit %s%% ×%s: +%s%% on average"]
                    add(format(text, percent(c.chance, fmt), Format.Number(c.multiplier, 2, fmt), percent(c.factor - 1, fmt)))
                end
                if side == "dmg" and show.levels and c.kind ~= "spell" and rate then
                    for levels = 1, 3 do
                        local chance = Metrics.CritAgainst(c.kind, c.chance, levels)
                        local value = rate / c.factor * Metrics.CritFactor(chance, c.multiplier)
                        local line = levels == 3 and L["Target level +%d (boss): crit %s%%, %s"] or L["Target level +%d: crit %s%%, %s"]
                        add(format(line, levels, percent(chance, fmt), format("%s: %s", L["DPS"], Format.Number(value, decimals, fmt))))
                    end
                elseif side == "dmg" and show.levels then
                    add(L["Spell crit doesn't depend on target level"])
                end
            end
        end
    end
end

-- shared with the settings preview. for a free cast, costs holds its last cost above 0
function Tooltip.Lines(result, t, costs, free, basePercents, unit, details, out, crit)
    local profile = db().profile
    local fmt = ns.NumberFormat()
    local m, combo
    local extra = result and result.extraPerPoint
    if result and result.combo then
        -- a finisher: the lines are for the chosen number of combo points, the details list them all
        local points
        combo = result.combo
        result, points = Parser.ComboRow(result, profile.combo.points)
        if result then
            out[#out + 1] = format(L["Combo points: %d"], points)
            out[#out + 1] = "info"
        end
    end
    if result then
        t.useCooldown = profile.lines.useCooldown
        m = Metrics.Compute(result, t, costs)
        Format.Lines(m, lineOptions(unit == "pet", free), L, fmt, out)
    end

    -- costs come from the API, so they show in every language
    wipe(costTexts)
    local forPet = unit == "pet"
    for _, powerType in ipairs(Resources.ORDER) do
        local resource = Resources.TYPES[powerType]
        local cost, base, isFree = costs[powerType], basePercents[powerType], free[powerType]
        if resource.enabled and ((cost and cost > 0) or base or isFree) then
            local names = Spells.ResourceNames(powerType, L)
            costTexts[#costTexts + 1] = Format.CostLine(cost, nil, "amount", names, L, fmt, base)
            if profile.resources[powerType].costLine and (not forPet or profile.pets.costLine) then
                local line = Format.CostLine(cost, Spells.MaxPower(unit, powerType), profile.costMode, names, L, fmt, base)
                if isFree then line = line and format(L["Free now, normally %s"], line) or L["Free now"] end
                if line then
                    out[#out + 1] = line
                    out[#out + 1] = "cost"
                end
            end
        end
    end

    if m and details and #out > 0 then
        if details == "show" then
            local show = profile.detailLines
            Format.Breakdown(m, L, fmt, ns.SchoolName, costTexts, wipe(breakdownBuf), show)
            for _, text in ipairs(breakdownBuf) do
                out[#out + 1] = text
                out[#out + 1] = "info"
            end
            if combo and show.combo then
                local options = lineOptions(unit == "pet", free)
                for points, row in ipairs(combo) do
                    local rowLines = Format.Lines(Metrics.Compute(row, t, costs), options, L, fmt, wipe(rowBuf))
                    local texts = {}
                    for i = 1, #rowLines, 2 do texts[#texts + 1] = rowLines[i] end
                    if #texts > 0 then
                        out[#out + 1] = format(L["Combo points %d: %s"], points, table.concat(texts, "; "))
                        out[#out + 1] = "info"
                    end
                end
            end
            if show.extra then breakPoints(out, m, extra, costs, free, unit, fmt, lineOptions(unit == "pet", free)) end
            if crit then critLines(out, m, crit, fmt, show) end
        else
            out[#out + 1] = format(L["Hold %s for details"], Tooltip.ModifierName(profile.lines.details))
            out[#out + 1] = "info"
        end
    end
    out.school = m and m.dmg.school
    return out
end

-- made-up spells for the preview
local SAMPLES = {
    {
        result = {dmg = {direct = 1240, periodic = 160, duration = 8, perHit = 0, school = "FIRE"},
                  heal = {direct = 0, periodic = 0, absorb = 0}},
        timings = {cast = 3.5, cooldown = 0, gcd = 1.5},
        costs = {[0] = 410},
    },
    {
        result = {dmg = {direct = 0, periodic = 0, perHit = 0}, heal = {direct = 1180, periodic = 1064, duration = 21, absorb = 0}},
        timings = {cast = 2, cooldown = 0, gcd = 1.5},
        costs = {[0] = 880},
    },
}

function Tooltip.Sample(out)
    local details = detailsState()
    for i, sample in ipairs(SAMPLES) do
        local state = details and (i == 2 and "show" or details)
        out[i] = Tooltip.Lines(sample.result, sample.timings, sample.costs, {}, {}, "player", state, wipe(out[i] or {}))
    end
    return out
end

function Tooltip.Color(kind, school)
    local look = db().profile.look
    if kind == "heal" then return look.healColor end
    if kind == "cost" then return look.costColor end
    if kind == "info" then return GRAY end
    return look.schoolTint and SCHOOL_COLORS[school] or look.damageColor
end

local OUTLINES = {[""] = "", OUTLINE = "OUTLINE", THICKOUTLINE = "THICKOUTLINE"}

function Tooltip.FontPath()
    local name = db().profile.look.font
    if name and name ~= "" then
        local path = LSM:Fetch("font", name, true)
        if path then return path end
    end
    return (GameTooltipText and GameTooltipText:GetFont()) or STANDARD_TEXT_FONT
end

function Tooltip.FontFlags() return OUTLINES[db().profile.look.outline] or "" end

-- the game reuses tooltip lines, so ours get their font back when the tooltip clears
local states = {}
local lastSpellID

local function onCleared(tooltip)
    local s = states[tooltip]
    if not s then return end
    for i = s.count, 1, -1 do
        s.lines[i]:SetFontObject(s.fonts[i])
        s.lines[i], s.fonts[i] = nil, nil
    end
    s.count, s.spellID, s.unit = 0, nil, nil
end

local function stateOf(tooltip)
    local s = states[tooltip]
    if s then return s end
    local name = tooltip.GetName and tooltip:GetName()
    s = {count = 0, lines = {}, fonts = {}, prefix = type(name) == "string" and not isSecret(name) and name .. "TextLeft" or nil}
    states[tooltip] = s
    tooltip:HookScript("OnTooltipCleared", onCleared)
    return s
end

local built = {}

local function appendLine(tooltip, s, text, color, path, size, flags)
    tooltip:AddLine(text, color[1], color[2], color[3])
    local line = s.prefix and _G[s.prefix .. tooltip:NumLines()]
    if line then
        s.count = s.count + 1
        s.lines[s.count], s.fonts[s.count] = line, line:GetFontObject()
        line:SetFont(path, size, flags)
    end
end

local function addLines(tooltip, spellID, unit)
    local s = stateOf(tooltip)
    s.spellID, s.unit, lastSpellID = spellID, unit, spellID
    Tooltip.Build(spellID, unit, built)
    if #built == 0 then return end
    local path, size, flags = Tooltip.FontPath(), db().profile.look.fontSize, Tooltip.FontFlags()
    for i = 1, #built, 2 do appendLine(tooltip, s, built[i], Tooltip.Color(built[i + 1], built.school), path, size, flags) end
    tooltip:Show()
end

-- only action buttons redraw their tooltip on a key press, so elsewhere the hint turns into the details in place.
-- lines can't be removed, letting go waits for the next redraw. skipped in combat, the text can be secret there
local function onModifier()
    local mode = db() and db().profile.lines.details
    if not MODIFIERS[mode] or not modifierDown(mode) or InCombatLockdown() then return end
    for tooltip, s in pairs(states) do
        if s.count > 0 and s.spellID and tooltip:IsShown() then
            Tooltip.Build(s.spellID, s.unit, built)
            local pairsCount = #built / 2
            if pairsCount > s.count then
                local path, size, flags = Tooltip.FontPath(), db().profile.look.fontSize, Tooltip.FontFlags()
                local had = s.count
                for n = 1, pairsCount do
                    local color = Tooltip.Color(built[n * 2], built.school)
                    if n <= had then
                        s.lines[n]:SetText(built[n * 2 - 1])
                        s.lines[n]:SetTextColor(color[1], color[2], color[3])
                    else
                        appendLine(tooltip, s, built[n * 2 - 1], color, path, size, flags)
                    end
                end
                tooltip:Show()
            end
        end
    end
end

local BANK_PET = Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Pet or 1

local function actionSpell(slot)
    if type(slot) ~= "number" or isSecret(slot) then return nil end
    local kind, id, subType = GetActionInfo(slot)
    if isSecret(kind) or isSecret(id) or isSecret(subType) then return nil end
    if kind == "spell" then return Spells.Number(id) end
    if kind == "macro" then
        if subType == "spell" then return Spells.Number(id) end
        local spellID = GetMacroSpell(id)
        return Spells.Number(spellID)
    end
end

-- which option applies and whose spell it is
local function source(tooltip, data)
    local info = tooltip.GetProcessingTooltipInfo and tooltip:GetProcessingTooltipInfo()
    if isSecret(info) then info = nil end
    local getter = type(info) == "table" and Spells.Text(info.getterName)
    local args = type(info) == "table" and not isSecret(info.getterArgs) and info.getterArgs
    local profile = db().profile
    local dataType = type(data) == "table" and Spells.Number(data.type)
    local spellID = dataType == Enum.TooltipDataType.Spell and Spells.Number(data.id) or nil
    if getter == "GetAction" then
        return profile.show.actionBar, (type(args) == "table" and actionSpell(args[1])) or spellID, "player"
    elseif getter == "GetPetAction" then
        return profile.pets.actionBar, spellID, "pet"
    elseif getter == "GetSpellBookItem" then
        local bank = type(args) == "table" and not isSecret(args[2]) and args[2]
        if bank == BANK_PET or bank == "pet" then return profile.pets.spellbook, spellID, "pet" end
        return profile.show.spellbook, spellID, "player"
    end
    return profile.show.other, spellID, "player"
end

local function onTooltipData(tooltip, data)
    if not db() or isSecret(data) then return end
    local shown, spellID, unit = source(tooltip, data)
    if shown and spellID then addLines(tooltip, spellID, unit) end
end

function Tooltip.HoveredSpellID()
    local s = states[GameTooltip]
    if GameTooltip:IsShown() and s and s.spellID then return s.spellID end
    if GameTooltip:IsShown() and GameTooltip.GetSpell then
        local ok, _, id = pcall(GameTooltip.GetSpell, GameTooltip)
        if ok and Spells.Number(id) then return id end
    end
    return lastSpellID
end

function Tooltip.Enable()
    stateOf(GameTooltip)
    local events = CreateFrame("Frame")
    events:RegisterEvent("MODIFIER_STATE_CHANGED")
    events:SetScript("OnEvent", function() ns.Guard(onModifier) end)
    local function post(tooltip, data) ns.Guard(onTooltipData, tooltip, data) end
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, post)
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, post)
    else
        -- older clients without the processor
        hooksecurefunc(GameTooltip, "SetSpellByID", function(self, spellID)
            ns.Guard(function()
                if db().profile.show.other and Spells.Number(spellID) then addLines(self, spellID, "player") end
            end)
        end)
        hooksecurefunc(GameTooltip, "SetAction", function(self, slot)
            ns.Guard(function()
                local spellID = actionSpell(slot)
                if db().profile.show.actionBar and spellID then addLines(self, spellID, "player") end
            end)
        end)
    end
end

Tooltip.SCHOOL_COLORS = SCHOOL_COLORS

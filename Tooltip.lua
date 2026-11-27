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
    DPM = L["DPM"],
    HPM = L["HPM"],
    DPR = L["DPR"],
    HPR = L["HPR"],
    DPE = L["DPE"],
    HPE = L["HPE"],
    DPF = L["DPF"],
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
    ns.Print(format(
               L["No damage or healing values for your game language (%s) yet, only costs. To help, send the author /sp dump all."],
               locale))
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

-- which lines Format.Lines writes. one shared table, filled again for every tooltip
local lineOptionsBuf = {rate = {}, costs = {}}

local function lineOptions(forPet, free)
    local profile = db().profile
    local lines, pets, o = profile.lines, profile.pets, lineOptionsBuf
    o.rate.dmg = lines.dps and (not forPet or pets.dps)
    o.rate.heal = lines.hps and (not forPet or pets.hps)
    o.dot, o.dotLong, o.perCast, o.swingTotal = lines.dot, lines.dotLong, lines.perCast, lines.swingTotal
    o.decimals = profile.look.decimals
    wipe(o.costs)
    for _, powerType in ipairs(Resources.ORDER) do
        local resource = Resources.TYPES[powerType]
        local settings = profile.resources[powerType]
        if resource.enabled and resource.labels and (not forPet or pets.perCost) then
            o.costs[#o.costs + 1] = {
                powerType = powerType,
                labels = {dmg = LABELS[resource.labels.dmg], heal = LABELS[resource.labels.heal]},
                dmg = settings.dmg,
                heal = settings.heal,
                free = free[powerType],
            }
        end
    end
    return o
end

-- out holds text, kind pairs
local function add(out, text, kind)
    out[#out + 1] = text
    out[#out + 1] = kind
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
local noTicks

-- a damage or heal over time whose ticks can't crit (Lifebloom, Vampiric Touch)
local function noTickCrit(spellID)
    if not noTicks then
        noTicks = {}
        for _, id in ipairs(ns.CritData.noTickCrit or {}) do noTicks[id] = true end
    end
    return noTicks[spellID] == true
end

local function withCrit(spellID, result, unit)
    local first = result.combo and result.combo[1] or result
    local school = first.dmg.school
    local crit = {}
    for _, side in ipairs({"dmg", "heal"}) do
        -- a drain is a spell even when its text names no school. Holy Strike crits like a strike
        local kind = result.critKind or Spells.CritKind(spellID, school, side == "heal" or result.drain)
        local chance, multiplier
        if unit == "pet" then
            chance, multiplier = Spells.PetCrit(kind, side == "dmg" and school or nil)
        else
            chance, multiplier = Spells.Crit(spellID, kind, side == "dmg" and school or nil)
        end
        crit[side] = {
            kind = kind,
            chance = chance,
            multiplier = multiplier,
            factor = chance and Metrics.CritFactor(chance, multiplier) or 1,
        }
    end
    crit.noTicks = noTickCrit(spellID)
    return Metrics.WithCrit(result, crit.dmg.factor, crit.heal.factor, crit.noTicks), crit
end

-- what crits add to an imbue's or poison's procs: kind "melee" for extra attacks, "spell" and a school for the
-- rest (wowsims). 1 when crit isn't counted
local function critFor(kind, school)
    if not db().profile.lines.crit then return 1 end
    local chance, multiplier = Spells.Crit(0, kind, school)
    return chance and Metrics.CritFactor(chance, multiplier) or 1
end

-- a pet's spell as its tooltip has it, the plain description uses your stats (Lash of Pain: 248 there, 116 on
-- the pet bar). the first line after the name with an amount
local function petDescription(spellID, lines, harmful, helpful)
    if type(lines) ~= "table" or isSecret(lines) then return nil end
    for i = 2, #lines do
        local line = lines[i]
        local text = type(line) == "table" and not isSecret(line) and Spells.Text(line.leftText)
        if text and text:find("%d") then
            local result = parse(spellID, text, harmful, helpful)
            if result and (result.found or result.weapon) then return text end
        end
    end
end

-- fills out with text, kind pairs. costs and max are the unit's. petLines: a pet tooltip's data lines
function Tooltip.Build(spellID, unit, out, petLines)
    wipe(out)
    local rule = ns.Rules.Get(spellID)
    if rule and rule.hide then return out end

    local desc, secret
    if unit == "pet" and petLines then desc = petDescription(spellID, petLines, Spells.Flags(spellID)) end
    if not desc then desc, secret = Spells.Description(spellID) end
    local result
    if desc then
        local harmful, helpful = Spells.Flags(spellID)
        result = parse(spellID, desc, harmful, helpful)
        if not ns.Patterns[GetLocale()] then noticeMissingPack() end
    elseif not secret then
        requestText(spellID)
    end
    wipe(spellCosts)
    wipe(spellFree)
    wipe(spellPercents)
    Spells.Costs(spellID, unit, spellCosts, spellFree, spellPercents)

    -- the text only says "weapon damage", the numbers come from the weapons
    local lines = db().profile.lines
    if unit == "player" and not (rule and rule.avg) then
        local strike, imbue = ns.WeaponData[spellID], ns.ImbueData[spellID]
        if imbue and lines.weapon then
            local info = ns.Weapon.Imbue(spellID, imbue, critFor)
            return Tooltip.ImbueLines(info, spellCosts, spellFree, spellPercents, unit, detailsState(), out)
        elseif strike and lines.weapon then
            result = ns.Weapon.Strike(spellID, strike, desc, result, critFor)
        elseif ns.Weapon.AUTO[spellID] and lines.autoAttack then
            result = ns.Weapon.Auto(spellID, critFor)
        end
    end
    if rule and rule.avg then result = ns.Rules.Pinned(result, rule.avg) end

    if result and result.combo and not db().profile.combo.show then result = nil end
    local crit
    if result and not result.weapon then
        Spells.Timings(spellID, timings)
        timings.swing = result.swing
        -- a pet's crit is its owner's, only hunters and warlocks have one
        if lines.crit and (unit == "player" or Spells.PetCrit("spell") ~= false) then
            result, crit = withCrit(spellID, result, unit)
        end
    else
        result = nil
    end
    return Tooltip.Lines(result, timings, spellCosts, spellFree, spellPercents, unit, detailsState(), out, crit)
end

-- Execute and Ferocious Bite with more rage or energy than they cost: steps of 10 up to your maximum,
-- steps of 5 when there's little room
local function breakPoints(out, m, perPoint, costs, free, unit, fmt, o)
    if not perPoint or m.dmg.direct <= 0 then return end
    for _, resource in ipairs(o.costs) do
        local powerType = resource.powerType
        local cost = not free[powerType] and costs[powerType]
        local max = cost and cost > 0 and Spells.MaxPower(unit, powerType)
        if max and max > cost then
            local step = max - cost > 50 and 10 or 5
            local name = Spells.ResourceNames(powerType, L).name
            for spent = (math.floor(cost / step) + 1) * step, max, step do
                local amount = m.dmg.direct + (spent - cost) * perPoint
                local text = format("%s %s: ", name, spent) .. format(L["%s damage"], Format.Amount(amount, fmt))
                if o.rate.dmg and m.dmg.time then
                    text = text .. format("   %s: %s", L["DPS"], Format.Number(amount / m.dmg.time, o.decimals, fmt))
                end
                if resource.dmg then
                    text = text .. format("   %s: %s", resource.labels.dmg, Format.Number(amount / spent, 2, fmt))
                end
                add(out, text, "info")
            end
        end
    end
end

local function percent(value, fmt) return Format.Number(value * 100, 1, fmt) end

-- melee and ranged crit drops against higher targets, spells keep theirs
local function levelLines(out, c, rate, label, fmt)
    if c.kind == "spell" then return add(out, L["Spell crit doesn't depend on target level"], "info") end
    if not rate then return end
    local decimals = db().profile.look.decimals
    for levels = 1, 3 do
        local chance = Metrics.CritAgainst(c.kind, c.chance, levels)
        local value = rate / c.factor * Metrics.CritFactor(chance, c.multiplier)
        local line = levels == 3 and L["Target level +%d (boss): crit %s%%, %s"] or L["Target level +%d: crit %s%%, %s"]
        add(out, format(line, levels, percent(chance, fmt), format("%s: %s", label, Format.Number(value, decimals, fmt))), "info")
    end
end

-- crit chance and size, and how higher targets change it
local function critLines(out, m, crit, fmt, show)
    for _, side in ipairs({"dmg", "heal"}) do
        local c, part = crit[side], m[side]
        -- a channel's ticks are its direct part by now
        local ticksOnly = crit.noTicks and (part.channel or part.direct == 0)
        if not ticksOnly and (part.direct > 0 or part.periodic > 0 or (part.perHit or 0) > 0) then
            if not c.chance then
                if show.crit then add(out, L["Crit can't be read right now, it's left out"], "info") end
            else
                if show.crit then
                    local text = side == "heal" and L["Heal crit %s%% ×%s: +%s%% on average"]
                                   or L["Crit %s%% ×%s: +%s%% on average"]
                    add(out,
                        format(text, percent(c.chance, fmt), Format.Number(c.multiplier, 2, fmt), percent(c.factor - 1, fmt)),
                        "info")
                end
                if side == "dmg" and show.levels then
                    -- Heroic Strike's main line is what it adds, so are these
                    local rate = part.addedPerSec or part.perSec or part.periodicPerSec
                    levelLines(out, c, rate, part.addedPerSec and L["Added DPS"] or L["DPS"], fmt)
                end
            end
        end
    end
end

-- a finisher's lines are for the chosen number of combo points, the details list them all
local function comboRowLines(out, combo, t, costs, o, fmt)
    for points, row in ipairs(combo) do
        local rowLines = Format.Lines(Metrics.Compute(row, t, costs), o, L, fmt, wipe(rowBuf))
        local texts = {}
        for i = 1, #rowLines, 2 do texts[#texts + 1] = rowLines[i] end
        if #texts > 0 then add(out, format(L["Combo points %d: %s"], points, table.concat(texts, "; ")), "info") end
    end
end

-- costs come from the API, so every language has them. costTexts gets them all for the details
local function costLines(out, costs, free, basePercents, unit, fmt)
    local profile = db().profile
    local forPet = unit == "pet"
    wipe(costTexts)
    for _, powerType in ipairs(Resources.ORDER) do
        local resource = Resources.TYPES[powerType]
        local cost, base, isFree = costs[powerType], basePercents[powerType], free[powerType]
        if resource.enabled and ((cost and cost > 0) or base or isFree) then
            local names = Spells.ResourceNames(powerType, L)
            costTexts[#costTexts + 1] = Format.CostLine(cost, nil, "amount", names, L, fmt, base)
            if profile.resources[powerType].costLine and (not forPet or profile.pets.costLine) then
                local line = Format.CostLine(cost, Spells.MaxPower(unit, powerType), profile.costMode, names, L, fmt, base)
                if isFree then line = line and format(L["Free now, normally %s"], line) or L["Free now"] end
                if line then add(out, line, "cost") end
            end
        end
    end
end

-- everything the details key shows, in the order the Details tab lists it
local function detailLines(out, m, s)
    local show = db().profile.detailLines
    Format.Breakdown(m, L, s.fmt, ns.SchoolName, costTexts, wipe(breakdownBuf), show)
    for _, text in ipairs(breakdownBuf) do add(out, text, "info") end
    if s.combo and show.combo then comboRowLines(out, s.combo, s.t, s.costs, s.o, s.fmt) end
    if show.extra then breakPoints(out, m, s.extra, s.costs, s.free, s.unit, s.fmt, s.o) end
    if s.crit then critLines(out, m, s.crit, s.fmt, show) end
end

local spellBuf = {}

-- an imbue or poison: what it adds, its cost line, and the details. info is nil when the weapons or the poison's
-- text can't be read, the cost still shows then
function Tooltip.ImbueLines(info, costs, free, basePercents, unit, details, out)
    local profile = db().profile
    local fmt = ns.NumberFormat()
    if info then Format.ImbueLines(info, lineOptions(false, free), L, fmt, out) end
    costLines(out, costs, free, basePercents, unit, fmt)
    if info and details and #out > 0 then
        local before = #out
        for _, text in ipairs(Format.ImbueDetails(info, L, fmt, wipe(breakdownBuf), profile.detailLines)) do
            add(out, text, "info")
        end
        if details == "hint" and #out > before then
            for i = #out, before + 1, -1 do out[i] = nil end
            add(out, format(L["Hold %s for details"], Tooltip.ModifierName(profile.lines.details)), "info")
        end
    end
    out.school = info and info.school
    return out
end

-- shared with the settings preview. for a free cast, costs holds its last cost above 0
function Tooltip.Lines(result, t, costs, free, basePercents, unit, details, out, crit)
    local profile = db().profile
    local fmt = ns.NumberFormat()
    local o = lineOptions(unit == "pet", free)
    local combo, extra = result and result.combo, result and result.extraPerPoint
    if combo then
        local points
        result, points = Parser.ComboRow(result, profile.combo.points)
        if result then add(out, format(L["Combo points: %d"], points), "info") end
    end
    local m
    if result then
        t.useCooldown = profile.lines.useCooldown
        m = Metrics.Compute(result, t, costs)
        Format.Lines(m, o, L, fmt, out)
    end
    costLines(out, costs, free, basePercents, unit, fmt)

    -- built for the hint too, it only shows when the details have something
    if m and details and #out > 0 then
        local before = #out
        local s = wipe(spellBuf)
        s.combo, s.extra, s.t, s.costs, s.free, s.unit, s.crit, s.o, s.fmt = combo, extra, t, costs, free, unit, crit, o, fmt
        detailLines(out, m, s)
        if details == "hint" and #out > before then
            for i = #out, before + 1, -1 do out[i] = nil end
            add(out, format(L["Hold %s for details"], Tooltip.ModifierName(profile.lines.details)), "info")
        end
    end
    out.school = m and m.dmg.school
    return out
end

-- made-up spells for the preview
local SAMPLES = {
    {
        result = {
            dmg = {direct = 1240, periodic = 160, duration = 8, perHit = 0, school = "FIRE"},
            heal = {direct = 0, periodic = 0, absorb = 0},
        },
        timings = {cast = 3.5, cooldown = 0, gcd = 1.5},
        costs = {[0] = 410},
    }, {
        result = {
            dmg = {direct = 0, periodic = 0, perHit = 0},
            heal = {direct = 1180, periodic = 1064, duration = 21, absorb = 0},
        },
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
        -- a skin addon may have set a plain font, there's no object to give back then
        if s.fonts[i] then s.lines[i]:SetFontObject(s.fonts[i]) end
        s.lines[i], s.fonts[i] = nil, nil
    end
    s.count, s.spellID, s.unit, s.petLines, s.details = 0, nil, nil, nil, nil
end

local function stateOf(tooltip)
    local s = states[tooltip]
    if s then return s end
    local name = tooltip.GetName and tooltip:GetName()
    s = {count = 0, lines = {}, fonts = {}, prefix = type(name) == "string" and not isSecret(name) and name .. "TextLeft" or nil}
    states[tooltip] = s
    tooltip:HookScript("OnTooltipCleared", function(self) ns.Guard(onCleared, self) end)
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

local function addLines(tooltip, spellID, unit, petLines)
    local s = stateOf(tooltip)
    s.spellID, s.unit, s.petLines, s.details, lastSpellID = spellID, unit, petLines, detailsState(), spellID
    Tooltip.Build(spellID, unit, built, petLines)
    if #built == 0 then return end
    local path, size, flags = Tooltip.FontPath(), db().profile.look.fontSize, Tooltip.FontFlags()
    for i = 1, #built, 2 do appendLine(tooltip, s, built[i], Tooltip.Color(built[i + 1], built.school), path, size, flags) end
    tooltip:Show()
end

-- What's Training adds its price lines after ours, so the details would land below them. its rows draw the
-- tooltip again when you hover them, and do that themselves for the rank they compare with
local function rowRedraw(tooltip)
    local name = tooltip:GetName()
    if type(name) ~= "string" or isSecret(name) or not name:find("^WhatsTraining") then return nil end
    local owner = tooltip:GetOwner()
    local onEnter = owner and not isSecret(owner) and owner:GetScript("OnEnter")
    if onEnter then return owner, onEnter end
end

local redraws = {}

-- action buttons and those rows redraw on a key press, elsewhere the hint turns into the details in place. lines
-- can't be removed, so letting go waits for a redraw. not in combat, the text can be secret
local function onModifier()
    local mode = db() and db().profile.lines.details
    if not MODIFIERS[mode] or InCombatLockdown() then return end
    local down = modifierDown(mode)
    wipe(redraws)
    for tooltip, s in pairs(states) do
        if s.count > 0 and s.spellID and tooltip:IsShown() then
            local owner, onEnter = rowRedraw(tooltip)
            if owner then
                if s.details ~= (down and "show" or "hint") then
                    redraws[#redraws + 1] = owner
                    redraws[#redraws + 1] = onEnter
                end
            elseif down then
                Tooltip.Build(s.spellID, s.unit, built, s.petLines)
                -- the details replace the hint, as many lines or more: ours get new text, the rest are added
                local pairsCount = #built / 2
                if pairsCount >= s.count then
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
    -- a redraw can bring a tooltip we haven't seen yet into states, so not while going through it
    for i = 1, #redraws, 2 do redraws[i + 1](redraws[i]) end
    wipe(redraws)
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

-- the slot's spell, a pet action tooltip has no spell ID
local function petActionSpell(slot)
    if type(slot) ~= "number" or isSecret(slot) or not GetPetActionInfo then return nil end
    return Spells.Number((select(7, GetPetActionInfo(slot))))
end

local function spellBookSpell(slot, bank)
    if type(slot) ~= "number" or isSecret(slot) or not (C_SpellBook and C_SpellBook.GetSpellBookItemInfo) then return nil end
    local ok, info = pcall(C_SpellBook.GetSpellBookItemInfo, slot, bank)
    if ok and type(info) == "table" and not isSecret(info) then
        return Spells.Number(info.spellID) or Spells.Number(info.actionID)
    end
end

local function isPetBank(bank) return not isSecret(bank) and (bank == BANK_PET or bank == "pet") end

-- What's Training shows the pet's spells as plain spells (tomes, beast training). its catalog says which they are
local petSpells, petSource = {}, nil

local function isPetSpell(spellID)
    local api = WT_API
    if api ~= petSource then
        petSource, petSpells = api, {}
        local _, class = UnitClass("player")
        class = Spells.Text(class)
        if (class == "HUNTER" or class == "WARLOCK") and type(api) == "table" and type(api.GetCatalog) == "function" then
            local ok, catalog = pcall(api.GetCatalog, class)
            for _, entry in ipairs(ok and type(catalog) == "table" and catalog or {}) do
                local id = type(entry) == "table" and entry.petAbility and (entry.taughtSpellId or entry.id)
                if type(id) == "number" then petSpells[id] = true end
            end
        end
    end
    return petSpells[spellID] == true
end

-- which option applies and whose spell it is
local function source(tooltip, data)
    local info = tooltip.GetProcessingTooltipInfo and tooltip:GetProcessingTooltipInfo()
    if isSecret(info) then info = nil end
    local getter = type(info) == "table" and Spells.Text(info.getterName)
    local args = type(info) == "table" and not isSecret(info.getterArgs) and type(info.getterArgs) == "table" and info.getterArgs
                   or {}
    local profile = db().profile
    local dataType = type(data) == "table" and Spells.Number(data.type)
    -- a poison: the lines go on the item, in the bags or on a bar
    if dataType and dataType == Enum.TooltipDataType.Item then
        local shown = profile.lines.weapon
                        and (getter == "GetAction" and profile.show.actionBar or getter ~= "GetAction" and profile.show.other)
        return shown, ns.Weapon.ItemSpell(Spells.Number(data.id)), "player"
    end
    local spellID = dataType == Enum.TooltipDataType.Spell and Spells.Number(data.id) or nil
    if getter == "GetAction" then
        return profile.show.actionBar, actionSpell(args[1]) or spellID, "player"
    elseif getter == "GetPetAction" then
        return profile.pets.actionBar, spellID or petActionSpell(args[1]), "pet"
    elseif getter == "GetSpellBookItem" then
        spellID = spellID or spellBookSpell(args[1], args[2])
        if isPetBank(args[2]) then return profile.pets.spellbook, spellID, "pet" end
        return profile.show.spellbook, spellID, "player"
    end
    return profile.show.other, spellID, spellID and isPetSpell(spellID) and "pet" or "player"
end

local function onTooltipData(tooltip, data)
    if not db() or isSecret(data) then return end
    local shown, spellID, unit = source(tooltip, data)
    if shown and spellID then addLines(tooltip, spellID, unit, unit == "pet" and data.lines or nil) end
end

-- the data lines of a tooltip the processor didn't hand over
local function tooltipLines(getter, ...)
    local get = C_TooltipInfo and C_TooltipInfo[getter]
    if not get then return nil end
    local ok, data = pcall(get, ...)
    if ok and type(data) == "table" and not isSecret(data) then return data.lines end
end

-- pet bar and pet spellbook tooltips that skip the processor
local function onPetAction(tooltip, slot)
    local s = states[tooltip]
    if not db() or (s and s.spellID) then return end
    local spellID = petActionSpell(slot)
    if spellID and db().profile.pets.actionBar then addLines(tooltip, spellID, "pet", tooltipLines("GetPetAction", slot)) end
end

local function onSpellBookItem(tooltip, slot, bank)
    local s = states[tooltip]
    if not db() or (s and s.spellID) then return end
    local spellID = spellBookSpell(slot, bank)
    local profile = db().profile
    local pet = isPetBank(bank)
    local shown = pet and profile.pets.spellbook or (not pet and profile.show.spellbook)
    if spellID and shown then
        addLines(tooltip, spellID, pet and "pet" or "player", pet and tooltipLines("GetSpellBookItem", slot, bank) or nil)
    end
end

-- what the tooltip says it shows, for the dump
local function shownData()
    if not GameTooltip.GetTooltipData then return "no GetTooltipData" end
    local ok, data = pcall(GameTooltip.GetTooltipData, GameTooltip)
    if not ok or isSecret(data) or type(data) ~= "table" then return "none" end
    return format("type=%s id=%s", tostring(Spells.Number(data.type)), tostring(Spells.Number(data.id)))
end

-- the spell under the mouse, and how it was found: from our lines, from the tooltip, or the last spell we saw
function Tooltip.HoveredSpellID()
    local s = states[GameTooltip]
    local shown = GameTooltip:IsShown()
    if shown and s and s.spellID then return s.spellID, "our lines" end
    if shown and GameTooltip.GetSpell then
        local ok, _, id = pcall(GameTooltip.GetSpell, GameTooltip)
        if ok and Spells.Number(id) then return id, "the tooltip's spell, no lines of ours (" .. shownData() .. ")" end
    end
    return lastSpellID,
           format("the last spell with our lines, the tooltip %s (%s)", shown and "has none" or "is closed", shownData())
end

function Tooltip.Enable()
    stateOf(GameTooltip)
    local events = CreateFrame("Frame")
    events:RegisterEvent("MODIFIER_STATE_CHANGED")
    events:SetScript("OnEvent", function() ns.Guard(onModifier) end)
    local function post(tooltip, data) ns.Guard(onTooltipData, tooltip, data) end
    -- pet tooltips come as a pet action or skip the processor. the hooks leave a tooltip with our lines alone
    if GameTooltip.SetPetAction then
        hooksecurefunc(GameTooltip, "SetPetAction", function(self, slot) ns.Guard(onPetAction, self, slot) end)
    end
    if GameTooltip.SetSpellBookItem then
        hooksecurefunc(GameTooltip, "SetSpellBookItem", function(self, slot, bank)
            ns.Guard(onSpellBookItem, self, slot, bank)
        end)
    end
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
        local types = Enum.TooltipDataType
        for _, kind in ipairs({types.Spell, types.Macro, types.PetAction, types.Item}) do
            TooltipDataProcessor.AddTooltipPostCall(kind, post)
        end
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

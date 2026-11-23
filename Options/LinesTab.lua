-- which lines show and where
local _, ns = ...
local L = ns.L
local W, Options = ns.Widgets, ns.Options

local controls = {}
local resourceBoxes = {} -- {box, powerType, key}

local COLUMN, RIGHT = Options.COLUMN, Options.RIGHT

-- written out so check_locale sees the keys
local DESCRIPTIONS = {
    DPM = L["DPM: damage per mana"],
    HPM = L["HPM: healing per mana"],
    DPR = L["DPR: damage per rage"],
    HPR = L["HPR: healing per rage"],
    DPE = L["DPE: damage per energy"],
    HPE = L["HPE: healing per energy"],
    DPF = L["DPF: damage per focus"],
    HPF = L["HPF: healing per focus"],
}
local COST_LINES = {
    MANA = L["Mana cost"],
    RAGE = L["Rage cost"],
    ENERGY = L["Energy cost"],
    FOCUS = L["Focus cost"],
}
local COST_MODES = {
    {value = "percent", text = L["Percent of your maximum"]}, {value = "amount", text = L["Amount"]},
    {value = "both", text = L["Amount and percent"]},
}
local LABELS = {
    DPM = L["DPM"], HPM = L["HPM"], DPR = L["DPR"], HPR = L["HPR"], DPE = L["DPE"], HPE = L["HPE"], DPF = L["DPF"],
    HPF = L["HPF"],
}

local profile = Options.Profile

local setter = Options.Setter

-- one row per resource: its name, then per cost for damage and healing and the cost line
local function resourceRow(parent, column, powerType)
    local resource = ns.Resources.TYPES[powerType]
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(COLUMN, 26)
    column.place(row, 26)
    local name = W.Label(row, ns.Spells.ResourceNames(powerType, L).name)
    name:SetPoint("LEFT", 0, 0)
    local cells = {
        {key = "dmg", text = LABELS[resource.labels.dmg], tip = DESCRIPTIONS[resource.labels.dmg], x = 110},
        {key = "heal", text = LABELS[resource.labels.heal], tip = DESCRIPTIONS[resource.labels.heal], x = 215},
        {key = "costLine", text = L["Cost"], tip = COST_LINES[resource.token], x = 320},
    }
    for _, cell in ipairs(cells) do
        local box = W.CheckBox(row, cell.text, function(checked)
            profile().resources[powerType][cell.key] = checked
        end)
        box:SetPoint("LEFT", cell.x, 0)
        W.AddTooltip(box, function(tooltip) tooltip:AddLine(cell.tip, 1, 1, 1, true) end)
        resourceBoxes[#resourceBoxes + 1] = {box = box, powerType = powerType, key = cell.key}
    end
end

local function create(parent)
    local left = Options.Column(parent, 0, COLUMN)
    left.title(L["Lines"])
    controls.dps = left.check(L["DPS: damage per second"], setter("lines", "dps"))
    controls.hps = left.check(L["HPS: healing per second"], setter("lines", "hps"))
    controls.dot = left.check(L["DoT and HoT lines"], setter("lines", "dot"))
    controls.dotLong = left.check(L["Show their total and duration"], setter("lines", "dotLong"), 24)
    controls.perCast = left.check(L["Per cast line (no DoT or HoT)"], setter("lines", "perCast"))
    controls.useCooldown = left.check(L["Include the cooldown"], setter("lines", "useCooldown"))
    controls.crit = left.check(L["Include crit"], setter("lines", "crit"))
    W.AddTooltip(controls.crit, function(tooltip)
        tooltip:AddLine(L["Include crit"])
        tooltip:AddLine(L["Average with your crit chance and talents, against a target of your level. The details show higher levels."], 1, 1, 1, true)
    end)
    left.help(L["Divide by the cooldown when it's longer than the cast."])

    left.title(L["Per resource"])
    for _, powerType in ipairs(ns.Resources.ORDER) do
        local resource = ns.Resources.TYPES[powerType]
        if resource.enabled and resource.labels then resourceRow(parent, left, powerType) end
    end
    left.label(L["Show the cost as"])
    controls.costMode = W.Dropdown(parent, 260, function() return COST_MODES end, function(value)
        profile().costMode = value
    end)
    left.place(controls.costMode, 32)

    local right = Options.Column(parent, RIGHT, COLUMN)
    right.title(L["Show on"])
    controls.actionBar = right.check(L["Action bars, macros included"], setter("show", "actionBar"))
    controls.spellbook = right.check(L["Spellbook"], setter("show", "spellbook"))
    controls.other = right.check(L["Other tooltips (chat links, addons)"], setter("show", "other"))
    right.help(L["Pets have their own tab."], 0)

    -- spell names from the game, so they read in the player's language
    local name = ns.Spells.Name
    right.title(L["Weapons"])
    controls.weapon = right.check(L["Weapon abilities"], setter("lines", "weapon"))
    W.AddTooltip(controls.weapon, function(tooltip)
        tooltip:AddLine(L["Weapon abilities"])
        tooltip:AddLine(format(L["%s, %s, %s and other abilities that hit with a weapon: from your weapon damage and attack power."],
                               name(12294) or "Mortal Strike", name(1752) or "Sinister Strike", name(19434) or "Aimed Shot"),
                        1, 1, 1, true)
    end)
    controls.swingTotal = right.check(L["Total DPS on next swing abilities, imbues and poisons"], setter("lines", "swingTotal"), 24)
    W.AddTooltip(controls.swingTotal, function(tooltip)
        tooltip:AddLine(L["Total DPS on next swing abilities, imbues and poisons"])
        tooltip:AddLine(format(L["%s, %s, imbues and poisons add to your swings. Added DPS is what they add, Total DPS the weapon's with them."],
                               name(78) or "Heroic Strike", name(6807) or "Maul"), 1, 1, 1, true)
    end)
    controls.autoAttack = right.check(L["Auto attacks"], setter("lines", "autoAttack"))
    W.AddTooltip(controls.autoAttack, function(tooltip)
        tooltip:AddLine(L["Auto attacks"])
        tooltip:AddLine(format(L["%s, %s and %s with a wand: damage per second of your weapons."], name(6603) or "Attack",
                               name(75) or "Auto Shot", name(5019) or "Shoot"), 1, 1, 1, true)
    end)

    right.title(L["Minimap"])
    controls.minimap = right.check(L["Show minimap button"], function(checked) ns.addon:SetMinimapButtonShown(checked) end)

    right.title(L["About the values"])
    right.help(L["Tooltips already include your bonuses, Spellwise takes them as shown. No hit chance. Area spells: per target."], 0)
end

local function refresh()
    local p = profile()
    controls.dps:SetChecked(p.lines.dps)
    controls.hps:SetChecked(p.lines.hps)
    controls.dot:SetChecked(p.lines.dot)
    controls.dotLong:SetChecked(p.lines.dotLong)
    controls.perCast:SetChecked(p.lines.perCast)
    controls.useCooldown:SetChecked(p.lines.useCooldown)
    controls.crit:SetChecked(p.lines.crit)
    for _, entry in ipairs(resourceBoxes) do entry.box:SetChecked(p.resources[entry.powerType][entry.key]) end
    controls.costMode:SetValue(p.costMode)
    controls.actionBar:SetChecked(p.show.actionBar)
    controls.spellbook:SetChecked(p.show.spellbook)
    controls.other:SetChecked(p.show.other)
    controls.weapon:SetChecked(p.lines.weapon)
    controls.swingTotal:SetChecked(p.lines.swingTotal)
    controls.autoAttack:SetChecked(p.lines.autoAttack)
    controls.minimap:SetChecked(not p.minimap.hide)
end

table.insert(ns.OptionsTabs, {key = "lines", label = L["Lines"], Create = create, Refresh = refresh})

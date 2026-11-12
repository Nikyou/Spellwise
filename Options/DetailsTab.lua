-- when the details show and which of their lines
local _, ns = ...
local L = ns.L
local W, Options = ns.Widgets, ns.Options

local controls = {}
local boxes = {} -- [key] = check box
local COLUMN = 390
local RIGHT = COLUMN + 30

local function profile() return ns.addon.db.profile end

local function detailItems()
    local items = {{value = "NONE", text = L["Never"]}, {value = "ALWAYS", text = L["Always"]}}
    for _, mode in ipairs({"SHIFT", "CTRL", "ALT"}) do
        items[#items + 1] = {value = mode, text = format(L["While %s is held"], ns.Tooltip.ModifierName(mode))}
    end
    return items
end

local function part(column, key, text, indent)
    boxes[key] = column.check(text, function(checked) profile().detailLines[key] = checked end, indent)
    return boxes[key]
end

local function create(parent)
    local left = Options.Column(parent, 0, COLUMN)
    left.title(L["Details"])
    left.label(L["Show details"])
    controls.details = W.Dropdown(parent, 260, detailItems, function(value)
        profile().lines.details = value
    end)
    left.place(controls.details, 32)

    left.title(L["In the details"])
    part(left, "amounts", L["Damage and healing amounts"])
    part(left, "time", L["Time the values are divided by"])
    part(left, "school", L["Spell school"])
    part(left, "costs", L["Costs"])
    part(left, "combo", L["Each number of combo points"])
    -- spell names from the game, so they read in the player's language
    part(left, "extra", format(L["More rage or energy (%s, %s)"],
                               ns.Spells.Name(5308) or "Execute", ns.Spells.Name(22568) or "Ferocious Bite"))
    part(left, "notes", L["Notes: per target, spell rules, bonuses"])

    local right = Options.Column(parent, RIGHT, COLUMN)
    right.title(L["Crit"])
    part(right, "crit", L["Crit chance and size"])
    part(right, "levels", L["Higher level targets"])
    right.help(L["Shown when Include crit is on in the Lines tab."], 0)
end

local function refresh()
    local p = profile()
    controls.details:SetValue(p.lines.details)
    for key, box in pairs(boxes) do box:SetChecked(p.detailLines[key]) end
end

table.insert(ns.OptionsTabs, {key = "details", label = L["Details"], Create = create, Refresh = refresh})

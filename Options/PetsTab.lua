-- pet abilities and finishers: their own lines and options
local _, ns = ...
local L = ns.L
local W, Options = ns.Widgets, ns.Options

local controls = {}
local COLUMN = 390
local RIGHT = COLUMN + 30

local POINTS = {}
for n = 1, 5 do POINTS[n] = {value = n, text = tostring(n)} end

local function profile() return ns.addon.db.profile end

local function setter(section, key)
    return function(checked)
        profile()[section][key] = checked
    end
end

local function create(parent)
    local left = Options.Column(parent, 0, COLUMN)
    left.title(L["Pets: show on"])
    controls.actionBar = left.check(L["Pet action bar"], setter("pets", "actionBar"))
    controls.spellbook = left.check(L["Pet spellbook"], setter("pets", "spellbook"))

    left.title(L["Lines on pet abilities"])
    left.help(L["Can only turn off what the Lines tab shows."], 0)
    controls.dps = left.check(L["DPS: damage per second"], setter("pets", "dps"))
    controls.hps = left.check(L["HPS: healing per second"], setter("pets", "hps"))
    controls.perCost = left.check(L["Damage and healing per cost (DPM, HPM)"], setter("pets", "perCost"))
    controls.costLine = left.check(L["Cost line"], setter("pets", "costLine"))
    left.help(L["Costs and maximums come from your pet."], 0)

    local right = Options.Column(parent, RIGHT, COLUMN)
    right.title(L["Finishers"])
    controls.comboShow = right.check(L["Lines on finishers"], setter("combo", "show"))
    right.label(L["Combo points for the lines"])
    controls.points = W.Dropdown(parent, 120, function() return POINTS end, function(value)
        profile().combo.points = value
    end)
    right.place(controls.points, 32)
    -- spell names from the game, so they read in the player's language
    right.help(format(L["%s, %s and other finishers: the lines use this many combo points, the details show all. DPS leaves out building them."],
                      ns.Spells.Name(2098) or "Eviscerate", ns.Spells.Name(1079) or "Rip"), 0)
end

local function refresh()
    local p = profile()
    for _, key in ipairs({"actionBar", "spellbook", "dps", "hps", "perCost", "costLine"}) do controls[key]:SetChecked(p.pets[key]) end
    controls.comboShow:SetChecked(p.combo.show)
    controls.points:SetValue(p.combo.points)
end

table.insert(ns.OptionsTabs, {key = "pets", label = L["Pets and finishers"], Create = create, Refresh = refresh})

-- power types: client strings, metric labels, default max and whether they show
local _, ns = ...

-- keyed by Enum.PowerType. nameTag and costTag are client globals, see the PowerType table.
-- defaultMax is in display units, mana has none because it's read live
local Resources = {}

Resources.TYPES = {
    [0] = {
        token = "MANA",
        nameTag = "MANA",
        costTag = "MANA_COST",
        labels = {dmg = "DPM", heal = "HPM"},
        enabled = true,
    },
    [1] = {
        token = "RAGE",
        nameTag = "RAGE",
        costTag = "RAGE_COST",
        labels = {dmg = "DPR", heal = "HPR"},
        enabled = true,
        defaultMax = 100, -- MaxBasePower 1000, DisplayModifier 10
    },
    [2] = {
        token = "FOCUS",
        nameTag = "FOCUS",
        costTag = "FOCUS_COST",
        labels = {dmg = "DPF", heal = "HPF"},
        enabled = true,
        defaultMax = 100,
    },
    [3] = {
        token = "ENERGY",
        nameTag = "ENERGY",
        costTag = "ENERGY_COST",
        labels = {dmg = "DPE", heal = "HPE"},
        enabled = true,
        defaultMax = 100,
    },
    -- only ever next to energy or rage (Rip, Eviscerate)
    [4] = {
        token = "COMBO_POINTS",
        nameTag = "COMBO_POINTS",
        costTag = "COMBO_POINTS_COST",
        defaultMax = 5,
        noMetrics = true,
    },
}

-- power types not listed above
Resources.FALLBACK_MAX = 100

Resources.ORDER = {0, 1, 3, 2, 4}

ns.Resources = Resources

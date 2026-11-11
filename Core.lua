-- addon setup, saved settings, slash commands and the minimap button
local ADDON_NAME, ns = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Spellwise")

local addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0", "AceConsole-3.0")
ns.addon = addon
ns.L = L

local SCHEMA_VERSION = 1
local ICON = 236513

local defaults = {
    profile = {
        lines = {
            dps = true,
            hps = true,
            dot = true, -- with the "Total per cast" line
            dotLong = false, -- "DoT: 40 over 12 sec" instead of "DoT: 3.3"
            perCast = false,
            details = "SHIFT", -- NONE, ALWAYS, SHIFT, CTRL or ALT
            useCooldown = false,
            crit = false, -- expected damage with crits, against a target of your level
        },
        -- per power type. a type that's off in Resources.lua shows nothing, whatever is saved here
        resources = {
            ["*"] = {dmg = false, heal = false, costLine = false},
            [0] = {dmg = true, heal = true, costLine = true},
            [1] = {dmg = true, heal = true, costLine = true},
            [2] = {dmg = true, heal = true, costLine = true},
            [3] = {dmg = true, heal = true, costLine = true},
        },
        costMode = "percent", -- percent, amount or both
        show = {actionBar = true, spellbook = true, other = true},
        pets = {actionBar = true, spellbook = true, dps = true, hps = true, perCost = true, costLine = true},
        combo = {show = true, points = 5}, -- finishers: the lines use this many combo points
        look = {
            damageColor = {1, 0.82, 0},
            healColor = {0.4, 0.9, 0.4},
            costColor = {0.45, 0.65, 1},
            schoolTint = true,
            font = "", -- "" is the tooltip's own font
            fontSize = 12,
            outline = "",
            decimals = 1,
            thousands = false,
        },
        minimap = {hide = false, showInCompartment = true},
        rules = {}, -- [spellID] = {hide = true} or {avg = number}
    },
    char = {
        power = {}, -- learned max power, see PowerMax.lua
    },
    global = {
        notices = {}, -- locales that got the "no patterns" notice
    },
}
ns.DEFAULTS = defaults

-- migrations[n] upgrades a profile from schema n - 1
local migrations = {
    [1] = function() end,
}

function addon:MigrateProfile()
    local profile = self.db.profile
    local version = profile.schemaVersion or 0
    for target = version + 1, SCHEMA_VERSION do if migrations[target] then migrations[target](profile) end end
    profile.schemaVersion = SCHEMA_VERSION
end
ns.SCHEMA_VERSION = SCHEMA_VERSION

local function isSecret(value) return issecretvalue ~= nil and issecretvalue(value) end
ns.IsSecret = isSecret

function addon:Print(...) print("|cff66ccff" .. ADDON_NAME .. "|r:", ...) end
function ns.Print(...) addon:Print(...) end

-- say it once and carry on, a broken tooltip is worse than a missing line
local errorReported = false
local function onError(err)
    if not errorReported then
        errorReported = true
        addon:Print(format(L["Error, skipped (shown once): %s"], tostring(err)))
    end
end

function ns.Guard(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then onError(err) end
    return ok
end

-- the client's separators. ruRU has none, so no grouping there
local FALLBACK_SEPARATORS = {ruRU = {"", ","}}

function ns.NumberFormat()
    local fallback = FALLBACK_SEPARATORS[GetLocale()] or {",", "."}
    local tsep, dsep = LARGE_NUMBER_SEPERATOR, DECIMAL_SEPERATOR
    if type(tsep) ~= "string" or isSecret(tsep) then tsep = fallback[1] end
    if type(dsep) ~= "string" or isSecret(dsep) or dsep == "" then dsep = fallback[2] end
    return {group = addon.db.profile.look.thousands, tsep = tsep, dsep = dsep}
end

local SCHOOL_FALLBACK = {
    PHYSICAL = L["Physical"],
    HOLY = L["Holy"],
    FIRE = L["Fire"],
    NATURE = L["Nature"],
    FROST = L["Frost"],
    SHADOW = L["Shadow"],
    ARCANE = L["Arcane"],
}

function ns.SchoolName(key)
    local name = _G["STRING_SCHOOL_" .. key]
    if type(name) == "string" and not isSecret(name) and name ~= "" then return name end
    return SCHOOL_FALLBACK[key] or key
end

-- English as a backup, some texts aren't translated in other clients
function ns.PatternPack()
    local Patterns = ns.Patterns
    return Patterns[GetLocale()], Patterns.enUS
end

function addon:OnProfileChanged()
    self:MigrateProfile()
    LibStub("LibDBIcon-1.0"):Refresh(ADDON_NAME, self.db.profile.minimap)
    if ns.Options then ns.Options:OnProfileChanged() end
end

local function canReadPower(unit)
    if UnitIsDeadOrGhost(unit) then return false end
    if UnitInVehicle and UnitInVehicle(unit) then return false end
    if unit == "player" and IsPossessBarVisible and IsPossessBarVisible() then return false end
    return true
end

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("SpellwiseDB", defaults, true)
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
    self:MigrateProfile()

    ns.PowerMax.Init(self.db.char.power, {
        UnitPowerType = UnitPowerType,
        UnitPowerMax = UnitPowerMax,
        IsSecret = isSecret,
        CanRead = canReadPower,
        Now = GetTime,
        After = function(delay, fn) C_Timer.After(delay, function() ns.Guard(fn) end) end,
    }, select(2, GetBuildInfo()))

    for _, command in ipairs({"sp", "spw", "spellwise"}) do self:RegisterChatCommand(command, "OnSlashCommand") end
    self:SetupMinimapButton()
end

local POWER_EVENTS = {
    "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "UNIT_PET", "UPDATE_SHAPESHIFT_FORM", "PLAYER_ENTERING_WORLD",
    "PLAYER_TALENT_UPDATE", "TRAIT_CONFIG_UPDATED", "CHARACTER_POINTS_CHANGED", "PLAYER_EQUIPMENT_CHANGED", "PLAYER_LEVEL_UP",
}
-- these can change costs for good. form changes don't belong here, they pass
local COST_EVENTS = {
    LEARNED_SPELL_IN_SKILL_LINE = true,
    LEARNED_SPELL_IN_TAB = true,
    PLAYER_TALENT_UPDATE = true,
    TRAIT_CONFIG_UPDATED = true,
    CHARACTER_POINTS_CHANGED = true,
    PLAYER_EQUIPMENT_CHANGED = true,
    PLAYER_LEVEL_UP = true,
}

local TALENT_EVENTS = {PLAYER_ENTERING_WORLD = true, PLAYER_TALENT_UPDATE = true, TRAIT_CONFIG_UPDATED = true, CHARACTER_POINTS_CHANGED = true}

local function onEvent(_, event, ...)
    if COST_EVENTS[event] then ns.NormalCost.Clear() end
    if TALENT_EVENTS[event] then ns.Guard(ns.Spells.ScanTalents) end
    for _, name in ipairs(POWER_EVENTS) do
        if name == event then
            ns.Guard(ns.PowerMax.OnEvent, event, ...)
            break
        end
    end
end

function addon:OnEnable()
    -- plain frame, so an event this client lacks doesn't break the others
    local frame = CreateFrame("Frame")
    local registered = {}
    local function register(event)
        if not registered[event] and pcall(frame.RegisterEvent, frame, event) then registered[event] = true end
    end
    for _, event in ipairs(POWER_EVENTS) do register(event) end
    for event in pairs(COST_EVENTS) do register(event) end
    frame:SetScript("OnEvent", onEvent)
    ns.Tooltip.Enable()
end

-- names only work for spells the character knows
function ns.ResolveSpell(text)
    text = strtrim(text or "")
    if text == "" then return nil end
    local id = tonumber(text)
    local info = C_Spell.GetSpellInfo(id or text)
    if type(info) == "table" and not isSecret(info.spellID) and type(info.spellID) == "number" then return info.spellID end
    return id
end

local function printHelp()
    local function line(usage, text) print("  |cffffd100/sp " .. usage .. "|r - " .. text) end
    addon:Print(L["Commands (also /spw and /spellwise):"])
    print("  |cffffd100/sp|r - " .. L["open the settings"])
    line("reset", L["center the settings window"])
    line("dump", L["raw data of the spell under the mouse"])
    line("dump <spell>", L["the same for a spell ID or name"])
    line("dump test", L["one spell of each kind"])
    line("dump <class>", format(L["a class, one rank per wording. Classes: %s"],
                                ns.Dump.ClassList()))
    line("dump all", L["the test set and all classes"])
    line("hide <spell>", L["hide Spellwise lines on a spell"])
    line("pin <spell> <average>", L["set a spell's average damage"])
    line("show <spell>", L["remove a spell's rule"])
    line("rules", L["list the spell rules"])
end

function addon:OnSlashCommand(input)
    local command, nextPos = self:GetArgs(input, 1)
    command = command and command:lower()
    local rest = strtrim(input:sub(nextPos or #input + 1))
    local Rules = ns.Rules
    if not command then
        ns.Options:Toggle()
    elseif command == "help" then
        printHelp()
    elseif command == "reset" then
        ns.Options:ResetPosition()
    elseif command == "dump" then
        ns.Dump.Start(rest)
    elseif command == "hide" or command == "show" then
        local id = ns.ResolveSpell(rest)
        if not id then
            self:Print(command == "hide" and L["Usage: /sp hide <spell ID or name>"] or L["Usage: /sp show <spell ID or name>"])
        elseif command == "hide" then
            Rules.Hide(id)
            self:Print(format(L["Lines hidden on %s."], Rules.SpellLabel(id)))
        else
            Rules.Remove(id)
            self:Print(format(L["Rule removed from %s."], Rules.SpellLabel(id)))
        end
    elseif command == "pin" or command == "setdmg" then
        local spell, value = rest:match("^(.-)%s+([%d%.,]+)%s*$")
        local id = ns.ResolveSpell(spell)
        local average = value and tonumber((value:gsub(",", ".")))
        if not id or not average or average <= 0 then
            self:Print(L["Usage: /sp pin <spell ID or name> <average damage>"])
        else
            Rules.Pin(id, average)
            self:Print(format(L["Average damage of %s set to %s."], Rules.SpellLabel(id), tostring(average)))
        end
    elseif command == "rules" then
        local list = Rules.List()
        if #list == 0 then self:Print(L["No spell rules."]) end
        for _, entry in ipairs(list) do self:Print(Rules.Describe(entry)) end
    else
        self:Print(format(L["Unknown command \"%s\"."], command))
        printHelp()
    end
end

function addon:SetupMinimapButton()
    local launcher = LibStub("LibDataBroker-1.1"):NewDataObject(ADDON_NAME, {
        type = "launcher",
        text = ADDON_NAME,
        icon = ICON,
        OnClick = function() ns.Options:Toggle() end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine(ADDON_NAME)
            tooltip:AddLine(L["Click to open the settings."], 1, 1, 1)
        end,
    })
    LibStub("LibDBIcon-1.0"):Register(ADDON_NAME, launcher, self.db.profile.minimap)
end

function addon:SetMinimapButtonShown(shown)
    self.db.profile.minimap.hide = not shown
    local icon = LibStub("LibDBIcon-1.0")
    if shown then icon:Show(ADDON_NAME) else icon:Hide(ADDON_NAME) end
end

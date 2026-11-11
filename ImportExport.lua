-- profile export and import. a string is "!SW1!" plus the profile, serialized, deflated and printable
local ADDON_NAME, ns = ...
local L = ns.L
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

local ImportExport = {}
ns.ImportExport = ImportExport

local PREFIX = "!SW1!"
local PAYLOAD_VERSION = 1
local ENUMS = {
    costMode = {percent = true, amount = true, both = true},
    outline = {[""] = true, OUTLINE = true, THICKOUTLINE = true},
    decimals = {[0] = true, [1] = true, [2] = true},
    details = {NONE = true, ALWAYS = true, SHIFT = true, CTRL = true, ALT = true},
    points = {[1] = true, [2] = true, [3] = true, [4] = true, [5] = true},
}
local FONT_SIZE = {8, 24}

local function color(value, default)
    if type(value) ~= "table" then return nil end
    local out = {}
    for i = 1, 3 do
        local c = tonumber(value[i])
        if not c then return nil end
        out[i] = math.min(1, math.max(0, c))
    end
    return out
end

-- only values with the default's type get through, a broken string can't break the profile
local function sanitize(source, defaults)
    local out = {}
    for key, default in pairs(defaults) do
        local value = source[key]
        if type(default) == "table" and default[1] ~= nil then
            out[key] = color(value, default)
        elseif type(default) == "table" then
            if type(value) == "table" then out[key] = sanitize(value, default) end
        elseif type(value) == type(default) then
            if ENUMS[key] and not ENUMS[key][value] then
                value = nil
            elseif key == "fontSize" then
                value = math.min(FONT_SIZE[2], math.max(FONT_SIZE[1], math.floor(value)))
            end
            out[key] = value
        end
    end
    return out
end

local function sanitizeResources(source)
    local out = {}
    if type(source) ~= "table" then return out end
    for powerType, settings in pairs(source) do
        if type(powerType) == "number" and type(settings) == "table" then
            out[powerType] = {dmg = settings.dmg == true, heal = settings.heal == true, costLine = settings.costLine == true}
        end
    end
    return out
end

local function sanitizeRules(source)
    local out, count = {}, 0
    if type(source) ~= "table" then return out, 0 end
    for spellID, rule in pairs(source) do
        if type(spellID) == "number" and spellID > 0 and type(rule) == "table" then
            if rule.hide == true then
                out[spellID] = {hide = true}
            elseif type(rule.avg) == "number" and rule.avg > 0 then
                out[spellID] = {avg = rule.avg}
            end
            if out[spellID] then count = count + 1 end
        end
    end
    return out, count
end

local SECTIONS = {"lines", "show", "pets", "combo", "look"}

local function profileData(profile)
    local data = {}
    for _, section in ipairs(SECTIONS) do data[section] = profile[section] end
    data.costMode = profile.costMode
    data.resources = {}
    for powerType, settings in pairs(profile.resources) do
        if type(powerType) == "number" then data.resources[powerType] = settings end
    end
    data.rules = profile.rules
    data.minimap = {hide = profile.minimap.hide}
    return data
end

function ImportExport.GetAddonVersion() return C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") end

function ImportExport.ExportProfile(profile)
    local payload = {
        v = PAYLOAD_VERSION,
        addonVersion = ImportExport.GetAddonVersion(),
        schema = ns.SCHEMA_VERSION,
        profile = profileData(profile or ns.addon.db.profile),
    }
    local compressed = LibDeflate:CompressDeflate(LibSerialize:Serialize(payload), {level = 9})
    return PREFIX .. LibDeflate:EncodeForPrint(compressed)
end

-- checks the string, doesn't apply anything
function ImportExport.Decode(text)
    if type(text) ~= "string" then return nil, L["The import string is empty."] end
    text = text:gsub("%s", "")
    if text == "" then return nil, L["The import string is empty."] end
    if text:sub(1, #PREFIX) ~= PREFIX then return nil, L["This is not a Spellwise profile string."] end
    local decoded = LibDeflate:DecodeForPrint(text:sub(#PREFIX + 1))
    local inflated = decoded and LibDeflate:DecompressDeflate(decoded)
    if not inflated then return nil, L["The import string is damaged."] end
    local ok, payload = LibSerialize:Deserialize(inflated)
    if not ok or type(payload) ~= "table" or type(payload.profile) ~= "table" then
        return nil, L["The import string is damaged."]
    end
    if payload.v ~= PAYLOAD_VERSION then return nil, L["This string needs a newer Spellwise."] end
    if type(payload.schema) == "number" and payload.schema > ns.SCHEMA_VERSION then
        return nil, L["This string needs a newer Spellwise."]
    end
    local source, defaults = payload.profile, ns.DEFAULTS.profile
    local data = {}
    for _, section in ipairs(SECTIONS) do
        data[section] = sanitize(type(source[section]) == "table" and source[section] or {}, defaults[section])
    end
    data.costMode = ENUMS.costMode[source.costMode] and source.costMode or nil
    data.resources = sanitizeResources(source.resources)
    data.rules, data.ruleCount = sanitizeRules(source.rules)
    data.minimapHide = type(source.minimap) == "table" and type(source.minimap.hide) == "boolean" and source.minimap.hide or nil
    data.addonVersion = type(payload.addonVersion) == "string" and payload.addonVersion or nil
    return data
end

function ImportExport.Summary(data)
    local lines = {L["All settings"]}
    lines[#lines + 1] = format(L["%d spell rule(s)"], data.ruleCount)
    if data.addonVersion and data.addonVersion:match("^v?%d") then
        lines[#lines + 1] = format(L["Made with Spellwise %s"], data.addonVersion)
    end
    return table.concat(lines, "\n")
end

function ImportExport.Apply(data, profile)
    profile = profile or ns.addon.db.profile
    for _, section in ipairs(SECTIONS) do
        for key, value in pairs(data[section]) do profile[section][key] = value end
    end
    if data.costMode then profile.costMode = data.costMode end
    for powerType, settings in pairs(data.resources) do profile.resources[powerType] = settings end
    wipe(profile.rules)
    for spellID, rule in pairs(data.rules) do profile.rules[spellID] = rule end
    if data.minimapHide ~= nil then profile.minimap.hide = data.minimapHide end
    ns.addon:OnProfileChanged()
end

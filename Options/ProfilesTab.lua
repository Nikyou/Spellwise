-- profiles: switch, create, copy, delete, reset, export and import
local _, ns = ...
local L = ns.L
local W, Options = ns.Widgets, ns.Options

local controls = {}
local WIDTH = 300

local function db() return ns.addon.db end

local function profileItems(excludeCurrent)
    local items = {}
    local current = db():GetCurrentProfile()
    local profiles = db():GetProfiles()
    table.sort(profiles)
    for _, name in ipairs(profiles) do
        if not excludeCurrent or name ~= current then items[#items + 1] = {value = name, text = name} end
    end
    return items
end

local function create(parent)
    local y = 0
    local function title(text)
        Options.SectionTitle(parent, text, 0, -y)
        y = y + 22
    end
    local function help(text)
        local label = Options.Help(parent, text, 0, -y, 600)
        y = y + label:GetStringHeight() + 6
    end

    title(L["Current profile"])
    controls.current = W.Dropdown(parent, WIDTH, profileItems, function(value) db():SetProfile(value) end)
    controls.current:SetPoint("TOPLEFT", 0, -y)
    y = y + 44

    title(L["New profile"])
    controls.newName = W.EditBox(parent, WIDTH)
    controls.newName:SetPoint("TOPLEFT", 6, -y)
    local createButton = W.Button(parent, L["Create"], nil, 22, function()
        local name = strtrim(controls.newName:GetText() or "")
        if name ~= "" then
            db():SetProfile(name)
            controls.newName:SetText("")
        end
    end)
    createButton:FitWidth()
    createButton:SetPoint("LEFT", controls.newName, "RIGHT", 6, 0)
    y = y + 44

    title(L["Copy from"])
    help(L["Copies another profile into this one."])
    controls.copy = W.Dropdown(parent, WIDTH, function() return profileItems(true) end, function(value)
        Options:Confirm(format(L["Overwrite the current profile with \"%s\"?"], value),
                        {{label = L["Copy"], onClick = function() db():CopyProfile(value) end}, {label = L["Cancel"]}})
        controls.copy:SetValue(nil)
    end, L["Select a profile"])
    controls.copy:SetPoint("TOPLEFT", 0, -y)
    y = y + 44

    title(L["Delete a profile"])
    controls.delete = W.Dropdown(parent, WIDTH, function() return profileItems(true) end, function(value)
        Options:Confirm(format(L["Delete the profile \"%s\"?"], value), {
            {
                label = L["Delete"],
                onClick = function()
                    db():DeleteProfile(value)
                    Options:RefreshActiveTab()
                end,
            }, {label = L["Cancel"]},
        })
        controls.delete:SetValue(nil)
    end, L["Select a profile"])
    controls.delete:SetPoint("TOPLEFT", 0, -y)
    y = y + 44

    title(L["Reset"])
    local reset = W.Button(parent, L["Reset current profile"], nil, 22, function()
        Options:Confirm(L["Reset this profile, spell rules included?"],
                        {{label = L["Reset"], onClick = function() db():ResetProfile() end}, {label = L["Cancel"]}})
    end)
    reset:FitWidth()
    reset:SetPoint("TOPLEFT", 0, -y)
    y = y + 44

    title(L["Share"])
    help(L["Share this profile as a string. Imports ask before replacing anything."])
    local export = W.Button(parent, L["Export profile"], nil, 22, function() Options:ShowProfileExport() end)
    export:FitWidth()
    export:SetPoint("TOPLEFT", 0, -y)
    local import = W.Button(parent, L["Import profile"], nil, 22, function() Options:ShowProfileImport() end)
    import:FitWidth()
    import:SetPoint("LEFT", export, "RIGHT", 6, 0)
end

local function refresh()
    controls.current:SetValue(db():GetCurrentProfile())
    controls.copy:SetValue(nil)
    controls.delete:SetValue(nil)
end

table.insert(ns.OptionsTabs, {key = "profiles", label = L["Profiles"], Create = create, Refresh = refresh})

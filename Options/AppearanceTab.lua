-- colours, numbers and font of the added lines, with a live preview
local _, ns = ...
local L = ns.L
local LSM = LibStub("LibSharedMedia-3.0")
local W, Options = ns.Widgets, ns.Options

local controls = {}
local preview = {lines = {}, samples = {}}

local COLUMN = 390
local RIGHT = COLUMN + 30
local PREVIEW_LINES = 16

local OUTLINES = {
    {value = "", text = L["None"]}, {value = "OUTLINE", text = L["Outline"]}, {value = "THICKOUTLINE", text = L["Thick outline"]},
}
local DECIMALS = {{value = 0, text = "0"}, {value = 1, text = "1"}, {value = 2, text = "2"}}

local function look() return ns.addon.db.profile.look end

local function fontItems()
    local items = {{value = "", text = L["Tooltip font"]}}
    for _, name in ipairs(LSM:List("font")) do items[#items + 1] = {value = name, text = name, font = LSM:Fetch("font", name, true)} end
    return items
end

local function refreshPreview()
    if not preview.frame then return end
    local Tooltip = ns.Tooltip
    local path, size, flags = Tooltip.FontPath(), look().fontSize, Tooltip.FontFlags()
    local index, y = 0, -10
    local function line(text, color)
        index = index + 1
        local fontString = preview.lines[index]
        if not fontString then
            fontString = preview.frame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
            fontString:SetJustifyH("LEFT")
            preview.lines[index] = fontString
        end
        fontString:SetFont(path, size, flags)
        fontString:SetTextColor(color[1], color[2], color[3])
        fontString:SetText(text)
        fontString:ClearAllPoints()
        fontString:SetPoint("TOPLEFT", 12, y)
        fontString:Show()
        y = y - (size + 4)
    end
    Tooltip.Sample(preview.samples)
    for i, built in ipairs(preview.samples) do
        local title = i == 1 and L["Fire bolt (made up)"] or L["Healing wave (made up)"]
        line(title, {1, 1, 1})
        for n = 1, #built, 2 do
            if index < PREVIEW_LINES then line(built[n], Tooltip.Color(built[n + 1], built.school)) end
        end
        y = y - 8
    end
    for n = index + 1, #preview.lines do preview.lines[n]:Hide() end
end

local function set(key, value)
    look()[key] = value
    refreshPreview()
end

local function create(parent)
    local left = Options.Column(parent, 0, COLUMN)
    left.title(L["Colours"])
    for _, entry in ipairs({
        {"damageColor", L["Damage lines"]}, {"healColor", L["Healing lines"]}, {"costColor", L["Cost line"]},
    }) do
        local swatch = W.ColorSwatch(parent, entry[2], function(color) set(entry[1], color) end)
        left.place(swatch, 26, 2)
        controls[entry[1]] = swatch
    end
    controls.schoolTint = left.check(L["Tint damage lines by spell school"], function(checked) set("schoolTint", checked) end)

    left.title(L["Numbers"])
    left.label(L["Decimals for DPS and HPS"])
    controls.decimals = W.Dropdown(parent, 120, function() return DECIMALS end, function(value) set("decimals", value) end)
    left.place(controls.decimals, 32)
    controls.thousands = left.check(L["Thousands separator"], function(checked) set("thousands", checked) end)
    left.help(L["Your client's separator, if it has one."])

    left.title(L["Font"])
    controls.font = W.Dropdown(parent, 260, fontItems, function(value) set("font", value) end)
    left.place(controls.font, 32)
    controls.size = W.Slider(parent, L["Font size"], 8, 24, 1, 260, function(value) set("fontSize", value) end)
    left.place(controls.size, 46)
    left.label(L["Outline"])
    controls.outline = W.Dropdown(parent, 260, function() return OUTLINES end, function(value) set("outline", value) end)
    left.place(controls.outline, 32)

    local right = Options.Column(parent, RIGHT, COLUMN)
    right.title(L["Preview"])
    preview.frame = W.Panel(parent)
    preview.frame:SetSize(COLUMN, 380)
    right.place(preview.frame, 380)
end

local function refresh()
    local l = look()
    controls.damageColor:SetColor(l.damageColor)
    controls.healColor:SetColor(l.healColor)
    controls.costColor:SetColor(l.costColor)
    controls.schoolTint:SetChecked(l.schoolTint)
    controls.decimals:SetValue(l.decimals)
    controls.thousands:SetChecked(l.thousands)
    controls.font:SetValue(l.font)
    controls.size:SetValue(l.fontSize)
    controls.outline:SetValue(l.outline)
    refreshPreview()
end

table.insert(ns.OptionsTabs, {key = "appearance", label = L["Appearance"], Create = create, Refresh = refresh})

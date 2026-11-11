-- spell rules: a list with add, edit, remove and clear all
local _, ns = ...
local L = ns.L
local W, Style, Options = ns.Widgets, ns.Style, ns.Options

local controls = {}
local rows = {}
local ROW = 26
local WIDTH = 810

local ACTIONS = {{value = "hide", text = L["Hide the lines"]}, {value = "avg", text = L["Set the average damage"]}}

local function showError(text)
    controls.status:SetTextColor(unpack(Style.WARN))
    controls.status:SetText(text)
end

local function showDone(text)
    controls.status:SetTextColor(unpack(Style.MUTED))
    controls.status:SetText(text)
end

local function save()
    local spellID = ns.ResolveSpell(controls.spell:GetText())
    if not spellID or not C_Spell.GetSpellInfo(spellID) then
        showError(L["No such spell. Names only work for spells you know."])
        return
    end
    if controls.action.value == "avg" then
        local average = tonumber(((controls.value:GetText() or ""):gsub(",", ".")))
        if not average or average <= 0 then
            showError(L["Enter a number above 0."])
            return
        end
        ns.Rules.Pin(spellID, average)
    else
        ns.Rules.Hide(spellID)
    end
    showDone(format(L["Saved: %s"], ns.Rules.SpellLabel(spellID)))
    controls.spell:SetText("")
    controls.value:SetText("")
end

local function edit(entry)
    controls.spell:SetText(tostring(entry.spellID))
    controls.action:SetValue(entry.rule.hide and "hide" or "avg")
    controls.value:SetText(entry.rule.avg and tostring(entry.rule.avg) or "")
    showDone(format(L["Editing %s. Change it and press Save."], entry.label))
end

local function rowAt(index)
    local row = rows[index]
    if row then return row end
    local content = controls.list.scroll.content
    row = CreateFrame("Button", nil, content)
    row:SetHeight(ROW)
    row:SetPoint("TOPLEFT", 0, -(index - 1) * ROW)
    row:SetPoint("RIGHT")
    W.StyleRow(row)
    row.text = W.Label(row, "")
    row.text:SetPoint("LEFT", 6, 0)
    row.text:SetPoint("RIGHT", -190, 0)
    row.text:SetWordWrap(false)
    row.remove = W.Button(row, L["Remove"], nil, 20)
    row.remove:FitWidth()
    row.remove:SetPoint("RIGHT", -4, 0)
    row.edit = W.Button(row, L["Edit"], nil, 20)
    row.edit:FitWidth()
    row.edit:SetPoint("RIGHT", row.remove, "LEFT", -4, 0)
    rows[index] = row
    return row
end

local function refresh()
    local list = ns.Rules.List()
    for index, entry in ipairs(list) do
        local row = rowAt(index)
        row.text:SetText(ns.Rules.Describe(entry))
        row.edit:SetScript("OnClick", function() edit(entry) end)
        row.remove:SetScript("OnClick", function() ns.Rules.Remove(entry.spellID) end)
        row:Show()
    end
    for index = #list + 1, #rows do rows[index]:Hide() end
    controls.list.scroll:SetContentHeight(#list * ROW)
    controls.empty:SetShown(#list == 0)
    controls.clear:SetEnabled(#list > 0)
end

local function create(parent)
    Options.SectionTitle(parent, L["Add or change a rule"], 0, 0)
    Options.Help(parent, L["Hide a spell's lines or fix its average damage. Also /sp hide, /sp pin, /sp show."], 0, -24, WIDTH)

    local spellLabel = W.Label(parent, L["Spell name or ID"])
    spellLabel:SetPoint("TOPLEFT", 0, -62)
    controls.spell = W.EditBox(parent, 240)
    controls.spell:SetPoint("TOPLEFT", 6, -80)
    controls.spell:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        save()
    end)

    local actionLabel = W.Label(parent, L["Rule"])
    actionLabel:SetPoint("TOPLEFT", 270, -62)
    controls.action = W.Dropdown(parent, 240, function() return ACTIONS end, function(value) controls.action.value = value end)
    controls.action:SetPoint("TOPLEFT", 270, -78)

    local valueLabel = W.Label(parent, L["Average damage"])
    valueLabel:SetPoint("TOPLEFT", 530, -62)
    controls.value = W.EditBox(parent, 120)
    controls.value:SetPoint("TOPLEFT", 536, -80)

    local saveButton = W.Button(parent, L["Save"], nil, 22, save)
    saveButton:FitWidth()
    saveButton:SetPoint("TOPLEFT", 680, -79)

    controls.status = W.Label(parent, "", 11, Style.MUTED)
    controls.status:SetPoint("TOPLEFT", 0, -108)
    controls.status:SetWidth(WIDTH)

    Options.SectionTitle(parent, L["Spell rules"], 0, -136)
    controls.list = W.Panel(parent)
    controls.list:SetPoint("TOPLEFT", 0, -160)
    controls.list:SetSize(WIDTH, 300)
    controls.list.scroll = W.ScrollArea(controls.list)
    controls.list.scroll:SetPoint("TOPLEFT", 8, -6)
    controls.list.scroll:SetPoint("BOTTOMRIGHT", -26, 6)
    controls.empty = W.Label(controls.list, L["No spell rules yet."], nil, Style.MUTED)
    controls.empty:SetPoint("TOPLEFT", 14, -14)

    controls.clear = W.Button(parent, L["Clear all"], nil, 22, function()
        Options:Confirm(L["Delete all spell rules?"], {{label = L["Delete"], onClick = ns.Rules.Clear}, {label = L["Cancel"]}})
    end)
    controls.clear:FitWidth()
    controls.clear:SetPoint("TOPLEFT", 0, -470)

    controls.action:SetValue("hide")
end

table.insert(ns.OptionsTabs, {key = "rules", label = L["Spell rules"], Create = create, Refresh = refresh})

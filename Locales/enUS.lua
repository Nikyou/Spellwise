-- interface strings in English, the keys every translation uses
local L = LibStub("AceLocale-3.0"):NewLocale("Spellwise", "enUS", true)
if not L then return end

-- Core.lua
L["Error, skipped (shown once): %s"] = true
L["Physical"] = true
L["Holy"] = true
L["Fire"] = true
L["Nature"] = true
L["Frost"] = true
L["Shadow"] = true
L["Arcane"] = true
L["Commands (also /spw and /spellwise):"] = true
L["open the settings"] = true
L["center the settings window"] = true
L["raw data of the spell under the mouse"] = true
L["the same for a spell ID or name"] = true
L["one spell of each kind"] = true
L["a class, one rank per wording. Classes: %s"] = true
L["the test set and all classes"] = true
L["hide Spellwise lines on a spell"] = true
L["set a spell's average damage"] = true
L["remove a spell's rule"] = true
L["list the spell rules"] = true
L["Usage: /sp hide <spell ID or name>"] = true
L["Usage: /sp show <spell ID or name>"] = true
L["Lines hidden on %s."] = true
L["Rule removed from %s."] = true
L["Usage: /sp pin <spell ID or name> <average damage>"] = true
L["Average damage of %s set to %s."] = true
L["No spell rules."] = true
L["Unknown command \"%s\"."] = true
L["Click to open the settings."] = true

-- Rules.lua
L["%s: lines hidden"] = true
L["%s: average damage %s"] = true

-- Tooltip.lua
L["DPM"] = true
L["HPM"] = true
L["DPR"] = true
L["HPR"] = true
L["DPE"] = true
L["HPE"] = true
L["DPF"] = true
L["HPF"] = true
L["No damage or healing values for your game language (%s) yet, only costs. To help, send the author /sp dump all."] = true
L["Free now, normally %s"] = true
L["Free now"] = true
L["Hold %s for details"] = true
L["Combo points: %d"] = true
L["Combo points %d: %s"] = true
L["%s damage"] = true
L["Crit can't be read right now, it's left out"] = true
L["Heal crit %s%% ×%s: +%s%% on average"] = true
L["Crit %s%% ×%s: +%s%% on average"] = true
L["Target level +%d (boss): crit %s%%, %s"] = true
L["Target level +%d: crit %s%%, %s"] = true
L["Spell crit doesn't depend on target level"] = true

-- Dump.lua
L["Spellwise dump"] = true
L["Loading %d spell(s), the text updates."] = true
L["Copy with Ctrl+A, Ctrl+C and send it to the author."] = true
L["Close"] = true
L["Hover a spell or name one: /sp dump <spell>"] = true
L["\"%s\" is no spell or class. Classes: %s"] = true

-- ImportExport.lua
L["The import string is empty."] = true
L["This is not a Spellwise profile string."] = true
L["The import string is damaged."] = true
L["This string needs a newer Spellwise."] = true
L["%d spell rule(s)"] = true
L["Made with Spellwise %s"] = true
L["All settings"] = true

-- Format.lua
L["HPS"] = true
L["DPS"] = true
L["Per cast: %s"] = true
L["HoT: %s over %s sec"] = true
L["DoT: %s over %s sec"] = true
L["HoT: %s"] = true
L["DoT: %s"] = true
L["Total per cast: %s"] = true
L["Per hit: %s"] = true
L["Absorb: %s"] = true
L["channel time"] = true
L["global cooldown"] = true
L["cooldown"] = true
L["cast time"] = true
L["Divided by %s sec (%s)"] = true
L["Cooldown of %s sec not counted"] = true
L["%s charges of %s each, %s in total"] = true
L["Healing: %s over a %s sec channel"] = true
L["Damage: %s over a %s sec channel"] = true
L["Healing: %s"] = true
L["Damage: %s"] = true
L["Healing over time: %s over %s sec"] = true
L["Damage over time: %s over %s sec"] = true
L["Per hit: %s (no attack rate in the text)"] = true
L["School: %s"] = true
L["Cost: %s"] = true
L["Values are per target"] = true
L["Average damage set by a spell rule"] = true
L["Includes your bonuses, as the game shows them"] = true
L["%s: %s%% of base"] = true
L["Free"] = true

-- Options/Options.lua
L["Please confirm"] = true
L["Export profile"] = true
L["Copy this string (Ctrl+C) and share it."] = true
L["Import profile"] = true
L["Paste a profile string (Ctrl+V)."] = true
L["Import"] = true
L["Enter a profile name."] = true
L["The profile \"%s\" already exists. Overwrite it?"] = true
L["Overwrite"] = true
L["Cancel"] = true
L["Import into a new profile or over \"%s\"?"] = true
L["New profile name"] = true
L["Imported"] = true
L["Create profile"] = true
L["Into current"] = true
L["Overwrite \"%s\"?"] = true

-- Options/LinesTab.lua
L["DPM: damage per mana"] = true
L["HPM: healing per mana"] = true
L["DPR: damage per rage"] = true
L["HPR: healing per rage"] = true
L["DPE: damage per energy"] = true
L["HPE: healing per energy"] = true
L["DPF: damage per focus"] = true
L["HPF: healing per focus"] = true
L["Mana cost"] = true
L["Rage cost"] = true
L["Energy cost"] = true
L["Focus cost"] = true
L["Percent of your maximum"] = true
L["Amount"] = true
L["Amount and percent"] = true
L["Lines"] = true
L["DPS: damage per second"] = true
L["HPS: healing per second"] = true
L["DoT and HoT lines"] = true
L["Show their total and duration"] = true
L["Per cast line (no DoT or HoT)"] = true
L["Include the cooldown"] = true
L["Cost line"] = true
L["Show the cost as"] = true
L["Show on"] = true
L["Action bars, macros included"] = true
L["Spellbook"] = true
L["Other tooltips (chat links, addons)"] = true
L["Pets have their own tab."] = true
L["Minimap"] = true
L["Show minimap button"] = true
L["About the values"] = true
L["Tooltips already include your bonuses, Spellwise takes them as shown. No hit chance. Area spells: per target."] = true
L["Divide by the cooldown when it's longer than the cast."] = true
L["Cost"] = true
L["Per resource"] = true
L["Include crit"] = true
L["Average with your crit chance and talents, against a target of your level. The details show higher levels."] = true

-- Options/DetailsTab.lua
L["Never"] = true
L["Always"] = true
L["While %s is held"] = true
L["Show details"] = true
L["Details"] = true
L["In the details"] = true
L["Damage and healing amounts"] = true
L["Time the values are divided by"] = true
L["Spell school"] = true
L["Costs"] = true
L["Each number of combo points"] = true
L["More rage or energy (%s, %s)"] = true
L["Notes: per target, spell rules, bonuses"] = true
L["Crit"] = true
L["Crit chance and size"] = true
L["Higher level targets"] = true
L["Shown when Include crit is on in the Lines tab."] = true

-- Options/AppearanceTab.lua
L["None"] = true
L["Outline"] = true
L["Thick outline"] = true
L["Tooltip font"] = true
L["Fire bolt (made up)"] = true
L["Healing wave (made up)"] = true
L["Colours"] = true
L["Damage lines"] = true
L["Healing lines"] = true
L["Tint damage lines by spell school"] = true
L["Numbers"] = true
L["Decimals for DPS and HPS"] = true
L["Thousands separator"] = true
L["Your client's separator, if it has one."] = true
L["Font"] = true
L["Font size"] = true
L["Preview"] = true
L["Appearance"] = true

-- Options/PetsTab.lua
L["Pet action bar"] = true
L["Pet spellbook"] = true
L["Lines on pet abilities"] = true
L["Can only turn off what the Lines tab shows."] = true
L["Damage and healing per cost (DPM, HPM)"] = true
L["Costs and maximums come from your pet."] = true
L["Pets: show on"] = true
L["Finishers"] = true
L["Lines on finishers"] = true
L["Combo points for the lines"] = true
L["%s, %s and other finishers: the lines use this many combo points, the details show all. DPS leaves out building them."] = true
L["Pets and finishers"] = true

-- Options/RulesTab.lua
L["Hide the lines"] = true
L["Set the average damage"] = true
L["No such spell. Names only work for spells you know."] = true
L["Enter a number above 0."] = true
L["Saved: %s"] = true
L["Editing %s. Change it and press Save."] = true
L["Remove"] = true
L["Edit"] = true
L["Add or change a rule"] = true
L["Hide a spell's lines or fix its average damage. Also /sp hide, /sp pin, /sp show."] = true
L["Spell name or ID"] = true
L["Rule"] = true
L["Average damage"] = true
L["Save"] = true
L["Spell rules"] = true
L["No spell rules yet."] = true
L["Clear all"] = true
L["Delete all spell rules?"] = true
L["Delete"] = true

-- Options/ProfilesTab.lua
L["Current profile"] = true
L["New profile"] = true
L["Create"] = true
L["Copy from"] = true
L["Copies another profile into this one."] = true
L["Overwrite the current profile with \"%s\"?"] = true
L["Copy"] = true
L["Select a profile"] = true
L["Delete a profile"] = true
L["Delete the profile \"%s\"?"] = true
L["Reset"] = true
L["Reset current profile"] = true
L["Reset this profile, spell rules included?"] = true
L["Share"] = true
L["Share this profile as a string. Imports ask before replacing anything."] = true
L["Profiles"] = true

-- Spells.lua
L["Mana"] = true
L["%s Mana"] = true
L["Rage"] = true
L["%s Rage"] = true
L["Focus"] = true
L["%s Focus"] = true
L["Energy"] = true
L["%s Energy"] = true
L["Combo Points"] = true
L["%s Combo Points"] = true

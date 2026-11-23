-- weapon damage from the character sheet, for abilities that hit with a weapon and for auto attacks
local _, ns = ...

local Weapon = {}
ns.Weapon = Weapon

local Spells, Metrics, Parser = ns.Spells, ns.Metrics, ns.Parser
local isSecret, number, text = ns.IsSecret, Spells.Number, Spells.Text
local type, ipairs, wipe, format = type, ipairs, wipe, string.format

local SLOTS = {mh = 16, oh = 17, ranged = 18}
-- the client's own names
local NAMES = {mh = {"MAINHANDSLOT", "Main Hand"}, oh = {"SECONDARYHANDSLOT", "Off Hand"}, ranged = {"RANGEDSLOT", "Ranged"}}

-- normalized abilities count these speeds, not the weapon's own
local NORMAL_DAGGER, NORMAL_TWO_HAND, NORMAL_ONE_HAND, NORMAL_RANGED = 1.7, 3.3, 2.4, 2.8
local WEAPON_CLASS, DAGGER, WAND = 2, 15, 19
local RANGED_SLOTS = {INVTYPE_RANGED = true, INVTYPE_RANGEDRIGHT = true, INVTYPE_THROWN = true}
-- cat, bear and dire bear fight with paws of their own, whatever is in the hands
local FERAL_FORMS = {[1] = true, [5] = true, [8] = true}

-- Attack, Auto Shot and wand Shoot
local AUTO = {[6603] = "melee", [75] = "ranged", [5019] = "wand"}
Weapon.AUTO = AUTO

local function handName(key)
    local name = NAMES[key]
    return text(_G[name[1]]) or name[2]
end

-- a weapon's speed is in its tooltip ("Speed 2.60"), the sheet has a hasted one. any language: the right side
-- of the damage line is the only one with a decimal number
local function tooltipSpeed(slot)
    if not (C_TooltipInfo and C_TooltipInfo.GetInventoryItem) then return nil end
    local ok, data = pcall(C_TooltipInfo.GetInventoryItem, "player", slot)
    local lines = ok and type(data) == "table" and not isSecret(data) and data.lines
    if type(lines) ~= "table" or isSecret(lines) then return nil end
    for _, line in ipairs(lines) do
        local right = type(line) == "table" and not isSecret(line) and text(line.rightText)
        local whole, fraction = (right or ""):match("(%d+)[%.,](%d+)")
        local speed = whole and tonumber(whole .. "." .. fraction)
        if speed and speed >= 0.5 and speed <= 6 then return speed end
    end
end

local function itemInstant(id)
    local get = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
    if not get then return nil end
    local _, _, _, equipLoc, _, classID, subclassID = get(id)
    return text(equipLoc), number(classID), number(subclassID)
end

-- what kind of weapon, by item. speed stays nil until the tooltip has it
local items = {}

local function itemInfo(slot)
    local id = number(GetInventoryItemID("player", slot))
    if not id then return nil end
    local key = text(GetInventoryItemLink("player", slot)) or id
    local info = items[key]
    if info and info.speed then return info end
    if not info then
        local equipLoc, classID, subclassID = itemInstant(id)
        if classID ~= WEAPON_CLASS then return nil end
        local normal = NORMAL_ONE_HAND
        if subclassID == DAGGER then
            normal = NORMAL_DAGGER
        elseif equipLoc == "INVTYPE_2HWEAPON" then
            normal = NORMAL_TWO_HAND
        elseif RANGED_SLOTS[equipLoc] then
            normal = NORMAL_RANGED
        end
        info = {normal = normal, dagger = subclassID == DAGGER, wand = subclassID == WAND}
        items[key] = info
    end
    info.speed = tooltipSpeed(slot)
    return info
end

local function sum(a, b, c) return a and (a + (b or 0) + (c or 0)) end
local function average(low, high) return low and high and (low + high) / 2 end

-- the last readable sheet, stats can turn secret in combat
local last = {}

local function readSheet()
    local s = {}
    local minMain, maxMain, minOff, maxOff, _, _, percent = UnitDamage("player")
    local mainSpeed, offSpeed = UnitAttackSpeed("player")
    local rangedSpeed, minRanged, maxRanged, _, _, rangedPercent = UnitRangedDamage("player")
    s.mh = average(number(minMain), number(maxMain))
    s.oh = average(number(minOff), number(maxOff))
    s.ranged = average(number(minRanged), number(maxRanged))
    s.mhSpeed, s.ohSpeed, s.rangedSpeed = number(mainSpeed), number(offSpeed), number(rangedSpeed)
    s.percent, s.rangedPercent = number(percent) or 1, number(rangedPercent) or 1
    local base, plus, minus = UnitAttackPower("player")
    s.ap = sum(number(base), number(plus), number(minus))
    base, plus, minus = UnitRangedAttackPower("player")
    s.rap = sum(number(base), number(plus), number(minus))
    if s.mh and s.mhSpeed and s.ap then
        last.melee = s
    elseif last.melee then
        s = last.melee
    else
        return nil
    end
    return s
end

local function feral()
    local form = GetShapeshiftFormID and GetShapeshiftFormID()
    return not isSecret(form) and FERAL_FORMS[form] == true
end

local hands = {}

-- each weapon as Metrics wants it, nil for a hand without one. ap and rap ride along
function Weapon.Hands()
    local s = readSheet()
    if not s then return nil end
    wipe(hands)
    hands.ap, hands.rap = s.ap, s.rap or 0
    local paws = feral()
    local function hand(key, avg, swing, percent)
        local item = not paws and itemInfo(SLOTS[key])
        hands[key] = {
            name = handName(key), avg = avg, swing = swing, percent = percent, share = key == "oh" and 0.5 or 1,
            speed = item and item.speed or swing, normal = item and item.normal, dagger = item and item.dagger,
            wand = item and item.wand, armed = paws or item ~= nil,
        }
    end
    hand("mh", s.mh, s.mhSpeed, s.percent)
    if s.oh and s.oh > 0 and s.ohSpeed and s.ohSpeed > 0 then hand("oh", s.oh, s.ohSpeed, s.percent) end
    if s.ranged and s.ranged > 0 and s.rangedSpeed and s.rangedSpeed > 0 and GetInventoryItemID("player", SLOTS.ranged) then
        hand("ranged", s.ranged, s.rangedSpeed, s.rangedPercent)
    end
    return hands
end

local function emptyHeal() return {direct = 0, periodic = 0, absorb = 0} end

-- the bonus as the text words it, cached like the parses: by spell, exact text and what the tables expect
local bonuses, bonusCount = {}, 0

local function textBonus(spellID, desc, expected, percent)
    if not desc then return nil end
    local key = spellID .. "\0" .. expected .. "\0" .. desc
    local cached = bonuses[key]
    if cached == nil then
        local pack, fallback = ns.PatternPack()
        cached = Parser.WeaponBonus(desc, pack or fallback, expected, percent) or false
        if bonusCount >= 400 then
            wipe(bonuses)
            bonusCount = 0
        end
        bonuses[key], bonusCount = cached, bonusCount + 1
    end
    return cached or nil
end

local function levelBonus(entry)
    local bonus, scaling = entry[3], entry.level
    if not scaling then return bonus end
    local level = number(UnitLevel("player"))
    if not level then return bonus end
    if scaling[3] > 0 then level = math.min(level, scaling[3]) end
    return bonus + scaling[1] * math.max(0, level - scaling[2])
end

local SPELL_SCHOOLS = {HOLY = 2, FIRE = 3, NATURE = 4, FROST = 5, SHADOW = 6, ARCANE = 7}

-- Holy Strike's text has spell power in its bonus, the tables don't
local function spellPower(entry)
    if not entry.sp or not GetSpellBonusDamage then return 0 end
    return entry.sp * (number(GetSpellBonusDamage(SPELL_SCHOOLS[entry.school] or 2)) or 0)
end

-- the weapons a strike uses. a hand needs a weapon in it, a fist can only Attack
local function strikeWeapons(all, hand)
    local out = {}
    if hand == "both" then
        if not all.mh.armed then return out end
        out[1] = all.mh
        if all.oh and all.oh.armed then out[2] = all.oh end
    elseif all[hand] and all[hand].armed then
        out[1] = all[hand]
    end
    return out
end

-- a result like the parser's, from the weapons. nil when a weapon it needs isn't there or can't be read.
-- parsed: the text's own result, for the area words
function Weapon.Strike(spellID, entry, desc, parsed)
    local all = Weapon.Hands()
    if not all then return nil end
    local _, class = UnitClass("player")
    -- Claw and Shred need a paw, a staff's numbers would be nonsense
    if text(class) == "DRUID" and not feral() then return nil end
    local hand, normalized, percent = entry[1], entry[2], entry[4]
    local weapons = strikeWeapons(all, hand)
    if #weapons == 0 or weapons[1].wand then return nil end
    if entry.dagger and all.mh.dagger then percent = entry.dagger end
    local expected = (levelBonus(entry) + spellPower(entry)) * percent / 100
    local bonus = textBonus(spellID, desc, expected, entry[4]) or expected
    local total, strike = Metrics.WeaponStrike(weapons, hand == "ranged" and all.rap or all.ap, normalized, percent, bonus)
    if entry.extra then
        strike.extra = {entry.extra[1], entry.extra[2], entry.extra[1] == "flametongue" and (Spells.Name(8024) or "Flametongue Weapon")}
    end
    local dmg = {direct = total, periodic = 0, perHit = 0, school = entry.school or "PHYSICAL", strike = strike, fromWeapon = true}
    -- the swing would hit anyway: its time is the swing's, and the cost buys only the bonus
    if entry.swing then
        strike.swing, dmg.added = true, bonus * weapons[1].percent
    end
    return {
        dmg = dmg,
        heal = emptyHeal(),
        area = parsed and parsed.area or false,
        critKind = hand == "ranged" and "ranged" or "melee",
        swing = entry.swing and weapons[1].swing or nil,
    }
end

-- Attack swings each weapon at its own speed, Auto Shot and Shoot fire the ranged one
function Weapon.Auto(spellID)
    local kind = AUTO[spellID]
    local all = kind and Weapon.Hands()
    if not all then return nil end
    local list = {}
    if kind == "melee" then
        list[1] = all.mh
        list[2] = all.oh
    elseif all.ranged and (kind == "wand") == (all.ranged.wand == true) then
        list[1] = all.ranged
    end
    if #list == 0 then return nil end
    local out = {}
    for i, w in ipairs(list) do out[i] = {name = w.name, hit = w.avg, every = w.swing} end
    local wand = kind == "wand"
    return {
        -- a wand's school is the wand's, the sheet doesn't say
        dmg = {direct = 0, periodic = 0, perHit = out[1].hit, hands = out, school = not wand and "PHYSICAL" or nil,
               fromWeapon = not wand},
        heal = emptyHeal(),
        area = false,
        -- wand shots crit like spells
        critKind = wand and "spell" or kind,
    }
end

-- for the dump: the sheet and each weapon as Spellwise reads them
function Weapon.Describe(out)
    local function value(v)
        if isSecret(v) then return "<secret>" end
        return tostring(v)
    end
    local function list(...)
        local parts = {}
        for i = 1, select("#", ...) do parts[i] = value((select(i, ...))) end
        return table.concat(parts, " ")
    end
    out[#out + 1] = "  UnitDamage = " .. list(UnitDamage("player"))
    out[#out + 1] = "  UnitAttackSpeed = " .. list(UnitAttackSpeed("player"))
    out[#out + 1] = "  UnitRangedDamage = " .. list(UnitRangedDamage("player"))
    out[#out + 1] = "  UnitAttackPower = " .. list(UnitAttackPower("player"))
    out[#out + 1] = "  UnitRangedAttackPower = " .. list(UnitRangedAttackPower("player"))
    for _, key in ipairs({"mh", "oh", "ranged"}) do
        local slot = SLOTS[key]
        local id = GetInventoryItemID("player", slot)
        local line = format("  item %s = id=%s", key, value(id))
        if number(id) then
            local equipLoc, classID, subclassID = itemInstant(id)
            line = line .. format(" equipLoc=%s class=%s/%s speed=%s", value(equipLoc), value(classID), value(subclassID),
                                  value(tooltipSpeed(slot)))
        end
        out[#out + 1] = line
    end
    local all = Weapon.Hands()
    for _, key in ipairs({"mh", "oh", "ranged"}) do
        local w = all and all[key]
        if w then
            out[#out + 1] = format("  weapon %s = avg=%.1f swing=%s speed=%s normal=%s normalizedHit=%.1f", key, w.avg,
                                   value(w.swing), value(w.speed), value(w.normal),
                                   Metrics.WeaponHit(w, key == "ranged" and all.rap or all.ap, true))
        end
    end
end

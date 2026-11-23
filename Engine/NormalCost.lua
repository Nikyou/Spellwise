-- the last cost above 0 per spell, for free casts and druid forms
local _, ns = ...

local NormalCost = {}
ns.NormalCost = NormalCost

local remembered = {} -- [powerType][spellID] = cost

-- costs are shown as the API gives them, so Inner Focus or Arcane Power show while they last.
-- a 0 has nothing to divide by, so the last cost above 0 fills in. in a form (Cat Form, mana spell)
-- the API answer means nothing and it fills in quietly, otherwise the cast is free right now
function NormalCost.Get(spellID, powerType, apiCost, inForm)
    local byType = remembered[powerType]
    if type(apiCost) == "number" and apiCost > 0 and not inForm then
        if not byType then
            byType = {}
            remembered[powerType] = byType
        end
        byType[spellID] = apiCost
        return apiCost, false
    end
    local known = byType and byType[spellID]
    if inForm then return known or (type(apiCost) == "number" and apiCost > 0 and apiCost or nil), false end
    -- a 0 for a resource the spell never cost isn't a free cast, the spell just doesn't use it
    return known, apiCost == 0 and known ~= nil
end

-- for when a form drops the mana entry
function NormalCost.Known(spellID, out)
    for powerType, byType in pairs(remembered) do if byType[spellID] then out[powerType] = byType[spellID] end end
    return out
end

-- a spell might be free for good now
function NormalCost.Clear() wipe(remembered) end

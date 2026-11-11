-- the DPS, DPM, HPS and HPM maths. no WoW API in here
local _, ns = ...

local Metrics = {}
ns.Metrics = Metrics

local pairs = pairs

Metrics.GCD = 1.5

-- cast or channel time, at least the GCD. the cooldown only if asked for and longer
function Metrics.DirectTime(base, channeled, t)
    local time, reason = base or 0, channeled and "channel" or "cast"
    local gcd = t.gcd and t.gcd > 0 and t.gcd or Metrics.GCD
    if gcd > time then time, reason = gcd, "gcd" end
    if t.useCooldown and (t.cooldown or 0) > time then time, reason = t.cooldown, "cooldown" end
    return time, reason
end

local function perCost(amount, cost)
    if amount and amount > 0 and cost and cost > 0 then return amount / cost end
end

-- every power type, shown or not, so turning one on later is just a setting
local function costValues(side, costs)
    local out = {}
    for powerType, cost in pairs(costs or {}) do
        out[powerType] = {
            direct = perCost(side.direct, cost),
            periodic = perCost(side.periodic, cost),
            total = perCost(side.total, cost),
            absorb = perCost(side.absorb, cost),
        }
    end
    return out
end

local function side(src, t, costs)
    local m = {
        direct = src.direct or 0,
        periodic = src.periodic or 0,
        periodicTime = src.duration,
        perHit = src.perHit or 0,
        absorb = src.absorb or 0,
        charges = src.charges,
        perCharge = src.perCharge,
        school = src.school,
    }
    -- a channel's ticks are the spell itself, divided by the channel time
    local base = t.cast or 0
    if t.channeled and m.periodic > 0 and m.direct == 0 then
        m.direct, m.channel, base = m.periodic, true, m.periodicTime or 0
        m.periodic, m.periodicTime = 0, nil
    end
    if m.direct > 0 and not m.charges then
        m.time, m.reason = Metrics.DirectTime(base, m.channel, t)
        m.perSec = m.direct / m.time
        if (t.cooldown or 0) > m.time then m.cooldownLeftOut = t.cooldown end
    end
    if m.periodic > 0 and m.periodicTime and m.periodicTime > 0 then m.periodicPerSec = m.periodic / m.periodicTime end
    if m.direct > 0 and m.periodic > 0 then m.total = m.direct + m.periodic end
    m.perCost = costValues(m, costs)
    return m
end

function Metrics.Compute(parsed, t, costs)
    return {
        dmg = side(parsed.dmg, t, costs),
        heal = side(parsed.heal, t, costs),
        area = parsed.area,
        pinned = parsed.pinned,
        costs = costs,
    }
end

function Metrics.HasDamage(m) return m.dmg.direct > 0 or m.dmg.periodic > 0 or m.dmg.perHit > 0 end
function Metrics.HasHealing(m) return m.heal.direct > 0 or m.heal.periodic > 0 or m.heal.absorb > 0 end

-- Crit

-- crit damage bonus: spells and heals crit for 1.5x, melee and ranged abilities for 2x.
-- talents raise the bonus, not the multiplier: +100% turns 1.5x into 2x
Metrics.CRIT_BONUS = {spell = 0.5, melee = 1, ranged = 1}

function Metrics.CritMultiplier(kind, bonusPercent)
    return 1 + Metrics.CRIT_BONUS[kind] * (1 + (bonusPercent or 0) / 100)
end

-- expected damage per hit relative to a hit that doesn't crit
function Metrics.CritFactor(chance, multiplier)
    chance = math.min(1, math.max(0, chance or 0))
    return 1 + chance * (multiplier - 1)
end

-- a higher target lowers melee and ranged crit by 1% per level (5 defense points each), spells keep theirs
function Metrics.CritAgainst(kind, chance, levelsAbove)
    if kind == "spell" then return chance end
    return math.max(0, chance - 0.01 * levelsAbove)
end

local function scaled(side, factor, isHeal)
    local out = {}
    for k, v in pairs(side) do out[k] = v end
    out.direct = (side.direct or 0) * factor
    out.periodic = (side.periodic or 0) * factor
    if side.perHit then out.perHit = side.perHit * factor end
    -- absorbs never crit
    if isHeal then out.absorb = side.absorb end
    return out
end

-- a new result with crits counted in. on Forever most damage and healing over time can crit too
function Metrics.WithCrit(parsed, dmgFactor, healFactor)
    local out = {}
    for k, v in pairs(parsed) do out[k] = v end
    out.dmg = scaled(parsed.dmg, dmgFactor)
    out.heal = scaled(parsed.heal, healFactor, true)
    if parsed.extraPerPoint then out.extraPerPoint = parsed.extraPerPoint * dmgFactor end
    if parsed.combo then
        out.combo = {}
        for points, row in ipairs(parsed.combo) do out.combo[points] = Metrics.WithCrit(row, dmgFactor, healFactor) end
    end
    return out
end

-- English, and the rule format every pack uses. the text gets A-Z lowercased and its numbers tidied first
local _, ns = ...
ns.Patterns = ns.Patterns or {}

-- rules run top to bottom and cut out what they match, so put the specific ones first.
-- a rule is {side, shape, pattern(s)}, optionally with when = "helpful", "harmful", "healOnly" or "notHarmful".
-- sides: dmg, heal, absorb, drain (the same amount as damage and healing), auto (healing if the spell is
-- only helpful), none. shapes: direct, over (amount and duration), tick (amount every so often), charges,
-- hit (per attack, no rate), ignore (cut the clause, it has no amount). a tick rule with interval = 1
-- is for "each second". placeholders: {v} amount or range, {n} number, {d} number with a time unit,
-- {s} school words only, {w} words in the same clause, {x} anything but a number.
-- finisher rows (comboRow, one wording or a list) are read one by one with the same rules
ns.Patterns.enUS = {
    ranges = {"{n} to {n}"},
    units = {{"seconds", 1}, {"second", 1}, {"sec", 1}, {"minutes", 60}, {"minute", 60}, {"min", 60}},
    -- the mixed schools first, "spellfire" would read as fire otherwise and leave "spell" in the slot
    schools = {
        {"spellfire", "FIRE"}, {"spellfrost", "FROST"}, {"shadowflame", "SHADOW"}, {"chimeric", "ARCANE"}, {"chaos", "SHADOW"},
        {"physical", "PHYSICAL"}, {"holy", "HOLY"}, {"fire", "FIRE"}, {"nature", "NATURE"}, {"frost", "FROST"},
        {"shadow", "SHADOW"}, {"arcane", "ARCANE"},
    },
    fillers = {"additional"},
    weapon = {
        -- "ranged damage" alone would catch Inner Fire's "melee or ranged damage hit against the priest"
        "weapon damage", "melee damage", "deals ranged damage", "increases ranged damage", "each hit", "main hand hit",
        "next attack", "per swing", "normal damage", "main hand weapon", "% damage plus",
    },
    -- finishers: one row per number of combo points, "1 point: ..." "2 points: ..."
    comboRow = "{n} point",
    -- damage per point of rage or energy spent above the cost (Execute, Ferocious Bite)
    extraPerPoint = {
        "each extra point of rage into {v} additional damage", "each extra point of energy into {v} additional damage",
    },
    area = {
        "nearby", "enemies near", "all enemies", "all enemy", "enemies within", "enemies in", "targets within", "party members",
        "group members", "raid members", "creatures within", "target area", "around the caster", "in a cone",
        "in front of", "additional targets", "enter the area", "their party", "to all within", "members of your raid",
    },
    lasts = {"lasts {d}", "for {d}"},
    rules = {
        -- Feedback: damage per mana burned is a rate, not an amount
        {"none", "ignore", "{v} {s}damage for each point of mana"},
        {"none", "ignore", {"to life with {v} health", "healing done for {d}", "for {n}% of your maximum health",
                              "{v} damage taken per hit"}},
        {"absorb", "direct", {"absorb{w} {v} {s}damage", "absorb{w} the next {v} {s}damage"}},
        {"dmg", "charges", "surrounded by {n} {w}{x}struck for {v} {s}damage"},
        {"dmg", "hit", {"repeatedly attacks{w} within {n} yards for {v} {s}damage", "repeatedly attacks{x}for {v} {s}damage"}},
        {"drain", "tick", {"transfers {v} health every {d}", "transfers {v} health{w} every {d}"}},
        {"dmg", "tick", {"{v} {s}damage each second for {d}", "{v} {s}damage every second"}, interval = 1},
        {"dmg", "tick", {"{v} {s}damage{w} every {d}", "{v} {s}damage{w} within {n} yards every {d}"}},

        {"heal", "tick", "heals {w}within {n} yards for {v} every {d}"},
        {"heal", "tick", {"for {v} health every second", "{v} health{w} every second", "for {v} every second"},
         interval = 1},
        {"heal", "tick", {"for {v} every {d} for {d}", "for {v} every {d}"}, when = "helpful"},
        {"auto", "over", "{v} {s}damage over {d}"},
        {"heal", "over", "restore {v} health over {d}"},
        {"heal", "over", {"{v} health over {d}", "{v} over {d}"}, when = "helpful"},
        {"dmg", "direct", "{v} {s}damage"},
        -- Shadow Cleave: "dealing 140 to 209 to each"
        {"dmg", "direct", "dealing {v} to each", when = "harmful"},
        -- "heal " with its space, or "with 5 health at the feet of the caster for 45 sec" reads as a heal
        {"heal", "direct", {"{v} healing", "heals {w}for {v}", "heal {w}for {v}", "healing {w}for {v}",
                            "heals {w}within {n} yards{w} for {v}", "healing {w}within {n} yards{w} for {v}",
                            "heals {w} below {n}% health for {v}"}},
    },
}

-- German. the school is glued to the word ("Feuerschaden") and the time often comes first
-- ("12 Sek. lang 40 Schaden")
local _, ns = ...
ns.Patterns = ns.Patterns or {}

ns.Patterns.deDE = {
    -- "1.508 bis 1.722"
    thousands = {"."},
    ranges = {"{n} bis {n}", "zwischen {n} und {n}"},
    units = {
        {"sekunden", 1}, {"sekunde", 1}, {"sek.", 1}, {"sek", 1}, {"minuten", 60}, {"minute", 60}, {"min.", 60}, {"min", 60},
    },
    -- the mixed schools first, "zauberfeuer" isn't plain fire
    schools = {
        {"zauberfeuer", "FIRE"}, {"zauberfrost", "FROST"}, {"schattenflammen", "SHADOW"}, {"schattenfrost", "FROST"},
        {"frostfeuer", "FIRE"}, {"schimären", "ARCANE"}, {"chaos", "SHADOW"}, {"körperlichen", "PHYSICAL"},
        {"körperliche", "PHYSICAL"}, {"heilig", "HOLY"}, {"feuer", "FIRE"}, {"natur", "NATURE"}, {"frost", "FROST"},
        {"schatten", "SHADOW"}, {"arkan", "ARCANE"},
    },
    fillers = {"punkt(en)", "punkt(e)", "punkte", "punkt", "zusätzlichen", "zusätzliche", "blutungs"},
    weapon = {
        "waffenschaden", "nahkampfschaden", "den distanzschaden um", "distanzschaden plus", "jeder treffer", "jedem treffer", "% schaden plus",
        "langsamere waffen", "waffenhandwaffe", "schaden dieser waffe", "normalen schaden", "nächsten angriff",
    },
    -- finishers: "1 Punkt: ..." "2 Punkte: ..."
    comboRow = "{n} punkt",
    extraPerPoint = {"jeder zusätzliche wutpunkt wird in {v} punkt(e) zusätzlichen schaden"},
    -- "im Umkreis" alone also stands for one target near a totem
    area = {
        "in der nähe", "alle gegner", "allen gegner", "aller gegner", "getroffenen gegner", "nahe gegner",
        "gegner innerhalb", "gegnern innerhalb", "feinden innerhalb", "zielen innerhalb", "zielbereich", "wirkungsbereich",
        "in dem gebiet", "im zielgebiet", "gruppenmitglieder", "schlachtzugsmitglieder", "mitglieder der gruppe",
        "dessen gruppe", "um den zaubernden herum", "kegelförmig", "den bereich betreten", "feinde in einem umkreis",
        "feinden in einem umkreis", "feinden im umkreis", "gegnern im umkreis", "dämonen im umkreis",
        "kreaturen in einem umkreis", "kreaturen im umkreis",
    },
    lasts = {"hält {d} lang an", "{d} lang"},
    rules = {
        {"none", "ignore", "manapunkt erleidet das ziel {v} punkt {s}schaden"},
        -- a resurrection, a soulstone, a totem's own health or a healthstone name health that isn't healed
        {"none", "ignore", {"mit {v} punkt(en) gesundheit", "mit {v} gesundheit", "um {v} punkt(e) gesundheit wiederherzustellen"}},
        {"absorb", "direct", {"absorbiert{w} {v} {s}schaden", "{v} {s}schaden absorbiert"}},
        {"dmg", "charges", "von {n} kugelblitzen umgeben{x}erleidet {v} {s}schaden"},
        -- Searing Totem
        {"dmg", "hit", "alle {d} einen feind im umkreis von {n} metern angreift und {v} {s}schaden"},
        -- Frozen Orb hits each enemy once
        {"dmg", "direct", "verursacht die kugel alle {d} {v} {s}schaden"},
        {"drain", "tick", "berträgt alle {d} {v} gesundheit"},
        {"dmg", "tick", "pro sekunde {v} {s}schaden", interval = 1},
        -- "6 Sek. lang alle 1 Sek." comes duration first, the duration is found later with lasts
        {"dmg", "tick", "alle {d}{w} {v} {s}schaden"},
        {"heal", "tick", {"alle {d} {v} gesundheit", "alle {d} um {v} punkt(e) heilt"}},
        {"heal", "tick", {"pro sekunde um {v} punkt(e) gesundheit", "pro sekunde um {v} gesundheit", "pro sekunde {v} gesundheit"},
         interval = 1},
        -- Rejuvenation: "Heilt beim Ziel 12 Sek. lang 32 Punkt(e) Schaden"
        {"heal", "over", {"heilt beim ziel {d} lang {v} punkt(e) schaden", "{d} lang um {v} schadenspunkt(e)"}},
        {"auto", "over", {"{d} lang, {v} {s}schaden", "{d} lang{w} {v} {s}schaden", "im verlauf von {d}{w} {v} {s}schaden",
                          "über {d} {v} {s}schaden", "{v} {s}schaden im verlauf von {d}", "{v} {s}schaden über {d}"}},
        {"heal", "over", "im verlauf von {d} {v} gesundheit wiederherzustellen"},
        {"heal", "over", {"im verlauf von {d} um {v} gesundheit", "im verlauf von {d} {v} gesundheit",
                          "im laufe von {d} {v} punkt(e) gesundheit", "über {d} um weitere {v}"}, when = "helpful"},
        {"dmg", "direct", "{v} {s}schaden"},
        -- not a bare "heilt {v}", "Heilt 1 Krankheit" cures
        {"heal", "direct", {"heilt{w} um {v}", "heilt{w} mit weniger als {n}% gesundheit sofort um {v}",
                            "heilt{w} innerhalb von {n} metern{w} um {v}", "um {v} gesundheit heil", "um {v} gesundheit geheilt",
                            "um {v} gesundheit zu heilen", "um {v} punkt(e) heil", "um {v} punkt(e) zu heilen",
                            "dessen gruppe um {v} geheilt", "heilt {v} bei"}},
    },
}

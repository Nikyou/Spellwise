-- French
local _, ns = ...
ns.Patterns = ns.Patterns or {}

ns.Patterns.frFR = {
    ranges = {"{n} à {n}"},
    -- "toutes les 1 s", "pendant 10 sec"
    units = {
        {"secondes", 1}, {"seconde", 1}, {"sec", 1}, {"s", 1}, {"minutes", 60}, {"minute", 60}, {"min", 60},
        {"heures", 3600}, {"heure", 3600},
    },
    -- "feu-sorcier" and "ombreflamme" land on fire and shadow through the plain words
    schools = {
        {"chimérique", "ARCANE"}, {"chaos", "SHADOW"}, {"physique", "PHYSICAL"}, {"sacré", "HOLY"}, {"feu", "FIRE"},
        {"nature", "NATURE"}, {"givre", "FROST"}, {"ombre", "SHADOW"}, {"arcanes", "ARCANE"},
    },
    -- not a bare "chaque coup", Fire Shield has "chaque coup porté à la cible"
    weapon = {
        "dégâts de l’arme", "dégâts de l'arme", "dégâts de votre arme", "dégâts normaux", "dégâts des armes",
        "dégâts des deux armes", "dégâts infligés en mêlée", "dégâts infligés par votre attaque à distance",
        "% de vos dégâts de mêlée", "% de dégâts plus",
        "dégâts par seconde de votre arme", "chaque attaque en mêlée inflige", "chaque coup inflige", "chaque coup a ",
        "à chaque coup", "chaque coup porté par l’arme", "points de dégâts la prochaine attaque",
        "de la prochaine attaque du",
    },
    comboRow = "{n} point",
    extraPerPoint = {"chaque point de rage en {v} points de dégâts supplémentaires"},
    -- not a bare "proche", food can be "d'un niveau proche", nor "dans les environs", Polymorph wanders there
    area = {
        "zone ciblée", "dans une zone de", "dans la zone d’effet", "qui entrent dans la zone", "membres du groupe",
        "membres de son groupe", "membres de votre groupe", "et son groupe", "autour du lanceur",
        "autour du personnage lanceur", "autour du point ciblé", "dans un cône", " proches", "proche supplémentaire",
        "du groupe proche", "à proximité", "des environs", "se trouvent dans les environs", "environnant",
        "tous les ennemis dans", "tous les ennemis présents", "tous les ennemis se trouvant", "tous les ennemis cachés",
        "tous les ennemis en face", "tous les ennemis qui se trouvent dans la zone", "adverses cachés",
        "toutes les cibles ennemies", "toutes les créatures", "créatures situées", "tous les morts-vivants",
        "ennemis à moins de", "adversaires à moins de", "adverses à moins de", "se trouvant à moins de",
        "se trouvent à moins de", "adversaires à portée", "à tous les autres", "pris dans l’explosion", "qu’il traverse",
    },
    lasts = {"dure {d}", "pendant {d}"},
    rules = {
        {"none", "ignore", "{v} point de dégâts{w} par point de mana"},
        -- totems and resurrections name health that isn't healed, Blessing of Sacrifice moves damage
        {"none", "ignore", {"dispose de {v} points de vie", "rappelle à la vie{w} et lui rend {v} points de vie",
                            "transfère {v} points de dégâts par coup", "transfère {v} points de dégâts subis"}},
        {"absorb", "direct", {"absorbe{w} {v} points de dégâts", "absorbant {v} points de dégâts"}},
        {"dmg", "charges", "entouré de {n} boules{x}{v} points de dégâts"},
        {"dmg", "hit", "attaque{w} dans un rayon de {n} mètres et inflige {v} points de dégâts"},
        {"drain", "tick", "transfère {v} points de vie{w} toutes les {d}"},
        {"dmg", "tick", {"{v} points de dégâts{w} toutes les secondes pendant {d}", "{v} dégâts{w} toutes les secondes"},
         interval = 1},
        {"dmg", "tick", {"{v} points de dégâts{w} toutes les {d}", "{v} points de dégâts{w} à moins de {n} m toutes les {d}"}},
        {"heal", "tick", {"de {v} les points de vie{w} à moins de {n} m toutes les {d} pendant {d}",
                          "soigne{w} de {v} points de vie toutes les {d}"}},
        {"heal", "tick", {"{v} points de vie par seconde", "{v} points de vie toutes les secondes"}, interval = 1},
        {"auto", "over", {"{v} points de dégâts{w} en {d}", "{v} points supplémentaires de dégâts{w} en {d}",
                          "{v} points de dégâts{w} supplémentaires pendant {d}", "{v} dégâts{w} en {d}"}},
        -- Rend: "elle saigne et perd 15 points de vie en 9 sec"
        {"dmg", "over", {"perd {v} points de vie en {d}", "puis {v} supplémentaires en {d}"}, when = "harmful"},
        {"heal", "over", "{v} points de vie{w} en {d}", when = "notHarmful"},
        {"heal", "over", "pour {v} points supplémentaires pendant {d}", when = "helpful"},
        -- Mana Burn: "0,5 point de dégât", Death Mark rows: "limite de dégâts de 425"
        {"dmg", "direct", {"{v} points de dégâts", "{v} point de dégât", "limite de dégâts de {v}"}},
        {"heal", "direct", {"soigne{w} de {v} points de vie", "soigne{w} pour {v}", "rend{w} {v} points de vie",
                            "restitue {v} points de vie", "reçoit{w} {v} points de vie"}},
    },
}

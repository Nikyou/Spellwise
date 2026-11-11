-- Spanish (Mexico), numbers look like 1,508 and 24.8
local _, ns = ...
ns.Patterns = ns.Patterns or {}

ns.Patterns.esMX = {
    ranges = {"entre {n} p. y {n}", "entre {n} p. a {n}", "entre {n} y {n}", "{n} p. a {n}", "{n} a {n}"},
    units = {{"segundos", 1}, {"segundo", 1}, {"s", 1}, {"minutos", 60}, {"minuto", 60}, {"min", 60}},
    -- the mixed schools first, "piroarcano" isn't plain arcane
    schools = {
        {"piroarcano", "FIRE"}, {"piroarcana", "FIRE"}, {"pirofrío", "FIRE"}, {"pirosombra", "SHADOW"}, {"fríosombra", "FROST"},
        {"quimérico", "ARCANE"}, {"caos", "SHADOW"}, {"físico", "PHYSICAL"}, {"sagrado", "HOLY"}, {"fuego", "FIRE"},
        {"naturaleza", "NATURE"}, {"escarcha", "FROST"}, {"sombras", "SHADOW"}, {"arcano", "ARCANE"},
    },
    fillers = {"de las", "de la", "de", "extra", "adicional", "más", "sangrado"},
    weapon = {
        "daño con arma", "daño de arma", "daño del arma", "daño con ambas armas", "el daño cuerpo a cuerpo y", "% de daño cuerpo a cuerpo",
        "inflige daño a distancia", "el daño a distancia.", "arma normal", "daño normal", "arma de la mano derecha", "arma de mano principal",
        "arma de tu mano izquierda", "cada golpe inflige", "cada golpe tiene", "cada golpe con el arma",
        "armas más lentas", "ataque siguiente", "siguiente ataque del", "% de daño más",
    },
    -- "1 punto:", Point Blank has "1 p.:"
    comboRow = {"{n} punto", "{n} p.:"},
    extraPerPoint = {"cada punto extra de ira en {v} p. más de daño", "cada punto extra de energía en {v} p. más de daño"},
    area = {
        "cercano", "cercanas", "cerca del taumaturgo", "todos los enemigos", "enemigos en un radio",
        "enemigos que estén en un radio", "criaturas que estén en un radio", "objetivos enemigos", "miembros del grupo",
        "miembros de su grupo", "y su grupo", "zona objetivo", "área objetivo", "área de efecto", "alrededor del taumaturgo",
        "en un cono", "delante de", "frente al", "objetivos adicionales", "en todas direcciones", "de tu tótem",
        "entren en la zona", "todos los objetivos en un radio", "criaturas en un radio", "miembros de tu banda",
        "miembros más del grupo",
    },
    lasts = {"dura {d}", "durante {d}"},
    rules = {
        {"none", "ignore", "{v} p. de daño{w} por cada punto de maná"},
        -- mana and health that isn't healed
        {"none", "ignore", "con {v} p. de salud"},
        {"none", "ignore", "{v} p. de maná"},
        {"none", "ignore", "{v} p. de su maná"},
        {"none", "ignore", "{v} p. de daño recibido por golpe"},
        {"absorb", "direct", {"absorbe{w} {v} p. de daño", "amortigua{w} {v} p. de daño"}},
        {"dmg", "charges", "rodead{w} {n} {w}{x}recibe {v} p. de daño"},
        {"dmg", "hit", {"ataca {w}en un radio de {n} {w} {v} p. de daño", "ataca {w}en un radio de {n} {w} {v} de daño",
                        "ataca repetidamente{x}{v} p. de daño"}},
        {"drain", "tick", {"transfiere {v} p. de salud cada {d}", "transfiere {v} p. de salud{w} cada {d}"}},
        {"dmg", "tick", {"{v} p. de daño {s}cada segundo durante {d}", "{v} p. de daño {s}cada segundo",
                         "{v} p. de daño {s}por segundo", "{v} p. de daño {s}por s "}, interval = 1},
        {"dmg", "tick", {"{v} p. de daño {w}cada {d}", "{v} p. de daño {w}en un radio de {n} {w}cada {d}"}},
        {"heal", "tick", {"{v} p. {w}en un radio de {n} {w}cada {d} durante {d}", "{v} p. {w}en un radio de {n} {w}cada {d}",
                          "{v} p. {w}en un radio de {n} m. cada {d}"}},
        {"heal", "tick", {"{v} p. de salud{w} cada segundo", "{v} p. cada segundo", "{v} p. de salud por segundo",
                          "{v} p. de salud por s "}, interval = 1},
        {"auto", "over", {"{v} p. {s}de daño {s}durante {d}", "{v} de daño {s}durante {d}", "{v} p. de daño {s}en {d}"}},
        -- Fireball: "y 2 p. extra durante 4 s"
        {"dmg", "over", {"daño extra de {v} p. durante {d}", "{v} p. extra durante {d}"}, when = "harmful"},
        {"heal", "over", {"recupera{w} {v} p. de salud durante {d}", "sanará {v} p. de salud durante {d}",
                          "restablece {v} p. de salud{w} durante {d}", "sana {v} p.{w} durante {d}",
                          "sana a{w} {v} p. durante {d}", "sana {v} p. de salud{w} en un radio de {n} m{w} durante {d}"}},
        {"heal", "over", {"cura{w} en {v} p. durante {d}", "otros {v} p. durante {d}"}, when = "helpful"},
        -- Black Arrow 3674 drops the "de": "150 p. daño de las Sombras"
        {"dmg", "direct", {"{v} p. {s}de daño", "{v} de daño", "límite de daño de {v}", "{v} p. daño"}},
        -- Black Arrow: "causa un daño de Sombras de 150 p."
        {"dmg", "direct", "un daño de {s}de {v} p.", when = "harmful"},
        -- Shadow Cleave: "inflige 136 a 204 p. a cada objetivo"
        {"dmg", "direct", "inflige {v} p. a cada", when = "harmful"},
        -- "sana " with its space, "sanación con hechizos 60 p." isn't a heal
        {"heal", "direct", {"{v} p. de sanación", "menos del {n}% de salud durante {v}", "sana {w}en {v} p.",
                            "sanando {v} p.", "sanar {v} p.", "sana instantáneamente {v} p.", "sana {v} p.",
                            "sana a{w} {v} p.", "sanen {v} p.", "restablece {v} p. de salud",
                            "restablece de {v} p. de salud", "restaura{w} {v} p. de salud"}},
    },
}

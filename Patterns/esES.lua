-- Spanish (Spain): "25 p. de daño de Fuego", the school comes after
local _, ns = ...
ns.Patterns = ns.Patterns or {}

ns.Patterns.esES = {
    -- Circle of Healing has "de 875 a969 p."
    ranges = {"entre {n} p. y {n}", "entre {n} p. a {n}", "entre {n} y {n}", "{n} p. a {n}", "{n} a {n}", "{n} a{n}"},
    units = {
        {"segundos", 1}, {"segundo", 1}, {"s", 1}, {"minutos", 60}, {"minuto", 60}, {"min", 60},
    },
    -- the mixed schools first, "piroarcano" isn't plain arcane
    schools = {
        {"piroarcano", "FIRE"}, {"pirofrío", "FIRE"}, {"pirosombra", "SHADOW"}, {"fríosombra", "FROST"},
        {"quimérico", "ARCANE"}, {"caos", "SHADOW"}, {"físico", "PHYSICAL"}, {"sagrado", "HOLY"}, {"fuego", "FIRE"},
        {"naturaleza", "NATURE"}, {"escarcha", "FROST"}, {"sombras", "SHADOW"}, {"arcano", "ARCANE"},
    },
    fillers = {"de las", "de la", "de", "extra", "adicional", "más"},
    weapon = {
        "daño con arma", "daño de arma", "daño con ambas armas", "aumenta el daño cuerpo a cuerpo", "% de daño cuerpo a cuerpo", "inflige daño a distancia", "el daño a distancia.",
        "arma normal", "daño normal", "arma de la mano derecha", "arma de mano principal", "arma de tu mano izquierda",
        "cada golpe inflige", "cada golpe tiene", "cada golpe con el arma", "armas más lentas", "ataque siguiente",
        "siguiente ataque del", "% de daño más", "% de daño y ",
    },
    -- "1 punto:", Point Blank has "1 p.:"
    comboRow = {"{n} punto", "{n} p.:"},
    extraPerPoint = {"cada punto extra de ira en {v} p. de daño", "cada punto extra de energía en {v} p. de daño"},
    area = {
        "cercano", "cercanas", "cerca del taumaturgo", "todos los enemigos", "enemigos en un radio",
        "enemigos que estén en un radio", "criaturas que estén en un radio", "objetivos enemigos", "miembros del grupo",
        "miembros de su grupo", "y su grupo", "zona objetivo", "área objetivo", "área de efecto", "alrededor del taumaturgo",
        "en un cono", "delante de", "frente al", "objetivos adicionales", "en todas direcciones", "lo pisen", "de tu tótem",
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
        {"dmg", "charges", "rodeado por {n} {w}{x}recibirá {v} p. de daño"},
        {"dmg", "hit", {"ataca repetidamente{w} en un radio de {n} {w} {v} p. de daño", "ataca repetidamente{x}{v} p. de daño"}},
        {"drain", "tick", {"transfiere {v} p. de salud cada {d}", "transfiere {v} p. de salud{w} cada {d}"}},
        -- Frozen Orb hits each enemy it passes once, "el orbe inflige 156 p. de daño de Escarcha cada 1 s"
        {"dmg", "direct", "el orbe inflige {v} p. de daño"},
        {"dmg", "tick", {"{v} p. de daño {s}cada segundo durante {d}", "{v} p. de daño {s}cada segundo",
                         "{v} p. de daño {s}por segundo"}, interval = 1},
        {"dmg", "tick", {"{v} p. de daño {w}cada {d}", "{v} p. de daño {w}en un radio de {n} {w}cada {d}"}},
        {"heal", "tick", {"{v} p. {w}en un radio de {n} {w}cada {d} durante {d}", "{v} p. {w}en un radio de {n} {w}cada {d}"}},
        {"heal", "tick", {"{v} p. de salud{w} cada segundo", "{v} p. cada segundo"}, interval = 1},
        {"auto", "over", {"{v} p. {s}de daño {s}durante {d}", "{v} de daño {s}durante {d}", "{v} p. de daño {s}en {d}"}},
        -- Rake: "un daño extra de 126 p. durante 9 s"
        {"dmg", "over", "daño extra de {v} p. durante {d}", when = "harmful"},
        {"heal", "over", {"recupera{w} {v} p. de salud durante {d}", "sanará {v} p. de salud durante {d}",
                          "sana {v} p.{w} durante {d}", "sana a{w} {v} p. durante {d}",
                          "sana {v} p. de salud{w} en un radio de {n} m durante {d}"}},
        {"heal", "over", {"cura{w} en {v} p. durante {d}", "otro en {v} p. durante {d}"}, when = "helpful"},
        {"dmg", "direct", {"{v} p. {s}de daño", "{v} de daño", "{v} de límite de daño"}},
        -- Black Arrow: "causa un daño de Sombras de 150 p."
        {"dmg", "direct", "un daño de {s}de {v} p.", when = "harmful"},
        -- "sana" alone, "sanación con hechizos 60 p." isn't a heal
        {"heal", "direct", {"{v} p. de sanación", "por debajo del {n}% de salud durante {v}", "cura{w} en {v} p.",
                            "curando {v} p.", "curar {v} p.", "cura instantáneamente {v} p.", "sana {v} p.",
                            "sana de {v} p.", "sana a{w} {v} p.", "sana primero a{w} {v} p.",
                            "sanará {v} p.", "sanen {v} p."}},
    },
}

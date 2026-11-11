-- Brazilian Portuguese, numbers look like 1.508 and 24,8
local _, ns = ...
ns.Patterns = ns.Patterns or {}

ns.Patterns.ptBR = {
    thousands = {"."},
    ranges = {"entre {n} e {n}", "{n} a {n}"},
    units = {{"segundos", 1}, {"segundo", 1}, {"s", 1}, {"minutos", 60}, {"minuto", 60}, {"min", 60}},
    -- the mixed schools first, "fogo místico" isn't plain fire
    schools = {
        {"fogo místico", "FIRE"}, {"fogofrio", "FIRE"}, {"chama sombria", "SHADOW"}, {"físico", "PHYSICAL"},
        {"sagrado", "HOLY"}, {"fogo", "FIRE"}, {"natureza", "NATURE"}, {"gelo", "FROST"}, {"sombra", "SHADOW"},
        {"arcano", "ARCANE"},
    },
    fillers = {"um adicional", "de", "a mais", "mais", "adicional", "extra"},
    weapon = {
        "dano da arma", "dano da sua arma", "dano normal", "dano das duas armas", "arma da mão principal",
        "o dano corpo a corpo e", "% de dano corpo a corpo", "dano de ataque corpo a corpo", "o dano de longo alcance.", "causa dano de longo alcance", "cada acerto causa",
        "cada acerto tem", "cada acerto com a mão", "armas mais lentas", "próximo ataque do", "% do dano mais",
    },
    comboRow = "{n} ponto",
    extraPerPoint = {"cada ponto extra de raiva em mais {v} de dano", "cada ponto extra de energia em mais {v} de dano"},
    area = {
        -- "próximos" alone would take "pelos próximos 15 s"
        "próximos no", "próximos até", "aliados próximos", "inimigos próximos", "alvos próximos", "feras próximas",
        "sombras próximas", "adversário próximo", "integrantes próximos", "que esteja próximo", "todos os inimigos",
        "inimigos em um raio", "integrantes do grupo", "membros do grupo", "área selecionada", "área do efeito", "área cônica",
        "ao redor do lançador", "em cone", "à sua frente", "alvos adicionais", "entrarem na área", "em todas as direções",
        "todos em um raio", "criaturas em um raio",
    },
    lasts = {"dura {d}", "por {d}"},
    rules = {
        {"none", "ignore", "{v} de dano{w} para cada ponto de mana"},
        -- health that isn't healed: totems, healthstones, Life Tap
        {"none", "ignore", "com {v} pontos de vida"},
        {"none", "ignore", "restaurar instantaneamente {v} pontos de vida"},
        {"none", "ignore", "converte {v} pontos de vida"},
        {"none", "ignore", "recuperará {v} pontos de vida"},
        {"absorb", "direct", "absorv{w} {v} de dano"},
        {"dmg", "charges", "envolto por {n} {w}{x}causar {v} de dano"},
        {"dmg", "hit", {"ataca repetidamente{w} em um raio de {n} m, causando {v} de dano", "ataca repetidamente{x}{v} de dano"}},
        -- Frozen Orb hits each enemy it passes once, Penance heals once
        {"dmg", "direct", "o orbe causa {v} de dano"},
        {"heal", "direct", "curando {v} pontos de vida de um aliado instantaneamente"},
        {"drain", "tick", {"transfere {v} pontos de vida a cada {d}", "transfere {v} pontos de vida{w} a cada {d}"}},
        {"dmg", "tick", {"{v} de dano {s}a cada segundo por {d}", "{v} de dano {s}a cada segundo"}, interval = 1},
        {"dmg", "tick", {"{v} de dano {w}a cada {d}", "{v} de dano {w}em um raio de {n} m a cada {d}"}},
        {"heal", "tick", "{v} pontos de vida{w} a cada segundo", interval = 1},
        {"heal", "tick", {"{v} pontos de vida{w} a cada {d} por {d}", "{v} pontos de vida{w} a cada {d}",
                          "{v} pontos de vida{w} em um raio de {n} m a cada {d} por {d}", "em um raio de {n} m por {v} a cada {d}"}},
        {"auto", "over", "{v} {s}de dano {s}ao longo de {d}"},
        {"heal", "over", {"{v} pontos de vida{w} ao longo de {d}", "{v} pontos de vida{w} em um raio de {n} m{w} ao longo de {d}",
                          "{v} de cura{w} ao longo de {d}"}},
        {"heal", "over", "{v} ao longo de {d}", when = "helpful"},
        {"dmg", "direct", {"{v} {s}de dano", "limite de dano de {v}"}},
        {"heal", "direct", {"{v} pontos de vida", "{v} de cura", "uma cura de {v}"}},
    },
}

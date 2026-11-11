-- Traditional Chinese, works like zhCN
local _, ns = ...
ns.Patterns = ns.Patterns or {}

ns.Patterns.zhTW = {
    ranges = {"{n}點到{n}", "{n}點至{n}", "{n}到{n}", "{n}至{n}"},
    units = {{"秒", 1}, {"分鐘", 60}},
    -- the mixed schools first, "暗霜" isn't plain shadow
    schools = {
        {"法火", "FIRE"}, {"法霜", "FROST"}, {"暗焰", "SHADOW"}, {"嵌合", "ARCANE"}, {"混沌", "SHADOW"}, {"霜火", "FROST"},
        {"暗霜", "FROST"}, {"物理", "PHYSICAL"}, {"神聖", "HOLY"}, {"火焰", "FIRE"}, {"自然", "NATURE"}, {"冰霜", "FROST"},
        {"暗影", "SHADOW"}, {"秘法", "ARCANE"},
    },
    fillers = {"額外的", "額外", "基礎"},
    weapon = {
        "武器傷害", "普通傷害", "的下一次攻擊", "的下一次近戰攻擊", "每次近戰攻擊額外造成", "主手武器每秒傷害", "%近戰傷害",
        "%外加", "遠程傷害提高", "造成遠程傷害", "攻擊速度越慢的武器", "根據武器攻速",
        "以武器速度為基準", "每次擊中敵人", "每次主手攻擊命中", "每次命中敵人時", "近戰攻擊所造成的傷害提高",
    },
    comboRow = "{n}點:",
    extraPerPoint = {"怒氣點數轉化為{v}點額外傷害"},
    -- "小隊成員" or "隊友" alone is often one party member, "在周圍到處閒逛" is Polymorph
    area = {
        "所有敵人", "範圍內的所有", "範圍內所有", "碼內的所有", "碼內所有", "範圍內的敵人", "範圍內最多", "碼內最多",
        "附近所有", "附近的", "附近其他", "使附近", "在目標附近", "鄰近", "周圍的", "周圍半徑", "周圍最", "錐形",
        "進入該區域", "在目標區域", "目標區域中", "所有小隊成員", "的小隊成員", "使小隊成員", "所有隊伍", "所有隊友",
        "小隊與團隊成員", "小隊和團隊成員", "隊伍或團隊成員的", "隊伍或團隊成員共同", "範圍內隊伍成員", "範圍內的隊伍成員每",
        "額外的隊伍成員", "範圍內的隊友", "碼內的隊友", "穿越它的隊友", "名隊友", "額外的敵人", "與其隊伍", "同隊隊員",
        "所有被", "個敵人因恐懼而逃跑", "穿過的敵人",
    },
    lasts = {"持續{d}", "在{d}內"},
    rules = {
        {"none", "ignore", "每燃燒一點法力會造成{v}點{s}傷害"},
        -- a resurrection, a soulstone, a healthstone, Dark Sacrifice or Blessing of Sacrifice name health that isn't healed.
        -- Demon Armor's regeneration and Devour Magic's pet heal are left out
        {"none", "ignore", {"復活,並恢復{v}點生命力", "可以立刻恢復{v}點生命力", "犧牲自身{v}點生命力", "分擔{v}點傷害",
                            "每吸收{n}點{s}傷害", "恢復速度每{d}提高{v}點生命力", "獵犬就可回復{v}點生命力"}},
        {"absorb", "direct", {"吸收{v}點{s}傷害"}},
        -- one rank writes "134 點"
        {"dmg", "charges", {"{n}個閃電球{x}{v}點{s}傷害", "{n}個閃電球{x}{v} 點{s}傷害"}},
        {"dmg", "hit", "頻繁攻擊{w}{n}碼{w},每次{w}{v}點{s}傷害"},
        -- Frozen Orb hits each enemy once
        {"dmg", "direct", "在移動過程中每{d}便會造成{v}點{s}傷害"},
        {"drain", "tick", {"每{d}{w}吸取{w}{v}點生命力"}},
        {"dmg", "tick", {"每秒{v}點{s}傷害", "每秒{w}{v}點{s}傷害"}, interval = 1},
        {"dmg", "tick", {"每{d}{w}{v}點{s}傷害", "每{d}{w}半徑{n}{w}{v}點{s}傷害", "每{d}{w}{n}碼{w}{v}點{s}傷害"}},
        {"heal", "tick", {"每秒{w}{v}點生命力", "每秒{w}{n}碼{w}{v}點生命力"}, interval = 1},
        {"heal", "tick", {"每{d}{w}{v}點生命力", "每{d}{w}{n}碼{w}{v}點生命力"}},
        {"auto", "over", "{d}內{w}{v}點{s}傷害"},
        -- Rupture rows: "159點傷害,持續8秒"
        {"dmg", "over", "{v}點{s}傷害,持續{d}", when = "harmful"},
        {"heal", "over", {"{d}內{w}{v}點生命力", "{d}的時間內{w}{v}點生命力", "{d}內{w}{n}碼{w}{v}點生命力"}},
        {"heal", "direct", "治療{v}點傷害"},
        {"dmg", "direct", {"{v}點{s}傷害", "{v}點傷害上限"}},
        {"heal", "direct", {"恢復{w}{v}點生命力", "恢復{w}{n}碼{w}{v}點生命力", "回復{v}點生命力", "治療{w}{v}點生命力"}},
    },
}

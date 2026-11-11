-- Simplified Chinese. no spaces, so keep {w} next to real words
local _, ns = ...
ns.Patterns = ns.Patterns or {}

ns.Patterns.zhCN = {
    ranges = {"{n}到{n}", "{n}至{n}"},
    units = {{"秒", 1}, {"分钟", 60}},
    schools = {
        {"法术火焰", "FIRE"}, {"法术冰霜", "FROST"}, {"暗影烈焰", "SHADOW"}, {"奇美拉", "ARCANE"}, {"混乱", "SHADOW"},
        {"霜火", "FROST"}, {"物理", "PHYSICAL"}, {"神圣", "HOLY"}, {"火焰", "FIRE"}, {"自然", "NATURE"}, {"冰霜", "FROST"},
        {"暗影", "SHADOW"}, {"奥术", "ARCANE"},
    },
    fillers = {"额外的", "额外", "基础"},
    weapon = {
        "武器伤害", "普通伤害", "下一次攻击", "每次近战攻击额外造成", "与攻击伤害的", "主手武器每秒伤害", "%的近战伤害",
        "使远程伤害提高", "造成远程伤害", "武器越慢", "根据武器速度", "每次击中敌人",
        "每次主手命中", "近战攻击所造成的伤害提高",
    },
    comboRow = "{n}点:",
    extraPerPoint = {"怒气点数转化为{v}点额外伤害"},
    -- "小队成员" alone is often one party member
    area = {
        "附近", "所有敌人", "进入该区域", "目标区域中", "在目标区域", "向目标区域", "指定区域", "指定位置", "锥形",
        "的小队成员", "使小队成员", "所有小队", "小队和团队", "小队或团队成员的", "及其小队", "团队中的所有成员", "团队中的友方单位",
        "的队伍成员", "所有队伍", "所有队友", "范围内的队友", "穿越它的队友", "名队友", "个队友", "周围的", "周围最",
        "周围半径", "图腾周围", "码内所有", "码内的所有", "范围内的所有", "范围内的敌人", "范围内的最多", "码内的最多",
        "码内的敌人", "额外的敌人", "额外目标", "个敌人因恐惧而逃跑",
    },
    lasts = {"持续{d}", "在{d}内"},
    rules = {
        -- a resurrection, a soulstone, a healthstone, Dark Sacrifice or Blessing of Sacrifice name health that isn't healed.
        -- Demon Armor's regeneration and Devour Magic's pet heal are left out
        {"none", "ignore", {"复活,并恢复{v}点生命值", "可以立刻恢复{v}点生命值", "吞噬自身的{v}点生命值", "分担{v}点伤害",
                            "每吸收{n}点{s}伤害", "造成最多{v}点额外的", "并使其每{d}恢复{v}点生命值",
                            "猎犬就可回复{v}点生命值"}},
        {"absorb", "direct", {"吸收{v}点{s}伤害"}},
        {"dmg", "charges", "{n}个闪电球{x}{v}点{s}伤害"},
        {"dmg", "hit", "频繁攻击{w}{n}码{w},每次{w}{v}点{s}伤害"},
        -- Frozen Orb hits each enemy once
        {"dmg", "direct", "每{d}对其穿过的所有敌人造成{v}点{s}伤害"},
        {"drain", "tick", {"每{d}{w}吸取{v}点生命值", "每{d}将目标的{v}点生命值转移"}},
        {"dmg", "tick", {"每秒{v}点{s}伤害", "每秒{w}{v}点{s}伤害"}, interval = 1},
        {"dmg", "tick", {"每{d}{w}{v}点{s}伤害", "每{d}{w}半径{n}{w}{v}点{s}伤害", "每{d}{w}{n}码{w}{v}点{s}伤害"}},
        {"heal", "tick", {"每秒{w}{v}点生命值"}, interval = 1},
        {"heal", "tick", {"每{d}{w}{v}点生命值", "每{d}{w}{n}码{w}{v}点生命值"}},
        {"auto", "over", "{d}内{w}{v}点{s}伤害"},
        -- Rupture rows: "159点伤害,持续8秒"
        {"dmg", "over", "{v}点{s}伤害,持续{d}", when = "harmful"},
        {"heal", "over", {"{d}内{w}{v}点生命值", "{d}的时间内{w}{v}点生命值", "{d}内{w}{n}码内{w}{v}点生命值"}},
        {"heal", "direct", "治疗{v}点伤害"},
        {"dmg", "direct", {"{v}点{s}伤害", "伤害上限为{v}点"}},
        {"heal", "direct", {"恢复{v}点生命值", "回复{v}点生命值"}},
    },
}

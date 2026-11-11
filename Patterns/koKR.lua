-- Korean. particles stick to the numbers ("14~23의")
local _, ns = ...
ns.Patterns = ns.Patterns or {}

ns.Patterns.koKR = {
    ranges = {"{n}에서 {n}"},
    units = {{"초", 1}, {"분", 60}},
    -- the mixed schools first, "암흑불길" would read as shadow and leave "불길" in the slot
    schools = {
        {"암흑불길", "SHADOW"}, {"키메라", "ARCANE"}, {"혼돈", "SHADOW"},
        {"물리", "PHYSICAL"}, {"신성", "HOLY"}, {"화염", "FIRE"}, {"자연", "NATURE"}, {"냉기", "FROST"},
        {"암흑", "SHADOW"}, {"비전", "ARCANE"},
    },
    fillers = {"추가", "출혈"},
    weapon = {
        "무기 공격력", "무기 피해", "근접 공격력", "일반 공격력", "원거리 공격력", "추가 원거리",
        "근접 무기", "초당 공격력", "%에 추가로", "매 타격", "매 공격 시", "무기는 매번 공격 시",
        "무기의 공격 속도에 따라", "공격을 적중시킬 때마다", "다음 공격은", "다음 공격 근접", "강하게 내리쳐",
        "순간적으로 공격하여", "제압하여",
    },
    -- "연계 점수 1점: 6~10의 피해", Kidney Shot has "1 포인트: 1초"
    comboRow = {"점수 {n}점", "{n} 포인트"},
    extraPerPoint = {"분노당 {v}의 피해"},
    -- no plural in korean, so "파티원" alone would also catch a blessing on one party member
    area = {
        "모든 적", "대상 지역", "해당 지역", "주변에 있는 모든", "주변의 적", "부채꼴", "미터 내의 적", "미터 내에 있는 적",
        "반경의 적", "반경 내의 적에게", "반경 내의 적 ", "반경 내에 있는 적", "반경 내의 모든", "주위의 적", "주위 적",
        "주위 3명", "그 주위의", "주위 모든", "주위를 휩쓸어", "추가 대상", "대상의 파티", "모든 파티원", "파티원과 공격대원",
        "반경 내의 파티원", "반경 내에 있는 파티원", "반경 내 파티원", "반경에 있는 파티원의", "반경에 있는 파티원과",
        "반경에 있는 파티원 또는", "미터 내에 있는 파티원", "명의 파티원", "사냥꾼의 파티원", "플레이어의 파티원",
        "주위 파티원", "파티원들이", "명이 필요", "파티원의 체력",
    },
    lasts = {"{d} 동안", "{d}에 걸쳐"},
    rules = {
        {"none", "ignore", "마나 당 {v}의 {s}피해"},
        -- a healthstone isn't a heal of the spell. Dark Sacrifice spends health, Blessing of Sacrifice
        -- takes damage, Devour Magic heals the felhunter. Bloodthirst and Shield of Righteousness only name the flat part
        {"none", "ignore", {"생명석을 사용하면 즉시 {v}의 생명력",
                            "생명력을 {v}만큼 포식", "타격당 {v}의 피해", "지옥사냥개는 {v}의 생명력",
                            "에 해당하는 피해와 {v}의 추가 피해", "증가하는 {s}피해와 {v}의 추가 {s}피해"}},
        {"absorb", "direct", "{v}의 {s}피해를 흡수"},
        {"dmg", "charges", "{n}개의 번개 구슬{x}{v}의 {s}피해"},
        {"dmg", "hit", "지속적으로 {w}{n}미터 {w}{v}의 {s}피해"},
        {"drain", "tick", "{d}마다 {v}의 생명력을 흡수"},
        -- Penance hits at once and then ticks, Frozen Orb only hits what it passes through
        {"dmg", "direct", {"즉시, 그리고 {d} 동안 {d}마다 {v}의 {s}피해", "{d}마다 통과하는 {w}{v}의 {s}피해"}},
        {"dmg", "tick", "매초마다 각각 {v}의 {s}피해", interval = 1},
        {"dmg", "tick", {"{d}마다 {w}{v}의 {s}피해", "{d}마다 {n}미터 {w}{v}의 {s}피해"}},
        {"heal", "tick", {"매초마다 {v}의 생명력"}, interval = 1},
        {"heal", "tick", {"{d}마다 {n}미터 내 {w}생명력을 {v}만큼",
                          "생명력을 매 {d}마다 {v}만큼", "{d}마다 {v}의 생명력을", "{d}마다 {w}{v}만큼 치유"}},
        {"auto", "over", "{d}에 걸쳐 {w}{v}의 {s}피해"},
        {"heal", "over", {"{d}에 걸쳐 {w}생명력을 총 {v}만큼", "{d}에 걸쳐 {w}생명력을 {v}만큼", "{d}에 걸쳐 {w}{v}의 생명력을",
                          "{d}에 걸쳐 {v}만큼"}},
        {"dmg", "direct", "{v}의 {s}피해"},
        {"heal", "direct", {"생명력을 {v}만큼", "{v}만큼 치유", "{v}만큼 생명력을", "{v}의 생명력을 회복"}},
    },
}

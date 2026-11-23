-- abilities that hit with a weapon: which one, whether its speed is normalized, and what the spell adds.
-- made by Dev\tools\weapon_data.lua from the Forever tables, don't edit by hand
local _, ns = ...

-- [spell] = {hand, normalized, bonus, percent}. hand: mh, oh, both (one strike with each) or ranged.
-- the bonus is added to the weapon damage before the percent. dagger: the percent with a dagger in the main hand.
-- school: when it isn't physical, sp: its spell power coefficient. level: {bonus per level, from level, up to level}.
-- swing: on the next main hand swing. extra: {what, percent} beside the strike, more damage or a heal
ns.WeaponData = {
    -- general
    [2480] = {"ranged", false, 0, 100}, -- Shoot Bow
    [7919] = {"ranged", false, 0, 100}, -- Shoot Crossbow
    [7918] = {"ranged", false, 0, 100}, -- Shoot Gun
    [2764] = {"ranged", false, 0, 100}, -- Throw
    -- warrior
    [845] = {"mh", false, 5, 100, swing = true}, -- Cleave
    [7369] = {"mh", false, 10, 100, swing = true}, -- Cleave
    [11608] = {"mh", false, 18, 100, swing = true}, -- Cleave
    [11609] = {"mh", false, 32, 100, swing = true}, -- Cleave
    [20569] = {"mh", false, 50, 100, swing = true}, -- Cleave
    [78] = {"mh", false, 11, 100, swing = true}, -- Heroic Strike
    [284] = {"mh", false, 21, 100, swing = true}, -- Heroic Strike
    [285] = {"mh", false, 32, 100, swing = true}, -- Heroic Strike
    [1608] = {"mh", false, 44, 100, swing = true}, -- Heroic Strike
    [11564] = {"mh", false, 58, 100, swing = true}, -- Heroic Strike
    [11565] = {"mh", false, 80, 100, swing = true}, -- Heroic Strike
    [11566] = {"mh", false, 111, 100, swing = true}, -- Heroic Strike
    [11567] = {"mh", false, 138, 100, swing = true}, -- Heroic Strike
    [25286] = {"mh", false, 157, 100, swing = true}, -- Heroic Strike
    [12294] = {"mh", true, 85, 100}, -- Mortal Strike
    [21551] = {"mh", true, 110, 100}, -- Mortal Strike
    [21552] = {"mh", true, 135, 100}, -- Mortal Strike
    [21553] = {"mh", true, 160, 100}, -- Mortal Strike
    [7384] = {"mh", true, 5, 100}, -- Overpower
    [7887] = {"mh", true, 15, 100}, -- Overpower
    [11584] = {"mh", true, 25, 100}, -- Overpower
    [11585] = {"mh", true, 35, 100}, -- Overpower
    [402911] = {"mh", true, 0, 115}, -- Raging Blow
    [1464] = {"mh", false, 32, 100}, -- Slam
    [8820] = {"mh", false, 43, 100}, -- Slam
    [11604] = {"mh", false, 68, 100}, -- Slam
    [11605] = {"mh", false, 87, 100}, -- Slam
    [1240193] = {"mh", false, 16, 100}, -- Slam
    [1310222] = {"mh", true, 0, 75, extra = {"giants", 100}}, -- Spearing Strike
    [1680] = {"both", true, 0, 100}, -- Whirlwind
    -- paladin
    [407778] = {"mh", false, 0, 110, extra = {"heals", 25}}, -- Divine Storm
    [678] = {"mh", true, 17, 29, school = "HOLY", sp = 0.429, level = {0.1, 12, 17}}, -- Holy Strike
    [679] = {"mh", true, 12, 25, school = "HOLY", sp = 0.429, level = {0.1, 6, 11}}, -- Holy Strike
    [680] = {"mh", true, 24, 36, school = "HOLY", sp = 0.429, level = {0.3, 28, 33}}, -- Holy Strike
    [1866] = {"mh", true, 19, 32, school = "HOLY", sp = 0.429, level = {0.2, 20, 25}}, -- Holy Strike
    [2495] = {"mh", true, 31, 39, school = "HOLY", sp = 0.429, level = {1, 36, 41}}, -- Holy Strike
    [5569] = {"mh", true, 53, 43, school = "HOLY", sp = 0.429, level = {1.5, 44, 49}}, -- Holy Strike
    [10332] = {"mh", true, 68, 46, school = "HOLY", sp = 0.429, level = {2.8, 52, 57}}, -- Holy Strike
    [10333] = {"mh", true, 93, 50, school = "HOLY", sp = 0.429, level = {3.2, 60, 65}}, -- Holy Strike
    [407803] = {"mh", false, 0, 85, school = "HOLY"}, -- Judgement of Martyrdom
    -- hunter
    [19434] = {"ranged", true, 40, 100}, -- Aimed Shot
    [20900] = {"ranged", true, 70, 100}, -- Aimed Shot
    [20901] = {"ranged", true, 115, 100}, -- Aimed Shot
    [20902] = {"ranged", true, 185, 100}, -- Aimed Shot
    [20903] = {"ranged", true, 260, 100}, -- Aimed Shot
    [20904] = {"ranged", true, 350, 100}, -- Aimed Shot
    [425711] = {"mh", true, 0, 65, extra = {"mainTarget", 50}}, -- Carve
    [409433] = {"ranged", true, 0, 135, school = "NATURE"}, -- Chimera Shot
    [19306] = {"mh", true, 26, 50}, -- Counterattack
    [20909] = {"mh", true, 70, 50}, -- Counterattack
    [20910] = {"mh", true, 110, 50}, -- Counterattack
    [1242634] = {"mh", true, 40, 50}, -- Counterattack
    [415320] = {"mh", true, 0, 100}, -- Flanking Strike
    [1495] = {"mh", true, 15, 100}, -- Mongoose Bite
    [14269] = {"mh", true, 22, 100}, -- Mongoose Bite
    [14270] = {"mh", true, 37, 100}, -- Mongoose Bite
    [14271] = {"mh", true, 57, 100}, -- Mongoose Bite
    [2643] = {"ranged", true, 0, 100}, -- Multi-Shot
    [2973] = {"mh", false, 5, 100, swing = true}, -- Raptor Strike
    [14260] = {"mh", false, 11, 100, swing = true}, -- Raptor Strike
    [14261] = {"mh", false, 21, 100, swing = true}, -- Raptor Strike
    [14262] = {"mh", false, 30, 100, swing = true}, -- Raptor Strike
    [14263] = {"mh", false, 35, 100, swing = true}, -- Raptor Strike
    [14264] = {"mh", false, 40, 100, swing = true}, -- Raptor Strike
    [14265] = {"mh", false, 55, 100, swing = true}, -- Raptor Strike
    [14266] = {"mh", false, 70, 100, swing = true}, -- Raptor Strike
    [409691] = {"oh", false, 2, 100}, -- Raptor Strike
    [409693] = {"oh", false, 5, 100}, -- Raptor Strike
    [409748] = {"oh", false, 10, 100}, -- Raptor Strike
    [409750] = {"oh", false, 17, 100}, -- Raptor Strike
    [409751] = {"oh", false, 25, 100}, -- Raptor Strike
    [409752] = {"oh", false, 40, 100}, -- Raptor Strike
    [409754] = {"oh", false, 55, 100}, -- Raptor Strike
    [409755] = {"oh", false, 70, 100}, -- Raptor Strike
    [415335] = {"mh", false, 5, 100}, -- Raptor Strike
    [415336] = {"mh", false, 11, 100}, -- Raptor Strike
    [415337] = {"mh", false, 21, 100}, -- Raptor Strike
    [415338] = {"mh", false, 34, 100}, -- Raptor Strike
    [415340] = {"mh", false, 50, 100}, -- Raptor Strike
    [415341] = {"mh", false, 80, 100}, -- Raptor Strike
    [415342] = {"mh", false, 110, 100}, -- Raptor Strike
    [415343] = {"mh", false, 140, 100}, -- Raptor Strike
    [19503] = {"ranged", false, 0, 50}, -- Scatter Shot
    [1310687] = {"ranged", true, 320, 100}, -- Sniper Shot
    [1310785] = {"ranged", true, 450, 100}, -- Sniper Shot
    [1310786] = {"ranged", true, 590, 100}, -- Sniper Shot
    [1317257] = {"mh", true, 0, 100}, -- Strider Kick
    -- rogue
    [8676] = {"mh", true, 28, 250}, -- Ambush
    [8724] = {"mh", true, 40, 250}, -- Ambush
    [8725] = {"mh", true, 50, 250}, -- Ambush
    [11267] = {"mh", true, 74, 250}, -- Ambush
    [11268] = {"mh", true, 92, 250}, -- Ambush
    [11269] = {"mh", true, 116, 250}, -- Ambush
    [53] = {"mh", true, 10, 150}, -- Backstab
    [2589] = {"mh", true, 20, 150}, -- Backstab
    [2590] = {"mh", true, 32, 150}, -- Backstab
    [2591] = {"mh", true, 46, 150}, -- Backstab
    [8721] = {"mh", true, 60, 150}, -- Backstab
    [11279] = {"mh", true, 90, 150}, -- Backstab
    [11280] = {"mh", true, 110, 150}, -- Backstab
    [11281] = {"mh", true, 140, 150}, -- Backstab
    [25300] = {"mh", true, 150, 150}, -- Backstab
    [14278] = {"mh", true, 0, 125, dagger = 180}, -- Ghostly Strike
    [16511] = {"mh", true, 0, 100, dagger = 145}, -- Hemorrhage
    [424919] = {"oh", true, 0, 100}, -- Main Gauche
    [399956] = {"both", true, 44, 90, extra = {"poisoned", 20}}, -- Mutilate
    [399960] = {"mh", true, 44, 90}, -- Mutilate
    [399961] = {"oh", true, 44, 90}, -- Mutilate
    [1241582] = {"both", true, 63, 90, extra = {"poisoned", 20}}, -- Mutilate
    [1241584] = {"both", true, 88, 90, extra = {"poisoned", 20}}, -- Mutilate
    [1241585] = {"mh", true, 63, 90}, -- Mutilate
    [1241586] = {"mh", true, 88, 90}, -- Mutilate
    [1241588] = {"oh", true, 63, 90}, -- Mutilate
    [1241590] = {"oh", true, 88, 90}, -- Mutilate
    [425013] = {"oh", true, 0, 100}, -- Poisoned Knife
    [398196] = {"ranged", true, 0, 100}, -- Quick Draw
    [14251] = {"mh", false, 0, 150}, -- Riposte
    [424785] = {"mh", true, 0, 100}, -- Saber Slash
    [399985] = {"mh", true, 0, 150}, -- Shadowstrike
    [1329283] = {"oh", false, 0, 50}, -- Shank
    [1329549] = {"oh", false, 0, 50}, -- Shank
    [1752] = {"mh", true, 3, 100}, -- Sinister Strike
    [1757] = {"mh", true, 6, 100}, -- Sinister Strike
    [1758] = {"mh", true, 10, 100}, -- Sinister Strike
    [1759] = {"mh", true, 15, 100}, -- Sinister Strike
    [1760] = {"mh", true, 22, 100}, -- Sinister Strike
    [8621] = {"mh", true, 33, 100}, -- Sinister Strike
    [11293] = {"mh", true, 52, 100}, -- Sinister Strike
    [11294] = {"mh", true, 68, 100}, -- Sinister Strike
    -- shaman
    [408507] = {"oh", false, 0, 100, school = "FIRE", extra = {"flametongue", 100}}, -- Lava Lash
    [17364] = {"mh", true, 0, 100}, -- Stormstrike
    -- druid
    [1082] = {"mh", false, 27, 140}, -- Claw
    [3029] = {"mh", false, 39, 140}, -- Claw
    [5201] = {"mh", false, 57, 140}, -- Claw
    [9849] = {"mh", false, 88, 140}, -- Claw
    [9850] = {"mh", false, 115, 140}, -- Claw
    [6807] = {"mh", false, 18, 100, swing = true}, -- Maul
    [6808] = {"mh", false, 27, 100, swing = true}, -- Maul
    [6809] = {"mh", false, 37, 100, swing = true}, -- Maul
    [8972] = {"mh", false, 49, 100, swing = true}, -- Maul
    [9745] = {"mh", false, 71, 100, swing = true}, -- Maul
    [9880] = {"mh", false, 101, 100, swing = true}, -- Maul
    [9881] = {"mh", false, 128, 100, swing = true}, -- Maul
    [407995] = {"mh", false, 42, 100}, -- Primal Bite
    [1238069] = {"mh", false, 62, 100}, -- Primal Bite
    [1238070] = {"mh", false, 77, 100}, -- Primal Bite
    [6785] = {"mh", false, 42, 435}, -- Ravage
    [6787] = {"mh", false, 62, 435}, -- Ravage
    [9866] = {"mh", false, 78, 435}, -- Ravage
    [9867] = {"mh", false, 98, 435}, -- Ravage
    [5221] = {"mh", false, 22, 200}, -- Shred
    [6800] = {"mh", false, 32, 200}, -- Shred
    [8992] = {"mh", false, 44, 200}, -- Shred
    [9829] = {"mh", false, 64, 200}, -- Shred
    [9830] = {"mh", false, 80, 200}, -- Shred
    [411128] = {"mh", false, 0, 250}, -- Swipe
}

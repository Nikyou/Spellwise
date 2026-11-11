-- spell IDs for /sp dump. the class lists come from Dev\tools\class_ids.lua, change a class here and nowhere else
local _, ns = ...

ns.DumpSpells = {
    order = {
        "test", "warrior", "paladin", "hunter", "rogue", "priest", "shaman", "mage", "warlock", "druid", "warlockpet",
        "hunterpet",
    },

    -- one spell of each kind, rank 1
    test = {
        133, 116, -- Fireball, Frostbolt: direct, direct + DoT
        348, -- Immolate: direct + DoT
        172, 589, -- Corruption, Shadow Word: Pain: DoT
        5143, 15407, 689, 10, -- Arcane Missiles, Mind Flay, Drain Life, Blizzard: channeled
        16914, 740, -- Hurricane, Tranquility: channeled ticks
        2050, 5185, -- Lesser Heal, Healing Touch: heal
        139, 774, -- Renew, Rejuvenation: HoT
        8936, -- Regrowth: heal + HoT
        17, -- Power Word: Shield: absorb
        15237, -- Holy Nova: damage and heal
        78, 1752, -- Heroic Strike, Sinister Strike: weapon-based
        324, 3599, -- Lightning Shield, Searing Totem: charges, per hit
        5394, 8050, -- Healing Stream Totem, Flame Shock: totem HoT, direct + DoT
        635, 26573, 20473, -- Holy Light, Consecration, Holy Shock
        1978, 3044, 2643, -- Serpent Sting, Arcane Shot, Multi-Shot
        772, 5308, -- Rend, Execute: rage
        2098, 1079, -- Eviscerate, Rip: energy and combo points
        768, 5487, 410176, -- Cat Form, Bear Form, Skull Bash: forms, a cost per form
        5176, 8921, -- Wrath, Moonfire
        3110, 17253, -- Firebolt (Imp), Bite (hunter pet): pet spells
    },

    warrior = {
        25289,                                   -- Battle Shout
        2457,                                    -- Battle Stance
        18499,                                   -- Berserker Rage
        2458,                                    -- Berserker Stance
        2687,                                    -- Bloodrage
        23894,                                   -- Bloodthirst
        1161,                                    -- Challenging Shout
        11578,                                   -- Charge
        20569,                                   -- Cleave
        403215,                                  -- Commanding Shout
        12809,                                   -- Concussion Blow
        12328,                                   -- Death Wish
        71,                                      -- Defensive Stance
        11556,                                   -- Demoralizing Shout
        403196,                                  -- Devastate
        676,                                     -- Disarm
        402913,                                  -- Enraged Regeneration
        20662,                                   -- Execute
        7373,                                    -- Hamstring
        25286,                                   -- Heroic Strike
        20617,                                   -- Intercept
        5246,                                    -- Intimidating Shout
        12975,                                   -- Last Stand
        403228,                                  -- Meathook
        20560,                                   -- Mocking Blow
        21553,                                   -- Mortal Strike
        11585,                                   -- Overpower
        12323,                                   -- Piercing Howl
        6554,                                    -- Pummel
        429765,                                  -- Quick Strike
        402911,                                  -- Raging Blow
        426490,                                  -- Rallying Cry
        1329555,                                 -- Reckless Swings
        1719,                                    -- Recklessness
        11574,                                   -- Rend
        20230,                                   -- Retaliation
        25288,                                   -- Revenge
        1672,                                    -- Shield Bash
        2565,                                    -- Shield Block
        23925,                                   -- Shield Slam
        871,                                     -- Shield Wall
        440488,                                  -- Shockwave
        1240193, 11605,                          -- Slam
        1310222,                                 -- Spearing Strike
        11597,                                   -- Sunder Armor
        12292,                                   -- Sweeping Strikes
        355,                                     -- Taunt
        6343, 8198, 11581,                       -- Thunder Clap
        461475,                                  -- Valor of Azeroth
        402927,                                  -- Victory Rush
        1680,                                    -- Whirlwind
    },

    paladin = {
        407788,                                  -- Avenging Wrath
        1044,                                    -- Blessing of Freedom
        20217,                                   -- Blessing of Kings
        25291,                                   -- Blessing of Might
        10278,                                   -- Blessing of Protection
        20729,                                   -- Blessing of Sacrifice
        25290,                                   -- Blessing of Wisdom
        4987,                                    -- Cleanse
        19746,                                   -- Concentration Aura
        20924,                                   -- Consecration
        10293,                                   -- Devotion Aura
        20216,                                   -- Divine Favor
        19752,                                   -- Divine Intervention
        458856,                                  -- Divine Light
        5573,                                    -- Divine Protection
        407804,                                  -- Divine Sacrifice
        1020,                                    -- Divine Shield
        407778,                                  -- Divine Storm
        10314,                                   -- Exorcism
        19900,                                   -- Fire Resistance Aura
        19943,                                   -- Flash of Light
        19898,                                   -- Frost Resistance Aura
        25898,                                   -- Greater Blessing of Kings
        25916,                                   -- Greater Blessing of Might
        25918,                                   -- Greater Blessing of Wisdom
        10308,                                   -- Hammer of Justice
        24239,                                   -- Hammer of Wrath
        407632,                                  -- Hammer of the Righteous
        25292,                                   -- Holy Light
        20928, 1239570,                          -- Holy Shield
        1311606, 20930,                          -- Holy Shock
        10333,                                   -- Holy Strike
        10318,                                   -- Holy Wrath
        425600,                                  -- Horn of Lordaeron
        407880,                                  -- Inspiration Exemplar
        20271,                                   -- Judgement
        633, 10310,                              -- Lay on Hands
        1311595,                                 -- Light's Vigil
        1328548,                                 -- Oath of Light
        1152,                                    -- Purify
        425609,                                  -- Rebuke
        20773,                                   -- Redemption
        20066,                                   -- Repentance
        10301,                                   -- Retribution Aura
        25780,                                   -- Righteous Fury
        412019,                                  -- Sacred Shield
        20375, 20920,                            -- Seal of Command
        1311649, 1311656, 20423,                 -- Seal of Fury
        20164,                                   -- Seal of Justice
        20348, 20349,                            -- Seal of Light
        407798,                                  -- Seal of Martyrdom
        20154, 20292, 20293,                     -- Seal of Righteousness
        20357,                                   -- Seal of Wisdom
        20308,                                   -- Seal of the Crusader
        5502,                                    -- Sense Undead
        19896,                                   -- Shadow Resistance Aura
        440658,                                  -- Shield of Righteousness
        1311015,                                 -- Templar's Bulwark
        10326,                                   -- Turn Undead
        1310897,                                 -- Voice of Truth
    },

    hunter = {
        20904,                                   -- Aimed Shot
        14287,                                   -- Arcane Shot
        13161, 1299447,                          -- Aspect of the Beast
        5118,                                    -- Aspect of the Cheetah
        469145,                                  -- Aspect of the Falcon
        25296,                                   -- Aspect of the Hawk
        13163,                                   -- Aspect of the Monkey
        13159,                                   -- Aspect of the Pack
        415423,                                  -- Aspect of the Viper
        20190,                                   -- Aspect of the Wild
        75,                                      -- Auto Shot
        1462,                                    -- Beast Lore
        19574,                                   -- Bestial Wrath
        14296,                                   -- Black Arrow
        883,                                     -- Call Pet
        425711,                                  -- Carve
        409433,                                  -- Chimera Shot
        409495,                                  -- Chimera Shot - Scorpid
        409493,                                  -- Chimera Shot - Serpent
        409494,                                  -- Chimera Shot - Viper
        5116,                                    -- Concussive Shot
        20910,                                   -- Counterattack
        19263,                                   -- Deterrence
        781, 14272, 14273,                       -- Disengage
        2641,                                    -- Dismiss Pet
        20736, 14274, 15629, 15630, 15631, 15632, -- Distracting Shot
        6197,                                    -- Eagle Eye
        1221404,                                 -- Enchanted Flare
        14317,                                   -- Explosive Trap
        1002,                                    -- Eyes of the Beast
        6991,                                    -- Feed Pet
        5384,                                    -- Feign Death
        415320,                                  -- Flanking Strike
        1543,                                    -- Flare
        14311,                                   -- Freezing Trap
        13809,                                   -- Frost Trap
        409580,                                  -- Heart of the Lion
        14325,                                   -- Hunter's Mark
        14305,                                   -- Immolation Trap
        19577,                                   -- Intimidation
        409379,                                  -- Kill Command
        1299332,                                 -- Lacerate
        3662, 13544,                             -- Mend Pet
        1495, 14271,                             -- Mongoose Bite
        2643,                                    -- Multi-Shot
        3045,                                    -- Rapid Fire
        14266,                                   -- Raptor Strike
        23989,                                   -- Readiness
        982,                                     -- Revive Pet
        14327,                                   -- Scare Beast
        19503,                                   -- Scatter Shot
        3043,                                    -- Scorpid Sting
        25295,                                   -- Serpent Sting
        1310786,                                 -- Sniper Shot
        1317257,                                 -- Strider Kick
        1293527,                                 -- Summon Hawk
        1515,                                    -- Tame Beast
        1494,                                    -- Track Beasts
        19878,                                   -- Track Demons
        19879,                                   -- Track Dragonkin
        19880,                                   -- Track Elementals
        19882,                                   -- Track Giants
        19885,                                   -- Track Hidden
        19883,                                   -- Track Humanoids
        19884,                                   -- Track Undead
        19801,                                   -- Tranquilizing Shot
        1299348, 20906,                          -- Trueshot Aura
        14280,                                   -- Viper Sting
        14295,                                   -- Volley
        14268,                                   -- Wing Clip
    },

    rogue = {
        13750,                                   -- Adrenaline Rush
        8676, 8724, 8725, 11267, 11268, 11269,   -- Ambush
        25300,                                   -- Backstab
        400009,                                  -- Between the Eyes
        400012,                                  -- Blade Dance
        13877,                                   -- Blade Flurry
        2094,                                    -- Blind
        1833,                                    -- Cheap Shot
        14177,                                   -- Cold Blood
        1325758,                                 -- Death Mark
        1842,                                    -- Disarm Trap
        1725,                                    -- Distract
        5277,                                    -- Evasion
        31016,                                   -- Eviscerate
        11198,                                   -- Expose Armor
        1966, 6768, 25302,                       -- Feint
        8633, 11290,                             -- Garrote
        14278,                                   -- Ghostly Strike
        11286,                                   -- Gouge
        16511,                                   -- Hemorrhage
        1769,                                    -- Kick
        408, 8643,                               -- Kidney Shot
        424919,                                  -- Main Gauche
        399956, 1241584,                         -- Mutilate
        921,                                     -- Pick Pocket
        425012,                                  -- Poisoned Knife
        14183,                                   -- Premeditation
        14185,                                   -- Preparation
        398196,                                  -- Quick Draw
        438040,                                  -- Redirect
        14251,                                   -- Riposte
        11275,                                   -- Rupture
        424785,                                  -- Saber Slash
        11297,                                   -- Sap
        399985,                                  -- Shadowstrike
        1329549,                                 -- Shank
        424799,                                  -- Shiv
        399986,                                  -- Shuriken Toss
        11294,                                   -- Sinister Strike
        6774,                                    -- Slice and Dice
        11305,                                   -- Sprint
        1787,                                    -- Stealth
        1856, 1857,                              -- Vanish
    },

    priest = {
        552,                                     -- Abolish Disease
        1277332, 1277335,                        -- Chastise
        401946,                                  -- Circle of Healing
        1277455,                                 -- Confounding Flash
        1277639, 1277640,                        -- Contingency Plan
        528,                                     -- Cure Disease
        1277328,                                 -- Dark Sacrifice
        19243,                                   -- Desperate Prayer
        19280,                                   -- Devouring Plague
        988,                                     -- Dispel Magic
        425294,                                  -- Dispersion
        1277370, 1277378,                        -- Divine Grace
        27841,                                   -- Divine Spirit
        2651,                                    -- Elune's Grace
        402789,                                  -- Eye of the Void
        586, 9578, 9579, 9592, 10941, 10942,     -- Fade
        6346,                                    -- Fear Ward
        19275,                                   -- Feedback
        10917,                                   -- Flash Heal
        25314,                                   -- Greater Heal
        6064,                                    -- Heal
        9035, 19285,                             -- Hex of Weakness
        15261,                                   -- Holy Fire
        15237, 27801,                            -- Holy Nova
        402799,                                  -- Homunculi
        10952,                                   -- Inner Fire
        14751,                                   -- Inner Focus
        2053,                                    -- Lesser Heal
        1706,                                    -- Levitate
        27871,                                   -- Lightwell
        10876,                                   -- Mana Burn
        10947,                                   -- Mind Blast
        605, 10912,                              -- Mind Control
        18807,                                   -- Mind Flay
        413259,                                  -- Mind Sear
        10953,                                   -- Mind Soothe
        431655,                                  -- Mind Spike
        2096, 10909,                             -- Mind Vision
        402004,                                  -- Pain Suppression
        1316995,                                 -- Penance
        10060,                                   -- Power Infusion
        425207,                                  -- Power Word: Barrier
        10938,                                   -- Power Word: Fortitude
        10900, 10901,                            -- Power Word: Shield
        21564,                                   -- Prayer of Fortitude
        25316,                                   -- Prayer of Healing
        401859, 1240827,                         -- Prayer of Mending
        27683,                                   -- Prayer of Shadow Protection
        27681,                                   -- Prayer of Spirit
        10890,                                   -- Psychic Scream
        25315,                                   -- Renew
        20770,                                   -- Resurrection
        10955,                                   -- Shackle Undead
        10958,                                   -- Shadow Protection
        401955, 1309636,                         -- Shadow Word: Death
        2767, 10894,                             -- Shadow Word: Pain
        401977,                                  -- Shadowfiend
        15473,                                   -- Shadowform
        19311, 19312,                            -- Shadowguard
        15487,                                   -- Silence
        10934,                                   -- Smite
        19305,                                   -- Starshards
        19264, 19266,                            -- Touch of Weakness
        15286,                                   -- Vampiric Embrace
        402668,                                  -- Vampiric Touch
        425204,                                  -- Void Plague
    },

    shaman = {
        409337,                                  -- Ancestral Guidance
        20777,                                   -- Ancestral Spirit
        556,                                     -- Astral Recall
        66843,                                   -- Call of the Ancestors
        66842,                                   -- Call of the Elements
        66844,                                   -- Call of the Spirits
        10623,                                   -- Chain Heal
        10605,                                   -- Chain Lightning
        2870,                                    -- Cure Disease
        526,                                     -- Cure Poison
        425874,                                  -- Decoy Totem
        8170,                                    -- Disease Cleansing Totem
        408514,                                  -- Earth Shield
        10414,                                   -- Earth Shock
        2484,                                    -- Earthbind Totem
        6196,                                    -- Far Sight
        408345,                                  -- Fire Nova
        10538,                                   -- Fire Resistance Totem
        29228,                                   -- Flame Shock
        8227, 16387,                             -- Flametongue Totem
        16342,                                   -- Flametongue Weapon
        10479,                                   -- Frost Resistance Totem
        10473,                                   -- Frost Shock
        16356,                                   -- Frostbrand Weapon
        2645,                                    -- Ghost Wolf
        25359,                                   -- Grace of Air Totem
        8177,                                    -- Grounding Totem
        415236,                                  -- Healing Rain
        10463,                                   -- Healing Stream Totem
        25357,                                   -- Healing Wave
        408507,                                  -- Lava Lash
        10468,                                   -- Lesser Healing Wave
        15208,                                   -- Lightning Bolt
        16166,                                   -- Lightning Mastery
        10432,                                   -- Lightning Shield
        10587,                                   -- Magma Totem
        5675, 10497,                             -- Mana Spring Totem
        16190, 17359, 1325256,                   -- Mana Tide Totem
        425339,                                  -- Molten Blast
        10601,                                   -- Nature Resistance Totem
        16188,                                   -- Nature's Swiftness
        8166,                                    -- Poison Cleansing Totem
        370, 8012,                               -- Purge
        425336,                                  -- Rage of the Farseer
        1239243,                                 -- Riptide
        16316,                                   -- Rockbiter Weapon
        10438,                                   -- Searing Totem
        408696,                                  -- Spirit of the Alpha
        10428,                                   -- Stoneclaw Totem
        10408,                                   -- Stoneskin Totem
        17364,                                   -- Stormstrike
        25361,                                   -- Strength of Earth Totem
        437009,                                  -- Totemic Call
        36936,                                   -- Totemic Recall
        8143,                                    -- Tremor Totem
        131,                                     -- Water Breathing
        408510,                                  -- Water Shield
        546,                                     -- Water Walking
        10614,                                   -- Windfury Totem
        8232, 8235, 16362,                       -- Windfury Weapon
        15112,                                   -- Windwall Totem
    },

    mage = {
        10170,                                   -- Amplify Magic
        400610,                                  -- Arcane Barrage
        1239700,                                 -- Arcane Blast
        23028,                                   -- Arcane Brilliance
        10202,                                   -- Arcane Explosion
        10157,                                   -- Arcane Intellect
        25345,                                   -- Arcane Missiles
        12042,                                   -- Arcane Power
        425124,                                  -- Arcane Surge
        1326082,                                 -- Arcane Wrath
        428878,                                  -- Balefire Bolt
        13021,                                   -- Blast Wave
        1953,                                    -- Blink
        10, 10187,                               -- Blizzard
        12472,                                   -- Cold Snap
        11129,                                   -- Combustion
        10160,                                   -- Cone of Cold
        597, 990, 6129, 10144, 10145, 28612,     -- Conjure Food
        759,                                     -- Conjure Mana Agate
        10053,                                   -- Conjure Mana Citrine
        3552,                                    -- Conjure Mana Jade
        10054,                                   -- Conjure Mana Ruby
        5504, 5505, 5506, 6127, 10138, 10139, 10140, 468766, -- Conjure Water
        2139,                                    -- Counterspell
        10174,                                   -- Dampen Magic
        12051,                                   -- Evocation
        24530,                                   -- Felfire
        10199,                                   -- Fire Blast
        10225,                                   -- Fire Ward
        25306,                                   -- Fireball
        10216,                                   -- Flamestrike
        7301,                                    -- Frost Armor
        10230,                                   -- Frost Nova
        28609,                                   -- Frost Ward
        25304,                                   -- Frostbolt
        1237313,                                 -- Frostfire Bolt
        440802,                                  -- Frozen Orb
        10220,                                   -- Ice Armor
        13033,                                   -- Ice Barrier
        11958,                                   -- Ice Block
        400640, 1240047,                         -- Ice Lance
        425121,                                  -- Icy Veins
        400613,                                  -- Living Bomb
        401556,                                  -- Living Flame
        6117, 22783,                             -- Mage Armor
        29442,                                   -- Magic Absorption
        10193,                                   -- Mana Shield
        412510,                                  -- Mass Regeneration
        29077,                                   -- Master of Elements
        28271, 28272, 12826,                     -- Polymorph
        28270,                                   -- Polymorph: Cow
        11419,                                   -- Portal: Darnassus
        11416,                                   -- Portal: Ironforge
        11417,                                   -- Portal: Orgrimmar
        10059,                                   -- Portal: Stormwind
        11420,                                   -- Portal: Thunder Bluff
        11418,                                   -- Portal: Undercity
        12043,                                   -- Presence of Mind
        18809,                                   -- Pyroblast
        401417,                                  -- Regeneration
        475,                                     -- Remove Lesser Curse
        401462,                                  -- Rewind Time
        10207,                                   -- Scorch
        130,                                     -- Slow Fall
        412532,                                  -- Spellfrost Bolt
        1297659,                                 -- Teleport: Dalaran
        3565,                                    -- Teleport: Darnassus
        3562,                                    -- Teleport: Ironforge
        3567,                                    -- Teleport: Orgrimmar
        3561,                                    -- Teleport: Stormwind
        3566,                                    -- Teleport: Thunder Bluff
        3563,                                    -- Teleport: Undercity
    },

    warlock = {
        18288,                                   -- Amplify Curse
        11713,                                   -- Bane of Agony
        603,                                     -- Bane of Doom
        1225228,                                 -- Bane of Havoc
        18647,                                   -- Banish
        403629,                                  -- Chaos Bolt
        18932,                                   -- Conflagrate
        25311,                                   -- Corruption
        6366, 17951, 17952, 17953,               -- Create Firestone
        6201, 6202, 5699, 11729, 11730,          -- Create Healthstone
        693, 20752, 20755, 20756, 20757,         -- Create Soulstone
        2362, 17727, 17728,                      -- Create Spellstone
        18223,                                   -- Curse of Exhaustion
        1010,                                    -- Curse of Idiocy
        11717,                                   -- Curse of Recklessness
        11719,                                   -- Curse of Tongues
        11708,                                   -- Curse of Weakness
        440892, 1311680,                         -- Curse of the Elements
        17926,                                   -- Death Coil
        11735,                                   -- Demon Armor
        412788,                                  -- Demon Charge
        696,                                     -- Demon Skin
        425463,                                  -- Demonic Grace
        412789,                                  -- Demonic Howl
        18788,                                   -- Demonic Sacrifice
        132, 2970, 11743,                        -- Detect Invisibility
        11700,                                   -- Drain Life
        11704,                                   -- Drain Mana
        11675,                                   -- Drain Soul
        126,                                     -- Eye of Kilrogg
        5782, 6215,                              -- Fear
        403619,                                  -- Fel Armor
        18708,                                   -- Fel Domination
        426301,                                  -- Grimoire of Synergy
        11695,                                   -- Health Funnel
        11684,                                   -- Hellfire
        17928,                                   -- Howl of Terror
        25309,                                   -- Immolate
        1293813,                                 -- Incinerate
        1122,                                    -- Inferno
        11689,                                   -- Life Tap
        403828,                                  -- Menace
        403789,                                  -- Metamorphosis
        437169,                                  -- Portal of Summoning
        11678,                                   -- Rain of Fire
        18540,                                   -- Ritual of Doom
        698,                                     -- Ritual of Summoning
        17923,                                   -- Searing Pain
        5500,                                    -- Sense Demons
        25307,                                   -- Shadow Bolt
        403852,                                  -- Shadow Cleave
        28610,                                   -- Shadow Ward
        17877, 18871,                            -- Shadowburn
        426320,                                  -- Shadowflame
        18881,                                   -- Siphon Life
        17924,                                   -- Soul Fire
        19028,                                   -- Soul Link
        11726,                                   -- Subjugate Demon
        691,                                     -- Summon Felhunter
        688,                                     -- Summon Imp
        713,                                     -- Summon Incubus
        712,                                     -- Summon Succubus
        697,                                     -- Summon Voidwalker
        5697,                                    -- Unending Breath
        426195,                                  -- Vengeance
        1316697,                                 -- Wrack
    },

    druid = {
        2893,                                    -- Abolish Poison
        1066,                                    -- Aquatic Form
        22812,                                   -- Barkskin
        8983,                                    -- Bash
        5487,                                    -- Bear Form
        417141,                                  -- Berserk
        768,                                     -- Cat Form
        5209,                                    -- Challenging Roar
        9850,                                    -- Claw
        8998, 9000, 9892,                        -- Cower
        8946,                                    -- Cure Poison
        9821,                                    -- Dash
        9898,                                    -- Demoralizing Roar
        9634,                                    -- Dire Bear Form
        417148,                                  -- Efflorescence
        5229,                                    -- Enrage
        9853,                                    -- Entangling Roots
        9907,                                    -- Faerie Fire
        1238122,                                 -- Feral Charge
        16979,                                   -- Feral Charge (Bear)
        22842,                                   -- Frenzied Regeneration
        21850,                                   -- Gift of the Wild
        6795,                                    -- Growl
        25297,                                   -- Healing Touch
        18658,                                   -- Hibernate
        16914, 17402,                            -- Hurricane
        29166,                                   -- Innervate
        24977,                                   -- Insect Swarm
        414644, 1235827,                         -- Lacerate
        408124,                                  -- Lifebloom
        414683,                                  -- Living Seed
        1126, 6756, 9885,                        -- Mark of the Wild
        9881,                                    -- Maul
        9835,                                    -- Moonfire
        24858,                                   -- Moonkin Form
        16689, 16810, 16811, 16812, 16813, 17329, -- Nature's Grasp
        17116,                                   -- Nature's Swiftness
        408247,                                  -- Nourish
        9827,                                    -- Pounce
        1238070,                                 -- Primal Bite
        9913,                                    -- Prowl
        9904,                                    -- Rake
        9867,                                    -- Ravage
        20748,                                   -- Rebirth
        9858,                                    -- Regrowth
        25299,                                   -- Rejuvenation
        2782,                                    -- Remove Curse
        1237951,                                 -- Revive
        9896,                                    -- Rip
        1322605,                                 -- Shifting Power
        9830,                                    -- Shred
        410176,                                  -- Skull Bash
        2908, 8955, 9901,                        -- Soothe Animal
        439748,                                  -- Starfall
        25298,                                   -- Starfire
        417157,                                  -- Starsurge
        414687, 414689,                          -- Sunfire
        408024,                                  -- Survival Instincts
        18562,                                   -- Swiftmend
        411128, 9908,                            -- Swipe
        18960,                                   -- Teleport: Moonglade
        9910,                                    -- Thorns
        5217, 417045,                            -- Tiger's Fury
        5225,                                    -- Track Humanoids
        9863,                                    -- Tranquility
        783,                                     -- Travel Form
        408120, 1238215,                         -- Wild Growth
        9912,                                    -- Wrath
    },

    warlockpet = {
        11767,                                   -- Blood Pact
        17854,                                   -- Consume Shadows
        19736,                                   -- Devour Magic
        11771,                                   -- Fire Shield
        11763,                                   -- Firebolt
        11780,                                   -- Lash of Pain
        7870,                                    -- Lesser Invisibility
        19480,                                   -- Paranoia
        4511,                                    -- Phase Shift
        19443,                                   -- Sacrifice
        6358,                                    -- Seduction
        6360, 7813, 11784, 11785,                -- Soothing Kiss
        19647,                                   -- Spell Lock
        17735, 17750, 17751, 17752,              -- Suffering
        19660,                                   -- Tainted Blood
        3716, 7809, 7810, 7811, 11774, 11775,    -- Torment
    },

    hunterpet = {
        17261,                                   -- Bite
        27685,                                   -- Charge
        3010, 3009,                              -- Claw
        1756, 16697,                             -- Cower
        23110,                                   -- Dash
        24577, 24579,                            -- Demoralizing Screech
        1264758, 1264933,                        -- Dismember
        23148,                                   -- Dive
        1265904,                                 -- Dust Cloud
        24597,                                   -- Furious Howl
        14921,                                   -- Growl
        19577,                                   -- Intimidation
        444681,                                  -- Lava Breath
        25012,                                   -- Lightning Breath
        1265058,                                 -- Mine!
        1264742,                                 -- Pinch
        24453,                                   -- Prowl
        1265069,                                 -- Savage Rend
        24587,                                   -- Scorpid Poison
        26064,                                   -- Shell Shield
        1264482,                                 -- Sonic Blast
        1264502,                                 -- Swipe
        1265042,                                 -- Tendon Rip
        26188, 1264455,                          -- Thunderstomp
        1310612,                                 -- Trickster's Dance
        1265883,                                 -- Web
    },
}

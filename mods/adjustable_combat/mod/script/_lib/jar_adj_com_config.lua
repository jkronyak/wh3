
------------------------------------------------------------------------
--- Module: Adjustable Combat Config
--- Author: AceTheGreat
--- Description: Contains configuration for Adjustable Combat
--- TODO: Replace much of the below configuration with localization.
------------------------------------------------------------------------

local adj_com_config = {}

-----------------------------------------------------------------------------
--- General Configuration
-----------------------------------------------------------------------------
adj_com_config.mod_config = { 
    mod_name = "jar_adjustable_combat",
    mod_title = "Adjustable Combat",
    mod_prefix = "jar_adj_com",
    mod_description = "Allows you to customize and rebalance unit stats!",
}
-----------------------------------------------------------------------------
--- Unit Set Configuration
-----------------------------------------------------------------------------
adj_com_config.unit_set_config = {
    jar_adj_com_unit_set_global = {
        display = "Global",
        description = "Includes every unit, and stacks with other settings.",
        static = true,
        key = "jar_adj_com_unit_set_global",
    },
    jar_adj_com_unit_set_characters = {
        display = "Characters",
        description = "Includes every lord and hero unit.",
        static = true,
        key = "jar_adj_com_unit_set_characters",
    },
    jar_adj_com_unit_set_cavalry = {
        display = "Cavalry",
        description = "Includes every unit classified as cavalry.",
        key = "jar_adj_com_unit_set_cavalry",
    },
    jar_adj_com_unit_set_chariots_war_machines = {
        display = "Chariots/War Machines",
        description = "Includes every unit classified as a chariot or war machine.",
        key = "jar_adj_com_unit_set_chariots_war_machines",
    },
    jar_adj_com_unit_set_war_beasts = {
        display = "War Beasts",
        description = "Includes every unit classified as a multiple entity monster, war beast, or small monstrous infantry. Ex. war dogs, harpies, etc.",
        key = "jar_adj_com_unit_set_war_beasts",
    },
    jar_adj_com_unit_set_infantry = {
        display = "Infantry",
        description = "Includes every unit classified as small-sized infantry. Ex. Elven Spearman, Goblins, etc. Also includes crewed artillery such as Empire Mortars.",
        key = "jar_adj_com_unit_set_infantry",
    },
    jar_adj_com_unit_set_monstrous_infantry = {
        display = "Monstrous Infantry",
        description = "Includes every unit classified as monstrous or large-sized infantry. Ex. Ogres, Ushabti, etc.",
        key = "jar_adj_com_unit_set_monstrous_infantry",
    },
    jar_adj_com_unit_set_single_entities = {
        display = "Single Entities",
        description = "Includes every unit classified as a single entity, excluding characters, chariots, and war machines. Ex. War Mammoths, Feral Manticore, Dragons, etc.",
        key = "jar_adj_com_unit_set_single_entities",
    },
}
-----------------------------------------------------------------------------
--- Bonus Value Configuration
-----------------------------------------------------------------------------
adj_com_config.bonus_value_config = {
    battle_healing_cap_mod = {
        display = "Healing Cap",
        description = "Modify the maximum healing capacity by n%.",
        unit_sets = {
            "jar_adj_com_unit_set_global"
        },
        type = "effect_bonus_value_basic_junction_tables",
        min = -500,
        max = 500,
        key = "battle_healing_cap_mod",
    },
    heal_power_percent_mod = {
        display = "Healing Power",
        description = "Modify healing received by n. Base is 100.",
        unit_sets = {
            "jar_adj_com_unit_set_global"
        },
        type = "effect_bonus_value_basic_junction_tables",
        min = -500,
        max = 500,
        key = "heal_power_percent_mod",
    },
    spell_mastery_percentage_mod = {
        display = "Spell Mastery",
        description = "Modify spell mastery by n. Base is 100",
        unit_sets = {
            "jar_adj_com_unit_set_global"
        },
        type = "effect_bonus_value_basic_junction_tables",
        min = -500,
        max = 500,
        key = "spell_mastery_percentage_mod",
    },
    miscast_chance_mod = {
        display = "Miscast Chance",
        description = "Modify spell miscast chance by n.",
        unit_sets = {
            "jar_adj_com_unit_set_global"
        },
        type = "effect_bonus_value_basic_junction_tables",
        min = -500,
        max = 500,
        key = "miscast_chance_mod",
    },
    morale_percentage_mod = {
        display = "Morale %",
        description = "Modify unit moral by n% of base.",
        unit_sets = {
            "jar_adj_com_unit_set_global"
        },
        type = "effect_bonus_value_basic_junction_tables",
        min = -500,
        max = 500,
        key = "morale_percentage_mod",
    },
    unit_damage_resistance_all_mod = {
        display = "Ward Save",
        description = "Modify unit ward save by n.",
        min = -500,
        max = 500,
        key = "unit_damage_resistance_all_mod",
    },
    unit_damage_resistance_flame_mod = {
        display = "Flame Resistance",
        description = "Modify unit flame resistance by n.",
        min = -500,
        max = 500,
        key = "unit_damage_resistance_flame_mod",
    },
    unit_damage_resistance_magic_mod = {
        display = "Spell Resistance",
        description = "Modify unit spell resistance by n.",
        min = -500,
        max = 500,
        key = "unit_damage_resistance_magic_mod",
    },
    unit_damage_resistance_missile_mod = {
        display = "Missile Resistance",
        description = "Modify unit missile resistance by n.",
        min = -500,
        max = 500,
        key = "unit_damage_resistance_missile_mod",
    },
    unit_damage_resistance_physical_mod = {
        display = "Physical Resistance",
        description = "Modify unit physical resistance by n.",
        min = -500,
        max = 500,
        key = "unit_damage_resistance_physical_mod",
    },
    unit_fatigue_resistance_mod = {
        display = "Fatigue Resistance",
        description = "Modify unit fatigue resistance by n.",
        min = -500,
        max = 500,
        key = "unit_fatigue_resistance_mod",
    },
    armour_mod = {
        display = "Armor",
        description = "Modify unit armor by n flat.",
        min = -500,
        max = 500,
        key = "armour_mod",
    },
    armour_mod_mult = {
        display = "Armor %",
        description = "Modify unit armor by n%.",
        min = -500,
        max = 500,
        key = "armour_mod_mult",
    },
    missile_block_chance_mod = {
        display = "Missile Block Chance",
        description = "Modify unit missile block chance (ex. shield) by n.",
        min = -500,
        max = 500,
        key = "missile_block_chance_mod",
    },
    battle_barrier_health = {
        display = "Barrier Health",
        description = "Modify unit barrier health by n flat.",
        min = -500,
        max = 500,
        key = "battle_barrier_health",
    },
    battle_barrier_health_mod = {
        display = "Barrier Health %",
        description = "Modify unit barrier health by n%.",
        min = -500,
        max = 500,
        key = "battle_barrier_health_mod",
    },
    morale = {
        display = "Morale",
        description = "Modify unit moral by n flat.",
        min = -500,
        max = 500,
        key = "morale",
    },
    unit_mass_percentage_mod = {
        display = "Mass",
        description = "Modify unit mass by n%.",
        min = -500,
        max = 500,
        key = "unit_mass_percentage_mod",
    },
    mod_land_movement_battle = {
        display = "Speed",
        description = "Modify unit speed by n%.",
        min = -500,
        max = 500,
        key = "mod_land_movement_battle",
    },
    melee_attack_mod = {
        display = "Melee Attack",
        description = "Modify unit melee attack by n flat.",
        min = -500,
        max = 500,
        key = "melee_attack_mod",
    },
    melee_attack_mod_mult = {
        display = "Melee Attack %",
        description = "Modify unit melee attack by n%.",
        min = -500,
        max = 500,
        key = "melee_attack_mod_mult",
    },
    melee_defence_mod = {
        display = "Melee Defense",
        description = "Modify unit melee defense by n flat.",
        min = -500,
        max = 500,
        key = "melee_defence_mod",
    },
    melee_defence_mod_mult = {
        display = "Melee Defense %",
        description = "Modify unit melee defense by n%.",
        min = -500,
        max = 500,
        key = "melee_defence_mod_mult",
    },
    melee_damage_mod_add = {
        display = "Base Weapon Damage",
        description = "Modify unit non-AP weapon damage by n flat.",
        min = -500,
        max = 500,
        key = "melee_damage_mod_add",
    },
    melee_damage_mod_mult = {
        display = "Base Weapon Damage %",
        description = "Modify unit non-AP weapon damage by n%.",
        min = -500,
        max = 500,
        key = "melee_damage_mod_mult",
    },
    melee_damage_ap_mod_add = {
        display = "AP Weapon Damage",
        description = "Modify unit AP weapon damage by n flat.",
        min = -500,
        max = 500,
        key = "melee_damage_ap_mod_add",
    },
    melee_damage_ap_mod_mult = {
        display = "AP Weapon Damage %",
        description = "Modify unit AP weapon damage ny n%.",
        min = -500,
        max = 500,
        key = "melee_damage_ap_mod_mult",
    },
}
-----------------------------------------------------------------------------
--- Unit Set - Bonus Value Mapping
-----------------------------------------------------------------------------
adj_com_config.bonus_value_mapping = {
    common = {
        "unit_damage_resistance_all_mod",
        "unit_damage_resistance_flame_mod",
        "unit_damage_resistance_magic_mod",
        "unit_damage_resistance_missile_mod",
        "unit_damage_resistance_physical_mod",
        "unit_fatigue_resistance_mod",
        "armour_mod",
        "armour_mod_mult",
        "missile_block_chance_mod",
        "battle_barrier_health",
        "battle_barrier_health_mod",
        "morale",
        "unit_mass_percentage_mod",
        "mod_land_movement_battle",
        "melee_attack_mod",
        "melee_attack_mod_mult",
        "melee_defence_mod",
        "melee_defence_mod_mult",
        "melee_damage_mod_add",
        "melee_damage_mod_mult",
        "melee_damage_ap_mod_add",
        "melee_damage_ap_mod_mult"
    },
    jar_adj_com_unit_set_global = {
        "battle_healing_cap_mod",
        "heal_power_percent_mod",
        "spell_mastery_percentage_mod",
        "miscast_chance_mod",
        "morale_percentage_mod"
    },
}
-----------------------------------------------------------------------------
--- Misc Setting Configuration
-----------------------------------------------------------------------------
adj_com_config.misc_config = {
    enable_mod = {
        display = "Enable Mod",
        description = "Enable this mod's functionality.",
    },
    apply_to_player = {
        display = "Apply to Player",
        description = "Apply the configured effects to the player.",
    },
    apply_to_ai = {
        display = "Apply to AI",
        description = "Apply the configured effects to the AI",
    },
    enable_logging = {
        display = "Enable Logging",
        description = "Enable developer logging.",
    },
}
-----------------------------------------------------------------------------
--- Option Default Settings; can be overwritten here
-----------------------------------------------------------------------------
adj_com_config.mod_defaults = {
    bonus_value = {
        jar_adj_com_unit_set_global = {
            battle_healing_cap_mod = {
                player = 0,
                ai = 0,
            },
            heal_power_percent_mod = {
                player = 0,
                ai = 0,
            },
            spell_mastery_percentage_mod = {
                player = 0,
                ai = 0,
            },
            miscast_chance_mod = {
                player = 0,
                ai = 0,
            },
            morale_percentage_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_all_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_flame_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_magic_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_missile_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_physical_mod = {
                player = 0,
                ai = 0,
            },
            unit_fatigue_resistance_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_block_chance_mod = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health_mod = {
                player = 0,
                ai = 0,
            },
            morale = {
                player = 0,
                ai = 0,
            },
            unit_mass_percentage_mod = {
                player = 0,
                ai = 0,
            },
            mod_land_movement_battle = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
        },
        jar_adj_com_unit_set_characters = {
            battle_healing_cap_mod = {
                player = 0,
                ai = 0,
            },
            heal_power_percent_mod = {
                player = 0,
                ai = 0,
            },
            spell_mastery_percentage_mod = {
                player = 0,
                ai = 0,
            },
            miscast_chance_mod = {
                player = 0,
                ai = 0,
            },
            morale_percentage_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_all_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_flame_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_magic_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_missile_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_physical_mod = {
                player = 0,
                ai = 0,
            },
            unit_fatigue_resistance_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_block_chance_mod = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health_mod = {
                player = 0,
                ai = 0,
            },
            morale = {
                player = 0,
                ai = 0,
            },
            unit_mass_percentage_mod = {
                player = 0,
                ai = 0,
            },
            mod_land_movement_battle = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
        },
        jar_adj_com_unit_set_cavalry = {
            battle_healing_cap_mod = {
                player = 0,
                ai = 0,
            },
            heal_power_percent_mod = {
                player = 0,
                ai = 0,
            },
            spell_mastery_percentage_mod = {
                player = 0,
                ai = 0,
            },
            miscast_chance_mod = {
                player = 0,
                ai = 0,
            },
            morale_percentage_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_all_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_flame_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_magic_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_missile_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_physical_mod = {
                player = 0,
                ai = 0,
            },
            unit_fatigue_resistance_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_block_chance_mod = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health_mod = {
                player = 0,
                ai = 0,
            },
            morale = {
                player = 0,
                ai = 0,
            },
            unit_mass_percentage_mod = {
                player = 0,
                ai = 0,
            },
            mod_land_movement_battle = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
        },
        jar_adj_com_unit_set_chariots_war_machines = {
            battle_healing_cap_mod = {
                player = 0,
                ai = 0,
            },
            heal_power_percent_mod = {
                player = 0,
                ai = 0,
            },
            spell_mastery_percentage_mod = {
                player = 0,
                ai = 0,
            },
            miscast_chance_mod = {
                player = 0,
                ai = 0,
            },
            morale_percentage_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_all_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_flame_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_magic_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_missile_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_physical_mod = {
                player = 0,
                ai = 0,
            },
            unit_fatigue_resistance_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_block_chance_mod = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health_mod = {
                player = 0,
                ai = 0,
            },
            morale = {
                player = 0,
                ai = 0,
            },
            unit_mass_percentage_mod = {
                player = 0,
                ai = 0,
            },
            mod_land_movement_battle = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
        },
        jar_adj_com_unit_set_war_beasts = {
            battle_healing_cap_mod = {
                player = 0,
                ai = 0,
            },
            heal_power_percent_mod = {
                player = 0,
                ai = 0,
            },
            spell_mastery_percentage_mod = {
                player = 0,
                ai = 0,
            },
            miscast_chance_mod = {
                player = 0,
                ai = 0,
            },
            morale_percentage_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_all_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_flame_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_magic_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_missile_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_physical_mod = {
                player = 0,
                ai = 0,
            },
            unit_fatigue_resistance_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_block_chance_mod = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health_mod = {
                player = 0,
                ai = 0,
            },
            morale = {
                player = 0,
                ai = 0,
            },
            unit_mass_percentage_mod = {
                player = 0,
                ai = 0,
            },
            mod_land_movement_battle = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
        },
        jar_adj_com_unit_set_infantry = {
            battle_healing_cap_mod = {
                player = 0,
                ai = 0,
            },
            heal_power_percent_mod = {
                player = 0,
                ai = 0,
            },
            spell_mastery_percentage_mod = {
                player = 0,
                ai = 0,
            },
            miscast_chance_mod = {
                player = 0,
                ai = 0,
            },
            morale_percentage_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_all_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_flame_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_magic_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_missile_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_physical_mod = {
                player = 0,
                ai = 0,
            },
            unit_fatigue_resistance_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_block_chance_mod = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health_mod = {
                player = 0,
                ai = 0,
            },
            morale = {
                player = 0,
                ai = 0,
            },
            unit_mass_percentage_mod = {
                player = 0,
                ai = 0,
            },
            mod_land_movement_battle = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
        },
        jar_adj_com_unit_set_monstrous_infantry = {
            battle_healing_cap_mod = {
                player = 0,
                ai = 0,
            },
            heal_power_percent_mod = {
                player = 0,
                ai = 0,
            },
            spell_mastery_percentage_mod = {
                player = 0,
                ai = 0,
            },
            miscast_chance_mod = {
                player = 0,
                ai = 0,
            },
            morale_percentage_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_all_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_flame_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_magic_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_missile_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_physical_mod = {
                player = 0,
                ai = 0,
            },
            unit_fatigue_resistance_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_block_chance_mod = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health_mod = {
                player = 0,
                ai = 0,
            },
            morale = {
                player = 0,
                ai = 0,
            },
            unit_mass_percentage_mod = {
                player = 0,
                ai = 0,
            },
            mod_land_movement_battle = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
        },
        jar_adj_com_unit_set_single_entities = {
            battle_healing_cap_mod = {
                player = 0,
                ai = 0,
            },
            heal_power_percent_mod = {
                player = 0,
                ai = 0,
            },
            spell_mastery_percentage_mod = {
                player = 0,
                ai = 0,
            },
            miscast_chance_mod = {
                player = 0,
                ai = 0,
            },
            morale_percentage_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_all_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_flame_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_magic_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_missile_mod = {
                player = 0,
                ai = 0,
            },
            unit_damage_resistance_physical_mod = {
                player = 0,
                ai = 0,
            },
            unit_fatigue_resistance_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod = {
                player = 0,
                ai = 0,
            },
            armour_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_block_chance_mod = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health = {
                player = 0,
                ai = 0,
            },
            battle_barrier_health_mod = {
                player = 0,
                ai = 0,
            },
            morale = {
                player = 0,
                ai = 0,
            },
            unit_mass_percentage_mod = {
                player = 0,
                ai = 0,
            },
            mod_land_movement_battle = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod = {
                player = 0,
                ai = 0,
            },
            melee_attack_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod = {
                player = 0,
                ai = 0,
            },
            melee_defence_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            melee_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
        },
    },
    link = {
        jar_adj_com_unit_set_global = true,
        jar_adj_com_unit_set_characters = true,
        jar_adj_com_unit_set_cavalry = true,
        jar_adj_com_unit_set_chariots_war_machines = true,
        jar_adj_com_unit_set_war_beasts = true,
        jar_adj_com_unit_set_infantry = true,
        jar_adj_com_unit_set_monstrous_infantry = true,
        jar_adj_com_unit_set_single_entities = true,
    },
    misc = {
        enable_mod = true,
        apply_to_ai = true,
        apply_to_player = true,
        enable_logging = false,
    },
}

core:add_static_object("adj_com_config", adj_com_config)

export const UNIT_SET_CONFIG = { 
    jar_adj_com_unit_set_global: { 
        display: "Global",
        description: "Includes every unit, and stacks with other settings.",
        static: true,
    },
    jar_adj_com_unit_set_characters: { 
        display: "Characters",
        description: "Includes every lord and hero unit.",
        static: true,
    },
    jar_adj_com_unit_set_cavalry: { 
        display: "Cavalry",
        description: "Includes every unit classified as cavalry.",
    },
    jar_adj_com_unit_set_chariots_war_machines: { 
        display: "Chariots/War Machines",
        description: "Includes every unit classified as a chariot or war machine.",
    },
    jar_adj_com_unit_set_war_beasts: { 
        display: "War Beasts",
        description: "Includes every unit classified as a multiple entity monster, war beast, or small monstrous infantry. Ex. war dogs, harpies, etc.",
    },
    jar_adj_com_unit_set_infantry: { 
        display: "Infantry",
        description: "Includes every unit classified as small-sized infantry. Ex. Elven Spearman, Goblins, etc. Also includes crewed artillery such as Empire Mortars.",
    },
    jar_adj_com_unit_set_monstrous_infantry: { 
        display: "Monstrous Infantry",
        description: "Includes every unit classified as monstrous or large-sized infantry. Ex. Ogres, Ushabti, etc.",
    },
    jar_adj_com_unit_set_single_entities: { 
        display: "Single Entities",
        description: "Includes every unit classified as a single entity, excluding characters, chariots, and war machines. Ex. War Mammoths, Feral Manticore, Dragons, etc.",
    }
} as Record<string, any>;

export const BONUS_VALUE_CONFIG  = {

    general_bodyguard_size_mod: { 
        display: "Hit Points",
        description: "Modify character hitpoints by n%. Warning: When using positive values, please reload your save on turn 1, otherwise some lords may be damaged on battle start. When using negative values, no reload is required, and the hit points will be updated on battle start or upon reloading your save.",
        unit_sets: ["jar_adj_com_unit_set_characters"],
        type: "effect_bonus_value_basic_junction_tables",
        min: -99
    },
    battle_healing_cap_mod: {
        display: "Healing Cap",
        description: "Modify the maximum healing capacity by n%.",
        unit_sets: ["jar_adj_com_unit_set_global"],
        type: "effect_bonus_value_basic_junction_tables",
    },
    heal_power_percent_mod: {
        display: "Healing Power",
        description: "Modify healing received by n. Base is 100.",
        unit_sets: ["jar_adj_com_unit_set_global"],
        type: "effect_bonus_value_basic_junction_tables"
    },
    spell_mastery_percentage_mod: {
        display: "Spell Mastery",
        description: "Modify spell mastery by n. Base is 100",
        unit_sets: ["jar_adj_com_unit_set_global"],
        type: "effect_bonus_value_basic_junction_tables"
    },
    miscast_chance_mod: {
        display: "Miscast Chance",
        description: "Modify spell miscast chance by n.",
        unit_sets: ["jar_adj_com_unit_set_global"],
        type: "effect_bonus_value_basic_junction_tables"
    },
    morale_percentage_mod: {
        display: "Morale %",
        description: "Modify unit moral by n% of base.",
        unit_sets: ["jar_adj_com_unit_set_global"],
        type: "effect_bonus_value_basic_junction_tables"
    },

    // Common
    unit_damage_resistance_all_mod: {
        display: "Ward Save",
        description: "Modify unit ward save by n.",

    },
    unit_damage_resistance_flame_mod: {
        display: "Flame Resistance",
        description: "Modify unit flame resistance by n.",

    },
    unit_damage_resistance_magic_mod: {
        display: "Spell Resistance",
        description: "Modify unit spell resistance by n.",

    },
    unit_damage_resistance_missile_mod: {
        display: "Missile Resistance",
        description: "Modify unit missile resistance by n.",

    },
    unit_damage_resistance_physical_mod: {
        display: "Physical Resistance",
        description: "Modify unit physical resistance by n.",

    },
    unit_fatigue_resistance_mod: {
        display: "Fatigue Resistance",
        description: "Modify unit fatigue resistance by n.",

    },

    armour_mod: {
        display: "Armor (Flat)",
        description: "Modify unit armor by n flat.",

    },
    armour_mod_mult: {
        display: "Armor %",
        description: "Modify unit armor by n%.",

    },

    missile_block_chance_mod: {
        display: "Missile Block Chance (Flat)",
        description: "Modify unit missile block chance (ex. shield) by n.",

    },

    battle_barrier_health: {
        display: "Barrier Health (Flat)",
        description: "Modify unit barrier health by n flat.",

    },
    battle_barrier_health_mod: {
        display: "Barrier Health %",
        description: "Modify unit barrier health by n%.",

    },

    morale: {
        display: "Morale (Flat)",
        description: "Modify unit moral by n flat.",

    },


    unit_mass_percentage_mod: {
        display: "Mass %",
        description: "Modify unit mass by n%.",

    },

    mod_land_movement_battle: {
        display: "Speed %",
        description: "Modify unit speed by n%.",

    },

    melee_attack_mod_mult: {
        display: "Melee Attack %",
        description: "Modify unit melee attack by n%.",
        
    },
    melee_defence_mod_mult: {
        display: "Melee Defense %",
        description: "Modify unit melee defense by n%.",

    },
    melee_defence_mod: {
        display: "Melee Defense (Flat)",
        description: "Modify unit melee defense by n flat.",
        
    },
    melee_attack_mod: {
        display: "Melee Attack (Flat)",
        description: "Modify unit melee attack by n flat.",

    },

    melee_damage_mod_mult: {
        display: "Base Weapon Damage %",
        description: "Modify unit non-AP weapon damage by n%.",
        
    },
    melee_damage_ap_mod_mult: {
        display: "AP Weapon Damage %",
        description: "Modify unit AP weapon damage ny n%.",
        
    },
    melee_damage_mod_add: {
        display: "Base Weapon Damage (Flat)",
        description: "Modify unit non-AP weapon damage by n flat.",

    },
    melee_damage_ap_mod_add: {
        display: "AP Weapon Damage (Flat)",
        description: "Modify unit AP weapon damage by n flat.",

    },

    charge_add: { 
        display: "Charge Bonus (Flat)",
        description: "Modify unit charge bonus by n flat.",
    },
    charge_bonus: { 
        display: "Charge Bonus %",
        description: "Modify unit charge bonus by n%."
    },

    damage_vs_infantry: { 
        display: "Bonus vs. Infantry (Flat)",
        description: "Modify unit bonus vs. infantry by n flat.",
    },
    damage_vs_large_entities: { 
        display: "Bonus vs. Large (Flat)",
        description: "Modify unit bonus vs. large by n flat.",
    },
    

} as Record<string, any>;
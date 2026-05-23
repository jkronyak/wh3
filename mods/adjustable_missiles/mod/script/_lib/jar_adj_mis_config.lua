
------------------------------------------------------------------------
--- Module: Adjustable Missiles Config
--- Author: AceTheGreat
--- Description: Contains configuration for Adjustable Missiles
--- TODO: Replace much of the below configuration with localization.
------------------------------------------------------------------------

local adj_mis_config = {}

-----------------------------------------------------------------------------
--- General Configuration
-----------------------------------------------------------------------------
adj_mis_config.mod_config = { 
    mod_name = "jar_adjustable_missiles",
    mod_title = "Adjustable Missiles",
    mod_prefix = "jar_adj_mis",
    mod_description = "Allows you to rebalance missile unit stats!",
}

adj_mis_config.mod_overrides = { 
    static_only = false
}
-----------------------------------------------------------------------------
--- Unit Set Configuration
-----------------------------------------------------------------------------
adj_mis_config.unit_set_config = {
    jar_unit_set_global = {
        display = "Global",
        description = "Includes every unit, and stacks with other settings.",
        static = true,
        key = "jar_unit_set_global",
    },
    jar_unit_set_characters = {
        display = "Characters",
        description = "Includes every lord and hero unit.",
        static = true,
        key = "jar_unit_set_characters",
    },
    jar_unit_set_artillery_war_machines = {
        display = "Artillery/War Machines",
        description = "Includes every unit classified as an artillery or war machine unit.",
        static = false,
        key = "jar_unit_set_artillery_war_machines",
    },
    jar_unit_set_single_entities = {
        display = "Single Entities",
        description = "Includes every single entity unit, except for characters, artillery, and war machines.",
        static = false,
        key = "jar_unit_set_single_entities",
    },
    jar_unit_set_cavalry_chariots = {
        display = "Cavalry/Chariots",
        description = "Includes every unit classified as cavalry or a chariot.",
        static = false,
        key = "jar_unit_set_cavalry_chariots",
    },
    jar_unit_set_infantry = {
        display = "Infantry",
        description = "Includes every unit classified as infantry or monstrous infantry.",
        static = false,
        key = "jar_unit_set_infantry",
    },
}
-----------------------------------------------------------------------------
--- Bonus Value Configuration
-----------------------------------------------------------------------------
adj_mis_config.bonus_value_config = {
    accuracy = {
        display = "Accuracy (Flat)",
        description = "Modify unit accuracy by n.",
        min = -100,
        max = 200,
        type = "ability",
        key = "accuracy",
    },
    unit_stat_bonus_accuracy_mod = {
        display = "Accuracy %",
        description = "Modify unit accuracy by n%.",
        unit_sets = {
            "jar_unit_set_global"
        },
        type = "effect_bonus_value_basic_junction_tables",
        min = -500,
        max = 500,
        key = "unit_stat_bonus_accuracy_mod",
    },
    reload = {
        display = "Reload Skill %",
        description = "Modify unit reload speed by n%.",
        min = -500,
        max = 500,
        key = "reload",
    },
    ammo_mod = {
        display = "Ammo %",
        description = "Modify unit ammunition by n%",
        min = -500,
        max = 500,
        key = "ammo_mod",
    },
    range_mod = {
        display = "Range %",
        description = "Modify unit range by n%",
        min = -500,
        max = 500,
        key = "range_mod",
    },
    missile_damage_mod_mult = {
        display = "Base Damage %",
        description = "Modify unit non-AP missile damage by n%.",
        min = -500,
        max = 500,
        key = "missile_damage_mod_mult",
    },
    missile_damage_ap_mod_mult = {
        display = "AP Damage %",
        description = "Modify unit AP missile damage by n%.",
        min = -500,
        max = 500,
        key = "missile_damage_ap_mod_mult",
    },
    missile_explosion_damage_mod_mult = {
        display = "Base Explosive Damage %",
        description = "Modify unit non-AP explosive missile damage by n%, if present.",
        min = -500,
        max = 500,
        key = "missile_explosion_damage_mod_mult",
    },
    missile_explosion_damage_ap_mod_mult = {
        display = "AP Explosive Damage %",
        description = "Modify unit AP explosive missile damage by n%, if present.",
        min = -500,
        max = 500,
        key = "missile_explosion_damage_ap_mod_mult",
    },
    missile_damage_mod_add = {
        display = "Base Damage (Flat)",
        description = "Modify unit non-AP missile damage by n flat.",
        min = -500,
        max = 500,
        key = "missile_damage_mod_add",
    },
    missile_damage_ap_mod_add = {
        display = "AP Damage (Flat)",
        description = "Modify unit AP missile damage by n flat.",
        min = -500,
        max = 500,
        key = "missile_damage_ap_mod_add",
    },
    missile_explosion_radius = {
        display = "Explosion Radius %",
        description = "Modify unit missile explosion radius by n%, if present.",
        min = -500,
        max = 500,
        key = "missile_explosion_radius",
    },
}
-----------------------------------------------------------------------------
--- Unit Set - Bonus Value Mapping
-----------------------------------------------------------------------------
adj_mis_config.bonus_value_mapping = {
    common = {
        "accuracy",
        "reload",
        "ammo_mod",
        "range_mod",
        "missile_damage_mod_mult",
        "missile_damage_ap_mod_mult",
        "missile_explosion_damage_mod_mult",
        "missile_explosion_damage_ap_mod_mult",
        "missile_damage_mod_add",
        "missile_damage_ap_mod_add",
        "missile_explosion_radius"
    },
    jar_unit_set_global = {
        "unit_stat_bonus_accuracy_mod"
    },
}
-----------------------------------------------------------------------------
--- Misc Setting Configuration
-----------------------------------------------------------------------------
adj_mis_config.misc_config = {
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
    --enable_logging = {
    --    display = "Enable Logging",
    --    description = "Enable developer logging.",
    --},
}
-----------------------------------------------------------------------------
--- Option Default Settings; can be overwritten here
-----------------------------------------------------------------------------
adj_mis_config.mod_defaults = {
    bonus_value = {
        jar_unit_set_global = {
            accuracy = {
                player = 0,
                ai = 0,
            },
            unit_stat_bonus_accuracy_mod = {
                player = 0,
                ai = 0,
            },
            reload = {
                player = 0,
                ai = 0,
            },
            ammo_mod = {
                player = 0,
                ai = 0,
            },
            range_mod = {
                player = 0,
                ai = 0,
            },
            missile_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_explosion_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_explosion_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            missile_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            missile_explosion_radius = {
                player = 0,
                ai = 0,
            },
        },
        jar_unit_set_characters = {
            accuracy = {
                player = 0,
                ai = 0,
            },
            reload = {
                player = 0,
                ai = 0,
            },
            ammo_mod = {
                player = 0,
                ai = 0,
            },
            range_mod = {
                player = 0,
                ai = 0,
            },
            missile_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_explosion_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_explosion_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            missile_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            missile_explosion_radius = {
                player = 0,
                ai = 0,
            },
        },
        jar_unit_set_artillery_war_machines = {
            accuracy = {
                player = 0,
                ai = 0,
            },
            reload = {
                player = 0,
                ai = 0,
            },
            ammo_mod = {
                player = 0,
                ai = 0,
            },
            range_mod = {
                player = 0,
                ai = 0,
            },
            missile_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_explosion_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_explosion_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            missile_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            missile_explosion_radius = {
                player = 0,
                ai = 0,
            },
        },
        jar_unit_set_single_entities = {
            accuracy = {
                player = 0,
                ai = 0,
            },
            reload = {
                player = 0,
                ai = 0,
            },
            ammo_mod = {
                player = 0,
                ai = 0,
            },
            range_mod = {
                player = 0,
                ai = 0,
            },
            missile_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_explosion_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_explosion_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            missile_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            missile_explosion_radius = {
                player = 0,
                ai = 0,
            },
        },
        jar_unit_set_cavalry_chariots = {
            accuracy = {
                player = 0,
                ai = 0,
            },
            reload = {
                player = 0,
                ai = 0,
            },
            ammo_mod = {
                player = 0,
                ai = 0,
            },
            range_mod = {
                player = 0,
                ai = 0,
            },
            missile_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_explosion_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_explosion_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            missile_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            missile_explosion_radius = {
                player = 0,
                ai = 0,
            },
        },
        jar_unit_set_infantry = {
            accuracy = {
                player = 0,
                ai = 0,
            },
            reload = {
                player = 0,
                ai = 0,
            },
            ammo_mod = {
                player = 0,
                ai = 0,
            },
            range_mod = {
                player = 0,
                ai = 0,
            },
            missile_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_explosion_damage_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_explosion_damage_ap_mod_mult = {
                player = 0,
                ai = 0,
            },
            missile_damage_mod_add = {
                player = 0,
                ai = 0,
            },
            missile_damage_ap_mod_add = {
                player = 0,
                ai = 0,
            },
            missile_explosion_radius = {
                player = 0,
                ai = 0,
            },
        },
    },
    link = {
        jar_unit_set_global = true,
        jar_unit_set_characters = true,
        jar_unit_set_artillery_war_machines = true,
        jar_unit_set_single_entities = true,
        jar_unit_set_cavalry_chariots = true,
        jar_unit_set_infantry = true,
    },
    misc = {
        enable_mod = true,
        apply_to_ai = true,
        apply_to_player = true,
        enable_logging = false,
    },
}

core:add_static_object("adj_mis_config", adj_mis_config)

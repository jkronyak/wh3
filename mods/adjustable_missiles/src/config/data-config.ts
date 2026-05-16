export const UNIT_SET_CONFIG = { 
    jar_unit_set_global: { 
        display: "Global",
        description: "Includes every unit, and stacks with other settings.",
        static: true,
    },
    jar_unit_set_characters: { 
        display: "Characters",
        description: "Includes every lord and hero unit.",
        static: true,
    },
    jar_unit_set_artillery_war_machines: { 
        display: "Artillery/War Machines",
        description: "Includes every unit classified as an artillery or war machine unit.",
        static: false,
    },
    jar_unit_set_single_entities: {
        display: "Single Entities",
        description: "Includes every single entity unit, except for characters, artillery, and war machines.",
        static: false,
    },
    jar_unit_set_cavalry_chariots: {
        display: "Cavalry/Chariots",
        description: "Includes every unit classified as cavalry or a chariot.",
        static: false,
    },
    jar_unit_set_infantry: {
        display: "Infantry",
        description: "Includes every unit classified as infantry or monstrous infantry.",
        static: false,
    }
} as Record<string, any>;

export const BONUS_VALUE_CONFIG  = {

    accuracy: { 
        display: "Accuracy",
        description: "Modify unit accuracy by n.",
        min: -100,
        max: 200,
        type: "ability",
    },
    reload: { 
        display: "Reload Skill %",
        description: "Modify unit reload speed by n%.",
    },
    ammo_mod: { 
        display: "Ammo %",
        description: "Modify unit ammunition by n%",
    },
    range_mod: {
        display: "Range %",
        description: "Modify unit range by n%",
    },

    missile_damage_mod_mult: {
        display: "Base Damage %",
        description: "Modify unit non-AP missile damage by n%.",
    },

    missile_damage_ap_mod_mult: {
        display: "AP Damage %",
        description: "Modify unit AP missile damage by n%.",
    },

    missile_explosion_damage_mod_mult: { 
        display: "Base Explosive Damage %",
        description: "Modify unit non-AP explosive missile damage by n%, if present.",
    },

    missile_explosion_damage_ap_mod_mult: { 
        display: "AP Explosive Damage %",
        description: "Modify unit AP explosive missile damage by n%, if present.",
    },

    missile_damage_mod_add: {
        display: "Base Damage (Flat)",
        description: "Modify unit non-AP missile damage by n flat.",
    },

    missile_damage_ap_mod_add: {
        display: "AP Damage (Flat)",
        description: "Modify unit AP missile damage by n flat.",
    },

    missile_explosion_radius: {
        display: "Explosion Radius %",
        description: "Modify unit missile explosion radius by n%, if present.",
    },

} as Record<string, any>;
local GLOBAL_SET = {
    set = "jar_unit_set_global",
    display = "Global",
    desc = "Includes every unit, and stacks with other categories."
}

local SETS_CFG = {
    {set = "jar_unit_set_characters", display = "Characters", desc = "Includes every lord or hero unit."}, {
        set = "jar_unit_set_artillery_war_machines",
        display = "Artillery/War Machines",
        desc = "Includes every artillery or war machine unit."
    }, {
        set = "jar_unit_set_single_entities",
        display = "Single Entities",
        desc = "Includes every single entity unit, except characters, artillery, and war machines."
    },
    {set = "jar_unit_set_infantry", display = "Infantry", desc = "Includes every infantry or monstrous infantry unit."},
    {
        set = "jar_unit_set_monstrous",
        display = "Monstrous",
        desc = "Applies to every multi-entity monster or monstrous unit."
    },
    {
        set = "jar_unit_set_cavalry_chariots",
        display = "Cavalry/Chariots",
        desc = "Applies to every cavalry/chariot unit."
    }
}

local STATS_CFG = {
    {
        stat = "accuracy",
        display = "Accuracy",
        min = -100,
        max = 100,
        desc = "Modify unit accuracy by n flat. Higher values = reduced spread."
    }, {
        stat = "reload",
        display = "Reload Skill (%)",
        min = -100,
        max = 500,
        desc = "Modify unit reload skill by (roughly) +n%. Higher values = faster reload."
    }, {
        stat = "ammo_mod",
        display = "Ammo (%)",
        min = -100,
        max = 500,
        desc = "Modify unit ammunition by n%. Higher values = more ammunition."
    }, {
        stat = "range_mod",
        display = "Range (%)",
        min = -100,
        max = 500,
        desc = "Modify unit range by n%. Higher values = more range."
    }, {
        stat = "missile_damage_mod_mult",
        display = "Base Damage (%)",
        min = -100,
        max = 500,
        desc = "Modify non-AP missile damage by n%. Includes non-AP explosive damage if present. Higher values = more damage."
    }, {
        stat = "missile_damage_ap_mod_mult",
        display = "AP Damage (%)",
        min = -100,
        max = 500,
        desc = "Modify AP missile damage by n%. Includes AP explosive damage if present. Higher values = more damage."
    }, {
        stat = "missile_damage_mod_add",
        display = "Base Damage (Flat)",
        min = -100,
        max = 500,
        desc = "Modify non-AP missile damage by n flat. Does not affect explosive damage. Higher values = more damage."
    }, {
        stat = "missile_damage_ap_mod_add",
        display = "AP Damage (Flat)",
        min = -100,
        max = 500,
        desc = "Modify AP missile damage by n flat. Does not affect explosive damage. Higher values = more damage."
    }

    -- TODO: Test that the missile_explosion_radius effect actually does something.
    -- {
    --     stat = "missile_explosion_radius",
    --     display = "Explosion Radius",
    --     min = -100,
    --     max = 500,
    --     desc = "Modify missile explosion radius by n%, if the unit has explosive damage. Higher values = larger radius."
    -- }
}

local CORE_CFG = {
    {
        cmd = "enable_mod",
        type = "checkbox",
        display = "Enable Mod",
        desc = "Enable or disable this mod. Applied upon reload or next turn."
    }, {
        cmd = "apply_to_player",
        type = "checkbox",
        display = "Apply To Player",
        desc = "Enable or disable this mod only for the player. Applied upon reload or next turn."
    }, {
        cmd = "apply_to_ai",
        type = "checkbox",
        display = "Apply To AI",
        desc = "Enable or disable this mod only for the AI. Applied upon reload or next turn."
    }
    -- { cmd = "dev_logging",     type = "checkbox", display = "Developer Logging", desc = "" }
}

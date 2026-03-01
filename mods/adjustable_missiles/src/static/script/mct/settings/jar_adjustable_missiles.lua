local stat_range = { min = -100, max = 100 }

local mod_unit_sets = {
    jar_unit_set_global = {
        display = "Global",
        description = "Includes all units.",
        order = 1
    },
    jar_unit_set_characters = {
        display = "Characters",
        description = "Includes lords and heroes.",
        order = 2
    },
    jar_unit_set_artillery_war_machines = {
        display = "Artillery/War Machines",
        description = "Includes artillery and war machines.",
        order = 3
    },
    jar_unit_set_single_entities = {
        display = "Single Entities",
        description = "Includes single entity units, except characters/artillery/war machines.",
        order = 4
    },

    jar_unit_set_infantry = {
        display = "Infantry",
        description = "Includes non-monstrous infantry.",
        order = 5
    },
    jar_unit_set_monstrous = {
        display = "Monstrous",
        description = "Includes multi-entity monsters, monstrous infantry, and some monstrous cavalry.",
        order = 6
    },
    jar_unit_set_cavalry_chariots = {
        display = "Cavalry/Chariots",
        description = "Includes cavalry and chariots.",
        order = 7
    }
}

local mod_stats = {
    range_mod = {
        display = "Range (%)",
        description = "Higher values increase range. Lower values decrease range.",
        order = 3
    },
    reload = {
        display = "Reload Skill (%)",
        description = "Higher values increase reload skill. Lower values decrease reload skill.",
        order = 2
    },
    accuracy = {
        display = "Accuracy",
        description = "Higher values increase accuracy. Lower values decrease accuracy.",
        order = 1
    },
}

local sorted_unit_sets = {}
for set, _ in pairs(mod_unit_sets) do
    sorted_unit_sets[#sorted_unit_sets + 1] = set
end
table.sort(sorted_unit_sets, function(a, b)
    return mod_unit_sets[a].order < mod_unit_sets[b].order
end)


local mct = get_mct()
local mct_mod = mct:register_mod("jar_adjustable_missiles")
mct_mod:set_title("Jar's Adjustable Missiles")
mct_mod:set_description("Allows you to customize missiles units by category")
mct_mod:set_option_sort_function_for_all_sections("index_sort")

-- for set, set_display in pairs(mod_unit_sets) do
for _, set in ipairs(sorted_unit_sets) do
    local set_cfg = mod_unit_sets[set]
    local section = mct_mod:add_new_section(set, set_cfg.display, false)
    section:set_option_sort_function("index_sort")
    for stat, stat_cfg in pairs(mod_stats) do
        -- Ex: jar_unit_set_lords_heroes__accuracy
        -- Ex: jar_unit_set_infantry__reload
        local opt = mct_mod:add_new_option(set .. "__" .. stat, "slider")
        opt:set_text(stat_cfg.display)
        opt:set_tooltip_text(stat_cfg.description)
        opt:slider_set_min_max(stat_range.min, stat_range.max)
        opt:slider_set_step_size(1)
        opt:set_default_value(0)
    end
end

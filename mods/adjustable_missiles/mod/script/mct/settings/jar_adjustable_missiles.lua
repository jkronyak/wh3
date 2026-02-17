local jar_unit_sets = { 
    jar_unit_set_lords_heroes = "Lords and Heroes",
    jar_unit_set_infantry = "Infantry",
    jar_unit_set_artillery_war_machines = "Artillery and War Machines",
    jar_unit_set_cavalry_chariots = "Cavalry and Chariots",
    jar_unit_set_monsters = "Monsters"
}

local jar_stats = { 
    reload = { 
        display = "Reload Skill",
        description = "Positive values increase reload skill (decrease time taken by n%).\nNegative values decrease reload skill (increase time taken n%).",
        min = -100,
        max = 100,
    },
    accuracy = {
        display = "Accuracy", 
        description = "Positive values increase missile accuracy.\nNegative values decrease missile accuracy.",
        min = -100,
        max = 100,
    },
}

local mct = get_mct()
local mct_mod = mct:register_mod("jar_adjustable_missiles")
mct_mod:set_title("Jar's Adjustable Missiles")
mct_mod:set_description("Allows you to customize missiles units by category")
mct_mod:set_option_sort_function_for_all_sections("index_sort")

for set, set_display in pairs(jar_unit_sets) do
    local section = mct_mod:add_new_section(set, set_display, false)
    section:set_option_sort_function("index_sort")
    for stat, stat_cfg in pairs(jar_stats) do
        -- Ex: jar_unit_set_lords_heroes__accuracy
        -- Ex: jar_unit_set_infantry__reload
        local opt = mct_mod:add_new_option(set .. "__".. stat, "slider")
        opt:set_text(stat_cfg.display)
        opt:slider_set_min_max(stat_cfg.min, stat_cfg.max)
        opt:slider_set_step_size(1)
        opt:set_default_value(0)
    end
end

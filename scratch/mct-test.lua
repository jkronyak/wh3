
local SETS_CFG = {{
    set = "jar_unit_set_global",
    display = "Global",
    desc = "Applies to every unit.",
}, {
    set = "jar_unit_set_characters",
    display = "Characters",
    desc = "Applies to every lord or hero unit.",
}, {
    set = "jar_unit_set_artillery_war_machines",
    display = "Artillery/War Machines",
    desc = "Applies to every artillery or war machine unit.",
}, {
    set = "jar_unit_set_single_entities",
    display = "Single Entities",
    desc = "Applies to every single-entity unit, except for characters, war machines, and artillery."
}, {
    set = "jar_unit_set_infantry",
    display = "Infantry",
    desc = "Applies to every non-monstrous infantry unit.",
}, {
    set = "jar_unit_set_monstrous",
    display = "Monstrous",
    desc = "Applies to every multi-entity monster or monstrous unit."
}, {
    set = "jar_unit_set_cavalry_chariots",
    display = "Cavalry/Chariots",
    desc = "Applies to every cavalry/chariot unit."
}}

local STATS_CFG = {{
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
},
{
    stat = "missile_damage_mod_add",
    display = "Base Damage (Flat)",
    min = -100,
    max = 500,
    desc = "Modify non-AP missile damage by n flat. Higher values = more damage.",
},
{
    stat = "missile_damage_ap_mod_add",
    display = "AP Damage (Flat)",
    min = -100,
    max = 500,
    desc = "Modify AP missile damage by n flat. Higher values = more damage.",
},
{
    stat = "missile_explosion_radius",
    display = "Explosion Radius",
    min = -100,
    max = 500,
    desc = "Modify missile explosion radius by n%, if the unit has explosive damage. Higher values = larger radius."
}}

local GEN_SETTINGS ={
    { key = "enable_mod", type = "checkbox", display = "Enable Mod", desc = "Enabble or disable this mod's functionality." },
    { key = "apply_to_player", type = "checkbox", display = "Apply To Player", desc = "" },
    { key = "apply_to_ai", type = "checkbox", display = "Apply To AI", desc = "" },
    { key = "dev_logging", type = "checkbox", display = "Developer Logging", desc = "" },
}

local mct = get_mct()
local mod_title = "jar_adjustable_missiles_test"
local mct_mod = mct:register_mod(mod_title)

mct_mod:remove_settings_page(mct_mod:get_default_settings_page())
mct_mod:set_title(mod_title)
mct_mod:set_author("AceTheGreat")
mct_mod:set_workshop_id("3297164969")


--- Format: opt__<type>__<data1>__<data2>__<data3>
--- type = set_stat | core | set_link
---
--- Set Stat: opt__set_stat__ai__jar_unit_set_global__reload
--- Core: opt__core__enable_mod
--- Set Link: opt__set_link__jar_unit_set_global

local function create_set_stat_key(scope, set, stat)
    return "opt__set_stat__" .. scope .. "__" .. set .. "__" .. stat
end

local function create_core_key(action)
    return "opt__core__" .. action
end

local function create_set_link_key(set)
    return "opt__set_link__" .. set
end

local function split_str(inputstr, sep)
        local t = {}
        for field in string.gmatch(inputstr, "([^"..sep.."]*)"..sep.."?") do
                table.insert(t, field)
        end
        return t
end

local function decode_opt_key(key)
    local parts = split_str(key, "__")
    local prefix, type = parts[1], parts[2]
    if prefix ~= "opt" then return nil end

    if type == "set_stat" then
        return { type = type, scope = parts[3], set = parts[4], stat = parts[5] }
    elseif type == "core" then
        return { type = type, action = parts[3] }
    elseif type == "set_link" then
        return { type = type, set = parts[3] }
    else
        return nil
    end
end

for i, set in ipairs(SETS_CFG) do
    local page = mct_mod:create_settings_page(set.display, 2)
    if i == 1 then mct_mod:set_default_settings_page(page) end

    local section_human = mct_mod:add_new_section(set.set .. "__human", "    " .. set.display .. " - Human")
    section_human:set_is_collapsible(true)
    section_human:set_description(set.desc)

    local section_ai = mct_mod:add_new_section(set.set .. "__ai", "    " .. set.display .. " - AI")
    section_ai:set_is_collapsible(true)
    section_ai:set_collapsed(true)

    local opt_link_set = mct_mod:add_new_option(create_set_link_key(set.set), "checkbox")
    opt_link_set:set_default_value(true)
    section_ai:assign_option(opt_link_set)


    for j, stat in ipairs(STATS_CFG) do
        local opt_human = mct_mod:add_new_option(create_set_stat_key("human", set, stat), "slider")
        opt_human:set_text(stat.display)
        opt_human:set_tooltip_text(stat.desc)
        opt_human:slider_set_min_max(stat.min, stat.max)
        section_human:assign_option(opt_human)

        local opt_ai = mct_mod:add_new_option(create_set_stat_key("ai", set, stat), "slider")
        opt_ai:set_text(stat.display)
        opt_ai:set_tooltip_text(stat.desc)
        opt_ai:slider_set_min_max(stat.min, stat.max)
        opt_ai:set_locked(true, "Reusing human values for AI.")
        section_ai:assign_option(opt_ai)
    end

    section_human:assign_to_page(page)
    section_ai:assign_to_page(page)




end

for i, unit_set in ipairs(SETS_CFG) do
    local page = mct_mod:create_settings_page(unit_set.display, 2)

    if i == 1 then mct_mod:set_default_settings_page(page) end

    local section_left = mct_mod:add_new_section(unit_set.set .. "__left", unit_set.display)
    section_left:set_is_collapsible(true)
    local section_right = mct_mod:add_new_section(unit_set.set .. "__right", "AI Opts")
    section_right:set_is_collapsible(true)
    section_right:set_collapsed(true)
    section_left:set_description(unit_set.desc)
    local reuse_opt = mct_mod:add_new_option("REUSE__" .. unit_set.set, "checkbox")
    reuse_opt:set_default_value(true)
    section_right:assign_option(reuse_opt)
    
    for j, unit_stat in ipairs(STATS_CFG) do
        local opt = mct_mod:add_new_option(unit_set.set .. "__" .. unit_stat.stat, "slider")
        opt:slider_set_min_max(unit_stat.min, unit_stat.max)
        opt:set_text(unit_stat.display)
        opt:set_tooltip_text(unit_stat.desc)
        opt:set_default_value(0)
        section_left:assign_option(opt)
    end
    for j, unit_stat in ipairs(STATS_CFG) do
        local opt = mct_mod:add_new_option("AI__" .. unit_set.set .. "__" .. unit_stat.stat, "slider")
        opt:slider_set_min_max(unit_stat.min, unit_stat.max)
        opt:set_text(unit_stat.display)
        opt:set_tooltip_text(unit_stat.desc)
        opt:set_default_value(0)
        opt:set_locked(true, "Reusing player values")
        section_right:assign_option(opt)
    end

    section_left:assign_to_page(page)
    section_right:assign_to_page(page)
end

local page = mct_mod:create_settings_page("Misc. Settings", 2)
local section = mct_mod:add_new_section("misc", "Misc. Settings")
for i, gen_setting in ipairs(GEN_SETTINGS) do
    local opt = mct_mod:add_new_option(gen_setting.key, gen_setting.type)
    opt:set_text(gen_setting.display)
    opt:set_tooltip_text(gen_setting.desc)
    opt:set_default_value(true)
    section:assign_option(opt)
end
section:assign_to_page(page)

-- TODO: Spruce up logic, it works at a basic level
core:add_listener(
    "JAR_adjustable_missiles_MctOptionSelectedSettingSet",
    "MctOptionSelectedSettingSet",
    function(context)
        ---@type MCT.Option
        local opt = context:option()
        local key = opt:get_key()
        return key:sub(1, #"REUSE") == "REUSE"

    end,
    function(context)
        ---@type MCT.Option
        local opt = context:option()
        local val = opt:get_selected_setting()
        out("&&")
        out(val)
        local mod = opt:get_mod()
        local ai_opts = mod:get_options_by_section("jar_unit_set_global__right")
        for key, ai_opt in pairs(ai_opts) do
            if not (key:sub(1, #"REUSE") == "REUSE") then
                ai_opt:revert_to_default()
                ai_opt:set_locked(val, "Reusing")
            end
        end

    end,
    true
)
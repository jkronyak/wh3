-----------------------
--- Imports/Utility ---
-----------------------
local Logger = {}
local log_override = false

function Logger:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Logger:write(...)
    if self.enabled or log_override then
        local arg = { ... }
        local file = io.open("_" .. self.file_name .. ".jar.log", "a")
        if not file then
            out("Unable to create/open log file")
            return
        end
        if self.write_ts then
            local t = os.date("[%Y-%m-%d][%H:%M:%S] ")
            file:write(t)
        end
        for _, v in pairs(arg) do
            if type(v) == "string" then
                file:write(v)
            else
                file:write(tostring(v))
            end
            file:write(" ")
        end
        file:write("\n")
        file:close()
    end
end

local logger = Logger:new({ file_name = "jar_adjustable_missiles_mct", enabled = false, write_ts = true })
----------------------------
--- Settings Data Tables ---
----------------------------
local SETS_CFG = {
    { set = "jar_unit_set_global",     display = "Global",     desc = "Applies to every unit." },
    { set = "jar_unit_set_characters", display = "Characters", desc = "Applies to every lord or hero unit." }, {
    set = "jar_unit_set_artillery_war_machines",
    display = "Artillery/War Machines",
    desc = "Applies to every artillery or war machine unit."
}, {
    set = "jar_unit_set_single_entities",
    display = "Single Entities",
    desc = "Applies to every single-entity unit, except for characters, war machines, and artillery."
}, { set = "jar_unit_set_infantry", display = "Infantry", desc = "Applies to every non-monstrous infantry unit." }, {
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
    desc = "Modify non-AP missile damage by n flat. Higher values = more damage."
}, {
    stat = "missile_damage_ap_mod_add",
    display = "AP Damage (Flat)",
    min = -100,
    max = 500,
    desc = "Modify AP missile damage by n flat. Higher values = more damage."
}, {
    stat = "missile_explosion_radius",
    display = "Explosion Radius",
    min = -100,
    max = 500,
    desc = "Modify missile explosion radius by n%, if the unit has explosive damage. Higher values = larger radius."
}
}

local CORE_CFG = {
    {
        cmd = "enable_mod",
        type = "checkbox",
        display = "Enable Mod",
        desc = "Enable or disable this mod's functionality."
    }, { cmd = "apply_to_player", type = "checkbox", display = "Apply To Player", desc = "" },
    { cmd = "apply_to_ai",     type = "checkbox", display = "Apply To AI",       desc = "" },
    -- { cmd = "dev_logging",     type = "checkbox", display = "Developer Logging", desc = "" }
}

-----------------
--- MCT SETUP ---
-----------------
local mct = get_mct()
local mod_title = "jar_adjustable_missiles"
local mod_title_display = "Adjustable Missiles"
local mod_prefix = "jam"
local mct_mod = mct:register_mod(mod_title)

mct_mod:set_title(mod_title_display)
mct_mod:set_workshop_id("3297164969")
mct_mod:remove_settings_page(mct_mod:get_default_settings_page())
mct_mod:set_description("Allows you to customize missile units to your heart's content!")

----------------------
--- OPTION HELPERS ---
----------------------

local function split_str(input_str, sep)
    local t = {}
    for field in (input_str .. sep):gmatch("(.-)" .. sep) do table.insert(t, field) end
    return t
end

local function create_set_stat_key(scope, set, stat) return "opt__setstat__" .. scope .. "__" .. set .. "__" .. stat end
local function create_set_link_key(set) return "opt__setlink__" .. set end
local function create_core_key(cmd) return "opt__core__" .. cmd end

local function parse_option_key(key)
    local parts = split_str(key, "__")
    local prefix, cmd = parts[1], parts[2]
    if prefix ~= "opt" then
        logger:write("WARNING: while parsing option key", key, ": prefix is missing")
        return nil
    end

    if cmd == "setstat" then
        return { cmd = cmd, scope = parts[3], set = parts[4], stat = parts[5] }
    elseif cmd == "core" then
        return { cmd = cmd, action = parts[3] }
    elseif cmd == "setlink" then
        return { cmd = cmd, set = parts[3] }
    else
        logger:write("WARNING: while parsing option key", key, ": unknown cmd", cmd)
        return nil
    end
end

---@param option MCT.Option
local function parse_option_object(option)
    local key_data = parse_option_key(option:get_key())
    if key_data == nil then return nil end

    return { key = option:get_key(), value = option:get_selected_setting(), type = option:get_type(), data = key_data }
end

--------------------------
--- MCT Initialization ---
--------------------------
local function create_set_section(set_cfg)
    local section_human = mct_mod:add_new_section(set_cfg.set .. "__human", "     " .. set_cfg.display .. " - Human")
    section_human:set_is_collapsible(true)
    section_human:set_description(set_cfg.desc .. " Human settings.")
    -- local dummy_option = mct_mod:add_new_option(set_cfg.set .. "__DUMMY", "dummy")
    -- dummy_option:set_uic_visibility(false, true)
    -- section_human:assign_option(dummy_option)

    local section_ai = mct_mod:add_new_section(set_cfg.set .. "__ai", "     " .. set_cfg.display .. " - AI")
    section_ai:set_is_collapsible(true)
    section_ai:set_description(set_cfg.desc .. " AI settings.")

    local option_set_link = mct_mod:add_new_option(create_set_link_key(set_cfg.set), "checkbox")
    if not option_set_link then
        logger:write("ERROR: unable to create link set option for", set_cfg.set)
    else
        option_set_link:set_text("Using same settings as Human")
        option_set_link:set_default_value(true)
        option_set_link:add_confirmation_popup(
            function(new_val)
                local msg = new_val == false and "" or
                        "Warning:\n\nEnabling this setting will overwrite any AI-specific settings you had for " ..
                        set_cfg.display ..
                        " to match your human selections.\n\nAre you sure you want to proceed?"
                return new_val, msg
            end
        )
        section_ai:assign_option(option_set_link)
    end
    return section_human, section_ai
end

local function create_stat_option(set_cfg, stat_cfg, scope)
    local option = mct_mod:add_new_option(create_set_stat_key(scope, set_cfg.set, stat_cfg.stat), "slider")
    option:set_text(stat_cfg.display)
    option:set_tooltip_text(stat_cfg.desc)
    option:slider_set_min_max(stat_cfg.min, stat_cfg.max)
    option:set_default_value(0)
    if scope == "ai" then option:set_read_only(true, "Reusing human values for AI.") end
    return option
end

local function initialize_mct_settings()
    -- Create Unit Set-Stat Settings
    for i, set_cfg in ipairs(SETS_CFG) do
        local cur_page = mct_mod:create_settings_page(set_cfg.display, 2)
        if i == 1 then mct_mod:set_default_settings_page(cur_page) end

        local section_human, section_ai = create_set_section(set_cfg)

        for _, stat_cfg in ipairs(STATS_CFG) do
            section_human:assign_option(create_stat_option(set_cfg, stat_cfg, "human"))
            section_ai:assign_option(create_stat_option(set_cfg, stat_cfg, "ai"))
        end
        section_human:assign_to_page(cur_page)
        section_ai:assign_to_page(cur_page)
    end

    -- Create Miscellaneous Settings
    local misc_page = mct_mod:create_settings_page("Misc. Settings", 2)
    local misc_section = mct_mod:add_new_section(mod_prefix .. "__misc", "Misc. Settings")
    for _, core_cfg in ipairs(CORE_CFG) do
        local option = mct_mod:add_new_option(create_core_key(core_cfg.cmd), core_cfg.type)
        if not option then
            logger:write("ERROR: unable to create new msc option for", core_cfg.cmd)
        else
            option:set_text(core_cfg.display)
            option:set_tooltip_text(core_cfg.desc)
            option:set_default_value(true)
            misc_section:assign_option(option)
        end
    end
    misc_section:assign_to_page(misc_page)
end


----------------------
--- Listener Setup ---
----------------------

---@param set string
local function synchronize_set_settings(set)

    -- Retrieve all options related to the affected set
    local section_human = mct_mod:get_section_by_key(set .. "__human")
    local section_ai = mct_mod:get_section_by_key(set .. "__ai")

    local options_human = section_human:get_options()
    local options_ai = section_ai:get_options()

    local option_set_link = mct_mod:get_option_by_key(create_set_link_key(set))
    if not option_set_link then 
        logger:write("ERROR: could not find set_link option for", set)
        return
    end
    local link_state = option_set_link:get_selected_setting()
    -- If the set_link is enabled, then synchronize the AI settings to the human settings, and lock.
    -- If the set_link is disabled, then simply unlock all AI settings.
    if link_state then
        for _, human_option in pairs(options_human) do
            local human_option_data = parse_option_object(human_option).data
            local ai_option_key = create_set_stat_key("ai", set, human_option_data.stat)
            local ai_option = options_ai[ai_option_key]
            local lock_reason = ai_option:get_lock_reason()

            local human_value = human_option:get_selected_setting()
            local ai_value = ai_option:get_selected_setting()

            -- Only sync if the settings are not equal, to avoid unnecessary MCT operations.
            if human_value ~= ai_value then
                ai_option:set_read_only(false, lock_reason)
                ai_option:set_selected_setting(human_option:get_selected_setting())
            end
            ai_option:set_read_only(true, lock_reason)
        end
    else
        for _, ai_option in pairs(options_ai) do
            local lock_reason = ai_option:get_lock_reason()
            ai_option:set_read_only(false, lock_reason)
        end
    end
end

-- 250, 56, 126
-- 174, 0, 198
core:add_listener(
    "JAR__" .. mod_title .. "__MCT_setting_sync",
    "MctOptionSelectedSettingSet",
    function(context)
        local option_data = parse_option_object(context:option()).data
        return (
            (option_data.cmd == "setstat" and option_data.scope == "human")
            or
            (option_data.cmd == "setlink")
        )
    end,
    function(context)
        ---@type MCT.Option
        local option = context:option()
        local set = parse_option_object(option).data.set
        synchronize_set_settings(set)
    end,
    true
)

core:add_listener(
    "JAR__" .. mod_title .. "__MCT_setting_sync_init",
    "MctInitialized",
    true,
    function()
        for _, set_cfg in ipairs(SETS_CFG) do
            synchronize_set_settings(set_cfg.set)
        end
    end,
    false
)

initialize_mct_settings()

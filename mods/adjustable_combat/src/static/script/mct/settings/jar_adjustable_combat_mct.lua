-----------------------
--- Imports/Utility ---
-----------------------
local Logger = {}
local log_override = true

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

local logger = Logger:new({ file_name = "jar_adjustable_combat_mct", enabled = false, write_ts = true })
----------------------------
--- Settings Data Tables ---
----------------------------
local GLOBAL_SET = { set = "jar_unit_set_global", display = "Global", desc = "Includes every unit, and stacks with other categories." }

local CHARACTER_SET = {
        set = "jar_unit_set_characters",
        display = "Characters",
        desc = "Includes every lord or hero unit."
    }

local SETS_CFG = {
    {
        set = "jar_unit_set_artillery_war_machines",
        display = "Artillery/War Machines",
        desc = "Includes every artillery or war machine unit."
    },
    {
        set = "jar_unit_set_single_entities",
        display = "Single Entities",
        desc = "Includes every single entity unit, except characters, artillery, and war machines."
    },
    {
        set = "jar_unit_set_infantry",
        display = "Infantry", 
        desc = "Includes every infantry or monstrous infantry unit."
    },
    {
        set = "jar_unit_set_cavalry_chariots",
        display = "Cavalry/Chariots",
        desc = "Applies to every cavalry/chariot unit."
    }
}


local STATS_CFG = {
    {
        stat = "armour_mod",
        display = "armour_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "armour_mod_mult",
        display = "armour_mod_mult",
        min = -100,
        max = 500,
    },
    {
        stat = "battle_barrier_health",
        display = "battle_barrier_health",
        min = -100,
        max = 500,
    },
    {
        stat = "battle_barrier_health_mod",
        display = "battle_barrier_health_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "unit_damage_resistance_all_mod",
        display = "unit_damage_resistance_all_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "unit_damage_resistance_flame_mod",
        display = "unit_damage_resistance_flame_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "unit_damage_resistance_magic_mod",
        display = "unit_damage_resistance_magic_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "unit_damage_resistance_missile_mod",
        display = "unit_damage_resistance_missile_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "unit_damage_resistance_physical_mod",
        display = "unit_damage_resistance_physical_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "unit_fatigue_resistance_mod",
        display = "unit_fatigue_resistance_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "unit_mass_percentage_mod",
        display = "unit_mass_percentage_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "xp_gain_rate_mod",
        display = "xp_gain_rate_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "morale",
        display = "morale",
        min = -100,
        max = 500,
    },
    {
        stat = "morale_mult",
        display = "morale_mult",
        min = -100,
        max = 500,
    },
    {
        stat = "melee_attack_mod",
        display = "melee_attack_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "melee_attack_mod_mult",
        display = "melee_attack_mod_mult",
        min = -100,
        max = 500,
    },
    {
        stat = "melee_defence_mod",
        display = "melee_defence_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "melee_defence_mod_mult",
        display = "melee_defence_mod_mult",
        min = -100,
        max = 500,
    },
    {
        stat = "melee_damage_ap_mod_add",
        display = "melee_damage_ap_mod_add",
        min = -100,
        max = 500,
    },
    {
        stat = "melee_damage_ap_mod_mult",
        display = "melee_damage_ap_mod_mult",
        min = -100,
        max = 500,
    },
    {
        stat = "melee_damage_mod_add",
        display = "melee_damage_mod_add",
        min = -100,
        max = 500,
    },
    {
        stat = "melee_damage_mod_mult",
        display = "melee_damage_mod_mult",
        min = -100,
        max = 500,
    },
    {
        stat = "mod_land_movement_battle",
        display = "mod_land_movement_battle",
        min = -100,
        max = 500,
    },
    {
        stat = "missile_block_chance_mod",
        display = "missile_block_chance_mod",
        min = -100,
        max = 500,
    },
}

local STATS_GLOBAL_CFG = {
    {
        stat = "spell_mastery_percentage_mod",
        display = "spell_mastery_percentage_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "miscast_chance_mod",
        display = "miscast_chance_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "heal_power_percent_mod",
        display = "heal_power_percent_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "battle_healing_cap_mod",
        display = "battle_healing_cap_mod",
        min = -100,
        max = 500,
    },
    {
        stat = "morale_percentage_mod",
        display = "morale_percentage_mod",
        min = -100,
        max = 500,
    },
}

local STATS_CHARACTER_CFG = {
    {
        stat = "general_bodyguard_size_mod",
        display = "general_bodyguard_size_mod",
        min = -100,
        max = 500,
    },
}

local CORE_CFG = {
    {
        cmd = "enable_mod",
        type = "checkbox",
        display = "Enable Mod",
        desc = "Enable or disable this mod. Applied upon reload or next turn."
    },
    {
        cmd = "apply_to_player",
        type = "checkbox",
        display = "Apply To Player",
        desc = "Enable or disable this mod only for the player. Applied upon reload or next turn."
    },
    {
        cmd = "apply_to_ai",
        type = "checkbox",
        display = "Apply To AI",
        desc = "Enable or disable this mod only for the AI. Applied upon reload or next turn."
    },
    -- TODO: Add proper MCT option for logging.
    -- { cmd = "dev_logging",     type = "checkbox", display = "Developer Logging", desc = "" }
}

local STAT_LOCK_REASON = "Reusing Player values for AI"

-----------------
--- MCT SETUP ---
-----------------
local mct = get_mct()
local mod_title = "jar_adjustable_combat"
local mod_title_display = "Adjustable Missiles"
local mct_mod = mct:register_mod(mod_title)

mct_mod:set_title(mod_title_display)
mct_mod:remove_settings_page(mct_mod:get_default_settings_page())
mct_mod:set_description("Allows you to customize various stats for missile units!")

----------------------
--- OPTION HELPERS ---
----------------------

local function split_str(input_str, sep)
    local t = {}
    for field in (input_str .. sep):gmatch("(.-)" .. sep) do table.insert(t, field) end
    return t
end

local OPTION_SCHEMAS = {
    STAT = { "set", "stat", "scope" },
    LINK = { "set" },
    CORE = { "action" },
    CATSELECT = {}
}

local function create_option_key(cmd, data)
    local key = "opt__" .. cmd
    for _, value in ipairs(data) do
        key = key .. "__" .. tostring(value)
    end
    return key
end

local function parse_option_key(key)
    local parts = split_str(key, "__")
    local prefix, cmd = parts[1], parts[2]
    local schema = OPTION_SCHEMAS[cmd]

    local result = { cmd = cmd, data = {} }
    for i, field in ipairs(schema) do
        result.data[field] = parts[2 + i]
    end
    return result
end

---@param option MCT.Option
local function parse_option_object(option)
    return parse_option_key(option:get_key())
end

--------------------------
--- MCT Initialization ---
--------------------------

--- Option Helpers ---
local function create_stat_option(set_name, stat_config, scope)
    local option = mct_mod:add_new_option(create_option_key("STAT", { set_name, stat_config.stat, scope }), 'slider')
    option:set_text(stat_config.display)
    -- option:set_tooltip_text(stat_config.desc)
    option:set_tooltip_text("PLACEHOLDER")
    option:slider_set_min_max(stat_config.min, stat_config.max)
    option:set_default_value(0)
    return option
end

local function create_core_option(core_config)
    local option = mct_mod:add_new_option(create_option_key("CORE", { core_config.cmd }), core_config.type)
    option:set_text(core_config.display)
    option:set_tooltip_text(core_config.desc)
    option:set_default_value(true)
    return option
end

local function create_link_option(set_name)
    local option = mct_mod:add_new_option(create_option_key("LINK", { set_name }), 'checkbox')
    option:set_text("Use Player values for AI?")
    option:set_tooltip_text("When enabled, AI settings will be overwritten with the Player settings for this category.")
    option:set_default_value(true)
    return option
end

local function create_category_dropdown_option()
    local option = mct_mod:add_new_option(create_option_key("CATSELECT", {}), 'dropdown')
    option:set_text("Category")
    option:set_tooltip_text("Use this dropdown to switch which unit category you are viewing.")
    for _, set_config in ipairs(SETS_CFG) do
        option:add_dropdown_value(set_config.set, set_config.display, set_config.desc, false)
    end
    return option
end

local function create_dummy_option(text)
    local option = mct_mod:add_new_option("dummy", "dummy")
    option:set_text(text)
    return option
end

--- Section Helpers ---
local function create_global_set_sections(set_config)
    local player_section = mct_mod:add_new_section(set_config.set .. "__player", "Player")
    local ai_section = mct_mod:add_new_section(set_config.set .. "__ai", "AI")

    player_section:set_description(set_config.desc)
    ai_section:set_description(set_config.desc)

    if set_config.set == "jar_unit_set_global" then
        for _, stat_config in ipairs(STATS_GLOBAL_CFG) do
            player_section:assign_option(create_stat_option(set_config.set, stat_config, "player"))
            ai_section:assign_option(create_stat_option(set_config.set, stat_config, "ai"))
        end
    end

    if set_config.set == "jar_unit_set_characters" then
        for _, stat_config in ipairs(STATS_CHARACTER_CFG) do
            player_section:assign_option(create_stat_option(set_config.set, stat_config, "player"))
            ai_section:assign_option(create_stat_option(set_config.set, stat_config, "ai"))
        end
    end

    for _, stat_config in ipairs(STATS_CFG) do
        player_section:assign_option(create_stat_option(set_config.set, stat_config, "player"))
        ai_section:assign_option(create_stat_option(set_config.set, stat_config, "ai"))
    end

    return player_section, ai_section
end

local function create_link_section(set_name, set_display)
    local link_section = mct_mod:add_new_section(set_name .. "__link", set_display)
    link_section:set_description("Toggle whether to share the same values for Player and AI.")
    link_section:assign_option(create_link_option(set_name))
    return link_section
end

local function create_display_set_sections()
    local player_section = mct_mod:add_new_section("display__player", "Player")
    local ai_section = mct_mod:add_new_section("display__ai", "AI")

    player_section:set_description("Player settings for the selected category")
    ai_section:set_description("AI settings for the selected category.")

    for _, stat_config in ipairs(STATS_CFG) do
        player_section:assign_option(create_stat_option("display", stat_config, "player"))
        ai_section:assign_option(create_stat_option("display", stat_config, "ai"))
    end

    return player_section, ai_section
end

local function create_category_select_section()
    local dropdown_section = mct_mod:add_new_section("category_select", "Unit Category")
    dropdown_section:set_description("Use the dropdown to pick which category to modify.")
    dropdown_section:assign_option(create_category_dropdown_option())
    return dropdown_section
end

local function create_dummy_section(title, desc)
    title = title or " "
    desc = desc or " "
    local dummy_section = mct_mod:add_new_section("dummy", title)
    dummy_section:assign_option(create_dummy_option(desc))
    return dummy_section
end

--- Page Helpers ---
local function create_global_page()
    local page = mct_mod:create_settings_page("Global", 2)
    mct_mod:set_default_settings_page(page)
    local dummy_section = create_dummy_section("Global Settings", "These settings apply to all units.")
    local link_section = create_link_section(GLOBAL_SET.set, "Link Player/AI Settings")
    local player_section, ai_section = create_global_set_sections(GLOBAL_SET)
    dummy_section:assign_to_page(page)
    player_section:assign_to_page(page)
    link_section:assign_to_page(page)
    ai_section:assign_to_page(page)
end

local function create_characters_page()
    local page = mct_mod:create_settings_page("Characters", 2)
    mct_mod:set_default_settings_page(page)
    local dummy_section = create_dummy_section("Character Settings", "These settings apply to all units.")
    local link_section = create_link_section(CHARACTER_SET.set, "Link Player/AI Settings")
    local player_section, ai_section = create_global_set_sections(CHARACTER_SET)
    dummy_section:assign_to_page(page)
    player_section:assign_to_page(page)
    link_section:assign_to_page(page)
    ai_section:assign_to_page(page)
end

local function create_misc_page()
    local page = mct_mod:create_settings_page("Misc.", 2)
    local misc_section = mct_mod:add_new_section(mod_title .. "__misc", "Misc.")
    for _, core_config in ipairs(CORE_CFG) do
        misc_section:assign_option(create_core_option(core_config))
    end
    misc_section:assign_to_page(page)
end

local function create_category_actuals_page()
    local page = mct_mod:create_settings_page("Category Actuals", 2)

    for _, set_config in ipairs(SETS_CFG) do
        local link_section = create_link_section(set_config.set, set_config.display)
        local player_section, ai_section = create_global_set_sections(set_config)

        player_section:set_is_collapsible(true)
        player_section:set_collapsed(true)

        ai_section:set_is_collapsible(true)
        ai_section:set_collapsed(true)

        link_section:assign_to_page(page)
        player_section:assign_to_page(page)
        ai_section:assign_to_page(page)
    end
    page:set_visibility(false)
end

local function create_category_display_page()
    local page = mct_mod:create_settings_page("Unit Categories", 2)

    local category_select_section = create_category_select_section()
    local link_display_section = create_link_section("display", "Link Player/AI Settings")

    local player_display_section, ai_display_section = create_display_set_sections()

    category_select_section:assign_to_page(page)
    player_display_section:assign_to_page(page)
    link_display_section:assign_to_page(page)
    ai_display_section:assign_to_page(page)
end

local function initialize_mct_settings()
    create_global_page()
    create_characters_page()
    create_category_display_page()
    create_category_actuals_page()
    create_misc_page()
end

------------------------------
--- Listeners and Synching ---
------------------------------

--- Global Set Functions ---
--- @param player_option MCT.Option
local function sync_stat_global_player_to_ai(player_option)
    local player_global_option_data = parse_option_object(player_option).data
    local stat                      = player_global_option_data.stat
    local set = player_global_option_data.set
    local ai_global_option          = mct_mod:get_option_by_key(create_option_key("STAT", { set, stat, "ai" }))

    local player_global_value       = player_option:get_selected_setting()
    local ai_global_value           = ai_global_option:get_selected_setting()
    if player_global_value ~= ai_global_value then
        local locked = ai_global_option:is_locked()
        if locked then ai_global_option:set_locked(false, STAT_LOCK_REASON) end
        ai_global_option:set_selected_setting(player_global_value)
        ai_global_option:set_locked(locked, STAT_LOCK_REASON)
    end
end

---@param link_option MCT.Option
local function sync_link_global(link_option)
    local link_state = link_option:get_selected_setting()
    local link_state_option_data = parse_option_object(link_option).data
    local set = link_state_option_data.set
    if link_state then
        local player_global_options = mct_mod:get_section_by_key(set .. "__player"):get_options()

        for _, option in pairs(player_global_options) do
            sync_stat_global_player_to_ai(option)
        end
    end
    local ai_global_options = mct_mod:get_section_by_key(set .. "__ai"):get_options()
    for _, option in pairs(ai_global_options) do option:set_locked(link_state, STAT_LOCK_REASON) end
end


local function sync_display_to_actual(set_name)
    local actual_player_options = mct_mod:get_section_by_key(set_name .. "__player"):get_options()
    local actual_ai_options = mct_mod:get_section_by_key(set_name .. "__ai"):get_options()
    local actual_link_value = mct_mod:get_option_by_key(create_option_key("LINK", { set_name })):get_selected_setting()

    local display_link_option = mct_mod:get_option_by_key(create_option_key("LINK", { "display" }))

    -- Update the set link state
    if display_link_option:get_selected_setting() ~= actual_link_value then
        display_link_option:set_selected_setting(actual_link_value)
    end

    -- Update player values
    for _, option in pairs(actual_player_options) do
        local stat = parse_option_object(option).data.stat
        local display_option = mct_mod:get_option_by_key(create_option_key("STAT", { "display", stat, "player" }))
        local actual_value = option:get_selected_setting()
        logger:write("Synchronizing player", stat, actual_value, display_option:get_selected_setting())
        if display_option:get_selected_setting() ~= actual_value then
            display_option:set_selected_setting(actual_value)
        end
    end

    -- Update AI values
    for _, option in pairs(actual_ai_options) do
        local stat = parse_option_object(option).data.stat
        local display_option = mct_mod:get_option_by_key(create_option_key("STAT", { "display", stat, "ai" }))
        local actual_value = option:get_selected_setting()
        logger:write("Synchronizing ai", stat, actual_value, display_option:get_selected_setting())
        if display_option:get_selected_setting() ~= actual_value then
            display_option:set_selected_setting(actual_value)
        end
    end
end
--- @param stat_option MCT.Option
--- Updates the Actual Value to match the Display Value
local function sync_stat_display_to_actual(stat_option)
    local new_value = stat_option:get_selected_setting()
    local stat_option_data = parse_option_object(stat_option).data
    local stat = stat_option_data.stat
    local scope = stat_option_data.scope

    local category_dropdown_option = mct_mod:get_option_by_key(create_option_key("CATSELECT", {}))
    local set = category_dropdown_option:get_selected_setting()

    logger:write("Handling display stat change for", stat_option:get_key(), set, stat, scope)
    local actual_option = mct_mod:get_option_by_key(create_option_key("STAT", { set, stat, scope }))
    local cur_value = actual_option:get_selected_setting()
    logger:write("cur:", cur_value, "new:", new_value)
    if cur_value ~= new_value then
        actual_option:set_selected_setting(new_value)
    end
end

--- @param player_display_option MCT.Option
--- Updates the AI Display Value to match the Player Display Value
local function sync_stat_display_player_to_ai(player_display_option)
    local player_display_option_data = parse_option_object(player_display_option).data
    local stat                       = player_display_option_data.stat
    local ai_display_option          = mct_mod:get_option_by_key(create_option_key("STAT", { "display", stat, "ai" }))

    local player_display_value       = player_display_option:get_selected_setting()
    local ai_display_value           = ai_display_option:get_selected_setting()
    if player_display_value ~= ai_display_value then
        local locked = ai_display_option:is_locked()
        if locked then ai_display_option:set_locked(false, STAT_LOCK_REASON) end
        ai_display_option:set_selected_setting(player_display_value)
        ai_display_option:set_locked(locked, STAT_LOCK_REASON)
    end
end

--- @param link_option MCT.Option
--- Updates AI Display Values to match Player Display values when link is true.
--- Updates Actual Link Value.
local function sync_link_display_to_actual(link_option)
    local link_state = link_option:get_selected_setting()
    if link_state then
        local player_display_section = mct_mod:get_section_by_key("display__player")
        local player_display_options = player_display_section:get_options()

        for _, option in pairs(player_display_options) do
            sync_stat_display_player_to_ai(option)
        end
    end
    local ai_display_options = mct_mod:get_section_by_key("display__ai"):get_options()
    for _, option in pairs(ai_display_options) do option:set_locked(link_state, STAT_LOCK_REASON) end

    local set = mct_mod:get_option_by_key(create_option_key("CATSELECT", {})):get_selected_setting()
    local actual_link_option = mct_mod:get_option_by_key(create_option_key("LINK", { set }))
    if actual_link_option:get_selected_setting() ~= link_state then actual_link_option:set_selected_setting(link_state) end
end

local function initialize_mct_listeners()
    -- Synchronizes the display values to the actuals.
    core:add_listener(
        "JAR__" .. mod_title .. "__MCT_display_change",
        "MctOptionSelectedSettingSet",
        function(context)
            local option = context:option() ---@type MCT.Option
            if option:get_mod_key() ~= mod_title then return false end
            local option_decode = parse_option_object(option)
            return (option_decode.cmd == "LINK" or option_decode.cmd == "STAT")
                    and option_decode.data.set == "display"
        end,
        function(context)
            ---@type MCT.Option
            local option = context:option()
            local option_decode = parse_option_object(option)
            local option_cmd = option_decode.cmd
            if option_cmd == "LINK" then
                sync_link_display_to_actual(option)
            elseif option_cmd == "STAT" then
                sync_stat_display_to_actual(option)
            end
        end,
        true
    )

    -- Synchronizes the display values for the player and AI when linked
    core:add_listener(
        "JAR__" .. mod_title .. "__MCT_sync_display_stat_link",
        "MctOptionSelectedSettingSet",
        function(context)
            local option = context:option() ---@type MCT.Option
            if option:get_mod_key() ~= mod_title then return false end
            local option_decode = parse_option_object(option)
            local link_display_option = mct_mod:get_option_by_key(create_option_key("LINK", { "display" }))
            local link_state = link_display_option and link_display_option:get_selected_setting()
            return link_state
                    and option_decode.cmd == "STAT"
                    and option_decode.data.set == "display"
                    and option_decode.data.scope == "player"
        end,
        function(context)
            local option = context:option() ---@type MCT.Option
            sync_stat_display_player_to_ai(option)
        end,
        true
    )

    core:add_listener(
        "JAR__" .. mod_title .. "__MCT_category_dropdown",
        "MctOptionSelectedSettingSet",
        function(context)
            local option = context:option() ---@type MCT.Option
            if option:get_mod_key() ~= mod_title then return false end
            local option_decode = parse_option_object(option)
            return option_decode.cmd == "CATSELECT"
        end,
        function(context)
            ---@type MCT.Option
            local option = context:option()
            local selected_set = option:get_selected_setting()
            sync_display_to_actual(selected_set)
        end,
        true
    )

    core:add_listener(
        "JAR__" .. mod_title .. "__MCT_sync_global_stat_link",
        "MctOptionSelectedSettingSet",
        function(context)
            local option = context:option() ---@type MCT.Option
            if option:get_mod_key() ~= mod_title then return false end
            local option_decode = parse_option_object(option)
            return option_decode.cmd == "LINK" and (option_decode.data.set == GLOBAL_SET.set or option_decode.data.set == CHARACTER_SET.set)
        end,
        function(context)
            logger:write("IN HERE REEE")
            ---@type MCT.Option
            local option = context:option()
            sync_link_global(option)
        end,
        true
    )

    core:add_listener(
        "JAR__" .. mod_title .. "__MCT_global_sync",
        "MctOptionSelectedSettingSet",
        function(context)
            local option = context:option() ---@type MCT.Option
            if option:get_mod_key() ~= mod_title then return false end
            local option_decode = parse_option_object(option)
            if not option_decode.data.set and (option_decode.data.set == GLOBAL_SET.set or option_decode.data.set == CHARACTER_SET.data.set ) then return false end
            local set = option_decode.data.set
            local link_display_option = mct_mod:get_option_by_key(create_option_key("LINK", { set }))
            local link_state = link_display_option and link_display_option:get_selected_setting()
            return link_state
                    and option_decode.cmd == "STAT"
                    and option_decode.data.scope == "player"
        end,
        function(context)
            local option = context:option() ---@type MCT.Option
            sync_stat_global_player_to_ai(option)
        end,
        true
    )

    core:add_listener(
        "JAR__" .. mod_title .. "__MCT_initialization_sync",
        "MctInitialized",
        true,
        function(context)
            local global_link_option = mct_mod:get_option_by_key(create_option_key("LINK", {GLOBAL_SET.set}))
            sync_link_global(global_link_option)

            local char_link_option = mct_mod:get_option_by_key(create_option_key("LINK", {CHARACTER_SET.set}))
            sync_link_global(char_link_option)

            local display_link_option = mct_mod:get_option_by_key(create_option_key("LINK", { "display" }))
            sync_link_display_to_actual(display_link_option)

        end,
        true
    )
end

initialize_mct_listeners()
initialize_mct_settings()

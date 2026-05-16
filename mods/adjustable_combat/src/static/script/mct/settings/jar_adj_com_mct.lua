---@diagnostic disable: need-check-nil
------------------------------------------------------------------------
--- Module: Adjustable Combat MCT
--- Author: AceTheGreat
--- Description: MCT setup for Adjustable Combat
------------------------------------------------------------------------


------------------------------------------------------------------------
--- Imports and Configuration
------------------------------------------------------------------------
core:load_global_script("jar_adj_com_config")
local config = core:get_static_object("adj_com_config")

core:load_global_script("jar_adj_com_utils")
local utils = core:get_static_object("adj_com_utils")
mod_config = config.mod_config

local logger = core:get_static_object("adj_com_logger")

------------------------------------------------------------------------
--- MCT Setup
------------------------------------------------------------------------
local mct = get_mct()
local mct_mod = mct:register_mod(mod_config.mod_prefix)
mct_mod:set_title(mod_config.mod_title)
mct_mod:set_description(mod_config.mod_description)

-- Remove the default settings page so we can replace it later.
mct_mod:remove_settings_page(mct_mod:get_default_settings_page())


------------------------------------------------------------------------
--- MCT Creation Helpers
------------------------------------------------------------------------
local function create_dummy_section(unit_set_key)
    local unit_set_config = utils.get_unit_set(unit_set_key)
    local dummy_section = mct_mod:add_new_section("dummy__" .. unit_set_key, unit_set_config.display)
    local dummy_option = mct_mod:add_new_option("dummy__" .. unit_set_key, "dummy")
    dummy_option:set_text(unit_set_config.description)
    dummy_section:assign_option(dummy_option)
    return dummy_section
end

local function create_bv_option(option_config)
    local option = mct_mod:add_new_option(option_config.option_key, "slider")
    option:set_text(option_config.bonus_value.display)
    option:set_tooltip_text(option_config.bonus_value.description)
    option:slider_set_min_max(option_config.bonus_value.min, option_config.bonus_value.max)
    option:set_default_value(option_config.default)
    return option
end

local function create_link_option(option_config)
    local option = mct_mod:add_new_option(option_config.option_key, "checkbox")
    option:set_text("Link Player/AI Settings")
    option:set_tooltip_text("When enabled, AI settings will mirror the Player settings.")
    option:set_default_value(option_config.default)
    return option
end

local function create_misc_option(option_config)
    local option = mct_mod:add_new_option(option_config.option_key, "checkbox")
    option:set_text(option_config.display)
    option:set_tooltip_text(option_config.description)
    option:set_default_value(option_config.default)
    return option
end

------------------------------------------------------------------------
--- MCT Creation
------------------------------------------------------------------------

local function create_link_section(unit_set_key)
    local section = mct_mod:add_new_section(unit_set_key .. "__link", "Link Player/AI Settings")
    section:set_description("Toggle whether to share settings for Player and AI.")
    local option_config = utils.get_link_option_config(unit_set_key)
    section:assign_option(create_link_option(option_config))
    return section
end

--- Creates a new "static" section containing bonus value options.
--- Static means it does not rely on the mirroring to an actuals page.
local function create_static_bv_section(unit_set_key, scope, section_title)

    local section = mct_mod:add_new_section(unit_set_key .. "__" .. scope, section_title)
    for _, bonus_value_key in ipairs(utils.get_unit_set_bonus_value_keys(unit_set_key)) do
        local option_config = utils.get_bv_option_config(unit_set_key, bonus_value_key, scope)
        section:assign_option(create_bv_option(option_config))
    end
    return section
end

local function create_static_page(unit_set_key, page_title)
    local page = mct_mod:create_settings_page(page_title, 2)

    local dummy_section = create_dummy_section(unit_set_key)
    local link_section = create_link_section(unit_set_key)
    local player_section = create_static_bv_section(unit_set_key, "player", "Player")
    local ai_section = create_static_bv_section(unit_set_key, "ai", "AI")
    dummy_section:assign_to_page(page)
    player_section:assign_to_page(page)
    link_section:assign_to_page(page)
    ai_section:assign_to_page(page)
    return page
end


local function create_static_pages()
    -- Create the static Global page and make it default.
    local global_page = create_static_page("jar_adj_com_unit_set_global", "Global")
    mct_mod:set_default_settings_page(global_page)
    -- Create the static Characters page.
    create_static_page("jar_adj_com_unit_set_characters", "Characters")
end

------------------------------------------------------------------------
--- MCT Display/Actuals Setup
------------------------------------------------------------------------
local function create_categorical_bv_section(scope, section_title)
    local section = mct_mod:add_new_section("categorical__" .. scope, section_title)
    for _, bonus_value_key in ipairs(utils.get_unit_set_bonus_value_keys()) do
        local option_config = utils.get_bv_display_option_config(bonus_value_key, scope)
        section:assign_option(create_bv_option(option_config))
    end
    return section
end

local function create_dropdown_section()
    local section = mct_mod:add_new_section("categorical__dropdown", "Unit Category")
    section:set_description("Use the dropdown to choose a unit category.")
    local option_config = utils.get_dropdown_option_config()

    local option = mct_mod:add_new_option(option_config.option_key, "dropdown")
    option:set_text(option_config.display)
    option:set_tooltip_text("Use the dropdown to choose a unit category.")
    local dropdown_items = option_config.dropdown_items
    for unit_set_key, unit_set_config in pairs(dropdown_items) do
        option:add_dropdown_value(unit_set_config.key, unit_set_config.display, unit_set_config.description, false)
    end
    section:assign_option(option)
    return section
end

local function create_categorical_link_section()
    local section = mct_mod:add_new_section("categorical__link", "Link Player/AI Section")
    section:set_description("Toggle whether to share settings for Player and AI.")
    local option_config = utils.get_link_display_option_config()
    section:assign_option(create_link_option(option_config))
    return section
end

local function create_categorical_actuals_page()
    local page = mct_mod:create_settings_page("Category Actuals", 2)

    for unit_set_key, unit_set_config in pairs(config.unit_set_config) do
        if unit_set_key ~= "jar_adj_com_unit_set_global" and unit_set_key ~= "jar_adj_com_unit_set_characters" then
            local link_section = create_link_section(unit_set_key)
            local player_section = create_static_bv_section(unit_set_key, "player", "Player  " .. unit_set_config.display)
            local ai_section = create_static_bv_section(unit_set_key, "ai", "AI  " .. unit_set_config.display)

            player_section:set_is_collapsible(true)
            player_section:set_collapsed(true)

            ai_section:set_is_collapsible(true)
            ai_section:set_collapsed(true)

            link_section:assign_to_page(page)
            player_section:assign_to_page(page)
            ai_section:assign_to_page(page)
        end
    end
    -- page:set_visibility(false)
    return page
end


local function create_categorical_display_page()
    local page = mct_mod:create_settings_page("Unit Categories", 2)
    local dropdown_section = create_dropdown_section()
    local link_section = create_categorical_link_section()
    local player_section = create_categorical_bv_section("player", "Player")
    local ai_section = create_categorical_bv_section("ai", "AI")
    dropdown_section:assign_to_page(page)
    player_section:assign_to_page(page)
    link_section:assign_to_page(page)
    ai_section:assign_to_page(page)
end

local function create_misc_page()
    local page = mct_mod:create_settings_page("General", 1)
    local section = mct_mod:add_new_section("core", "General Settings")
    for misc_key, _ in pairs(config.misc_config) do
        section:assign_option(create_misc_option(utils.get_misc_option_config(misc_key)))
    end
    section:assign_to_page(page)
end

create_static_pages()
create_categorical_display_page()
create_categorical_actuals_page()
create_misc_page()

------------------------------------------------------------------------
--- MCT Option Helpers
------------------------------------------------------------------------
local function get_categorical_dropdown_value()
    local dropdown_option_key = utils.get_dropdown_option_config().option_key
    local dropdown_option = mct_mod:get_option_by_key(dropdown_option_key)
    local dropdown_option_value = dropdown_option:get_selected_setting()
    return dropdown_option_value
end

--- @param source MCT.Option
--- @param target MCT.Option
local function cascade_option_value(source, target)

    local source_value = source:get_selected_setting()
    local target_value = target:get_selected_setting()

    if source_value == target_value then return true end

    if target:is_locked() then
        local lock_reason = target:get_lock_reason()
        target:set_locked(false)
        target:set_selected_setting(source:get_selected_setting())
        target:set_locked(true, lock_reason)
    else
        target:set_selected_setting(source:get_selected_setting())
    end

end


--- @param option MCT.Option
local function is_mod_option(option)
    return option:get_mod_key() == mod_config.mod_prefix
end

------------------------------------------------------------------------
--- MCT Listeners
------------------------------------------------------------------------
core:add_listener(
    "JAR__" .. mod_config.mod_prefix .. "__MCT_player_option_sync",
    "MctOptionSelectedSettingSet",
    function(context)

        --- @type MCT.Option
        local option = context:option()
        
        -- Check that the option belongs to this mod.
        if not is_mod_option(option) then return false end

        -- Check that the option is for BV
        local option_data = utils.get_option_data(option)
        local command = option_data.command

        if command ~= "BV" or option_data.scope ~= "player" then return false end

        -- Check that the link setting is enabled for this set.

        local link_value = mct_mod:get_option_by_key(utils.create_link_option_key(option_data.unit_set_key)):get_selected_setting()
        if not link_value then return false end

        -- If all conditions pass (BV, player, linked) return true
        return true

    end,
    function(context)
        --- @type MCT.Option
        local option = context:option()

        local option_data = utils.get_option_data(option)
        local unit_set_key = option_data.unit_set_key
        local bonus_value_key = option_data.bonus_value_key

        local ai_option = mct_mod:get_option_by_key(utils.create_bv_option_key(unit_set_key, bonus_value_key, "ai"))

        cascade_option_value(option, ai_option)

    end,
    true
)

core:add_listener(
    "JAR__" .. mod_config.mod_prefix .. "__MCT_categorical_option_sync",
    "MctOptionSelectedSettingSet",
    function(context)

        --- @type MCT.Option
        local option = context:option()

        -- Check that the option belongs to this mod.
        if not is_mod_option(option) then return false end

        -- Check that the option is for BV
        local option_data = utils.get_option_data(option)
        local command = option_data.command

        if (command ~= "BV" and command ~= "LINK") or option_data.unit_set_key ~= "categorical" then return false end

        -- If all conditions pass (BV or LINK, categorical) return true
        return true

    end,
    function(context)
        --- @type MCT.Option
        local option = context:option()
        local value = option:get_selected_setting()

        local option_data = utils.get_option_data(option)
        local bonus_value_key = option_data.bonus_value_key

        -- If this is the categorical page, also cascade to actuals

        local dropdown_value = get_categorical_dropdown_value()

        local command = option_data.command

        if command == "BV" then
            local player_actual_option = mct_mod:get_option_by_key(utils.create_bv_option_key(dropdown_value, bonus_value_key, option_data.scope))

            cascade_option_value(option, player_actual_option)
        elseif command == "LINK" then
            local link_actual_option = mct_mod:get_option_by_key(utils.create_link_option_key(dropdown_value))

            cascade_option_value(option, link_actual_option)

        end
    end,
    true
)

core:add_listener(
    "JAR__" .. mod_config.mod_prefix .. "__MCT_link_sync",
    "MctOptionSelectedSettingSet",
    function(context)

        --- @type MCT.Option
        local option = context:option()

        if not is_mod_option(option) then return false end

        local option_data = utils.get_option_data(option)
        local command = option_data.command

        -- Check that this option is for the link state
        return command == "LINK"
    end,
    function(context)
        --- @type MCT.Option
        local option = context:option()
        local value = option:get_selected_setting()

        local option_data = utils.get_option_data(option)
        local unit_set_key = option_data.unit_set_key


        local bonus_value_keys = utils.get_unit_set_bonus_value_keys(unit_set_key)

        for _, bonus_value_key in ipairs(bonus_value_keys) do
            local player_option = mct_mod:get_option_by_key(utils.create_bv_option_key(unit_set_key, bonus_value_key, "player"))

            local ai_option = mct_mod:get_option_by_key(utils.create_bv_option_key(unit_set_key, bonus_value_key, "ai"))

            -- If link is enabled for the current set, synchronize settings and lock
            if value then
                cascade_option_value(player_option, ai_option)
                ai_option:set_locked(true, ai_option:get_lock_reason() or "Reusing Player values for AI")
            else 
                ai_option:set_locked(false)
            end
        end

    end,
    true
)

core:add_listener(
    "JAR__" .. mod_config.mod_prefix .. "__MCT_categorical_select_sync",
    "MctOptionSelectedSettingSet",
    function(context)

        --- @type MCT.Option
        local option = context:option()

        if not is_mod_option(option) then return false end

        local option_data = utils.get_option_data(option)
        local command = option_data.command

        -- Check that this option is for the link state
        return command == "CAT"
    end,
    function(context)
        --- @type MCT.Option
        local option = context:option()
        local unit_set_key = option:get_selected_setting()

        -- Cascade the link setting
        local cat_link_option = mct_mod:get_option_by_key(utils.create_link_option_key("categorical"))
        local act_link_option = mct_mod:get_option_by_key(utils.create_link_option_key(unit_set_key))
        cascade_option_value(act_link_option, cat_link_option)

        local bonus_value_keys = utils.get_unit_set_bonus_value_keys(unit_set_key)
        for _, bonus_value_key in ipairs(bonus_value_keys) do


            local cat_player_option = mct_mod:get_option_by_key(utils.create_bv_option_key("categorical", bonus_value_key, "player"))
            local cat_ai_option = mct_mod:get_option_by_key(utils.create_bv_option_key("categorical", bonus_value_key, "ai"))

            local act_player_option = mct_mod:get_option_by_key(utils.create_bv_option_key(unit_set_key, bonus_value_key, "player"))
            local act_ai_option = mct_mod:get_option_by_key(utils.create_bv_option_key(unit_set_key, bonus_value_key, "ai"))

            cascade_option_value(act_player_option, cat_player_option)
            cascade_option_value(act_ai_option, cat_ai_option)

        end
    end,
    true
)

--- TODO: Check this; AI generated
core:add_listener(
    "JAR__" .. mod_config.mod_prefix .. "_MCT_init_sync",
    "MctInitialized",
    true,
    function(context)
        -- 1. For each actual unit set, synchronize the value and lock state if the set is linked
        for unit_set_key, _ in pairs(config.unit_set_config) do
            local link_option = mct_mod:get_option_by_key(utils.create_link_option_key(unit_set_key))
            local link_value = link_option:get_selected_setting()

            for _, bonus_value_key in ipairs(utils.get_unit_set_bonus_value_keys(unit_set_key)) do
                local player_option = mct_mod:get_option_by_key(utils.create_bv_option_key(unit_set_key, bonus_value_key, "player"))
                local ai_option = mct_mod:get_option_by_key(utils.create_bv_option_key(unit_set_key, bonus_value_key, "ai"))

                if link_value then
                    cascade_option_value(player_option, ai_option)
                    ai_option:set_locked(true, ai_option:get_lock_reason() or "Reusing Player values for AI")
                else
                    ai_option:set_locked(false)
                end
            end
        end

        -- 2. Synchronize the categorical page to the actuals based on the dropdown value
        local unit_set_key = get_categorical_dropdown_value()
        if unit_set_key then
            local cat_link_option = mct_mod:get_option_by_key(utils.create_link_option_key("categorical"))
            local act_link_option = mct_mod:get_option_by_key(utils.create_link_option_key(unit_set_key))
            cascade_option_value(act_link_option, cat_link_option)

            for _, bonus_value_key in ipairs(utils.get_unit_set_bonus_value_keys(unit_set_key)) do
                local cat_player_option = mct_mod:get_option_by_key(utils.create_bv_option_key("categorical", bonus_value_key, "player"))
                local cat_ai_option     = mct_mod:get_option_by_key(utils.create_bv_option_key("categorical", bonus_value_key, "ai"))
                local act_player_option = mct_mod:get_option_by_key(utils.create_bv_option_key(unit_set_key, bonus_value_key, "player"))
                local act_ai_option     = mct_mod:get_option_by_key(utils.create_bv_option_key(unit_set_key, bonus_value_key, "ai"))

                cascade_option_value(act_player_option, cat_player_option)
                cascade_option_value(act_ai_option, cat_ai_option)
            end
        end
    end,
    false
)

--- TODO: 
---
--- Synchronize on link state change
--- 
--- Synchronize categorical on dropdown change
---
--- Synchronize lock state on initialization for every set
---     or synchronize lock state and
---
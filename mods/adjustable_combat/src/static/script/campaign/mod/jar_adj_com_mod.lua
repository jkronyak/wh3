---@diagnostic disable: need-check-nil
------------------------------------------------------------------------
--- Module: Adjustable Combat Mod
--- Author: AceTheGreat
--- Description: Mod functionality for Adjustable Combat
------------------------------------------------------------------------


------------------------------------------------------------------------
--- Imports and Configuration
------------------------------------------------------------------------
core:load_global_script("jar_adj_com_config")
local config = core:get_static_object("adj_com_config")

core:load_global_script("jar_adj_com_utils")
local utils = core:get_static_object("adj_com_utils")
local mod_config = config.mod_config

local logger = core:get_static_object("adj_com_logger")

local mod_settings = {
    bonus_value = {},
    core = {},
}

local effect_bundle_key = mod_config.mod_name .. "__effect_bundle"


---@param faction FACTION_SCRIPT_INTERFACE
local function should_apply_to_faction(faction)
    if faction:is_dead() or not mod_settings.core.enable_mod then return false end
    if faction:is_human() and not mod_settings.core.apply_to_player then return false end
    if (not faction:is_human()) and not mod_settings.core.apply_to_ai then return false end
    return true
end



local function load_mod_settings()

    local mct = get_mct()

    for unit_set_key, _ in pairs(utils.get_active_unit_set_configs()) do

        -- Ensure nested unit_set_key object exists
        mod_settings.bonus_value[unit_set_key] = mod_settings.bonus_value[unit_set_key] or {}

        for _, bonus_value_key in ipairs(utils.get_unit_set_bonus_value_keys(unit_set_key)) do

            -- Ensure nested bonus_value_key object exists
            mod_settings.bonus_value[unit_set_key][bonus_value_key] = mod_settings.bonus_value[unit_set_key][bonus_value_key] or {}

            local player_value = 0
            local ai_value = 0
            local player_option_config = utils.get_bv_option_config(unit_set_key, bonus_value_key, "player")
            local ai_option_config = utils.get_bv_option_config(unit_set_key, bonus_value_key, "ai")

            if mct then
                local mod = mct:get_mod_by_key(mod_config.mod_name)
                local player_option = mod:get_option_by_key(player_option_config.option_key)
                local ai_option = mod:get_option_by_key(ai_option_config.option_key)

                player_value = player_option:get_selected_setting()
                ai_value = ai_option:get_selected_setting()
            else
                player_value = player_option_config.default
                ai_value = ai_option_config.default
            end

            mod_settings.bonus_value[unit_set_key][bonus_value_key].player = player_value
            mod_settings.bonus_value[unit_set_key][bonus_value_key].ai = ai_value

        end
    
    end

    for misc_key, _ in pairs(config.misc_config) do
        local misc_option_config = utils.get_misc_option_config(misc_key)

        if mct then
            local mod = mct:get_mod_by_key(mod_config.mod_name)
            local option = mod:get_option_by_key(misc_option_config.option_key)
            mod_settings.core[misc_key] = option:get_selected_setting()
        else
            mod_settings.core[misc_key] = misc_option_config.default
        end
    end
end

local function create_mod_effect_bundle(scope)
    local effect_bundle = cm:create_new_custom_effect_bundle(effect_bundle_key)

    for unit_set_key, bonus_value_table in pairs(mod_settings.bonus_value) do
        for bonus_value_key, values in pairs(bonus_value_table) do
            local effect_scope = "faction_to_force_own"
            local value = values[scope]
            if value ~= 0 then
                local effect_string = mod_config.mod_name .. "__effect__" .. bonus_value_key .. "__" .. unit_set_key
                logger:debug("Applying", effect_string, "with value", value)

                if bonus_value_key == "general_bodyguard_size_mod" and unit_set_key == "jar_adj_com_unit_set_characters" then
                    -- Special case for Character HP, set scope to target only characters
                    effect_scope = "faction_to_character_own"
                end
                effect_bundle:add_effect(effect_string, effect_scope, value)
            end
        end
    end
    effect_bundle:set_duration(2)
    return effect_bundle
end

--- @param world WORLD_SCRIPT_INTERFACE
local function apply_mod_effects(world)

    local faction_list = world:faction_list()

    for i = 0, faction_list:num_items() - 1 do
        local faction = faction_list:item_at(i)
        if should_apply_to_faction(faction) then
            local effect_bundle = create_mod_effect_bundle(faction:is_human() and "player" or "ai")
            cm:apply_custom_effect_bundle_to_faction(effect_bundle, faction)
        elseif faction:has_effect_bundle(effect_bundle_key) then
            cm:remove_effect_bundle(effect_bundle_key, faction:name())
        end
    end
end

core:add_listener(
    "JAR__" .. mod_config.mod_prefix .. "_WorldStartRound",
    "WorldStartRound",
    true,
    function(ctx)
        load_mod_settings()
        local world = ctx:world()
        apply_mod_effects(world)
    end,
    true
)

cm:add_pre_first_tick_callback(function()
    if cm:is_game_running() then
        load_mod_settings()
        apply_mod_effects(cm:model():world())
    end
end)

core:add_listener(
    "JAR__" .. mod_config.mod_prefix .. "_MctInitialized",
    "MctInitialized",
    true,
    function()
        load_mod_settings()
    end,
    true
)

core:add_listener(
    "JAR__" .. mod_config.mod_prefix .. "_MctFinalized",
    "MctFinalized",
    true,
    function()
        load_mod_settings()
    end,
    true
)
-- -----------------------
-- --- Imports/Utility ---
-- -----------------------
-- core:load_global_script("jar_core/jar_logger")
-- local JAR_LOG = core:get_static_object("jar_logger")

local MOD_EB_NAME = "jar_adjustable_combat__effect_bundle"

-- local EFFECT_SCOPE = "faction_to_force_own"

-- local logger = JAR_LOG:new({ 
--     name = "jar_adjustable_combat",
--     enabled = true,
-- })


-- local function create_gen_effect_key(set, stat)
--     return "jar_adjustable_combat__effect__" .. stat .. "__" .. set
-- end

-- ----------------------
-- --- OPTION HELPERS ---
-- ----------------------
-- --- COPIED FROM MCT FILE

-- local function split_str(input_str, sep)
--     local t = {}
--     for field in (input_str .. sep):gmatch("(.-)" .. sep) do table.insert(t, field) end
--     return t
-- end

-- local OPTION_SCHEMAS = {
--     STAT = { "set", "stat", "scope" },
--     LINK = { "set" },
--     CORE = { "action" },
--     CATSELECT = {}
-- }

-- local function create_option_key(cmd, data)
--     local key = "opt__" .. cmd
--     for _, value in ipairs(data) do
--         key = key .. "__" .. tostring(value)
--     end
--     return key
-- end

-- local function parse_option_key(key)
--     local parts = split_str(key, "__")
--     local prefix, cmd = parts[1], parts[2]
--     local schema = OPTION_SCHEMAS[cmd] or {}

--     local result = { cmd = cmd, data = {} }
--     for i, field in ipairs(schema) do
--         result.data[field] = parts[2 + i]
--     end
--     return result
-- end

-- ---@param option MCT.Option
-- local function parse_option_object(option)
--     return parse_option_key(option:get_key())
-- end
-- --------------------------
-- --- OPTION HELPERS END ---
-- --------------------------

-- local all_settings = {}
-- local core_settings = {}
-- local stat_settings = {
--     ai = {},
--     player = {},
-- }
-- local set_link_settings = {}

-- ---@param mct_mod MCT.Mod
-- local function read_mct_values(mct_mod)
--     local mod_options = mct_mod:get_options()
--     logger:debug("There are", #mod_options, "options")
--     for key, option in pairs(mod_options) do
--         local option_data = parse_option_object(option)
--         local cmd = option_data.cmd
--         local value = option:get_selected_setting()

--         local data = option_data.data
--         data.value = value

--         if cmd == "CORE" then
--             core_settings[key] = data
--         elseif cmd == "STAT" then
--             local scope = option_data.data.scope
--             for k, v in pairs(data) do logger:debug(k, v) end
--             if data.set ~= "display" then stat_settings[scope][key] = data end
--         end
--     end
-- end

-- ---@param faction FACTION_SCRIPT_INTERFACE
local function should_apply_to_faction(faction)
    if faction:is_dead() or not core_settings.opt__CORE__enable_mod.value then return false end
    return (faction:is_human() and core_settings.opt__CORE__apply_to_player.value)
        or (not faction:is_human() and core_settings.opt__CORE__apply_to_ai.value)
end

-- ---------------------
-- --- FUNCTIONALITY ---
-- ---------------------

local function create_effect_bundle(scope)
    logger:debug("In create_effect_bundle", scope)
    local effect_bundle = cm:create_new_custom_effect_bundle(MOD_EB_NAME)
    for option_key, option_data in pairs(stat_settings[scope]) do
        local set = option_data.set
        local stat = option_data.stat
        local value = option_data.value
        logger:debug(set, stat, value)
        if value ~= 0 then

            --- 
            --- NOTES:
            --- Health increases are a little finicky; may need to apply this with a separate effect bundle with a longer duration.
            --- 999 duration seems stable; decrease applied at next turn.
            --- If above 100, characters need to heal
            --- Applying duration 2 with no callback correctly applies it immediately. NEVERMIND: On Karl Franz it did not apply at turn start?
            --- 
            --- 
            --- Duration 2, No Callback:
            ---     Malekith: 5x HP;
            ---     Skaven: Normal XP
            ---     Same behavior with add_pre_first_tick_callback
            ---     HP is set once battle loads, but lord is missing the difference between base and increase
            --- 
            --- Duration 2, With Callback:
            ---     Neither has new HP until battle starts; difference is missing
            --- 
            --- Duration 2, no Callback, post_first_tick_callback
            ---     Applies to Malekith, not AI
            --- 
            --- Reloading save applies it to the AI as well.
            --- 
            --- Using hard coded effects + scripted effect bundle has the same issue; maybe exclude this one for now?
            if stat == "general_bodyguard_size_mod" then
                local effect_string = "jar_adjustable_combat__effect__general_bodyguard_size_mod__jar_unit_set_characters"
--                 effect_bundle:add_effect(effect_string, EFFECT_SCOPE, value) -- faction_to_force_own WORKS
                -- effect_bundle:add_effect(effect_string, "faction_to_character_own", 500)
            else
                local effect_string = create_gen_effect_key(set, stat)
                effect_bundle:add_effect(effect_string, EFFECT_SCOPE, value)
            end
        end
    end
    effect_bundle:set_duration(2)
    return effect_bundle
end

-- ---@param world WORLD_SCRIPT_INTERFACE
-- local function apply_mod_effects(world)
--     logger:debug("In apply_mod_effects")
--     local faction_list = world:faction_list()
--     -- cm:callback(
--         -- function()
--             for i = 0, faction_list:num_items() - 1 do
--                 local faction = faction_list:item_at(i)
--                 if should_apply_to_faction(faction) then
--                     logger:debug("applying to", faction:name())
--                     local scope = faction:is_human() and "player" or "ai"
--                     local effect_bundle = create_effect_bundle(scope)
--                     cm:apply_custom_effect_bundle_to_faction(effect_bundle, faction)
--                 elseif faction:has_effect_bundle(MOD_EB_NAME) then
--                     logger:debug("Removing effect from", faction:name())
--                     cm:remove_effect_bundle(MOD_EB_NAME, faction:name())
--                 end
--             end
--         -- end,
--         -- 0.2
--     -- )
-- end

-- -----------------------
-- --- EVENT LISTENERS ---
-- -----------------------
-- core:add_listener(
--     "jar_adjustable_combat_WorldStartRound",
--     "WorldRoundStart",
--     true,
--     function(ctx)
--         logger:debug("WorldRoundStart")
--         apply_mod_effects(ctx:world())
--     end,
--     true
-- )

-- core:add_listener(
--     "jar_adjustable_combat_MctFinalized",
--     "MctFinalized",
--     true,
--     function(context)
--         logger:debug("MctFinalized")
--         local mct = context:mct()
--         local mct_mod = mct:get_mod_by_key("jar_adjustable_combat")
--         read_mct_values(mct_mod)
--     end,
--     true
-- )

-- core:add_listener(
--     "jar_adjustable_combat_MctInitialized",
--     "MctInitialized",
--     true,
--     function(context)
--         logger:debug("MctInitialized")
--         local mct = context:mct()
--         local mct_mod = mct:get_mod_by_key("jar_adjustable_combat")
--         read_mct_values(mct_mod)
--     end,
--     true
-- )

-- cm:add_first_tick_callback(function()
--     if cm:is_game_running() then
--         logger:debug("First tick callback")
--         apply_mod_effects(cm:model():world())
--     end
-- end)
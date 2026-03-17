-----------------------
--- Imports/Utility ---
-----------------------
local JAR_LOG = core:get_static_object("jar_logger")

local MOD_EB_NAME = "jar_adjustable_missiles__effect_bundle"

local EFFECT_SCOPE = "faction_to_force_own"

local logger = JAR_LOG:new({ 
    file_name = "jar_adjustable_missiles",
    enabled = false,
    write_ts = true
})

-- Helper Functions --
local function signed_string(n) return n > 0 and "+" .. n or tostring(n) end

---@param set string
---@param val string 
local function create_acc_effect_key(set, val)
    return "jar_adjustable_missiles__effect__acc__" .. set .. "__" .. signed_string(val)
end

local function create_dmg_effect_keys(set, stat)
    local str1 = "jar_adjustable_missiles__effect__" .. stat .. "__" .. set
    return str1, str1:gsub("missile_damage", "missile_explosion_damage")
end

local function create_gen_effect_key(set, stat)
    return "jar_adjustable_missiles__effect__" .. stat .. "__" .. set
end

----------------------
--- OPTION HELPERS ---
----------------------
--- COPIED FROM MCT FILE

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
    local schema = OPTION_SCHEMAS[cmd] or {}

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
--- OPTION HELPERS END ---
--------------------------

local all_settings = {}
local core_settings = {}
local stat_settings = {
    ai = {},
    player = {},
}
local set_link_settings = {}

---@param mct_mod MCT.Mod
local function read_mct_values(mct_mod)
    local mod_options = mct_mod:get_options()
    logger:write("There are", #mod_options, "options")
    for key, option in pairs(mod_options) do
        logger:write("Reading", key)
        local option_data = parse_option_object(option)
        local cmd = option_data.cmd
        local value = option:get_selected_setting()

        local data = option_data.data
        data.value = value

        if cmd == "CORE" then
            logger:write("Found CORE")
            core_settings[key] = data
        elseif cmd == "STAT" then
            local scope = option_data.data.scope
            logger:write("Found STAT", scope)
            for k, v in pairs(data) do logger:write(k, v) end
            if data.set ~= "display" then stat_settings[scope][key] = data end
        end
    end



    -- local mod_options = mct_mod:get_options()
    -- for key, option in pairs(mod_options) do
    --     local option_data = parse_option_object(option)
    --     local cmd = option_data.cmd
    --     local data = option_data.data
    --     data.value = option:get_finalized_setting()

    --     if cmd == "CORE" then
    --         logger:write("Reading CORE setting")
    --         core_settings[key] = data
    --     elseif cmd == "STAT" then
    --         logger:write("Reading STAT setting")
    --         for k, v in pairs(data) do logger:write(k, v) end
    --         stat_settings[option_data.data.scope][key] = data
    --     end
    -- end
end

---@param faction FACTION_SCRIPT_INTERFACE
local function should_apply_to_faction(faction)
    logger:write("should_apply_to_faction", faction:name())
    logger:write("is_dead", faction:is_dead())
    logger:write("is_human", faction:is_human())
    logger:write("opt__core__enable_mod", core_settings.opt__CORE__enable_mod.value)
    logger:write("opt__core__apply_to_player", core_settings.opt__CORE__apply_to_player.value)
        logger:write("opt__core__apply_to_ai", core_settings.opt__CORE__apply_to_ai.value)
    if faction:is_dead() or not core_settings.opt__CORE__enable_mod.value then return false end
    return (faction:is_human() and core_settings.opt__CORE__apply_to_player.value)
        or (not faction:is_human() and core_settings.opt__CORE__apply_to_ai.value)
end

---------------------
--- FUNCTIONALITY ---
---------------------

local function create_effect_bundle(scope)
    logger:write("In create_effect_bundle", scope)
    local effect_bundle = cm:create_new_custom_effect_bundle(MOD_EB_NAME)
    for option_key, option_data in pairs(stat_settings[scope]) do
        logger:write("Parsing option", option_data)
        for k, v in pairs(option_data) do logger:write(k, v) end
        local set = option_data.set
        local stat = option_data.stat
        local value = option_data.value
        logger:write(set, stat, value)
        if value ~= 0 then
            if stat == "accuracy" then
                local effect_string = create_acc_effect_key(set, value)
                effect_bundle:add_effect(effect_string, EFFECT_SCOPE, 1)
            elseif stat == "missile_damage_mod_mult" or stat == "missile_damage_ap_mod_mult" then
                local damage_effect_string, explosive_damage_effect_string = create_dmg_effect_keys(set, stat)
                effect_bundle:add_effect(damage_effect_string, EFFECT_SCOPE, value)
                effect_bundle:add_effect(explosive_damage_effect_string, EFFECT_SCOPE, value)
            else
                local effect_string = create_gen_effect_key(set, stat)
                effect_bundle:add_effect(effect_string, "faction_to_force_own", value)
            end
        end
    end
    effect_bundle:set_duration(1)
    return effect_bundle
end

---@param world WORLD_SCRIPT_INTERFACE
local function apply_mod_effects(world)
    logger:write("In apply_mod_effects")
    local faction_list = world:faction_list()
    cm:callback(
        function()
            for i = 0, faction_list:num_items() - 1 do
                local faction = faction_list:item_at(i)
                if should_apply_to_faction(faction) then
                    logger:write("Applying effect to", faction:name())
                    -- result = condition and value_if_true or value_if_false
                    local scope = faction:is_human() and "player" or "ai"
                    local effect_bundle = create_effect_bundle(scope)
                    cm:apply_custom_effect_bundle_to_faction(effect_bundle, faction)
                elseif faction:has_effect_bundle(MOD_EB_NAME) then
                    logger:write("Removing effect from", faction:name())
                    cm:remove_effect_bundle(MOD_EB_NAME, faction:name())
                end
            end
        end,
        0.2
    )
end

-----------------------
--- EVENT LISTENERS ---
-----------------------
core:add_listener(
    "JAR_adjustable_missiles_WorldStartRound",
    "WorldStartRound",
    true,
    function(ctx)
        logger:write("WorldStartRound")
        apply_mod_effects(ctx:world())
    end,
    true
)

core:add_listener(
    "JAR_adjustable_missiles_MctFinalized",
    "MctFinalized",
    true,
    function(context)
        logger:write("MctFinalized")
        local mct = context:mct()
        local mct_mod = mct:get_mod_by_key("jar_adjustable_missiles")
        read_mct_values(mct_mod)
    end,
    true
)

core:add_listener(
    "JAR_adjustable_missiles_MctInitialized",
    "MctInitialized",
    true,
    function(context)
        logger:write("MctInitialized")
        local mct = context:mct()
        local mct_mod = mct:get_mod_by_key("jar_adjustable_missiles")
        read_mct_values(mct_mod)
    end,
    true
)

cm:add_first_tick_callback(function()
    if cm:is_game_running() then
        logger:write("First tick callback")
        apply_mod_effects(cm:model():world())
    end
end)

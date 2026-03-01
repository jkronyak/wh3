local JAR_LOG = core:get_static_object("jar_logger")
local logger = JAR_LOG:new({ file_name = "jar_adjustable_missiles", enabled = true, write_ts = false })

local sets = { 
    "jar_unit_set_global",
    "jar_unit_set_characters",
    "jar_unit_set_artillery_war_machines",
    "jar_unit_set_single_entities",
    "jar_unit_set_infantry",
    "jar_unit_set_monstrous",
    "jar_unit_set_cavalry_chariots"
}

local stats = { "reload", "accuracy", "range_mod" }


local settings = {}
for _, set in ipairs(sets) do
    settings[set] = {}
end

local function signed_string(n)
    return n > 0 and "+" .. n or tostring(n)
end


local function apply_missile_effect(faction)
    local effect_bundle = cm:create_new_custom_effect_bundle('jar_adjustable_missiles__effect_bundle')
    for set, stats in pairs(settings) do
        for stat, value in pairs(stats) do
            logger:write("Appyling effect for", set, "and", stat)
            local signed_value = signed_string(value)
            if stat == 'accuracy' then
                local effect_str = "jar_adjustable_missiles__effect__acc__" .. set .. "__" .. signed_value
                logger:write("effect_str", effect_str)
                effect_bundle:add_effect(effect_str, "faction_to_force_own", 1)
            elseif stat == 'reload' then
                local effect_str = "jar_adjustable_missiles__effect__reload__" .. set
                logger:write("effect_str", effect_str)
                effect_bundle:add_effect(effect_str, "faction_to_force_own", value)
            elseif stat == "range_mod" then
                    local effect_str = "jar_adjustable_missiles__effect__range_mod__" .. set
                logger:write("effect_str", effect_str)
                effect_bundle:add_effect(effect_str, "faction_to_force_own", value)
            end
        end
    end
    effect_bundle:set_duration(1)
    cm:apply_custom_effect_bundle_to_faction(effect_bundle, faction)
end

core:add_listener(
    "JAR_adjustable_missiles_WorldStartRound",
    "WorldStartRound",
    true,
    function(ctx)
        logger:write("in WorldRoundStart listener")
        local world = ctx:world() -- WORLD_SCRIPT_INTERFACE
        local faction_list = world:faction_list()

        cm:callback(function()
            for i = 0, faction_list:num_items() - 1 do
                local faction = faction_list:item_at(i)
                if not faction:is_dead() then
                    logger:write("Faction", faction:name(), "is alive. Applying effect.")
                    apply_missile_effect(faction)
                end
            end
        end, 0.2)

    end,
    true
)


local function read_mct_values(mct_mod)
    for i, set in ipairs(sets) do
        for j, stat in ipairs(stats) do
            logger:write("reading", set, "and", stat)
            local opt = mct_mod:get_option_by_key(set .. "__" .. stat)
            settings[set][stat] = opt:get_finalized_setting()
        end
    end
end

core:add_listener(
    "JAR_adjustable_missiles_MctInitialized",
    "MctInitialized",
    true,
    function(context)
        local mct = context:mct()
        local mct_mod = mct:get_mod_by_key("jar_adjustable_missiles")
        logger:write("MCT_MOD", mct_mod)
        read_mct_values(mct_mod)
    end,
    true
)

core:add_listener(
    "JAR_adjustable_missiles_MctFinalizd",
    "MctFinalized",
    true,
    function(context)
        local mct = context:mct()
        local mct_mod = mct:get_mod_by_key("jar_adjustable_missiles")
        read_mct_values(mct_mod)
    end,
    true
)
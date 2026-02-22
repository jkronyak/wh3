local JAR_LOG = core:get_static_object("jar_logger")
local logger = JAR_LOG:new({ file_name = "jar_adjustable_missiles", enabled = true, write_ts = false })

local settings = {
    all_units = {
        accuracy = -10,
        reload = -100
    }
}

local function apply_accuracy_effect(faction)
    local effect_bundle = cm:create_new_custom_effect_bundle('jar_missile_debuff_eb')
    local acc_effect_str = "jar_missile_debuff_effect__accuracy__all" .. tostring(settings["all_units"]["accuracy"])
    logger:write("Adding", acc_effect_str, "effect")
--     effect_bundle:add_effect(acc_effect_str, 'faction_to_force_own', 1)
    
    -- testing here
    effect_bundle:add_effect("jar_missile_effect__accuracy__artillery_units-10", 'faction_to_force_own', 1)
    effect_bundle:add_effect("jar_missile_effect__accuracy__missile_infantry-10", 'faction_to_force_own', 1)
    
    local rel_effect_str = "jar_missile_debuff_effect__reload__all"
    logger:write("Adding", rel_effect_str, "effect")
    effect_bundle:add_effect(rel_effect_str, "faction_to_force_own", settings["all_units"]["reload"])
    
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
                    apply_accuracy_effect(faction)
                end
            end
        end, 0.2)

    end,
    true
)

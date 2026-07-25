----------------------------------------------------------------------------
--- Module: World Walkers Factionwide Sea Attacks
--- Author: AceTheGreat
--- Description: Logic for converting all World Walker armies to the custom
--- force type, allowing sea-based attacks.
----------------------------------------------------------------------------

core:load_global_script("jar_core/jar_logger")
local JARLOG = core:get_static_object("jar_logger")

local logger = JARLOG:new({
    enabled = false,
    append = false,
    name = "jar_norsca_tweaks",
    min_level = JARLOG.LEVELS.INFO,
})

local WW_FACTION_KEY = "wh_dlc08_nor_norsca"
local MF_TYPE_KEY = "JAR_MF_TYPE_WORLD_WALKERS"


local function is_faction_eligible(faction)
    return faction:name() == WW_FACTION_KEY
end

local function is_force_eligible(force)
    return
        is_faction_eligible(force:faction())
        and force:force_type():key() == "ARMY"
        and not force:is_armed_citizenry()
end

---@param force_list MILITARY_FORCE_LIST_SCRIPT_INTERFACE
local function convert_force_list(force_list)
    for i = 0, force_list:num_items() - 1 do
        local cur_force = force_list:item_at(i)
        if is_force_eligible(cur_force) then
            cm:convert_force_to_type(cur_force, MF_TYPE_KEY)
        end
    end
end

local function initialize()

    core:add_listener(
        "JAR_norsca_tweaks_MilitaryForceCreated",
        "MilitaryForceCreated",
        function(ctx)
            return is_force_eligible(ctx:military_force_created())
        end,
        function(ctx)
            cm:convert_force_to_type(ctx:military_force_created(), MF_TYPE_KEY)
        end,
        true
    )

    core:add_listener(
        "JAR_norsca_tweaks_FactionTurnStart",
        "FactionTurnStart",
        function(ctx)
            return is_faction_eligible(ctx:faction())
        end,
        function(ctx)
            convert_force_list(ctx:faction():military_force_list())
        end,
        true
    )

    core:add_listener(
        "JAR_norsca_tweaks_FactionJoinsConfederation",
        "FactionJoinsConfederation",
        function(ctx)
            return is_faction_eligible(ctx:confederation())
        end,
        function(ctx)
            local receiver_force_list = ctx:confederation():military_force_list()
            convert_force_list(receiver_force_list)
        end,
        true
    )
end

cm:add_first_tick_callback(initialize)
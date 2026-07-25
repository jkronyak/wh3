core:load_global_script("jar_core/jar_logger")
local JARLOG = core:get_static_object("jar_logger")


local jar_ww_sea_attack = {}



core:load_global_script("jar_core/jar_logger")
local JARLOG = core:get_static_object("jar_logger")

local logger = JARLOG:new({
    enabled = true,
    append = false,
    name = "jar_norsca_tweaks",
    min_level = JARLOG.LEVELS.DEBUG
})

local WW_FACTION_KEY = "wh_dlc08_nor_norsca"
local MF_TYPE_KEY = "JAR_MF_TYPE_WORLD_WALKERS"



core:add_listener(
    "JAR_norsca_tweaks_MilitaryForceCreated",
    "MilitaryForceCreated",
    function(ctx)
        ---@type MILITARY_FORCE_SCRIPT_INTERFACE
        local mil_force = ctx:military_force_created()
        local faction_name = mil_force:faction():name()
        return faction_name == WW_FACTION_KEY and mil_force:force_type():key() == "ARMY" and not mil_force:is_armed_citizenry()
    end,
    function(ctx)
        logger:debug("In JAR_norsca_tweaks_MilitaryForceCreated body")
        ---@type MILITARY_FORCE_SCRIPT_INTERFACE
        local mil_force = ctx:military_force_created()
        cm:convert_force_to_type(mil_force, MF_TYPE_KEY)
    end,
    true
)

core:add_listener(
    "JAR_norsca_tweaks_FactionTurnStart",
    "FactionTurnStart",
    function(ctx)
        return ctx:faction():name() == WW_FACTION_KEY
    end,
    function(ctx)
        ---@type FACTION_SCRIPT_INTERFACE
        local faction = ctx:faction()
        local mil_force_list = faction:military_force_list()
        for i = 0, mil_force_list:num_items() - 1 do
            local mil_force = mil_force_list:item_at(i)
            local force_type = mil_force:force_type():key()
            if force_type == "ARMY" and not mil_force:is_armed_citizenry() then
                cm:convert_force_to_type(mil_force, MF_TYPE_KEY)
            end
        end
    end,
    true
)

core:add_listener(
    "JAR_norsca_tweaks_FactionJoinsConfederation",
    "FactionJoinsConfederation",
    function(ctx)
        local owning_faction_name = ctx:confederation():name()
        return owning_faction_name == "wh_dlc08_nor_norsca"
    end,
    function(ctx)
        ---@type FACTION_SCRIPT_INTERFACE
        local faction1 = ctx:confederation()
        local mil_force_list = faction1:military_force_list()
        logger:debug("iterating confederation()", faction1:name())
        for i = 0, mil_force_list:num_items() - 1 do
            local mil_force = mil_force_list:item_at(i)
            local force_type = mil_force:force_type():key()
            if force_type == "ARMY" and not mil_force:is_armed_citizenry() then
                logger:debug("Found army to convert", i)
                cm:convert_force_to_type(mil_force, MF_TYPE_KEY)
            end
        end

        local faction2 = ctx:faction()
        local mil_force_list2 = faction2:military_force_list()
        logger:debug("iterating faction()", faction2:name())
        for i = 0, mil_force_list2:num_items() - 1 do
            local mil_force = mil_force_list2:item_at(i)
            local force_type = mil_force:force_type():key()
            if force_type == "ARMY" and not mil_force:is_armed_citizenry() then
                logger:debug("Found army to convert", i)
                cm:convert_force_to_type(mil_force, MF_TYPE_KEY)
            end
        end
    end,
    true
)

core:load_global_script("jar_core/jar_logger")
local JARLOG = core:get_static_object("jar_logger")

local logger = JARLOG:new({
    enabled = true,
    append = false,
    name = "TEST"
})

core:load_global_script("jar_core/jar_utils")
local jar_utils = core:get_static_object("jar_utils")

--- Checks whether the supplied region has a valid owner; optionally exclude rebels as a valid owner.
--- @param region REGION_SCRIPT_INTERFACE
--- @param excl_rebels boolean
local function is_region_owned(region, excl_rebels)
    excl_rebels = excl_rebels or false
    -- logger:debug(region:name(), region:is_abandoned())
    return
        not region:is_abandoned() -- Region must not be abandoned
        and region:owning_faction() -- Region must be owned
        and not region:owning_faction():is_null_interface() -- Owner must not be null interfact
        and (not excl_rebels or region:owning_faction():name() ~= "rebels")
end

local function get_sea_region_to_factions()
    local result = {}
    local faction_list = cm:model():world():faction_list()
    local sea_region_manager = cm:model():world():sea_region_manager()

    for i = 0, faction_list:num_items() - 1 do
        local faction = faction_list:item_at(i)
        local sea_region_list = sea_region_manager:faction_sea_region_list(faction:name())

        for j = 0, sea_region_list:num_items() - 1 do
            
            local sea_region = sea_region_list:item_at(j) ---@type SEA_REGION_SCRIPT_INTERFACE
            local sea_region_name = sea_region:name()

            if not result[sea_region_name] then result[sea_region_name] = {} end

            local pred = function(f) return f:name() == faction:name() end
            if not jar_utils.contains(result[sea_region_name], pred) then
                table.insert(result[sea_region_name], faction)
            end
        end
    end

    return result

end

--- @param faction FACTION_SCRIPT_INTERFACE
local function get_faction_sea_neighbors(faction)

    local result = {}
    local visited = { [faction:name()] = true }
    local sea_region_manager = cm:model():world():sea_region_manager()

    local sea_region_to_faction_map = get_sea_region_to_factions()


    local sea_region_list = sea_region_manager:faction_sea_region_list(faction:name())

    for i = 0, sea_region_list:num_items() - 1 do
        local sea_region = sea_region_list:item_at(i) ---@type SEA_REGION_SCRIPT_INTERFACE
        local sea_region_name = sea_region:name()

        local faction_list = sea_region_to_faction_map[sea_region_name]
        for _, cur_faction in ipairs(faction_list) do

            if not visited[cur_faction:name()] then
                table.insert(result, cur_faction)
                visited[cur_faction:name()] = true
            end
        end
    end

    return result

end

---@param initial_faction FACTION_SCRIPT_INTERFACE
---@param degrees integer
local function get_adjacent_factions_n_degrees(initial_faction, degrees)

    local result = {}
    local visited = { [initial_faction:name()] = true }
    local cur_faction_list = { initial_faction }

    function process_faction(faction, next_faction_list)
        if not visited[faction:name()] then
            table.insert(next_faction_list, faction)
            table.insert(result, faction)
            visited[faction:name()] = true
        end
    end


    for _ = 1, degrees do
        local next_faction_list = {}

        for _, faction in pairs(cur_faction_list) do
            local adj_regions = cm:get_regions_adjacent_to_faction(faction, false)

            ---@param region REGION_SCRIPT_INTERFACE
            for r_idx, region in pairs(adj_regions) do

                if is_region_owned(region, true) then
                    local region_owner = region:owning_faction()
                    process_faction(region_owner, next_faction_list)

                    -- Check if the current region_owner is a vassal
                    if region_owner:is_vassal() then
                        local master = region_owner:master()
                        process_faction(master, next_faction_list)
                    end
                end
            end

            -- Process sea region neighbors
            -- local sea_neighbors = get_faction_sea_neighbors
            for _, sea_neighbor in ipairs(get_faction_sea_neighbors(faction)) do
                process_faction(sea_neighbor, next_faction_list)
            end
        end
        cur_faction_list = next_faction_list
        if #cur_faction_list == 0 then break end
    end
    return result
end

local human_factions = cm:get_human_factions()

for i = 1, #human_factions do
    local faction_name = human_factions[i]
    local faction = cm:get_faction(faction_name)

    logger:debug(faction:name())
    local adjacent_factions = get_adjacent_factions_n_degrees(faction, 1)
    for j = 1, #adjacent_factions do
        logger:debug(j, adjacent_factions[j]:name())
    end

    -- get_faction_sea_neighbors(faction)

end



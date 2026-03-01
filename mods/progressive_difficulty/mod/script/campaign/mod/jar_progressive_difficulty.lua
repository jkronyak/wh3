local JAR_LOG = core:get_static_object("jar_logger")
local logger = JAR_LOG:new({ file_name = "jar_pd_stats", enabled = true })

local function get_region_settlement_level(region)
    return region:settlement():primary_slot():building():building_level()
end

local STAT_ORDER = {
    "num_settlements",
    "num_provinces",
    "num_complete_provinces",
    "sum_settlement_tiers",

    "num_major_settlements_total",
    -- "num_major_settlements_t1",
    -- "num_major_settlements_t2",
    -- "num_major_settlements_t3",
    -- "num_major_settlements_t4",
    -- "num_major_settlements_t5",

    "num_minor_settlements_total",
    -- "num_minor_settlements_t1",
    -- "num_minor_settlements_t2",
    -- "num_minor_settlements_t3",
    -- "num_minor_settlements_t4",
    -- "num_minor_settlements_t5",
}


local function get_player_stats(faction)

    local stats = {
        name = faction:name(),
        num_settlements = 0,
        num_provinces = 0,
        num_complete_provinces = 0,
        sum_settlement_tiers = 0,

        num_major_settlements_total = 0,
        num_major_settlements_t0 = 0,
        num_major_settlements_t1 = 0,
        num_major_settlements_t2 = 0,
        num_major_settlements_t3 = 0,
        num_major_settlements_t4 = 0,
        num_major_settlements_t5 = 0,

        num_minor_settlements_total = 0,
        num_minor_settlements_t0 = 0,
        num_minor_settlements_t1 = 0,
        num_minor_settlements_t2 = 0,
        num_minor_settlements_t3 = 0,
        num_minor_settlements_t4 = 0,
        num_minor_settlements_t5 = 0,
    }

    local region_list = faction:region_list()
    stats.num_settlements = region_list:num_items()
    stats.num_provinces = faction:num_provinces()
    stats.num_complete_provinces = faction:num_complete_provinces()

    for i = 0, region_list:num_items() - 1 do
        local region = region_list:item_at(i)
        local level = get_region_settlement_level(region)
        stats.sum_settlement_tiers = stats.sum_settlement_tiers + level

        if region:is_province_capital() then
            local key = "num_major_settlements_t" .. level
            if stats[key] then
                stats[key] = stats[key] + 1
            end
            stats.num_major_settlements_total = stats.num_major_settlements_total + 1
        else
            local key = "num_minor_settlements_t" .. level
            if stats[key] then
                stats[key] = stats[key] + 1
            end
            stats.num_minor_settlements_total = stats.num_minor_settlements_total + 1
        end
    end

    return stats
end

local function log_player_stats(tbl)
    for _, k in ipairs(STAT_ORDER) do
        logger:write('\t', k, '=', tbl[k])
    end
end

local function log_ai_stats(tbl)
    table.sort(tbl, function(a, b)
        return a.sum_settlement_tiers > b.sum_settlement_tiers
    end)
    for i = 1, math.min(10, #tbl) do
        local cur = tbl[i]
        logger:write(string.format('\t[%s]', cur.name), cur.sum_settlement_tiers, cur.num_settlements)
    end

end

ai_faction_stats = { }


core:add_listener(
    "JAR_PD_HumanFactTurnStart",
    "FactionTurnStart",
    function(ctx)
        return ctx:faction():is_human() and cm:turn_number() > 1
    end,
    function(ctx)
        local faction = ctx:faction()
        local turn = cm:turn_number()
        logger:write(string.format('\n[T%s][%s]:', turn, faction:name()))
        logger:write('[HUMAN]:')
        local stats = get_player_stats(faction)
        log_player_stats(stats)
        logger:write('[AI TOP 10]:')
        log_ai_stats(ai_faction_stats)
        ai_faction_stats = { }
    end,
    true
)

core:add_listener(
    "JAR_PD_AIMajorFactTurnStart",
    "FactionTurnStart",
    function(ctx)
        local faction = ctx:faction()
        -- logger:write('JAR_PD_AIMajorFactTurnStart', faction:name(), faction:is_primary_faction())
        return (not faction:is_human()) and faction:is_primary_faction()
    end,
    function(ctx)
        local faction = ctx:faction()
        local stats = get_player_stats(faction)
        table.insert(ai_faction_stats, stats)
    end,
    true
)
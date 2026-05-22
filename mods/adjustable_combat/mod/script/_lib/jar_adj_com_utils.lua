

----------------------------------------------------------------------------
--- Module: Adjustable Combat Utils
--- Author: AceTheGreat
--- Description: Utilities and common functionality for Adjustable Combat
----------------------------------------------------------------------------



core:load_global_script("jar_core/jar_logger")
core:load_global_script("jar_adj_com_config")
core:load_global_script("jar_core/jar_utils")
local adj_com_config = core:get_static_object("adj_com_config")
local jar_utils = core:get_static_object("jar_utils")

------------------------------------------------------------------------
--- Logger Initialization; defaults to dummy object if jar_logger could
--- not be found.
------------------------------------------------------------------------
local JARLOG = core:get_static_object("jar_logger")

if not JARLOG then
    local mock_fn = function() end
    JARLOG = {
        LEVELS = { DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4 },
        new = function(self, _)
            return {
                debug = mock_fn,
                info = mock_fn,
                warn = mock_fn,
                error = mock_fn,
                write = mock_fn,
                set_level = mock_fn,
                enable = mock_fn,
                disable = mock_fn,
            }
        end
    }
end

local logger = JARLOG:new({
    enabled = true,
    append = false,
    name = adj_com_config.mod_config.mod_name,
    min_level = JARLOG.LEVELS.DEBUG
})

core:add_static_object("adj_com_logger", logger)


local adj_com_utils = {}
function adj_com_utils.get_unit_set(unit_set_key)
    return adj_com_config.unit_set_config[unit_set_key]
end

function adj_com_utils.get_bonus_value(bonus_value_key)
    return adj_com_config.bonus_value_config[bonus_value_key]
end

function adj_com_utils.get_misc_config(misc_key)
    return adj_com_config.misc_config[misc_key]
end

function adj_com_utils.create_bv_option_key(unit_set_key, bonus_value_key, scope)
    return "mct_" .. adj_com_config.mod_config.mod_prefix .. "_BV__" .. unit_set_key .. "__" .. bonus_value_key .. "__" .. scope
end

function adj_com_utils.create_link_option_key(unit_set_key)
    return "mct_" .. adj_com_config.mod_config.mod_prefix .. "_LINK__" .. unit_set_key
end

function adj_com_utils.create_misc_option_key(misc_option_key)
    return "mct_" .. adj_com_config.mod_config.mod_prefix .. "_MISC__" .. misc_option_key
end

function adj_com_utils.decode_option_key(option_key)
    local cleaned = string.gsub(option_key, "mct_" .. adj_com_config.mod_config.mod_prefix, "")
    local parts = jar_utils.split_str(cleaned, "__")
    local command = string.gsub(parts[1], "_", "")

    if command == "BV" then
        local unit_set_key = parts[2]
        local bonus_value_key = parts[3]
        local scope = parts[4]

        return
            command,
            {
                unit_set_key = unit_set_key,
                bonus_value_key = bonus_value_key,
                scope = scope
            }

    elseif command == "LINK" then
        local unit_set_key = parts[2]
        return
            command,
            {
                unit_set_key = unit_set_key
            }
    elseif command == "CAT" then
        return
            command,
            {}
    elseif command == "MISC" then
        return
            command,
            {}
    else
        return nil, {}
    end

end


--- @param option MCT.Option
function adj_com_utils.get_option_data(option)
    local option_key = option:get_key()
    local command, data = adj_com_utils.decode_option_key(option_key)

    if command == "BV" then
        local scope = data.scope or nil

        return {
            command = command,
            option_key = option_key,
            unit_set_key = data.unit_set_key,
            bonus_value_key = data.bonus_value_key,
            scope = scope
        }
    elseif command == "LINK" then
        return {
            command = command,
            option_key = option_key,
            unit_set_key = data.unit_set_key
        }
    elseif command == "CAT" then
        return {
            command = command,
            option_key = option_key
        }
    elseif command == "MISC" then
        return {
            command = command,
            option_key = option_key
        }
    else
        return { command = nil, option_key = nil }
    end

end

function adj_com_utils.get_bv_option_config(unit_set_key, bonus_value_key, scope)
    local unit_set_config = adj_com_utils.get_unit_set(unit_set_key)
    local bonus_value_config = adj_com_utils.get_bonus_value(bonus_value_key)
    local default = adj_com_config.mod_defaults.bonus_value[unit_set_key][bonus_value_key][scope]
    return {
        option_key = adj_com_utils.create_bv_option_key(unit_set_key, bonus_value_key, scope),
        default = default,
        unit_set = unit_set_config,
        bonus_value = bonus_value_config,
    }
end

function adj_com_utils.get_link_option_config(unit_set_key)
    local option_key = adj_com_utils.create_link_option_key(unit_set_key)
    local unit_set_config = adj_com_utils.get_unit_set(unit_set_key)
    local default = adj_com_config.mod_defaults.link[unit_set_key]
    return {
        option_key = option_key,
        unit_set = unit_set_config,
        default = default
    }
end

function adj_com_utils.get_misc_option_config(misc_key)
    local misc_config = adj_com_utils.get_misc_config(misc_key)
    local option_key = adj_com_utils.create_misc_option_key(misc_key)
    local default = adj_com_config.mod_defaults.misc[misc_key]
    return {
        option_key = option_key,
        misc_config = misc_config,
        default = default
    }
end

function adj_com_utils.get_unit_set_bonus_value_keys(unit_set_key)

    local unit_set_bonus_values = adj_com_config.bonus_value_mapping[unit_set_key] or {}
    local common_unit_set_bonus_values = adj_com_config.bonus_value_mapping["common"]

    local keys = {}
    for _, bonus_value_key in ipairs(unit_set_bonus_values) do table.insert(keys, bonus_value_key) end
    for _, bonus_value_key in ipairs(common_unit_set_bonus_values) do table.insert(keys, bonus_value_key) end

    return keys
end

function adj_com_utils.get_ordered_unit_set_configs()
    local unit_set_configs = {}
    for _, unit_set_key in ipairs(adj_com_config.unit_set_config) do
        local unit_set_config = adj_com_utils.get_unit_set(unit_set_key)
        table.insert(unit_set_configs, unit_set_config)
    end
    return unit_set_configs
end

function adj_com_utils.get_link_display_option_config()
    local option_key = adj_com_utils.create_link_option_key("categorical")
    return {
        option_key = option_key,
        default = true,
        display_value = true,
    }
end

function adj_com_utils.create_dropdown_option_key()
    return "mct_" .. adj_com_config.mod_config.mod_prefix .. "_CAT__"
end

function adj_com_utils.get_dropdown_option_config()
    local option_key = adj_com_utils.create_dropdown_option_key()
    local unit_set_configs = {}
    for unit_set_key, unit_set_config in pairs(adj_com_config.unit_set_config) do
        if not unit_set_config.static then unit_set_configs[unit_set_key] = unit_set_config end
    end
    return {
        option_key = option_key,
        display = "Unit Category",
        dropdown_items = unit_set_configs
    }
end

function adj_com_utils.get_bv_display_option_config(bonus_value_key, scope)

    local option_key = adj_com_utils.create_bv_option_key("categorical", bonus_value_key, scope)
    local bonus_value_config = adj_com_utils.get_bonus_value(bonus_value_key)
    return {
        option_key = option_key,
        bonus_value = bonus_value_config,
        default = 0,
        display_value = true,
    }
end

core:add_static_object("adj_com_utils", adj_com_utils)
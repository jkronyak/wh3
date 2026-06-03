
local jar_utils = {}

function jar_utils.split_str(input, delimiter)
    local parts = {}
    for field in (input .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(parts, field)
    end
    return parts
end

function jar_utils.filter(t, predicate)
    local result = {}
    for k, v in pairs(t) do
        if predicate(v, k) then
            result[k] = v
        end
    end
    return result
end

function jar_utils.contains(t, predicate)
    for k, v in pairs(t) do
        if type(predicate) == "function" and predicate(v, k) then
            return true
        elseif v == predicate then
            return true
        end
    end
    return false
end

function jar_utils.table_length(t)
    local c = 0
    for _ in pairs(t) do c = c + 1 end
    return c
end

core:add_static_object("jar_utils", jar_utils)
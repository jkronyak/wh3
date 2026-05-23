
local jar_utils = {}

function jar_utils.split_str(input, delimiter)
    local parts = {}
    for field in (input .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(parts, field)
    end
    return parts
end

core:add_static_object("jar_utils", jar_utils)
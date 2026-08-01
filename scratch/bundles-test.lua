
out("********HERE")
local function pr(str)
    console_print(tostring(str))
    out(tostring(str))
end

local faction = cm:get_local_faction()
local eb_list = faction:effect_bundles()

for i = 0, eb_list:num_items() - 1 do
    ---@type EFFECT_BUNDLE_SCRIPT_INTERFACE
    local bundle = eb_list:item_at(i)
    pr(bundle:key())
    local effect_list = bundle:effects()
    
    local k = bundle:key()
    -- if k == "jar_adjustable_combat__effect_bundle"
        -- or k == "jar_adjustable_missiles__effect_bundle" then
        for j = 0, effect_list:num_items() - 1 do
            local effect = effect_list:item_at(j)
            pr("\t " .. effect:key())
            pr("\t " .. effect:value())
            pr("\t " .. effect:scope())
        end
    -- end

end
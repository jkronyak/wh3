-- [User Interface] --
local function get_or_create_btn()
    out("[FUNC] get_or_create_btn")
    local ui_button_parent = find_uicomponent(
        core:get_ui_root(), "hud_campaign", "info_panel_holder", "primary_info_panel_holder", "info_panel_background",
            "CharacterInfoPopup", "character_info_parent", "porthole_top"
    )
    if not is_uicomponent(ui_button_parent) then
        out("Get or create button was called, but we couldn't find the parent!")
        return
    end
    local button_name = "jar_embed_select_button"
    local existing_button = find_uicomponent(ui_button_parent, button_name)
    if is_uicomponent(existing_button) then
        return existing_button
    else
        local btn = UIComponent(
            ui_button_parent:CreateComponent(button_name, "ui/templates/square_medium_button.twui.xml")
        )
        btn:SetImagePath("ui/skins/default/button_basic_active_purple.png")
        btn:SetCanResizeCurrentStateImageHeight(0, true)
        btn:SetCanResizeCurrentStateImageWidth(0, true)
        btn:SetCanResizeHeight(true)
        btn:SetCanResizeWidth(true)
        btn:ResizeCurrentStateImage(0, 32, 32)
        btn:Resize(32, 32, true)
        return btn
    end
end

local function populate_btn(btn)
    out("[FUNC] populate_btn")
    if not is_uicomponent(btn) then
        out("btn is falsy")
        return
    end
    local char_cqi = cm:get_campaign_ui_manager():get_char_selected_cqi()
    if not char_cqi or char_cqi == -1 then
        out("No character is selected")
        return
    end
    local char = cm:get_character_by_cqi(char_cqi)

    if not (char:is_embedded_in_military_force() or char:has_military_force()) then
        out("setting as active")
        btn:SetState("active")
        btn:SetVisible(true)
        out(hero_to_embed_cqi)
        if hero_to_embed_cqi == nil then
            out("hero_to_embed_cqi == nil")
            btn:SetTooltipText(
                "Click to select this hero. The hero will be embedded in the next owned army that you left click on.",
                    true
            )
            btn:SetImagePath("ui/skins/default/button_basic_active_purple.png")
        elseif hero_to_embed_cqi == char_cqi then
            out("hero_to_embed_cqi == char_cqi")
            btn:SetTooltipText("Click to deselect this hero.", true)
            btn:SetImagePath("ui/skins/default/button_basic_selected_purple.png")
        else
            out("hero_to_embed_cqi ~= nil")
            btn:SetState("inactive")
            btn:SetTooltipText("Another hero is already selected.", true)
            btn:SetImagePath("ui/skins/default/button_basic_inactive_purple.png")
        end
    else
        out("setting as inactive")
        btn:SetState("inactive")
        btn:SetVisible(false)
        btn:SetTooltipText("Do not click me!", true)
        btn:SetImagePath("ui/skins/default/button_basic_inactive_purple.png")
    end
end

-- [Logic] --
hero_to_embed_cqi = nil

-- Receives Character lord_char and Character hero_char
-- Embeds or re-embeds the hero_char into the military_force of lord_char by:
-- 1.   Copying the data for non-lord and non-hero units
-- 2.   Disbanding all of the non-lord and non-hero units
-- 3.   Embedding the hero into the army (now that it has room)
-- 4.   Recruit all of the units back into the army, adding experience, health state, and vanilla
--      upgrades at each step.
local function embed_hero_into_army(lord_char, hero_char)
    out("[FUNC] refresh_army_with_hero")
    -- If there is no hero_char, return.
    if not hero_char or hero_char:is_null_interface() then
        out("hero_char is falsy or is the null interface")
        return
    end

    local mf = lord_char:military_force()
    cm:embed_agent_in_force(hero_char, mf)
    hero_to_embed_cqi = nil
end

-- Sets/unsets the cqi variable for the hero to embed
local function handle_hero_selected()
    if hero_to_embed_cqi ~= nil then
        hero_to_embed_cqi = nil
        return
    end
    local char = cm:get_character_by_cqi(cm:get_campaign_ui_manager():get_char_selected_cqi())
    if not (char:is_embedded_in_military_force() or char:has_military_force() or char:is_wounded()) then
        hero_to_embed_cqi = char:cqi()
    end
end

local function handle_army_selected(context)
    if not hero_to_embed_cqi then
        return
    end
    local hero = cm:get_character_by_cqi(hero_to_embed_cqi)
    embed_hero_into_army(context:character(), hero)
end

-- LuaFormatter off
core:add_listener(
    "JarAdjArmiesCharSelected",
    "CharacterSelected",
    function(context)
        return (context:character():faction():is_human())
    end,
    function()
        populate_btn(get_or_create_btn())
        end,
    true
)

core:add_listener(
    "JarAdjArmiesArmySelected",
    "CharacterSelected",
    function(context)
        local char = context:character()
        return char:faction():is_human() and char:has_military_force()
    end,
    function(context)
        handle_army_selected(context)
    end,
    true
)

core:add_listener(
    "JarAdjArmiesBtnClicked",
    "ComponentLClickUp",
    function(context) return context.string == "jar_embed_select_button" end,
    function()
        handle_hero_selected()
        populate_btn(get_or_create_btn())
    end,
    true
)

-- LuaFormatter on
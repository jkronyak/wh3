
local function change_grom_start_pos()
    local eltharion_faction_key = 'wh2_main_hef_yvresse'
    local eltharion_faction = cm:get_faction(eltharion_faction_key)
    if cm:is_new_game() and (cm:model():campaign_name_key() == 'wh3_main_combi') and eltharion_faction:is_human() then

        -- intermediate teleport position
        local temp_pos = { 305, 382 }

        -- GROM STUFF
        local grom_faction_key = 'wh2_dlc15_grn_broken_axe'
        local grom_faction = cm:get_faction(grom_faction_key)

        local grom = grom_faction:faction_leader()
        local grom_pos = { grom:logical_position_x(), grom:logical_position_y() }
        local grom_hero = cm:get_closest_hero_to_position_from_faction(grom_faction, 0, 0)
        local grom_hero_pos = { grom_hero:logical_position_x(), grom_hero:logical_position_y() }
        local massif_orcal_key = 'wh3_main_combi_region_massif_orcal'
        -- Grom starting enemy
        local aquitaine_faction_key = 'wh3_main_brt_aquitaine'

        -- GORBAD STUFF
        local gorbad_faction_key = 'wh3_dlc26_grn_gorbad_ironclaw'
        local gorbad_faction = cm:get_faction(gorbad_faction_key)
        local gorbad = gorbad_faction:faction_leader()
        local gorbad_pos = { gorbad:logical_position_x(), gorbad:logical_position_y() }
        local gorbad_hero = cm:get_closest_hero_to_position_from_faction(gorbad_faction, 0, 0)
        local gorbad_hero_pos = { gorbad_hero:logical_position_x() , gorbad_hero:logical_position_y() }
        local black_crag_key = 'wh3_main_combi_region_black_crag'
        local karag_dron_key = 'wh3_main_combi_region_karag_dron'
        -- Gorbad starting enemy
        local scabby_faction_key = 'wh_main_grn_scabby_eye'


        -- Swap starting army and hero positions
        -- 1. Grom to intermediate point
        cm:teleport_to(cm:char_lookup_str(grom), temp_pos[1], temp_pos[2])
        -- 2. Gorbad to Grom's original position
        cm:teleport_to(cm:char_lookup_str(gorbad), grom_pos[1], grom_pos[2])
        -- 3. Grom to Gorbad's original position
        cm:teleport_to(cm:char_lookup_str(grom), gorbad_pos[1], gorbad_pos[2])


        -- 4. Grom hero to intermediate point
        cm:teleport_to(cm:char_lookup_str(grom_hero), temp_pos[1], temp_pos[2])
        -- 5. Gorbad hero to Grom hero original position
        cm:teleport_to(cm:char_lookup_str(gorbad_hero), grom_hero_pos[1], grom_hero_pos[2])
        -- 6. Grom hero to Gorbad hero original position
        cm:teleport_to(cm:char_lookup_str(grom_hero), gorbad_hero_pos[1], gorbad_hero_pos[2])


        -- Swap starting settlements
        cm:transfer_region_to_faction(massif_orcal_key, gorbad_faction_key)
        cm:transfer_region_to_faction(black_crag_key, grom_faction_key)
        cm:transfer_region_to_faction(karag_dron_key, grom_faction_key)
        cm:heal_garrison(cm:get_region(massif_orcal_key):cqi())
        cm:heal_garrison(cm:get_region(black_crag_key):cqi())
        cm:heal_garrison(cm:get_region(karag_dron_key):cqi())

        -- Swap starting wars
        cm:force_make_peace(grom_faction_key, aquitaine_faction_key)
        cm:force_make_peace(gorbad_faction_key, scabby_faction_key)

        cm:force_declare_war(grom_faction_key, scabby_faction_key, false, false)
        cm:force_declare_war(gorbad_faction_key, aquitaine_faction_key, false, false)

        -- Reset fog of war
        cm:reset_shroud(grom_faction)
        cm:reset_shroud(gorbad_faction)

    end
end
cm:add_first_tick_callback(function() change_grom_start_pos() end)
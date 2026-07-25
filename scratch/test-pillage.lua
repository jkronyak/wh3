
local MF_TYPE_KEY = "JAR_MF_TYPE_WORLD_WALKERS"

local cqi = cm:get_campaign_ui_manager():get_mf_selected_cqi()
console_print(cqi)
local mf = cm:get_military_force_by_cqi(cqi):force_type():key()
console_print(mf)

cm:convert_force_to_type(mf, MF_TYPE_KEY)

function nor_pillaging:spawn_army(character)
	local faction = character:faction()
	local faction_key = faction:name()
	local distance = 10
	local x, y = cm:find_valid_spawn_location_for_character_from_character(faction_key, cm:char_lookup_str(character), false, distance)
	if x > 0 then
		local bonus_size = cm:get_characters_bonus_value(character, "pillaging_force_size_mod")

		local ram = random_army_manager
		ram:remove_force("nor_pillage_army")
		ram:new_force("nor_pillage_army")
		ram:add_mandatory_unit("nor_pillage_army", "wh_main_nor_inf_chaos_marauders_0", 2)
		ram:add_mandatory_unit("nor_pillage_army", "wh_main_nor_cav_marauder_horsemen_0", 1)

		ram:add_unit("nor_pillage_army", "wh_main_nor_inf_chaos_marauders_0", 10)
		ram:add_unit("nor_pillage_army", "wh_main_nor_inf_chaos_marauders_1", 10)
		ram:add_unit("nor_pillage_army", "wh_dlc08_nor_inf_marauder_berserkers_0", 10)
		ram:add_unit("nor_pillage_army", "wh_main_nor_cav_marauder_horsemen_0", 5)

		local army_size = math.clamp(self.spawned_army_size + bonus_size, 1, 19)
		local unit_list = ram:generate_force("nor_pillage_army", army_size, false)
		local subtype = self.spawned_army_general_subtype
		if character:military_force():force_type():key() ~= "ARMY_PILLAGING" then
			cm:create_force_with_general(
				faction_key,
				unit_list,
				cm:model():world():region_manager():region_list():item_at(1):name(),
				x,
				y,
				"general",
				subtype,
				"",
				"",
				"",
				"",
				false,
				function(cqi)
                    local char = cm:get_character_by_cqi(cqi)
                    cm:convert_force_to_type(char:military_force(), "ARMY_PILLAGING")
					cm:apply_effect_bundle_to_characters_force(self.spawned_army_starting_bundle_key, cqi, 0)
					self:transfer_spoils_to_force(character, cqi)
				end
			)
		end
	end
end
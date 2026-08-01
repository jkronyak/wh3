-- local mr = assert(_G.memreader)


-- local address_mapping = {
--     -- { address = 0x1ed719e, offset = 1 },
--     { address = 0x239c6bf, offset = -1 }
-- }

-- local ai_address_mapping = {
--     -- ai_army_size = { address = 0x1ed71af, offset = 0 },
--     ai_army_size = { address = 0x239c6d0, offset = 0 },
-- }

-- local size = 40
-- local ai_size = 40
-- local base = mr.base -- ex: 0x0000000140000000

-- for name, addr in pairs(address_mapping) do
--     mr.write(mr.add(base, addr.address), addr.offset, mr.uint32(size))
-- end

-- for name, addr in pairs(ai_address_mapping) do
--     mr.write(mr.add(base, addr.address), addr.offset, mr.uint32(ai_size))
-- end



	core:add_listener(
		"jar_MilitaryForceCreated_pillaging",
		"MilitaryForceCreated",
		function(context)
			return context:military_force_created():force_type():key() == "ARMY_PILLAGING"
		end,
		function(context)
			local general_cqi = context:military_force_created():general_character():command_queue_index()
			local general_lookup = "character_cqi:" .. general_cqi
			cm:replenish_action_points(general_lookup, 0.5)
            cm:enable_movement_for_character(general_lookup)
		end,
		true
	)

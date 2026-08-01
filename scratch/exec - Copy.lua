-- -- local cqi = 573
-- -- -- local cqi = 569
-- -- local unit_cco = cco("CcoCampaignUnit", cqi)

-- -- local unit_details = unit_cco:Call("UnitDetailsContext")

-- -- local stat_list = unit_details:Call("StatList")

-- -- local stat_list_size = unit_cco:Call("StatList.Size")

-- -- -- console_print(tostring(stat_list_size))

-- -- -- local first_stat = unit_details:Call("StatList.FirstContext(Key==\"stat_accuracy\").Key")
-- -- -- local stat = unit_details:Call("StatList.At(0).Key")
-- -- -- console_print(tostring(unit_details:Call("StatList.At(0).Key")))
-- -- -- console_print(tostring(unit_details:Call("StatList.At(1).Key")))
-- -- -- console_print(tostring(unit_details:Call("StatList.At(2).Key")))
-- -- -- console_print(tostring(unit_details:Call("StatList.At(3).Key")))
-- -- -- console_print(tostring(unit_details:Call("StatList.At(4).Key")))
-- -- -- console_print(tostring(unit_details:Call("StatList.At(5).Key")))
-- -- -- console_print(tostring(unit_details:Call("StatList.At(6).Key")))
-- -- -- console_print(tostring(unit_details:Call("StatList.At(7).Key")))
-- -- -- console_print(tostring(unit_details:Call("StatList.At(8).Key")))
-- -- -- console_print(tostring(unit_details:Call("StatList.At(9).Key")))
-- -- -- console_print(tostring(unit_details:Call("StatList.At(10).Key")))
-- -- -- console_print(tostring(unit_details:Call("StatList.At(11).Key")))

-- -- local main_unit = unit_cco:Call("UnitRecordContext")

-- -- local default_proj_record = main_unit:Call("DefaultProjectileRecord.At(0)")

-- -- function print(str)
-- --     console_print(tostring(str))
-- -- end

-- -- -- print(default_proj_record:Call("BaseReloadTimeContext.MinValue"))
-- -- -- print(default_proj_record)

-- -- local cco_root = cco("CcoCampaignRoot", "")
-- -- local cco_projectile = cco_root:Call("DefaultDatabaseRecord('CcoProjectileRecord')")

-- -- print(unit_details:Call("BaseStatValueFromKey('stat_accuracy')"))

-- -- -- Wrapper for Lua Console mod ouput
-- -- function print(str)
-- --     console_print(tostring(str))
-- -- end

-- -- -- local cqi = 569 -- archer unit
-- -- local cqi = 573 -- huntsmen unit
-- -- local unit_cco = cco("CcoCampaignUnit", cqi)
-- -- local unit_details = unit_cco:Call("UnitDetailsContext")
-- -- print(unit_details:Call("BaseStatValueFromKey('stat_accuracy')"))
-- -- Outputs 10 when when land_units record uses default accuracy 10. Outputs 0 when land_units record uses accuracy -100.

-- -- Lua Console output wrapper
-- -- function print(str) console_print(tostring(str)) end
-- local cco_main_unit = cco("CcoMainUnitRecord", "wh2_dlc13_emp_inf_huntsmen_0")
-- local unit_details = cco_main_unit:Call("UnitDetailsContext")
-- local base_accuracy = unit_details:Call("BaseStatValueFromKey('stat_accuracy')")
-- out("ACCURACY")
-- out(base_accuracy)
-- -- Outputs 0 when land_units.accuracy is -100.
-- -- Outputs 10 when land_units.accuracy is 10.
-- -- Outputs 50 when land_units.accuracy is 50.
-- -- Outputs 999 when land_units.accuracy is 999.
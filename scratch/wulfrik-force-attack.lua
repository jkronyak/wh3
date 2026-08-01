
core:remove_listener("JAR_wulfrik_turn_1")
core:add_listener(
    "JAR_wulfrik_turn_1",
    "CharacterCompletedBattle",
    function(ctx)
        out("J**IN LISTENER")
        local faction = ctx:character():faction()
        out("**J" .. tostring(faction:name()))
        return faction:name() == "wh_dlc08_nor_norsca"
    end,
    function(ctx)
        cm:callback(
            function()
                out("J**ATTACKING")
                local character = ctx:character()
                local region = character:region()
                cm:attack_region(cm:char_lookup_str(character:cqi()), region:name())
            end,
            1
        )
    end,
    false
)

local function pr(v)
    console_print(tostring(v))
    out(tostring(v))
end


local function force_attack_lee(char)
    console_print("Forcing attack " .. pr(char) .. " to " .. char:region():name())
    cm:attack_region(cm:char_lookup_str(char), char:region():name())
end

core:add_listener(
    "JAR_WULFRIK_FACTION",
    "FactionBeginTurnPhaseNormal",
    function(context)
        local f = context:faction()
        return f:name() == "wh_dlc08_nor_norsca"
    end,
    function()
        pr("Adding listener")
        core:add_listener(
            "JAR_WULFRIK_CharacterPostBattleEnslave",
            "CharacterPostBattleEnslave",
            function(ctx)
                local f = ctx:character():faction()
                return f:name() == "wh_dlc08_nor_norsca"
            end,
            function(ctx)
                force_attack_lee(ctx:character())
            end,
            false
        )

        core:add_listener(
            "JAR_WULFRIK_CharacterPostBattleRelease",
            "CharacterPostBattleRelease",
            function(ctx)
                local f = ctx:character():faction()
                return f:name() == "wh_dlc08_nor_norsca"
            end,
            function(ctx)
                force_attack_lee(ctx:character())
            end,
            false
        )

        core:add_listener(
            "JAR_WULFRIK_CharacterPostBattleSlaughter",
            "CharacterPostBattleSlaughter",
            function(ctx)
                local f = ctx:character():faction()
                return f:name() == "wh_dlc08_nor_norsca"
            end,
            function(ctx)
                force_attack_lee(ctx:character())
            end,
            false
        )


    end,
    false
)
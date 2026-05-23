import fs from 'fs';
import path from 'path';

import { MOD_OUTPUT_PATH } from '../config/mod-config.ts';
import { BONUS_VALUE_CONFIG, UNIT_SET_CONFIG } from '../config/data-config.ts';
import { MOD_TITLE, MOD_NAME, MOD_PREFIX, MOD_DESCRIPTION } from '../config/mod-config.ts';

const MIN = -500;
const MAX = 500;

for (const bonusValue of Object.keys(BONUS_VALUE_CONFIG)) {


    BONUS_VALUE_CONFIG[bonusValue].min = BONUS_VALUE_CONFIG[bonusValue].min ?? MIN;
    BONUS_VALUE_CONFIG[bonusValue].max = BONUS_VALUE_CONFIG[bonusValue].max ?? MAX;;
    BONUS_VALUE_CONFIG[bonusValue].key = bonusValue;
};

for (const unitSet of Object.keys(UNIT_SET_CONFIG)) { 
    UNIT_SET_CONFIG[unitSet].key = unitSet;
};

type LuaValue =
    | string
    | number
    | boolean
    | null
    | undefined
    | LuaValue[]
    | { [key: string]: LuaValue };

function objectToLua(obj: LuaValue, indent = 0): string {
    const pad = "    ".repeat(indent);
    const innerPad = "    ".repeat(indent + 1);

    if (Array.isArray(obj)) {
        if (obj.length === 0) return "{}";
        const items = obj.map(v => `${innerPad}${objectToLua(v, indent + 1)}`);
        return `{\n${items.join(",\n")}\n${pad}}`;
    }

    if (typeof obj === "object" && obj !== null) {
        const entries = Object.entries(obj);
        if (entries.length === 0) return "{}";
        const lines = entries.map(([k, v]) => {
            const key = /^[a-zA-Z_][a-zA-Z0-9_]*$/.test(k) ? k : `["${k}"]`;
            return `${innerPad}${key} = ${objectToLua(v, indent + 1)},`;
        });
        return `{\n${lines.join("\n")}\n${pad}}`;
    }

    if (typeof obj === "string") return `"${obj.replace(/\\/g, "\\\\").replace(/"/g, '\\"')}"`;
    if (typeof obj === "boolean") return obj.toString();
    if (typeof obj === "number") return obj.toString();
    if (obj === null || obj === undefined) return "nil";

    return `"${String(obj)}"`;
}

const bonusValueMap: Record<string, any> = {
    common: [],
};
const bonusValueDefaults: Record<string, any> = {};
const coreDefaults = { 
    enable_mod: true,
    apply_to_ai: true,
    apply_to_player: true,
    enable_logging: false,
};
const linkDefaults: Record<string, any> = {};


for (const unitSet of Object.keys(UNIT_SET_CONFIG)) {
    if (!bonusValueDefaults[unitSet]) bonusValueDefaults[unitSet] = {};
    linkDefaults[unitSet] = true;
};

for (const [bonusValue, bonusValueConfig] of Object.entries(BONUS_VALUE_CONFIG)) {
    const targetUnitSets = Array.isArray(bonusValueConfig.unit_sets) && bonusValueConfig.unit_sets.length > 0
        ? bonusValueConfig.unit_sets
        : Object.keys(UNIT_SET_CONFIG);

    for (const unitSet of targetUnitSets) {
        if (!bonusValueDefaults[unitSet]) bonusValueDefaults[unitSet] = {};
        if (!bonusValueDefaults[unitSet][bonusValue]) bonusValueDefaults[unitSet][bonusValue] = {};
        for (const scope of ['player', 'ai']) {
            bonusValueDefaults[unitSet][bonusValue][scope] = 0;
        }
    }
};

for (const [bonusValueKey, bonusValueConfig] of Object.entries(BONUS_VALUE_CONFIG)) {
    if (Array.isArray(bonusValueConfig.unit_sets) && bonusValueConfig.unit_sets.length > 0) {
        for (const unitSetKey of bonusValueConfig.unit_sets) { 
            (bonusValueMap[unitSetKey] ??= []).push(bonusValueKey);
        }
    } else {
        (bonusValueMap.common ??= []).push(bonusValueKey);
    }
}

const modDefaults = { 
    bonus_value: bonusValueDefaults,
    link: linkDefaults,
    misc: coreDefaults
}

const luaTableString = `
------------------------------------------------------------------------
--- Module: Adjustable Missiles Config
--- Author: AceTheGreat
--- Description: Contains configuration for Adjustable Missiles
--- TODO: Replace much of the below configuration with localization.
------------------------------------------------------------------------

local adj_mis_config = {}

-----------------------------------------------------------------------------
--- General Configuration
-----------------------------------------------------------------------------
adj_mis_config.mod_config = { 
    mod_name = "${MOD_NAME}",
    mod_title = "${MOD_TITLE}",
    mod_prefix = "${MOD_PREFIX}",
    mod_description = "${MOD_DESCRIPTION}",
}

adj_mis_config.mod_overrides = { 
    static_only = false
}
-----------------------------------------------------------------------------
--- Unit Set Configuration
-----------------------------------------------------------------------------
adj_mis_config.unit_set_config = ${objectToLua(UNIT_SET_CONFIG)}
-----------------------------------------------------------------------------
--- Bonus Value Configuration
-----------------------------------------------------------------------------
adj_mis_config.bonus_value_config = ${objectToLua(Object.fromEntries(
    Object.entries(BONUS_VALUE_CONFIG).map(([key, value]) => [key, value])))}
-----------------------------------------------------------------------------
--- Unit Set - Bonus Value Mapping
-----------------------------------------------------------------------------
adj_mis_config.bonus_value_mapping = ${objectToLua(bonusValueMap)}
-----------------------------------------------------------------------------
--- Misc Setting Configuration
-----------------------------------------------------------------------------
adj_mis_config.misc_config = {
    enable_mod = {
        display = "Enable Mod",
        description = "Enable this mod's functionality.",
    },
    apply_to_player = {
        display = "Apply to Player",
        description = "Apply the configured effects to the player.",
    },
    apply_to_ai = {
        display = "Apply to AI",
        description = "Apply the configured effects to the AI",
    },
    --enable_logging = {
    --    display = "Enable Logging",
    --    description = "Enable developer logging.",
    --},
}
-----------------------------------------------------------------------------
--- Option Default Settings; can be overwritten here
-----------------------------------------------------------------------------
adj_mis_config.mod_defaults = ${objectToLua(modDefaults)}

core:add_static_object("adj_mis_config", adj_mis_config)
`;


const generateLua = async () => {
    const folderPath = path.join(MOD_OUTPUT_PATH, "script", "_lib");
    fs.mkdirSync(folderPath, { recursive: true });
    fs.writeFileSync(path.join(folderPath, "jar_adj_mis_config.lua"), luaTableString);};

export { generateLua };
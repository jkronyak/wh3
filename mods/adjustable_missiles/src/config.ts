import path from 'path';
const __dirname = import.meta.dirname;

export const parentGroupToUnitSet = { 
    commander: "jar_unit_set_lords_heroes",
    heroes_agents: "jar_unit_set_lords_heroes",
    campaign_exclusives: "jar_unit_set_lords_heroes",
    artillery_war_machines: "jar_unit_set_artillery_war_machines",
    flying_war_machine: "jar_unit_set_artillery_war_machines",
    cavalry_chariots: "jar_unit_set_cavalry_chariots",
    missile_cavalry_chariots: "jar_unit_set_cavalry_chariots",
    infantry: "jar_unit_set_infantry",
    missile_infantry: "jar_unit_set_infantry",
    missile_monster_beasts: "jar_unit_set_monsters",
    monster_beasts: "jar_unit_set_monsters",
    construct: "jar_unit_set_monsters",
};

export type ParentGroup = keyof typeof parentGroupToUnitSet;

export const modUnitSets = [...new Set (Object.values(parentGroupToUnitSet))].concat("jar_unit_set_global")

export const modUnitSetRecords = modUnitSets.map(set => ({
    key: set,
    use_unit_exp_level_range: false,
    min_unit_exp_level_inclusive: -1,
    max_unit_exp_level_inclusive: -1,
    special_category: ""
}))

export const MOD_DIR = path.join(__dirname, '../');

export const REF_PATH = path.join(MOD_DIR, "temp", "ref");

export const PATCH_MOD_PATH = path.join(MOD_DIR, "src", "patch-mods.json");

export const MOD_INPUT_PATH = path.join(MOD_DIR, "input");

export const MOD_OUTPUT_PATH = path.join(MOD_DIR, "mod");

export const MOD_DIST_PATH = path.join(MOD_DIR, "dist");

export const MOD_STATIC_PATH = path.join(MOD_DIR, "src", "static");
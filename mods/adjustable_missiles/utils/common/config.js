const parentGroupUnitSetMap = {
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

const modUnitSets = [...new Set(Object.values(parentGroupUnitSetMap))];

const unitSets = ["characters", ...modUnitSets];

// const unitCastExcludeList = ["lord", "hero"];
const unitCastExcludeList = [];

module.exports = {
    parentGroupUnitSetMap,
    unitSets,
    modUnitSets,
    unitCastExcludeList,
};

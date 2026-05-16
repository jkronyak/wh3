
import { MOD_UNIT_SETS } from "./config.ts";


const GLOBAL_ONLY_BONUS_VALUES = [
    {
        key: "battle_healing_cap_mod",
        display: "Battle Healing Cap",
        description: "",
    },
    {
        key: "heal_power_percent_mod",
        display: "Healing Power (+/-)",
        description: "Modify healing received by n. Base value is 100%.",
    },
    {
        key: "spell_mastery_percentage_mod",
        display: "Spell Mastery (+/-)",
        description: "Modify spell mastery by n. Base value is 100%.",
    },
    {
        key: "miscast_chance_mod",
        display: "Miscast Chance",
        description: "Modify miscast chance by n. Base value is x%.",
    },
    {
        key: "morale_percentage_mod",
        display: "Morale (%)",
        description: "",
    },
];

const UNIT_SET_BONUS_VALUES = [
    {
        key: "morale",
        display: "Morale (+)",
        description: "",
    },
];
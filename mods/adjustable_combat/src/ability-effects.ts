import 'dotenv/config';
import path from 'path';
import tsv from '../../../lib/helpers/tsv.ts';
import { MOD_UNIT_SETS, MOD_OUTPUT_PATH } from "./config.ts";
import { getOrCreateSession } from '../../../lib/rpfm-client/rpfm-client-instance.ts';
const client = await getOrCreateSession();

const UID_START = 644261121;

const ACC_MIN = -100;
const ACC_MAX = 200;

let curUid = UID_START;

const recordPrefix = `jar_adjustable_combat`;

type TableName =
    | "unit_abilities_tables"
    | "unit_special_abilities_tables"
    | "special_ability_phases_tables"
    | "special_ability_to_special_ability_phase_junctions_tables"
    | "special_ability_phase_stat_effects_tables"
    | "effects_tables"
    | "unit_set_unit_ability_junctions_tables"
    | "effect_bonus_value_unit_set_unit_ability_junctions_tables"
    | "effect_bonus_value_ids_unit_sets_tables"
    | "effect_bonus_value_basic_junction_tables"
    | "effect_bundles_tables"


const accSuf = (acc: number) => acc > 0 ? `+${acc}` : `${acc}`;


const singleRowGenerators: Partial<Record<TableName, Function>> = {
    effect_bundles_tables: () => ({
        key: `${recordPrefix}__effect_bundle`,
        localised_description: '',
        localised_title: '',
        bundle_target: 'faction',
        priority: '1',
        // ui_icon: 'jar_accuracy.png',
        ui_icon: '', // hide in UI
        is_global_effect: 'true',
        show_in_3d_space: 'false',
        owner_only: 'true'
    })
};

const otherStatRowGenerators: Partial<Record<TableName, Function>> = {
    effects_tables: (set: string, stat: string) => ({
        effect: `${recordPrefix}__effect__${stat}__${set}`,
        icon: 'general_ability.png',
        priority: 0,
        icon_negative: 'general_ability.png',
        category: 'campaign',
        is_positive_value_good: true
    }),
    effect_bonus_value_ids_unit_sets_tables: (set: string, stat: string) => ({
        bonus_value_id: stat,
        effect: `${recordPrefix}__effect__${stat}__${set}`,
        unit_set: set
    }),
    effect_bonus_value_basic_junction_tables: (set: string, stat: string) => ({
        effect: `${recordPrefix}__effect__${stat}__${set}`,
        bonus_value_id: stat,
    })
};


type TableResult = Partial<Record<TableName, Record<string, any>[]>>;

const writeModTable = async (data: Record<string, any>[], dbTable: string, tableName: string): Promise<void> => {
    const writePath = path.join(MOD_OUTPUT_PATH, "db", dbTable, `${tableName}__jac.tsv`);
    const version = await client.getTableVersionString(dbTable, tableName);
    tsv.writeTSV(writePath, data, version);
}

const generateAbilityEffects = async () => {

    const tableResult: TableResult = {};
    // Add the effect bundle.
    tableResult["effect_bundles_tables"] = [singleRowGenerators["effect_bundles_tables"]!()];

    // campaign_bonus_value_ids_basic_tables
    const globalOnlyBonusValues = [
        "battle_healing_cap_mod",
        "heal_power_percent_mod",
        "spell_mastery_percentage_mod",
        "miscast_chance_mod",
        // "morale_mult", // crash
        "morale_percentage_mod",
    
    ];  

    // const characterOnlyBonusValues = [
        // "general_bodyguard_size_mod", // glitchy
    // ];


    // campaign_bonus_value_ids_unit_sets_tables 
    const commonBonusValues = [ 

        "battle_barrier_health",
        "battle_barrier_health_mod",

        "unit_damage_resistance_all_mod",
        "unit_damage_resistance_flame_mod",
        "unit_damage_resistance_magic_mod",
        "unit_damage_resistance_missile_mod",
        "unit_damage_resistance_physical_mod",
        "unit_fatigue_resistance_mod",

        "unit_mass_percentage_mod",

        "xp_gain_rate_mod",

        "morale",

        // "morale_mult", // crash

        "armour_mod",
        "armour_mod_mult",

        "melee_attack_mod",
        "melee_attack_mod_mult",
        
        "melee_defence_mod",
        "melee_defence_mod_mult",

        "melee_damage_ap_mod_add",
        "melee_damage_ap_mod_mult",

        "melee_damage_mod_add",
        "melee_damage_mod_mult",

        "mod_land_movement_battle",

        "missile_block_chance_mod",
    ];

    for (const unitSet of MOD_UNIT_SETS) { 
        for (const statMod of commonBonusValues) {
            const effectsTablesFunc = otherStatRowGenerators.effects_tables!;
            const bonusValueJunctionFunc = otherStatRowGenerators.effect_bonus_value_ids_unit_sets_tables!;
            (tableResult["effects_tables"] ??= []).push(effectsTablesFunc(unitSet, statMod));
            (tableResult["effect_bonus_value_ids_unit_sets_tables"] ??= []).push(bonusValueJunctionFunc(unitSet, statMod));

        }
    }

    const globalSet =     "jar_unit_set_global";
    // const characterSet = "jar_unit_set_characters";

    for (const bonusValue of globalOnlyBonusValues) {
        const effectsTablesFunc = otherStatRowGenerators.effects_tables!;
        const bonusValueJunctionFunc = otherStatRowGenerators.effect_bonus_value_basic_junction_tables!;

        (tableResult["effects_tables"] ??= []).push(effectsTablesFunc(globalSet, bonusValue));
        (tableResult["effect_bonus_value_basic_junction_tables"] ??= []).push(bonusValueJunctionFunc(globalSet, bonusValue))

    }

    
    // for (const bonusValue of characterOnlyBonusValues) {
    //     const effectsTablesFunc = otherStatRowGenerators.effects_tables!;
    //     const bonusValueJunctionFunc = otherStatRowGenerators.effect_bonus_value_basic_junction_tables!;

    //     (tableResult["effects_tables"] ??= []).push(effectsTablesFunc(characterSet, bonusValue));
    //     (tableResult["effect_bonus_value_basic_junction_tables"] ??= []).push(bonusValueJunctionFunc(characterSet, bonusValue))

    // }

    

    // Write output to mod folder.
    console.log('Created the following number of records for each table:');
    for (const [table, data] of Object.entries(tableResult)) {
        console.log(`${table}: ${data.length}`)
        await writeModTable(data, table, "jar_adjustable_missiles")
    }
};

export { generateAbilityEffects };


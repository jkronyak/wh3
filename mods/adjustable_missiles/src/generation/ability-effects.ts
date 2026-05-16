import 'dotenv/config';
import path from 'path';
import tsv from '../../../../lib/helpers/tsv.ts';
import { MOD_OUTPUT_PATH, MOD_PREFIX } from "../config/mod-config.ts";
import { getOrCreateSession } from '../../../../lib/rpfm-client/rpfm-client-instance.ts';
import { BONUS_VALUE_CONFIG, UNIT_SET_CONFIG } from '../config/data-config.ts';
const client = await getOrCreateSession();

const recordPrefix = MOD_PREFIX;

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

    for (const [bvKey, bvConfig] of Object.entries(BONUS_VALUE_CONFIG)) {
        

        const bvUnitSets = (Array.isArray(bvConfig.unit_sets) && bvConfig.unit_sets.length > 0)
            ? bvConfig.unit_sets
            : Object.keys(UNIT_SET_CONFIG);
        
        const tableName = (bvConfig.type || "effect_bonus_value_ids_unit_sets_tables") as TableName;
        
        for (const unitSetKey of bvUnitSets) {
            const effectsTablesFunc = otherStatRowGenerators.effects_tables!;
            const bonusValueJuncFunc = otherStatRowGenerators[tableName]!;
            (tableResult["effects_tables"] ??= []).push(effectsTablesFunc(unitSetKey, bvKey));
            (tableResult[tableName] ??= []).push(bonusValueJuncFunc(unitSetKey, bvKey));
        }
    }

    // Write output to mod folder.
    console.log('Created the following number of records for each table:');
    for (const [table, data] of Object.entries(tableResult)) {
        console.log(`${table}: ${data.length}`)
        await writeModTable(data, table, "jar_adjustable_missiles")
    }
};

export { generateAbilityEffects };


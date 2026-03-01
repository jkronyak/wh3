import 'dotenv/config';
import path from 'path';

import { getModPackPath, type Mod } from '../../../lib/steam-workshop/steam-workshop.ts';
import tsv from '../../../lib/helpers/tsv.ts';
import { readJSON } from '../../../lib/helpers/helpers.ts';
import { getOrCreateSession } from '../../../lib/rpfm-client/rpfm-client-instance.ts';
const client = await getOrCreateSession();

import {
    PATCH_MOD_PATH,
    REPORT_PATH,
    MOD_OUTPUT_PATH,
    MOD_UNIT_SETS,
    MOD_TABLE_NAME
} from './config.ts';
import type { Definition } from '../../../lib/rpfm-client/rpfm-types.js';

type ModUnitSet = typeof MOD_UNIT_SETS[number];

type UnitInfo = {
    mainUnitKey: string,
    landUnitKey: string,
    caste: string,
    category: string,
    class: string,
    uiGroup: string,
    parentGroup: string,
    numMen: number,
    numEngines: number,
    numMounts: number,
    useHitpointsInCampaign: boolean,
    primaryMissileWeapon: string,
    primaryAmmo: number,
    unitSet?: ModUnitSet | null
};

type DecodedRow = Record<string, any>

type DecodedTable = {
    table_name: string,
    definition: Definition,
    rows: DecodedRow[]
};

const getModPackFilePaths = (): string[] => (readJSON(PATCH_MOD_PATH) as Mod[]).flatMap(mod => getModPackPath(mod.appId, mod.id) ?? []);

const getPackName = (packPath: string) => packPath.split("\\").slice(-1)[0]!.replace(".pack", "");

const decodeTablesFromPack = async <T extends string>(
    tableNames: readonly T[],
    packPath?: string
): Promise<Record<T, DecodedTable>> => {
    if (packPath) await client.loadPackFiles([packPath]);

    const decodeTable = async (internalPath: string, sourceType: "GameFiles" | "PackFile") => {
        const [tableData] = await client.decodeFile(internalPath, sourceType);
        const definition = tableData.table.definition;
        const fields = await client.getFieldsProcessed(definition);
        const rows = tableData.table.table_data;
        return {
            definition,
            rows: rows.map(row =>
                fields.reduce((acc, field, idx) => {
                    acc[field.name] = row[idx][field.field_type];
                    return acc;
                }, {} as Record<string, any>)
            ),
        };
    };

    const result: Record<string, any> = {};

    for (const tableName of tableNames) {
        const sourceType = packPath ? "PackFile" : "GameFiles";
        const internalPaths = packPath ? await client.getTablePaths(tableName) : [`db/${tableName}/data__`];
        let definition;
        const allRows = [];
        for (const internalPath of internalPaths) {
            const decodedData = await decodeTable(internalPath, sourceType);
            definition = decodedData.definition;
            allRows.push(...decodedData.rows);
        }
        result[tableName] = { table_name: tableName, definition, rows: allRows };
    }

    if (packPath) await client.closePack();
    return result;
}

const writeModTable = async (data: Record<string, any>[], dbTable: string, tableName: string): Promise<void> => {
    const writePath = path.join(MOD_OUTPUT_PATH, "db", dbTable, `${tableName}.tsv`);
    const version = await client.getTableVersionString(dbTable, tableName);
    tsv.writeTSV(writePath, data, version);
}

const calculateUnitSet = (unit: UnitInfo): ModUnitSet | null => {
    if (
        unit.caste === 'warmachine'
        || ['artillery_war_machines', 'flying_war_machine'].includes(unit.parentGroup)
    ) return 'jar_unit_set_artillery_war_machines';

    if (
        unit.numMen === 1
        || unit.numMounts === 1
        || unit.numEngines === 1
        || unit.useHitpointsInCampaign
    ) return "jar_unit_set_single_entities";

    if (["cavalry_chariots", "missile_cavalry_chariots"].includes(unit.parentGroup))
        return "jar_unit_set_cavalry_chariots";

    if (['monstrous_infantry'].includes(unit.caste)
        || ['missile_monster_beasts', 'monster_beasts', 'constructs'].includes(unit.parentGroup)
    ) return "jar_unit_set_monstrous";

    if (['missile_infantry', 'melee_infantry'].includes(unit.caste)) return "jar_unit_set_infantry"

    return null;
}

const categorizeUnits = (
    mainUnits: DecodedRow[],
    landUnits: DecodedRow[],
    uiUnitGroupings: DecodedRow[],
    writeToFile?: string,
    filterCharacters: boolean = true,
    filterNonRanged: boolean = true
): UnitInfo[] => {
    const result: UnitInfo[] = [];
    const landUnitMap = new Map<string, any>(landUnits.map(l => [l.key, l]));
    const uiGroupToParentMap = new Map<string, string>(uiUnitGroupings.map(g => [g.key, g.parent_group]));
    for (const mainUnit of mainUnits) {
        const landUnit = landUnitMap.get(mainUnit.land_unit);
        if (!landUnit) throw new Error(`Could not find associated land unit record for ${mainUnit.unit}`);
        const parentGroup = uiGroupToParentMap.get(mainUnit.ui_unit_group_land);
        if (!parentGroup) throw new Error(`Could not find parent group for ${mainUnit.unit}`);

        if (filterCharacters && ['lord', 'hero'].includes(mainUnit.caste)) continue;
        if (filterNonRanged && (!landUnit.primary_missile_weapon && landUnit.primary_ammo < 1)) continue;

        const unitInfo: UnitInfo = {
            mainUnitKey: mainUnit.unit,
            landUnitKey: landUnit.key,
            caste: mainUnit.caste,
            category: landUnit.category,
            class: landUnit.class,
            uiGroup: mainUnit.ui_unit_group_land,
            parentGroup: parentGroup,
            numMen: mainUnit.num_men,
            numEngines: landUnit.num_engines,
            numMounts: landUnit.num_mounts,
            useHitpointsInCampaign: (mainUnit.use_hitpoints_in_campaign === true),
            primaryMissileWeapon: landUnit.primary_missile_weapon || null,
            primaryAmmo: landUnit.primary_ammo,
        };
        const unitSet = calculateUnitSet(unitInfo);
        if (!unitSet) throw new Error(`Could not calculate set for ${mainUnit.unit}: \n${JSON.stringify(unitInfo, null, 4)}`);
        const cur = { ...unitInfo, unitSet };
        result.push(cur);
    }
    if (writeToFile) tsv.writeTSV(`${writeToFile}`, result);
    return result;
}

const generateStaticUnitSetJunctions = (unitCastes: DecodedTable): Record<string, any>[] => {
    return [
        ...unitCastes.rows.map(row => ({
            unit_caste: row.caste,
            unit_category: '', unit_class: '', unit_record: '', unit_set: 'jar_unit_set_global', exclude: false
        })),
        ...['lord', 'hero'].map(caste => ({
            unit_caste: caste,
            unit_category: '', unit_class: '', unit_record: '', unit_set: 'jar_unit_set_characters', exclude: false
        }))
    ];
}

const generateUnitSetJunctions = (units: UnitInfo[]): Record<string, any>[] => {
    return units.map(unit => ({
        unit_caste: '',
        unit_category: '',
        unit_class: '',
        unit_record: unit.mainUnitKey,
        unit_set: unit.unitSet!,
        exclude: false
    })).sort((a, b) => a.unit_set.localeCompare(b.unit_set));
}

const generateUnitSets = async (writeReport = true, vanillaOnly = false) => {

    // 1.1. Decode vanilla tables from pack.
    const extractTables = [
        'ui_unit_groupings_tables',
        'main_units_tables',
        'land_units_tables',
        'unit_castes_tables'
    ] as const;
    console.log('Processing vanilla tables.');
    const vanillaTables = await decodeTablesFromPack(extractTables);

    // 1.2. Aggregate unit category and unit set information.
    const categorizedUnits = categorizeUnits(
        vanillaTables.main_units_tables.rows,
        vanillaTables.land_units_tables.rows,
        vanillaTables.ui_unit_groupings_tables.rows,
        (writeReport ? `${REPORT_PATH}/categorizations/vanilla.tsv` : undefined)
    );
    console.log(`Found ${categorizedUnits.length} units after categorization and filtering.`);
    // 1.3 Generate vanilla unit set information.
    const vanillaSetJunctions = generateUnitSetJunctions(categorizedUnits);
    const staticSetJunctions = generateStaticUnitSetJunctions(vanillaTables.unit_castes_tables);

    const unitSets = MOD_UNIT_SETS.map(set => ({
        key: set, use_unit_exp_level_range: false, min_unit_exp_level_inclusive: -1,
        max_unit_exp_level_inclusive: -1, special_category: ""
    }));
    await writeModTable(unitSets, "unit_sets_tables", `${MOD_TABLE_NAME}__vanilla__`);
    await writeModTable([...vanillaSetJunctions, ...staticSetJunctions], "unit_set_to_unit_junctions_tables", `${MOD_TABLE_NAME}__vanilla__`);

    if (vanillaOnly) return client.close();

    // 2.1 Process mod data.
    const modPaths = getModPackFilePaths();
    for (const modPath of modPaths) {
        const packName = getPackName(modPath);
        console.log(`Processing pack file ${packName}.`);
        const modTables = await decodeTablesFromPack(['ui_unit_groupings_tables', 'main_units_tables', 'land_units_tables'], modPath);
        const modCategorizedUnits = categorizeUnits(
            modTables.main_units_tables.rows,
            modTables.land_units_tables.rows,
            modTables.ui_unit_groupings_tables.rows.concat(vanillaTables.ui_unit_groupings_tables.rows),
            (writeReport ? `${REPORT_PATH}/categorizations/${packName}.tsv` : undefined)
        );
        console.log(`Found ${modCategorizedUnits.length} units after categorization and filtering.`);
        const modSetJunctions = generateUnitSetJunctions(modCategorizedUnits);
        await writeModTable(modSetJunctions, "unit_set_to_unit_junctions_tables", `${MOD_TABLE_NAME}__${packName}__`);
    }

    // client.close();
    return;
};

export { generateUnitSets };
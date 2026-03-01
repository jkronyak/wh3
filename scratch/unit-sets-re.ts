import 'dotenv/config';
import fs from 'fs';
import path from 'path';

import { getModPackPath, type Mod } from '../../../lib/steam-workshop/steam-workshop.ts';
import tsv from '../../../lib/helpers/tsv.ts';
import { readJSON } from '../../../lib/helpers/helpers.ts';
import { getOrCreateSession } from '../../../lib/rpfm-client/rpfm-client-instance.ts';
const client = await getOrCreateSession();

import {
    parentGroupToUnitSet,
    type ParentGroup,
    REF_PATH,
    PATCH_MOD_PATH,
    REPORT_PATH,
    MOD_INPUT_PATH,
    MOD_OUTPUT_PATH,
    modUnitSetRecords
} from './config.ts';
import type { DecodedData, Definition, FieldType, Schema, TableInMemory } from '../../../lib/rpfm-client/rpfm-types.js';

type UnitCategoryInfo = {
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
    primaryAmmo: number
};

type DecodedTable = { 
    table_name: string,
    definition: Definition,
    rows: Record<string, any>[]
};

const getModPackFilePaths = (): string[] => (readJSON(PATCH_MOD_PATH) as Mod[]).flatMap(mod => getModPackPath(mod.appId, mod.id) ?? []);


// ========== Packed File Operations/Helpers ==========
const getPackName = (packPath: string) => packPath.split("\\").slice(-1)[0]!.replace(".pack", "");

const extractTablesFromPack = async (tableNames: string[], destination: string, packPath?: string) => {
    const sourceFiles = tableNames.map(tbl => ({ Folder: `db/${tbl}` }));
    // If the path to a pack file was provided, extract it from there. Else use vanilla game files.
    if (packPath) {
        const packName = getPackName(packPath);
        await client.loadPackFiles([packPath]);
        const extract = await client.extractPackedFiles({
            PackFile: sourceFiles
        }, `${destination}/${packName}`, true);
        await client.closePack();
        return extract;
    } else {
        const extract = await client.extractPackedFiles({
            GameFiles: sourceFiles
        }, destination, true);
        await client.closePack();
        return extract;
    }
};


const decodeTablesFromPack = async (tableNames: string[], packPath?: string): Promise<Record<string, DecodedTable>> => { 

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
    return result;
}

// TODO: Fix issue where only the last file in the table path is set to the result
const decodeTablesFromPack2 = async (tableNames: string[], packPath?: string) => {
    const result: Record<string, any> = {};
    for (const tableName of tableNames) {
        if (!packPath) {
            const internalPath = `db/${tableName}/data__`;
            const [tableData, fileInfo] = await client.decodeFile(internalPath, "GameFiles");
            const definition = tableData.table.definition;
            const fields = await client.getFieldsProcessed(definition);
            const rows = tableData.table.table_data;
            result[tableData.table.table_name] = {
                table_name: tableData.table.table_name,
                definition: definition,
                rows: rows.map(row => {
                    return fields.reduce((acc, field, idx) => {
                        acc[field.name] = row[idx][field.field_type];
                        return acc;
                    }, {} as Record<string, any>);
                })
            }
        } else {
            console.log(tableName);
            await client.loadPackFiles([packPath]);
            const internalPaths = await client.getTablePaths(tableName);
            const allRows = [];
            let definition;
            for (const internalPath of internalPaths) {
                const [tableData, fileInfo] = await client.decodeFile(internalPath, "PackFile");
                definition = tableData.table.definition;
                const fields = await client.getFieldsProcessed(definition);
                const rows = tableData.table.table_data;
                allRows.push(...rows.map(row => { 
                    return fields.reduce((acc, field, idx) => { 
                        acc[field.name] = row[idx][field.field_type];
                        return acc;
                    }, {} as Record<string, any>);
                }));
            };
            result[tableName] = {
                table_name: tableName, 
                definition: definition,
                rows: allRows
            };
            // console.log('internal', internalPaths);
        }
    }
    return result;
}


// ========== a ==========
const extractVanillaData = async () => {
    const extractTables = ['ui_unit_groupings_tables', 'main_units_tables', 'land_units_tables', 'unit_castes_tables'];

    const decodeResult = await decodeTablesFromPack(extractTables);
};


const getUnitCategorizations = (
    mainUnits: Record<string, any>[],
    landUnits: Record<string, any>[],
    uiUnitGroupings: Record<string, any>[],
    writeToFile?: string,
    filterCharacters: boolean = true,
    filterNonRanged: boolean = true,
): UnitCategoryInfo[] => {
    const result: UnitCategoryInfo[] = [];
    const landUnitsMap = new Map<string, any>(landUnits.map(l => [l.key, l]));
    const uiGroupToParentMap = new Map<string, string>(uiUnitGroupings.map(g => [g.key, g.parentGroup]));
    for (const mainUnit of mainUnits) {
        const landUnit = landUnitsMap.get(mainUnit.landUnit);
        if (!landUnit) throw new Error(`Could not find landUnit for ${mainUnit.unit}`);
        const parentGroup = uiGroupToParentMap.get(mainUnit.uiUnitGroupLand);
        if (!parentGroup) throw new Error(`Could not find parentGroup for ${mainUnit.unit}`);

        if (filterCharacters && ['lord', 'hero'].includes(mainUnit.caste)) continue;
        if (filterNonRanged && (!landUnit.primaryMissileWeapon && landUnit.primaryAmmo < 1)) continue;

        result.push({
            mainUnitKey: mainUnit.unit,
            landUnitKey: landUnit.key,
            caste: mainUnit.caste,
            category: landUnit.category,
            class: landUnit.class,
            uiGroup: mainUnit.uiUnitGroupLand,
            parentGroup: parentGroup,
            numMen: Number(mainUnit.numMen),
            numEngines: Number(landUnit.numEngines),
            numMounts: Number(landUnit.numMounts),
            useHitpointsInCampaign: (mainUnit.useHitpointsInCampaign === 'true'),
            primaryMissileWeapon: landUnit.primaryMissileWeapon || null,
            primaryAmmo: Number(landUnit.primaryAmmo)

        } as UnitCategoryInfo);
    }
    if (writeToFile) tsv.writeTSV(`${writeToFile}/categorizations.tsv`, result);
    return result;
};

const calculateUnitSet = (unit: UnitCategoryInfo): string | null => {

    const isArtilleryOrWarMachine = (
        unit.caste === 'warmachine' || ['artillery_war_machines', 'flying_war_machine'].includes(unit.parentGroup)
    );
    if (isArtilleryOrWarMachine) return 'jar_unit_set_artillery_war_machine';

    const isSingeEntity = (
        unit.numMen === 1 || unit.numMounts === 1 || unit.numEngines === 1 || unit.useHitpointsInCampaign
    );
    if (isSingeEntity) return 'jar_unit_set_single_entity_monster';

    const isCavalry = (
        ['missile_cavalry', 'melee_cavalry'].includes(unit.caste)
        || unit.category === 'cavalry'
    );
    if (isCavalry) return 'jar_unit_set_cavalry';

    const isChariot = (
        unit.caste === 'chariot'
    );
    if (isChariot) return 'jar_unit_set_chariot';

    const isMonstrous = (
        ['monstrous_infantry', 'monster', 'war_beast'].includes(unit.caste)
        || ['missile_monster_beasts', 'monster_beasts', 'constructs'].includes(unit.parentGroup)
    );
    if (isMonstrous) return 'jar_unit_set_monstrous';

    const isInfantry = (
        ['missile_infantry', 'melee_infantry'].includes(unit.caste)
    );
    if (isInfantry) return 'jar_unit_set_infantry';

    return 'REEEEEEEEE';




    return null;
}

const generateUnitSetJunctions = (units: UnitCategoryInfo[]): Record<string, any>[] => {

    return units.map(unit => ({
        ...unit,
        unitSet: calculateUnitSet(unit)
    }))
}

const generate = async (writeReport = true) => {

    console.log('Processing vanilla tables.');
    // await client.send("GenerateDependenciesCache")
    // const res = await extractVanillaData();
    const modPaths = getModPackFilePaths();

    const res = await decodeTablesFromPack(['main_units_tables'], modPaths[0]);
    console.log('res', res.main_units_tables!.rows.length);
    // const resp = await client.decodeFile('db/unit_castes_tables/data__', "GameFiles");
    // // console.log(resp[0].table.definition.fields)
    // // console.log('resp', resp[0]);
    // const rows: any[][] = resp[0].table.table_data;
    // const fields: any[] = resp[0].table.definition.fields;
    // const newRows = rows.map(row => {
    //     return fields.reduce((acc, cur) => {
    //         acc[cur.name] = row[cur.ca_order][cur.field_type]
    //         return acc;
    //     }, {});

    // })

    // console.log('newRow', newRows);

    // console.log(resp);

    // const tableData = {
    //     table_name: resp[0].table.table_name,
    //     table_data: resp[0].table.table_data.map((row: any) => {
    //         return resp[0].table.definition.fields.reduce((acc: Record<string, any>, cur: any) => {
    //             acc[cur.name] = row[cur.ca_order][cur.field_type]
    //             return acc;
    //         }, {} as Record<string, any>);

    //     })
    // }
    // console.log('tableData', tableData);
    // const result = { 
    //     [resp.table.table_name]: (

    //     )
    // }
    // const vanillaTableData = await extractVanillaData();
    // console.log(vanillaTableData);
    // console.log('Retrieved the following objects: ', Object.keys(vanillaTableData));
    // const categorizedUnits = getUnitCategorizations(
    //     vanillaTableData.mainUnits,
    //     vanillaTableData.landUnits,
    //     vanillaTableData.uiUnitGroupings,
    //     (writeReport ? REPORT_PATH : undefined),
    //     true,
    //     false
    // );
    // console.log(`Found ${categorizedUnits.length} units after categorizing.`);
    // const unitSetJunctions = generateUnitSetJunctions(categorizedUnits);
    // console.log(unitSetJunctions);
    // tsv.writeTSV(`${REPORT_PATH}/test.tsv`, unitSetJunctions);

    // const paths = getModPackFilePaths();
    // await client.loadPackFiles([paths[0]!])
    // const resp = await client.send({ FolderExists: 'db/main_units_tables'})
    // console.log('resp', resp);
    // const resp = await client.send("Schema")
    // const schema = (resp as { Schema: Schema }).Schema;
    // const uiUnitGroupingsDef = schema.definitions.ui_unit_groupings_tables!.sort((a, b) => b.version - a.version);
    // console.log(uiUnitGroupingsDef![0])
    await client.close();
    return;
};
generate();
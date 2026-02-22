import 'dotenv/config';
import fs from 'fs';
import path from 'path';
const __dirname = import.meta.dirname;

let client: RPFMClient;

import { RPFMClient } from '../../../lib/rpfmServer/rpfmClient.ts';
import { getModPackPath, type Mod } from '../../../lib/steam-workshop/steam-workshop.ts';
import tsv from '../../../lib/helpers/tsv.ts';
import { readJSON } from '../../../lib/helpers/helpers.ts';

import {
    parentGroupToUnitSet,
    type ParentGroup,
    modUnitSets,
    MOD_DIR,
    REF_PATH,
    PATCH_MOD_PATH,
    MOD_INPUT_PATH,
    MOD_OUTPUT_PATH,
    MOD_DIST_PATH,
    modUnitSetRecords
} from './config.ts';

// const client = new RPFMClient(process.env.RPFM_SERVER_PATH!);

const getModPackFilePaths = (): string[] => (readJSON(PATCH_MOD_PATH) as Mod[]).flatMap(mod => getModPackPath(mod.appId, mod.id) ?? []);

const getPackName = (packPath: string) => packPath.split("\\").slice(-1)[0]!.replace(".pack", "");

const extractTablesFromPack = async (packPath: string, tableNames: string[]) => {
    const packName = getPackName(packPath);
    console.log(`Extracting ${tableNames.join(', ')} from ${packName}`);
    await client.loadPackFiles([packPath]);
    const extract = await client.extractPackedFiles({
        PackFile: tableNames.map(tbl => ({ Folder: `db/${tbl}` }))
    }, `${MOD_INPUT_PATH}/${packName}`, true);
    await client.closePack();
    return extract;
}

const parseModTables = (
    packName: string,
    tableNames: string[]
) => {
    return tableNames.reduce((acc, tbl) => {
        const tablePath = path.join(MOD_INPUT_PATH, packName, "db", tbl);
        acc[tbl] = (fs.existsSync(tablePath)) ? tsv.parseTSVFolder(tablePath) : null
        return acc;
    }, {} as Record<string, Record<string, any>[] | null>);
}

const joinUnitAndGroupData = (
    units: Record<string, any>[],
    groups: Record<string, any>[],
    casteExclusions: string[] = []
): Record<string, any>[] => {

    const result: Record<string, any>[] = [];
    const mismatches = [];
    for (const unit of units) {
        if (!casteExclusions.includes(unit.caste)) {
            const unitKey = unit.unit;
            const unitGroup = unit.ui_unit_group_land;
            const parentGroup = groups.find(g => g.key === unitGroup)?.parent_group ?? null;
            if (!parentGroup) throw new Error(`Unable to find parent_group for ${unitKey}. Record: ${JSON.stringify(unit)}`);
            result.push({
                key: unitKey,
                group: unitGroup,
                parentGroup: parentGroup
            });
        } else {
            // Simple checking for lord/hero units that would have ended up in a group other than
            // jar_unit_set_lords_heroes. No action required, since they are already handled separately.
            const unitGroup = unit.ui_unit_group_land;
            const parentGroup = groups.find(g => g.key === unitGroup)!.parent_group;
            if (!['commander', 'heroes_agents', 'campaign_exclusives'].includes(parentGroup)) {
                mismatches.push({
                    unit: unit.unit,
                    caste: unit.caste,
                    unitGroup,
                    parentGroup
                });
            }
        }
    }
    if (mismatches.length > 0) {
        console.log('Found the following lord or hero units with mismatched UI and caste:');
        mismatches.forEach(m => console.log(`[${m.unit}]:\n\tc: ${m.caste}\n\tpg: ${m.parentGroup}\n\tg: ${m.unitGroup}`))
    }

    return result;
}

const generateUnitSetJunctions = (units: Record<string, any>[]): Record<string, any>[] => {
    return units.map(unit => ({
        unit_caste: '',
        unit_category: '',
        unit_class: '',
        unit_record: unit.key,
        unit_set: parentGroupToUnitSet[unit.parentGroup as ParentGroup],
        exclude: false
    })).sort((a, b) => a.unit_set.localeCompare(b.unit_set));
}

const generateStaticUnitSetJunctions = (): Record<string, any>[] => {
    const unitCastes = tsv.parseTSVFolder(path.join(REF_PATH, "db", "unit_castes_tables")).map(i => i.caste);
    const globalUnitSetJunctions = unitCastes.map(caste => ({
        unit_caste: caste,
        unit_category: '',
        unit_class: '',
        unit_record: '',
        unit_set: 'jar_unit_set_global',
        exclude: false
    }));
    const lordHeroUnitSetJunctions = [{
        unit_caste: 'lord',
        unit_category: '',
        unit_class: '',
        unit_record: '',
        unit_set: 'jar_unit_set_lords_heroes',
        exclude: false
    },
    {
        unit_caste: 'hero',
        unit_category: '',
        unit_class: '',
        unit_record: '',
        unit_set: 'jar_unit_set_lords_heroes',
        exclude: false
    }];
    return globalUnitSetJunctions.concat(lordHeroUnitSetJunctions);
};

const writeModTable = async (data: Record<string, any>[], dbTable: string, tableName: string): Promise<void> => {
    const writePath = path.join(MOD_OUTPUT_PATH, "db", dbTable, `${tableName}__jam.tsv`);
    const version = await client.getTableVersionString(dbTable, tableName);
    tsv.writeTSV(writePath, data, version);
}

// TODO: Add error handling for RFPMClient function calls.
const generateUnitSets = async (sessionId = 0) => {

    const casteExclusions = ['lord', 'hero'];

    // await client._connect();
    client = new RPFMClient(process.env.RPFM_EXEC_PATH, sessionId);
    await client._connect();

    // Step 1: Extract and process the required vanilla tables.

    const extractTables = ["ui_unit_groupings_tables", "main_units_tables"];

    // 1.1 Extract the tables to the reference folder.
    console.log('Processing vanilla tables.');
    const referenceExtract = await client.extractPackedFiles({
        GameFiles: [
            { Folder: "db/ui_unit_groupings_tables" },
            { Folder: "db/main_units_tables" },
            { Folder: "db/unit_castes_tables" }
        ]
    }, REF_PATH, true);

    console.log(`Extracted ${referenceExtract[1].length} files from vanilla.`);

    // 1.2 Parse the TSV files into JSON variables.
    const vanillaUiUnitGroupings = tsv.parseTSVFolder(path.join(REF_PATH, "db", "ui_unit_groupings_tables"));
    const vanillaMainUnits = tsv.parseTSVFolder(path.join(REF_PATH, "db", "main_units_tables"));

    console.log('Generating unit sets for vanilla.')
    // 1.3 Generate the unit set junction records.
    const vanillaJoinedData = joinUnitAndGroupData(vanillaMainUnits, vanillaUiUnitGroupings, casteExclusions);
    const vanillaUnitSetsJunctions = generateUnitSetJunctions(vanillaJoinedData);
    const vanillaStaticUnitSetsJunctions = generateStaticUnitSetJunctions();
    const vanillaCombinedUnitSetJunctions = [...vanillaUnitSetsJunctions, ...vanillaStaticUnitSetsJunctions];
    console.log(`Generated ${vanillaCombinedUnitSetJunctions.length} unit set junction records.`);

    // 1.4 Write the unit set and unit set junction records to the mod folder.
    console.log("Writing vanilla tables to mod folder.")
    await writeModTable(modUnitSetRecords, "unit_sets_tables", "jar_adjustable_missiles");
    await writeModTable(vanillaCombinedUnitSetJunctions, "unit_set_to_unit_junctions_tables", "jar_adjustable_missiles");
    // Step 2: Extract and process the tables for each mod in the configuration.
    const modPaths = getModPackFilePaths();
    for (const modPath of modPaths) {
        const packName = getPackName(modPath);

        console.log(`\nProcessing mod pack: ${packName}.`);
        // 2.1 Extract the tables into the input folder.
        const modExtract = await extractTablesFromPack(modPath, extractTables);
        console.log(`Extracted ${modExtract[1].length} files from mod.`);

        // 2.2 Parse the TSV files into JSON variables.
        const modData = parseModTables(packName, extractTables)

        const modMainUnits = modData.main_units_tables ?? [];
        const modUiUnitGroupings = modData.ui_unit_groupings_tables ?? [];
        modUiUnitGroupings.push(...vanillaUiUnitGroupings);

        if (modMainUnits.length === 0) {
            console.log(`Pack ${packName} does not have records in main_units_tables. It can be removed from the patch config.`);
            continue;
        }
        // 2.3 Generate the unit set junction records.
        const modJoinedUnitData = joinUnitAndGroupData(modMainUnits, modUiUnitGroupings, casteExclusions);
        const modUnitSetJunctions = generateUnitSetJunctions(modJoinedUnitData);
        console.log(`Generated ${modUnitSetJunctions.length} unit set junction records.`);

        // 2.4 Write the modded unit set junction records to the mod folder.
        await writeModTable(modUnitSetJunctions, "unit_set_to_unit_junctions_tables", `${packName}__jam`);
        // await client.disconnect();
    }
};

export { generateUnitSets };
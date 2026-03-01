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
    MOD_INPUT_PATH,
    MOD_OUTPUT_PATH,
    modUnitSetRecords
} from './config.ts';

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
    const landUnitsData = tsv.parseTSVFolder(path.join(REF_PATH, "db", "land_units_tables"), ["key", "num_engines", "num_mounts", "use_hitpoints_in_campaign"]);
    const result: Record<string, any>[] = [];
    for (const unit of units) {
        if (!casteExclusions.includes(unit.caste)) {
            const landUnitRecord = landUnitsData.find(record => record.key === unit.land_unit);
            if (!landUnitRecord) throw new Error(`Unable to find land unit record for ${unit.unit}`);
            // If this unit has no primary_missile_weapon nor any ammo, then it is not a missile unit. Skip.
            if (landUnitRecord.primary_missile_weapon === '' && Number(landUnitRecord.primary_ammo) === 0) continue;
            const unitKey = unit.unit;
            const unitGroup = unit.ui_unit_group_land;
            const landUnit = unit.land_unit
            const parentGroup = groups.find(g => g.key === unitGroup)?.parent_group ?? null;
            if (!parentGroup) throw new Error(`Unable to find parent_group for ${unitKey}. Record: ${JSON.stringify(unit)}`);
            result.push({
                key: unitKey,
                group: unitGroup,
                parentGroup: parentGroup,
                landUnit,
                caste: unit.caste,
                numMen: unit.num_men,
                numEngines: landUnitRecord.num_engines,
                numMounts: landUnitRecord.num_mounts,
                useHitpointsInCampaign: unit.use_hitpoints_in_campaign,
            });
        }
    }
    return result;
}

const calculateUnitSet = (unit: Record<string, any>): any => {

    const isArtilleryOrWarMachine = (
        unit.caste === 'artillery'
        || ['art_fix', 'art_fld', 'art_siege'].includes(unit.class)
        || ['artillery_war_machines', 'flying_war_machine'].includes(unit.parentGroup)
    );
    if (isArtilleryOrWarMachine) return 'jar_unit_set_artillery_war_machine';

    const isSingeEntityMonster = (
        Number(unit.numMen) === 1
        || Number(unit.numMounts) === 1
        || Number(unit.numEngines) === 1
        || unit.useHitpointsInCampaign === "true"
    );
    if (isSingeEntityMonster) return 'jar_unit_set_single_entity_monster';

    const isMonstrous = (
        unit.caste === 'monstrous_infantry'
        || ['missile_monster_beasts', 'monster_beasts', 'constructs'].includes(unit.parentGroup)
        // Should we exclude class === 'cav_mis' here? This would exclude flying monster-mounted cavalry
    );
    if (isMonstrous) return 'jar_unit_set_monstrous';

    const isCavalry = (
        ['cavalry_chariots', 'missile_cavalry_chariots'].includes(unit.parentGroup)
        && unit.caste !== 'chariot'
    );
    if (isCavalry) return 'jar_unit_set_cavalry';

    const isChariot = (
        ['cavalry_chariots', 'missile_cavalry_chariots'].includes(unit.parentGroup)
        && unit.caste === 'chariot'
    );
    if (isChariot) return 'jar_unit_set_chariot';

    const isInfantry = (
        ['infantry', 'missile_infantry'].includes(unit.parentGroup)
    );
    if (isInfantry) return 'jar_unit_set_infantry';

    console.log('Warning: Found unit with no matching set: ', unit);
    return null;
};


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
    const lordHeroUnitSetJunctions = ['lord', 'hero'].map(caste => ({
        unit_caste: caste,
        unit_category: '',
        unit_class: '',
        unit_record: '',
        unit_set: 'jar_unit_set_lords_heroes',
        exclude: false
    }));
    return globalUnitSetJunctions.concat(lordHeroUnitSetJunctions);
};

const generateUnitSetReport = async (joinedUnitData: Record<string, any>[]) => {
    console.log('Generating report');
    await client.extractPackedFiles({
        GameFiles: [{ Folder: "db/land_units_tables" }]
    }, REF_PATH, true);
    const landUnitsData = tsv.parseTSVFolder(path.join(REF_PATH, "db", "land_units_tables"));
    const result = [];
    for (const unit of joinedUnitData) {
        const landUnitRecord = landUnitsData.find(record => record.key === unit.landUnit);
        if (!landUnitRecord) throw new Error(`Unable to find land unit record for ${unit.unit}`);
        result.push({
            unit: unit.key,
            caste: unit.caste,
            category: landUnitRecord.category,
            class: landUnitRecord.class,
            num_men: unit.numMen,
            num_engines: unit.numEngines,
            num_mounts: unit.numMounts,
            // group: unit.group,
            parent_group: unit.parentGroup,
            unit_set: parentGroupToUnitSet[unit.parentGroup as ParentGroup],
            unit_set_new: calculateUnitSet(unit)
        });
    }
    const __dirname = import.meta.dirname;
    tsv.writeTSV(path.join(__dirname, 'reports', 'unit_set_report.tsv'), result);
}


const writeModTable = async (data: Record<string, any>[], dbTable: string, tableName: string): Promise<void> => {
    const writePath = path.join(MOD_OUTPUT_PATH, "db", dbTable, `${tableName}__jam.tsv`);
    const version = await client.getTableVersionString(dbTable, tableName);
    tsv.writeTSV(writePath, data, version);
}





// TODO: Add error handling for RFPMClient function calls.
const generateUnitSets = async (generateReport = false, vanillaOnly = false) => {
    const casteExclusions = ['lord', 'hero'];


    // Step 1: Extract and process the required vanilla tables.
    const extractTables = ["ui_unit_groupings_tables", "main_units_tables", "land_units_tables"];

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

    if (generateReport) await generateUnitSetReport(vanillaJoinedData);

    // 1.4 Write the unit set and unit set junction records to the mod folder.
    console.log("Writing vanilla tables to mod folder.")
    await writeModTable(modUnitSetRecords, "unit_sets_tables", "jar_adjustable_missiles");
    await writeModTable(vanillaCombinedUnitSetJunctions, "unit_set_to_unit_junctions_tables", "jar_adjustable_missiles");

    if (vanillaOnly) return;
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
    }
};

export { generateUnitSets };
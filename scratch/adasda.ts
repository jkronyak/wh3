import 'dotenv/config';
import path from 'path';
import fs from 'fs';
const __dirname = import.meta.dirname;

import { RPFMClient } from "../lib/rpfmServer/rpfmClient.ts";
import { getModPackPath, type Mod } from '../lib/steam-workshop/steam-workshop.ts';
import tsv from '../lib/helpers/tsv.ts';
import { readJSON } from '../lib/helpers/helpers.ts';

const REF_PATH = path.join(__dirname, '../', 'temp/ref');
const PATCH_MOD_PATH = path.join(__dirname, './patch-mods.json');
const MOD_INPUT_PATH = path.join(__dirname, '../input');
const MOD_OUTPUT_PATH = path.join(__dirname, '../mod')
const DIST_PATH = path.join(__dirname, '../dist');
const client = new RPFMClient(process.env.RPFM_SERVER_PATH!);

const modUnitSets = [
    'jar_unit_set_lords_heroes',
    'jar_unit_set_artillery_war_machines',
    'jar_unit_set_infantry',
    'jar_unit_set_cavalry_chariots',
    'jar_unit_set_monsters',
];
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

type ParentGroup = keyof typeof parentGroupUnitSetMap;

const getPackFilePaths = (): string[] => {
    const patchMods = readJSON(PATCH_MOD_PATH) as Mod[];
    const res: string[] = [];
    patchMods.forEach(mod => {
        const modPath = getModPackPath(mod.appId, mod.id);
        if (modPath) res.push(modPath);
    });
    return res;
};

const extractModTables = async (modPath: string, tableNames: string[]) => {
    const packFileName = modPath.split('\\').slice(-1)[0]?.replace('.pack', '');
    console.log(`Extracting ${tableNames.join(', ')} from ${packFileName}`);
    await client.loadPackFiles([modPath]);
    const result = await client.extractPackedFiles({
        PackFile: tableNames.map(tbl => ({ Folder: `db/${tbl}` }))
    }, `${MOD_INPUT_PATH}/${packFileName}`, true);
    console.log('extractres', result)
    return result;
}

const readModTables = (
    packName: string,
    tableNames: string[]
): Record<string, Record<string, any>[] | null> => {

    const result: Record<string, Record<string, any>[] | null> = {};
    for (const tbl of tableNames) {
        const tblPath = path.join(MOD_INPUT_PATH, packName, "db", tbl);
        if (!fs.existsSync(tblPath)) result[tbl] = null;
        else result[tbl] = tsv.parseTSVFolder(tblPath);
    }
    return result;
}

const joinUnitAndGroupData = (
    units: Record<string, any>[],
    groups: Record<string, any>[],
    casteExclusions: string[] = []
): Record<string, any>[] => {

    const result: Record<string, any>[] = [];

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
        }
    }
    return result;
}

const generateUnitSetJunctions = (units: Record<string, any>[]): Record<string, any>[] => {
    console.log('units[0]', units[0]);
    return units.map(unit => ({
        unit_caste: '',
        unit_category: '',
        unit_class: '',
        unit_record: unit.key,
        unit_set: parentGroupUnitSetMap[unit.parentGroup as ParentGroup],
        exclude: false
    })).sort((a, b) => a.unit_set.localeCompare(b.unit_set));
}

const writeModTable = async (unitSets: Record<string, any>[], dbTable: string, tableName: string): Promise<void> => {
    const unitSetPath = path.join(MOD_OUTPUT_PATH, "db", dbTable, `${tableName}.tsv`);
    const version = await client.getTableVersionString(dbTable, tableName);
    tsv.writeTSV(unitSetPath, unitSets, version);
}

const generate = async (generateVanilla: boolean = true) => {

    await client._connect();

    const refFileExtract = {
        GameFiles: [
            { Folder: 'db/ui_unit_groupings_tables' },
            ...(generateVanilla ? [{ Folder: 'db/main_units_tables' }] : [])
        ]
    };
    const refExtractResult = await client.extractPackedFiles(refFileExtract, REF_PATH, true);
    console.log(`Extracted ${refExtractResult[1].length} folders/files`);
    await client.closePack();

    const refUiUnitGroupings = tsv.parseTSVFolder(path.join(REF_PATH, "db", "ui_unit_groupings_tables"));

    const vanillaMainUnits = generateVanilla ? tsv.parseTSVFolder(path.join(REF_PATH, "db", "main_units_tables")) : [];
    const vUiUnitGroupings = joinUnitAndGroupData(vanillaMainUnits, refUiUnitGroupings);
    const vUnitSetJunctions = generateUnitSetJunctions(vUiUnitGroupings);
    await writeModTable(vUnitSetJunctions, "unit_set_to_unit_junctions_tables", "vanilla");

    const unitSets = modUnitSets.map(set => ({
        key: set,
        use_unit_exp_level_range: false,
        min_unit_exp_level_inclusive: -1,
        max_unit_exp_level_inclusive: -1,
        special_category: ""
    }));
    await writeModTable(unitSets, "unit_sets_tables", "jar_adjustable_missiles");



    const modFilePaths = getPackFilePaths();
    for (const modPath of modFilePaths) {
        const packName = modPath.split('\\').slice(-1)[0]!.replace('.pack', '');

        // Extract the necessary tables from the pack file.
        const extractResult = await extractModTables(modPath, ['ui_unit_groupings_tables', 'main_units_tables']);
        console.log(`Extracted ${extractResult[1].length} tables`);

        // Load the tables into variables
        const modData = readModTables(packName, ['ui_unit_groupings_tables', 'main_units_tables']);
        const mainUnitsTables = modData.main_units_tables ?? [];
        const uiUnitGroupingsTables = modData.ui_unit_groupings_tables ?? [];

        if (mainUnitsTables.length === 0) {
            console.log('Current mod does not have main_units_tables, skipping.');
            continue;
        }
        uiUnitGroupingsTables.push(...refUiUnitGroupings);

        // Join main_units_tables to ui_unit_groupings_tables and get parent_group.
        const joinedUnitData = joinUnitAndGroupData(mainUnitsTables, uiUnitGroupingsTables, []);

        // Generate unit sets from the joined data;
        const unitSetJunctions = generateUnitSetJunctions(joinedUnitData);
        await writeModTable(unitSetJunctions, "unit_set_to_unit_junctions_tables", `${packName}_jam`);
    }

    await client.closePack();

    //
    let r;
    r = await client.send("NewPack");
    r = await client.insertPackedFiles(["C:/Repos/wh3/mods/adjustable_missiles/mod/db"], [{ Folder: "db" }], null);
    console.log('r', r);
    await client.savePackAs(path.join(DIST_PATH, 'jar_adjustable_missiles2.pack'));
    return await client.stop();
    await client.stop();
};
generate();
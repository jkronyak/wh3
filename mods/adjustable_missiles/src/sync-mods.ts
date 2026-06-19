import fs from 'fs';
import path from 'path';
const __dirname = import.meta.dirname;

import { readJSON } from "../../../lib/helpers/helpers.ts";
import { getOrCreateSession } from "../../../lib/rpfm-client/rpfm-client-instance.ts";
import { getModInfo, getModPackPath, synchronizeMods, deleteMod, type Mod } from "../../../lib/steam-workshop/steam-workshop.ts";
import { PATCH_MOD_PATH, WH3_APP_ID } from "./config/mod-config.ts";
const MOD_URL_LIST_PATH = path.join(__dirname, './mod-urls.txt');
const client = await getOrCreateSession();

// Taken from unit-sets.ts START
import type { Definition } from '../../../lib/rpfm-client/rpfm-types.js';
type DecodedRow = Record<string, any>
type DecodedTable = {
    table_name: string,
    definition: Definition,
    rows: DecodedRow[]
};

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
        result[tableName] = { table_name: tableName, definition, rows: allRows.toSorted() };
    }

    if (packPath) await client.closePack();
    return result;
}
// Taken from unit-sets.ts END

const packHasUnits = async (packPath: string)  => {
    let result = true;
    await client.loadPackFiles([packPath]);
    const mainUnitsExists = await client.folderExists("db/main_units_tables");
    const landUnitsExists = await client.folderExists("db/land_units_tables");
    await client.closePack();
    if (!mainUnitsExists || !landUnitsExists) result = false;
    else {
        const tables = await decodeTablesFromPack(['main_units_tables', 'land_units_tables'], packPath);
        const mainUnits = tables.main_units_tables.rows.filter(i => !['lord', 'hero'].includes(i.caste));
        const landUnits = tables.land_units_tables.rows.filter(i => i.primary_missile_weapon || i.primary_ammo > 0);
        if (mainUnits.length === 0 || landUnits.length === 0) result = false;
    }
    return result;
};

// Grab the existing JSON.
const existingSync = readJSON(PATCH_MOD_PATH); 

// Iterate through the input list; clean URLs and remove duplicates.
const modUrls = Array.from(new Set(
    fs.readFileSync(MOD_URL_LIST_PATH, "utf-8")
        .split('\n')
        .map(url => {
            try {
                const parsed = new URL(url.trim());
                const id = parsed.searchParams.get('id');
                parsed.search = '';
                parsed.searchParams.set('id', id!);
                return parsed.toString();
            } catch {
                return url.trim();
            }
        })
        .filter(Boolean)
));
fs.writeFileSync(MOD_URL_LIST_PATH, modUrls.join('\n'), "utf-8");

const modInfo = await getModInfo(modUrls) as Record<string, any>[];

const modInfoMap = modInfo.reduce((acc, cur) => {

    // Check if this was previously marked as required or not; default to true.
    const required = existingSync[cur.id]?.required ?? true;

    acc[cur.id] = {
        title: cur.title,
        url: cur.url,
        required
    }
    return acc;
}, {});

console.log('modInfoMap', modInfoMap);

const result: Record<string, any> = {};

for (const [modId, modData] of Object.entries(modInfoMap)) {
    if (!modData.required) {
        console.log(`${modData.title} was previously marked as not required. Skipping.`);
        result[modId] = { ...modData, sync_ts: Date.now() };
        deleteMod(WH3_APP_ID, modId);
        continue;
    }

    const syncResult = await synchronizeMods(WH3_APP_ID, [modId]);
    const packPath = getModPackPath(WH3_APP_ID, modId);
    if (!packPath) throw new Error(`Error: No pack path for ${modId} (${modData.title})`);

    // Check if the current mod contains main_units_tables.
    const containsUnits = await packHasUnits(packPath!);

    result[modId] = { ...modData, sync_status: syncResult[0].status, sync_ts: Date.now(), required: containsUnits };
}
await client.close();

fs.writeFileSync(PATCH_MOD_PATH, JSON.stringify(result, null, 4));
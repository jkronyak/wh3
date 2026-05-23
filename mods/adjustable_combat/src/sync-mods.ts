import fs from 'fs';
import path from 'path';
const __dirname = import.meta.dirname;

import { readJSON } from "../../../lib/helpers/helpers.ts";
import { getOrCreateSession } from "../../../lib/rpfm-client/rpfm-client-instance.ts";
import { getModInfo, getModPackPath, synchronizeMods, type Mod } from "../../../lib/steam-workshop/steam-workshop.ts";
import { PATCH_MOD_PATH, WH3_APP_ID } from "./config/mod-config.ts";
const MOD_URL_LIST_PATH = path.join(__dirname, './mod-urls.txt');
const client = await getOrCreateSession();


const packHasUnits = async (packPath: string)  => {
    await client.loadPackFiles([packPath]);
    const exists = await client.folderExists("db/main_units_tables");
    await client.closePack();
    return exists;
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
        continue;
    }

    const syncResult = await synchronizeMods(WH3_APP_ID, [modId]);
    const packPath = getModPackPath(WH3_APP_ID, modId);

    // Check if the current mod contains main_units_tables.
    const containsUnits = await packHasUnits(packPath!);

    result[modId] = { ...modData, sync_status: syncResult[0].status, sync_ts: Date.now(), required: containsUnits };
}
await client.close();

console.log('result', result);
fs.writeFileSync(PATCH_MOD_PATH, JSON.stringify(result, null, 4));
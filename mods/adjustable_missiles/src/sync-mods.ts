import fs from 'fs';
import path from 'path';
const __dirname = import.meta.dirname;
import { synchronizeMods, getModInfo, type Mod } from "../../../lib/steam-workshop/steam-workshop.ts";
const APP_ID = 1142710;
const MOD_URL_LIST_PATH = path.join(__dirname, './mod-urls.txt');
const PATCH_MOD_PATH = path.join(__dirname, './patch-mods.json');


const modUrls = Array.from(new Set(fs.readFileSync(MOD_URL_LIST_PATH, "utf-8").split('\n').map(url => url.trim()).filter(Boolean)));
const modInfo = await getModInfo(modUrls);
fs.writeFileSync(PATCH_MOD_PATH, JSON.stringify(modInfo, null, 4));
const syncResults = await synchronizeMods(APP_ID, modInfo);
console.log('\nsync-mods results:');
syncResults.forEach(result => {
    console.log(`\n[${result.id}] ${result.title}:`);
    console.log(`Status: ${result.status}`);
    console.log(`URL: ${result.url}`)
});

// TODO: Clean up downloaded pack files after use.
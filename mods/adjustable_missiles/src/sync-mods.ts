import fs from 'fs';
import path from 'path';
const __dirname = import.meta.dirname;
import { synchronizeMods, type Mod } from "../../../lib/steam-workshop/steam-workshop.ts";
const PATCH_MOD_PATH = path.join(__dirname, './patch-mods.json');

const modList = JSON.parse(fs.readFileSync(PATCH_MOD_PATH, "utf-8")) as Mod[];

const syncResults = await synchronizeMods(modList);
console.log('\nsync-mods results:');
syncResults.forEach(result => {
    console.log(`\n[${result.id}] ${result.name}:`);
    console.log(`Status: ${result.status}`);
})
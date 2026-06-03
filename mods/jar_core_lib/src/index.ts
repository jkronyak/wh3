import 'dotenv/config';
import fs from 'fs';
import path from 'path';
const __dirname = import.meta.dirname;

const MOD_DIR = path.join(__dirname, '../');
console.log('MOD_DIR', MOD_DIR);
const MOD_STATIC_PATH = path.join(MOD_DIR, "src", "static");
const MOD_OUTPUT_PATH = path.join(MOD_DIR, "mod");
const MOD_DIST_PATH = path.join(MOD_DIR, "dist");
const GAME_DATA_FOLDER_PATH = "J:/SteamLibrary/steamapps/common/Total War WARHAMMER III/data";

console.log(
    MOD_DIR,
    MOD_STATIC_PATH,
    MOD_OUTPUT_PATH
)

const MOD_NAME = "jar_core_lib";

import { getOrCreateSession } from '../../../lib/rpfm-client/rpfm-client-instance.ts';
const client = await getOrCreateSession();

const run = async () => {
    for (const entry of fs.readdirSync(MOD_STATIC_PATH, { withFileTypes: true })) {
        if (entry.isDirectory()) {
            fs.cpSync(
                path.join(MOD_STATIC_PATH, entry.name),
                path.join(MOD_OUTPUT_PATH, entry.name),
                { recursive: true }
            );
        }
    }

    await client.send("NewPack");
    await client.insertPackedFiles([
            `${MOD_OUTPUT_PATH}/script`,
        ], 
        [
            { Folder: "" },
        ]
    );
    await client.savePackAs(`${MOD_DIST_PATH}/${MOD_NAME}.pack`);
    await client.savePackAs(`${GAME_DATA_FOLDER_PATH}/${MOD_NAME}.pack`);
    await client.closePack();
    client.close();


};

run();
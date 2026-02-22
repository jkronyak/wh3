import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { generateAbilityEffects } from "./ability-effects.ts";
import { generateUnitSets } from "./unit-sets.ts";
import { MOD_OUTPUT_PATH, MOD_DIST_PATH, MOD_STATIC_PATH } from "./config.ts";
import { RPFMClient } from "../../../lib/rpfmServer/rpfmClient.ts";
import { exit } from 'process';
const run = async () => {
    const client = new RPFMClient(process.env.RPFM_SERVER_PATH!);
    await client._connect();
    await generateUnitSets(0);
    await generateAbilityEffects(0);


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
    // await client.insertPackedFiles(["C:/Repos/wh3/mods/adjustable_missiles/mod/db"], [{ Folder: "db", }], null);
    await client.insertPackedFiles([`${MOD_OUTPUT_PATH}/db`, `${MOD_OUTPUT_PATH}/script`, `${MOD_OUTPUT_PATH}/ui`], [{ Folder: "db" }, { Folder: "" }, { Folder: "" }]);
    // const staticFolders = fs.readdirSync(MOD_STATIC_PATH);
    // for (const staticFolder of staticFolders) { 
    //     const l = await client.insertPackedFiles([`${MOD_STATIC_PATH}/${staticFolder}`], [{ Folder: staticFolder }]);
    //     console.log(staticFolder, l);
    // }
    // const l = await client.insertPackedFiles(staticFolders, [{ Folder: "" }]);
    // console.log('l', l);
    await client.savePackAs(`${MOD_DIST_PATH}/jar_adjustable_missiles_new.pack`);
    await client.closePack();
    await client.stop();
    exit();
};

run();
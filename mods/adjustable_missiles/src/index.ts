import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { MOD_OUTPUT_PATH, MOD_DIST_PATH, MOD_STATIC_PATH } from "./config.ts";
import { generateAbilityEffects } from "./ability-effects.ts";
import { generateUnitSets } from "./unit-sets.ts";
import { getOrCreateSession } from '../../../lib/rpfm-client/rpfm-client-instance.ts';
const client = await getOrCreateSession();

const run = async () => {
    await generateUnitSets();
    await generateAbilityEffects();


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
    await client.insertPackedFiles([`${MOD_OUTPUT_PATH}/db`, `${MOD_OUTPUT_PATH}/script`, `${MOD_OUTPUT_PATH}/ui`], [{ Folder: "db" }, { Folder: "" }, { Folder: "" }]);
    await client.savePackAs(`${MOD_DIST_PATH}/jar_adjustable_missiles_new.pack`);
    await client.closePack();
    client.close();
};

run();
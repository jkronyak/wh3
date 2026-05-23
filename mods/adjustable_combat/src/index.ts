import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { MOD_OUTPUT_PATH, MOD_DIST_PATH, MOD_STATIC_PATH, GAME_DATA_FOLDER_PATH, MOD_NAME } from "./config/mod-config.ts";
import { generateAbilityEffects } from "./generation/ability-effects.ts";
import { generateUnitSets } from "./generation/unit-sets.ts";
import { generateLua } from "./generation/option-config.ts";
import { getOrCreateSession } from '../../../lib/rpfm-client/rpfm-client-instance.ts';
const client = await getOrCreateSession();

const run = async () => {
    await client.send("GenerateDependenciesCache");

    await generateUnitSets(true);
    await generateAbilityEffects();
    await generateLua();

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
    await client.send({ SetDependencyPackFilesList: [[false, "jar_core_lib.pack"]]})
    await client.insertPackedFiles([`${MOD_OUTPUT_PATH}/db`, `${MOD_OUTPUT_PATH}/script`, `${MOD_OUTPUT_PATH}/ui`], [{ Folder: "db" }, { Folder: "" }, { Folder: "" }]);
    await client.send({
        OptimizePackFile: {
            pack_remove_itm_files: true,
            db_import_datacores_into_twad_key_deletes: true,
            db_optimize_datacored_tables: true,
            table_remove_duplicated_entries: true,
            table_remove_itm_entries: true,
            table_remove_itnr_entries: true,
            table_remove_empty_file: true,
            text_remove_unused_xml_map_folders: true,
            text_remove_unused_xml_prefab_folder: true,
            text_remove_agf_files: true,
            text_remove_model_statistics_files: true,
            pts_remove_unused_art_sets: true,
            pts_remove_unused_variants: true,
            pts_remove_empty_masks: true,
            pts_remove_empty_file: true,
        }
    })
    await client.savePackAs(`${MOD_DIST_PATH}/${MOD_NAME}.pack`);
    await client.savePackAs(`${GAME_DATA_FOLDER_PATH}/${MOD_NAME}.pack`);

    await client.closePack();
    client.close();
};

run();
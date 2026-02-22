// const { RPFMClient } = require('./rpfmClient');
import { RPFMClient } from '../lib/rpfmServer/rpfmClient.ts';
const rpfmServerExecPath = 'C:/Modding/Warhammer3/RPFMv4.7.100/rpfm_server.exe';
const packInputPath = "C:/Repos/wh3/lib/rpfmServer/jar_adjustable_missiles.pack";

const inputPaths = [
    "C:/Repos/wh3/lib/rpfmServer/jar_adjustable_missiles.pack",
    "C:/Repos/wh3/lib/rpfmServer/jar_rout_tweaks_less_speed.pack"
]

const execute = async () => {
    const server = new RPFMClient(rpfmServerExecPath);
    await server.start();
    // await server.send({ SetGameSelected: ["warhammer_3", false]})

    const r1 = await server.send({ OpenPackFiles: inputPaths });
    console.log('r1', r1);

    let r = await server.send("GetPackFilePath")
    console.log('r', r);
    // const rfileinfo = await server.send({ GetRFileInfo: })
    // await server.send({ GenerateDependenciesCache: [{ asskit_tables: '', vanilla_packed_files: '', parent_packed_files: '' }]})

    // const r2 = await server.send({ 
    //     ExtractPackedFiles: [{ PackFile: "db/effects_tables" }], destPath: "./", asTsv: true
    // });
    // const r2 = await server.send({ExtractPackedFiles: [{ PackFile: [{ File: "db/effects_tables/jar_adjustable_missiles__accuracy"}] }, "./", true] });

    // NOTE: export fails unless you generate dependencies cache beforehand
    const resp = await server.send({
        ExtractPackedFiles: [{
            PackFile: [
                // { Folder: "db/effect_bundles_tables" },
                // { File: "db/effects_tables" },
                { Folder: "db/effects_tables/jar_adjustable_missiles__accuracy" }
            ]
        }, "./_test_out", true]
    });
    // console.log('resp', resp);

    // const r3 = await server.send("Schema");
    // console.log("r3", r3);
    // console.log('r3', Object.keys(r3.Schema.definitions));
    // { 
    //     PackFile: [
    //         { Folder: "db/effect_bundles_tables" }, 
    //         { File: "db/effects_tables/jar_adjustable_missiles__accuracy"}
    //     ]
    // }


    // console.log('r2', r2);
    await server.stop();
};

// execute();

const exec = async () => {
    const client = new RPFMClient(rpfmServerExecPath);
    await client.start();
    let r
    r = await client.loadPackFiles(["C:/Repos/wh3/mods/adjustable_missiles/dist/jar_adjustable_missiles.pack"])
    r = await client.insertPackedFiles(["C:\\Repos\\wh3\\mods\\adjustable_missiles\\mod\\db"], [{ Folder: "db" }], null);
    console.log('r', r);

    // resp = await client.loadPackFiles(inputPaths);
    // console.log('resp', resp);

    // resp = await client.getTablePaths('unit_special_abilities_tables');
    // console.log('resp', resp);

    // resp = await client.getTreeView();

    // const requiredFiles = resp[1].filter(fileInfo => fileInfo.path.startsWith('db/unit_special_abilities_tables/')).map(fileInfo => ({ File: fileInfo.path }))
    // console.log('resp', resp);
    // resp = await client.extractPackedFiles({ PackFile: requiredFiles }, './out', true)

    // resp = await client.insertPackedFiles(["C:\\Repos\\wh3\\mods\\adjustable_missiles\\utils\\unit_set_generator\\input\\teb\\db\\main_units_tables"], [{ Folder: "db" }]);
    // console.log('resp', resp);

    await client.stop();
};

exec();
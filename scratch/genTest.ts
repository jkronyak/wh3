    
    // import { RPFMClient } from "../lib/rpfmServer/rpfmClient.ts";
    // const rpfmServerExecPath = 'C:/Modding/Warhammer3/RPFMv4.7.100/rpfm_server.exe';

    // const client = new RPFMClient(rpfmServerExecPath)
    // let r;
    // r = await client.send("NewPack");
    // r = await client.insertPackedFiles(["C:/Repos/wh3/mods/adjustable_missiles/mod/db"], [{ Folder: "db" }], null);
    // // r = await client.loadPackFiles(["C:/Repos/wh3/mods/adjustable_missiles/dist/jar_adjustable_missiles.pack"])
    // // r = await client.send({ SavePackedFileFromExternalView: ["db/unit_sets_tables", "C:/Repos/wh3/mods/adjustable_missiles/mod/db/unit_sets_tables/jar_adjustable_missiles.tsv"]})
    // // r = await client.insertPackedFiles(["C:\\Repos\\wh3\\mods\\adjustable_missiles\\mod\\db\\unit_sets_tables\\jar_adjustable_missiles.tsv"], [{ Folder: "db" }], null);
    // // r = await client.send({ GetPackedFilesInfo: ["jar_adjustable_missiles.pack"]})
    // // r = await client.send({ NewPackedFile: ["db", { DB: ["test_tbl", "unit_sets_tables", 2]}]});
    // console.log(r);
    // // r = await client.send({ ImportTSV: ["db/unit_sets_tables/jar_adjustable_missiles", "C:\\Repos\\wh3\\mods\\adjustable_missiles\\mod\\db\\unit_sets_tables\\jar_adjustable_missiles.tsv"]})
    // console.log('r', r);
    // await client.savePackAs(path.join(DIST_PATH, 'jar_adjustable_missiles2.pack'));
    // return await client.stop();
    // // const getModFilePaths = () => {
    // //     const paths: string[] = [];
    // //     const dbPath = path.join(MOD_OUTPUT_PATH, 'db');
    // //     const tblPaths = fs.readdirSync(dbPath);
    // //     tblPaths.forEach(tbl => {
    // //         const tblContents = fs.readdirSync(path.join(dbPath, tbl));
    // //         console.log('tblContent', tblContents);
    // //         paths.push(
    // //             ...tblContents.map(t => path.join(dbPath, tbl, t))
    // //         )
    // //     })
    // //     return paths;
    // // }
    // // const p = getModFilePaths();
    // // console.log('p', p);
    // let n;
    // let p =["C:\\Repos\\wh3\\mods\\adjustable_missiles\\mod\\db\\unit_sets_tables\\jar_adjustable_missiles.tsv"]
    
    // // n = await client.send("NewPack");
    // n = await client.loadPackFiles(["C:/Repos/wh3/mods/adjustable_missiles/dist/jar_adjustable_missiles.pack"])
    // // n = await client.send({ NewPackedFile: ['db', { DB: ["test", "unit_sets_tables", 2] } ] })
    // const c = fs.existsSync("C:/Repos/wh3/mods/adjustable_missiles/mod/db/unit_sets_tables/jar_adjustable_missiles.tsv");
    // console.log(c);
    // // n = await client.send({
    // //     AddPackedFiles: [
    // //         ["C:/Repos/wh3/mods/adjustable_missiles/mod/db/unit_sets_tables"],
    // //         [{ Folder: "db/unit_sets_tables"}],
    // //         null
    // //     ]
    // // })
    // // n = await client.send({
    // //     NewPackedFile: ["db", ]
    // // })
    // // n = await client.send({
    // //     AddPackedFiles: [
    // //         ["C:/Repos/wh3/mods/adjustable_missiles/mod/db/test"],
    // //         [{ Folder: "db/unit_sets_tables"}],
    // //         null
    // //     ]
    // // })
    // console.log('n', n);
    // n = await client.send({
    //     ImportTSV: [
    //         "db/unit_sets_tables/jar_adjustable_missiles",
    //         "C:/Repos/wh3/mods/adjustable_missiles/mod/db/unit_sets_tables/jar_adjustable_missiles.tsv"
    //     ]
    //     })
    // console.log('n', n);
    // // Load output into packfile

    // // console.log('dbPath', dbPath);
    // // const r= await client.insertPackedFiles(['C:\\Repos\\wh3\\mods\\adjustable_missiles_old\\utils\\unit_set_generator\\output\\db\\unit_sets_tables\\jar_adjustable_missiles__unit_sets.tsv'], [{ Folder: 'db'}]);
    // // console.log('r', r);
    

    // // const r= await client.insertPackedFiles(p, [{ Folder: "db" }]);
    // // console.log('r', r);
    // const r2 = await client.savePackAs(path.join(DIST_PATH, 'jar_adjustable_missiles2.pack'))
    // console.log('r2', r2);
    // await client.stop();
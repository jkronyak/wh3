const str = `3576835384|3349407231|3582943816|3157105199|3071058075|3279306741|3663101254|3204456842|3279306577|3296549245|2855155169|3592061984|3682936627|3663191603|3718323618|3718019340|3675455628|3719964945|2884276140|3717367851|3675477092|3712899901|3712899932|3434094468|3718037777|3722094372|3673849955|3170836889|3674469007|3682644065|3682644193|3685583354|3674549287|3278112051|3419889793|3008719674|3726564670|3726564851|3719798355|3677948227|2902803962|2827059394|2979155544|3680790065|2865974624|3053402711|3215474218|3231024410|3253398688|3149445431|2859968660|3724069727|3368217482|3573533329|3257109494|2998630271|3007996493|3512109914|2794696516|3029800597|3722205256|3305404052|3305404660|3290280611|2803817483|2939352017|2981528163|3156893047|2789872729|2796990765|2793720664|2789845128|2987536840|2802810577|2802811244|3004371352|2868273452|3166984131|3244980225|3720703201|2943382015|3044691047|3025510782|3079915520|2809686435|3592152960|2789850920|2789855135|2794192760|3055783983|2923584440|2958113532|2927955021|2854346056|2790733660|2931087074|2795421325|3297164969|2805826969|2789888346|3082390369|2856202634|3725583336|2789857945|3430887175|3485282424|3247433565|2804381193|2794064207|2790774407|3663273850|2859802328|3440143038|2854685719|3054249433|2903267289|3440283762|2792731173|3674295514|3626991681|3601814378|2854819509|2792727547|2876864283|2995252693|2790444477|3530687394|3241827850|2853239091|2855364225|3463177635|2789863945|3281249977|3140200173|3270487551|3117083206`;

const modIdArr = str.split('|');

// console.log(modIdArr);

const workshopPath = 'J:/SteamLibrary/steamapps/workshop/content/1142710';

import fs from 'fs';
import path from 'path';
import { getOrCreateSession } from '../../lib/rpfm-client/rpfm-client-instance.ts';
const client = await getOrCreateSession();

for (const id of modIdArr.filter(i => Number(i) === 2792731173)) {
    const curPath = path.join(workshopPath, id);
    const files = fs.readdirSync(curPath);
    const packFileName = files.find(f => f.endsWith('.pack'));
    const packFile = path.join(curPath, packFileName!);
    await client.loadPackFiles([packFile]);
    // const res = await client.send({ GetTablesByTableName: "campaign_map_attrition_damages_tables"});
    // const res = await client.getTablePaths("campaign_map_attritions_tables");
    // console.log('res', res);
    // if (res.length > 0) console.log(id, res);

    const searchRes = await client.send({
        GlobalSearch: {
            pattern: "attrition",
            replace_text: "attrition",
            case_sensitive: false,
            use_regex: false,
            source: "Pack",
            search_on: {
                  anim: false,
                anim_fragment_battle: false,
                anim_pack: false,
                anims_table: false,
                atlas: false,
                audio: false,
                bmd: false,
                db: true,
                esf: false,
                group_formations: false,
                image: false,
                loc: false,
                matched_combat: false,
                pack: true,
                portrait_settings: false,
                rigid_model: false,
                sound_bank: false,
                text: true,
                uic: false,
                unit_variant: false,
                unknown: false,
                video: false,
                schema: false,
            },
            matches: {
                anim: [],
                anim_fragment_battle: [],
                anim_pack: [],
                anims_table: [],
                atlas: [],
                audio: [],
                bmd: [],
                db: [],
                esf: [],
                group_formations: [],
                image: [],
                loc: [],
                matched_combat: [],
                pack: [],
                portrait_settings: [],
                rigid_model: [],
                sound_bank: [],
                text: [],
                uic: [],
                unit_variant: [],
                unknown: [],
                video: [],
                schema: { matches: [] },
            },
            game_key: "warhammer_3"
            
        }})
    console.log(searchRes.GlobalSearchVecRFileInfo[1].filter(i => i.path.startsWith('script') || i.path.startsWith('db')));

}

// campaign_map_attritions_tables
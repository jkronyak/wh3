
const fs = require('fs');
const path = require('path');
const filePath = `C:/Repos/wh3/mods/adjustable_missiles/temp/db/effect_bundles_tables/jar_adjustable_accuracy.tsv`


const data = fs.readFileSync(filePath, 'utf-8');
const lines = data.trim().split('\n');
const headers = lines[0].split('\t');

const sampleObj = lines.slice(2).map((line) => {
        const values = line.split("\t");
        return headers.reduce((obj, header, index) => {
            obj[header] = values[index];
            return obj;
        }, {});
    });

console.log(sampleObj[0]);
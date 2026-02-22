const fs = require("fs");
const path = require("path");
const { getTableVersion } = require('./helpers');

function parseTSV(filePath) {
    const data = fs.readFileSync(filePath, "utf-8");
    const lines = data.trim().split("\n");
    const headers = lines[0].split("\t");

    // Skip first two lines; line 1 is header; line P2 is export data comment
    return lines.slice(2).map((line) => {
        const values = line.split("\t");
        return headers.reduce((obj, header, index) => {
            obj[header] = values[index];
            return obj;
        }, {});
    });
}

function writeTSVWithVersion(filePath, data, dbTable, modTable) {
    const v = getTableVersion(dbTable);
    console.log('dbTable', dbTable, v);
    const schemaStr = `#${dbTable};${v};db/${dbTable}/${modTable}`;
    
    const headers = Object.keys(data[0]);
    const headerRow = headers.join("\t");
    const dataRows = data.map((obj) => headers.map((header) => obj[header] ?? "").join("\t"));
    
    const tsvContent = [headerRow, schemaStr, ...dataRows].join("\n");
    
    fs.mkdirSync(path.dirname(filePath), { recursive: true });
    fs.writeFileSync(filePath, tsvContent, "utf-8");
}

function writeTSV(filePath, data) {
    const headers = Object.keys(data[0]);
    const headerRow = headers.join("\t");

    const dataRows = data.map((obj) => headers.map((header) => obj[header] ?? "").join("\t"));

    const tsvContent = [headerRow, ...dataRows].join("\n");
    fs.mkdirSync(path.dirname(filePath), { recursive: true });
    fs.writeFileSync(filePath, tsvContent, "utf-8");
}

function parseTSVFolder(folderPath) {
    const files = fs.readdirSync(folderPath);
    const data = [];
    files
        .filter((file) => file.endsWith(".tsv"))
        .forEach((file) => {
            const curPath = path.join(folderPath, file);
            data.push(...parseTSV(curPath));
        });
    return data;
}

module.exports = {
    parseTSV,
    writeTSV,
    parseTSVFolder,
    writeTSVWithVersion
};

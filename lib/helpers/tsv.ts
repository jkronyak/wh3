import { readFileSync, mkdirSync, writeFileSync, readdirSync } from "fs";
import { dirname, join } from "path";

function parseTSV(filePath: string, cols?: string[]) {
    const data = readFileSync(filePath, "utf-8");
    const lines = data.trim().split("\n");
    const headers = lines[0]!.split("\t").filter(header => cols?.includes(header) ?? true);
    // console.log('headers', headers);
    // const keepColIndexs = cols?.map(c => headers.findIndex(h => c === h)) ?? null;
    // console.log('keepColIndexes', keepColIndexs);

    // Skip first two lines; line 1 is header; line P2 is export data comment
    return lines.slice(2).map((line) => {
        const values = line.split("\t");
        return headers.reduce((obj: Record<string, string>, header, index) => {
            obj[header] = values[index] ?? "";
            return obj;
        }, {});
    });
}

function writeTSV(filePath: string, data: any[], versionString: string | null = null) {
    const headers = Object.keys(data[0]);
    const headerRow = headers.join("\t");

    const dataRows = data.map((obj) => headers.map((header) => obj[header] ?? "").join("\t"));
    const tsvContent = [headerRow,  ...(versionString ? [versionString] : []), ...dataRows].join("\n");
    mkdirSync(dirname(filePath), { recursive: true });
    writeFileSync(filePath, tsvContent, "utf-8");
}

function parseTSVFolder(folderPath: string, cols?: string[]): Record<string, any>[] {
    const files = readdirSync(folderPath);
    const data: any[] = [];
    files
        .filter((file) => file.endsWith(".tsv"))
        .forEach((file) => {
            const curPath = join(folderPath, file);
            data.push(...parseTSV(curPath, cols));
        });
    return data;
}

export default {
    parseTSV,
    writeTSV,
    parseTSVFolder,
};

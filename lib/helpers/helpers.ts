import fs from 'fs';

export const sleep = (ms: number) => new Promise(res => setTimeout(res, ms));

export const readJSON = (filePath: string) => JSON.parse(fs.readFileSync(filePath, "utf-8"));
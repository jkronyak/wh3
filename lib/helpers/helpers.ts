import fs from 'fs';

export const sleep = (ms: number) => new Promise(res => setTimeout(res, ms));

export const readJSON = (filePath: string) => JSON.parse(fs.readFileSync(filePath, "utf-8"));

export const innerJoin = (
    left: Record<string, any>[],
    right: Record<string, any>[],
    leftOn: string,
    rightOn: string,
    leftCols: string[],
    rightCols: string[]
): Record<string, any>[] => { 
    const rightMapping = new Map(right.map(r => [r[rightOn], r]));
    const result = [];
    for (const l of left) { 
        const r = rightMapping.get(l[leftOn]);
        if (!r) continue;
        const combined: Record<string, any> = { ...l, ...r };

        const cols = [...leftCols, ...rightCols];
        result.push(
            cols.reduce( (acc, cur) => {
                if (cur in combined) acc[cur] = combined[cur];
                return acc;
            }, {} as Record<string, any>)
        )
    }
    return result;

};


const decodeACF = (text: string) => { 
    const result: Record<string, any> = {};
    const lines = text.split('\n');

    let stack: string[] = [];   // Tracks current nested path

    lines.forEach(line => {
        const tokens = line.trim().replaceAll('"', '').split(/\s+/).filter(Boolean);
        
        // If the current line has a single token (ex. key for an object, or a curly brace)
        if (tokens.length === 1) {
            const tkn = tokens[0]!.toString();
            if (tkn === '{') return;    // Starting brace for current objec ; skip current line.
            else if (tkn === '}') return stack.pop();   // Current object finished; remove from stack.
            else {
                // Entering object; add the nested path to the result and add to stack.
                const tgt = stack.reduce((acc, cur) => acc[cur], result);
                tgt[tkn] = {};
                stack.push(tkn);
            }
        } else if (tokens.length === 2) {
            // Otherwise check if the current line has two tokens (ex. key-value pair)
            // Add the pair at the correct nesting level in the result
            const key = tokens[0]!;
            const val = tokens[1]!;
            const tgt = stack.reduce((acc, cur) => acc[cur], result);
            tgt[key] = val; 
        }
    });
    return result;
}

export { decodeACF };


// import path from 'path';
// const __dirname = import.meta.dirname;
// import fs from 'fs';
// const APP_ID = '1142710';
// const WORKSHOP_FOLDER_PATH = "C:/Modding/SteamCMD/steamapps/workshop"

// const filePath = path.join(WORKSHOP_FOLDER_PATH, `appworkshop_${APP_ID}.acf`);
// const testFile = fs.readFileSync(filePath, 'utf-8')
// const res = decode(testFile)
// console.log('res', JSON.stringify(res, null, 4));
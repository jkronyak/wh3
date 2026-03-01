
import 'dotenv/config';
import path from 'path';
import fs from 'fs';
import { exec, execSync } from 'child_process';
import { sleep } from '../helpers/helpers.ts';

const STEAM_API_BASE_URL = "https://api.steampowered.com"
const STEAM_CMD_PATH = process.env.STEAM_CMD_PATH!;
const STEAM_CMD_USER = process.env.STEAM_CMD_USER!;
const MANIFEST_FOLDER_PATH = path.join(process.env.STEAM_CMD_PATH!, "steamapps", "workshop");

type Mod = {
    id: string | number;
    appId: string | number;
    url: string;
    name: string;
};

type SyncResult = Mod & { 
    status: 'success' | 'fail' | 'nochange' | null
}

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

const getLocalManifest = (appId: string | number): Record<string, any> | null => {
    const manifestPath = path.join(MANIFEST_FOLDER_PATH, `appworkshop_${appId}.acf`);
    if (!fs.existsSync(manifestPath)) return null;
    const manifestContent = decodeACF(fs.readFileSync(manifestPath, "utf-8")).AppWorkshop;
    return manifestContent;
}

const getLocalManifestId = (appId: string | number, modId: string | number = ""): string | null => {
    const manifestContent = getLocalManifest(appId);
    return manifestContent?.WorkshopItemsInstalled[modId]?.manifest ?? null;
}

const getLocalManifestIdMulti = (
    appId: string | number,
    modIdList: string[] | number[]
): Record<string, string | null> | null => {
    const manifestContent = getLocalManifest(appId);
    if (!manifestContent) return null;
    const workshopItemDetails = manifestContent.WorkshopItemDetails;
    const manifestMapping: Record<string, string | null> = {};
    modIdList.forEach(modId => manifestMapping[modId] = workshopItemDetails[modId].manifest ?? null);
    console.log('manifestMpping', manifestMapping);
    return manifestMapping;
}

const getRemoteManifestId = async (modId: string | number): Promise<string | null> => {
    const params = new URLSearchParams({ itemcount: '1', 'publishedfileids[0]': String(modId) })
    const response = await fetch(`${STEAM_API_BASE_URL}/ISteamRemoteStorage/GetPublishedFileDetails/v1/`, {
        method: 'POST',
        body: params
    });
    if (!response.ok) throw new Error(`Remote manifest request request failed: ${response.status} ${response.statusText}`)
    const respJson = await response.json() as Record<string, any>;
    const manifestId = respJson?.response?.publishedfiledetails[0]?.hcontent_file ?? null;
    return manifestId;
}

const getRemoteManifestModMapping = async (modIdList: string[] | number[]): Promise<string[] | null> => {
    const manifestMapping = Object.fromEntries(await Promise.all(modIdList.map(async modId => [modId, await getRemoteManifestId(modId)])));
    console.log('manifestMapping', manifestMapping);
    return null;
};


/**
 * Checks if the mod with the supplied appId and modId exist on disk
 * in the Steam CMD directory.
 */
const isModDownloaded = (appId: string | number, modId: string | number): boolean => {
    const modFolderPath = path.join(STEAM_CMD_PATH, "steamapps", "workshop", "content", String(appId), String(modId));
    if (!fs.existsSync(modFolderPath)) return false;
    const modPackPath = fs.readdirSync(modFolderPath).find(file => file.endsWith('.pack'));
    return Boolean(modPackPath);
}

/**
 * Compares the local and remote manifest ID for the mod with the
 * supplied appId and modId.
 */
const isModUpdated = async (appId: string | number, modId: string | number): Promise<boolean> => {
    const localManifestId = getLocalManifestId(appId, modId);
    const remoteManifestId = await getRemoteManifestId(modId);
    return Boolean(localManifestId && remoteManifestId) && (localManifestId === remoteManifestId);
};


/**
 * Downloads the desired mod via SteamCMD to the default folder; optionally removes existing folder
 * to prevent an error during the download.
 */
const downloadMod = async (appId: string | number, modId: string | number, deleteIfExists: boolean = true): Promise<any> => {
    if (deleteIfExists) deleteMod(appId, modId);
    const execRes = execSync(`${STEAM_CMD_PATH}/steamcmd.exe +login ${STEAM_CMD_USER} +workshop_download_item ${appId} ${modId} +quit`, { encoding: 'utf-8' });
    const modFolderPath = path.join(STEAM_CMD_PATH, "steamapps", "workshop", "content", String(appId), String(modId));
    const exists = fs.existsSync(modFolderPath);
    if(!exists) console.log(execRes);
    return exists;
}

/**
 * Deletes the desired mod's folder if it exists; returns whether the folder exists after.
 */
const deleteMod = (appId: string | number, modId: string | number): Boolean => {
    const modFolderPath = path.join(STEAM_CMD_PATH, "steamapps", "workshop", "content", String(appId), String(modId));
    fs.rmSync(modFolderPath, { recursive: true, force: true });
    return !fs.existsSync(modFolderPath);
}

const getModPackPath = (appId: string | number, modId: string | number): string | null => {
    const modFolderPath = path.join(STEAM_CMD_PATH, "steamapps", "workshop", "content", String(appId), String(modId));
    if (!fs.existsSync(modFolderPath)) return null;
    const modPackPath = fs.readdirSync(modFolderPath).find(file => file.endsWith('.pack'));
    if (!modPackPath) return null;
    return path.join(modFolderPath, modPackPath);
}

const synchronizeMods = async (modList: Mod[]): Promise<SyncResult[]> => {

    // const syncResults: Record<string, any>[] = [];
    const syncResults: SyncResult[] = [];
    for (const mod of modList) {
        console.log(`Checking sync status for ${mod.name} (${mod.url})`);
        const isCurrent = await isModUpdated(mod.appId, mod.id);
        const isDownloaded = isModDownloaded(mod.appId, mod.id);

        const curResult: SyncResult = { ...mod, status: null };
        const currentStatus = isCurrent ? 'current' : 'outdated';
        const downloadedStatus = isDownloaded ? 'present' : 'missing';
        console.log(`Status: ${currentStatus} and ${downloadedStatus}`);
        if (!isCurrent || !isDownloaded) {

            console.log('Downloading mod...');
            const dlRes = await downloadMod(mod.appId, mod.id, true);
            const syncStatus = dlRes ? 'success' : 'fail';
            console.log(`Download ${syncStatus}`);
            curResult.status = syncStatus;
        } else {
            curResult.status = 'nochange';
        }
        syncResults.push(curResult);
    }

    return syncResults;
}

/*
    Should the "main" function simply return the status for all mods? 

*/
export {
    getLocalManifest,
    getLocalManifestId,
    getRemoteManifestId,
    getRemoteManifestModMapping,
    getLocalManifestIdMulti,
    isModDownloaded,

    synchronizeMods,
    getModPackPath,
    type Mod
}
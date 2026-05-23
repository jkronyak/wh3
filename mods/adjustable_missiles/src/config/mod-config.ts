import path from 'path';
const __dirname = import.meta.dirname;

// General
export const MOD_TITLE = "Adjustable Missiles";

export const MOD_NAME = "jar_adjustable_missiles";

export const MOD_PREFIX = "jar_adj_mis";

export const MOD_DESCRIPTION = "Allows you to rebalance missile unit stats!";

// Paths
export const MOD_DIR = path.join(__dirname, '../../');

export const REF_PATH = path.join(MOD_DIR, "temp", "ref");

export const PATCH_MOD_PATH = path.join(MOD_DIR, "src", "patch-mods.json");

export const MOD_INPUT_PATH = path.join(MOD_DIR, "input");

export const MOD_OUTPUT_PATH = path.join(MOD_DIR, "mod");

export const MOD_DIST_PATH = path.join(MOD_DIR, "dist");

export const MOD_STATIC_PATH = path.join(MOD_DIR, "src", "static");

export const REPORT_PATH = path.join(MOD_DIR, "reports");

export const MOD_TABLE_NAME = 'jar_adjustable_missiles';

export const GAME_DATA_FOLDER_PATH = "J:/SteamLibrary/steamapps/common/Total War WARHAMMER III/data";

export const WH3_APP_ID = 1142710;
const fs = require("fs");
const path = require('path');
const url = "https://raw.githubusercontent.com/Frodo45127/rpfm-schemas/171fae99bc240972d45f0fda6537b2a6cf2187a9/schema_wh3.ron";

const fetchSchema = async () => { 
    const resp = await fetch(url);
    fs.writeFileSync(path.join(__dirname, 'wh3_schema.ron'), await resp.text());
}
fetchSchema();

const tables = [
    "effect_bonus_value_ids_unit_sets_tables",
    "effect_bonus_value_unit_set_unit_ability_junctions_tables",
    "effect_bundles_tables",
    "effects_tables",
    "special_ability_to_special_ability_phase_junctions_tables",
    "unit_abilities_tables",
    "unit_set_to_unit_junctions_tables",
    "unit_set_to_unit_junctions_tables",
    "unit_set_unit_ability_junctions_tables",
    "unit_sets_tables",
    "unit_special_abilities_tables",
    "special_ability_phases_tables",
    "special_ability_phase_stat_effects_tables",
];

function getTableVersion(ronContent, tableName) {
    // Match the table name and capture the version number
    const pattern = new RegExp(`"${tableName}":\\s*\\[\\s*\\(\\s*version:\\s*(\\d+)`, 'm');
    const match = ronContent.match(pattern);
    return match ? parseInt(match[1]) : null;
}

// Read the .ron file
const ronContent = fs.readFileSync(path.join(__dirname,'./wh3_schema.ron'), 'utf8');

// Extract versions for all tables
const tableVersions = {};
for (const table of tables) {
    const version = getTableVersion(ronContent, table);
    if (version !== null) {
        tableVersions[table] = version;
    } else {
        console.warn(`Warning: Could not find version for table: ${table}`);
    }
}

fs.writeFileSync(path.join(__dirname, 'table_versions.json'), JSON.stringify(tableVersions))
// console.log(tableVersions);
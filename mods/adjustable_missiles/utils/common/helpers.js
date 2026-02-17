const fs = require('fs');
const TABLE_VERSION_PATH = 'schema/table_versions.json';
const tableVersions = JSON.parse(fs.readFileSync(TABLE_VERSION_PATH), 'utf8');

const getTableVersion = table => tableVersions[table];

module.exports = { 
    getTableVersion
};
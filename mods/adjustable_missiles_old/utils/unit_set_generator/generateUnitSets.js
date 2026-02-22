
const fs = require("fs");
const path = require("path");

const { writeTSV, parseTSVFolder, writeTSVWithVersion } = require("../common/tsv");
const { parentGroupUnitSetMap, unitCastExcludeList, unitSets, modUnitSets } = require("../common/config");
const { getTableVersion } = require('../common/helpers');

const INPUT_PATH = path.join(__dirname, "input");
const OUTPUT_PATH = path.join(__dirname, "output");
const REFERENCE_PATH = path.join(__dirname, "reference");

const getReferenceData = tableName => parseTSVFolder(path.join(REFERENCE_PATH, "db", tableName));
const getModTableData = (modName, tableName) => parseTSVFolder(path.join(INPUT_PATH, modName, "db", tableName));

const getInputModFolders = () => fs.readdirSync(INPUT_PATH, { withFileTypes: true }).filter(f => f.isDirectory()).map(f => f.name);

const joinUnitAndGroupData = (units, groups, casteExclusions = []) => { 
    console.log(`Joining unit data with UI group data and excluding castes ${casteExclusions.join(', ')}`);
    const result = [];
    for (const unit of units) {
        if (!unitCastExcludeList.includes(unit.caste)) {
            const unitKey = unit.unit;
            const unitGroup = unit.ui_unit_group_land;
            const parentGroup = groups.find(group => group.key === unitGroup)?.parent_group ?? false;
            if (!parentGroup) throw new Error(`Error: Unable to find parent_group for ${unitKey}. Record: ${JSON.stringify(unit)}`);
    
            result.push({
                key: unitKey,
                group: unitGroup,
                parentGroup: parentGroup,
            });
        }
    }
    return result;
};

const generateUnitSets = (units) => { 
    console.log('Generating unit sets');
    return units.map(unit => ({
        unit_caste: '',
        unit_category: '',
        unit_class: '',
        unit_record: unit.key,
        unit_set: parentGroupUnitSetMap[unit.parentGroup],
        exclude: false
    })).toSorted((a, b) => a.unit_set.localeCompare(b.unit_set));
}

const writeUnitSetsTable = () => { 
    const unitSetsPath = path.join(OUTPUT_PATH, "db", "unit_sets_tables", "jar_adjustable_missiles__unit_sets.tsv");
    const unitSetsData = modUnitSets.map(set => ({ 
        key: set,
        use_unit_exp_level_range: "false",
        min_unit_exp_level_inclusive: -1,
        max_unit_exp_level_inclusive: -1,
        special_category: ""
    }));
    writeTSVWithVersion(unitSetsPath, unitSetsData, "unit_sets_tables", "jar_adjustable_missiles__unit_sets")
    // writeTSV(unitSetsPath, unitSetsData);
}

const writeUnitSetToUnitJunctionsTable = (modName, data) => { 
    const tablePath = path.join(OUTPUT_PATH, "db", "unit_set_to_unit_junctions_tables", `jar_adjustable_missiles__${modName}.tsv`);
    writeTSVWithVersion(tablePath, data, "unit_set_to_unit_junctions_tables", `jar_adjustable_missiles__${modName}`);
    // writeTSV(tablePath, data);
};

const generate = () => {
    // 1. Load necessary reference tables.
    const referenceData = { ui_unit_groupings_tables: getReferenceData("ui_unit_groupings_tables") };
    // console.log(referenceData)

    // 2. Process each mod in the input folder.
    const modFolders = getInputModFolders();
    console.log('modfolders', modFolders);
    for (const mod of modFolders) {

        // 2.1 Retrieve the relevant table data from the mod input folder.
        console.log(`\nStarting generation for mod: ${mod}`);
        const mainUnitData = getModTableData(mod, "main_units_tables");
        const uiUnitGroupData = getModTableData(mod, "ui_unit_groupings_tables");
        // Join the reference ui_unit_groupings_tables table from vanilla if we are not
        // currently processing vanilla.
        if (mod !== 'vanilla') { 
            uiUnitGroupData.push(...referenceData.ui_unit_groupings_tables);
        }

        // 2.2 Join the unit data with associated UI group and unit set.
        const joinedUnitData = joinUnitAndGroupData(mainUnitData, uiUnitGroupData);
        console.log('joined', joinedUnitData.length);
        // Filter out any units from the exclude list; ex. lords and heroes.
        // const joinedUnitDataFiltered = joinedUnitData.filter(i => !unitCastExcludeList.includes(i.caste))
        // console.log('filtered', joinedUnitDataFiltered.length);

        // 3. Generate unit sets from the joined data.
        const unitSets = generateUnitSets(joinedUnitData);
        console.log('unit sets', unitSets.length);
        // console.log(unitSets);

        // 4. Write unit_sets_tables and unit_set_to_unit_junction_tables
        writeUnitSetsTable();
        writeUnitSetToUnitJunctionsTable(mod, unitSets);

    }
}

generate()
/*
    Accuracy required tables:

    +unit_abilities_tables
    +unit_special_abilities_tables
    +special_abilities_phases_tables
    +special_ability_to_special_ability_phase_junctions_tables
    +special_ability_phase_stat_effects_tables

    +effects_tables
    +unit_set_unit_ability_junctions_tables
    +effect_bonus_value_unit_set_unit_ability_junctions_tables

*/
const fs = require("fs");
const path = require("path");

const { writeTSV, writeTSVWithVersion } = require("../common/tsv");
const { modUnitSets } = require("../common/config");

const OUTPUT_PATH = path.join(__dirname, "output");

const accMin = -5;
const accMax = 5;

const unitAbilitiesTableRow = ({ set, acc }) => ({
    key: `jar_adjustable_missiles__ability__acc__${set}__${acc > 0 ? `+${acc}` : acc.toString()}`,
    requires_effect_enabling: "false",
    icon_name: "jar_accuracy",
    overpower_option: "",
    type: "wh_type_hex",
    video: "",
    uniqueness: "wh_main_anc_group_common",
    is_unit_upgrade: false,
    is_hidden_in_ui: false, // TODO: add separate option for this, default true
    source_type: "passive",
    superseded_abilities_set: "",
    is_hidden_in_ui_for_enemy: "false",
});

const unitSpecialAbilitiesTableRow = ({ set, acc, uid }) => ({
    key: `jar_adjustable_missiles__ability__acc__${set}__${acc > 0 ? `+${acc}` : acc.toString()}`,
    active_time: "-1.0000",
    recharge_time: "-1.0000",
    num_uses: "-1",
    effect_range: "0.0000",
    affect_self: true,
    num_effected_friendly_units: "0",
    num_effected_enemy_units: "0",
    update_targets_every_frame: false,
    initial_recharge: "-1.0000",
    activated_projectile: "",
    target_friends: false,
    target_enemies: false,
    target_ground: false,
    target_intercept_range: "0.0000",
    always_affect_self: false,
    only_affect_target: false,
    wind_up_time: "0.0000",
    passive: true,
    // unique_id: "571363808",
    unique_id: uid,
    bombardment: "",
    spawned_unit: "",
    wind_up_stance: "",
    mana_cost: "0.0000",
    min_range: "0.0000",
    targetting_aoe: "wh_abilities_generic_debuff_no_ring",
    passive_aoe: "",
    active_aoe: "",
    activation_effect: "",
    vortex: "",
    miscast_chance: "0.0000",
    miscast_explosion: "",
    ai_usage: "",
    audio: "",
    special_ability_display: "",
    voiceover_state: "vo_battle_special_ability_generic_response",
    additional_melee_cp: "0.0000",
    additional_missile_cp: "0.0000",
    parent_ability: "",
    spawn_type: "",
    spawn_proxy_vfx: "",
    target_ground_under_allies: false,
    target_ground_under_enemies: false,
    miscast_global_bonus: true,
    target_self: false,
    composite_scene_group_on_wind_up: "",
    composite_scene_group_on_active: "",
    wind_down_stance: "",
    use_loop_stance: false,
    update_phase_by_ability_duration: false,
    spawn_is_transformation: false,
    spawn_is_decoy: false,
    only_affect_owned_units: false,
    formation: "",
    behaviour: "",
    current_mana_moves_to_reserve: false,
    spawn_shares_health_and_fatigue: false,
    affect_siege_equipment: true,
    shared_recharge_time: "-1.0000",
    intensity_based_activation: false,
    autoresolver_usage: "disabled",
    autoresolver_targets: "1",
    display_stops_when_display_expires: false,
    autoresolve_cp_multiplier: "1.0000",
    ability_available_ui_event: "",
    can_be_copied_to_transformation_unit: true,
    audio_switch_casting_override: "",
    audio_switch_ui_override: "",
    ai_usage_template_group: "",
    audio_vo_actor_override: "",
    mom_vortex_key: "",
});

const specialAbilityPhasesTableRow = ({ acc }) => ({
    id: `jar_adjustable_missiles__ability_phase__acc__${acc > 0 ? `+${acc}` : acc.toString()}`,
    duration: "0.0000",
    effect_type: "negative",
    requested_stance: "",
    cant_move: "false",
    freeze_fatigue: "false",
    fatigue_change_ratio: "0.0000",
    inspiration_aura_range_mod: "0.0000",
    ability_recharge_change: "0.0000",
    hp_change_frequency: "0.0000",
    damage_amount: "0",
    max_damaged_entities: "-1",
    resurrect: "false",
    mana_regen_mod: "0.0000",
    mana_max_depletion_mod: "0.0000",
    imbue_magical: "false",
    imbue_ignition: "0",
    imbue_contact: "",
    phase_display: "",
    phase_audio: "",
    is_hidden_in_ui: "false",
    affects_allies: "true",
    affects_enemies: "true",
    replenish_ammo: "0.0000",
    composite_scene_group: "",
    spreading: "",
    freeze_recharge: "false",
    heal_amount: "0.0000",
    barrier_heal_amount: "0.0000",
    remove_magical: "false",
    execute_ratio: "0.0000",
});

const specialAbilityToSpecialAbilityPhaseJunctionTableRow = ({ set, acc }) => ({
    order: 0,
    special_ability: `jar_adjustable_missiles__ability__acc__${set}__${acc > 0 ? `+${acc}` : acc.toString()}`,
    target_self: "true",
    target_friends: "false",
    target_enemies: "false",
    phase: `jar_adjustable_missiles__ability_phase__acc__${acc > 0 ? `+${acc}` : acc.toString()}`,
});

const specialAbilityPhaseStateEffectsTableRow = ({ acc }) => ({
    phase: `jar_adjustable_missiles__ability_phase__acc__${acc > 0 ? `+${acc}` : acc.toString()}`,
    stat: "stat_accuracy",
    value: acc,
    how: "add",
});

const effectsTableRow = ({ set, acc }) => ({
    effect: `jar_adjustable_missiles__effect__acc__${set}__${acc > 0 ? `+${acc}` : acc.toString()}`,
    icon: 'general_ability.png',
    priority: 0,
    icon_negative: 'general_ability.png',
    category: 'campaign', 
    is_positive_value_good: true
});

const unitSetUnitAbilityJunctionsTableRow = ({ set, acc}) => ({
    key: `jar_adjustable_missiles__unit_set_ability__acc__${set}__${acc > 0 ? `+${acc}` : acc.toString()}`,
    unit_ability: `jar_adjustable_missiles__ability__acc__${set}__${acc > 0 ? `+${acc}` : acc.toString()}`,
    unit_set: set,
});

const effectBonusValueUnitSetUnitAbilityJunctionsTableRow = ({ set, acc }) => ({
    bonus_value_id: 'enable',
    effect: `jar_adjustable_missiles__effect__acc__${set}__${acc > 0 ? `+${acc}` : acc.toString()}`,
    unit_set_ability: `jar_adjustable_missiles__unit_set_ability__acc__${set}__${acc > 0 ? `+${acc}` : acc.toString()}`,
});

const effectBundlesTableRow = () => ({
    key: 'jar_adjustable_missiles__effect_bundle',
    localised_description: '',
    localised_title: '',
    bundle_target: 'faction',
    priority: '1',
    ui_icon: 'jar_accuracy.png',
    is_global_effect: 'true',
    show_in_3d_space: 'false',
    owner_only: 'true'
})

// Tables that require separate entires per each accuracy and unit set combination.
const perSetPerValFuncMap = {
    unit_abilities_tables: unitAbilitiesTableRow,
    unit_special_abilities_tables: unitSpecialAbilitiesTableRow,
    special_ability_to_special_ability_phase_junctions_tables: specialAbilityToSpecialAbilityPhaseJunctionTableRow,
    effects_tables: effectsTableRow,
    unit_set_unit_ability_junctions_tables: unitSetUnitAbilityJunctionsTableRow,
    effect_bonus_value_unit_set_unit_ability_junctions_tables: effectBonusValueUnitSetUnitAbilityJunctionsTableRow,
};

// Tables that require separate entires only per each accuracy value.
const perValFuncMap = {
    special_ability_phases_tables: specialAbilityPhasesTableRow,
    special_ability_phase_stat_effects_tables: specialAbilityPhaseStateEffectsTableRow,
};

const generate = () => {
    const firstUid = 112144626;
    let uidCount = firstUid;
    const tableData = {};
    tableData['effect_bundles_tables'] = [effectBundlesTableRow()];
    for (let acc = accMin; acc <= accMax; acc++) {
        const curUid = uidCount++;
        for (const set of modUnitSets) {
            // Process tables that have entries per set per val
            for (const key in perSetPerValFuncMap) {
                (tableData[key] ??= []).push(perSetPerValFuncMap[key]({ set, acc, uid: curUid }));
            }
        }
        // Process tables that have entries only per val
        for (const key in perValFuncMap) {
            (tableData[key] ??= []).push(perValFuncMap[key]({ acc, uid: curUid }));
        }
    }

    for (const [table, data] of Object.entries(tableData)) { 
        // console.log('table', table);
        const tablePath = path.join(OUTPUT_PATH, "db", table, "jar_adjustable_missiles__accuracy.tsv");
        writeTSVWithVersion(tablePath, data, table, "jar_adjustable_missiles__accuracy")
        // writeTSV(tablePath, data);
    }

};

generate();

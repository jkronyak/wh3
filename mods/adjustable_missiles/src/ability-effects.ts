import 'dotenv/config';
import path from 'path';
import tsv from '../../../lib/helpers/tsv.ts';
import { MOD_UNIT_SETS, MOD_OUTPUT_PATH } from "./config.ts";
import { getOrCreateSession } from '../../../lib/rpfm-client/rpfm-client-instance.ts';
const client = await getOrCreateSession();

const UID_START = 644261121;

const ACC_MIN = -100;
const ACC_MAX = 100;

let curUid = UID_START;

type TableName =
    | "unit_abilities_tables"
    | "unit_special_abilities_tables"
    | "special_ability_phases_tables"
    | "special_ability_to_special_ability_phase_junctions_tables"
    | "special_ability_phase_stat_effects_tables"
    | "effects_tables"
    | "unit_set_unit_ability_junctions_tables"
    | "effect_bonus_value_unit_set_unit_ability_junctions_tables"
    | "effect_bonus_value_ids_unit_sets_tables"
    | "effect_bundles_tables"


const accSuf = (acc: number) => acc > 0 ? `+${acc}` : `${acc}`;

// Partial<Record<TableName, Function>> 
// Record<string, Partial<<Record<TableName, Function>>>> 
const accuracyRowGenerators: Record<string, Partial<Record<TableName, Function>>> = {

    SetAndAcc: {
        unit_abilities_tables: (set: string, acc: number) => ({
            key: `jar_adjustable_missiles__ability__acc__${set}__${accSuf(acc)}`,
            requires_effect_enabling: "false",
            icon_name: "jar_accuracy",
            overpower_option: "",
            type: "wh_type_hex",
            video: "",
            uniqueness: "wh_main_anc_group_common",
            is_unit_upgrade: false,
            is_hidden_in_ui: true, // TODO: add separate option for this, default false
            source_type: "passive",
            superseded_abilities_set: "",
            is_hidden_in_ui_for_enemy: "false",
        }),
        unit_special_abilities_tables: (set: string, acc: number) => ({
            key: `jar_adjustable_missiles__ability__acc__${set}__${accSuf(acc)}`,
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
            unique_id: curUid++, // Increment UID here.
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
        }),
        special_ability_to_special_ability_phase_junctions_tables: (set: string, acc: number) => ({
            order: 0,
            special_ability: `jar_adjustable_missiles__ability__acc__${set}__${accSuf(acc)}`,
            target_self: "true",
            target_friends: "false",
            target_enemies: "false",
            phase: `jar_adjustable_missiles__ability_phase__acc__${accSuf(acc)}`,
        }),
        effects_tables: (set: string, acc: number) => ({
            effect: `jar_adjustable_missiles__effect__acc__${set}__${accSuf(acc)}`,
            icon: 'general_ability.png',
            priority: 0,
            icon_negative: 'general_ability.png',
            category: 'campaign',
            is_positive_value_good: true
        }),
        unit_set_unit_ability_junctions_tables: (set: string, acc: number) => ({
            key: `jar_adjustable_missiles__unit_set_ability__acc__${set}__${accSuf(acc)}`,
            unit_ability: `jar_adjustable_missiles__ability__acc__${set}__${accSuf(acc)}`,
            unit_set: set,
        }),
        effect_bonus_value_unit_set_unit_ability_junctions_tables: (set: string, acc: number) => ({
            bonus_value_id: 'enable',
            effect: `jar_adjustable_missiles__effect__acc__${set}__${accSuf(acc)}`,
            unit_set_ability: `jar_adjustable_missiles__unit_set_ability__acc__${set}__${accSuf(acc)}`,
        })
    },
    Acc: {
        special_ability_phases_tables: (acc: number) => ({
            id: `jar_adjustable_missiles__ability_phase__acc__${accSuf(acc)}`,
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
            is_hidden_in_ui: false,
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
        }),
        special_ability_phase_stat_effects_tables: (acc: number) => ({
            phase: `jar_adjustable_missiles__ability_phase__acc__${accSuf(acc)}`,
            stat: "stat_accuracy",
            value: acc,
            how: "add",
        })
    }
};

const singleRowGenerators: Partial<Record<TableName, Function>> = {
    effect_bundles_tables: () => ({
        key: 'jar_adjustable_missiles__effect_bundle',
        localised_description: '',
        localised_title: '',
        bundle_target: 'faction',
        priority: '1',
        // ui_icon: 'jar_accuracy.png',
        ui_icon: '', // hide in UI
        is_global_effect: 'true',
        show_in_3d_space: 'false',
        owner_only: 'true'
    })
};

const otherStatRowGenerators: Partial<Record<TableName, Function>> = {
    effects_tables: (set: string, stat: string) => ({
        effect: `jar_adjustable_missiles__effect__${stat}__${set}`,
        icon: 'general_ability.png',
        priority: 0,
        icon_negative: 'general_ability.png',
        category: 'campaign',
        is_positive_value_good: true
    }),
    effect_bonus_value_ids_unit_sets_tables: (set: string, stat: string) => ({
        bonus_value_id: stat,
        effect: `jar_adjustable_missiles__effect__${stat}__${set}`,
        unit_set: set
    })
};


type TableResult = Partial<Record<TableName, Record<string, any>[]>>;

const writeModTable = async (data: Record<string, any>[], dbTable: string, tableName: string): Promise<void> => {
    const writePath = path.join(MOD_OUTPUT_PATH, "db", dbTable, `${tableName}__jam.tsv`);
    const version = await client.getTableVersionString(dbTable, tableName);
    tsv.writeTSV(writePath, data, version);
}

// TODO: Refactor and cleanup typing.
const generateAbilityEffects = async () => {

    const tableResult: TableResult = {};
    // Add the effect bundle.
    tableResult["effect_bundles_tables"] = [singleRowGenerators["effect_bundles_tables"]!()];

    console.log('Generating ability and effects records.')
    for (let acc = ACC_MIN; acc <= ACC_MAX; acc++) {
        // Process data that has to be generated per unit set per accuracy value.
        for (const unitSet of MOD_UNIT_SETS) {
            for (const [table, func] of Object.entries(accuracyRowGenerators.SetAndAcc!) as [TableName, Function][]) {
                (tableResult[table] ??= []).push(func(unitSet, acc));
            }
        }

        // Process data to be generated per accuracy value only.
        for (const [table, func] of Object.entries(accuracyRowGenerators.Acc!) as [TableName, Function][]) {
            (tableResult[table] ??= []).push(func(acc));
        }

    }

    // Process data to be generated per unit set per stat type (reload, range).
    const statMods = [
        'reload',

        'range_mod',
        'ammo_mod',

        'missile_damage_mod_mult',
        'missile_damage_ap_mod_mult',

        'missile_explosion_damage_mod_mult',
        'missile_explosion_damage_ap_mod_mult',

        'missile_damage_mod_add',
        'missile_damage_ap_mod_add',

        'missile_explosion_radius',
    
    ];
    for (const unitSet of MOD_UNIT_SETS) { 
        for (const statMod of statMods) {
            for (const [table, func] of Object.entries(otherStatRowGenerators) as [TableName, Function][]) {
                (tableResult[table] ??= []).push(func(unitSet, statMod));
            }
        }
    }

    // Write output to mod folder.
    console.log('Created the following number of records for each table:');
    for (const [table, data] of Object.entries(tableResult)) {
        console.log(`${table}: ${data.length}`)
        await writeModTable(data, table, "jar_adjustable_missiles")
    }
};

export { generateAbilityEffects };
if (!variable_global_exists("Gloomy_Player")) {
    global.Gloomy_Player = {
        LV: 1,
        EXP: 0,
        GOLD: 0,
        Hp_Max: 20,
        Hp_Normal: 20,
        Hp_Karma: 0,
        Hp_Final: 20,
        Atk_Self: 0,
        Atk_Equip: 0,
        Atk_Final: 0,
        Def_Self: 0,
        Def_Equip: 0,
        Def_Final: 0,
        Exp_Next: 20
    };
}

ui_state = 0;
ui_page = 0;
ui_main_selected = 0;
ui_item_selected = 0;
ui_item_focus = 0;
ui_action_selected = 0;
ui_cell_selected = 0;

ui_main_entries = ["ITEM", "STAT", "CELL"];
ui_item_entries = ["PLACEHOLDER"];
ui_item_actions = ["USE", "INFO", "DROP"];
ui_cell_entries = ["PLACEHOLDER"];

ui_font = asset_get_index("Fnt_8bitoperator_JVE_12");
ui_small_font = asset_get_index("Fnt_Crypt_Of_Tomorrow_6");
ui_character_below = false;

global.Gloomy_Overworld_UI_Open = false;

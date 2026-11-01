// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy, JO-Beacon

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

if (!variable_global_exists("Gloomy_Inventory")) {
    global.Gloomy_Inventory = ["GLOWSTICK", "CANDY"];
    global.Gloomy_EnderChest = ["TOY_KNIFE"];
    global.Gloomy_ItemCatalog = {
        "GLOWSTICK": { name: "Glowstick", info: "A faint glow.", heal: 0 },
        "CANDY": { name: "Candy", info: "Restores 5 HP.", heal: 5 },
        "TOY_KNIFE": { name: "Toy Knife", info: "A plastic knife.", heal: 0 }
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
ui_item_entries = [];
ui_item_actions = ["USE", "INFO", "DROP"];
ui_cell_entries = ["TORIEL"];
ui_box_inventory_entries = [];
ui_box_chest_entries = [];
ui_box_focus = 0;
ui_box_selected_inventory = 0;
ui_box_selected_chest = 0;
ui_item_info_text = "";

ui_font = asset_get_index("Fnt_8bitoperator_JVE_12");
ui_small_font = asset_get_index("Fnt_Crypt_Of_Tomorrow_6");
ui_character_below = false;

inventory_get_names = function() {
    var names = [];
    for (var i = 0; i < array_length(global.Gloomy_Inventory); i++) {
        var item_id = global.Gloomy_Inventory[i];
        var item = global.Gloomy_ItemCatalog[$ item_id];
        names[i] = (item != undefined ? item.name : item_id);
    }
    return names;
};

chest_get_names = function() {
    var names = [];
    for (var i = 0; i < array_length(global.Gloomy_EnderChest); i++) {
        var item_id = global.Gloomy_EnderChest[i];
        var item = global.Gloomy_ItemCatalog[$ item_id];
        names[i] = (item != undefined ? item.name : item_id);
    }
    return names;
};

inventory_add_item = function(_item_id) {
    if (array_length(global.Gloomy_Inventory) >= 8) {
        return false;
    }
    global.Gloomy_Inventory[array_length(global.Gloomy_Inventory)] = _item_id;
    return true;
};

inventory_remove_item = function(_index) {
    if (_index < 0 || _index >= array_length(global.Gloomy_Inventory)) {
        return;
    }
    array_delete(global.Gloomy_Inventory, _index, 1);
};

chest_add_item = function(_item_id) {
    if (array_length(global.Gloomy_EnderChest) >= 10) {
        return false;
    }
    global.Gloomy_EnderChest[array_length(global.Gloomy_EnderChest)] = _item_id;
    return true;
};

chest_remove_item = function(_index) {
    if (_index < 0 || _index >= array_length(global.Gloomy_EnderChest)) {
        return;
    }
    array_delete(global.Gloomy_EnderChest, _index, 1);
};

inventory_use_item = function(_index) {
    if (_index < 0 || _index >= array_length(global.Gloomy_Inventory)) {
        return;
    }
    var item_id = global.Gloomy_Inventory[_index];
    var item = global.Gloomy_ItemCatalog[$ item_id];
    var item_name = (item != undefined ? item.name : item_id);
    if (item != undefined && item.heal > 0 && variable_global_exists("Gloomy_Player")) {
        var healed = min(item.heal, global.Gloomy_Player.Hp_Max - global.Gloomy_Player.Hp_Final);
        global.Gloomy_Player.Hp_Final += healed;
        global.Gloomy_Player.Hp_Normal = min(global.Gloomy_Player.Hp_Normal + healed, global.Gloomy_Player.Hp_Max);
    }
    inventory_remove_item(_index);
    ui_item_info_text = "Used " + item_name + ".";
};

inventory_info_item = function(_index) {
    if (_index < 0 || _index >= array_length(global.Gloomy_Inventory)) {
        return;
    }
    var item_id = global.Gloomy_Inventory[_index];
    var item = global.Gloomy_ItemCatalog[$ item_id];
    ui_item_info_text = (item != undefined ? item.info : item_id);
};

inventory_drop_item = function(_index) {
    if (_index < 0 || _index >= array_length(global.Gloomy_Inventory)) {
        return;
    }
    inventory_remove_item(_index);
    ui_item_info_text = "";
};

global.Gloomy_Overworld_UI_Open = false;

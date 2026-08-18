var toggle_pressed = Scr_Input_KeyPressed(ord("C")) || Scr_Input_KeyPressed(vk_control);
var confirm_pressed = Scr_Input_ConfirmPressed();
var cancel_pressed = Scr_Input_CancelPressed();
var up_pressed = Scr_Input_UpPressed();
var down_pressed = Scr_Input_DownPressed();
var left_pressed = Scr_Input_LeftPressed();
var right_pressed = Scr_Input_RightPressed();

if (ui_state == 0) {
    if (toggle_pressed) {
        audio_play_sound(Snd_Menu_Select, 0, false);
        ui_state = 1;
        ui_page = 0;
    }
}
else if (toggle_pressed) {
    ui_state = 0;
    ui_page = 0;
    ui_item_focus = 0;
}
else if (cancel_pressed) {
    if (ui_page == 1 && ui_item_focus == 1) {
        ui_item_focus = 0;
    }
    else if (ui_page != 0) {
        ui_page = 0;
    }
    else {
        ui_state = 0;
    }
}
else if (ui_page == 0) {
    var main_count = array_length(ui_main_entries);

    if (up_pressed) {
        var previous_main_selected = ui_main_selected;
        ui_main_selected = (ui_main_selected + main_count - 1) mod main_count;
        if (ui_main_selected != previous_main_selected) {
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
    }
    else if (down_pressed) {
        var previous_main_selected = ui_main_selected;
        ui_main_selected = (ui_main_selected + 1) mod main_count;
        if (ui_main_selected != previous_main_selected) {
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
    }

    if (confirm_pressed) {
        ui_page = ui_main_selected + 1;
        ui_item_focus = 0;
        ui_item_info_text = "";
        if (ui_page == 1) {
            ui_item_selected = 0;
            ui_action_selected = 0;
        }
        if (ui_page == 3) {
            ui_box_focus = 0;
            ui_box_selected_inventory = 0;
            ui_box_selected_chest = 0;
        }
        audio_play_sound(Snd_Menu_Selection, 0, false);
    }
}
else if (ui_page == 1) {
    if (ui_item_focus == 0) {
        var item_count = array_length(global.Gloomy_Inventory);

        if (item_count > 0 && up_pressed) {
            var previous_item_selected = ui_item_selected;
            ui_item_selected = (ui_item_selected + item_count - 1) mod item_count;
            if (ui_item_selected != previous_item_selected) {
                audio_play_sound(Snd_Menu_Select, 0, false);
            }
        }
        else if (item_count > 0 && down_pressed) {
            var previous_item_selected = ui_item_selected;
            ui_item_selected = (ui_item_selected + 1) mod item_count;
            if (ui_item_selected != previous_item_selected) {
                audio_play_sound(Snd_Menu_Select, 0, false);
            }
        }

        if (confirm_pressed && item_count > 0) {
            ui_item_focus = 1;
            audio_play_sound(Snd_Menu_Selection, 0, false);
        }
    }
    else {
        var action_count = array_length(ui_item_actions);

        if (left_pressed) {
            var previous_action_selected = ui_action_selected;
            ui_action_selected = (ui_action_selected + action_count - 1) mod action_count;
            if (ui_action_selected != previous_action_selected) {
                audio_play_sound(Snd_Menu_Select, 0, false);
            }
        }
        else if (right_pressed) {
            var previous_action_selected = ui_action_selected;
            ui_action_selected = (ui_action_selected + 1) mod action_count;
            if (ui_action_selected != previous_action_selected) {
                audio_play_sound(Snd_Menu_Select, 0, false);
            }
        }

        if (confirm_pressed) {
            if (ui_action_selected == 0) {
                inventory_use_item(ui_item_selected);
            }
            else if (ui_action_selected == 1) {
                inventory_info_item(ui_item_selected);
            }
            else if (ui_action_selected == 2) {
                inventory_drop_item(ui_item_selected);
            }
            ui_item_focus = 0;
            var remaining = array_length(global.Gloomy_Inventory);
            if (remaining == 0) {
                ui_item_selected = 0;
            }
            else {
                ui_item_selected = min(ui_item_selected, remaining - 1);
            }
            audio_play_sound(Snd_Menu_Selection, 0, false);
        }
    }
}
else if (ui_page == 3) {
    if (left_pressed && ui_box_focus == 1) {
        ui_box_focus = 0;
        audio_play_sound(Snd_Menu_Select, 0, false);
    }
    else if (right_pressed && ui_box_focus == 0) {
        ui_box_focus = 1;
        audio_play_sound(Snd_Menu_Select, 0, false);
    }
    else if (up_pressed) {
        var previous_box_selected = (ui_box_focus == 0 ? ui_box_selected_inventory : ui_box_selected_chest);
        if (ui_box_focus == 0) {
            ui_box_selected_inventory = max(ui_box_selected_inventory - 1, 0);
        }
        else {
            ui_box_selected_chest = max(ui_box_selected_chest - 1, 0);
        }
        var current_box_selected = (ui_box_focus == 0 ? ui_box_selected_inventory : ui_box_selected_chest);
        if (current_box_selected != previous_box_selected) {
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
    }
    else if (down_pressed) {
        var previous_box_selected = (ui_box_focus == 0 ? ui_box_selected_inventory : ui_box_selected_chest);
        var box_row_limit = (ui_box_focus == 0 ? 7 : 9);
        if (ui_box_focus == 0) {
            ui_box_selected_inventory = min(ui_box_selected_inventory + 1, box_row_limit);
        }
        else {
            ui_box_selected_chest = min(ui_box_selected_chest + 1, box_row_limit);
        }
        var current_box_selected = (ui_box_focus == 0 ? ui_box_selected_inventory : ui_box_selected_chest);
        if (current_box_selected != previous_box_selected) {
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
    }

    if (confirm_pressed) {
        if (ui_box_focus == 0 && ui_box_selected_inventory < array_length(global.Gloomy_Inventory)) {
            var item_id = global.Gloomy_Inventory[ui_box_selected_inventory];
            if (chest_add_item(item_id)) {
                inventory_remove_item(ui_box_selected_inventory);
                ui_box_selected_inventory = min(ui_box_selected_inventory, max(array_length(global.Gloomy_Inventory) - 1, 0));
            }
        }
        else if (ui_box_focus == 1 && ui_box_selected_chest < array_length(global.Gloomy_EnderChest)) {
            var chest_item_id = global.Gloomy_EnderChest[ui_box_selected_chest];
            if (inventory_add_item(chest_item_id)) {
                chest_remove_item(ui_box_selected_chest);
                ui_box_selected_chest = min(ui_box_selected_chest, max(array_length(global.Gloomy_EnderChest) - 1, 0));
            }
        }
        audio_play_sound(Snd_Menu_Selection, 0, false);
    }
}

global.Gloomy_Overworld_UI_Open = (ui_state != 0);

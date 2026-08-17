var toggle_pressed = keyboard_check_pressed(ord("C")) || keyboard_check_pressed(vk_control);
var confirm_pressed = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);
var cancel_pressed = keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_shift);
var up_pressed = keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up);
var down_pressed = keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down);
var left_pressed = keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left);
var right_pressed = keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right);

if (ui_state == 0) {
    if (toggle_pressed) {
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
        audio_play_sound(Snd_Menu_Selection, 0, false);
    }
}
else if (ui_page == 1) {
    if (ui_item_focus == 0) {
        var item_count = array_length(ui_item_entries);

        if (up_pressed) {
            var previous_item_selected = ui_item_selected;
            ui_item_selected = (ui_item_selected + item_count - 1) mod item_count;
            if (ui_item_selected != previous_item_selected) {
                audio_play_sound(Snd_Menu_Select, 0, false);
            }
        }
        else if (down_pressed) {
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
    }
}
else if (ui_page == 3) {
    var cell_count = array_length(ui_cell_entries);

    if (up_pressed) {
        var previous_cell_selected = ui_cell_selected;
        ui_cell_selected = (ui_cell_selected + cell_count - 1) mod cell_count;
        if (ui_cell_selected != previous_cell_selected) {
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
    }
    else if (down_pressed) {
        var previous_cell_selected = ui_cell_selected;
        ui_cell_selected = (ui_cell_selected + 1) mod cell_count;
        if (ui_cell_selected != previous_cell_selected) {
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
    }
}

global.Gloomy_Overworld_UI_Open = (ui_state != 0);

var toggle_pressed = keyboard_check_pressed(ord("C")) || keyboard_check_pressed(vk_control);
var confirm_pressed = keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter);
var cancel_pressed = keyboard_check_pressed(ord("X")) || keyboard_check_pressed(vk_shift);
var up_pressed = keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up);
var down_pressed = keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down);

switch (ui_state) {
    case 0:
        if (toggle_pressed) {
            ui_state = 1;
        }
        break;

    case 1:
        ui_progress = min(1, ui_progress + ui_animation_speed);
        if (toggle_pressed || cancel_pressed) {
            ui_state = 3;
        }
        else if (ui_progress >= 1) {
            ui_state = 2;
        }
        break;

    case 2:
        if (toggle_pressed) {
            ui_state = 3;
        }
        else if (cancel_pressed) {
            if (ui_page > 0) {
                ui_page = 0;
            }
            else {
                ui_state = 3;
            }
        }
        else if (ui_page == 0) {
            if (up_pressed) {
                ui_selected = (ui_selected + ui_entry_count - 1) mod ui_entry_count;
            }
            else if (down_pressed) {
                ui_selected = (ui_selected + 1) mod ui_entry_count;
            }

            if (confirm_pressed) {
                ui_page = ui_selected + 1;
            }
        }
        break;

    case 3:
        ui_progress = max(0, ui_progress - ui_animation_speed);
        if (toggle_pressed) {
            ui_state = 1;
        }
        else if (ui_progress <= 0) {
            ui_state = 0;
            ui_page = 0;
        }
        break;
}

global.Gloomy_Overworld_UI_Open = (ui_state != 0);

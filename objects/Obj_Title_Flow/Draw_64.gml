// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy, JO-Beacon

var previous_alpha = draw_get_alpha();
var previous_colour = draw_get_color();
var previous_font = draw_get_font();
var previous_halign = draw_get_halign();
var previous_valign = draw_get_valign();

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(title_font >= 0 ? title_font : -1);

var center_x = display_get_gui_width() * 0.5;

switch (title_state) {
    case 0:
        draw_text(center_x, 88, "SELECT LANGUAGE");
        draw_text(center_x, 128, "> ENGLISH");
        draw_text(center_x, 168, "Z / ENTER - CONFIRM");
        break;

    case 1:
        draw_text(center_x, 216, "PRESS Z / ENTER");
        break;

    case 2:
        draw_text(center_x, 52, "FAN GAME / NON-COMMERCIAL");
        draw_text(center_x, 76, "UNDERTALE IS BY TOBY FOX");
        draw_text(center_x, 100, "UNDERTALE SOUNDS BY TOBY FOX");
        draw_text(center_x, 124, "CONTAINS FLASHING IMAGES");
        draw_text(center_x, 148, "RECOMMENDED FOR AGES 16+");
        draw_text(center_x, 184, "Z / ENTER - CONFIRM");
        break;

    case 3:
        draw_text(center_x, 104, "INTRO PLACEHOLDER");
        draw_text(center_x, 136, "Z / ENTER - SKIP");
        break;

    case 4:
        draw_text(center_x, 48, "GLOOMYTALE");
        for (var i = 0; i < array_length(title_main_entries); i++) {
            var label = title_main_entries[i];
            if (i == title_selected) {
                label = "> " + label;
            }
            draw_text(center_x, 92 + i * 28, label);
        }
        draw_text(center_x, 216, "Z / ENTER - SELECT");
        break;

    case 7:
        draw_text(center_x, 48, "WORLD MANAGER");
        var world_count = Scr_Save_GetWorldCount();
        for (var save_i = 0; save_i < world_count; save_i++) {
            var world = Scr_Save_GetWorld(save_i);
            var world_name = (world != undefined ? world.name : "WORLD " + string(save_i + 1));
            var save_label = world_name;
            if (save_i == title_world_selected) {
                save_label = "> " + save_label;
            }
            draw_text(center_x, 92 + save_i * 28, save_label);
        }
        var new_world_label = (title_world_selected == world_count ? "> " : "") + "NEW WORLD";
        draw_text(center_x, 92 + world_count * 28, new_world_label);
        var back_label = (title_world_selected == world_count + 1 ? "> " : "") + "BACK";
        draw_text(center_x, 92 + (world_count + 1) * 28, back_label);
        draw_text(center_x, 216, "Z / ENTER - SELECT");
        break;

    case 8:
        var selected_action_world = Scr_Save_GetWorld(title_world_selected);
        var action_world_name = (selected_action_world != undefined ? selected_action_world.name : "WORLD");
        draw_text(center_x, 48, "WORLD ACTIONS");
        draw_text(center_x, 72, action_world_name);
        for (var action_i = 0; action_i < array_length(title_world_actions); action_i++) {
            var action_label = title_world_actions[action_i];
            if (action_i == title_world_action_selected) {
                action_label = "> " + action_label;
            }
            draw_text(center_x, 108 + action_i * 28, action_label);
        }
        draw_text(center_x, 216, "X / SHIFT - BACK");
        break;

    case 9:
    case 10:
    case 12:
        draw_text(center_x, 48, title_world_text_prompt);
        draw_text(center_x, 96, keyboard_string + "_");
        draw_text(center_x, 144, "Z / ENTER - CONFIRM");
        draw_text(center_x, 168, "X / SHIFT - CANCEL");
        break;

    case 11:
        var delete_world = Scr_Save_GetWorld(title_world_selected);
        var delete_world_name = (delete_world != undefined ? delete_world.name : "WORLD");
        draw_text(center_x, 48, "DELETE WORLD?");
        draw_text(center_x, 80, delete_world_name);
        var no_label = (title_world_confirm_delete == 0 ? "> " : "") + "NO";
        var yes_label = (title_world_confirm_delete == 1 ? "> " : "") + "YES";
        draw_text(center_x, 128, no_label);
        draw_text(center_x, 156, yes_label);
        draw_text(center_x, 200, "Z / ENTER - CONFIRM");
        break;

    case 5:
        draw_text(center_x, 48, "SETTINGS");
        for (var setting_i = 0; setting_i < array_length(title_settings_entries); setting_i++) {
            var setting_label = title_settings_entries[setting_i];
            if (setting_i == title_settings_selected) {
                setting_label = "> " + setting_label;
            }
            draw_text(center_x, 92 + setting_i * 28, setting_label);
        }
        draw_text(center_x, 216, "X / SHIFT - BACK");
        break;

    case 13:
        draw_text(center_x, 48, "CLEAR ALL SAVES?");
        draw_text(center_x, 80, "THIS CANNOT BE UNDONE");
        var clear_no_label = (title_clear_saves_confirm == 0 ? "> " : "") + "NO";
        var clear_yes_label = (title_clear_saves_confirm == 1 ? "> " : "") + "YES";
        draw_text(center_x, 128, clear_no_label);
        draw_text(center_x, 156, clear_yes_label);
        draw_text(center_x, 200, "Z / ENTER - CONFIRM");
        break;

    case 6:
        draw_text(center_x, 80, "GLOOMYTALE - NON-COMMERCIAL FAN GAME");
        draw_text(center_x, 104, "UNDERTALE BY TOBY FOX");
        draw_text(center_x, 136, "X / SHIFT - BACK");
        break;
}

draw_set_alpha(previous_alpha);
draw_set_color(previous_colour);
draw_set_font(previous_font);
draw_set_halign(previous_halign);
draw_set_valign(previous_valign);

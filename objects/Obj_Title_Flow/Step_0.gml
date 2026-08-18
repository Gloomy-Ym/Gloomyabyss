var confirm_pressed = Scr_Input_ConfirmPressed();
var cancel_pressed = Scr_Input_CancelPressed();
var up_pressed = Scr_Input_UpPressed();
var down_pressed = Scr_Input_DownPressed();

switch (title_state) {
    case 0:
        if (confirm_pressed) {
            audio_play_sound(Snd_Menu_Select, 0, false);
            global.Title_Language = "en";
            layer_set_visible("Assets", true);
            title_timer = 120;
            title_state = 1;
        }
        break;

    case 1:
        if (title_timer > 0) {
            title_timer--;
        }
        if (confirm_pressed || title_timer <= 0) {
            layer_set_visible("Assets", false);
            title_state = 2;
            title_timer = 0;
        }
        break;

    case 2:
        if (confirm_pressed) {
            audio_play_sound(Snd_Menu_Select, 0, false);
            title_state = 3;
            title_timer = 240;
        }
        break;

    case 3:
        if (title_timer > 0) {
            title_timer--;
        }
        if (confirm_pressed || title_timer <= 0) {
            title_state = 4;
            title_selected = 0;
        }
        break;

    case 4:
        if (up_pressed) {
            title_selected = (title_selected + array_length(title_main_entries) - 1) % array_length(title_main_entries);
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (down_pressed) {
            title_selected = (title_selected + 1) % array_length(title_main_entries);
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (confirm_pressed) {
            audio_play_sound(Snd_Menu_Select, 0, false);
            switch (title_selected) {
                case 0:
                    title_world_selected = 0;
                    title_state = 7;
                    break;
                case 1:
                    title_state = 5;
                    break;
                case 2:
                    title_state = 6;
                    break;
                case 3:
                    game_end();
                    break;
            }
        }
        break;

    case 7:
        var world_count = Scr_Save_GetWorldCount();
        var world_entry_count = world_count + 2;
        if (up_pressed) {
            title_world_selected = (title_world_selected + world_entry_count - 1) % world_entry_count;
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (down_pressed) {
            title_world_selected = (title_world_selected + 1) % world_entry_count;
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (confirm_pressed) {
            audio_play_sound(Snd_Menu_Select, 0, false);
            if (title_world_selected < world_count) {
                title_world_action_selected = 0;
                title_state = 8;
            }
            else if (title_world_selected == world_count) {
                keyboard_string = Scr_Save_GetNextWorldName();
                title_world_text_prompt = "NEW WORLD NAME";
                title_state = 9;
            }
            else {
                title_state = 4;
                title_selected = 0;
            }
        }
        if (cancel_pressed) {
            title_state = 4;
            title_selected = 0;
        }
        break;

    case 8:
        var action_count = array_length(title_world_actions);
        if (up_pressed) {
            title_world_action_selected = (title_world_action_selected + action_count - 1) % action_count;
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (down_pressed) {
            title_world_action_selected = (title_world_action_selected + 1) % action_count;
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (confirm_pressed) {
            audio_play_sound(Snd_Menu_Select, 0, false);
            switch (title_world_action_selected) {
                case 0:
                    if (Scr_Save_GetStoryCount(title_world_selected) > 0) {
                        Scr_Save_SelectActive(title_world_selected, 0);
                        Scr_Save_WriteIndex();
                        room_goto(OverWorld);
                    }
                    break;
                case 1:
                    var rename_world = Scr_Save_GetWorld(title_world_selected);
                    keyboard_string = (rename_world != undefined ? rename_world.name : "");
                    title_world_text_prompt = "RENAME WORLD";
                    title_state = 10;
                    break;
                case 2:
                    var copy_source = Scr_Save_GetWorld(title_world_selected);
                    keyboard_string = (copy_source != undefined ? copy_source.name : "") + " COPY";
                    title_world_text_prompt = "COPY WORLD NAME";
                    title_state = 12;
                    break;
                case 3:
                    title_world_confirm_delete = 0;
                    title_state = 11;
                    break;
                case 4:
                    title_state = 7;
                    break;
            }
        }
        if (cancel_pressed) {
            title_state = 7;
        }
        break;

    case 9:
        keyboard_string = string_copy(keyboard_string, 1, title_world_name_limit);
        if (confirm_pressed) {
            var new_world_name = Scr_Title_SanitizeWorldName(keyboard_string);
            var new_world_index = Scr_Save_CreateWorld(new_world_name);
            if (new_world_index >= 0) {
                Scr_Save_WriteWorld(new_world_index);
                Scr_Save_WriteIndex();
                title_world_selected = new_world_index;
            }
            keyboard_string = "";
            title_state = 7;
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (cancel_pressed) {
            keyboard_string = "";
            title_state = 7;
        }
        break;

    case 10:
        keyboard_string = string_copy(keyboard_string, 1, title_world_name_limit);
        if (confirm_pressed) {
            var renamed_world_name = Scr_Title_SanitizeWorldName(keyboard_string);
            if (Scr_Save_SetWorldName(title_world_selected, renamed_world_name)) {
                Scr_Save_WriteWorld(title_world_selected);
                Scr_Save_WriteIndex();
            }
            keyboard_string = "";
            title_state = 7;
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (cancel_pressed) {
            keyboard_string = "";
            title_state = 8;
        }
        break;

    case 11:
        if (up_pressed || down_pressed) {
            title_world_confirm_delete = 1 - title_world_confirm_delete;
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (confirm_pressed) {
            if (title_world_confirm_delete == 1) {
                Scr_Save_DeleteWorld(title_world_selected);
                Scr_Save_WriteIndex();
                var remaining_worlds = Scr_Save_GetWorldCount();
                title_world_selected = min(title_world_selected, max(remaining_worlds - 1, 0));
            }
            title_state = 7;
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (cancel_pressed) {
            title_state = 8;
        }
        break;

    case 12:
        keyboard_string = string_copy(keyboard_string, 1, title_world_name_limit);
        if (confirm_pressed) {
            var copied_world_name = Scr_Title_SanitizeWorldName(keyboard_string);
            var copied_world_index = Scr_Save_CopyWorld(title_world_selected, copied_world_name);
            if (copied_world_index >= 0) {
                Scr_Save_WriteWorld(copied_world_index);
                Scr_Save_WriteIndex();
                title_world_selected = copied_world_index;
            }
            keyboard_string = "";
            title_state = 7;
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (cancel_pressed) {
            keyboard_string = "";
            title_state = 8;
        }
        break;

    case 5:
        var settings_count = array_length(title_settings_entries);
        if (up_pressed) {
            title_settings_selected = (title_settings_selected + settings_count - 1) % settings_count;
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (down_pressed) {
            title_settings_selected = (title_settings_selected + 1) % settings_count;
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (confirm_pressed) {
            audio_play_sound(Snd_Menu_Select, 0, false);
            if (title_settings_selected == 0) {
                title_clear_saves_confirm = 0;
                title_state = 13;
            }
            else {
                title_state = 4;
                title_selected = 1;
            }
        }
        if (cancel_pressed) {
            title_state = 4;
        }
        break;

    case 13:
        if (up_pressed || down_pressed) {
            title_clear_saves_confirm = 1 - title_clear_saves_confirm;
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (confirm_pressed) {
            if (title_clear_saves_confirm == 1) {
                Scr_Save_ClearAllSaves();
            }
            title_state = 5;
            audio_play_sound(Snd_Menu_Select, 0, false);
        }
        if (cancel_pressed) {
            title_state = 5;
        }
        break;

    case 6:
        if (cancel_pressed) {
            title_state = 4;
        }
        break;
}

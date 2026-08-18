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
                    room_goto(OverWorld);
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

    case 5:
        if (cancel_pressed) {
            title_state = 4;
        }
        break;

    case 6:
        if (cancel_pressed) {
            title_state = 4;
        }
        break;
}

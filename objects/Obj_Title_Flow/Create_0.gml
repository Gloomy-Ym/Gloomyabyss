// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

Scr_Save_Init();

title_state = 0;
title_timer = 0;
title_selected = 0;
title_world_selected = 0;
title_world_action_selected = 0;
title_world_text_prompt = "";
title_world_confirm_delete = 0;
title_world_name_limit = 20;
title_main_entries = ["START GAME", "SETTINGS", "ABOUT", "MAP EDITOR", "EXIT"];
title_world_actions = ["CONTINUE", "RENAME", "COPY", "DELETE", "BACK"];
title_settings_entries = ["CLEAR ALL SAVES", "BACK"];
title_settings_selected = 0;
title_clear_saves_confirm = 0;
title_font = asset_get_index("Fnt_8bitoperator_JVE_12");

global.Title_Language = "en";

layer_set_visible("Assets", false);

function Scr_Title_SanitizeWorldName(_text) {
    var source_text = string_upper(string_copy(_text, 1, title_world_name_limit));
    var result = "";

    for (var char_i = 1; char_i <= string_length(source_text); char_i++) {
        var current_character = string_char_at(source_text, char_i);
        var is_letter_or_digit = (current_character >= "A" && current_character <= "Z")
            || (current_character >= "0" && current_character <= "9");
        if (is_letter_or_digit || current_character == " " || current_character == "-" || current_character == "_") {
            result += current_character;
        }
    }

    while (string_length(result) > 0 && string_char_at(result, 1) == " ") {
        result = string_copy(result, 2, string_length(result) - 1);
    }

    if (string_length(result) == 0) {
        result = "WORLD";
    }

    return result;
}

if (ui_state == 0) {
    exit;
}

var previous_alpha = draw_get_alpha();
var previous_colour = draw_get_color();
var previous_font = draw_get_font();
var previous_halign = draw_get_halign();
var previous_valign = draw_get_valign();

var draw_panel = function(_x, _y, _width, _height) {
    draw_set_color(c_white);
    draw_rectangle(_x, _y, _x + _width, _y + _height, false);
    draw_set_color(c_black);
    draw_rectangle(_x + 6, _y + 6, _x + _width - 6, _y + _height - 6, false);
};

var draw_ui_text = function(_x, _y, _text) {
    draw_text(_x, _y, _text);
};

var draw_small_text = function(_x, _y, _text) {
    if (ui_small_font >= 0) {
        draw_set_font(ui_small_font);
        draw_text_transformed(_x, _y, _text, 2, 2, 0);
    }
    else {
        draw_set_font(ui_font >= 0 ? ui_font : -1);
        draw_text(_x, _y, _text);
    }
};

var draw_cursor = function(_x, _y) {
    draw_sprite(Spr_SoulGUI_Red, 0, _x + 9, _y + 9);
};

if (ui_font < 0) {
    ui_font = asset_get_index("Fnt_Ark_Pixel_12_ZH_CN");
}
if (ui_small_font < 0) {
    ui_small_font = asset_get_index("Fnt_Crypt_Of_Tomorrow_6");
}

draw_set_alpha(1);
draw_set_font(ui_font >= 0 ? ui_font : -1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var info_y = ui_character_below ? 322 : 52;
draw_panel(32, info_y, 140, 108);
draw_panel(32, 168, 140, 146);

draw_set_color(c_white);
draw_ui_text(48, info_y + 16, "GLOOMY");
draw_small_text(48, info_y + 48, "LV  1");
draw_small_text(48, info_y + 72, "HP  20 / 20");

draw_set_font(ui_font >= 0 ? ui_font : -1);

for (var i = 0; i < array_length(ui_main_entries); i++) {
    draw_ui_text(84, 188 + i * 36, ui_main_entries[i]);
}

if (ui_page == 0) {
    draw_cursor(56, 196 + ui_main_selected * 36);
}

switch (ui_page) {
    case 1:
        draw_panel(188, 52, 344, 360);

        draw_set_color(c_white);
        for (var item_index = 0; item_index < array_length(ui_item_entries); item_index++) {
            draw_ui_text(232, 80 + item_index * 32, ui_item_entries[item_index]);
        }

        for (var action_index = 0; action_index < array_length(ui_item_actions); action_index++) {
            var action_x = [232, 328, 442][action_index];
            draw_ui_text(action_x, 360, ui_item_actions[action_index]);
        }

        if (ui_item_focus == 0) {
            draw_cursor(208, 88 + ui_item_selected * 32);
        }
        else {
            var action_cursor_x = [208, 304, 418][ui_action_selected];
            draw_cursor(action_cursor_x, 368);
        }
        break;

    case 2:
        draw_panel(188, 52, 344, 416);

        draw_set_color(c_white);
        draw_ui_text(232, 80, "GLOOMY");
        draw_small_text(232, 120, "LV 1");
        draw_small_text(232, 152, "HP 20 / 20");
        draw_small_text(232, 200, "AT 0 (0)");
        draw_small_text(232, 232, "DF 0 (0)");
        draw_small_text(232, 280, "EXP: 0");
        draw_small_text(232, 312, "NEXT: 10");
        draw_small_text(232, 360, "GOLD: 0");
        break;

    case 3:
        draw_panel(188, 52, 344, 268);

        draw_set_color(c_white);
        for (var cell_index = 0; cell_index < array_length(ui_cell_entries); cell_index++) {
            draw_ui_text(232, 80 + cell_index * 32, ui_cell_entries[cell_index]);
        }
        draw_cursor(208, 88 + ui_cell_selected * 32);
        break;
}

draw_set_alpha(previous_alpha);
draw_set_color(previous_colour);
draw_set_font(previous_font);
draw_set_halign(previous_halign);
draw_set_valign(previous_valign);

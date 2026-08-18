if (ui_state == 0) {
    exit;
}

var previous_alpha = draw_get_alpha();
var previous_colour = draw_get_color();
var previous_font = draw_get_font();
var previous_halign = draw_get_halign();
var previous_valign = draw_get_valign();
var ui_scale = display_get_gui_width() / 640;

var draw_panel = function(_x, _y, _width, _height, _scale) {
    _x *= _scale;
    _y *= _scale;
    _width *= _scale;
    _height *= _scale;
    var border = 6 * _scale;

    draw_set_color(c_white);
    draw_rectangle(_x, _y, _x + _width, _y + _height, false);
    draw_set_color(c_black);
    draw_rectangle(_x + border, _y + border, _x + _width - border, _y + _height - border, false);
};

var draw_ui_text = function(_x, _y, _text, _scale) {
    draw_text_transformed(_x * _scale, _y * _scale, _text, 2 * _scale, 2 * _scale, 0);
};

var draw_small_text = function(_x, _y, _text, _scale) {
    if (ui_small_font >= 0) {
        draw_set_font(ui_small_font);
        draw_text_transformed(_x * _scale, _y * _scale, _text, 2 * _scale, 2 * _scale, 0);
    }
    else {
        draw_set_font(ui_font >= 0 ? ui_font : -1);
        draw_text_transformed(_x * _scale, _y * _scale, _text, 2 * _scale, 2 * _scale, 0);
    }
};

var draw_cursor = function(_x, _y, _scale) {
    draw_sprite_ext(
        Spr_SoulGUI_Red,
        0,
        (_x + 9) * _scale,
        (_y + 9) * _scale,
        _scale,
        _scale,
        0,
        c_white,
        1
    );
};

if (ui_font < 0) {
    ui_font = asset_get_index("Fnt_8bitoperator_JVE_12");
}
if (ui_small_font < 0) {
    ui_small_font = asset_get_index("Fnt_Crypt_Of_Tomorrow_6");
}

draw_set_alpha(1);
draw_set_font(ui_font >= 0 ? ui_font : -1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var player_stats = variable_global_exists("Gloomy_Player")
    ? global.Gloomy_Player
    : {
        LV: 1,
        EXP: 0,
        GOLD: 0,
        Hp_Max: 20,
        Hp_Final: 20,
        Atk_Final: 0,
        Atk_Equip: 0,
        Def_Final: 0,
        Def_Equip: 0,
        Exp_Next: 20
    };
var player_lv_text = string(player_stats.LV);
var player_hp_text = string(player_stats.Hp_Final) + " / " + string(player_stats.Hp_Max);
var player_gold_text = string(player_stats.GOLD);
var player_atk_text = "AT " + string(player_stats.Atk_Final) + " (" + string(player_stats.Atk_Equip) + ")";
var player_def_text = "DF " + string(player_stats.Def_Final) + " (" + string(player_stats.Def_Equip) + ")";
var player_exp_text = "EXP: " + string(player_stats.EXP);
var player_next_text = "NEXT: " + (player_stats.LV < 20 ? string(player_stats.Exp_Next) : "MAX");

var info_y = ui_character_below ? 322 : 52;
draw_panel(32, info_y, 140, 108, ui_scale);
draw_panel(32, 168, 140, 146, ui_scale);

draw_set_color(c_white);
draw_ui_text(46, info_y + 8, "GLOOMY", ui_scale);
draw_small_text(46, info_y + 48, "LV", ui_scale);
draw_small_text(82, info_y + 48, player_lv_text, ui_scale);
draw_small_text(46, info_y + 66, "HP", ui_scale);
draw_small_text(82, info_y + 66, player_hp_text, ui_scale);
draw_small_text(46, info_y + 84, "G", ui_scale);
draw_small_text(82, info_y + 84, player_gold_text, ui_scale);

draw_set_font(ui_font >= 0 ? ui_font : -1);

for (var i = 0; i < array_length(ui_main_entries); i++) {
    draw_ui_text(84, 188 + i * 36, ui_main_entries[i], ui_scale);
}

if (ui_page == 0) {
    draw_cursor(56, 196 + ui_main_selected * 36, ui_scale);
}

switch (ui_page) {
    case 1:
        draw_panel(188, 52, 344, 360, ui_scale);

        draw_set_color(c_white);
        for (var item_index = 0; item_index < array_length(ui_item_entries); item_index++) {
            draw_ui_text(232, 80 + item_index * 32, ui_item_entries[item_index], ui_scale);
        }

        for (var action_index = 0; action_index < array_length(ui_item_actions); action_index++) {
            var action_x = [232, 328, 442][action_index];
            draw_ui_text(action_x, 360, ui_item_actions[action_index], ui_scale);
        }

        if (ui_item_focus == 0) {
            draw_cursor(208, 88 + ui_item_selected * 32, ui_scale);
        }
        else {
            var action_cursor_x = [208, 304, 418][ui_action_selected];
            draw_cursor(action_cursor_x, 368, ui_scale);
        }
        break;

    case 2:
        draw_panel(188, 52, 344, 416, ui_scale);

        draw_set_color(c_white);
        draw_ui_text(232, 80, "GLOOMY", ui_scale);
        draw_small_text(232, 120, "LV " + player_lv_text, ui_scale);
        draw_small_text(232, 152, "HP " + player_hp_text, ui_scale);
        draw_small_text(232, 200, player_atk_text, ui_scale);
        draw_small_text(232, 232, player_def_text, ui_scale);
        draw_small_text(232, 280, player_exp_text, ui_scale);
        draw_small_text(232, 312, player_next_text, ui_scale);
        draw_small_text(232, 360, "GOLD: " + player_gold_text, ui_scale);
        break;

    case 3:
        draw_panel(188, 52, 344, 268, ui_scale);

        draw_set_color(c_white);
        for (var cell_index = 0; cell_index < array_length(ui_cell_entries); cell_index++) {
            draw_ui_text(232, 80 + cell_index * 32, ui_cell_entries[cell_index], ui_scale);
        }
        draw_cursor(208, 88 + ui_cell_selected * 32, ui_scale);
        break;
}

draw_set_alpha(previous_alpha);
draw_set_color(previous_colour);
draw_set_font(previous_font);
draw_set_halign(previous_halign);
draw_set_valign(previous_valign);

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

var info_value_font = ui_small_font >= 0 ? ui_small_font : ui_font;
draw_set_font(info_value_font >= 0 ? info_value_font : -1);
var info_value_x = 46 + string_width("LV  ") * 2;
draw_set_font(ui_font >= 0 ? ui_font : -1);

ui_item_entries = inventory_get_names();
ui_box_inventory_entries = inventory_get_names();
ui_box_chest_entries = chest_get_names();

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
var player_exp_value = string(player_stats.EXP);
var player_next_value = (player_stats.LV < 20 ? string(player_stats.Exp_Next) : "MAX");

var info_y = ui_character_below ? 322 : 52;
draw_panel(32, info_y, 140, 108, ui_scale);
draw_panel(32, 168, 140, 146, ui_scale);

draw_set_color(c_white);
draw_ui_text(46, info_y + 8, "GLOOMY", ui_scale);
draw_small_text(46, info_y + 42, "LV", ui_scale);
draw_small_text(info_value_x, info_y + 42, player_lv_text, ui_scale);
draw_small_text(46, info_y + 60, "HP", ui_scale);
draw_small_text(info_value_x, info_y + 60, player_hp_text, ui_scale);
draw_small_text(46, info_y + 78, "G", ui_scale);
draw_small_text(info_value_x, info_y + 78, player_gold_text, ui_scale);

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

        if (ui_item_info_text != "") {
            draw_small_text(232, 320, ui_item_info_text, ui_scale);
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
        draw_ui_text(216, 84, "GLOOMY", ui_scale);
        draw_ui_text(216, 144, "LV " + player_lv_text, ui_scale);
        draw_ui_text(216, 176, "HP " + player_hp_text, ui_scale);
        draw_ui_text(216, 240, player_atk_text, ui_scale);
        draw_ui_text(216, 272, player_def_text, ui_scale);
        draw_ui_text(216, 332, "EXP", ui_scale);
        draw_ui_text(384, 332, player_exp_value, ui_scale);
        draw_ui_text(216, 364, "NEXT", ui_scale);
        draw_ui_text(384, 364, player_next_value, ui_scale);
        draw_ui_text(216, 404, "GOLD: " + player_gold_text, ui_scale);
        break;

    case 4:
        draw_panel(16, 16, 608, 448, ui_scale);

        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_ui_text(168, 30, "ITEM", ui_scale);
        draw_ui_text(470, 30, "BOX", ui_scale);
        draw_set_halign(fa_left);

        for (var box_item_index = 0; box_item_index < array_length(ui_box_inventory_entries); box_item_index++) {
            draw_ui_text(68, 72 + box_item_index * 32, ui_box_inventory_entries[box_item_index], ui_scale);
        }

        for (var chest_item_index = 0; chest_item_index < array_length(ui_box_chest_entries); chest_item_index++) {
            draw_ui_text(370, 72 + chest_item_index * 32, ui_box_chest_entries[chest_item_index], ui_scale);
        }

        draw_set_color(c_red);
        for (var empty_inventory_row = array_length(ui_box_inventory_entries); empty_inventory_row < 8; empty_inventory_row++) {
            draw_line(39, 46 + empty_inventory_row * 16, 129, 46 + empty_inventory_row * 16);
        }
        for (var empty_chest_row = array_length(ui_box_chest_entries); empty_chest_row < 10; empty_chest_row++) {
            draw_line(190, 46 + empty_chest_row * 16, 280, 46 + empty_chest_row * 16);
        }

        draw_set_color(c_white);
        draw_line(160, 40, 160, 190);
        draw_line(161, 40, 161, 190);

        if (ui_box_focus == 0) {
            draw_cursor(40, 82 + ui_box_selected_inventory * 32, ui_scale);
        }
        else {
            draw_cursor(342, 82 + ui_box_selected_chest * 32, ui_scale);
        }
        break;

    case 3:
        draw_panel(188, 52, 344, 268, ui_scale);

        draw_set_color(c_white);
        draw_ui_text(232, 80, "CELL", ui_scale);
        for (var cell_index = 0; cell_index < array_length(ui_cell_entries); cell_index++) {
            draw_ui_text(232, 112 + cell_index * 32, ui_cell_entries[cell_index], ui_scale);
        }
        if (array_length(ui_cell_entries) > 0) {
            draw_cursor(208, 120 + ui_cell_selected * 32, ui_scale);
        }
        draw_small_text(232, 272, "Z / ENTER - CALL", ui_scale);
        break;
}

draw_set_alpha(previous_alpha);
draw_set_color(previous_colour);
draw_set_font(previous_font);
draw_set_halign(previous_halign);
draw_set_valign(previous_valign);

// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

var previous_alpha = draw_get_alpha();
var previous_colour = draw_get_color();
var previous_font = draw_get_font();
var previous_halign = draw_get_halign();
var previous_valign = draw_get_valign();
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();
var nav_scale = gui_width / 640;
var button_count = array_length(nav_rooms);
var button_width = nav_button_width * nav_scale;
var button_height = nav_button_height * nav_scale;
var button_gap = nav_button_gap * nav_scale;
var margin = nav_margin * nav_scale;
var total_width = button_count * button_width + (button_count - 1) * button_gap;
var start_x = (gui_width - total_width) * 0.5;
var start_y = gui_height - margin - button_height;

draw_set_font(-1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

for (var i = 0; i < button_count; i++) {
    var button_x = start_x + i * (button_width + button_gap);
    var is_current = nav_rooms[i] == room;
    var is_hovered = i == nav_hovered && !is_current;

    draw_set_alpha(0.9);
    draw_set_color(is_current ? c_dkgray : c_black);
    draw_rectangle(
        button_x,
        start_y,
        button_x + button_width,
        start_y + button_height,
        false
    );

    draw_set_alpha(1);
    draw_set_color(is_hovered ? c_yellow : c_white);
    draw_rectangle(
        button_x,
        start_y,
        button_x + button_width,
        start_y + button_height,
        true
    );
    draw_text_transformed(
        button_x + button_width * 0.5,
        start_y + button_height * 0.5,
        nav_labels[i],
        nav_scale,
        nav_scale,
        0
    );
}

draw_set_alpha(previous_alpha);
draw_set_color(previous_colour);
draw_set_font(previous_font);
draw_set_halign(previous_halign);
draw_set_valign(previous_valign);

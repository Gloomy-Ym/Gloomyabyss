// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

var previous_alpha = draw_get_alpha();
var previous_colour = draw_get_color();
var previous_font = draw_get_font();
var previous_halign = draw_get_halign();
var previous_valign = draw_get_valign();

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_font(death_font >= 0 ? death_font : -1);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var center_x = display_get_gui_width() * 0.5;
draw_text(center_x, 88, "YOU DIED");
if ((death_blink_timer div 30) mod 2 == 0) {
    draw_text(center_x, 152, "Z / ENTER - RETURN TO TITLE");
}

draw_set_alpha(previous_alpha);
draw_set_color(previous_colour);
draw_set_font(previous_font);
draw_set_halign(previous_halign);
draw_set_valign(previous_valign);

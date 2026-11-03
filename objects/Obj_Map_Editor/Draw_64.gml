// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

draw_set_font(font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_color(c_white);
draw_text(20, 20, "MAP EDITOR");

var count = array_length(buttons);
for (var i = 0; i < count; i++) {
    var top = 72 + i * 32;
    var active = (i == selected);

    draw_set_color(active ? c_yellow : c_gray);
    draw_rectangle(20, top, 260, top + 24, false);

    draw_set_color(active ? c_black : c_white);
    draw_text(30, top + 6, buttons[i]);
}

draw_set_color(c_white);
draw_text(20, 202, "UP/DOWN  ENTER  OR CLICK");
if (message != "") {
    draw_set_color(c_yellow);
    draw_text(20, 216, message);
}

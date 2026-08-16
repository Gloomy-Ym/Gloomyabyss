if (ui_state == 0) {
    exit;
}

var previous_alpha = draw_get_alpha();
var previous_colour = draw_get_color();
var previous_font = draw_get_font();
var previous_halign = draw_get_halign();
var previous_valign = draw_get_valign();

var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();
var eased_progress = ui_progress * ui_progress * (3 - 2 * ui_progress);
var margin = 24;
var panel_width = min(220, gui_width - margin * 2);
var panel_height = min(300, gui_height - margin * 2);
var panel_x = lerp(-panel_width - margin, margin, eased_progress);
var panel_y = (gui_height - panel_height) * 0.5;

draw_set_alpha(0.55 * eased_progress);
draw_set_color(c_black);
draw_rectangle(0, 0, gui_width, gui_height, false);

draw_set_alpha(eased_progress);
draw_set_color(c_black);
draw_rectangle(panel_x, panel_y, panel_x + panel_width, panel_y + panel_height, false);
draw_set_color(c_white);
draw_rectangle(panel_x, panel_y, panel_x + panel_width, panel_y + panel_height, true);

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

for (var i = 0; i < ui_entry_count; i++) {
    var entry_y = panel_y + 70 + i * 52;
    draw_set_color((i == ui_selected && ui_page == 0) ? c_yellow : c_white);
    draw_text(panel_x + 48, entry_y, ui_entries[i]);

    if (i == ui_selected && ui_page == 0) {
        draw_text(panel_x + 24, entry_y, ">");
    }
}

if (ui_page > 0) {
    var content_margin = 24;
    var content_x1 = panel_x + panel_width + content_margin;
    var content_x2 = gui_width - margin;

    if (content_x2 - content_x1 >= 160) {
        draw_set_color(c_black);
        draw_rectangle(content_x1, panel_y, content_x2, panel_y + panel_height, false);
        draw_set_color(c_white);
        draw_rectangle(content_x1, panel_y, content_x2, panel_y + panel_height, true);
        draw_set_valign(fa_top);
        draw_text(content_x1 + 24, panel_y + 24, ui_entries[ui_page - 1]);
        draw_set_color(c_gray);
        draw_text(content_x1 + 24, panel_y + 70, "PLACEHOLDER");
    }
}

draw_set_alpha(previous_alpha);
draw_set_color(previous_colour);
draw_set_font(previous_font);
draw_set_halign(previous_halign);
draw_set_valign(previous_valign);

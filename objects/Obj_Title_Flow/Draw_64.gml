var previous_alpha = draw_get_alpha();
var previous_colour = draw_get_color();
var previous_font = draw_get_font();
var previous_halign = draw_get_halign();
var previous_valign = draw_get_valign();

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(title_font >= 0 ? title_font : -1);

var center_x = display_get_gui_width() * 0.5;

switch (title_state) {
    case 0:
        draw_text(center_x, 88, "SELECT LANGUAGE");
        draw_text(center_x, 128, "> ENGLISH");
        draw_text(center_x, 168, "Z / ENTER - CONFIRM");
        break;

    case 1:
        draw_text(center_x, 216, "PRESS Z / ENTER");
        break;

    case 2:
        draw_text(center_x, 52, "FAN GAME / NON-COMMERCIAL");
        draw_text(center_x, 76, "UNDERTALE IS BY TOBY FOX");
        draw_text(center_x, 100, "UNDERTALE SOUNDS BY TOBY FOX");
        draw_text(center_x, 124, "CONTAINS FLASHING IMAGES");
        draw_text(center_x, 148, "RECOMMENDED FOR AGES 16+");
        draw_text(center_x, 184, "Z / ENTER - CONFIRM");
        break;

    case 3:
        draw_text(center_x, 104, "INTRO PLACEHOLDER");
        draw_text(center_x, 136, "Z / ENTER - SKIP");
        break;

    case 4:
        draw_text(center_x, 48, "GLOOMYTALE");
        for (var i = 0; i < array_length(title_main_entries); i++) {
            var label = title_main_entries[i];
            if (i == title_selected) {
                label = "> " + label;
            }
            draw_text(center_x, 92 + i * 28, label);
        }
        draw_text(center_x, 216, "Z / ENTER - SELECT");
        break;

    case 5:
        draw_text(center_x, 96, "SETTINGS PLACEHOLDER");
        draw_text(center_x, 128, "X / SHIFT - BACK");
        break;

    case 6:
        draw_text(center_x, 80, "GLOOMYTALE - NON-COMMERCIAL FAN GAME");
        draw_text(center_x, 104, "UNDERTALE BY TOBY FOX");
        draw_text(center_x, 136, "X / SHIFT - BACK");
        break;
}

draw_set_alpha(previous_alpha);
draw_set_color(previous_colour);
draw_set_font(previous_font);
draw_set_halign(previous_halign);
draw_set_valign(previous_valign);

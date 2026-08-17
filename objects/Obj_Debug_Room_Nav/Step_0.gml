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
var mouse_x_gui = device_mouse_x_to_gui(0);
var mouse_y_gui = device_mouse_y_to_gui(0);

nav_hovered = -1;
for (var i = 0; i < button_count; i++) {
    var button_x = start_x + i * (button_width + button_gap);
    var is_inside = point_in_rectangle(
        mouse_x_gui,
        mouse_y_gui,
        button_x,
        start_y,
        button_x + button_width,
        start_y + button_height
    );

    if (is_inside) {
        nav_hovered = i;
        break;
    }
}

if (nav_hovered >= 0 && mouse_check_button_pressed(mb_left)) {
    var target_room = nav_rooms[nav_hovered];
    if (target_room != room) {
        room_goto(target_room);
    }
}

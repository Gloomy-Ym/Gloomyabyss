// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

var count = array_length(buttons);

// 键盘选择
if (keyboard_check_pressed(vk_up)) {
    selected = (selected + count - 1) % count;
}
if (keyboard_check_pressed(vk_down)) {
    selected = (selected + 1) % count;
}

// 鼠标悬停 / 点击（按钮在 Draw GUI 里画，坐标也用 GUI 坐标）
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var clicked = mouse_check_button_pressed(mb_left);
var hovered = -1;

for (var i = 0; i < count; i++) {
    var top = 72 + i * 32;
    if (mx >= 20 && mx <= 260 && my >= top && my <= top + 24) {
        hovered = i;
    }
}
if (hovered >= 0) {
    selected = hovered;
}

if (keyboard_check_pressed(vk_enter) || (clicked && hovered >= 0)) {
    switch (selected) {
        case 0:
            var info = Scr_World_ImportGmapDialog();
            if (info != undefined) {
                message = "IMPORTED: " + info.name;
            } else {
                message = "IMPORT CANCELLED OR FAILED";
            }
            break;

        case 1:
            var overworld = Scr_World_Load("overworld");
            if (overworld == undefined) {
                message = "CANNOT READ OVERWORLD";
            } else if (Scr_World_ExportGmapDialog(overworld.dir)) {
                message = "EXPORTED OVERWORLD";
            } else {
                message = "EXPORT CANCELLED OR FAILED";
            }
            break;

        case 2:
            var corridor = Scr_World_Load("corridor");
            if (corridor == undefined) {
                message = "CANNOT READ CORRIDOR";
            } else if (Scr_World_ExportGmapDialog(corridor.dir)) {
                message = "EXPORTED CORRIDOR";
            } else {
                message = "EXPORT CANCELLED OR FAILED";
            }
            break;

        case 3:
            room_goto(Title_Room);
            break;
    }
}

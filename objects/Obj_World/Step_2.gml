// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon
//
// F3：调试界面开关
if (keyboard_check_pressed(vk_f3)) {
    global.Gloomy_Debug = !global.Gloomy_Debug;
}

// End Step：相机跟随
// 地图边界 = world.width/height * tile_size，相机夹在 [0, 地图尺寸 - 视口尺寸]

if (world == undefined || !variable_instance_exists(id, "camera") || camera == -1) {
    exit;
}

var view_w = camera_get_view_width(camera);
var view_h = camera_get_view_height(camera);
var left = world.min_col * world.tile_size;
var right = world.max_col * world.tile_size;
var top = world.min_row * world.tile_size;
var bottom = world.max_row * world.tile_size;

var target_x = 0;
var target_y = 0;

if (instance_exists(Obj_Player)) {
    target_x = Obj_Player.x - view_w * 0.5;
    target_y = Obj_Player.y - view_h * 0.5 - 10;
}

var final_x = target_x;
var final_y = target_y;

if (!world.unbounded_x) {
    final_x = clamp(target_x, left, max(left, right - view_w));
}
if (!world.unbounded_y) {
    final_y = clamp(target_y, top, max(top, bottom - view_h));
}

camera_set_view_pos(camera, final_x, final_y);

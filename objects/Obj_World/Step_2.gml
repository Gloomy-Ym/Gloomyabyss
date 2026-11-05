// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon
//
// F3：调试界面开关
if (keyboard_check_pressed(vk_f3)) {
    global.Gloomy_Debug = !global.Gloomy_Debug;
}

// End Step：相机跟随
// 玩家永远在视口中心，不再按地图边界夹取。

if (world == undefined || !variable_instance_exists(id, "camera") || camera == -1) {
    exit;
}

var view_w = camera_get_view_width(camera);
var view_h = camera_get_view_height(camera);

var target_x = 0;
var target_y = 0;

if (instance_exists(Obj_Player)) {
    target_x = Obj_Player.x - view_w * 0.5;
    target_y = Obj_Player.y - view_h * 0.5 - 10;
}

camera_set_view_pos(camera, target_x, target_y);

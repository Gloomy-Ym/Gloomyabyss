// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

if (world == undefined) {
    exit;
}

var cam_x = 0;
var cam_y = 0;
var cam_w = room_width;
var cam_h = room_height;

if (variable_instance_exists(id, "camera") && camera != -1) {
    cam_x = camera_get_view_x(camera);
    cam_y = camera_get_view_y(camera);
    cam_w = camera_get_view_width(camera);
    cam_h = camera_get_view_height(camera);
}

Scr_World_Draw(world, cam_x, cam_y, cam_w, cam_h);
Scr_World_DrawProps(world, cam_x, cam_y, cam_w, cam_h);

if (variable_instance_exists(id, "debug_draw") && debug_draw) {
    Scr_World_DrawSolids(world);
}

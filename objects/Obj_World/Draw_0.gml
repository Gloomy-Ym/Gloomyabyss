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

var eye_x = cam_x + cam_w * 0.5;
var eye_y = cam_y + cam_h * 0.5;
var player = instance_find(Obj_Player, 0);
if (instance_exists(player)) {
    eye_x = player.portal_eye_x;
    eye_y = player.portal_eye_y;
}
Scr_World_DrawPortalViews(world, cam_x, cam_y, cam_w, cam_h, eye_x, eye_y);

if (variable_global_exists("Gloomy_Debug") && global.Gloomy_Debug) {
    Scr_World_DrawSolids(world);
    draw_set_colour(c_yellow);
    draw_text(cam_x + 4, cam_y + 4, "DEBUG  F3");
    draw_set_colour(c_white);
}

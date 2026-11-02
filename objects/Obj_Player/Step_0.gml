// SPDX-License-Identifier: PolyForm-Noncommercial-1.0.0
// Copyright (C) 2026 Gloomy-Ym, JO-Beacon

var overworld_menu_open = variable_global_exists("Gloomy_Overworld_UI_Open") && global.Gloomy_Overworld_UI_Open;
var move_left = Scr_Input_KeyDown(ord("A")) || Scr_Input_KeyDown(vk_left);
var move_right = Scr_Input_KeyDown(ord("D")) || Scr_Input_KeyDown(vk_right);
var move_up = Scr_Input_KeyDown(ord("W")) || Scr_Input_KeyDown(vk_up);
var move_down = Scr_Input_KeyDown(ord("S")) || Scr_Input_KeyDown(vk_down);
var horizontal = move_right - move_left;
var vertical = move_down - move_up;

if (overworld_menu_open) {
    horizontal = 0;
    vertical = 0;
}

if (horizontal != 0 && vertical != 0) {
    horizontal *= 0.70710678;
    vertical *= 0.70710678;
}

if (vertical < 0) {
    player_direction = 3;
}
else if (vertical > 0) {
    player_direction = 0;
}
else if (horizontal < 0) {
    player_direction = 2;
}
else if (horizontal > 0) {
    player_direction = 1;
}

var is_moving = horizontal != 0 || vertical != 0;
if (is_moving) {
    player_frame_timer += 1;
    if (player_frame_timer >= 6) {
        player_frame_timer = 0;
        player_frame = (player_frame + 1) mod 4;
    }
}
else {
    player_frame = 0;
    player_frame_timer = 0;
}

image_index = player_direction * 4 + player_frame;
move_and_collide(horizontal * player_move_speed, 0, player_colliders);
move_and_collide(0, vertical * player_move_speed, player_colliders);
depth = -y;
